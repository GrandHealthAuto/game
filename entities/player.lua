local player = class{inherits = BaseEntity, 
	function (self, pos, dimensions)
		BaseEntity.construct (self, pos, dimensions)
		self.visual = Image.ambulance

		self.controls = {}
	end
}

function player:update(dt)
	local heading = vector (math.cos(self.angle), math.sin(self.angle))

	self.velocity = vector (0, 0)

	if self.controls.accelerate then
		self.velocity = heading * 128
	end

	self.angle_velocity = 0

	if self.controls.left then
		self.angle_velocity = -5
	end

	if self.controls.right then
		self.angle_velocity = 5
	end

	self.pos = self.pos + dt * self.velocity	
	self.angle = self.angle + dt * self.angle_velocity
end

function player:accelerate(state)
	self.controls.accelerate = state
end

function player:turn_left(state)
	self.controls.left = state
end

function player:turn_right(state)
	self.controls.right = state
end



return player
