local car = class{name = "Car", inherits = Entity.BaseEntity,
	function (self, pos, angle, name)
		Entity.BaseEntity.construct (self, pos, vector(15, 28))
		self.visual = Image.car
		self.name = name
		self.angle = angle
		self.shape_offset = vector(7,0)
		self.targetPos = vector(0,0)
		self.speed = 70
		self.state = 'drive'
		self.lastStateUpdate = love.timer.getMicroTime()
		self.mass = 1

		self.direction = 'east'
		self.hitList = {}
		self.debug = false
	end
}

-- get collision lines
function car:getCollisionLines() 
	local lines = {}
	
	local headingSize = 40
	local headingAngle = 3.14159 / 36 * 6 -- 30°

	local headingLeft = self.pos + headingSize * vector (math.cos(self.angle - headingAngle), math.sin(self.angle - headingAngle))
	local headingRight = self.pos + headingSize * vector (math.cos(self.angle + headingAngle), math.sin(self.angle + headingAngle))

	table.insert(lines, {x1 = self.pos.x, y1 = self.pos.y, x2 = headingLeft.x, y2 = headingLeft.y })
	table.insert(lines, {x1 = self.pos.x, y1 = self.pos.y, x2 = headingRight.x, y2 = headingRight.y })
	table.insert(lines, {x1 = headingLeft.x, y1 = headingLeft.y, x2 = headingRight.x, y2 = headingRight.y })
	return lines
end

-- Add collition hit to own hit list
function car:collisionHitCallback(fixture, x, y, xn, yn, fraction)
	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x, y
	hit.xn, hit.yn = xn, yn
	hit.fraction = fraction

	table.insert(self.hitList, hit)
	return 1 -- Continues with ray cast through all shapes.
end

-- detect any collision
function car:detectCollision()
	if self.state == 'reverse' then
		return
	end

	local lines = self:getCollisionLines()
	for i = 1,#lines do
		State.game.world:rayCast(lines[i].x1, lines[i].y1, lines[i].x2, lines[i].y2, function (fixture, x, y, xn, yn, fraction)
			return self:collisionHitCallback(fixture, x, y, xn, yn, fraction)
		end )
	end
end

function car:setState(state)
	if self.state ~= state then
		self:log("Change state from " .. self.state .. " to " .. state)
		self.state = state
	end
end

function car:updateStateMachine()
	if self.state == 'drive' then
		if #self.hitList > 0 then
			self:setState('pause')
		end
	elseif self.state == 'pause' then
		if #self.hitList == 0 then
			self:setState('drive')
		end
	end
end

-- Return angle between two points
function car:getAngle(p1, p2)
	local x = p2.x - p1.x
	local y = p2.y - p1.y

	if x == 0 and y >= 0 then
		return 0
	elseif x == 0 then
		return 3.14159
	else
		return math.atan2(y, x)
	end
end

function car:updatePosition(dt, angle) 
	local heading = vector (math.cos(angle), math.sin(angle))
	
	if self.state == 'drive' then
		self.velocity = heading * self.speed
		self.pos = self.pos + dt * self.velocity
	elseif self.state == 'pause' then
		self.velocity = self.velocity * 0.7
	end
end

function car:getMapDx()
	if self.direction == 'east' then
		return 1
	elseif self.direction == 'west' then
		return -1
	else
		return 0
	end
end

function car:getMapDy()
	if self.direction == 'south' then
		return 1
	elseif self.direction == 'north' then
		return -1
	else
		return 0
	end
end

function car:canDriveAhead(map, x, y, dx, dy)
	self:log(x .. "," .. y .. ":isStreet: " .. tostring(map:isStreet(x, y)))
	self:log(x .. "," .. y .. ":isSidewalk: " .. tostring(map:isSidewalk(x, y)))
	if map:isStreet(x + dx, y + dy) then
		self:log("is street")
		return true
	end
	return false
end

-- Returns new direction. One of north, east, south, west, 
-- north-east, north-west, south-east, south-west directions
function car:getTargetPosition()
	local map = State.game.map
	local x, y = map:tileCoords(self.pos.x, self.pos.y)
	self:log(self.pos.x .. "," .. self.pos.y .. " at tile " .. x .. "," .. y)

	local dx = self:getMapDx()
	local dy = self:getMapDy()
	
	if self:canDriveAhead(map, x, y, dx, dy) then
		local x1, y1, x2, y2 = map:mapCoords(x + dx, y + dy)
		return vector(math.floor(x2 - x1), math.floor(y2 - y1))
	else
		self:log("Can not drive forward")
		return self.pos
	end
end

function car:update(dt)
	self.hitList = {}
	self:updateFromPhysics()
	-- behavior
	self:detectCollision()
	self:updateStateMachine()
	self.targetPos = self:getTargetPosition()
	local angle = self:getAngle(self.pos, self.targetPos)
	self:log("Target position is " .. self.targetPos.x .. ", " .. self.targetPos.y .. " with angle " .. angle)
	self:updatePosition(dt, angle)

	self:updateToPhysics()
end

function car:draw()
	Entity.BaseEntity.draw(self)

	if self.debug then
		local lines = self:getCollisionLines()
		for i = 1,#lines do
			love.graphics.line(lines[i].x1, lines[i].y1, lines[i].x2, lines[i].y2)
		end	

		local crossSize = 5
		for i = 1,#self.hitList do
			local hit = self.hitList[i]
			love.graphics.line(hit.x-crossSize, hit.y-crossSize, hit.x+crossSize, hit.y+crossSize)
			love.graphics.line(hit.x-crossSize, hit.y+crossSize, hit.x+crossSize, hit.y-crossSize)
		end
		love.graphics.line(self.pos.x, self.pos.y, self.targetPos.x, self.targetPos.y)
	end
end

function car:log(msg)
	if self.debug then
		local now = love.timer.getMicroTime()
		print(now .. " " .. self.name .. ": " .. msg)
	end
end

return car