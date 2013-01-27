local Gui = require "Quickie"
local st = GS.new()
local mouse_hot, mouse_x, mouse_y
local inputInfo={text=GVAR["player_name"]}
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

local t = 0
function st:update(dt)
	t = t + dt
	love.graphics.setFont(Font.XPDR[16])

	Gui.group.push{grow = "down", pos={SCREEN_WIDTH/2-Gui.group.default.size[1]/2,SCREEN_HEIGHT/2}}
		Gui.Label{text="Please enter your name and press >>Start<<"}
		Gui.Input{info = inputInfo}
		if Gui.Button{text="Start"} then
			GVAR['player_name'] = inputInfo["text"]
			GS.transition(.5, State.game)
		end
	Gui.group.pop{}
	-- on mouse move -> set widget focus to mouse
	if mouse_hot ~= Gui.mouse.getHot() then
		Gui.keyboard.setFocus(Gui.mouse.getHot() or Gui.keyboard.getFocus())
		mouse_hot = Gui.mouse.getHot()
	end
end

function st:draw()
	local w,h = Image.titlescreen:getWidth(), Image.titlescreen:getHeight()
	love.graphics.setColor(20,20,20)
	love.graphics.draw(Image.titlescreen,
		math.sin(.2*t)*20 + SCREEN_WIDTH/2, math.cos(.3*t)*20 + SCREEN_HEIGHT/2,
		math.sin(.02*t)*.05, 1.5,1.5, w/2,h/2)
	love.graphics.setColor(255,255,255)

	local lw,lh = Image.logo:getWidth(), Image.logo:getHeight()
	love.graphics.setScissor(0,SCREEN_HEIGHT/4-lh*.5, SCREEN_WIDTH,lh)
	love.graphics.draw(Image.titlescreen,
		SCREEN_WIDTH/2, math.sin(.01*t)*h/2 + SCREEN_HEIGHT/4,
		math.cos(.021*t)*.05, 1,1, w/2,h/2)
	love.graphics.draw(Image.logo, SCREEN_WIDTH/4, SCREEN_HEIGHT/4, math.sin(.021*t)*.05, .8, .8, lw/2,lh/2)
	love.graphics.setColor(122,0,10)
	love.graphics.rectangle('fill', 0,SCREEN_HEIGHT/4-lh*.5-2, SCREEN_WIDTH,9)
	love.graphics.rectangle('fill', 0,SCREEN_HEIGHT/4+lh*.5-7, SCREEN_WIDTH,7)
	love.graphics.setScissor()
	Gui.core.draw()
end

function st:mappingDown(mapping)
	-- sync keyboard and mouse highlight
	Gui.mouse.setHot(Gui.keyboard.getFocus())
	mouse_hot = Gui.mouse.getHot()
	-- FIXME: play sound
end

function st:keypressed(key,code)
	if (code >= 65 and code <= 90) or (code >=97 and code <=122) or code == 8 or code == 9  or code == 32 or key == "return" then
		Gui.keyboard.pressed(key, code)
	end
end

return st
