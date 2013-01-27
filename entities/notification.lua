local notification = class{name = "notification",
	function(self, text, color)
		self.text = text
		self.color = color or {255, 255, 0, 255}
		self.duration = 5.
		self.size = 64
		self.subtitleSize = 32
		self.subtext = "rescue the crash victim"
		self.angle = 0
		self.pos = vector(SCREEN_WIDTH/2-64,SCREEN_HEIGHT/2)
		self.oldfont = {}
		self.w, self.h = 512, 128
		
	function start()
		self.oldfont = love.graphics.getFont()
		self.text = "GO GO GO"
		self.color = {255, 255, 255, 255}
		self.subtext = "rescue the crash victim"
		self.pos = vector(SCREEN_WIDTH/2-self.w/2, SCREEN_HEIGHT/4)
		Tween(self.duration, self.color, {self.color[1],self.color[2],self.color[3],0})
	    Tween(self.duration, self.pos, {y = 100}, 'outSine')
	end
	start()

	Signal.register ('victim-picked-up', function()
		self.oldfont = love.graphics.getFont()
		self.text = "BRING EM HOME"
		self.color = {255, 255, 255, 255}
		self.subtext = "to the hospital"
		self.pos = vector(SCREEN_WIDTH/2-self.w/2, SCREEN_HEIGHT/4)
		Tween(self.duration, self.color, {self.color[1],self.color[2],self.color[3],0})
	    Tween(self.duration, self.pos, {y = 100}, 'outSine')
	end)
	
	Signal.register ('quest-finish', function()
		self.oldfont = love.graphics.getFont()
		self.text = "$$$"
		self.color = {255, 255, 255, 255}
		self.subtext = "nice one!"
		self.pos = vector(SCREEN_WIDTH/2-self.w/2, SCREEN_HEIGHT/4)
		Tween(self.duration, self.color, {self.color[1],self.color[2],self.color[3],0})
	    Tween(self.duration, self.pos, {y = 100}, 'outSine')	    
	end)
	
end}

function notification:draw()
	if self.duration > 0 then
		love.graphics.setFont(Font.XPDR[self.size])
		love.graphics.setColor(0,0,0,self.color[4])
		love.graphics.rectangle('fill', self.pos.x, self.pos.y, self.w, self.h)
        love.graphics.setColor(255,0,0,self.color[4])
        love.graphics.print(self.text, self.pos.x+self.w/2-Font.XPDR[self.size-2]:getWidth(self.text)/2, self.pos.y+8)
        love.graphics.setColor(self.color)
		love.graphics.setFont(Font.XPDR[self.size-2])
        love.graphics.print(self.text, self.pos.x+self.w/2-Font.XPDR[self.size-2]:getWidth(self.text)/2, self.pos.y+8)
		love.graphics.setFont(Font.XPDR[self.subtitleSize])
        love.graphics.print(self.subtext, self.pos.x+self.w/2-Font.XPDR[self.subtitleSize]:getWidth(self.subtext)/2, self.pos.y+self.size)
		love.graphics.setFont(self.oldfont)
	end
end

return notification
