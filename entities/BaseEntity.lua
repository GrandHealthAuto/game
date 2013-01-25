local base_entity = class{name = "BaseEntity", function (self, pos, dimensions)
	self.pos = pos:clone()
	self.dimensions = dimensions:clone()
	self.velocity = vector(0,0)
	self.angle = 0.
	self.angle_velocity = 0.

	print ("adding base_entity")
	Entities.add(self)
end
}

function base_entity:draw()
	if self.visual then
		love.graphics.draw (
		self.visual,
		self.pos.x, self.pos.y, self.angle,
		1, 1,
		self.dimensions.x * 0.5, self.dimensions.y * 0.5
		)
	else
		love.graphics.rectangle (
		'fill',
		self.pos.x - self.dimensions.x * 0.5,
		self.pos.y - self.dimensions.y * 0.5,
		self.dimensions.x,
		self.dimensions.y
		)
	end
end

return base_entity
