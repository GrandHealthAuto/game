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
	hs:set(0)
	print ("resetting world")
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
	self.map = map
end

function st:getStreetPos()
	local w = map.width
	local h = map.height
	for i = 0, 100 do
		local x = math.floor(math.random(0, w))
		local y = math.floor(math.random(0, h))
		if map:isStreet(x, y) then
			return map:mapCoordsCenter(x, y)
		end
	end
	return map:mapCoordsCenter(math.floor(math.random(0, w)), math.floor(math.random(0, h)))
end

function st:enter()
	self:resetWorld()

	self.player = Entity.player(map.rescue_zone)

	self.pedestrians = {}
	for i = 1,300 do
		local pos = vector(math.random(0,160 * 32), math.random(0,160 * 32))
		local pedestrian = Entity.pedestrian (pos, math.random(0,3.1415), "Person " .. i)
		table.insert(self.pedestrians, pedestrian)
	end

	for i = 1,80 do
		local pos = vector(math.random(0,160 * 32), math.random(0,160 * 32))
		pos = self:getStreetPos()
		local car = Entity.car (vector(map.rescue_zone.x + i * 100, map.rescue_zone.y + 30), 0, "Car " .. i)
		--car.direction = 'east'
		--car.angle = math.pi - math.random(0,1) + 0.5
		local car = Entity.car (pos, 0, "Car " .. i)
		--car:log(car.pos.x .. "," .. car.pos.y .. " " .. car.targetPos.x .. "," .. car.targetPos.y)
	end

	cam = Camera()
	cam.scale = 2
	cam.pos = vector(cam.x, cam.y)
	for rect in pairs(geometry) do
		Entity.obstacle(vector(rect.x + rect.w * 0.5, rect.y + rect.h * 0.5), vector (rect.w, rect.h))
	end

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
			hs:add(100)
			Signal.emit('get-next-victim')
		else -- pick up victim
			hs:add(50)
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
		Sound.static["shout"..math.random(2)]:play()
		local v = Entity.victim(pedestrian.pos)
		v.color = pedestrian.color
		self.victims[v] = v
		Entities.remove(pedestrian)
	end)

	Entities.registerPhysics(self.world)

	-- XXX: properly initialize this
	local v = Entity.victim(map.rescue_zone + vector(500,0))
	self.victims[v] = v
	Signal.emit('get-next-victim')

	self.heart_monitor = Entity.heartmonitor()
	self.radio = Entity.radio()
	st.sirensfx = false
end

function st:mappingDown(mapping)
	if mapping == 'action' then
	    if not st.sirensfx then
            Sound.static.siren:setVolume(0.2)
            Sound.static.siren:setLooping(true)
            st.sirensfx = Sound.static.siren:play() 
        else
            st.sirensfx:stop()
            st.sirensfx = false
        end
    end
end

function st:leave()
	hs:save()
	Signal.clear()
	Entities.clear()
	self.player = nil
end

function st:draw()
	love.graphics.setColor(255,255,255)
	cam:attach()
	map:draw(cam)
	Entities.draw()

	if self.player then
		self.player:draw()
	end

	self.heart_monitor:drawMarker()
	cam:detach()

	love.graphics.printf(hs.value, 0,4, SCREEN_WIDTH-10, 'right')
	self.heart_monitor:draw()
	self.radio:draw()
end

function st:update(dt)
	--FIXME
	local lookahead = self.player.velocity * 40 * dt
	lookahead.x = math.max(math.min(lookahead.x, 200), -200)
	lookahead.y = math.max(math.min(lookahead.y, 200), -200)
	cam.target = self.player.pos + lookahead
	if self.player.heading then
		cam.rot_target = self.player.heading:cross(self.player.velocity:normalized()) * .03
		cam.rot_target = math.min(math.max(cam.rot_target, -math.pi/20), math.pi/20)
		cam.rot = cam.rot + (cam.rot_target - cam.rot) * 5 * dt
	end

	-- awesome camera zooming
	--cam:zoomTo(2. -  self.player.velocity:len() * 0.001)

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

	self.heart_monitor:update(dt)
	Entities.update(dt)
end

return st
