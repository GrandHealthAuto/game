local marker = class{name = 'QuestMarker', inherits = Entity.BaseEntity,
	function (self, pos, radius)
		Entity.BaseEntity.construct(self, pos:clone(), vector(128,128))
		--self.visual = Image.victim

		self.physics.shape = love.physics.newCircleShape(radius or 64)
		self.t = 0
		self.bobbing_frequency = 1.
		self.playerInRange = false
	end
}

function marker:update(dt)
	self.t = self.t + dt
	if self.playerInRange then
		self.bobbing_frequency = self.bobbing_frequency + dt * 3.
	else
		self.bobbing_frequency = 1.
	end
end

function marker:draw()
	local pos = vector(self.physics.body:getPosition())
	love.graphics.draw(Image.pick_me_up, pos.x,
		pos.y, 0,1.5,1.5,
		Image.pick_me_up:getWidth()/2,
		Image.pick_me_up:getHeight() + (.5 + .5*math.sin((self.t+self.bobbing_frequency)*2*math.pi)) * 10 + 5)
end

function marker:registerPhysics(...)
	Entity.BaseEntity.registerPhysics(self, ...)
	self.physics.fixture:setSensor(true)
end

function marker:beginContact(other)
	if other ~= State.game.player then return end
	self.playerInRange = true
	local t = 0
	self.countown_timer = Timer.do_for(2, function(dt)
		t = t + dt
		Signal.emit('quest-timer', t / 2)
	end, function()
		if self.playerInRange then
			Signal.emit('quest-finish')
		end
	end)
end

function marker:endContact(other)
	if other ~= State.game.player then return end
	self.playerInRange = false
	Timer.cancel(self.countown_timer)
	Signal.emit('quest-abort')
end

return marker
