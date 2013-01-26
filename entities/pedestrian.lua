local pedestrian = class{name = "Pedestrian", inherits = Entity.BaseEntity,
	function (self, pos, angle)
		Entity.BaseEntity.construct (self, pos, vector(15, 28))
		self.visual = Image.pedestrian
		self.angle = angle or 0
		self.mass = 1
		self.angle = angle
	end
}

function pedestrian:update(dt)
	self:updateFromPhysics()
	self:updateToPhysics()
end

return pedestrian
