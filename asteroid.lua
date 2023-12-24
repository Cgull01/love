local Entity = require("entity")
local Utils = require("utils")

local Asteroid = setmetatable({}, {__index = Entity})

Asteroid.__index = Asteroid


-- gets random position thats on the edge of window
-- also spawns asteroids further away from the player
function getRandomPositionOnEdge()

    local blockedBorder = Utils.getClosestBorder(player.body:getX(), player.body:getY())

    local posX, posY
    local edge = math.random(4)

    if edge == blockedBorder then
    edge = (edge + 1) % 4
    end

    if edge == 1 then -- top
        posX = math.random(0, windowWidth)
        posY = 0
    elseif edge == 2 then -- right
        posX = windowWidth
        posY = math.random(0, windowHeight)
    elseif edge == 3 then -- bottom
        posX = math.random(0, windowWidth)
        posY = windowHeight
    else -- left
        posX = 0
        posY = math.random(0, windowHeight)
    end

    return posX, posY

end

function generateRandomAsteroidShape(radius, numPoints)
    -- Calculate the range of random distances
    local minDist = radius - 5
    local maxDist = radius + 5

    -- Create a table to hold the points
    local points = {}

    -- Generate the points
    for i = 1, numPoints do
        -- Calculate the angle for this point
        local theta = (i - 1) * (2 * math.pi / numPoints)

        -- Generate a random distance for this point
        local dist = math.random(minDist, maxDist)

        -- Calculate the x and y coordinates for this point
        local x = dist * math.cos(theta)
        local y = dist * math.sin(theta)

        -- Add the point to the table
        table.insert(points, x)
        table.insert(points, y)
    end

    return points
 end


function Asteroid.new(health)
    local self = setmetatable({}, Asteroid)
    local posX, posY = getRandomPositionOnEdge()

    self.body = love.physics.newBody(world, posX, posY, "dynamic")

    local dirX, dirY = Utils.getDirectionToPoint(posX, posY, player.body:getX(), player.body:getY())
    self.body:setLinearVelocity(70 * math.cos(dirX + love.math.random(-10, 10)), 70 * math.sin(dirY + love.math.random(-10, 10)))
    self.body:setAngularVelocity(math.random(-0.1, 0.1))

    self.direction = math.atan2(dirX, dirY)

    local points = generateRandomAsteroidShape(10+health*2, math.random(5, 8))
    self.shape = love.physics.newPolygonShape(points)

    self.fixture = love.physics.newFixture(self.body, self.shape)
    -- self.fixture:setSensor(true)
    self.fixture:setUserData({name = "Asteroid", data = self})
    self.fixture:setRestitution( 0.6 )

    self.id = #asteroids + 1
    self.health = health
    self.isSplit = false

    return self
end

function Asteroid:splitAsteroid()

    if self.health > 0 then

        self.health = self.health - 1

        local leftDirection = self.direction + math.pi / 2
        local rightDirection = self.direction - math.pi / 2

        local leftAsteroid = Asteroid.new(self.health - 1)
        local rightAsteroid = Asteroid.new(self.health - 1)

        leftAsteroid.body:setX(self.body:getX())
        leftAsteroid.body:setY(self.body:getY())

        rightAsteroid.body:setX(self.body:getX())
        rightAsteroid.body:setY(self.body:getY())

        leftAsteroid.id = #asteroids + 1
        rightAsteroid.id = #asteroids + 2

        leftAsteroid.body:applyLinearImpulse(math.cos(leftDirection), math.sin(leftDirection))
        rightAsteroid.body:applyLinearImpulse(math.cos(leftDirection), math.sin(leftDirection))

        asteroids[leftAsteroid.id] = leftAsteroid
        asteroids[rightAsteroid.id] = rightAsteroid
    end
    self.body:destroy()
    asteroids[self.id] = nil

end

function Asteroid:draw()
    love.graphics.push()
    love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.pop()
end

return Asteroid
