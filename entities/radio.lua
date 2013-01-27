local radio = class{name = 'Radio',
    function(self)
        self.volume = 0.8
        self.sender = {
            { name = 'Cardiac Riddim Radio 104.9', snd = Sound.stream.reggae},
            { name = 'Up The Antechamber 76.2', snd = Sound.stream.drone },
            { name = 'Electronic Pacemaker 81.6', snd = Sound.stream.electro},
            { name = 'Hop Hop 55.8', snd = Sound.stream.hiphop},
            { name = 'Psychedelic Veins 74.5', snd = Sound.stream.psy}
        }
        self.id = math.random(#self.sender)
        self:play(self.id)
    end
}

function radio:play(id)
    if self.music then self.music:stop() end
    self.music = self.sender[id].snd:play()
    self.music:setVolume(self.volume)
    self.music:setLooping(true)
end

function radio:draw()
    love.graphics.print(self.sender[self.id].name, 0, 0)
end

return radio