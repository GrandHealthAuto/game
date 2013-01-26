local victim = class{name = 'Victim',
	function (self, pos)
		local img = Image.pedestriandead
		self.ox = img:getWidth()/2
		self.oy = img:getHeight()/2
		self.pos = pos:clone()
		self.rot = math.random(0,2*math.pi)

		self.heartrate = 100

		self.is_stabilized = false
		Entities.add(self)
	end
}

function victim:draw()
	if not self.is_stabilized then
		love.graphics.draw(Image.pedestriandead, self.pos.x, self.pos.y, self.rot, 1,1, self.ox, self.oy)
	end
end

function victim:update(dt)
	if self.is_stabilized then
		self.heartrate = self.heartrate - 30 / 100 * dt -- 30 seconds to flatline
		if self.heartrate <= 0 then
			Entities.remove(self)
			State.game.victims[self] = nil
			if State.game.current_target == self then
				Signal.emit('get-next-victim')
			end
		end
	else
		-- FIXME: heartrate modification according to driving style
		if self.heartrate <= 0 or self.heartrate > 150 then
			Signal.emit('game-over', 'victim died in car')
		end
	end
end

function victim:stabilize()
	self.is_stabilized = true
	self.heartrate = 80
end

return victim
