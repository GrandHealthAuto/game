local obstacle = class{name = 'Obstacle', inherits = Entity.BaseEntity,
	function (self, pos, dimensions)
		Entity.BaseEntity.construct (self, pos, dimensions)
		self.mass = 0
	end
}

return obstacle
