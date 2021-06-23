Player = Object.extend(Object)
-- I can probably use this as a generic character class for all ghosts, pacman, etc.

-- TODO: subclass this for each char instead of all this per-char specific stuff
--       or at least a special one for pacman.
-- 
-- only difference is pathfinding:
--    ghosts: simple ecludian distance descision making on turns
--    pacman: eating pellets, avoiding ghosts, power pellets + ghost attack, etc
--    player: controlled by user

function Player.new(self, x, y, sprite, name)
    self.name = name
    self.x = x
    self.y = y
    self.tile_x = 0
    self.tile_y = 0
    self.width = 32
    self.height = 32
    self.velocity = 2
     -- 0 = left, 1 = right, 2 = up, 3 = down
    self.direction = 0

    self.queued_direction = nil
    self.new_tile = false

    self.target_x = 0
    self.target_y = 0

    -- TODO: Animate and change sprite based on direction etc
    self.img = sprite

    math.randomseed(os.time())

end


function Player.update(self, dt)
    updateTilePos(self)
    if self.name == "pacman" then
        if self.new_tile then
            local tv = maze.tilemap[self.tile_y][self.tile_x]
            if tv == 39 or tv == 40 then
                maze.tilemap[self.tile_y][self.tile_x] = 0
            end
            
        end
        if self.new_tile and self.queued_direction == nil then
            randomMovement(self)
            self.new_tile = false
        end
        if self.queued_direction and self:changeDirection(self.queued_direction) then
            -- print("Move executed", self.queued_direction)
            self.queued_direction = nil
            
        end
        
    end

    if self.name == "pinky" then
        if self.new_tile and self.queued_direction == nil then
            local nt = nextTile(self)
            local possible = possibleMovements(self, nt)
            target = findTargetTile(self)
            self.queued_direction = decideDirectionEcludian(self, target, possible)
            self.new_tile = false
        end
        if self.queued_direction and self:changeDirection(self.queued_direction) then
            self.queued_direction = nil
  --          print("Move executed")
        end
    end

    move(self)
end

function findTargetTile(self)
    local target = {}
    if self.name == "pinky" then
        if pacman.direction == LEFT then
            target.x = pacman.tile_x - 4
            target.y = pacman.tile_y
        elseif pacman.direction == RIGHT then
            target.x = pacman.tile_x + 4
            target.y = pacman.tile_y
        elseif pacman.direction == UP then
            -- x modification mimics the original's bug
            target.x = pacman.tile_x - 4
            target.y = pacman.tile_y - 4
        elseif pacman.direction == DOWN then
            target.x = pacman.tile_x
            target.y = pacman.tile_y + 4
        end
    elseif self.name == "inky" then

    end
    self.target_x = target.x
    self.target_y = target.y
    return target
end

function decideDirectionEcludian(self, target, possible)
    -- ecludian distance, same for all ghosts
    local min = nil
    local dir = nil
    for _, _v in ipairs(possible) do
        local d,ty,tx = unpack(_v)
        local dis = distance(tx, ty, target.x, target.y)
        --print("option", d, dis)
        if min == nil or dis < min then
            min = dis
            dir = d
        end
    end
    --print("best option", dir)
    
    return dir
end

function distance ( x1, y1, x2, y2 )
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt ( dx * dx + dy * dy )
end


function nextTile(self)
    local target = {}
    target.x = self.tile_x
    target.y = self.tile_y

    if self.direction == 0 and emptyTiles[maze.tilemap[target.y][target.x -1]] then
        target.x = target.x -1
    elseif self.direction == 1 and emptyTiles[maze.tilemap[target.y][target.x +1]] then
        target.x = target.x +1
    elseif self.direction == 2 and emptyTiles[maze.tilemap[target.y -1][target.x]] then
        target.y = target.y -1
    elseif self.direction == 3 and emptyTiles[maze.tilemap[target.y +1][target.x]] then
        target.y = target.y +1
    end
    return target
end

function possibleMovements(self, target)
    -- TODO: remove the 'going backwards' restriction
    -- it's up to the movement algo to not go backwards
    -- change to possible[0] = coordinates ?
    -- ipairs seems strange when you do that
    -- might just change direction to a string entirely, then index possible with "up" etc
    -- then for checking direction I check the keys of the table
    -- alternatively do 1= left 2 = right, 3=up, 4 = down etc.
    -- annoying to renumber them all but 0 is just problematic many times so far

    local possible = {}
    if emptyTiles[maze.tilemap[target.y][target.x -1]] and self.direction ~= 1 then 
        table.insert(possible, {0, target.y, target.x -1})
    end
    if emptyTiles[maze.tilemap[target.y][target.x +1]] and self.direction ~= 0 then 
        table.insert(possible, {1, target.y, target.x +1})
    end
    if emptyTiles[maze.tilemap[target.y -1][target.x]] and self.direction ~= 3 then
	    table.insert(possible, {2, target.y -1,target.x})
    end
    if emptyTiles[maze.tilemap[target.y +1][target.x]] and self.direction ~=2 then
	    table.insert(possible, {3, target.y +1, target.x})
    end
    return possible
end

function randomMovement(self)
    -- TODO: make actual pacman movement routine
    local target = nextTile(self)
    local possible = possibleMovements(self, target)

    local r = possible[math.random( #possible )]
    if r == nil then
        newdir = self.direction
    else
        newdir = unpack(r)
    end
    -- this is a hack to deal with the wraparound, the possible directions will be nil
    if newdir == nil then
        newdir = self.direction
    end

    self.queued_direction = newdir

    -- print("Queued ", self.queued_direction, "on ", target.x, target.y)
    
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
        if not emptyTiles[maze.tilemap[self.tile_y][tileX]] then
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
        if not emptyTiles[maze.tilemap[self.tile_y][tileX]] then
            self.x = (tileX * 16) - 24
        end
    elseif self.direction == 2 then
        self.y = self.y - self.velocity     
        tileY = math.floor(((self.y + 8) / 16))

        if not emptyTiles[maze.tilemap[tileY][self.tile_x]] then
            self.y = (tileY * 16) + 8
        end
    elseif self.direction == 3 then
        self.y = self.y + self.velocity   
        tileY = math.floor(((self.y + 24) / 16))

        if not emptyTiles[maze.tilemap[tileY][self.tile_x]] then
            self.y = (tileY * 16) - 24
        end
    end
end

function Player.changeDirection(self, dir)
    -- TODO tile value of pellets might not be 0
    -- if I gate this properly I don't need to check empty here
    horiz_check = math.abs((self.y+8) - self.tile_y * 16) < 3
    vert_check = math.abs((self.x+8) - self.tile_x * 16) < 3
    if dir == 0 and emptyTiles[maze.tilemap[self.tile_y][self.tile_x-1]] and horiz_check then
        self.direction = 0
        self.y = (self.tile_y * 16) - 8
        return true
    elseif dir == 1 and emptyTiles[maze.tilemap[self.tile_y][self.tile_x+1]] and horiz_check then
        self.direction = 1
        self.y = (self.tile_y * 16) - 8
        return true
    elseif dir == 2 and emptyTiles[maze.tilemap[self.tile_y-1][self.tile_x]] and vert_check then
        -- ghosts not allowed to go UP to [y,x] 13,26 + 16,26 and 13,14 + 16,14
            -- unless in scatter mode? TODO if I want to do that.
            -- undecided if I want player to be constrained here if I do ghosts
        self.direction = 2
        self.x = (self.tile_x * 16) - 8
        return true
    elseif dir == 3 and emptyTiles[maze.tilemap[self.tile_y+1][self.tile_x]] and vert_check then
        self.direction = 3
        self.x = (self.tile_x * 16) - 8
        return true
    end
    return false
end

function updateTilePos(self)
    -- tile is determined by the point in the exact 'center' of the sprite.
    -- since it's 32x32 there is no actual center 
    -- so it ends up on the top-left pixel of the center 4
    new_y = math.floor(((self.y + 16) / 16))
    new_x = math.floor(((self.x + 16) / 16))

    if new_y ~= self.tile_y or new_x ~= self.tile_x then
        self.new_tile = true
        self.tile_y = new_y
        self.tile_x = new_x
   --     print("Now on", new_x, new_y)
    end
end

function Player.draw(self)
    love.graphics.draw(self.img, self.x, self.y)
end
