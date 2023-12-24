local Player = require("player")
local Asteroid = require("asteroid")
local Bullet = require("bullet")
local Utils = require("utils")

windowWidth, windowHeight = love.graphics.getDimensions()

-- TODO
-- player lifepoints
-- gameover
-- massive world? tracking player?

local ASTEROID_COUNT = 5
local ASTEROID_SIZE = 5

local SHOOTING_SPEED = 1

function love.load()
    math.randomseed(os.time())

    local screenWidth, screenHeight = love.graphics.getDimensions()

    love.window.setMode(
        screenWidth,
        screenHeight,
        {
            fullscreen = false,
            vsync = true,
            resizable = true,
            minwidth = 800,
            minheight = 600,
            highdpi = true
        }
    )

    world = love.physics.newWorld(0, 0, true)
    gameOver = false

    shootingDelay = 0

    player = Player.new()

    asteroids = {}

    for i = 1, ASTEROID_COUNT do
        local asteroid = Asteroid.new(ASTEROID_SIZE)
        asteroids[asteroid.id] = asteroid
    end

    world:setCallbacks(beginContact)
end

local function gameOverHandler()
    gameOver = true
    print("Game Over")
end

function beginContact(a, b)
    local collisionHandlers = {
        ["AsteroidPlayer"] = gameOverHandler,
        ["BulletPlayer"] = function(playerFixture, bulletFixture)
            local bullet = bulletFixture:getUserData().data

            if player.bullets[bullet.id] ~= nil then
                if bullet.isDamaging == true then
                    gameOverHandler()
                end

                bullet.body:destroy()
                player.bullets[bullet.id] = nil
            end
        end,
        ["AsteroidBullet"] = function(asteroidFixture, bulletFixture)
            local bullet = bulletFixture:getUserData().data
            local asteroid = asteroidFixture:getUserData().data

            bullet.body:destroy()

            asteroid.isSplit = true

            player.bullets[bullet.id] = nil
        end,
        ["BulletBullet"] = function(bulletFixture1, bulletFixture2)
            local bullet1 = bulletFixture1:getUserData().data
            local bullet2 = bulletFixture2:getUserData().data

            bullet1.body:destroy()
            bullet2.body:destroy()

            player.bullets[bullet1.id] = nil
            player.bullets[bullet2.id] = nil
        end
    }

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

function love.update(dt)
    world:update(dt)
    windowWidth, windowHeight = love.graphics.getDimensions()

    local mouseX, mouseY = love.mouse.getPosition()

    dirX, dirY = Utils.getDirectionToPoint(player.body:getX(), player.body:getY(), mouseX, mouseY)

    player.angle = math.atan2(dirY, dirX)

    shootingDelay = shootingDelay - dt * 10

    -- if right mouse button is pressed, move the player
    if love.mouse.isDown(2) then
        player.body:applyForce(dirX * 150, dirY * 150)
    end
    if love.mouse.isDown(1) and shootingDelay <= 0 then
        local startX = player.body:getX() + dirX * 15
        local startY = player.body:getY() + dirY * 15

        local angle = math.atan2((mouseY - startY), (mouseX - startX))

        local bullet = Bullet.new(startX, startY, angle)

        player.bullets[bullet.id] = bullet

        shootingDelay = SHOOTING_SPEED
    end

    for k, bullet in pairs(player.bullets) do
        bullet:updatePosition()

        if bullet.isDamaging == false then
            if Utils.getDistance(player.body:getX(), player.body:getY(), bullet.body:getX(), bullet.body:getY()) > 100 then
                bullet.isDamaging = true
            end
        end

    end

    player:updatePosition()

    for k, asteroid in pairs(asteroids) do
        if asteroid.isSplit then
            asteroid:splitAsteroid()
        else
            asteroid:updatePosition()
        end
    end
end

function love.draw()
    local angle = math.atan2(dirY, dirX)

    for k, bullet in pairs(player.bullets) do
        bullet:draw()
    end

    player:draw()

    for k, asteroid in pairs(asteroids) do
        asteroid:draw()
    end

    local mouseX, mouseY = love.mouse.getPosition()

    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print("bullets: " .. tostring(#player.bullets), 10, 20)
    -- love.graphics.print("x: " .. tostring(player.body:getX()), 10, 30)
    -- love.graphics.print("y: " .. tostring(player.body:getY()), 10, 40)
end
