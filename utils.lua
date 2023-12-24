local utils = {}

function utils.getDirectionToPoint(x1, y1, x2, y2)
    local dirX = x2 - x1
    local dirY = y2 - y1

    local len = math.sqrt(dirX * dirX + dirY * dirY)
    dirX = dirX / len
    dirY = dirY / len

    return dirX, dirY
end

function utils.getDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function utils.getClosestBorder(playerX, playerY)
    local distances = {
        [1] = playerY,
        [2] = windowWidth - playerX,
        [3] = windowHeight - playerY,
        [4] = playerX
    }

    local distanceToEdge = {
        [playerY] = 1,
        [windowWidth - playerX] = 2,
        [windowHeight - playerY] = 3,
        [playerX] = 4
    }

    local smallestDistance = math.min(distances[1], distances[2], distances[3], distances[4])

    return distanceToEdge[smallestDistance]
end

return utils
