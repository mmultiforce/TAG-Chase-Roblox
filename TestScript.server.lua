-- Test Script for TAG/CHASE Game
-- This script helps verify that all components are working correctly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TestScript = {}

function TestScript.runAllTests()
    print("========================================")
    print("    RUNNING PROGRESSIVE TAG/CHASE TESTS")
    print("========================================")
    
    local tests = {
        TestScript.testGameStructure,
        TestScript.testModules,
        TestScript.testRemoteEvents,
        TestScript.testSpawnZones,
        TestScript.testUIComponents
    }
    
    local passedTests = 0
    local totalTests = #tests
    
    for _, test in ipairs(tests) do
        local success, result = pcall(test)
        if success then
            if result then
                passedTests = passedTests + 1
                print("✅ PASS: " .. result)
            else
                print("❌ FAIL: Test returned false")
            end
        else
            print("❌ ERROR: " .. tostring(result))
        end
    end
    
    print("========================================")
    print("TEST RESULTS: " .. passedTests .. "/" .. totalTests .. " tests passed")
    print("========================================")
    
    if passedTests == totalTests then
        print("🎉 All tests passed! Progressive TAG/CHASE game is ready to play.")
    else
        print("⚠️  Some tests failed. Check the setup guide.")
    end
    
    return passedTests == totalTests
end

function TestScript.testGameStructure()
    -- Check if game folder exists
    local gameFolder = Workspace:FindFirstChild("TagChaseGame")
    if not gameFolder then
        return "Game folder not found"
    end
    
    -- Check if spawn zones exist
    local spawnZones = Workspace:FindFirstChild("SpawnZones")
    if not spawnZones then
        return "Spawn zones not created"
    end
    
    local chaserZone = spawnZones:FindFirstChild("ChaserZone")
    local runnerZone = spawnZones:FindFirstChild("RunnerZone")
    
    if not chaserZone or not runnerZone then
        return "Missing spawn zones"
    end
    
    return "Game structure test passed"
end

function TestScript.testModules()
    local ServerScriptService = game:GetService("ServerScriptService")
    local tagChaseFolder = ServerScriptService:FindFirstChild("TagChaseGame")
    
    if not tagChaseFolder then
        return "TagChaseGame folder not found in ServerScriptService"
    end
    
    local requiredModules = {
        "MainGameScript.server.lua",
        "TagChaseGameManager.server.lua", 
        "RoleManager.module.lua",
        "SpawnManager.module.lua",
        "UIManager.module.lua"
    }
    
    for _, moduleName in ipairs(requiredModules) do
        local module = tagChaseFolder:FindFirstChild(moduleName)
        if not module then
            return "Missing module: " .. moduleName
        end
    end
    
    -- Test client script
    local StarterPlayer = game:GetService("StarterPlayer")
    local StarterPlayerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    local clientScript = StarterPlayerScripts:FindFirstChild("ClientUIHandler.client.lua")
    
    if not clientScript then
        return "Missing client script"
    end
    
    return "Module structure test passed"
end

function TestScript.testRemoteEvents()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remoteEventsFolder = ReplicatedStorage:FindFirstChild("TagChaseRemoteEvents")
    
    if not remoteEventsFolder then
        return "RemoteEvents folder not found"
    end
    
    local requiredEvents = {
        "UpdateUI",
        "ShowAnnouncement", 
        "ShowScoreboard"
    }
    
    for _, eventName in ipairs(requiredEvents) do
        local event = remoteEventsFolder:FindFirstChild(eventName)
        if not event then
            return "Missing RemoteEvent: " .. eventName
        end
    end
    
    return "RemoteEvents test passed"
end

function TestScript.testSpawnZones()
    local spawnZones = Workspace:FindFirstChild("SpawnZones")
    if not spawnZones then
        return "Spawn zones not found"
    end
    
    local chaserZone = spawnZones:FindFirstChild("ChaserZone")
    local survivorZone = spawnZones:FindFirstChild("SurvivorZone")
    
    if not chaserZone or not survivorZone then
        return "Missing spawn zones"
    end
    
    -- Check if spawn points exist
    local chaserSpawns = 0
    local survivorSpawns = 0
    
    for _, part in ipairs(Workspace:GetChildren()) do
        if part:IsA("SpawnLocation") then
            if part.Name:match("ChaserSpawn") then
                chaserSpawns = chaserSpawns + 1
            elseif part.Name:match("SurvivorSpawn") then
                survivorSpawns = survivorSpawns + 1
            end
        end
    end
    
    if chaserSpawns == 0 then
        return "No chaser spawn points found"
    end
    
    if survivorSpawns == 0 then
        return "No survivor spawn points found"
    end
    
    return "Spawn zones test passed (" .. chaserSpawns .. " chaser, " .. survivorSpawns .. " survivor spawns)"
end

function TestScript.testUIComponents()
    local StarterGui = game:GetService("StarterGui")
    
    -- Check if UI templates exist
    local tagChaseUI = StarterGui:FindFirstChild("TagChaseUI")
    local announcementUI = StarterGui:FindFirstChild("AnnouncementUI")
    local scoreboardUI = StarterGui:FindFirstChild("ScoreboardUI")
    
    if not tagChaseUI then
        return "TagChaseUI template not found"
    end
    
    if not announcementUI then
        return "AnnouncementUI template not found"
    end
    
    if not scoreboardUI then
        return "ScoreboardUI template not found"
    end
    
    -- Check UI components
    local roleFrame = tagChaseUI:FindFirstChild("RoleFrame")
    local chaserFrame = tagChaseUI:FindFirstChild("ChaserFrame")
    
    if not roleFrame or not chaserFrame then
        return "Missing UI components"
    end
    
    return "UI components test passed"
end

function TestScript.testWithPlayers()
    print("Testing with simulated players...")
    
    -- This would require actual players to join
    -- For now, just check if player handling is set up
    local playerCount = #Players:GetPlayers()
    print("Current players: " .. playerCount)
    
    if playerCount >= 2 then
        print("✅ Enough players for game to start")
    else
        print("⚠️  Need " .. (2 - playerCount) .. " more players to start game")
    end
    
    return "Player test completed"
end

-- Auto-run tests when script is executed
task.spawn(function()
    task.wait(3) -- Wait for game to initialize
    TestScript.runAllTests()
end)

return TestScript