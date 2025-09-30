-- Bounce Network - Love2D Prototype
-- Main entry point

require("config")
require("src.state_manager")
require("src.states.menu")
require("src.states.gameplay")
require("src.states.pause")

function love.load()
    -- Window setup
    love.window.setTitle(Config.window.title)
    love.window.setMode(Config.window.width, Config.window.height, {
        resizable = Config.window.resizable,
        vsync = Config.window.vsync,
        msaa = Config.window.msaa
    })

    -- Initialize random seed
    math.randomseed(os.time())
    Config.rngSeed = math.random(1, 999999)
    math.randomseed(Config.rngSeed)

    -- Initialize state manager
    StateManager.init()
    StateManager.setState("menu")
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end

function love.keypressed(key)
    StateManager.keypressed(key)
end

function love.mousepressed(x, y, button)
    StateManager.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    StateManager.mousereleased(x, y, button)
end