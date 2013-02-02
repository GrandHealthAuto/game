-- simple passthrough effect, won't modify the image
return love.graphics.newPixelEffect [[

	extern vec2 cammera;
		
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		number alpha = distance(texture_coords,cammera) / 1.9 - 0.15;
	
		color = Texel(texture, texture_coords);
		return mix(color, vec4(0,0,0,alpha), alpha);
	}
]]