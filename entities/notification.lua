local notification = class{name = "notification",
	function(self, text, color)
		self.text = text
		self.color = color or {255, 255, 0, 255}
		self.duration = 5.
		self.size = 64
		self.angle = 0
		self.pos = vector(SCREEN_WIDTH/2-64,SCREEN_HEIGHT/2)
		self.oldfont = {}

	Signal.register ('get-next-victim', function()
		self.oldfont = love.graphics.getFont()
		self.text = "GO GO GO"
		self.color = {255, 255, 255, 255}
		self.pos = vector(SCREEN_WIDTH/2-Font.XPDR[self.size]:getWidth(self.text)/2, SCREEN_HEIGHT/4)
		Tween(self.duration, self.color, {self.color[1],self.color[2],self.color[3],0})
	    Tween(self.duration, self.pos, {y = 100}, 'outSine')
	end)

	Signal.register ('victim-picked-up', function()
		self.oldfont = love.graphics.getFont()
		self.text = "BRING HOME"
		self.color = {255, 255, 255, 255}
		self.pos = vector(SCREEN_WIDTH/2-Font.XPDR[self.size]:getWidth(self.text)/2, SCREEN_HEIGHT/4)
		Tween(self.duration, self.color, {self.color[1],self.color[2],self.color[3],0})
	    Tween(self.duration, self.pos, {y = 100}, 'outSine')

	end)
end}

function notification:draw()
	if self.duration > 0 then
		love.graphics.setFont(Font.XPDR[self.size])
		love.graphics.setColor(0,0,0,self.color[4])
		love.graphics.rectangle('fill', self.pos.x-12, self.pos.y-4, Font.XPDR[self.size]:getWidth(self.text), self.size)
        love.graphics.setColor(255,0,0,self.color[4])
        love.graphics.print(self.text, self.pos.x-8, self.pos.y)
        love.graphics.setColor(self.color)
		love.graphics.setFont(Font.XPDR[self.size-2])
        love.graphics.print(self.text, self.pos.x, self.pos.y)
		love.graphics.setFont(Font.XPDR[self.size])

		love.graphics.setFont(self.oldfont)
	end
end

return notification
