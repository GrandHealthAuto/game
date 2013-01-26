return = {
    width = width,   -- width of a tile
    height = height, -- height of a tile
    { -- first pixel color (x,y = 0,0) in map
        name = "house",
        is_collision_tile = true, -- should participate in collision box
    },
    { 
        name = "upperstreet",
    },
    { 
        name = "lowerstreet",
        
    },
    { 
        name = "sidewalk",
    }
    { 
        -- no name
        is_collision_tile = true,
    },
    {
        
    }
}