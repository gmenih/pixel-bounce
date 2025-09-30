-- Gameplay utility functions

GameplayHelpers = {}

function GameplayHelpers.getBouncerRadius()
    return Config.physics.bouncerRadius + Upgrades.levels.size * Config.upgrades.size.delta
end

function GameplayHelpers.getMagnetRadius()
    return Config.physics.magnetRadius + Upgrades.levels.magnet * Config.upgrades.magnet.delta
end

return GameplayHelpers