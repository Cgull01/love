local Player = require("player")
local Asteroid = require("asteroid")
local Bullet = require("bullet")
local Utils = require("utils")

windowWidth, windowHeight = love.graphics.getDimensions()


function love.load()
    world = love.physics.newWorld(0, 0, true)
    gameOver = false

    player = Player.new(world, windowWidth, windowHeight)

    asteroid = Asteroid.new(world, windowWidth, windowHeight, player.body:getX(), player.body:getY())

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

local collisionHandlers = {
    ["AsteroidPlayer"] = function(asteroidFixture, bulletFixture)
        gameOver = true
        print("Game Over")

    end,
    ["AsteroidBullet"] = function(asteroidFixture, bulletFixture)
        bulletId = bulletFixture:getUserData().data.id
        player.bullets[bulletId] = nil

        -- TOOD: split asteroid
    end
}

function beginContact(a, b)
    -- Sort the names to avoid duplicating handlers for A vs B and B vs A
    local sortedNames = {a:getUserData().name, b:getUserData().name}
    table.sort(sortedNames)
    local key = table.concat(sortedNames)

    -- Call the appropriate handler, if one exists
    local handler = collisionHandlers[key]
    if handler then
        handler(a, b)
    end
end

function love.mousepressed(x, y, button)
    -- if left mouse button pressed, spawn a bullet
    if button == 1 then
        asteroid = {}
        asteroid = Asteroid.new(world, windowWidth, windowHeight, player.body:getX(), player.body:getY())

        -- local startX = player.body:getX() + dirX * 15
        -- local startY = player.body:getY() + dirY * 15
        -- local angle = math.atan2((y - startY), (x - startX))

        -- local bullet = Bullet.new(world, windowWidth, windowHeight, startX, startY, angle)

        -- player.bullets[bullet.id] = bullet
    end
end

function love.update(dt)
    world:update(dt)

    local mouseX, mouseY = love.mouse.getPosition()

    dirX, dirY = Utils.getDirectionToPoint(player.body:getX(), player.body:getY(), mouseX, mouseY)
    player.angle = math.atan2(dirY, dirX)

     -- if right mouse button is pressed, move the player
    if love.mouse.isDown(2) then
        player.body:applyForce(dirX * 150, dirY * 150)
    end

    -- move the bullets and remove the ones out of bounds
    for k,bullet in pairs(player.bullets) do
        if bullet.body:getX() < 0 or bullet.body:getY() < 0 or bullet.body:getX() > windowWidth or bullet.body:getY() > windowHeight then
            player.bullets[bullet.id] = nil
        end
    end


    player:updatePosition(windowWidth,windowHeight)
    asteroid:updatePosition(windowWidth,windowHeight)

end

function love.draw()
    local angle = math.atan2(dirY, dirX)

    for k,bullet in pairs(player.bullets) do
        bullet:draw()
    end

    player:draw()

    asteroid:draw()
    local mouseX, mouseY = love.mouse.getPosition()

    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print("bullets: " .. tostring(#player.bullets), 10, 20)
    -- love.graphics.print("x: " .. tostring(player.body:getX()), 10, 30)
    -- love.graphics.print("y: " .. tostring(player.body:getY()), 10, 40)
    love.graphics.print("x: " .. tostring(mouseX), 10, 30)
    love.graphics.print("y: " .. tostring(mouseY), 10, 40)
end
