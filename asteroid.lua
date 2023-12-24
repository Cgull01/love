local Entity = require("entity")
local Utils = require("utils")

local Asteroid = setmetatable({}, {__index = Entity})

Asteroid.__index = Asteroid


-- gets random position thats on the edge of window
-- also preferably spawns asteroids further away from the player
function getRandomPositionOnEdge(windowWidth, windowHeight,blockedBorder)

    math.randomseed(os.time())

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

function Asteroid.new(world, windowWidth, windowHeight, playerX, playerY)
    local self = setmetatable({}, Asteroid)

    local blockedBorder = Utils.getClosestBorder(playerX, playerY, windowWidth, windowHeight)

    local posX, posY = getRandomPositionOnEdge(windowWidth,windowHeight,blockedBorder)

    self.body = love.physics.newBody(world, posX, posY, "dynamic")
    self.shape = love.physics.newCircleShape(20)
    self.fixture = love.physics.newFixture(self.body, self.shape)

    local dirX, dirY = Utils.getDirectionToPoint(posX, posY, playerX, playerY)

    -- local dirX = playerX - posX + math.random(-1, 1)
    -- local dirY = playerY - posY + math.random(-1, 1)
    -- local len = math.sqrt(dirX * dirX + dirY * dirY)

    -- dirX = dirX / len
    -- dirY = dirY / len

    self.body:setLinearVelocity(70 * dirX, 70 * dirY)
    self.fixture:setSensor(true)
    self.fixture:setUserData({name = "Asteroid", data = self})
    return self
end

function Asteroid:draw()

    love.graphics.push()
    love.graphics.circle("line", self.body:getX(), self.body:getY(), 20, 5 )
    love.graphics.pop()

end

return Asteroid
