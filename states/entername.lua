local Gui = require "Quickie"
local st = GS.new()
local mouse_hot, mouse_x, mouse_y
local inputInfo={text=""}
function st:enter()
	Gui.core.style = require 'gui.style'
	Gui.group.default.size[1] = SCREEN_WIDTH
	Gui.group.default.size[2] = 25
	Gui.group.default.spacing = 5

	Gui.keyboard.cycle.prev = {key = 'select-prev'}
	Gui.keyboard.cycle.next = {key = 'select-next'}
	mouse_hot, mouse_x, mouse_y = nil, nil, nil

	Gui.keyboard.setFocus(nil)
	Gui.mouse.setActive(nil)
end

function st:leave()
	Gui.keyboard.pressed()
	Gui.keyboard.setFocus(nil)
end

local t = 0
function st:update(dt)
	t = t + dt
	love.graphics.setFont(Font.XPDR[16])

	Gui.group.push{grow = "down", size = {SCREEN_WIDTH-500,40}, pos = {SCREEN_WIDTH/2-250,SCREEN_HEIGHT * .6}}
		Gui.Label{text="What should I call you?"}
		Gui.Input{info = inputInfo}
		if inputInfo.text ~= '' then
			if Gui.Button{text="Start"} then
				GVAR['player_name'] = inputInfo["text"]
				GS.transition(.5, State.game)
				local amp = 1
				Timer.do_for(1, function(dt)
					amp = amp - dt
					State.menu.music:setVolume(math.max(0, amp))
				end, function()
					State.menu.music:stop()
					State.menu.music = false
				end)
			end
		end
		Gui.group.pop{}
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
		Gui.keyboard.pressed('return', -1)
	else
		return
	end

	-- sync keyboard and mouse highlight
	Gui.mouse.setHot(Gui.keyboard.getFocus())
	mouse_hot = Gui.mouse.getHot()
	-- FIXME: play sound
end

function st:keypressed(key,code)
	if (code >= 65 and code <= 90) or (code >=97 and code <=122) or code == 8 or code == 9  or code == 32 or key == "return" or key == "backspace" or key == "left" or key == "right" or key == "shift" then
		Gui.keyboard.pressed(key, code)
	end
end

return st
