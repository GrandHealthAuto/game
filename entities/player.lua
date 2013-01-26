local player = class{name = "Player", inherits = Entity.BaseEntity,
	function (self, pos)
		Entity.BaseEntity.construct (self, pos, vector(56, 24))
		self.visual = Image.ambulancebig
		self.mass = 5
		self.linear_damping = GVAR.player_linear_damping
		self.angular_damping = GVAR.player_angular_damping
		self.shape_offset = vector(14,0)

		self.physics.shape = love.physics.newPolygonShape(
			-28 + 14,  7,
			-23 + 14,  12,
			 23 + 14,  12,
			 28 + 14,  7,
			 28 + 14, -7,
			 23 + 14, -12,
			-23 + 14, -12,
			-28 + 14, -7
		)

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
	self.skidfactor = 0.
	self.runningsfx:setPitch(self.motorspeed)
end

function player:update(dt)
	self:updateFromPhysics()

	local acceleration = vector(0,0)

	local speed = math.sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y)

	if math.abs(speed) < 5.0e-2 then
		speed = 0.
		self.velocity.x = 0.
		self.velocity.y = 0.
	end

	self.heading = vector(math.cos (self.angle), math.sin (self.angle))
	local rotation_speed_factor = math.min (speed, 320) / 320

	-- 
	if speed > 300 then
		self.physics.body:setLinearDamping (0.08 * 32)
	elseif speed > 200 then
		self.physics.body:setLinearDamping (0.10 * 32)
	elseif speed > 150 then
		self.physics.body:setLinearDamping (0.15 * 32)
	else
		self.physics.body:setLinearDamping (GVAR["player_linear_damping"])
	end

	if Input.isDown('accelerate') then
		self.angle_velocity = 0.

		if speed < GVAR["player_accel_max_speed"] then
			acceleration = self.heading * GVAR["player_accel"] * 1. 
		else
			print ("superspeed")
			acceleration = self.heading * GVAR["player_accel"] * 1.
		end
	end

--	print (speed)

	if Input.isDown('decelerate') then
		if speed < GVAR["player_reverse_max_speed"] then
			local drag_penalty = 1.

			if speed + dt * GVAR["player_reverse"] > GVAR["player_reverse_max_speed"] then
				drag_penalty = (GVAR["player_reverse_max_speed"] - speed) / (dt * math.abs(GVAR["player_reverse"]))
			end

			acceleration = self.heading * GVAR["player_reverse"] * drag_penalty 
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
	
	self.motorspeed = speed / GVAR["player_motor_sound_maxspeed"]
	self.runningsfx:setPitch(0.5 + self.motorspeed*0.5)
	self.runningsfx:setVolume(0.05 + self.motorspeed*0.5)

	local angle_clamp = 0.05

	if self.angle < 0 then
		self.angle = self.angle + math.pi * 2
	elseif self.angle > math.pi * 2 then
		self.angle = self.angle - math.pi * 2
	end

	if math.abs(self.angle) < angle_clamp then
		self.angle = 0.
	elseif math.abs(self.angle - math.pi * 0.5) < angle_clamp then
		self.angle = math.pi * 0.5
	elseif math.abs(self.angle - math.pi) < angle_clamp then
		self.angle = math.pi
	elseif math.abs(self.angle - math.pi * 1.5) < angle_clamp then
		self.angle = math.pi * 1.5
	elseif math.abs(self.angle - math.pi * 2.) < angle_clamp then
		self.angle = math.pi * 2. 
	end

	-- sliding detection
	local tangential_part = heading * self.velocity
	local velocity_ortho = self.velocity - (heading * tangential_part)
	self.skidfactor = math.max (velocity_ortho:len() - GVAR["player_ortho_vel_skid_start"], 0);

	self:updateToPhysics()
end

-- for debugging of the skidfactor
--function player:draw()
--		old_color = {love.graphics.getColor() }
--
--		if self.skidfactor > 0 then
--			love.graphics.setColor(255, 0., 0., 255)
--		end
--
--		Entity.BaseEntity.draw(self)
--
--		love.graphics.setColor(old_color)
--end

return player
