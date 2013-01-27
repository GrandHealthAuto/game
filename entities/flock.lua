local flock = class{name = "Flock", function(self, n_pedestrians, n_cars, max_dist)
	self.pedestrians = {}
	self.cars = {}
	self.max_dist = (max_dist or SCREEN_WIDTH / State.game.cam.scale * 1.5)

	local pos = State.game.player.pos

	for i = 1,n_pedestrians or 50 do
		local p
		repeat
			local r = math.random() * self.max_dist + 100
			local phi = math.random() * 2*math.pi
			p = pos + vector(math.cos(phi)*r, math.sin(phi)*r)
		until State.game.map:cellAt(p.x, p.y).is_sidewalk
		local pedestrian = Entity.pedestrian(p, math.random(0,3.1415), "Person " .. i)
		pedestrian.flock = self
	end

	Signal.register('pedestrian-killed', function()
		Timer.add(0, function()
			n_pedestrians = n_pedestrians + 1
			local mindist = SCREEN_WIDTH / State.game.cam.scale
			local r = math.random() * (self.max_dist - mindist) + mindist
			local phi = math.random() * 2*math.pi
			local p = State.game.player.pos + vector(math.cos(phi)*r, math.sin(phi)*r)
			local pedestrian = Entity.pedestrian(p, math.random(0,3.1415), "Person " .. n_pedestrians)
			pedestrian.flock = self
			pedestrian:registerPhysics(State.game.world)
		end)
	end)

	for i = 1, n_cars or 10 do
		local p = self:findStreet(pos, 100, self.max_dist)
		local car = Entity.car(p, 0, "Car " .. i)
		car.flock = self
	end
end}

function flock:findStreet(pos, min_dist, max_dist)
	local p
	repeat
		local r = math.random() * (max_dist - min_dist) + min_dist
		local phi = math.random() * 2*math.pi
		p = pos + vector(math.cos(phi)*r, math.sin(phi)*r)
	until State.game.map:cellAt(p.x, p.y).is_street
	return p
end

function flock:findWalkable(pos, min_dist, max_dist)
	local p
	repeat
		local r = math.random() * (max_dist - min_dist) + min_dist
		local phi = math.random() * 2*math.pi
		p = pos + vector(math.cos(phi)*r, math.sin(phi)*r)
	until State.game.map:cellAt(p.x, p.y).is_walkable
	return p
end

function flock:maybeRelocate(obj, needStreet)
	if not State.game.map:cellAt(obj.pos:unpack()).is_walkable or State.game.player.pos:dist(obj.pos) > self.max_dist then
		local mindist = SCREEN_WIDTH / State.game.cam.scale
		local pos
		if needStreet then
			pos = self:findStreet(State.game.player.pos, mindist, self.max_dist)
		else
			pos = self:findWalkable(State.game.player.pos, mindist, self.max_dist)
		end
		obj.physics.body:setPosition(pos:unpack())
	end
end

return flock
