local st = GS.new()

st.world = {}

function st:resetWorld()
	st.world = love.physics.newWorld()
	print ("resetting world")
end

function st:addObstacle (pos, dimensions)
end

function st:init()
	print ("State.game.init()")
	self:resetWorld()

	self.player = Player (vector(40, 100), vector(32, 32))

	Obstacle (vector(192, 496), vector (64, 256))
	Obstacle (vector(512, 386), vector (64, 256))
	Obstacle (vector(386, 256), vector (64, 256))

	map, geometry = (require 'level-loader')('map.png', {
		width = 32, height = 32, {name = 'foo'}, {name = 'foo', is_collision_tile = true}
	}, {texture = 'tiles.png', frames = {
		{name = 'foo', uvRect = {u0 = 0, v0 = 0, u1 = 1, v1 = 1}}
	}})
	cam = Camera()
end

function st:leave()
	self.player = nil
end

function st:draw()
	cam:attach()

	love.graphics.setFont(Font[30])
	love.graphics.printf("GAME", 0,SCREEN_HEIGHT/4-Font[30]:getLineHeight(),SCREEN_WIDTH, 'center')

	map:draw(cam)
	for rect in pairs(geometry) do
		love.graphics.rectangle('line', rect.x-3, rect.y-3, rect.w-6, rect.h-6)
	end

	Entities.draw()

	cam:detach()
end

function st:update(dt)
--	self.world.update(dt)
	cam:lookAt(self.player.pos:unpack())

	Entities.update(dt)
end

function st:keypressed(key)
	if key == 'escape' then
		GS.switch (State.menu)
	end

	if self.player then
		if key == 'up' then
			self.player:accelerate(true)
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
		elseif key == 'left' then
			self.player:turn_left(nil)
		elseif key == 'right' then
			self.player:turn_right(nil)
		end
	end
end

return st
