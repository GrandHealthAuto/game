local car = class{name = "Car", inherits = Entity.BaseEntity,
	function (self, pos, dimensions)
                Entity.BaseEntity.construct (self, pos, dimensions)
		self.visual = Image.car
                self.hitList = {}
	end
}

function car:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList)
    local hit = {}
    hit.fixture = fixture
    hit.x, hit.y = x, y
    hit.xn, hit.yn = xn, yn
    hit.fraction = fraction

    table.insert(hitList, hit)
    return 1 -- Continues with ray cast through all shapes.
end

function car:update(dt)
	-- behavior
        self:updateFromPhysics()

	local heading = vector (math.cos(self.angle), math.sin(self.angle))

        -- Collition detection
        local hitList = {}
        local ray = self.pos + heading * 30
        State.game.world:rayCast(self.pos.x, self.pos.y, ray.x, ray.y, function (fixture, x, y, xn, yn, fraction) 
            return self:worldRayCastCallback(fixture, x, y, xn, yn, fraction, hitList) 
        end )
        if #hitList == 0 then
            print("have " .. #hitList .. " hits")
            self.velocity = heading * 64
        else
            self.velocity = vector(0, 0)
            self.angle = self.angle + 0.3
        end

	self.pos = self.pos + dt * self.velocity	
	self.angle = self.angle + dt * self.angle_velocity
        
	self:updateToPhysics()
end


-- etc.

return car
