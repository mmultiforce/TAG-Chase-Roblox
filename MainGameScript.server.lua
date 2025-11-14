-- Main Game Script
-- This script initializes and starts the TAG/CHASE game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Print game startup message
print("========================================")
print("    TAG/CHASE GAME STARTING UP")
print("========================================")

-- Game Configuration
local MIN_PLAYERS = 2
local GAME_CONFIG = {
    GAME_DURATION = 300, -- 5 minutes
    GRACE_PERIOD = 5, -- 5 seconds
    SPAWN_ZONES_SEPARATION = 100,
    CHASER_COLOR = BrickColor.new("Bright red"),
    RUNNER_COLOR = BrickColor.new("Bright blue")
}

-- Create game structure
local function createGameStructure()
    print("Creating game structure...")
    
    -- Create folders for organization
    local gameFolder = Instance.new("Folder")
    gameFolder.Name = "TagChaseGame"
    gameFolder.Parent = workspace
    
    local configFolder = Instance.new("Folder")
    configFolder.Name = "Config"
    configFolder.Parent = gameFolder
    
    -- Store configuration
    local configValue = Instance.new("StringValue")
    configValue.Name = "GameConfig"
    configValue.Value = game.HttpService:JSONEncode(GAME_CONFIG)
    configValue.Parent = configFolder
    
    return gameFolder
end

-- Load game modules
local function loadGameModules()
    print("Loading game modules...")
    
    -- Get the game manager (this will be the main script)
    local gameManager = script.Parent:FindFirstChild("TagChaseGameManager")
    if gameManager then
        print("Game Manager found: " .. gameManager:GetFullName())
    else
        warn("Game Manager not found!")
    end
    
    -- Load other modules
    local modules = {
        "RoleManager",
        "SpawnManager", 
        "UIManager"
    }
    
    for _, moduleName in ipairs(modules) do
        local module = script.Parent:FindFirstChild(moduleName)
        if module then
            print("Module loaded: " .. moduleName)
        else
            warn("Module not found: " .. moduleName)
        end
    end
end

-- Setup player scripts
local function setupPlayerScripts()
    print("Setting up player scripts...")
    
    local StarterPlayer = game:GetService("StarterPlayer")
    local StarterPlayerScripts = StarterPlayer:WaitForChild("StarterPlayerScripts")
    
    -- Create client UI handler
    local clientScript = script.Parent:FindFirstChild("ClientUIHandler")
    if clientScript then
        local clone = clientScript:Clone()
        clone.Parent = StarterPlayerScripts
        print("Client UI Handler setup complete")
    else
        warn("Client UI Handler not found!")
    end
end

-- Initialize game
local function initializeGame()
     print("Initializing TAG/CHASE game...")

     -- Create game structure
     local gameFolder = createGameStructure()

     -- Load modules
     loadGameModules()

     -- Initialize UI manager FIRST - before client scripts
     local UIManager = require(script.Parent:FindFirstChild("UIManager"))
     UIManager.initialize()

     -- Setup player scripts after UI manager is ready
     setupPlayerScripts()

     -- Wait for game manager to be ready
     local gameManager = script.Parent:FindFirstChild("TagChaseGameManager")
     if gameManager then
         -- Create and start game manager
         local GameManager = require(gameManager)
         local gameManagerInstance = GameManager.new()

         -- Initialize spawn manager first
         local SpawnManager = require(script.Parent:FindFirstChild("SpawnManager"))
         SpawnManager.initialize()

         -- Start the game
         gameManagerInstance:initialize()

         print("Game manager initialized and started!")
     else
         warn("Failed to initialize game - Game Manager not found")
     end
end

-- Setup teams (optional, for future expansion)
local function setupTeams()
    local Teams = game:GetService("Teams")
    
    -- Create Chaser team
    local chaserTeam = Instance.new("Team")
    chaserTeam.Name = "Chasers"
    chaserTeam.TeamColor = BrickColor.new("Bright red")
    chaserTeam.AutoAssignable = false
    chaserTeam.Parent = Teams
    
    -- Create Runner team
    local runnerTeam = Instance.new("Team")
    runnerTeam.Name = "Runners"
    runnerTeam.TeamColor = BrickColor.new("Bright blue")
    runnerTeam.AutoAssignable = false
    runnerTeam.Parent = Teams
    
    print("Teams setup complete")
end

-- Main initialization
task.spawn(function()
    -- Setup teams
    setupTeams()
    
    -- Wait a moment for everything to load
    task.wait(1)
    
    -- Initialize the game
    initializeGame()
    
    print("========================================")
    print("   TAG/CHASE GAME READY TO PLAY!")
    print("   Waiting for players to join...")
    print("========================================")
end)

-- Cleanup function
local function cleanup()
    print("Cleaning up game...")
    
    -- Remove game folder
    local gameFolder = workspace:FindFirstChild("TagChaseGame")
    if gameFolder then
        gameFolder:Destroy()
    end
    
    -- Clean up spawn zones
    local spawnZones = workspace:FindFirstChild("SpawnZones")
    if spawnZones then
        spawnZones:Destroy()
    end
    
    -- Clean up ground parts
    for _, part in ipairs(workspace:GetChildren()) do
        if part.Name:match("ChaserGround") or part.Name:match("RunnerGround") then
            part:Destroy()
        end
    end
    
    -- Clean up spawn points
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("SpawnLocation") and (part.Name:match("ChaserSpawn") or part.Name:match("RunnerSpawn")) then
            part:Destroy()
        end
    end
end

-- Handle game shutdown
game:BindToClose(function()
    cleanup()
end)

print("Main game script loaded successfully!")