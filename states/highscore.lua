local Gui = require "Quickie"

local st = GS.new()
function st:enter()
    Gui.core.style = require 'gui.style'
    Gui.group.default.size[1] = SCREEN_WIDTH
    Gui.group.default.size[2] = 25
    Gui.group.default.spacing = 5
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
end

function st:draw()
    Gui.core.draw()
end

return st