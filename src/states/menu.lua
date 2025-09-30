-- Main menu state

require("src.utils.ui_helpers")

MenuState = {}

local playButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "PLAY",
    hovered = false
}

function MenuState:enter()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    playButton.x = screenWidth / 2 - playButton.width / 2
    playButton.y = screenHeight / 2 + Config.ui.menuPlayButtonOffsetY
end

function MenuState:update(dt)
    playButton.hovered = UIHelpers.isMouseInRect(playButton)
end

function MenuState:draw()
    love.graphics.setBackgroundColor(Config.colors.background)

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.setColor(Config.colors.hud)
    love.graphics.printf("BOUNCE NETWORK", 0, screenHeight / 2 - Config.ui.titleOffsetY, screenWidth, "center")

    if playButton.hovered then
        love.graphics.setColor(Config.colors.buttonHover)
    else
        love.graphics.setColor(Config.colors.button)
    end
    love.graphics.rectangle("fill", playButton.x, playButton.y, playButton.width, playButton.height)

    love.graphics.setColor(Config.colors.buttonText)
    love.graphics.printf(playButton.text, playButton.x, playButton.y + Config.ui.buttonTextOffsetY, playButton.width, "center")
end

function MenuState:mousepressed(x, y, button)
    if button == 1 and playButton.hovered then
        StateManager.setState("gameplay")
    end
end

return MenuState