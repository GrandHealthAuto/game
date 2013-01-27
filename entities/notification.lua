local notification = class{name = "notification",
	function(self, text, color)
		self.text = text
		self.color = color or {255, 255, 255, 255}
		self.duration = 2.
		self.size = 100
		self.angle = 0
		self.pos = vector(SCREEN_HEIGHT/2-Font.XPDR[self.size]:getLineHeight(),SCREEN_WIDTH)
		self.oldfont = {}

	Signal.register ('get-next-victim', function()
		self.oldfont = love.graphics.getFont()
		self.text = "PICKUP"
		Tween(self.duration, self.color, {255, 255, 255, 0})

	end)

	Signal.register ('victim-picked-up', function()
		self.oldfont = love.graphics.getFont()
		self.text = "BRING HOME"
		self.color = {255, 255, 255, 255}
		Tween(self.duration, self.color, {255, 255, 255, 0})
	end)
end}

function notification:draw()
	if self.duration > 0 then
		love.graphics.setColor(self.color)
		love.graphics.setFont(Font.XPDR[self.size])
		love.graphics.printf(self.text, self.angle, self.pos.x, self.pos.y, 'center')
		love.graphics.setFont(Font.XPDR[self.size])

		love.graphics.setFont(self.oldfont)
	end
end

return notification
