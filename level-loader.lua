-- usage: load_level('maps/city.png', tile_info, tile_data)
--
-- where:
--
-- tile_info = {
--     width = width,   -- width of a tile
--     height = height, -- height of a tile
--     { -- first pixel color (x,y = 0,0) in map
--         name = "sidewalk.png",
--     },
--     { -- second pixel color (x,y = 1,0) in map
--         name = "street.png",
--     },
--     { -- third pixel color (x,y = 2,0) in map
--         name = "house.png",
--         is_collision_tile = true, -- should participate in collision box
--     }
--     { -- fourth pixel color (x,y = 3,0) in map
--         -- no name
--         is_collision_tile = true,
--     }
-- }
--
-- and `tile_data' is table from TexturePacker:
--
-- {
--     texture = 'tiledata.png',
--     frames = {
--         {
--             name = "sidewalk.png",
--             uvRect = { u0 = 0.03125, v0 = 0.28125, u1 = 0.53125, v1 = 0.53125 },
--             ...
--         },
--         {
--             name = "street.png",
--             uvRect = { u0 = 0.03125, v0 = 0.015625, u1 = 0.53125, v1 = 0.265625 },
--             ...
--         }
--     }
-- }
--
--
-- returns map, geometry
--
-- where `map'      is a sparse 2-d array of quads with fields `atlas' (image object),
--                  and `draw(self, cam)' (function)
-- and   `geometry' is a set of {x = x, y = y, w = w, h = h} tables
return function(map_path, tile_info, tile_data)
	local atlas = Image[tile_data.texture:match('^(.+)%.png$')]
	local REF_W, REF_H = atlas:getWidth(), atlas:getHeight()
	local quads = {}
	for _,frame in ipairs(tile_data.frames) do
		local tc = frame.uvRect
		local size = frame.spriteSourceSize
		quads[frame.name] = love.graphics.newQuad(tc.u0, tc.v0, tc.u1-tc.u0, tc.v1-tc.v0, 1,1)
	end

	local image_data = love.image.newImageData(map_path)
	local color_to_tile = {}
	for x = 0,image_data:getWidth()-1 do
		local hex = ("%02x%02x%02x%02x"):format(image_data:getPixel(x,0))
		if color_to_tile[hex] then break end
		color_to_tile[hex] = x+1
	end

	local collision_boxes = {}
	local TW, TH = tile_info.width, tile_info.height

	local map = {atlas = atlas, rescue_zone = vector(0,0)}
	for y = 1,image_data:getHeight()-1 do
		local row = {}
		collision_boxes[y] = {}
		for x = 0,image_data:getWidth()-1 do
			local hex = ("%02x%02x%02x%02x"):format(image_data:getPixel(x,y))
			local tile = tile_info[color_to_tile[hex]] or {}
			if tile.name then
				row[x+1] = {
					q = quads[tile.name],
					is_street   = tile.name:match('street^'),
					is_sidewalk = tile.name:match('sidewalk^'),
				}
			end
			if tile.is_rescue_zone then
				map.rescue_zone.x = (x+1) * TW
				map.rescue_zone.y = (y+.5) * TH
			end

			if tile.is_collision_tile then
				local box = collision_boxes[y][x-1]
				if not box then
					-- create collison box
					box = {x = x*TW, y = y*TH, w = TW, h = TH}
				else
					-- merge adjacent boxes
					box.w = box.w + TW
					collision_boxes[y][x-1] = nil
				end
				collision_boxes[y][x] = box
			end
		end
		map[y] = row
	end

	-- merge adjacent collison boxes of same size (rows)
	local row_last, geometry = {}, {}
	for y,row in ipairs(collision_boxes) do
		for x,box in pairs(row) do
			local adjacent = row_last[x]
			if adjacent and adjacent.w == box.w then
				-- merge boxes
				adjacent.h = adjacent.h + TH
				row[x] = adjacent
			else
				geometry[row[x]] = row[x] -- record geometry
			end
		end
		row_last = row
	end

	-- map drawing
	function map:draw(cam, overdraw)
		overdraw = overdraw or 5
		-- rotated bounding box
		local xul,yul = cam:worldCoords(0,0)
		local xll,yll = cam:worldCoords(0, SCREEN_HEIGHT)
		local xur,yur = cam:worldCoords(SCREEN_WIDTH,0)
		local xlr,ylr = cam:worldCoords(SCREEN_WIDTH,SCREEN_HEIGHT)

		-- axis aligned bounding box
		local x0,y0 = math.min(xul, xll, xur, xlr), math.min(yul, yll, yur, ylr)
		local x1,y1 = math.max(xul, xll, xur, xlr), math.max(yul, yll, yur, ylr)

		-- to grid coords
		x0,y0 = math.floor(x0/TW)+1, math.floor(y0/TH)+1
		x1,y1 = math.ceil(x1/TW)+1, math.ceil(y1/TH)+1

		x0,y0 = math.max(1, x0-overdraw), math.max(1, y0-overdraw)

		for i = y0,y1+overdraw do
			local row = self[i]
			for k = x0,x1+overdraw do
				if row and row[k] then
					local cell = row[k]
					love.graphics.drawq(self.atlas, cell.q, (k-1)*TW, i*TH, 0, REF_W,REF_H)
				end
			end
		end
	end

	function map:tileCoords(x,y)
		return math.floor(x0/TW)+1, math.floor(y0/TH)+1
	end

	function map:cell(i,k)
		return (map[i] or {})[k]
	end

	function map:cellAt(x,y)
		return self:cell( self:tileCoords(x,y) )
	end

	function map:isStreet(x,y)
		return self:cell(x,y).is_street
	end

	function map:isSidewalk(x,y)
		return self:cell(x,y).is_sidewalk
	end

	return map, geometry
end
