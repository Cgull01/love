local Entity = require("entity")
local Player = setmetatable({}, {__index = Entity})

Player.__index = Player

function Player.new()
    local self = setmetatable({}, Player)
    self.body = love.physics.newBody(world, windowWidth / 2, windowHeight / 2, "dynamic")
    self.shape = love.physics.newPolygonShape(-10, -10, 10, 0, -10, 10, -5, 0)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({name = "Player", data = self})
    self.fixture:setSensor(true)

    self.angle = 0
    self.health = 3
    self.bullets = {}
    return self
end

function Player:receiveDamage()
    self.health = self.health - 1
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.angle)
    love.graphics.polygon("line", -10, -10, 10, 0, -10, 10, -5, 0)
    love.graphics.pop()
end

return Player
