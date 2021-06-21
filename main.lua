function love.load()
    Object = require "classic"
    require "player"
    require "maze"

    maze = Maze()
    

    love.window.setMode(480, 600)
    love.window.setTitle("Blinky")
   
  
    width = 16
    height = 16
    blinky = Player((14.5*width) - (width/2), (15*height) - (height/2))


    pacman = love.graphics.newImage("pacman.png")
    pacman_X = (14.5*width) - (width/2)
    pacman_Y = (27*height) - (height/2)
end

totals = 0
function love.update(dt)
    totals = totals + dt

    if love.keyboard.isDown("left") then
        blinky:changeDirection(0)
    elseif love.keyboard.isDown("right") then
        blinky:changeDirection(1)
    elseif love.keyboard.isDown("up") then
        blinky:changeDirection(2)
    elseif love.keyboard.isDown("down") then
        blinky:changeDirection(3)
    end
    
    blinky:update(dt)

    
end


function love.draw()
    love.graphics.print("It's simple, we kill the pacman", 20, 20)
    maze.draw(maze)
    
    love.graphics.draw(pacman, pacman_X, pacman_Y)
    blinky.draw(blinky)
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