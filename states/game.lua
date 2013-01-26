local st = GS.new()

st.world = {}

function st:resetWorld()
	st.world = love.physics.newWorld()

	st.world:setCallbacks (
		function(a, b, coll) self:beginContact (a, b, coll) end,
		function(a, b, coll) self:endContact (a, b, coll) end
		)
	print ("resetting world")
end

function st:beginContact (a, b, coll)
	local entity_a = a:getUserData()
	local entity_b = b:getUserData()

	if entity_a.beginContact ~= nil then
		entity_a:beginContact (entity_b, coll)
	end

	if entity_b.beginContact ~= nil then
		entity_b:beginContact (entity_a, coll)
	end
end

function st:endContact (a, b, coll)
	local entity_a = a:getUserData()
	local entity_b = b:getUserData()

	if entity_a.endContact ~= nil then
		entity_a:endContact (entity_b, coll)
	end

	if entity_b.endContact ~= nil then
		entity_b:endContact (entity_a, coll)
	end
end

local map, geometry
function st:init()
	map, geometry = (require 'level-loader')('map.png', require'tileinfo', require 'tiledata')
end

function st:enter()
	self:resetWorld()

	self.player = Entity.player(map.rescue_zone)

	self.cars = {}
	for i = 1,30 do
		local pos = vector(math.random(0,SCREEN_WIDTH), math.random(0,SCREEN_HEIGHT))
		local car = Entity.car (pos, math.random(0,3.1415), "car" .. i)
		table.insert(self.cars, car)
	end

	cam = Camera()
    cam.scale = 2
	for rect in pairs(geometry) do
		Entity.obstacle(vector(rect.x + rect.w * 0.5, rect.y + rect.h * 0.5), vector (rect.w, rect.h))
	end
	Entity.pedestrian(vector(100, 100), 0)

	self.marker = Entity.questmarker(map.rescue_zone)
	Entities.registerPhysics(self.world)

	self.pickup_progress = 0
	self.victim_on_board = false
	Signal.register('victim-picked-up', function()
		self.pickup_progress = 0
		if self.victim_on_board then
			-- delivered at hospital
			self.marker.physics.body:setPosition(map.rescue_zone:unpack())
			self.victim_on_board = false
		else
			-- victim picked up
			self.victim_on_board = true
			-- TODO: next victim
			self.marker.physics.body:setPosition(math.random(0,#map[1]*32), math.random(0, #map*32))
		end
		self.marker:updateFromPhysics()
	end)
	Signal.register('victim-pickup-timer', function(progress)
		self.pickup_progress = progress
	end)
	Signal.register('victim-pickup-abort', function()
		self.pickup_progress = 0
	end)

	Signal.emit('victim-picked-up')
end

function st:leave()
	Signal.clear('victim-picked-up', 'victim-pickup-timer', 'victim-pickup-abort')
	Entities.clear()
	self.player = nil
end

function st:draw()
	cam:attach()
	map:draw(cam)
	Entities.draw()

	if self.marker then
		local ppos = vector(self.player.physics.body:getPosition())
		local qpos = vector(self.marker.physics.body:getPosition())
		local dir  = (qpos - ppos):normalize_inplace()

		-- TODO: this in pretty
		love.graphics.setLine(5, 'smooth')
		love.graphics.setColor(255,100,100)
		love.graphics.line(ppos.x+dir.x*40, ppos.y+dir.y*40, (ppos+dir*60):unpack())
		love.graphics.setColor(255,255,255)
		love.graphics.setLine(1, 'rough')
	end

	cam:detach()

	if self.pickup_progress > 0 then
		local p = self.pickup_progress
		love.graphics.setColor((1-p)*200+55,p*200+55,55)
		love.graphics.setLine(2, 'smooth')
		love.graphics.rectangle('line', 10,SCREEN_HEIGHT-40, SCREEN_WIDTH-20, 30)
		love.graphics.rectangle('fill', 14,SCREEN_HEIGHT-36, p*(SCREEN_WIDTH-28), 22)
		love.graphics.setLine(1, 'rough')
		love.graphics.setColor(255,255,255)
	end
end

local timeslice = 0
function st:update(dt)
	cam:lookAt(self.player.pos:unpack())
	if self.world then
		timeslice = timeslice + dt
		while timeslice > 1/60 do
			self.world:update(1/60)
			timeslice = timeslice - 1/60
		end
	end

	Entities.update(dt)
end

return st
