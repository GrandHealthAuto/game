local obstacle = class{inherits = BaseEntity, 
	function (self, pos, dimensions)
		BaseEntity.construct (self, pos, dimensions)
	end
}

return obstacle
