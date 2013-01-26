local st = GS.new()

st.world = {}

function st:resetWorld()
	st.world = love.physics.newWorld()
	print ("resetting world")
end

function st:addObstacle(pos, dimensions)
	local obstacle = Entity.obstacle (pos, dimensions)
	obstacle:registerPhysics (self.world, 0.)
end

function st:init()
	print ("State.game.init()")
	self:resetWorld()

	self.player = Entity.player (vector(40, 100), vector(32, 32))
	self.player:registerPhysics (self.world, 1.)

	map, geometry = (require 'level-loader')('map.png', {
		width = 32, height = 32, {name = 'foo'}, {name = 'foo', is_collision_tile = true}
	}, {texture = 'tiles.png', frames = {
		{name = 'foo', uvRect = {u0 = 0, v0 = 0, u1 = 1, v1 = 1}}
	}})
	cam = Camera()

	for rect in pairs(geometry) do
		self:addObstacle (vector(rect.x + rect.w * 0.5, rect.y + rect.h * 0.5), vector (rect.w, rect.h))
	end
end

function st:leave()
	self.player = nil
end

function st:draw()
	cam:attach()

	love.graphics.setFont(Font[30])
	love.graphics.printf("GAME", 0,SCREEN_HEIGHT/4-Font[30]:getLineHeight(),SCREEN_WIDTH, 'center')

	map:draw(cam)

	Entities.draw()

	cam:detach()
end

function st:update(dt)
	cam:lookAt(self.player.pos:unpack())
	if self.world then
		self.world:update(dt)
	end

	Entities.update(dt)
end

function st:keypressed(key)
	if key == 'escape' then
		GS.switch (State.menu)
	end

	if self.player then
		if key == 'up' then
			self.player:accelerate(true)
		elseif key == 'down' then
			self.player:reverse(true)
		elseif key == 'left' then
			self.player:turn_left(true)
		elseif key == 'right' then
			self.player:turn_right(true)
		end
	end
end

function st:keyreleased(key)
	if self.player then
		if key == 'up' then
			self.player:accelerate(nil)
		elseif key == 'down' then
			self.player:reverse(nil)
		elseif key == 'left' then
			self.player:turn_left(nil)
		elseif key == 'right' then
			self.player:turn_right(nil)
		end
	end
end

return st
