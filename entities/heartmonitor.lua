local monitor = class{name = 'Heartmonitor',
	function (self)
		self.t = 0
		self.scale = 2
		self.w = Image.heart:getWidth()
		self.h = Image.heart:getHeight()
		self.x = SCREEN_WIDTH/2
		self.y = self.h/2+20

		self.arrow = {Image.questmarker_arrow_full, Image.questmarker_arrow_empty}
		self.heart = {Image.questmarker_heart_full, Image.questmarker_heart_empty}
	end
}

function monitor:draw()
	local victim = State.game.current_target or State.game.current_passanger
	local w, h = math.floor(self.w * self.scale), math.floor(self.h * self.scale)
	local x, y = math.floor(self.x-w/2), math.floor(self.y-h/2)
	local p = 1 - math.min(1, victim.heartrate / 150)

	love.graphics.setScissor(x,y, w, p*h)
	love.graphics.draw(Image.heart_gray, self.x,self.y, 0, self.scale, self.scale, self.w/2, self.h/2)

	love.graphics.setScissor(x,y+p*h, w,(1-p)*h)
	love.graphics.draw(Image.heart, self.x,self.y, 0, self.scale, self.scale, self.w/2, self.h/2)

	love.graphics.setScissor()
end

function monitor:drawMarker()
	local ppos = vector(State.game.player.physics.body:getPosition())
	local qpos = vector(State.game.marker.physics.body:getPosition())
	local dir  = qpos - ppos
	local dist = dir:len()
	dir:normalize_inplace()
	local phi = math.atan2(dir.y, dir.x)

	local p = State.game.pickup_progress or 0
	if State.game.current_passanger then p = 1 - p end

	local offset = math.max(20, math.min(100, dist))
	local hpos = ppos + dir * offset -- hear pos
	if not self.mpos then self.mpos = hpos end
	self.mpos = self.mpos + (hpos - self.mpos) * love.timer.getDelta() * 5 -- hackety hack

	local hs, hox, hoy = self.scale/2 * (1+p), self.heart[1]:getWidth()/2, self.heart[1]:getHeight()/2
	local apos = self.mpos + dir * (self.arrow[1]:getWidth() * 1.1)
	local as, aox, aoy = 1, self.arrow[1]:getWidth()/2, self.arrow[1]:getHeight()/2

	love.graphics.setColor(255,255,255,(1-p)*255)
	love.graphics.draw(self.heart[2], self.mpos.x, self.mpos.y, 0, hs,hs, hox,hoy)
	love.graphics.draw(self.arrow[2], apos.x, apos.y, phi, as,as, aox,aoy)

	love.graphics.setColor(255,255,255,p*255)
	love.graphics.draw(self.heart[1], self.mpos.x, self.mpos.y, 0, hs,hs, hox,hoy)
	love.graphics.draw(self.arrow[1], apos.x, apos.y, phi, as,as, aox,aoy)
end

function monitor:update(dt)
	self.t = self.t + dt
	local victim = State.game.current_target or State.game.current_passanger
	if not victim then return end
	local tmax = 60 / victim.heartrate
	if self.t >= tmax then
		self.t = self.t - tmax
		Tween(.1, self, {scale = 2.3}, 'outBack', function()
		    Sound.static.beep:setVolume(0.05)
			Sound.static.beep:play()
			Tween(.1, self, {scale = 2}, 'outBack')
		end)
	end
end


return monitor
