local Entity = {}
Entity.__index = Entity

function Entity.new(world, windowWidth, windowHeight)
    local self = setmetatable({}, Entity)
    self.body = love.physics.newBody(world, windowWidth / 2, windowHeight / 2, "dynamic")
    return self
end

function Entity:updatePosition(windowWidth, windowHeight)
    self.body:setX(self.body:getX() % windowWidth)
    self.body:setY(self.body:getY() % windowHeight)
end

return Entity