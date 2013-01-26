local cls = Class{name = "Template", function(self)
	Entities.add(self)
	-- more init stuff
end}

function cls:update(dt)
	-- behavior
end

function cls:draw()
	-- appearance
end

function cls:onCollide(other, contact)
	-- collision callback with other
	Entities.remove(self)
end

-- etc.

return cls
