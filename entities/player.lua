local player = class{name = "Player", inherits = Entity.BaseEntity,
	function (self, pos)
		Entity.BaseEntity.construct (self, pos, vector(56, 24))
		self.visual = Image.ambulancebig
		self.mass = 5
		self.linear_damping = GVAR.player_linear_damping
		self.angular_damping = GVAR.player_angular_damping
		self.shape_offset = vector(14,0)
		self:initSound()
	end
}

function player:initSound()
	Sound.static.enginestart:setVolume(0.2)
    Sound.static.enginestart:play()
    self.runningsfx = Sound.static.enginerunning:play()
	self.runningsfx:setLooping(true)
	self.runningsfx:setVolume(0.2)
	self.motorspeed = 0.5
	self.runningsfx:setPitch(self.motorspeed)
end

function player:update(dt)
	self:updateFromPhysics()

	local heading = vector (math.cos(self.angle), math.sin(self.angle))

	local acceleration = vector(0,0)

	local speed = math.sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y)

	if math.abs(speed) < 5.0e-2 then
		speed = 0.
		self.velocity.x = 0.
		self.velocity.y = 0.
	end

	local heading = vector(math.cos (self.angle), math.sin (self.angle))
	local heading_dot_velocity = heading.x * self.velocity.x + heading.y * self.velocity.y

-- self.angle_velocity = 0.

	local rotation_speed_factor = math.min (speed, 320) / 320

	if Input.isDown('accelerate') then
		self.angle_velocity = 0.

		if speed < GVAR["player_accel_max_speed"] then
			local drag_penalty = 1.

			if speed + dt * GVAR["player_accel"] > GVAR["player_accel_max_speed"] then
				drag_penalty = (GVAR["player_accel_max_speed"] - speed) / (dt * math.abs(GVAR["player_accel"]))
			end

			acceleration = heading * GVAR["player_accel"] * drag_penalty
		end
	end

	if Input.isDown('decelerate') then
		if speed < GVAR["player_reverse_max_speed"] then
			local drag_penalty = 1.

			if speed + dt * GVAR["player_reverse"] > GVAR["player_reverse_max_speed"] then
				drag_penalty = (GVAR["player_reverse_max_speed"] - speed) / (dt * math.abs(GVAR["player_reverse"]))
			end

			acceleration = heading * GVAR["player_reverse"] * drag_penalty 
		end

		self.angle_velocity = - self.angle_velocity
		rotation_speed_factor = rotation_speed_factor * -1.
	end

	if Input.isDown('right') then
		self.angle_velocity = GVAR["player_rotation_speed"] * rotation_speed_factor
	end

	if Input.isDown('left') then
		self.angle_velocity = - GVAR["player_rotation_speed"] * rotation_speed_factor
	end

	self.velocity = self.velocity + dt * acceleration
	
	self.motorspeed = speed / GVAR["player_accel_max_speed"]
	self.runningsfx:setPitch(0.5 + self.motorspeed*0.5)
	self.runningsfx:setVolume(0.05 + self.motorspeed*0.5)
	
	self:updateToPhysics()
end

function player:beginContact (other, coll)
end

function player:endContact (other, coll)
end


return player
