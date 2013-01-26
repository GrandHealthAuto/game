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

function st:update(dt)
	Gui.group.push{grow = "down", pos={SCREEN_WIDTH/2-Gui.group.default.size[1]/2,SCREEN_HEIGHT/2}}
	Gui.Input{info = inputInfo, size={100}}
	
	Gui.group.pop{}
	-- on mouse move -> set widget focus to mouse
	if mouse_hot ~= Gui.mouse.getHot() then
		Gui.keyboard.setFocus(Gui.mouse.getHot() or Gui.keyboard.getFocus())
		mouse_hot = Gui.mouse.getHot()
	end
end

function st:draw()
	love.graphics.draw(Image.logo, SCREEN_WIDTH/2, SCREEN_HEIGHT/4, 0, 2, 2, Image.logo:getWidth()/2, Image.logo:getHeight()/2)
	love.graphics.setFont(Font.XPDR[16])
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

function st:keypressed(key,code)
	Gui.keyboard.pressed(key, code)
end

return st