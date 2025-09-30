-- State management system

StateManager = {
    currentState = nil,
    states = {}
}

function StateManager.init()
    StateManager.states.menu = MenuState
    StateManager.states.gameplay = GameplayState
    StateManager.states.pause = PauseState
end

function StateManager.setState(stateName)
    local newState = StateManager.states[stateName]
    if not newState then
        error("State '" .. stateName .. "' does not exist")
    end

    if StateManager.currentState and StateManager.currentState.exit then
        local success, err = pcall(StateManager.currentState.exit, StateManager.currentState)
        if not success then
            print("Error exiting state: " .. tostring(err))
        end
    end

    StateManager.currentState = newState

    if StateManager.currentState.enter then
        local success, err = pcall(StateManager.currentState.enter, StateManager.currentState)
        if not success then
            error("Error entering state '" .. stateName .. "': " .. tostring(err))
        end
    end
end

function StateManager.update(dt)
    if StateManager.currentState and StateManager.currentState.update then
        StateManager.currentState:update(dt)
    end
end

function StateManager.draw()
    if StateManager.currentState and StateManager.currentState.draw then
        StateManager.currentState:draw()
    end
end

function StateManager.keypressed(key)
    if StateManager.currentState and StateManager.currentState.keypressed then
        StateManager.currentState:keypressed(key)
    end
end

function StateManager.mousepressed(x, y, button)
    if StateManager.currentState and StateManager.currentState.mousepressed then
        StateManager.currentState:mousepressed(x, y, button)
    end
end

function StateManager.mousereleased(x, y, button)
    if StateManager.currentState and StateManager.currentState.mousereleased then
        StateManager.currentState:mousereleased(x, y, button)
    end
end

return StateManager