-- UI utility functions

UIHelpers = {}

function UIHelpers.isPointInRect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.width
       and y >= rect.y and y <= rect.y + rect.height
end

function UIHelpers.isMouseInRect(rect)
    local mx, my = love.mouse.getPosition()
    return UIHelpers.isPointInRect(mx, my, rect)
end

return UIHelpers