local Entity = require("entity")
local Asteroid = setmetatable({}, {__index = Entity})

Asteroid.__index = Asteroid

function Asteroid.new(world, windowWidth, windowHeight)
    local self = setmetatable({}, Asteroid)
    self.body = love.physics.newBody(world, windowWidth, windowHeight / 2, "dynamic")
    self.shape = love.physics.newCircleShape(20)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.body:setLinearVelocity(70 * math.cos(love.math.random(10)), 70 * math.sin(love.math.random(10)))
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
