local player = class{inherits = Entity.BaseEntity,
	function (self, pos, dimensions)
		Entity.BaseEntity.construct (self, pos, dimensions)
		self.visual = Image.ambulance
	end
}

function player:update(dt)
	self:updateFromPhysics()

	local heading = vector (math.cos(self.angle), math.sin(self.angle))

	self.velocity = vector (0, 0)

	if Input.isDown('up') then
		self.velocity = heading * 128
	elseif Input.isDown('down') then
		self.velocity = heading * -16
	end

	self.angle_velocity = 0

	if Input.isDown('left') then
		self.angle_velocity = -5
	elseif Input.isDown('right') then
		self.angle_velocity = 5
	end

	self.pos = self.pos + dt * self.velocity	
	self.angle = self.angle + dt * self.angle_velocity

	self:updateToPhysics()
end

function player:collide (other, coll)
	print ("player is colliding")
end

return player
