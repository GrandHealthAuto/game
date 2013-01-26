local _M = {} -- the module

-- callbacks:
-- function input.mappingDown(mapping, amount)
-- function input.mappingUp(mapping, amount)
_M.mappingDown = function() end
_M.mappingUp   = function() end

-- *replaces* mapping, e.g.
--
-- input.bind{
--     name = "left",
--     key  = {"left", "a"}, -- keys left and a
--     axis = -1,  -- joystick axis 1, negative
--     button = 1, -- joystick button 1
-- }
--
-- input.bind{
--     name = "right",
--     key  = {"right", "d"}, -- keys right and d
--     axis = 1,  -- joystick axis 1, positive
--     button = 2, -- joystick button 2
-- }
local mappings = {} -- the mappings
function _M.bind(t)
	assert(type(t) == "table" and t.name)

	for name in Set{'key', 'axis', 'button'} do
		if type(t[name]) ~= 'table' then
			t[name] = {t[name]}
		end
	end

	local m = {key = {}, axis = {}, button = {}, is_down = false, mag = 0}
	for name in Set{'key', 'axis', 'button'} do
		m[name] = t[name]
	end

	mappings[t.name] = m
end

-- call in love.update
function _M.update()
	for name, info in pairs(mappings) do
		local mag = 0
		mag = mag + (love.keyboard.isDown(unpack(info.key)) and 1 or 0)
		mag = mag + (love.joystick.isDown(1, unpack(info.button)) and 1 or 0)

		-- FIXME: more than one joystick?
		for _, axis in ipairs(info.axis) do
			mag = mag or love.joystick.getAxis(1, math.abs(axis)) * axis
		end

		local down = mag > .5
		if info.is_down ~= down then
			(down and _M.mappingDown or _M.mappingUp)(name, mag)
		end
		info.is_down = down
		info.mag     = math.min(mag, 1)
	end
end

-- returns true if mapping is down, false if not
function _M.isDown(mapping)
	return (mappings[mapping] or {}).is_down
end

-- returns value of axis in [0,1].
-- keys and buttons are either pressed (1) or not (0)
function _M.getDown(mapping)
	return (mappings[mapping] or {}).mag
end

return _M
