-- TagChaseGameManager
-- Main game controller for TAG/CHASE game mechanics

local TagChaseGameManager = {}
TagChaseGameManager.__index = TagChaseGameManager

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local DebrisService = game:GetService("Debris")

-- Dependencies
local RoleManager = require(script.Parent.RoleManager)
local SpawnManager = require(script.Parent.SpawnManager)
local UIManager = require(script.Parent.UIManager)

-- Game Configuration
local GAME_DURATION = 300 -- 5 minutes in seconds
local GRACE_PERIOD = 5 -- 5 seconds grace period for chaser

function TagChaseGameManager.new()
    local self = setmetatable({}, TagChaseGameManager)
    
    self.gameState = {
        isActive = false,
        timeRemaining = GAME_DURATION,
        currentChaser = nil,
        startTime = 0,
        gracePeriodActive = false
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
        role = "Runner",
        roleChanges = 0
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
    
    -- Setup collision detection
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
    print("Starting TAG/CHASE game!")
    
    self.gameState.isActive = true
    self.gameState.timeRemaining = GAME_DURATION
    self.gameState.startTime = tick()
    
    -- Select initial chaser
    self:selectNewChaser()
    
    -- Start game loop
    self:startGameLoop()
    
    -- Start grace period
    self:startGracePeriod()
end

function TagChaseGameManager:selectNewChaser()
    local runners = {}
    
    -- Find all current runners
    for userId, playerData in pairs(self.players) do
        if playerData.role == "Runner" and playerData.player.Parent == Players then
            table.insert(runners, playerData.player)
        end
    end
    
    if #runners > 0 then
        -- Randomly select new chaser
        local newChaser = runners[math.random(1, #runners)]
        
        -- Update roles
        if self.gameState.currentChaser then
            RoleManager.setRole(self.gameState.currentChaser, "Runner")
        end
        
        RoleManager.setRole(newChaser, "Chaser")
        self.gameState.currentChaser = newChaser
        
        print("New chaser selected: " .. newChaser.Name)
        
        -- Update scoreboard
        self:updateScoreboard(newChaser, "became_chaser")
        
        -- Update all players' UIs
        self:updateAllPlayerUIs()
        
        -- Respawn players at appropriate locations
        self:respawnAllPlayers()
    end
end

function TagChaseGameManager:startGracePeriod()
    self.gameState.gracePeriodActive = true
    
    -- Announce grace period
    UIManager.announceToAll("Game Starting! Chaser has " .. GRACE_PERIOD .. " seconds grace period!")
    
    task.spawn(function()
        for i = GRACE_PERIOD, 1, -1 do
            if not self.gameState.isActive then break end
            UIManager.announceToAll("Chaser can move in: " .. i)
            task.wait(1)
        end
        
        self.gameState.gracePeriodActive = false
        UIManager.announceToAll("CHASE BEGINS!")
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
            if otherRole == "Runner" then
                self:onChaserCaughtRunner(player, otherPlayer)
            end
        end
    end)
end

function TagChaseGameManager:onChaserCaughtRunner(chaser, runner)
    print(chaser.Name .. " caught " .. runner.Name)
    
    -- Update scoreboard
    self:updateScoreboard(chaser, "tag")
    self:updateScoreboard(runner, "tagged")
    
    -- Switch roles
    RoleManager.setRole(chaser, "Runner")
    RoleManager.setRole(runner, "Chaser")
    self.gameState.currentChaser = runner
    
    -- Visual and audio feedback
    UIManager.announceToAll(runner.Name .. " is now the CHASER!")
    
    -- Respawn both players
    self:respawnPlayer(chaser)
    self:respawnPlayer(runner)
    
    -- Update UIs
    self:updateAllPlayerUIs()
end

function TagChaseGameManager:respawnPlayer(player)
    local character = player.Character
    if character then
        local role = RoleManager.getRole(player)
        SpawnManager.spawnPlayer(player, character, role)
        
        -- Reset collision if new chaser
        if role == "Chaser" then
            self:setupChaserCollision(player, character)
        end
    end
end

function TagChaseGameManager:respawnAllPlayers()
    for _, playerData in pairs(self.players) do
        if playerData.player.Parent == Players then
            self:respawnPlayer(playerData.player)
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
    for _, playerData in pairs(self.players) do
        if playerData.player.Parent == Players then
            local role = RoleManager.getRole(playerData.player)
            UIManager.updatePlayerUI(playerData.player, role, self.gameState.timeRemaining)
        end
    end
end

function TagChaseGameManager:updateScoreboard(player, action)
    if not self.scoreboard[player.UserId] then
        self.scoreboard[player.UserId] = {
            playerName = player.Name,
            tags = 0,
            tagged = 0,
            timeAsChaser = 0
        }
    end
    
    if action == "tag" then
        self.scoreboard[player.UserId].tags = self.scoreboard[player.UserId].tags + 1
    elseif action == "tagged" then
        self.scoreboard[player.UserId].tagged = self.scoreboard[player.UserId].tagged + 1
    elseif action == "became_chaser" then
        self.players[player.UserId].roleChanges = self.players[player.UserId].roleChanges + 1
    end
end

function TagChaseGameManager:endGame(reason)
    print("Game ending: " .. reason)
    
    self.gameState.isActive = false
    
    -- Show final scoreboard
    UIManager.showFinalScoreboard(self.scoreboard)
    
    -- Reset after 10 seconds
    task.wait(10)
    
    if #Players:GetPlayers() >= 2 then
        self:startGame()
    end
end

return TagChaseGameManager