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
    player.fixture:setUserData("Player")
    player.bullets = {}

    -- create one asteroid
    asteroid = {}
    asteroid.body = love.physics.newBody(world, windowWidth, windowHeight / 2, "dynamic")
    asteroid.shape = love.physics.newCircleShape(20)
    asteroid.fixture = love.physics.newFixture(asteroid.body, asteroid.shape)
    asteroid.fixture:setUserData("Asteroid")

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function beginContact(a, b, coll)
    local x, y = coll:getNormal()
    local textA = a:getUserData()
    local textB = b:getUserData()

    if textA == "Player" and textB == "Asteroid" or textB == "Player" and textA == "Asteroid" then
        gameOver = true
    end

    print(textA, textB)
end

function love.mousepressed(x, y, button)
    if button == 2 then -- if right mouse button pressed, spawn a bullet
        local startX = player.body:getX() + 10 / 2
        local startY = player.body:getY() + 10 / 2

        local angle = math.atan2((y - startY), (x - startX))

        local bulletDx = bulletSpeed * math.cos(angle)
        local bulletDy = bulletSpeed * math.sin(angle)

        table.insert(player.bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
    end
end

function love.update(dt)
    world:update(dt)

    local mouseX, mouseY = love.mouse.getPosition()
    dirX, dirY = Utils.getDirectionToPoint(player.body:getX(), player.body:getY(), mouseX, mouseY)

    if love.mouse.isDown(1) then -- if left mouse button is pressed, move the player
        player.body:applyForce(dirX * 150, dirY * 150)
    end

    -- move the bullets and remove the ones out of bounds
    for i = #player.bullets, 1, -1 do
        local bullet = player.bullets[i]
        bullet.x = bullet.x + (bullet.dx * dt)
        bullet.y = bullet.y + (bullet.dy * dt)

        if bullet.x < 0 or bullet.y < 0 or bullet.x > windowWidth or bullet.y > windowHeight then
            table.remove(player.bullets, i)
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
    for i, v in ipairs(player.bullets) do
        love.graphics.circle("fill", v.x, v.y, 1)
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

    if (gameOver) then
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    end

    love.graphics.print("bullets: " .. tostring(#player.bullets), 10, 10)
end
