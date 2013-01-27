local radio = class{name = 'Radio',
    function(self)
        self.volume = 0.5
        self.sender = {
            { name = 'Riddim Radio 104.9', snd = Sound.static.reggae},
            { name = '', snd = Sound.static.reggae }
        }
        self.id = 1
        self:play(1)
    end
}

function radio:play(id)
    self.music = self.sender[self.id].snd:play()
    self.music:setVolume(self.volume)
    self.music:setLooping()
end

function radio:draw()
    love.graphics.print(self.sender[self.id].name, 0, 0)
end

return radio