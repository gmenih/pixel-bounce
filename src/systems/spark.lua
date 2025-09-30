-- Spark system with pooling and magnetism

Spark = {}

function Spark.new(x, y, sparkType)
    sparkType = sparkType or "white"
    local typeConfig = Config.sparkTypes[sparkType]

    return {
        x = x,
        y = y,
        active = false,
        sparkType = sparkType,
        value = typeConfig.value,
        color = typeConfig.color
    }
end

function Spark.selectRandomType()
    local totalWeight = 0
    for _, sparkType in pairs(Config.sparkTypes) do
        totalWeight = totalWeight + sparkType.spawnWeight
    end

    local rand = math.random() * totalWeight
    local cumulative = 0

    local orderedTypes = {"white", "blue", "green", "purple", "pink"}
    for _, typeName in ipairs(orderedTypes) do
        local sparkType = Config.sparkTypes[typeName]
        cumulative = cumulative + sparkType.spawnWeight
        if rand <= cumulative then
            return typeName
        end
    end

    return "white"
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

function Spark.isHovered(spark, mouseX, mouseY)
    if not spark.active then
        return false
    end

    local dx = mouseX - spark.x
    local dy = mouseY - spark.y
    local distSq = dx * dx + dy * dy
    local radiusSq = Config.physics.sparkRadius * Config.physics.sparkRadius

    return distSq <= radiusSq
end

function Spark.updateHover(sparks, mouseX, mouseY)
    for _, spark in ipairs(sparks) do
        if spark.active then
            spark.hovered = Spark.isHovered(spark, mouseX, mouseY)
        end
    end
end

function Spark.draw(spark)
    if spark.active then
        if spark.color then
            love.graphics.setColor(spark.color)
        else
            love.graphics.setColor(Config.colors.spark)
        end

        local radius = Config.physics.sparkRadius
        if spark.hovered then
            radius = radius * 1.5
        end

        love.graphics.circle("fill", spark.x, spark.y, radius)
    end
end

return Spark