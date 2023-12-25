local Player = require("player")
local Asteroid = require("asteroid")
local Bullet = require("bullet")
local Utils = require("utils")

windowWidth, windowHeight = love.graphics.getDimensions()

local DEATH_TIMER = 10

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

    -- globals
    world = love.physics.newWorld(0, 0, true)
    player = Player.new()
    level = 0
    asteroids = {}
    _shootingSpeed = 0
    _deathTimer = 0
    gameOver = false
    heartIcon = love.graphics.newImage("heart_icon.png")
    --


    world:setCallbacks(beginContact)
end

local function gameOverHandler()
    player.body:destroy()
    gameOver = true
    print("Game Over")
end

function beginContact(a, b)
    local collisionHandlers = {
        ["AsteroidPlayer"] = function(playerFixture, asteroidFixture)
            local player = playerFixture:getUserData().data
            local asteroid = asteroidFixture:getUserData().data

            player:receiveDamage()
            _deathTimer = DEATH_TIMER
            asteroid.isSplit = true

            if player.health <= 0 then
                gameOverHandler()
            end
        end,
        ["BulletPlayer"] = function(playerFixture, bulletFixture)
            local bullet = bulletFixture:getUserData().data
            local player = playerFixture:getUserData().data

            if player.bullets[bullet.id] ~= nil then
                if bullet.isDamaging == true then
                    player:receiveDamage()
                    _deathTimer = DEATH_TIMER

                    if player.health <= 0 then
                        gameOverHandler()
                    end
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
    local handler = collisionHandlers[key]
    if handler then
        handler(a, b)
    end
end

function love.update(dt)
    world:update(dt)

    if player.body:isDestroyed() == true then
        return
    end


    windowWidth, windowHeight = love.graphics.getDimensions()

    local mouseX, mouseY = love.mouse.getPosition()

    dirX, dirY = Utils.getDirectionToPoint(player.body:getX(), player.body:getY(), mouseX, mouseY)

    player.angle = math.atan2(dirY, dirX)
    _shootingSpeed = _shootingSpeed - dt * 10

    -- if right mouse button is pressed, move the player
    if love.mouse.isDown(2) then
        player.body:applyLinearImpulse(dirX * 2, dirY * 2)
    end

    -- if left mouse button is pressed, shoot a bullet
    if love.mouse.isDown(1) and _shootingSpeed <= 0 then
        local startX = player.body:getX() + dirX * 15
        local startY = player.body:getY() + dirY * 15

        local angle = math.atan2((mouseY - startY), (mouseX - startX))

        local bullet = Bullet.new(startX, startY, angle)
        player.bullets[bullet.id] = bullet
        _shootingSpeed = SHOOTING_SPEED
    end

    for k, bullet in pairs(player.bullets) do
        bullet:updatePosition()
    end

    player:updatePosition()

    for k, asteroid in pairs(asteroids) do
        if asteroid.isSplit then
            asteroid:splitAsteroid()
        else
            asteroid:updatePosition()
        end
    end

    if _deathTimer > 0 then
        _deathTimer = _deathTimer - dt * 10
        player.body:setActive(false)
        player.body:setX(windowWidth / 2)
        player.body:setY(windowHeight / 2)
        player.body:setLinearVelocity(0, 0)
        return
    else
        player.body:setActive(true)
    end


    if #asteroids <= 0 then
        level = level + 1
        for i = 1, math.random(2, level + 1) do
            local asteroid = Asteroid.new(math.random(level + 2, level + 4))
            asteroids[asteroid.id] = asteroid
        end
    end
end

function love.draw()
    local angle = math.atan2(dirY, dirX)

    for k, bullet in pairs(player.bullets) do
        bullet:draw()
    end

    if _deathTimer <= 0 and player.health > 0 then
        player:draw()
    elseif player.health > 0 then
        love.graphics.print(_deathTimer, windowWidth / 2, windowHeight / 2)
    else
        love.graphics.print("GAME OVER", windowWidth / 2, windowHeight / 2)
    end

    for k, asteroid in pairs(asteroids) do
        asteroid:draw()
    end

    for i = 1, player.health do
        love.graphics.circle("fill", windowWidth - 10 - i * 15, 10, 5)
    end

    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print("bullets: " .. tostring(#player.bullets), 10, 20)
    -- love.graphics.print("x: " .. tostring(player.body:getX()), 10, 30)
    -- love.graphics.print("y: " .. tostring(player.body:getY()), 10, 40)
end
