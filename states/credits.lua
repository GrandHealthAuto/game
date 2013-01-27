local Gui = require "Quickie"
local st = GS.new()

function st:update(dt)
	love.graphics.setFont(Font.XPDR[16])
	Gui.group{grow = "down", size = {500,40}, pos = {SCREEN_WIDTH/2-250,SCREEN_HEIGHT - 50}, function()
		if Gui.Button{text="BACK"} then
			GS.transition(.5, State.menu)
		end
	end}
end

function st:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Image.credits, 0,0)
	Gui.core.draw()
end

return st
