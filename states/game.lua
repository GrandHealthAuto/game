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

function st:addObstacle(pos, dimensions)
	local obstacle = Entity.obstacle (pos, dimensions)
	obstacle:registerPhysics (self.world, 0.)
end

function st:addPedestrian(pos, angle)
	local pedestrian = Entity.pedestrian (pos, angle)
	pedestrian:registerPhysics(self.world, 1.)
end

function st:beginContact (a, b, coll)
	local entity_a = a:getUserData()
	local entity_b = b:getUserData()

--	print ("entity_a = " .. tostring (entity_a))

	if a.collide ~= nil then
		a:collide (entity_b, coll)
	end

	if b.collide ~= nil then
		b:collide (entity_a, coll)
	end
end

function st:endContact (a, b, coll)
end

function st:init()
	print ("State.game.init()")
	self:resetWorld()

	self.player = Entity.player (vector(40, 100))
	self.player:registerPhysics (self.world, 1.)

        self.cars = {}
        for i = 1,30 do
            local pos = vector(math.random(0,SCREEN_WIDTH), math.random(0,SCREEN_HEIGHT)) 
            local car = Entity.car (pos, math.random(0,3.1415), "car" .. i)
            table.insert(self.cars, car)
        end

	map, geometry = (require 'level-loader')('map.png', require'tileinfo', require 'tiledata')
	cam = Camera()
    cam.scale = 2
	for rect in pairs(geometry) do
		self:addObstacle (vector(rect.x + rect.w * 0.5, rect.y + rect.h * 0.5), vector (rect.w, rect.h))
	end

	self:addPedestrian (vector(100, 100), 0 )
end

function st:leave()
end

function st:draw()
	cam:attach()

	love.graphics.setFont(Font[30])
	love.graphics.printf("GAME", 0,SCREEN_HEIGHT/4-Font[30]:getLineHeight(),SCREEN_WIDTH, 'center')

	map:draw(cam)

	Entities.draw()

	cam:detach()
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
