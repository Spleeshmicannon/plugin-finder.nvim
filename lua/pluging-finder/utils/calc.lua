local M = {}

function M.clamp(val, min, max)
    if val < min then
        return min
    end

    if val > max then
        return max
    end

    return val
end

function M.centre(size, total)
    return math.floor((total - size) / 2)
end

return M
