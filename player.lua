Player = Object.extend(Object)
-- I can probably use this as a generic character class for all ghosts, pacman, etc.
-- 
-- only difference is pathfinding:
--    ghosts: simple ecludian distance descision making on turns
--    pacman: navigating and eating pellets etc
--    player: controlled by user

function Player.new(self, x, y)
    self.x = x
    self.y = y
    self.tile_x = 0
    self.tile_y = 0
    self.width = 32
    self.height = 32
    self.velocity = 2
     -- 0 = left, 1 = right, 2 = up, 3 = down
    self.direction = 0

    -- TODO: Animate and change sprite based on direction etc
    self.img = love.graphics.newImage("blinky.png")

end


function Player.update(self, dt)
    updateTilePos(self)
    move(self)
end

function move(self)
    --pacman chars move 'on rails' in an 8px bound box 
    -- so their x/y is constrained to stay centered in the maze.
    -- since I doubled everything it's 16px bounding in this case
    -- I can probably greatly simplify this movement system.
    if self.direction == 0 then
        self.x = self.x - self.velocity
        tileX = math.floor(((self.x + 8) / 16))
        --wraparound special
        if self.tile_y == 18 then
            if self.x + 32 == 16 then 
                self.x = (29 * 16)
                return
            end
            if tileX < 1 or tileX > 28 then
                return
            end
            
        end
        if maze.tilemap[self.tile_y][tileX] ~= 0 then
            self.x = (tileX * 16) + 8
        end
    elseif self.direction == 1 then
        self.x = self.x + self.velocity  
        tileX = math.floor(((self.x + 24) / 16))
        --wraparound special
        if self.tile_y == 18 then
            if self.x == (29 * 16) then 
                self.x = -16
                return
            end
            if tileX > 28 or tileX < 1 then
                return
            end
            
        end
        if maze.tilemap[self.tile_y][tileX] ~= 0 then
            self.x = (tileX * 16) - 24
        end
    elseif self.direction == 2 then
        self.y = self.y - self.velocity     
        tileY = math.floor(((self.y + 8) / 16))

        if maze.tilemap[tileY][self.tile_x] ~= 0 then
            self.y = (tileY * 16) + 8
        end
    elseif self.direction == 3 then
        self.y = self.y + self.velocity   
        tileY = math.floor(((self.y + 24) / 16))

        if maze.tilemap[tileY][self.tile_x] ~= 0 then
            self.y = (tileY * 16) - 24
        end
    end
end

function Player.changeDirection(self, dir)
    -- TODO tile value of pellets might not be 0
    horiz_check = math.abs((self.y+8) - self.tile_y * 16) < 3
    vert_check = math.abs((self.x+8) - self.tile_x * 16) < 3
    if dir == 0 and maze.tilemap[self.tile_y][self.tile_x-1] == 0 and horiz_check then
        self.direction = 0
        self.y = (self.tile_y * 16) - 8
    elseif dir == 1 and maze.tilemap[self.tile_y][self.tile_x+1] == 0 and horiz_check then
        self.direction = 1
        self.y = (self.tile_y * 16) - 8
    elseif dir == 2 and maze.tilemap[self.tile_y-1][self.tile_x] == 0 and vert_check then
        -- ghosts not allowed to go UP to [y,x] 13,26 + 16,26 and 13,14 + 16,14
            -- unless in scatter mode? TODO if I want to do that.
            -- undecided if I want player to be constrained here if I do ghosts
        self.direction = 2
        self.x = (self.tile_x * 16) - 8
    elseif dir == 3 and maze.tilemap[self.tile_y+1][self.tile_x] == 0 and vert_check then
        self.direction = 3
        self.x = (self.tile_x * 16) - 8
    end
end

function updateTilePos(self)
    -- tile is determined by the point in the exact 'center' of the sprite.
    -- since it's 32x32 there is no actual center 
    -- so it ends up on the top-left pixel of the center 4
    self.tile_y = math.floor(((self.y + 16) / 16))
    self.tile_x = math.floor(((self.x + 16) / 16))
end

function Player.draw(self)
    love.graphics.draw(self.img, self.x, self.y)
end
