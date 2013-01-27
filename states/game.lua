local highscore = require "highscore"
local hs = highscore(GVAR['player_name'])
local st = GS.new()
local oldScore = 0
st.world = {}

function st:resetWorld()
	st.world = love.physics.newWorld()

	st.world:setCallbacks (
		function(a, b, coll) self:beginContact (a, b, coll) end,
		function(a, b, coll) self:endContact (a, b, coll) end
		)
	hs:set(0)
	oldScore = hs:getSavedHighscore()
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

function st:enter()
	self:resetWorld()

	self.cam = Camera()
	self.cam.scale = 2
	self.cam.pos = vector(self.cam.x, self.cam.y)

	self.player = Entity.player(map.rescue_zone)

	-- pedestrians and cars
	self.flock = Entity.flock(50, 10)

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
		-- hs:add(-100)
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
	elseif mapping == 'escape' then
		local continue
		continue = Interrupt{
			draw = function(draw)
				draw()
				love.graphics.setColor(0,0,0,200)
				love.graphics.rectangle('fill', 0,0,SCREEN_WIDTH,SCREEN_HEIGHT)

				love.graphics.setColor(255,255,255)
				love.graphics.setFont(Font.XPDR[16])
				love.graphics.printf("- PAUSE -", 0,SCREEN_HEIGHT/2-Font[30]:getLineHeight(),SCREEN_WIDTH, 'center')
				love.graphics.printf("Press [Escape] to quit game", 0,SCREEN_HEIGHT/2-Font[30]:getLineHeight() + 30,SCREEN_WIDTH, 'center')
				love.graphics.printf("or [Return] to continue", 0,SCREEN_HEIGHT/2-Font[30]:getLineHeight() + 60,SCREEN_WIDTH, 'center')
			end, update = function() Input.update() end,
		}

		local mappingDown = Input.mappingDown
		Input.mappingDown = function(mapping, mag)
			if mapping == 'escape' then
				love.audio.stop()
				GS.switch(State.menu)
				continue()
				Input.mappingDown = mappingDown
			elseif mapping == 'action' then
				continue()
				Input.mappingDown = mappingDown
			end
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
	--local cs = self.cam.scale
	--self.cam.scale = .5
	self.cam:attach()
	--self.cam.scale = cs
	map:draw(self.cam)
	Entities.draw()

	if self.player then
		self.player:draw()
	end

	self.heart_monitor:drawMarker()
	self.cam:detach()

	scoretext = ""
	if oldScore then
		scoretext = scoretext .. " Previous Score: "..oldScore
	end
	love.graphics.printf(scoretext .." Score: "..hs.value, 0,4, SCREEN_WIDTH-15, 'right')
	love.graphics.printf(hs.value, 0,4, SCREEN_WIDTH-10, 'right')
	love.graphics.printf((self.player.gui_speed .. " km/h"), 0, SCREEN_HEIGHT - 20, SCREEN_WIDTH-10, 'right')

	self.heart_monitor:draw()
	self.radio:draw()
end

function st:update(dt)
	--FIXME
	local lookahead = self.player.velocity * 40 * dt
	lookahead.x = math.max(math.min(lookahead.x, 200), -200)
	lookahead.y = math.max(math.min(lookahead.y, 200), -200)
	self.cam.target = self.player.pos + lookahead
	if self.player.heading then
		self.cam.rot_target = self.player.heading:cross(self.player.velocity:normalized()) * .03
		self.cam.rot_target = math.min(math.max(self.cam.rot_target, -math.pi/20), math.pi/20)
		self.cam.rot = self.cam.rot + (self.cam.rot_target - self.cam.rot) * 5 * dt
	end

	-- awesome camera zooming
	self.cam:zoomTo(2.1 -  1 / (1 + math.exp(-.02 * self.player.velocity:len() + 5)) * .2)

	self.cam.direction = self.cam.target - self.cam.pos
	local delta = self.cam.direction * dt * 4
	if math.abs(self.cam.direction.x) > SCREEN_WIDTH/3 then
		delta.x = self.cam.direction.x
	end
	if math.abs(self.cam.direction.y) > SCREEN_HEIGHT/3 then
		delta.y = self.cam.direction.y
	end
	self.cam.pos = self.cam.pos + delta
	self.cam:lookAt(math.floor(self.cam.pos.x+.5), math.floor(self.cam.pos.y+.5))

	self.world:update(dt)

	self.heart_monitor:update(dt)
	Entities.update(dt)
end

return st
