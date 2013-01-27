local radio = class{name = 'Radio',
    function(self)
        self.volume = 0.8
        self.sender = {
            { name = 'Cardiac Riddim Radio 104.9', snd = Sound.stream.reggae},
            { name = 'Up The Antechamber 76.2', snd = Sound.stream.drone }
        }
        self.id = math.random(#self.sender)
        self:play(self.id)
    end
}

function radio:play(id)
    self.music = self.sender[self.id].snd:play()
    self.music:setVolume(self.volume)
    self.music:setLooping(true)
end

function radio:draw()
    love.graphics.print(self.sender[self.id].name, 0, 0)
end

return radio