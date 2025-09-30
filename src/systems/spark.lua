-- Spark system with pooling and magnetism

Spark = {}

function Spark.new(x, y)
    return {
        x = x,
        y = y,
        active = false,
        value = 1
    }
end

function Spark.applyMagnetism(sparks, bouncer, magnetRadius, dt)
    local magnetRadiusSq = magnetRadius * magnetRadius

    for _, spark in ipairs(sparks) do
        if spark.active then
            local dx = bouncer.x - spark.x
            local dy = bouncer.y - spark.y
            local distSq = dx * dx + dy * dy

            if distSq < magnetRadiusSq and distSq > 0 then
                local dist = math.sqrt(distSq)
                local accel = Config.physics.magnetStrength * dt

                spark.x = spark.x + (dx / dist) * accel
                spark.y = spark.y + (dy / dist) * accel
            end
        end
    end
end

function Spark.draw(spark)
    if spark.active then
        love.graphics.setColor(Config.colors.spark)
        love.graphics.circle("fill", spark.x, spark.y, Config.physics.sparkRadius)
    end
end

return Spark