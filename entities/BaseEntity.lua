local base_entity = class{name = "BaseEntity", function (self, pos, dimensions)
	self.pos = pos:clone()
	self.dimensions = dimensions:clone()
	self.velocity = vector(0,0)
	self.center = vector(0,0)
	self.angle = 0
	self.angle_velocity = 0
	self.mass = self.mass or 0
	self.physics = {}
	self.shape_offset = vector(0,0)

	--print ("adding base_entity")
	Entities.add(self)
end
}

function base_entity:draw()
	old_color = {love.graphics.getColor() }

	if self.visual then
		if self.color then
			love.graphics.setColor (self.color)
		end

		love.graphics.draw(self.visual,
			self.pos.x, self.pos.y, self.angle,
			1, 1,
			self.visual:getWidth() * 0.5 - self.shape_offset.x,
			self.visual:getHeight() * 0.5 - self.shape_offset.y)
	end

	if GVAR.draw_collision_boxes then
		love.graphics.setColor(255, 0., 0., 255)

		if self.physics.shape:getType() == 'polygon' then
			love.graphics.polygon("line", self.physics.body:getWorldPoints(self.physics.shape:getPoints()))
		end
	end

	love.graphics.setColor(old_color)
end

function base_entity:registerPhysics(world)
	local physics_type = 'dynamic'
	if self.mass == 0 then
		physics_type = 'static'
	end

	self.physics.body  = self.physics.body or love.physics.newBody(world, self.pos.x, self.pos.y  - self.dimensions.y, physics_type)
	self.physics.body:setLinearDamping (self.linear_damping or 10)
	self.physics.body:setAngularDamping (self.linear_damping or 10)

	self.physics.shape = self.physics.shape or love.physics.newRectangleShape(self.shape_offset.x, self.shape_offset.y, self.dimensions:unpack())

	self.physics.fixture = self.physics.fixture or love.physics.newFixture(self.physics.body, self.physics.shape, 1)

	self.physics.fixture:setUserData (self)

	self.physics.body:setPosition (self.pos.x, self.pos.y)
	self.physics.body:setAngle (self.angle)

	self:updateToPhysics()
end

function base_entity:updateFromPhysics()
	if self.physics then
		self.pos.x, self.pos.y = self.physics.body:getPosition()
		self.angle = self.physics.body:getAngle()
		self.angle_velocity = self.physics.body:getAngularVelocity()

		self.velocity.x, self.velocity.y = self.physics.body:getLinearVelocity()
	end
end

function base_entity:updateToPhysics()
	if self.physics then
		self.physics.body:setAngularVelocity (self.angle_velocity)
		self.physics.body:setLinearVelocity (self.velocity.x, self.velocity.y)
	end
end

function base_entity:finalize()
	-- dummy timer so we dont destroy the fixture while maybe there are some
	-- callbacks still pending
	Timer.add(0, function()
		pcall(self.physics.fixture.destroy, self.physics.fixture)
	end)
end

return base_entity
