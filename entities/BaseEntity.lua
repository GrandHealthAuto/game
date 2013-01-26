local base_entity = class{name = "BaseEntity", function (self, pos, dimensions)
	self.pos = pos:clone()
	self.dimensions = dimensions:clone()
	self.velocity = vector(0,0)
	self.angle = 0.
	self.angle_velocity = 0.

	--print ("adding base_entity")
	Entities.add(self)
end
}

function base_entity:draw()
	if self.visual then
		love.graphics.draw (
		self.visual,
		self.pos.x, self.pos.y, self.angle,
		1, 1,
		self.dimensions.x * 0.5, self.dimensions.y * 0.5
		)
	else
		love.graphics.rectangle (
		'line',
		self.pos.x - self.dimensions.x * 0.5,
		self.pos.y - self.dimensions.y * 0.5,
		self.dimensions.x,
		self.dimensions.y
		)
	end
end

function base_entity:registerPhysics(world, mass)
	self.physics = {}

	local physics_type = 'dynamic'
	if mass == 0. then
		physics_type = 'static'
	end

	self.physics.body = love.physics.newBody (world, self.pos.x, self.pos.y, physics_type)
	self.physics.shape = love.physics.newRectangleShape (self.dimensions.x, self.dimensions.y)

	self.physics.fixture = love.physics.newFixture (self.physics.body, self.physics.shape, 1)

	self:updateToPhysics()
end

function base_entity:updateFromPhysics()
	if self.physics then
		self.pos.x, self.pos.y = self.physics.body:getPosition()
		self.angle = self.physics.body:getAngle()

		self.velocity.x, self.velocity.y = self.physics.body:getLinearVelocity()
	end
end

function base_entity:updateToPhysics()
	if self.physics then
		self.physics.body:setPosition (self.pos.x, self.pos.y)
		self.physics.body:setAngle (self.angle)
		self.physics.body:setAngularVelocity (0)

		self.physics.body:setLinearVelocity (self.velocity.x, self.velocity.y)
	end
end

return base_entity
