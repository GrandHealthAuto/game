local http = require "socket.http"
local dkjson = require "dkjson/dkjson"

local Highscore = {}
Highscore.__index = Highscore
Highscore.server = "http://highscore.devedge.eu/"
Highscore.value = 0


local function new(name)
	return setmetatable({name = name or "no name"}, Highscore)
end

function Highscore:set(value)
	self.value = value
	return self
end

function Highscore:add(value)
	self.value = self.value + value
	return self
end

function Highscore:save()
	b,c,h = http.request(self.server .. "save/", "player=" .. self.name .. "&value=" .. self.value)
	if c == 200 or b == 1 then return true end	
	return false
end

function Highscore:getSavedHighscore()
	b,c,h = http.request(self.server .."get/", "name=" .. self.name)
	if not c == 200 then return false end
	return b
end

--- returns table, containing tables with keys name/value/rank 
function Highscore:getHighscore(offset)
	b,c,h = http.request(self.server .. "load/", "offset=" .. offset)
	if not c == 200 then return false end
	
	local obj, pos, err = dkjson.decode (b,1, nil)
	if err then
		return false
	end
	return obj
end

return setmetatable({
	new = new
},{ 
	__call = function(_,...) return new(...) end 
})