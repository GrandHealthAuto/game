local Ringbuffer = require "hump.ringbuffer"
local Gui = require "Quickie"

local st = GS.new()

function st:init()
	self.music = false
end

local mouse_hot, mouse_x, mouse_y
function st:enter()
	Gui.core.style = require 'gui.style'
	Gui.group.default.size[1] = SCREEN_WIDTH
	Gui.group.default.size[2] = 25
	Gui.group.default.spacing = 5

	Gui.keyboard.cycle.prev = {key = 'select-prev'}
	Gui.keyboard.cycle.next = {key = 'select-next'}
	mouse_hot, mouse_x, mouse_y = nil, nil, nil

	Image.logo:setFilter('linear', 'linear')
	Image.titlescreen:setFilter('linear', 'linear')

	Gui.keyboard.setFocus(nil)
	Gui.mouse.setActive(nil)

	if not self.music then
		self.music = Sound.stream.menu:play()
		self.music:setLooping(true)
	end
end

local t = 0
function st:update(dt)
	t = t + dt
	love.graphics.setFont(Font.XPDR[16])
	Gui.group.push{grow = "down", size = {SCREEN_WIDTH-50,40}, pos = {25,SCREEN_HEIGHT * .6}}
	if Gui.Button{text="START"} then
		self.music:stop()
		self.music = false
		GS.switch(State.entername)
	end
	if Gui.Button{text="HIGHSCORES"} then
		GS.switch(State.highscore)
	end
	if Gui.Button{text="CREDITS"} then
		GS.transition(.5, State.credits)
	end
	if Gui.Button{text="QUIT"} then
		love.event.push('quit')
	end

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
