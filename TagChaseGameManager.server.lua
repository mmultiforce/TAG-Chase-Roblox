-- TagChaseGameManager
-- Main game controller for TAG/CHASE game mechanics
-- Progressive chase: when a survivor gets caught, they become a chaser too!

local TagChaseGameManager = {}
TagChaseGameManager.__index = TagChaseGameManager

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local DebrisService = game:GetService("Debris")

-- Dependencies
local RoleManager = require(script.Parent:FindFirstChild("RoleManager"))
local SpawnManager = require(script.Parent:FindFirstChild("SpawnManager"))
local UIManager = require(script.Parent:FindFirstChild("UIManager"))

-- Game Configuration
local GAME_DURATION = 300 -- 5 minutes in seconds
local GRACE_PERIOD = 5 -- 5 seconds grace period for initial chaser

function TagChaseGameManager.new()
    local self = setmetatable({}, TagChaseGameManager)
    
    self.gameState = {
        isActive = false,
        timeRemaining = GAME_DURATION,
        startTime = 0,
        gracePeriodActive = false,
        gameStartTime = 0
    }
    
    self.players = {}
    self.scoreboard = {}
    
    return self
end

function TagChaseGameManager:initialize()
    print("Initializing Tag Chase Game Manager...")
    
    -- Connect player events
    Players.PlayerAdded:Connect(function(player)
        self:onPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:onPlayerRemoved(player)
    end)
    
    -- Wait for players to join before starting
    self:waitForPlayersAndStart()
end

function TagChaseGameManager:onPlayerAdded(player)
    print("Player added: " .. player.Name)
    
    -- Initialize player data
    self.players[player.UserId] = {
        player = player,
        role = "Survivor",
        roleChanges = 0,
        survivalStartTime = 0,
        totalSurvivalTime = 0,
        caughtTime = nil
    }
    
    -- Setup character spawn
    player.CharacterAdded:Connect(function(character)
        self:onCharacterSpawned(player, character)
    end)
end

function TagChaseGameManager:onPlayerRemoved(player)
    print("Player removed: " .. player.Name)
    
    -- Clean up player data
    if self.players[player.UserId] then
        self.players[player.UserId] = nil
    end
    
    -- If the chaser leaves, select a new one
    if self.gameState.currentChaser == player then
        self:selectNewChaser()
    end
end

function TagChaseGameManager:onCharacterSpawned(player, character)
    -- Wait for character to fully load
    character:WaitForChild("Humanoid")
    
    -- Spawn player based on role
    local role = RoleManager.getRole(player)
    SpawnManager.spawnPlayer(player, character, role)
    
    -- Setup collision detection for chasers
    if role == "Chaser" then
        self:setupChaserCollision(player, character)
    end
    
    -- Update UI
    UIManager.updatePlayerUI(player, role, self.gameState.timeRemaining)
end

function TagChaseGameManager:waitForPlayersAndStart()
    -- Wait for at least 2 players
    local function checkPlayers()
        local playerCount = #Players:GetPlayers()
        if playerCount >= 2 and not self.gameState.isActive then
            self:startGame()
        elseif playerCount < 2 and self.gameState.isActive then
            self:endGame("Not enough players")
        end
    end
    
    -- Check every 5 seconds
    while true do
        checkPlayers()
        task.wait(5)
    end
end

function TagChaseGameManager:startGame()
    print("Starting Progressive TAG/CHASE game!")
    
    self.gameState.isActive = true
    self.gameState.timeRemaining = GAME_DURATION
    self.gameState.startTime = tick()
    self.gameState.gameStartTime = tick()
    
    -- Reset all players to survivors first
    for userId, playerData in pairs(self.players) do
        if playerData.player.Parent == Players then
            RoleManager.setRole(playerData.player, "Survivor")
            playerData.role = "Survivor"
            playerData.survivalStartTime = tick()
            playerData.totalSurvivalTime = 0
            playerData.caughtTime = nil
        end
    end
    
    -- Select initial chaser
    self:selectInitialChaser()
    
    -- Start game loop
    self:startGameLoop()
    
    -- Start grace period
    self:startGracePeriod()
end

function TagChaseGameManager:selectInitialChaser()
    local survivors = {}
    
    -- Find all current survivors
    for userId, playerData in pairs(self.players) do
        if playerData.role == "Survivor" and playerData.player.Parent == Players then
            table.insert(survivors, playerData.player)
        end
    end
    
    if #survivors > 0 then
        -- Randomly select initial chaser
        local initialChaser = survivors[math.random(1, #survivors)]
        
        -- Convert to chaser
        RoleManager.setRole(initialChaser, "Chaser")
        self.players[initialChaser.UserId].role = "Chaser"
        self.players[initialChaser.UserId].survivalStartTime = 0 -- Chasers don't survive
        self.players[initialChaser.UserId].totalSurvivalTime = 0
        
        print("Initial chaser selected: " .. initialChaser.Name)
        
        -- Update scoreboard
        self:updateScoreboard(initialChaser, "become_initial_chaser")
        
        -- Update all players' UIs
        self:updateAllPlayerUIs()
        
        -- Respawn players at appropriate locations
        self:respawnAllPlayers()
    end
end

function TagChaseGameManager:startGracePeriod()
    self.gameState.gracePeriodActive = true
    
    -- Announce grace period
    UIManager.announceToAll("Game Starting! First chaser has " .. GRACE_PERIOD .. " seconds grace period!")
    
    task.spawn(function()
        for i = GRACE_PERIOD, 1, -1 do
            if not self.gameState.isActive then break end
            UIManager.announceToAll("Chase begins in: " .. i)
            task.wait(1)
        end
        
        self.gameState.gracePeriodActive = false
        UIManager.announceToAll("CHASE BEGINS! Survivors, RUN!")
    end)
end

function TagChaseGameManager:setupChaserCollision(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Create collision detector
    local collisionDetector = Instance.new("Part")
    collisionDetector.Name = "ChaserDetector"
    collisionDetector.Size = Vector3.new(4, 6, 4)
    collisionDetector.CanCollide = false
    collisionDetector.Transparency = 1
    collisionDetector.Parent = character
    
    -- Weld to humanoid root part
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = collisionDetector
    weld.Part1 = rootPart
    weld.Parent = collisionDetector
    
    -- Setup touch connection
    collisionDetector.Touched:Connect(function(hit)
        if self.gameState.gracePeriodActive then return end
        
        local otherPlayer = Players:GetPlayerFromCharacter(hit.Parent)
        if otherPlayer and otherPlayer ~= player then
            local otherRole = RoleManager.getRole(otherPlayer)
            if otherRole == "Survivor" then
                self:onSurvivorCaught(player, otherPlayer)
            end
        end
    end)
end

function TagChaseGameManager:onSurvivorCaught(chaser, survivor)
    print(chaser.Name .. " caught survivor " .. survivor.Name)
    
    -- Calculate survival time for the caught survivor
    local currentTime = tick()
    local survivalTime = currentTime - self.players[survivor.UserId].survivalStartTime
    self.players[survivor.UserId].totalSurvivalTime = survivalTime
    self.players[survivor.UserId].caughtTime = currentTime
    
    -- Update scoreboard
    self:updateScoreboard(chaser, "catch")
    self:updateScoreboard(survivor, "caught")
    
    -- Convert survivor to chaser (progressive chase!)
    RoleManager.setRole(survivor, "Chaser")
    self.players[survivor.UserId].role = "Chaser"
    self.players[survivor.UserId].survivalStartTime = 0 -- No longer surviving
    
    -- Visual and audio feedback
    UIManager.announceToAll(survivor.Name .. " a été attrapé! Il devient maintenant chasseur!")
    
    -- Respawn the new chaser
    self:respawnPlayer(survivor)
    
    -- Setup collision detection for the new chaser
    local character = survivor.Character
    if character then
        self:setupChaserCollision(survivor, character)
    end
    
    -- Update UIs
    self:updateAllPlayerUIs()
    
    -- Check if all survivors have been caught
    self:checkGameEndCondition()
end

function TagChaseGameManager:respawnPlayer(player)
    local character = player.Character
    if character then
        local role = RoleManager.getRole(player)
        SpawnManager.spawnPlayer(player, character, role)
    end
end

function TagChaseGameManager:respawnAllPlayers()
    for _, playerData in pairs(self.players) do
        if playerData.player.Parent == Players then
            self:respawnPlayer(playerData.player)
            
            -- Setup collision detection for all chasers
            if playerData.role == "Chaser" then
                local character = playerData.player.Character
                if character then
                    self:setupChaserCollision(playerData.player, character)
                end
            end
        end
    end
end

function TagChaseGameManager:startGameLoop()
    task.spawn(function()
        while self.gameState.isActive and self.gameState.timeRemaining > 0 do
            task.wait(1)
            self.gameState.timeRemaining = self.gameState.timeRemaining - 1
            self:updateAllPlayerUIs()
        end
        
        if self.gameState.isActive then
            self:endGame("Time's up!")
        end
    end)
end

function TagChaseGameManager:updateAllPlayerUIs()
    local survivorCount = self:getSurvivorCount()
    local chaserCount = self:getChaserCount()
    
    for _, playerData in pairs(self.players) do
        if playerData.player.Parent == Players then
            local role = RoleManager.getRole(playerData.player)
            UIManager.updatePlayerUI(playerData.player, role, self.gameState.timeRemaining, survivorCount, chaserCount)
        end
    end
end

function TagChaseGameManager:updateScoreboard(player, action)
    if not self.scoreboard[player.UserId] then
        self.scoreboard[player.UserId] = {
            playerName = player.Name,
            catches = 0,
            caught = 0,
            survivalTime = 0,
            finalRole = "Survivor"
        }
    end
    
    if action == "catch" then
        self.scoreboard[player.UserId].catches = self.scoreboard[player.UserId].catches + 1
    elseif action == "caught" then
        self.scoreboard[player.UserId].caught = self.scoreboard[player.UserId].caught + 1
        self.scoreboard[player.UserId].survivalTime = self.players[player.UserId].totalSurvivalTime
        self.scoreboard[player.UserId].finalRole = "Caught"
    elseif action == "become_initial_chaser" then
        self.scoreboard[player.UserId].finalRole = "Initial Chaser"
    end
end

function TagChaseGameManager:getSurvivorCount()
    local count = 0
    for _, playerData in pairs(self.players) do
        if playerData.role == "Survivor" and playerData.player.Parent == Players then
            count = count + 1
        end
    end
    return count
end

function TagChaseGameManager:getChaserCount()
    local count = 0
    for _, playerData in pairs(self.players) do
        if playerData.role == "Chaser" and playerData.player.Parent == Players then
            count = count + 1
        end
    end
    return count
end

function TagChaseGameManager:checkGameEndCondition()
    local survivorCount = self:getSurvivorCount()
    
    if survivorCount == 0 then
        -- All survivors have been caught!
        self:endGame("Tous les survivants ont été attrapés!")
    end
end

function TagChaseGameManager:endGame(reason)
    print("Game ending: " .. reason)
    
    self.gameState.isActive = false
    
    -- Calculate final survival times for remaining survivors
    local currentTime = tick()
    for userId, playerData in pairs(self.players) do
        if playerData.role == "Survivor" and playerData.player.Parent == Players then
            -- Calculate total survival time for survivors who made it to the end
            local totalSurvivalTime = currentTime - playerData.survivalStartTime
            if not self.scoreboard[userId] then
                self.scoreboard[userId] = {
                    playerName = playerData.player.Name,
                    catches = 0,
                    caught = 0,
                    survivalTime = 0,
                    finalRole = "Survivor"
                }
            end
            self.scoreboard[userId].survivalTime = totalSurvivalTime
            self.scoreboard[userId].finalRole = "Winner - Survived!"
        end
    end
    
    -- Show final scoreboard with survival times
    UIManager.showFinalScoreboard(self.scoreboard)
    
    -- Reset after 15 seconds
    task.wait(15)
    
    if #Players:GetPlayers() >= 2 then
        self:startGame()
    end
end

return TagChaseGameManager