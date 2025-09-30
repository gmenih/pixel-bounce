-- Pause state

require("src.utils.ui_helpers")

PauseState = {}

local resumeButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "RESUME",
    hovered = false
}

local quitButton = {
    x = 0,
    y = 0,
    width = 200,
    height = 60,
    text = "QUIT TO MENU",
    hovered = false
}

function PauseState:enter()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    resumeButton.x = screenWidth / 2 - resumeButton.width / 2
    resumeButton.y = screenHeight / 2 + Config.ui.pauseResumeButtonOffsetY

    quitButton.x = screenWidth / 2 - quitButton.width / 2
    quitButton.y = screenHeight / 2 + Config.ui.pauseQuitButtonOffsetY
end

function PauseState:update(dt)
    resumeButton.hovered = UIHelpers.isMouseInRect(resumeButton)
    quitButton.hovered = UIHelpers.isMouseInRect(quitButton)
end

function PauseState:draw()
    love.graphics.setBackgroundColor(Config.colors.background)

    local screenWidth = love.graphics.getWidth()

    love.graphics.setColor(Config.colors.hud)
    love.graphics.printf("PAUSED", 0, 200, screenWidth, "center")

    if resumeButton.hovered then
        love.graphics.setColor(Config.colors.buttonHover)
    else
        love.graphics.setColor(Config.colors.button)
    end
    love.graphics.rectangle("fill", resumeButton.x, resumeButton.y, resumeButton.width, resumeButton.height)

    love.graphics.setColor(Config.colors.buttonText)
    love.graphics.printf(resumeButton.text, resumeButton.x, resumeButton.y + Config.ui.buttonTextOffsetY, resumeButton.width, "center")

    if quitButton.hovered then
        love.graphics.setColor(Config.colors.buttonHover)
    else
        love.graphics.setColor(Config.colors.button)
    end
    love.graphics.rectangle("fill", quitButton.x, quitButton.y, quitButton.width, quitButton.height)

    love.graphics.setColor(Config.colors.buttonText)
    love.graphics.printf(quitButton.text, quitButton.x, quitButton.y + Config.ui.buttonTextOffsetY, quitButton.width, "center")
end

function PauseState:keypressed(key)
    if key == "escape" then
        StateManager.setState("gameplay")
    end
end

function PauseState:mousepressed(x, y, button)
    if button == 1 then
        if resumeButton.hovered then
            StateManager.setState("gameplay")
        elseif quitButton.hovered then
            StateManager.setState("menu")
        end
    end
end

return PauseState