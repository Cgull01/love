-- local Player = require("player")
-- local Asteroid = require("asteroid")
local Utils = require("utils")

windowWidth, windowHeight = love.graphics.getDimensions()


function love.load()
    world = love.physics.newWorld(0, 0, true)
    gameOver = false
    bulletSpeed = 250

    -- create the player
    player = {}
    player.angle = 0
    player.body = love.physics.newBody(world, windowWidth / 2, windowHeight / 2, "dynamic")
    player.shape = love.physics.newPolygonShape(-10, -10, 10, 0, -10, 10, -5, 0)
    player.fixture = love.physics.newFixture(player.body, player.shape) -- connect body to shape
    player.fixture:setSensor(true)
    player.bullets = {}
    player.fixture:setUserData({name = "Player", data = player})

    -- create one asteroid
    asteroid = {}
    asteroid.body = love.physics.newBody(world, windowWidth, windowHeight / 2, "dynamic")
    asteroid.shape = love.physics.newCircleShape(20)
    asteroid.fixture = love.physics.newFixture(asteroid.body, asteroid.shape)
    asteroid.body:setLinearVelocity(70 * math.cos(love.math.random(10)), 70 * math.sin(love.math.random(10)))
    asteroid.fixture:setSensor(true)
    asteroid.fixture:setUserData({name = "Asteroid", data = asteroid})


    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

local collisionHandlers = {
    ["AsteroidPlayer"] = function(asteroidFixture, bulletFixture, coll)
        gameOver = true
        print("Game Over")

    end,
    ["AsteroidBullet"] = function(asteroidFixture, bulletFixture, coll)
        bulletId = bulletFixture:getUserData().data.id
        player.bullets[bulletId] = nil

        -- TOOD: split asteroid
    end
}

function beginContact(a, b, coll)

    -- Sort the names to avoid duplicating handlers for A vs B and B vs A
    local sortedNames = {a:getUserData().name, b:getUserData().name}
    table.sort(sortedNames)
    local key = table.concat(sortedNames)

    -- Call the appropriate handler, if one exists
    local handler = collisionHandlers[key]
    if handler then
        handler(a, b, coll)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- if right mouse button pressed, spawn a bullet
        local startX = player.body:getX() + dirX * 15
        local startY = player.body:getY() + dirY * 15

        local angle = math.atan2((y - startY), (x - startX))

        bullet = {}
        bullet.shape = love.physics.newCircleShape(1)
        bullet.body = love.physics.newBody(world, startX, startY, "dynamic")
        bullet.body:setLinearVelocity(bulletSpeed * math.cos(angle), bulletSpeed * math.sin(angle))
        bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape) -- connect body to shape
        bullet.fixture:setUserData({name = "Bullet", data = bullet})
        bullet.fixture:setSensor(true)
        bullet.body:setBullet(true)
        local bulletId = #player.bullets + 1
        bullet.id = bulletId
        player.bullets[bulletId] = bullet
    end
end

function love.update(dt)
    world:update(dt)

    local mouseX, mouseY = love.mouse.getPosition()
    dirX, dirY = Utils.getDirectionToPoint(player.body:getX(), player.body:getY(), mouseX, mouseY)

    if love.mouse.isDown(2) then -- if left mouse button is pressed, move the player
        player.body:applyForce(dirX * 150, dirY * 150)
    end

    -- move the bullets and remove the ones out of bounds
    -- for i = #player.bullets, 1, -1 do
    for k,bullet in pairs(player.bullets) do
        if bullet.body:getX() < 0 or bullet.body:getY() < 0 or bullet.body:getX() > windowWidth or bullet.body:getY() > windowHeight then
            player.bullets[bullet.id] = nil
        end
    end

    player.angle = math.atan2(dirY, dirX)

    local Px = player.body:getX()
    local Py = player.body:getY()

    player.body:setX(Px % windowWidth)
    player.body:setY(Py % windowHeight)

    local Ax = asteroid.body:getX()
    local Ay = asteroid.body:getY()

    asteroid.body:setX(Ax % windowWidth)
    asteroid.body:setY(Ay % windowHeight)
end

function love.draw()
    local angle = math.atan2(dirY, dirX)

    -- draw bullets
    love.graphics.push()
    love.graphics.setColor(1,1,1)
    for k,bullet in pairs(player.bullets) do
        love.graphics.circle("fill", bullet.body:getX(), bullet.body:getY(), 1)
    end
    love.graphics.pop()

    -- draw player
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(player.body:getX(), player.body:getY())
    love.graphics.rotate(player.angle)
    love.graphics.polygon("line", -10, -10, 10, 0, -10, 10, -5, 0)
    love.graphics.pop()


    -- draw asteroid
    love.graphics.push()
    love.graphics.circle("line", asteroid.body:getX(), asteroid.body:getY(), 20, 5)
    love.graphics.pop()

    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    if (gameOver) then
        love.graphics.print("OVER", 10, 50)
    end

    love.graphics.print("bullets: " .. tostring(#player.bullets), 10, 20)
    love.graphics.print("x: " .. tostring(player.body:getX()), 10, 30)
    love.graphics.print("y: " .. tostring(player.body:getY()), 10, 40)
end
