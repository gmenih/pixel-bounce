-- Bouncer entity with physics

Bouncer = {}

function Bouncer.new(x, y, velX, velY)
    return {
        x = x,
        y = y,
        velX = velX,
        velY = velY,
        color = {
            math.random() * 0.5 + 0.5,
            math.random() * 0.5 + 0.5,
            math.random() * 0.5 + 0.5
        }
    }
end

function Bouncer.update(bouncer, dt)
    local speed = Config.physics.bouncerBaseSpeed
    if Upgrades and Upgrades.levels.speed then
        speed = speed * (1 + Upgrades.levels.speed * Config.upgrades.speed.delta)
    end

    bouncer.x = bouncer.x + bouncer.velX * speed * dt
    bouncer.y = bouncer.y + bouncer.velY * speed * dt
end

function Bouncer.reflect(bouncer, normalX, normalY)
    local dotProduct = bouncer.velX * normalX + bouncer.velY * normalY
    bouncer.velX = bouncer.velX - 2 * dotProduct * normalX
    bouncer.velY = bouncer.velY - 2 * dotProduct * normalY

    local len = math.sqrt(bouncer.velX * bouncer.velX + bouncer.velY * bouncer.velY)
    if len > 0 then
        bouncer.velX = bouncer.velX / len
        bouncer.velY = bouncer.velY / len
    end
end

function Bouncer.draw(bouncer, radius)
    if bouncer.color then
        love.graphics.setColor(bouncer.color)
    else
        love.graphics.setColor(Config.colors.bouncer)
    end
    local halfSize = radius
    love.graphics.rectangle("fill", bouncer.x - halfSize, bouncer.y - halfSize, halfSize * 2, halfSize * 2)
end

return Bouncer