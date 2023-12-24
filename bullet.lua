local Entity = require("entity")
local Bullet = setmetatable({}, {__index = Entity})
Bullet.__index = Bullet

function Bullet.new(x, y, angle)
    local self = setmetatable({}, Bullet)

    local bulletSpeed = 250
    self.shape = love.physics.newCircleShape(1)
    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.body:setLinearVelocity(bulletSpeed * math.cos(angle), bulletSpeed * math.sin(angle))
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({name = "Bullet", data = self})
    self.fixture:setSensor(true)
    self.body:setBullet(true)
    self.id = #player.bullets + 1
    self.isDamaging = false
    return self
end

function Bullet:draw()
    love.graphics.push()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), 1)
    love.graphics.pop()
end

return Bullet
