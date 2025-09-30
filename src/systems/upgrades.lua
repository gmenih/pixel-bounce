-- Upgrade system with 4 channels

require("src.utils.ui_helpers")

Upgrades = {
    levels = {
        speed = 0,
        size = 0,
        magnet = 0,
        cornering = 0
    },
    buttons = {},
    freeMode = false
}

function Upgrades.reset()
    Upgrades.levels.speed = 0
    Upgrades.levels.size = 0
    Upgrades.levels.magnet = 0
    Upgrades.levels.cornering = 0
end

function Upgrades.getCost(channel)
    local cfg = Config.upgrades[channel]
    local level = Upgrades.levels[channel]
    return math.floor(cfg.base * (cfg.growth ^ level))
end

function Upgrades.purchase(channel, currentSparks)
    if Upgrades.freeMode then
        Upgrades.levels[channel] = Upgrades.levels[channel] + 1
        return true, 0
    end

    local cost = Upgrades.getCost(channel)
    if currentSparks >= cost then
        Upgrades.levels[channel] = Upgrades.levels[channel] + 1
        return true, cost
    end
    return false, 0
end

function Upgrades.draw(currentSparks)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local panelWidth = 500
    local panelHeight = 400
    local panelX = screenWidth / 2 - panelWidth / 2
    local panelY = screenHeight / 2 - panelHeight / 2

    love.graphics.setColor(0.2, 0.2, 0.2, 0.95)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)

    love.graphics.setColor(Config.colors.hud)
    love.graphics.printf("UPGRADES", panelX, panelY + 20, panelWidth, "center")

    local channels = {
        {name = "speed", label = "Speed", desc = "+10% speed"},
        {name = "size", label = "Size", desc = "+1.5 radius"},
        {name = "magnet", label = "Magnetism", desc = "+22 magnet radius"},
        {name = "cornering", label = "Cornering", desc = "+2 proximity/angle"}
    }

    Upgrades.buttons = {}

    for i, channel in ipairs(channels) do
        local rowY = panelY + 70 + (i - 1) * 70
        local level = Upgrades.levels[channel.name]
        local cost = Upgrades.freeMode and 0 or Upgrades.getCost(channel.name)
        local canAfford = Upgrades.freeMode or currentSparks >= cost

        love.graphics.setColor(Config.colors.hud)
        love.graphics.print(channel.label .. " (Lv " .. level .. ")", panelX + 20, rowY)
        love.graphics.setFont(love.graphics.getFont())
        love.graphics.print(channel.desc, panelX + 20, rowY + 20)

        local button = {
            x = panelX + panelWidth - 140,
            y = rowY,
            width = 120,
            height = 50,
            channel = channel.name,
            canAfford = canAfford
        }
        button.hovered = UIHelpers.isMouseInRect(button)

        table.insert(Upgrades.buttons, button)

        if canAfford then
            if button.hovered then
                love.graphics.setColor(Config.colors.buttonHover)
            else
                love.graphics.setColor(Config.colors.button)
            end
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end

        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

        love.graphics.setColor(Config.colors.buttonText)
        love.graphics.printf("BUY\n" .. cost, button.x, button.y + 8, button.width, "center")
    end

    love.graphics.setColor(Config.colors.hud)
    local helpText = "Press U to close"
    if Upgrades.freeMode then
        helpText = "FREE MODE | Press U to close"
    else
        helpText = helpText .. " | F for free mode"
    end
    love.graphics.printf(helpText, panelX, panelY + panelHeight - Config.ui.upgradesPanelBottomMargin, panelWidth, "center")
end

function Upgrades.handleClick(x, y, currentSparks)
    for _, button in ipairs(Upgrades.buttons) do
        if x >= button.x and x <= button.x + button.width
        and y >= button.y and y <= button.y + button.height
        and button.canAfford then
            return Upgrades.purchase(button.channel, currentSparks)
        end
    end
    return false, 0
end

return Upgrades