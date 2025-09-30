-- Gameplay state with fixed timestep physics

require("src.systems.arena")
require("src.systems.bouncer")
require("src.systems.spark")
require("src.systems.corner_events")
require("src.systems.upgrades")
require("src.systems.hud")
require("src.utils.gameplay_helpers")

GameplayState = {
    accumulator = 0,
    arena = nil,
    bouncers = {},
    sparks = {},
    sparkPool = {},
    totalSparks = 0,
    globalMultiplier = 1.0,
    cornerHits = 0,
    boostTimer = 0,
    spawnTimer = 0,
    upgradesVisible = false
}

function GameplayState:enter()
    self.accumulator = 0
    self.bouncers = {}
    self.sparks = {}
    self.sparkPool = {}
    self.totalSparks = 0
    self.globalMultiplier = 1.0
    self.cornerHits = 0
    self.boostTimer = 0
    self.spawnTimer = 0
    self.upgradesVisible = false

    Upgrades.reset()

    self.arena = Arena.new(4, Config.arena.centerX, Config.arena.centerY, Config.arena.radius)

    local startX = Config.arena.centerX
    local startY = Config.arena.centerY - 50
    local startVelX = math.random() * 2 - 1
    local startVelY = math.random() * 2 - 1
    local len = math.sqrt(startVelX * startVelX + startVelY * startVelY)
    startVelX = startVelX / len
    startVelY = startVelY / len

    table.insert(self.bouncers, Bouncer.new(startX, startY, startVelX, startVelY))

    for i = 1, Config.physics.maxSparks do
        table.insert(self.sparkPool, Spark.new(0, 0))
    end
end

function GameplayState:update(dt)
    self.accumulator = self.accumulator + dt

    while self.accumulator >= Config.physics.fixedDt do
        self:fixedUpdate(Config.physics.fixedDt)
        self.accumulator = self.accumulator - Config.physics.fixedDt
    end

    local mouseX, mouseY = love.mouse.getPosition()
    Spark.updateHover(self.sparks, mouseX, mouseY)
end

function GameplayState:fixedUpdate(dt)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= 1.0 / Config.physics.spawnPerSecond then
        self.spawnTimer = 0
        self:spawnSpark()
    end

    if self.boostTimer > 0 then
        self.boostTimer = self.boostTimer - dt
        if self.boostTimer <= 0 then
            self.globalMultiplier = 1.0
        end
    end

    for i = #self.bouncers, 1, -1 do
        local bouncer = self.bouncers[i]
        Bouncer.update(bouncer, dt)

        local collisionResult = Arena.checkCollision(self.arena, bouncer)
        if collisionResult.collided then
            Bouncer.reflect(bouncer, collisionResult.normalX, collisionResult.normalY)

            if collisionResult.cornerHit then
                self:handleCornerEvent(bouncer)
            end
        end

        self:checkSparkCollection(bouncer)
    end

    local magnetRadius = GameplayHelpers.getMagnetRadius()
    if magnetRadius > 0 then
        for _, bouncer in ipairs(self.bouncers) do
            Spark.applyMagnetism(self.sparks, bouncer, magnetRadius, dt)
        end
    end
end

function GameplayState:spawnSpark()
    local activeSparks = #self.sparks
    if activeSparks >= Config.physics.maxSparks then
        return
    end

    local spark = table.remove(self.sparkPool)
    if not spark then
        return
    end

    local sparkType = Spark.selectRandomType()
    local typeConfig = Config.sparkTypes[sparkType]

    local pos = Arena.randomPointInside(self.arena, Config.physics.wallPadding)
    spark.x = pos.x
    spark.y = pos.y
    spark.active = true
    spark.sparkType = sparkType
    spark.value = typeConfig.value
    spark.color = typeConfig.color

    table.insert(self.sparks, spark)
end

function GameplayState:checkSparkCollection(bouncer)
    local bouncerRadius = GameplayHelpers.getBouncerRadius()
    local collectRadiusSq = (bouncerRadius + Config.physics.sparkRadius) * (bouncerRadius + Config.physics.sparkRadius)

    for i = #self.sparks, 1, -1 do
        local spark = self.sparks[i]
        local dx = spark.x - bouncer.x
        local dy = spark.y - bouncer.y
        local distSq = dx * dx + dy * dy

        if distSq <= collectRadiusSq then
            self.totalSparks = self.totalSparks + spark.value * self.globalMultiplier
            spark.active = false
            table.insert(self.sparkPool, table.remove(self.sparks, i))
        end
    end
end

function GameplayState:handleCornerEvent(bouncer)
    self.cornerHits = self.cornerHits + 1

    local effectType = CornerEvents.selectEffect()

    if effectType == "Clone" then
        local angle = math.atan2(bouncer.velY, bouncer.velX)
        local spreadAngle = math.rad(45)

        local newAngle = angle + spreadAngle
        local vx = math.cos(newAngle)
        local vy = math.sin(newAngle)
        table.insert(self.bouncers, Bouncer.new(bouncer.x, bouncer.y, vx, vy))

        bouncer.velX = math.cos(angle - spreadAngle)
        bouncer.velY = math.sin(angle - spreadAngle)
    elseif effectType == "Burst" then
        for i = 1, Config.corner.burstCount do
            self:spawnSpark()
        end
    elseif effectType == "Boost" then
        self.globalMultiplier = Config.corner.boostMultiplier
        self.boostTimer = Config.corner.boostDuration
    end
end

function GameplayState:draw()
    love.graphics.setBackgroundColor(Config.colors.background)

    Arena.draw(self.arena)

    for _, spark in ipairs(self.sparks) do
        Spark.draw(spark)
    end

    local bouncerRadius = GameplayHelpers.getBouncerRadius()
    for _, bouncer in ipairs(self.bouncers) do
        Bouncer.draw(bouncer, bouncerRadius)
    end

    HUD.draw(self.totalSparks, self.globalMultiplier, #self.bouncers, self.cornerHits, self.arena, Config.rngSeed)

    Upgrades.draw(self.totalSparks)
end

function GameplayState:keypressed(key)
    if key == "escape" then
        StateManager.setState("pause")
    elseif key == "f" then
        Upgrades.freeMode = not Upgrades.freeMode
    end
end

function GameplayState:mousepressed(x, y, button)
    if button == 1 then
        for i = #self.sparks, 1, -1 do
            local spark = self.sparks[i]
            if spark.active and Spark.isHovered(spark, x, y) then
                self.totalSparks = self.totalSparks + spark.value * self.globalMultiplier
                spark.active = false
                table.insert(self.sparkPool, table.remove(self.sparks, i))
                return
            end
        end

        local purchased, cost = Upgrades.handleClick(x, y, self.totalSparks)
        if purchased then
            self.totalSparks = self.totalSparks - cost
        end
    end
end

return GameplayState