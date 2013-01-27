-- simple passthrough effect, won't modify the image
return love.graphics.newPixelEffect [[
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		return color * Texel(texture, texture_coords);
	}
]]