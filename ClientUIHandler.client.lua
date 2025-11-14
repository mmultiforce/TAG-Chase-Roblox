-- ClientUIHandler
-- LocalScript for handling UI updates on the client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get remote events
local remoteEvents = ReplicatedStorage:WaitForChild("TagChaseRemoteEvents")
local updateUIEvent = remoteEvents:WaitForChild("UpdateUI")
local announcementEvent = remoteEvents:WaitForChild("ShowAnnouncement")
local scoreboardEvent = remoteEvents:WaitForChild("ShowScoreboard")

-- UI references
local tagChaseUI = nil
local announcementUI = nil
local scoreboardUI = nil

-- Initialize UI
local function initializeUI()
    -- Wait for UI to be created
    tagChaseUI = playerGui:WaitForChild("TagChaseUI", 10)
    announcementUI = playerGui:WaitForChild("AnnouncementUI", 10)
    scoreboardUI = playerGui:WaitForChild("ScoreboardUI", 10)
    
    if tagChaseUI then
        print("Tag Chase UI loaded successfully")
    else
        warn("Failed to load Tag Chase UI")
    end
end

-- Update main game UI
local function updateUI(data)
    if not tagChaseUI then return end
    
    local roleLabel = tagChaseUI:FindFirstChild("RoleFrame"):FindFirstChild("RoleLabel")
    local timerLabel = tagChaseUI:FindFirstChild("RoleFrame"):FindFirstChild("TimerLabel")
    local chaserLabel = tagChaseUI:FindFirstChild("ChaserFrame"):FindFirstChild("ChaserLabel")
    local statsLabel = tagChaseUI:FindFirstChild("RoleFrame"):FindFirstChild("StatsLabel")
    
    if roleLabel then
        if data.role == "Chaser" then
            roleLabel.Text = "TU ES LE CHASSEUR!"
            roleLabel.TextColor3 = Color3.new(1, 0, 0)
            tagChaseUI.RoleFrame.BackgroundColor3 = Color3.new(1, 0, 0)
            tagChaseUI.RoleFrame.BackgroundTransparency = 0.3
        else
            roleLabel.Text = "TU SURVIS!"
            roleLabel.TextColor3 = Color3.new(0, 1, 0)
            tagChaseUI.RoleFrame.BackgroundColor3 = Color3.new(0, 0.5, 0)
            tagChaseUI.RoleFrame.BackgroundTransparency = 0.3
        end
    end
    
    if timerLabel then
        local minutes = math.floor(data.timeRemaining / 60)
        local seconds = data.timeRemaining % 60
        timerLabel.Text = string.format("Temps: %d:%02d", minutes, seconds)
        
        -- Change color based on time remaining
        if data.timeRemaining <= 30 then
            timerLabel.TextColor3 = Color3.new(1, 0, 0)
        elseif data.timeRemaining <= 60 then
            timerLabel.TextColor3 = Color3.new(1, 1, 0)
        else
            timerLabel.TextColor3 = Color3.new(1, 1, 1)
        end
    end
    
    if chaserLabel then
        local chaserText = "CHASSEURS: "
        if data.currentChasers and #data.currentChasers > 0 then
            chaserText = chaserText .. table.concat(data.currentChasers, ", ")
        else
            chaserText = chaserText .. "Aucun"
        end
        chaserLabel.Text = chaserText
    end
    
    -- Update stats label if it exists
    if statsLabel then
        statsLabel.Text = string.format("Survivants: %d | Chasseurs: %d", data.survivorCount or 0, data.chaserCount or 0)
    end
end

-- Show announcement
local function showAnnouncement(message)
    if not announcementUI then return end
    
    local announcementFrame = announcementUI:FindFirstChild("AnnouncementFrame")
    local announcementLabel = announcementFrame:FindFirstChild("AnnouncementLabel")
    
    if announcementFrame and announcementLabel then
        announcementLabel.Text = message
        announcementFrame.Visible = true
        
        -- Play sound effect
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxasset://sounds/uuhhh.mp3"
        sound.Volume = 0.5
        sound.Parent = workspace
        sound:Play()
        
        -- Hide after 3 seconds
        game:GetService("Debris"):AddItem(sound, 3)
        
        task.wait(3)
        if announcementFrame then
            announcementFrame.Visible = false
        end
    end
end

-- Show final scoreboard
local function showScoreboard(scoreboardData)
    if not scoreboardUI then return end
    
    local scoreboardFrame = scoreboardUI:FindFirstChild("ScoreboardFrame")
    local scrollingFrame = scoreboardFrame:FindFirstChild("ScrollingFrame")
    
    if scoreboardFrame and scrollingFrame then
        -- Clear existing entries
        for _, child in pairs(scrollingFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Create scoreboard entries
        for i, playerData in ipairs(scoreboardData) do
            local entryFrame = Instance.new("Frame")
            entryFrame.Name = "Entry" .. i
            entryFrame.Size = UDim2.new(1, -10, 0, 40)
            entryFrame.Position = UDim2.new(0, 5, 0, (i - 1) * 42)
            entryFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            entryFrame.BorderSizePixel = 1
            entryFrame.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
            entryFrame.LayoutOrder = i
            entryFrame.Parent = scrollingFrame
            
            -- Rank label
            local rankLabel = Instance.new("TextLabel")
            rankLabel.Name = "RankLabel"
            rankLabel.Size = UDim2.new(0, 50, 1, 0)
            rankLabel.Position = UDim2.new(0, 0, 0, 0)
            rankLabel.BackgroundTransparency = 1
            rankLabel.Text = "#" .. i
            rankLabel.TextColor3 = Color3.new(1, 1, 0)
            rankLabel.TextScaled = true
            rankLabel.Font = Enum.Font.SourceSansBold
            rankLabel.Parent = entryFrame
            
            -- Name label
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(0, 120, 1, 0)
            nameLabel.Position = UDim2.new(0, 50, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = playerData.playerName
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = entryFrame
            
            -- Role label
            local roleLabel = Instance.new("TextLabel")
            roleLabel.Name = "RoleLabel"
            roleLabel.Size = UDim2.new(0, 100, 1, 0)
            roleLabel.Position = UDim2.new(0, 170, 0, 0)
            roleLabel.BackgroundTransparency = 1
            roleLabel.Text = playerData.finalRole or "Survivor"
            roleLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            roleLabel.TextScaled = true
            roleLabel.Font = Enum.Font.SourceSans
            roleLabel.TextXAlignment = Enum.TextXAlignment.Left
            roleLabel.Parent = entryFrame
            
            -- Survival time label
            local survivalLabel = Instance.new("TextLabel")
            survivalLabel.Name = "SurvivalLabel"
            survivalLabel.Size = UDim2.new(0, 80, 1, 0)
            survivalLabel.Position = UDim2.new(0, 270, 0, 0)
            survivalLabel.BackgroundTransparency = 1
            local minutes = math.floor(playerData.survivalTime / 60)
            local seconds = math.floor(playerData.survivalTime % 60)
            survivalLabel.Text = string.format("%d:%02d", minutes, seconds)
            survivalLabel.TextColor3 = Color3.new(1, 1, 0)
            survivalLabel.TextScaled = true
            survivalLabel.Font = Enum.Font.SourceSans
            survivalLabel.TextXAlignment = Enum.TextXAlignment.Left
            survivalLabel.Parent = entryFrame
        end
        
        -- Update scrolling frame size
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #scoreboardData * 42)
        
        -- Show scoreboard
        scoreboardFrame.Visible = true
        
        -- Hide after 10 seconds
        task.wait(10)
        if scoreboardFrame then
            scoreboardFrame.Visible = false
        end
    end
end

-- Connect remote events
updateUIEvent.OnClientEvent:Connect(updateUI)
announcementEvent.OnClientEvent:Connect(showAnnouncement)
scoreboardEvent.OnClientEvent:Connect(showScoreboard)

-- Initialize UI when player joins
initializeUI()

print("Client UI Handler initialized for " .. player.Name)