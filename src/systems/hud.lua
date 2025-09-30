-- HUD display system

HUD = {}

function HUD.draw(totalSparks, multiplier, bouncerCount, cornerHits, arena, seed)
    love.graphics.setColor(Config.colors.hud)

    love.graphics.print("Sparks: " .. math.floor(totalSparks), 10, 10)
    love.graphics.print("Multiplier: x" .. string.format("%.1f", multiplier), 10, 30)
    love.graphics.print("Bouncers: " .. bouncerCount, 10, 50)
    love.graphics.print("Corner Hits: " .. cornerHits, 10, 70)

    local screenWidth = love.graphics.getWidth()
    local shapeNames = {
        [4] = "Square",
        [6] = "Hexagon",
        [8] = "Octagon"
    }
    local shapeName = shapeNames[arena.sides] or "Polygon"

    local screenHeight = love.graphics.getHeight()
    love.graphics.print("ESC: Pause | F: Free Mode", 10, screenHeight - 25)
end

return HUD