local highscore = require "highscore"
local hs = highscore(GVAR['player_name'])

local st = GS.new()

st.world = {}

function st:resetWorld()
	st.world = love.physics.newWorld()

	st.world:setCallbacks (
		function(a, b, coll) self:beginContact (a, b, coll) end,
		function(a, b, coll) self:endContact (a, b, coll) end
		)
end

function st:beginContact (a, b, coll)
	local entity_a = a:getUserData()
	local entity_b = b:getUserData()

	local a_x, a_y, b_x, b_y = vector(coll:getPositions())

	local c_point = vector(a_x, a_y)
	local c_normal = vector(coll:getNormal())
	local c_velocity = entity_b.velocity - entity_a.velocity

	if entity_a.beginContact ~= nil then
		entity_a:beginContact (entity_b, c_point, c_normal, c_velocity)
	end

	if entity_b.beginContact ~= nil then
		entity_b:beginContact (entity_a, c_point, c_normal * -1., c_velocity * -1.)
	end
end

function st:endContact (a, b, coll)
	local entity_a = a:getUserData()
	local entity_b = b:getUserData()

	if entity_a.endContact ~= nil then
		entity_a:endContact (entity_b)
	end

	if entity_b.endContact ~= nil then
		entity_b:endContact (entity_a)
	end
end

local map, geometry
function st:init()
	map, geometry = (require 'level-loader')('map.png', require'tileinfo', require 'tiledata')
end

function st:enter()
	self:resetWorld()

	self.player = Entity.player(map.rescue_zone)

	self.pedestrians = {}
	for i = 1,30 do
		local pos = vector(math.random(0,SCREEN_WIDTH), math.random(0,SCREEN_HEIGHT))
		local pedestrian = Entity.pedestrian (pos, math.random(0,3.1415), "Person " .. i)
		table.insert(self.pedestrians, pedestrian)
	end

	-- test pedestrian
	local pedestrian = Entity.pedestrian (vector(2580, 3120) , 0., "Crash Dummy")
	table.insert(self.pedestrians, pedestrian)

	cam = Camera()
	cam.scale = 2
	cam.pos = vector(cam.x, cam.y)
	for rect in pairs(geometry) do
		Entity.obstacle(vector(rect.x + rect.w * 0.5, rect.y + rect.h * 0.5), vector (rect.w, rect.h))
	end
	Entity.pedestrian(vector(100, 100), 0)

	self.marker = Entity.questmarker(map.rescue_zone)

	self.victims = {}
	self.current_target    = false
	self.current_passanger = false
	self.pickup_progress   = 0

	Signal.register('victim-pickup-timer', function(p)
		self.pickup_progress = p
	end)

	Signal.register('victim-pickup-abort', function()
		self.pickup_progress = 0
	end)

	Signal.register('victim-picked-up', function()
		if self.current_passanger then -- deliver at hospital
			self.current_passanger = false
			Signal.emit('get-next-victim')
		else -- pick up victim
			self.victims[self.current_target] = nil
			self.current_passanger = self.current_target
			self.current_passanger:stabilize()
			self.current_target = false
			self.marker.physics.body:setPosition(map.rescue_zone:unpack())
			self.marker:updateFromPhysics()
		end
	end)

	Signal.register('get-next-victim', function()
		local target = next(self.victims)
		if not target then
			Signal.emit('game-over', 'no more victims')
			return
		end
		self.current_target = target
		self.marker.physics.body:setPosition(self.current_target.pos:unpack())
		self.marker:updateFromPhysics()
		self.pickup_progress = 0
	end)

	-- pedestrians
	Signal.register('pedestrian-killed', function (pedestrian)
		hs:add(-100)
		local v = Entity.victim(pedestrian.pos)
		self.victims[v] = v
		Entities.remove(pedestrian)
	end)

	Entities.registerPhysics(self.world)

	-- XXX: properly initialize this
	local v = Entity.victim(map.rescue_zone + vector(500,0))
	self.victims[v] = v
	Signal.emit('get-next-victim')
end

function st:leave()
	hs:save()
	Signal.clear()
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
	love.graphics.draw(Image.heart, SCREEN_WIDTH/2-Image.heart:getHeight(), 0, 0, 2, 2)
end

function st:update(dt)
	cam.target    = self.player.pos + self.player.velocity * dt * 40

	-- awesome camera zooming
	-- cam:zoomTo(2. -  self.player.velocity:len() * 0.001)

	cam.direction = cam.target - cam.pos
	local delta = cam.direction * dt * 4
	if math.abs(cam.direction.x) > SCREEN_WIDTH/3 then
		delta.x = cam.direction.x
	end
	if math.abs(cam.direction.y) > SCREEN_HEIGHT/3 then
		delta.y = cam.direction.y
	end
	cam.pos = cam.pos + delta
	cam:lookAt(math.floor(cam.pos.x+.5), math.floor(cam.pos.y+.5))

	self.world:update(dt)

	Entities.update(dt)
end

return st
