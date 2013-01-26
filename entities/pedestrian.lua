local pedestrian = class{name = "Pedestrian", inherits = Entity.BaseEntity,
	function (self, pos, angle, name)
		Entity.BaseEntity.construct (self, pos, vector(8, 16))
		self.visual = Image.pedestrian
		self.name = name
		self.angle = angle
		self.shape_offset = vector(7,0)

		self.speed = 96
		self.state = 'walk'
		self.lastStateUpdate = love.timer.getMicroTime()
		self.mass = 1

		self.angleSpeed = 10
		self.rayCastLengthForward = 20
		self.rayCastLengthSide = 15
		self.rayCastAngleSide = 3.14159 / 4 -- 45°

		self.hitList = {}
		self.debug = false
	end
}

function pedestrian:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList)
	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x, y
	hit.xn, hit.yn = xn, yn
	hit.fraction = fraction

	table.insert(hitList, hit)
	return 1 -- Continues with ray cast through all shapes.
end

function pedestrian:changeState(state)
	if self.state ~= state then
		self:log("Change state from " .. self.state .. " to " .. state)
		self.state = state
		self.lastStateUpdate = love.timer.getMicroTime()
	end
end

function pedestrian:updateState()
	local now = love.timer.getMicroTime()
	if now - self.lastStateUpdate < 0.5 then
		return
	end

	local r = math.random()

	if r > 0.8 then
		self:changeState ('stop')
	elseif r > 0.6 then
		self:changeState ('walkFast')
	else
		self:changeState ('walk')
	end

	self.lastStateUpdate = now
end

function pedestrian:mergeList(one, another)
	for i=1,#another do
		table.insert(one, another[i])
	end
end

function pedestrian:detectCollision(hitList)
	self.hitList = {}

	local hitsForward = {}
	local headingForward = vector (math.cos(self.angle), math.sin(self.angle))
	local ray_start = self.pos + headingForward * 4.5
	local ray = self.pos + headingForward * self.rayCastLengthForward 

	self:log ("ray_start: " .. tostring (ray_start) .. " ray: " .. tostring(ray - ray_start))

	State.game.world:rayCast(ray_start.x, ray_start.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction)
		return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitsForward)
	end )
	self:mergeList(self.hitList, hitsForward)

	-- If we have something in front of us we stop
	if #hitsForward > 0 then
		self:log("Front collision: " .. tostring(#hitsForward))
		if self.state == 'walkFast' then
			self:changeState ('walk')
		elseif self.state == 'walk' then
			self:changeState ('walkSlow')
		elseif self.state == 'walkSlow' then
			if math.random() > 0.5 then
				self:changeState ('left')
			else 
				self:changeState ('right')
			end
		end
		return
	end

	local hitsLeft = {}
	local headingLeft = vector (math.cos(self.angle - self.rayCastAngleSide), math.sin(self.angle - self.rayCastAngleSide))
	local ray = ray_start + headingLeft * self.rayCastLengthSide
	State.game.world:rayCast(ray_start.x, ray_start.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction)
		return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitsLeft)
	end )

	local hitsRight = {}
	local headingRight = vector (math.cos(self.angle + self.rayCastAngleSide), math.sin(self.angle + self.rayCastAngleSide))
	local ray = ray_start + headingRight * self.rayCastLengthSide
	State.game.world:rayCast(ray_start.x, ray_start.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction)
		return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitsRight)
	end )

	-- We turn right if something is on the left and on the right it is free.
	-- Or vise versa. If there is something on the left and on the right we stop
	if #hitsLeft > 0 and #hitsRight == 0 then
		self:log("Left collision (" .. #hitsLeft .. " left, " .. #hitsRight .. " right)")
		self:changeState('right')
	elseif #hitsRight > 0 and #hitsLeft == 0 then
		self:log("Right collision (" .. #hitsLeft .. " left, " .. #hitsRight .. " right)")
		self:changeState('left')
	elseif #hitsRight > 0 and #hitsLeft then
		self:log("Left and right collision (" .. #hitsLeft .. ", " .. #hitsRight .. " right)")
		self:changeState('reverse')
	elseif #hitsRight == 0 and #hitsLeft == 0 then
		self:changeState('walk')
	end
	self:mergeList(self.hitList, hitsLeft)
	self:mergeList(self.hitList, hitsRight)
	--]]
end

function pedestrian:update(dt)
	-- behavior
	self:updateFromPhysics()

	self:updateState()
	self:detectCollision()

	self.angle_velocity = 0 
	if self.state == 'left' then
		self.angle_velocity = -4
	elseif self.state == 'right' then
		self.angle_velocity = 4
	elseif self.state == 'reverse' then
		self.angle_velocity = 0 
	end

	local heading = vector (math.cos(self.angle), math.sin(self.angle))
	self.velocity = vector(0, 0)

	if self.state == 'walkFast' then
		self.velocity = heading * self.speed * 2.
	elseif self.state == 'walk' then
		self.velocity = heading * self.speed
	elseif self.state == 'walkSlow' then
		self.velocity = heading * self.speed * 0.8
	elseif self.state == 'stop' then
		self.velocity = vector(0, 0)
	elseif self.state == 'reverse' then
		self.velocity = heading * self.speed * -0.2
	end

	if (self.name) then
		self:log ("[" .. self.name .. "]: " .. self.state .. " velocity = " .. tostring(self.velocity))
	end

	self:updateToPhysics()
end

function pedestrian:beginContact (other_entity, contact_point, contact_normal, contact_velocity) 
	local impact = -contact_normal * contact_velocity

	if impact > GVAR.pedestrian_impact_kill then
		Signal.emit('pedestrian-killed', self)
	end
end

function pedestrian:draw()
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

function pedestrian:log(msg)
	if self.debug then
		local now = love.timer.getMicroTime()
		print(now .. " " .. (self.name or "unnamed") .. ": " .. msg)
	end
end

-- etc.

return pedestrian
