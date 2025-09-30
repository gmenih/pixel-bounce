-- Corner events system (jackpot effects)

CornerEvents = {}

function CornerEvents.selectEffect()
    local weights = Config.corner.effectWeights
    local total = weights.Clone + weights.Burst + weights.Boost
    local rand = math.random() * total

    local cumulative = 0
    for effect, weight in pairs(weights) do
        cumulative = cumulative + weight
        if rand <= cumulative then
            return effect
        end
    end

    return "Clone"
end

return CornerEvents