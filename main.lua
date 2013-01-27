class      = require 'hump.class'
Timer      = require 'hump.timer'
vector     = require 'hump.vector'
Camera     = require 'hump.camera'
GS         = require 'hump.gamestate'
Signal     = require 'hump.signal'
Interrupt  = require 'interrupt'
Entities   = require 'entities'
Input      = require 'input'
Tween      = require "tween"

require 'slam'

-- evil global variables
GVAR = {
	draw_collision_boxes = false,

	player_linear_damping = 0.19 * 32,
	player_angular_damping = 0.1,

	player_accel = 35. * 32, -- m/s^2
	player_accel_max_speed = 20 * 32, -- m/s
	player_motor_sound_maxspeed = 20 * 32,
	player_reverse = -20. * 32, -- m/s^2
	player_reverse_max_speed = 20. * 32, -- m/s
	player_rotation_speed = 220 * math.pi / 180.,
	player_ortho_vel_skid_start = 150,

	pedestrian_linear_damping = 0.1 * 32,
	pedestriang_angular_damping = 10,
	pedestrian_impact_injury = 3000,
	pedestrian_impact_kill = 6000,
	
	player_name ="Player One"
}

function serialize(t, indent)
	local result = ""
	indent = "  " or indent
	for k,v in pairs(t) do
		if type(v) == "table" then
			result = result .. (indent .. " " .. k .. " = table (" .. tostring(v) .. "):") .. "\n"
			result = result .. serialize (v, indent .. "  ") .. "\n"
		else
			result = result .. (indent .. " " .. k .. " = " .. tostring(v)) .. "\n"
		end
	end

	return result
end

function GS.transition(length, to, ...)
	length = length or 1

	local fade_color, sw, t = {0,0,0,0}, GS.switch, 0
	local continue = Interrupt{
		__base = GS,
		draw = function(draw)
			draw()
			color = {love.graphics.getColor()}
			love.graphics.setColor(fade_color)
			love.graphics.rectangle('fill', 0,0,
				love.graphics.getWidth(), love.graphics.getHeight())
			love.graphics.setColor(color)
		end,
		update = function(up, dt)
			up(dt)
			t = t + dt
			local s = t/length
			fade_color[4] = math.min(255, math.max(0, s < .5 and 2*s*255 or (2 - 2*s) * 255))
		end,
		-- disable switching states while in transition
		switch = function() end,
		transition = function() end,
	}

	local args = {...}
	Timer.add(length / 2, function() sw(to, unpack(args)) end)
	Timer.add(length, continue)
end

-- minimum frame rate
local up = GS.update
GS.update = function(dt)
	--if love.keyboard.isDown('1') then dt = dt / 10 end -- slow mo
	return up(math.min(dt, 1/60))
end


-- shallow copy
function table.copy(t)
	local r = {}
	for k,v in pairs(t) do r[k] = v end
	return r
end

-- iterator over items, i.e. for item in Set{1, 2, 3} do print(item) end
function Set(t)
	local s = {}
	for _,k in ipairs(t) do
		s[k] = k
	end
	return pairs(s)
end


-- proxies
local function Proxy(f)
	return setmetatable({}, {__index = function(t,k)
		local v = f(k)
		t[k] = v
		return v
	end})
end

-- e.g. GS.switch(State.menu)
State  = Proxy(function(path) return require('states.' .. path) end)

-- e.g. Entity.pawn(x,y) -- spawns pawn at x,y
Entity = Proxy(function(path) return require('entities.' .. path) end)

-- e.g. love.graphics.draw(Image.car, self.x, self.y)
Image  = Proxy(function(path)
	local i = love.graphics.newImage('img/'..path..'.png')
	i:setFilter('nearest', 'nearest')
	return i
end)

-- e.g. love.graphics.setFont(Font[30])
--      love.graphics.setFont(Font.fontface[20])
Font = Proxy(function(arg)
	if tonumber(arg) then
		return love.graphics.newFont(arg)
	end
	return Proxy(function(size) return love.graphics.newFont('font/'..arg..'.ttf', size) end)
end)

-- e.g. Sound.static.splatter:play()
--      Sound.stream.music:play()
Sound = {
	static = Proxy(function(path) return love.audio.newSource('snd/'..path..'.ogg', 'static') end),
	stream = Proxy(function(path) return love.audio.newSource('snd/'..path..'.ogg', 'stream') end)
}


function love.quit()
	-- save state etc
end

function love.load()
	SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getWidth(), love.graphics.getHeight()
	GS.registerEvents()
	--GS.switch(State.splash)
	GS.switch(State.menu)

	love.physics.setMeter (32)

	Input.bind{name = 'left',   key = {'left'}, axis = -1}
	Input.bind{name = 'right',  key = {'right'}, axis = 1}
	Input.bind{name = 'up',     key = {'up'}, axis = {-2}}
	Input.bind{name = 'down',   key = {'down'}, axis = {2}}
	Input.bind{name = 'accelerate', key = {'up'}, axis = {-3}}
	Input.bind{name = 'decelerate', key = {'down'}, axis = {3}}
	Input.bind{name = 'action', key = {' ', 'enter', 'return'}, button = 1}
	Input.bind{name = 'escape', key = 'escape'} -- FIXME: add start button
end

function love.update(dt)
	Input.update()
	Timer.update(dt)
	Tween.update(dt)
end

function love.keypressed(key)
end

function Input.mappingDown(mapping, mag)
	GS.mappingDown(mapping, mag)
end

function Input.mappingUp(mapping, mag)
	GS.mappingUp(mapping, mag)
end
