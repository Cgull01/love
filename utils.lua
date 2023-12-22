local utils = {}

function utils.getDirectionToPoint(x1, y1, x2, y2)
    local dirX = x2 - x1
    local dirY = y2 - y1

    local len = math.sqrt(dirX * dirX + dirY * dirY)
    dirX = dirX / len
    dirY = dirY / len

    return dirX, dirY
end

return utils