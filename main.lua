-- local Player = require("player")
-- local Asteroid = require("asteroid")
local Utils = require("utils")

windowWidth, windowHeight = love.graphics.getDimensions()


function love.load()

    world = love.physics.newWorld(0, 0, true)
    gameOver = false
    player = {}
    player.angle = 0
    player.body = love.physics.newBody(world, windowWidth/2, windowHeight/2, "dynamic")
    player.shape = love.physics.newPolygonShape(-10, -10, 10, 0, -10, 10,-5, 0)
    player.fixture = love.physics.newFixture(player.body, player.shape) -- connect body to shape
    player.fixture:setUserData("Player")

    asteroid = {}
    asteroid.body = love.physics.newBody(world, windowWidth,windowHeight/2, "dynamic")
    asteroid.shape = love.physics.newCircleShape(20)
    asteroid.fixture = love.physics.newFixture(asteroid.body, asteroid.shape)
    asteroid.fixture:setUserData("Asteroid")

    bulletSpeed = 250
    player.bullets = {}

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

function endContact(a, b, coll)
end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)

end


function love.update(dt)

    world:update(dt)

    local mouseX, mouseY = love.mouse.getPosition()

    dirX, dirY = Utils.getDirectionToPoint(player.body:getX(), player.body:getY(), mouseX, mouseY)

    if love.mouse.isDown(1) then
        player.body:applyForce(dirX*250, dirY*250)
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


    -- asteroid.x = (asteroid.x + asteroid.Vx * dt * 200) % windowWidth
    -- asteroid.y = (asteroid.y + asteroid.Vy * dt * 200) % windowHeight

    -- player.x = (player.x + player.Vx * dt * 200) % windowWidth
    -- player.y = (player.y + player.Vy * dt * 200) % windowHeight
end

function love.draw()

    local angle = math.atan2(dirY, dirX)

    love.graphics.push() -- Save the current transformation
    love.graphics.translate(player.body:getX(), player.body:getY()) -- Move the origin to the player's position
    love.graphics.rotate(player.angle) -- Rotate the coordinate system
    love.graphics.polygon("line", -10, -10, 10, 0, -10, 10,-5, 0) -- Draw the triangle
    love.graphics.pop()

    love.graphics.push() -- Save the current transformation
    love.graphics.circle("line",asteroid.body:getX(), asteroid.body:getY(), 20,5) -- Draw the triangle
    love.graphics.pop()

    -- love.graphics.polygon("line", asteroid.body:getWorldPoints(asteroid.shape:getPoints()))

    if(gameOver) then
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    end

    -- love.graphics.print("FPS: " .. tostring(p), 10, 10)
    -- love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)


end
