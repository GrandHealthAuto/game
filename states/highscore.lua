local Gui = require "Quickie"

local highscorefetcher = require "highscore"
local hs = highscorefetcher.new()

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
		},
	}
	
	Gui.group.push{ grow="right", size={ 300, 30}, pos={10,10} }
	Gui.Label{text="Rank", size={100, 30}} Gui.Label{text="Name"} Gui.Label { text="Score"}
	Gui.group.pop{}
	
	local hsData = hs:getHighscore(0)
	if hsData then
		for i, player in pairs(hsData) do
			Gui.group.push{ grow="right", size={ 300, 30}, pos={10,0} }
			Gui.Label{text=player["rank"], size={100, 30}} Gui.Label{text=player["name"]} Gui.Label { text=player["value"]}
			Gui.group.pop{}
		end
	end
	
	if Gui.Button{text="Back"} then
		GS.switch(State.menu)
    end

	-- on mouse move -> set widget focus to mouse
	if mouse_hot ~= Gui.mouse.getHot() then
		Gui.keyboard.setFocus(Gui.mouse.getHot() or Gui.keyboard.getFocus())
		mouse_hot = Gui.mouse.getHot()
	end
	
	Gui.group.pop{}
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
