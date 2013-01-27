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

function st:mappingDown(mapping)
	local cycle
	if mapping == 'up' then
		Gui.keyboard.pressed('select-prev')
	elseif mapping == 'down' then
		Gui.keyboard.pressed('select-next')
	elseif mapping == 'action' then
		Gui.keyboard.pressed('return')
	else
		return
	end

	-- sync keyboard and mouse highlight
	Gui.mouse.setHot(Gui.keyboard.getFocus())
	mouse_hot = Gui.mouse.getHot()
	-- FIXME: play sound
end

return st
