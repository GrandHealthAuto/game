local obstacle = class{inherits = Entity.BaseEntity,
	function (self, pos, dimensions)
		Entity.BaseEntity.construct (self, pos, dimensions)
	end
}

return obstacle
