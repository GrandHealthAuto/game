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

local function remove(entity, ...)
	assert(entity, "No entity to remove")
	entities[entity] = nil
	(entity.onDelete or _NOP_)(entity, ...)
end

local function clear(...)
	for e in pairs(entities) do
		remove(e, ...)
	end
end

-- Usage:
-- Entities.update(dt)
-- Entities.draw()
-- ...
return setmetatable({
	add    = add,
	remove = remove,
	clear  = clear,
}, {__index = function(_, func)
	return function(...)
		for e in pairs(entities) do
			(e[func] or _NOP_)(e,...)
		end
	end
end})
