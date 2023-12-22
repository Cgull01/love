Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid.new(x, y)
    local self = setmetatable({}, Asteroid)
    self.x = x
    self.y = y
    self.Vx = 0.5
    self.Vy = 0.3
    return self
end


function Asteroid:draw()

    love.graphics.push() -- Save the current transformation
    -- love.graphics.polygon("line", -10, -10, 10, 0, -10, 10,-5, 0) -- Draw the triangle
    love.graphics.ellipse("line",self.x, self.y ,25, 15, 7)
    love.graphics.pop() -- Restore the transformation

end

return Asteroid
