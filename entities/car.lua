local car = class{name = "Car", inherits = Entity.BaseEntity,
	function (self, pos, angle, name)
                Entity.BaseEntity.construct (self, pos, vector(32, 16))
		self.visual = Image.car
                self.name = name
                self.angle = angle
                self.debug = true
                self.state = 'drive'
                self.lastStateUpdate = love.timer.getMicroTime()

                self.rayCastLengthForward = 35
                self.rayCastLengthSide = 20
                self.rayCastAngleSide = 3.14159 / 4 -- 45°
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
    if r < 70 then
        self.state = 'drive'
    elseif r < 80 then
        self.state = 'left'
    elseif r < 90 then
        self.state = 'right'
    else
        self.state = 'halt'
    end

    if self.debug and oldState ~= self.state then
        print(self.name .. ": Change state from " .. oldState .. " to " .. self.state)
    end
end

function car:detectCollition(hitList)
    local headingForward = vector (math.cos(self.angle), math.sin(self.angle))
    local headingLeft = vector (math.cos(self.angle - self.rayCastAngleSide), math.sin(self.angle - self.rayCastAngleSide))
    local headingRight = vector (math.cos(self.angle + self.rayCastAngleSide), math.sin(self.angle + self.rayCastAngleSide))
    
    local ray = self.pos + headingForward * self.rayCastLengthForward
    State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction) 
        return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList) 
    end )
    local ray = self.pos + headingLeft * self.rayCastLengthSide
    State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction) 
        return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList) 
    end )
    local ray = self.pos + headingRight * self.rayCastLengthSide
    State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction) 
        return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList) 
    end )
end

function car:update(dt)
	-- behavior
        self:updateFromPhysics()
        self:updateState()
        
        if self.state == 'left' then
            self.angle = self.angle - 3.14159 / 2
            self.state = 'drive'
        elseif self.state == 'right' then
            self.angle = self.angle + 3.14159 / 2
            self.state = 'drive'
        end
            
	local heading = vector (math.cos(self.angle), math.sin(self.angle))

        local hitList = {}
        self:detectCollition(hitList)
        -- Collition detection
        if #hitList == 0 then
            --print("have " .. #hitList .. " hits")
            self.velocity = heading * 64
        else
            self.velocity = vector(0, 0)
            self.angle = self.angle + 0.3
        end

	if self.state == 'drive' then
            self.pos = self.pos + dt * self.velocity	
        end
	self.angle = self.angle + dt * self.angle_velocity
        
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
        end
end

-- etc.

return car
