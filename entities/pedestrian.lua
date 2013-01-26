local pedestrian = class{inherits = Entity.BaseEntity,
	function (self, pos, angle)
		Entity.BaseEntity.construct (self, pos, vector(15, 28))
		self.visual = Image.pedestrian
		self.angle = angle
	end
}

function pedestrian:update(dt)
	self:updateFromPhysics()

	local heading = vector (math.cos(self.angle), math.sin(self.angle))
	self.velocity = vector (0, 0)

	self.pos = self.pos + dt * self.velocity	
	self.angle = self.angle + dt * self.angle_velocity

	self:updateToPhysics()
end

return pedestrian
