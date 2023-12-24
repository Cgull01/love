local Entity = require("entity")
local Utils = require("utils")

local Asteroid = setmetatable({}, {__index = Entity})

Asteroid.__index = Asteroid


-- gets random position thats on the edge of window
-- also spawns asteroids further away from the player
function getRandomPositionOnEdge()

    math.randomseed(os.time())

    local blockedBorder = Utils.getClosestBorder(player.body:getX(), player.body:getY(), windowWidth, windowHeight)

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

function Asteroid.new()
    local self = setmetatable({}, Asteroid)


    local posX, posY = getRandomPositionOnEdge()

    self.body = love.physics.newBody(world, posX, posY, "dynamic")
    self.shape = love.physics.newCircleShape(20)

    local dirX, dirY = Utils.getDirectionToPoint(posX, posY, player.body:getX(), player.body:getY())
    self.body:setLinearVelocity(70 * dirX, 70 * dirY)

    self.fixture = love.physics.newFixture(self.body, self.shape)
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
