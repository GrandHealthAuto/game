local Gui = require "Quickie"

local st = GS.new()
local mouse_hot, mouse_x, mouse_y
function st:enter()
	mouse_hot, mouse_x, mouse_y = nil, nil, nil
end

function st:update(dt)
    Gui.group.push{
		grow = "down", 
		pos={
			SCREEN_WIDTH/2-Gui.group.default.size[1]/2,
			--SCREEN_HEIGHT
			0
		}
	}
    if Gui.Button{text="Back"} then
		GS.switch(State.menu)
    end

	-- on mouse move -> set widget focus to mouse
	if mouse_hot ~= Gui.mouse.getHot() then
		Gui.keyboard.setFocus(Gui.mouse.getHot() or Gui.keyboard.getFocus())
		mouse_hot = Gui.mouse.getHot()
	end
end

function st:draw()
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
