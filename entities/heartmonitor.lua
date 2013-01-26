local monitor = class{name = 'Heartmonitor',
	function (self)
		self.t = 0
		self.scale = 2
		self.ox = Image.heart:getWidth()/2
		self.oy = Image.heart:getHeight()/2
		self.x = SCREEN_WIDTH/2
		self.y = self.oy+20
	end
}

function monitor:draw()
	if not State.game.current_target then return end
	love.graphics.draw(Image.heart, self.x,self.y, 0, self.scale, self.scale, self.ox, self.oy)
end

function monitor:update(dt)
	self.t = self.t + dt
	local tmax = 60 / State.game.current_target.heartrate
	if self.t >= tmax then
		self.t = self.t - tmax
		Tween(.1, self, {scale = 2.3}, 'outBack', function()
			-- FIXME: heartbeat sound
			Tween(.1, self, {scale = 2}, 'outBack')
		end)
	end
end


return monitor
