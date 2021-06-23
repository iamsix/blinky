function love.load()
    Object = require "classic"
    require "player"
    require "maze"

    maze = Maze()
    emptyTiles = {[0] = true, [39] = true, [40] = true}

    game_state = "playing"
    

    love.window.setMode(480, 600)
    love.window.setTitle("Blinky")
   
    LEFT = 0
    RIGHT = 1
    UP = 2
    DOWN = 3
  
    width = 16
    height = 16

    player = love.graphics.newImage("blinky.png")
    blinky = Player((14.5*width) - (width/2),
                    (15*height) - (height/2),
		    player, "blinky")


    p = love.graphics.newImage("inky.png")
    pinky = Player((17*width) - (width/2),
                (15*height) - (height/2),
                p, "pinky")

    pac = love.graphics.newImage("pacman.png")
    pacman_X = (14.5*width) - (width/2)
    pacman_Y = (27*height) - (height/2)
    pacman = Player(pacman_X, pacman_Y, pac, "pacman")
    pacman.direction = 1

end

function love.keypressed(k)
    if k == 'escape' then
       love.event.quit()
    end

    if k == "p" then
        if game_state == "pause" then game_state = "playing" else game_state = "pause" end
    end

    if k == "q" then
        if pacman.velocity == 0 then pacman.velocity = 2 else pacman.velocity = 0 end
    end
 end

--totals = 0
function love.update(dt)
    --totals = totals + dt

    if game_state == "winner" or game_state == "pause" then
        return
    end

    if love.keyboard.isDown("left") then
        blinky:changeDirection(0)
    elseif love.keyboard.isDown("right") then
        blinky:changeDirection(1)
    elseif love.keyboard.isDown("up") then
        blinky:changeDirection(2)
    elseif love.keyboard.isDown("down") then
        blinky:changeDirection(3)
    end
    
    pacman:update(dt)
    blinky:update(dt)
    pinky:update(dt)

    checkCollision()
    
end

function checkCollision()
    if (blinky.tile_x == pacman.tile_x and blinky.tile_y == pacman.tile_y) or
       (pinky.tile_x == pacman.tile_x and pinky.tile_y == pacman.tile_y)
        then
        game_state = "winner"
    end
end

function love.draw()
    if game_state == "winner" then
        love.graphics.print("WINNER", 20, 20)
        
    else
        love.graphics.print("It's simple, we kill the pacman", 20, 20)
    end
    maze.draw(maze)
    
    pacman.draw(pacman)
    blinky.draw(blinky)


    -- hax for now just colour the grey one
    love.graphics.setColor(255,0,10)
    pinky.draw(pinky)

    love.graphics.setColor(1,0,0)
    love.graphics.circle("fill", ((pinky.target_x) * width) +8, ((pinky.target_y) * width)+8, 2)
    
    love.graphics.setColor(255,255,255)
    -- TODO: black rectangle hack to hide the left/right sides for wraparound
end

function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end
