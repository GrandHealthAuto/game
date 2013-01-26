local Tween = require "tween"
local Ringbuffer = require "hump.ringbuffer"
local Gui = require "Quickie"

local st = GS.new()
function st:enter()
    Gui.core.style = require 'gui.style'
    Gui.group.default.size[1] = SCREEN_WIDTH
    Gui.group.default.size[2] = 25
    Gui.group.default.spacing = 5
end

function st:update(dt)
    Tween.update(dt)
    Gui.group.push{grow = "down", pos={SCREEN_WIDTH/2-Gui.group.default.size[1]/2,SCREEN_HEIGHT/2}}
    if Gui.Button{text="Start"} then
    end
    if Gui.Button{text="Highscore"} then
		GS.switch(State.highscore)
    end
    if Gui.Button{text="Options"} then
    end
    if Gui.Button{text="End"} then
    end
end

function st:draw()
	love.graphics.draw(Image.logo, SCREEN_WIDTH/2, SCREEN_HEIGHT/4, 0, 2, 2, Image.logo:getWidth()/2, Image.logo:getHeight()/2)
	love.graphics.setFont(Font.XPDR[16])
    Gui.core.draw()
end

return st