local Gui = require "Quickie"

local highscorefetcher = require "highscore"
local hs = highscorefetcher.new()
local offset =0
local st = GS.new()
local mouse_hot, mouse_x, mouse_y
local hsData = nil

function st:enter()
	offset = 0
	mouse_hot, mouse_x, mouse_y = nil, nil, nil
	hsData = hs:getHighscore(offset)
end

function st:update(dt)
	local w = (SCREEN_WIDTH-50)/2
	love.graphics.setFont(Font.XPDR[16])
	Gui.group{grow = "down", size = {SCREEN_WIDTH-50,40}, pos = {25,SCREEN_HEIGHT - 90}, function()
		Gui.group{grow="right", size={w}, function()
			local ox = w + 5
			if offset > 0 then
				if Gui.Button{id = 'prev', text="PREVIOUS PAGE"} then
					offset = offset - 7
					if offset < 0 then offset = 0 end
					hsData = hs:getHighscore(offset)
				end
				ox = 0
			end
			if #hsData >= 7 then
				if Gui.Button{id = 'next', text="NEXT PAGE", pos = {ox}} then
					offset = offset + 7
					hsData = hs:getHighscore(offset)
				end
			end
		end}
		if Gui.Button{id = 'back', text="BACK"} then
			GS.switch(State.menu)
		end
	end}

	w = SCREEN_WIDTH-600
	love.graphics.setFont(Font.XPDR[20])
	Gui.group{grow = "down", size = {w,40}, pos = {300,SCREEN_HEIGHT * .51}, function()
		if hsData then
			for i = 1,math.min(#hsData, 7) do
				local player = hsData[i]
				Gui.group.push{grow="right", size={nil, 30}}
					Gui.Label{text=player.rank .. '. ',  align = "right", size = {20}}
					Gui.Label{text=player.name, align = "left", size = {w-114}}
					Gui.Label{text=player.value, align="right", size = {90}}
				Gui.group.pop{}
			end
		else
			Gui.Label{text="The highscore server is currently not reachable"}
		end
	end}

	-- on mouse move -> set widget focus to mouse
	if mouse_hot ~= Gui.mouse.getHot() then
		Gui.keyboard.setFocus(Gui.mouse.getHot() or Gui.keyboard.getFocus())
		mouse_hot = Gui.mouse.getHot()
	end
end

function st:draw()
    State.menu.draw(self)
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
