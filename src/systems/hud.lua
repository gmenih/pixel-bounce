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

    love.graphics.printf("Screen A — " .. shapeName, screenWidth - 200, 10, 190, "right")
    love.graphics.printf("Sides: " .. arena.sides, screenWidth - 200, 30, 190, "right")
    love.graphics.printf("Seed: " .. seed, screenWidth - 200, 50, 190, "right")

    local screenHeight = love.graphics.getHeight()
    love.graphics.print("U: Upgrades | ESC: Pause", 10, screenHeight - 25)
end

return HUD