-- Polygon arena system with collision detection

Arena = {}

function Arena.new(sides, centerX, centerY, radius)
    assert(type(sides) == "number" and sides >= 3, "Arena must have at least 3 sides")
    assert(type(radius) == "number" and radius > 0, "Arena radius must be positive")
    assert(type(centerX) == "number", "Arena centerX must be a number")
    assert(type(centerY) == "number", "Arena centerY must be a number")

    local arena = {
        sides = sides,
        centerX = centerX,
        centerY = centerY,
        radius = radius,
        vertices = {},
        edges = {},
        cornerProximity = Config.corner.proximityPx,
        cornerAngle = math.rad(Config.corner.angleDeg)
    }

    Arena.generatePolygon(arena)

    return arena
end

function Arena.generatePolygon(arena)
    arena.vertices = {}
    arena.edges = {}

    local angleStep = (2 * math.pi) / arena.sides
    local startAngle = 0
    if arena.sides == 4 then
        startAngle = math.pi / 4
    end

    for i = 1, arena.sides do
        local angle = (i - 1) * angleStep + startAngle
        local x = arena.centerX + arena.radius * math.cos(angle)
        local y = arena.centerY + arena.radius * math.sin(angle)
        table.insert(arena.vertices, {x = x, y = y})
    end

    for i = 1, arena.sides do
        local v1 = arena.vertices[i]
        local v2 = arena.vertices[(i % arena.sides) + 1]

        local edgeX = v2.x - v1.x
        local edgeY = v2.y - v1.y
        local len = math.sqrt(edgeX * edgeX + edgeY * edgeY)

        local normalX = -edgeY / len
        local normalY = edgeX / len

        table.insert(arena.edges, {
            v1 = v1,
            v2 = v2,
            normalX = normalX,
            normalY = normalY
        })
    end
end

function Arena.checkCollision(arena, bouncer)
    local result = {
        collided = false,
        normalX = 0,
        normalY = 0,
        cornerHit = false
    }

    local bouncerRadius = Config.physics.bouncerRadius +
                         (Upgrades and Upgrades.levels.size or 0) * Config.upgrades.size.delta

    for i, edge in ipairs(arena.edges) do
        local v1 = edge.v1
        local v2 = edge.v2

        local edgeX = v2.x - v1.x
        local edgeY = v2.y - v1.y
        local edgeLen = math.sqrt(edgeX * edgeX + edgeY * edgeY)

        local toBouncer = {
            x = bouncer.x - v1.x,
            y = bouncer.y - v1.y
        }

        local projection = (toBouncer.x * edgeX + toBouncer.y * edgeY) / (edgeLen * edgeLen)
        projection = math.max(0, math.min(1, projection))

        local closestX = v1.x + projection * edgeX
        local closestY = v1.y + projection * edgeY

        local distX = bouncer.x - closestX
        local distY = bouncer.y - closestY
        local distSq = distX * distX + distY * distY
        local radiusSq = bouncerRadius * bouncerRadius

        if distSq < radiusSq then
            result.collided = true
            result.normalX = edge.normalX
            result.normalY = edge.normalY

            local dist = math.sqrt(distSq)
            if dist > 0 then
                local overlap = bouncerRadius - dist
                bouncer.x = bouncer.x + (distX / dist) * overlap
                bouncer.y = bouncer.y + (distY / dist) * overlap
            end

            local cornerProximity = Config.corner.proximityPx +
                                  (Upgrades and Upgrades.levels.cornering or 0) * Config.upgrades.cornering.proximityDelta
            local cornerAngle = math.rad(Config.corner.angleDeg +
                               (Upgrades and Upgrades.levels.cornering or 0) * Config.upgrades.cornering.angleDelta)

            for _, vertex in ipairs(arena.vertices) do
                local vdx = bouncer.x - vertex.x
                local vdy = bouncer.y - vertex.y
                local vdist = math.sqrt(vdx * vdx + vdy * vdy)

                if vdist <= cornerProximity then
                    local velLen = math.sqrt(bouncer.velX * bouncer.velX + bouncer.velY * bouncer.velY)
                    if velLen > 0 then
                        local velNormX = bouncer.velX / velLen
                        local velNormY = bouncer.velY / velLen

                        local bisectorX = edge.normalX
                        local bisectorY = edge.normalY

                        local dotProduct = velNormX * bisectorX + velNormY * bisectorY
                        local angle = math.acos(math.max(-1, math.min(1, -dotProduct)))

                        if angle <= cornerAngle then
                            result.cornerHit = true
                            break
                        end
                    end
                end
            end

            break
        end
    end

    return result
end

function Arena.randomPointInside(arena, padding)
    local maxAttempts = 100
    for attempt = 1, maxAttempts do
        local angle = math.random() * 2 * math.pi
        local r = math.sqrt(math.random()) * (arena.radius - padding)
        local x = arena.centerX + r * math.cos(angle)
        local y = arena.centerY + r * math.sin(angle)

        local inside = true
        for _, edge in ipairs(arena.edges) do
            local toPoint = {
                x = x - edge.v1.x,
                y = y - edge.v1.y
            }
            local dotProd = toPoint.x * edge.normalX + toPoint.y * edge.normalY
            if dotProd < -padding then
                inside = false
                break
            end
        end

        if inside then
            return {x = x, y = y}
        end
    end

    return {x = arena.centerX, y = arena.centerY}
end

function Arena.draw(arena)
    love.graphics.setColor(Config.colors.arena)
    love.graphics.setLineWidth(2)

    for i = 1, #arena.vertices do
        local v1 = arena.vertices[i]
        local v2 = arena.vertices[(i % #arena.vertices) + 1]
        love.graphics.line(v1.x, v1.y, v2.x, v2.y)
    end
end

return Arena