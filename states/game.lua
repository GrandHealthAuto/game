local st = GS.new()

st.world = {}

function st:resetworld()
	st.world = love.physics.newWorld()
	print ("resetting world")
end

function st:addObstacle (pos, dimensions)
end

function st:init()
	print ("State.game.init()")
	self:resetworld()
	self.player = Player (vector(40, 100), vector(32, 32))
end

function st:leave()
	self.player = nil
end

function st:draw()
	love.graphics.setFont(Font[30])
	love.graphics.printf("GAME", 0,SCREEN_HEIGHT/4-Font[30]:getLineHeight(),SCREEN_WIDTH, 'center')

	Entities.draw()
end

function st:update(dt)
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
