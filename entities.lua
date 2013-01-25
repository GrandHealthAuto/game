local entities = {}

local function _NOP_() end

-- Usage:
-- class{function(self)
--     STUFF()
--     Entities.add(self)
-- end}
local function add(entity)
	entities[entity] = assert(entity, "No entity to add")
end

local function remove(entity)
	assert(entity, "No entity to remove")
	entities[entity] = nil
end

-- Usage:
-- Entities.update(dt)
-- Entities.draw()
-- ...
return setmetatable({
	add      = add,
	remove   = remove,
}, {__index = function(_, f)
	return function(...)
		for e in pairs(entities) do
			(e[func] or _NOP_)(...)
		end
	end
end}
