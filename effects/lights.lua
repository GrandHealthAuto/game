-- simple passthrough effect, won't modify the image
return love.graphics.newPixelEffect [[

	extern vec2 center;
	extern number time;
	
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
	{
		number dis = distance(texture_coords,center);
			if ((dis <= (time + 50)) &&
			       (dis >= (time - 50)))
				{
					number diff = (dis - time);
					number powDiff = 1.0 - pow(abs(diff*50.0),8);
					number diffTime = diff * powDiff;
					vec2 diffUV = normalize(texture_coords - center);
					texture_coords=texture_coords + diffUV * diffTime;
				}
			
			color = Texel(texture, texture_coords);
			return color * vec4(0.4,0.4,1,0.2);
	}
]]