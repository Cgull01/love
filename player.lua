Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.Vx = 0
    self.Vy = 0
    self.dirX = 0
    self.dirY = 0

    return self
end


function Player:draw()
    local angle = math.atan2(self.dirY, self.dirX)

    love.graphics.push() -- Save the current transformation
    love.graphics.translate(self.x, self.y) -- Move the origin to the player's position
    love.graphics.rotate(angle) -- Rotate the coordinate system
    love.graphics.polygon("line", -10, -10, 10, 0, -10, 10,-5, 0) -- Draw the triangle
    love.graphics.pop() -- Restore the transformation

end

return Player
