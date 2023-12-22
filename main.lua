local Player = require("player")
local Asteroid = require("asteroid")
local Utils = require("utils")

windowWidth, windowHeight = love.graphics.getDimensions()


function love.load()

    world = love.physics.newWorld(0, 0, true)

    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    player = Player.new(windowWidth / 2, windowHeight / 2, world)

    asteroid = Asteroid.new(windowWidth, windowHeight)

    text       = ""
    persisting = 0
end

function beginContact(a, b, coll)
    x,y = coll:getNormal()
    text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
end



function love.update(dt)
    mouseX, mouseY = love.mouse.getPosition()

    player.dirX, player.dirY = Utils.getDirectionToPoint(player.x, player.y, mouseX, mouseY)

    if love.mouse.isDown(1) then
        player.Vx = player.Vx + player.dirX * 1.5 * dt
        player.Vy = player.Vy + player.dirY * 1.5 * dt

        local angle = math.atan2(-player.dirY, -player.dirX)
    else
    end

    asteroid.x = (asteroid.x + asteroid.Vx * dt * 200) % windowWidth
    asteroid.y = (asteroid.y + asteroid.Vy * dt * 200) % windowHeight

    player.x = (player.x + player.Vx * dt * 200) % windowWidth
    player.y = (player.y + player.Vy * dt * 200) % windowHeight
end

function love.draw()
    player:draw()
    asteroid:draw()

    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.print(text, 10, 20)


end
