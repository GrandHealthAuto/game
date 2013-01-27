-- simple passthrough effect, won't modify the image
return love.graphics.newPixelEffect [[

	extern vec2 light1;
	extern vec2 light2;
		
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		number alpha = 0.5;
		
		number dis1 = distance(texture_coords,light1);
		number dis2 = distance(texture_coords,light2);
		
		if( dis1 < 50 ||  dis2 < 50) {
			alpha = dis1 / 100 + dis2 /100;
		}
		
		color = Texel(texture, texture_coords);
		return color * vec4(0.4,0.4,1,alpha);
	}
]]