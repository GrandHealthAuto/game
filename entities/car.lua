local car = class{name = "Car", inherits = Entity.BaseEntity,
	function (self, pos, angle, name)
                Entity.BaseEntity.construct (self, pos, vector(32, 16))
				self.visual = Image.car
                self.name = name
                self.angle = angle
                self.state = 'drive'
                self.lastStateUpdate = love.timer.getMicroTime()
		self.mass = 1

                self.angleRotateSide = 3.14159 / 2 -- 90°
                self.rayCastLengthForward = 35
                self.rayCastLengthSide = 20
                self.rayCastAngleSide = 3.14159 / 4 -- 45°

                self.hitList = {}
                self.debug = false
	end
}

function car:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList)
    local hit = {}
    hit.fixture = fixture
    hit.x, hit.y = x, y
    hit.xn, hit.yn = xn, yn
    hit.fraction = fraction

    table.insert(hitList, hit)
    return 1 -- Continues with ray cast through all shapes.
end

function car:updateState()
    local now = love.timer.getMicroTime()
    -- print(self.name .. " last update " .. self.lastStateUpdate .. " now " .. now)
    if now - self.lastStateUpdate < 2 then
        return
    end
    self.lastStateUpdate = now

    local oldState = self.state
    local r = math.random(0, 100)
    if r < 20 then
        self.state = 'fastdrive' -- 20%
    elseif r < 60 then
        self.state = 'drive' -- 40%
    elseif r < 70 then
        self.state = 'slowdrive' -- 10%
    elseif r < 80 then
        self.state = 'left' -- 10%
    elseif r < 90 then
        self.state = 'right' -- 10%
    else
        self.state = 'halt' -- 10%
    end

    if oldState ~= self.state then
        self:log("Change state from " .. oldState .. " to " .. self.state)
    end
end

function car:mergeList(one, another)
    for i=1,#another do
	table.insert(one, another[i])
    end
end

function car:detectCollision(hitList)

    local hitsForward = {}
    local headingForward = vector (math.cos(self.angle), math.sin(self.angle))
    local ray = self.pos + headingForward * self.rayCastLengthForward
    State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction)
        return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitsForward)
    end )
    self:mergeList(self.hitList, hitsForward)

    -- If we have something in front of us we stop
    if #hitsForward > 0 then
	self:log("Front collision")
	self.state = 'halt'
    end

    local hitsLeft = {}
    local headingLeft = vector (math.cos(self.angle - self.rayCastAngleSide), math.sin(self.angle - self.rayCastAngleSide))
    local ray = self.pos + headingLeft * self.rayCastLengthSide
    State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction)
        return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitsLeft)
    end )

    local hitsRight = {}
    local headingRight = vector (math.cos(self.angle + self.rayCastAngleSide), math.sin(self.angle + self.rayCastAngleSide))
    local ray = self.pos + headingRight * self.rayCastLengthSide
    State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction)
        return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitsRight)
    end )

    -- We turn right if something is on the left and on the right it is free.
    -- Or vise versa. If there is something on the left and on the right we stop
    if #hitsLeft > 0 and #hitsRight == 0 then
	self:log("Left collision (" .. #hitsLeft .. ", " .. #hitsRight .. " right)")
	self.angle = self.angle + 0.03
    elseif #hitsRight > 0 and #hitsLeft == 0 then
	self:log("Right collision (" .. #hitsLeft .. ", " .. #hitsRight .. " right)")
	self.angle = self.angle - 0.03
    elseif #hitsRight > 0 and #hitsLeft then
	self:log("Left and right collision (" .. #hitsLeft .. ", " .. #hitsRight .. " right)")
	self.state = 'halt'
    end
    self:mergeList(self.hitList, hitsLeft)
    self:mergeList(self.hitList, hitsRight)
end

function car:update(dt)
	-- behavior
        self:updateFromPhysics()
        self:updateState()

        if self.state == 'left' then
            self.angle = self.angle - self.angleRotateSide
            -- self.state = 'drive'
        elseif self.state == 'right' then
            self.angle = self.angle + self.angleRotateSide
            -- self.state = 'drive'
        end

        self:detectCollision()

	local heading = vector (math.cos(self.angle), math.sin(self.angle))

	if self.state == 'fastdrive' then
            self.pos = self.pos + dt * self.velocity * 2
	elseif self.state == 'drive' then
            self.pos = self.pos + dt * self.velocity
	elseif self.state == 'slowdrive' then
            self.pos = self.pos + dt * self.velocity * 0.5
        end

	-- self.angle = self.angle + dt * self.angle_velocity

	self:updateToPhysics()
end

function car:draw()
        Entity.BaseEntity.draw(self)

        if self.debug then
            local heading = vector (math.cos(self.angle), math.sin(self.angle))
            local ray = self.pos + heading * self.rayCastLengthForward
            love.graphics.line(self.pos.x, self.pos.y, ray.x, ray.y)

            local heading = vector (math.cos(self.angle - self.rayCastAngleSide), math.sin(self.angle - self.rayCastAngleSide))
            local ray = self.pos + heading * self.rayCastLengthSide
            love.graphics.line(self.pos.x, self.pos.y, ray.x, ray.y)

            local heading = vector (math.cos(self.angle + self.rayCastAngleSide), math.sin(self.angle + self.rayCastAngleSide))
            local ray = self.pos + heading * self.rayCastLengthSide
            love.graphics.line(self.pos.x, self.pos.y, ray.x, ray.y)

	    for i = 1,#self.hitList do
		local hit = self.hitList[i]
		love.graphics.line(hit.x, hit.y-10, hit.x, hit.y+10)
		love.graphics.line(hit.x-10, hit.y, hit.x+10, hit.y)
	    end
        end
end

function car:log(msg)
    if self.debug then
	print(self.name .. ": " .. msg)
    end
end

-- etc.

return car
