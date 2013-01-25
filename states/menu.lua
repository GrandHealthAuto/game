local st = GS.new()

function st:draw()
	love.graphics.setFont(Font[30])
	love.graphics.printf("GRAND HEALTH AUTO", 0,SCREEN_HEIGHT/4-Font[30]:getLineHeight(),SCREEN_WIDTH, 'center')
end

return st
