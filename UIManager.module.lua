-- UIManager
-- Handles all UI elements and player communication

local UIManager = {}
UIManager.__index = UIManager

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- RemoteEvents for client-server communication
local remoteEvents = {}

function UIManager.initialize()
    print("Initializing UI Manager...")
    
    -- Create RemoteEvents
    UIManager.createRemoteEvents()
    
    -- Create UI templates
    UIManager.createUITemplates()
end

function UIManager.createRemoteEvents()
    local remoteEventsFolder = Instance.new("Folder")
    remoteEventsFolder.Name = "TagChaseRemoteEvents"
    remoteEventsFolder.Parent = ReplicatedStorage
    
    -- Create remote events
    remoteEvents.UpdateUI = Instance.new("RemoteEvent")
    remoteEvents.UpdateUI.Name = "UpdateUI"
    remoteEvents.UpdateUI.Parent = remoteEventsFolder
    
    remoteEvents.ShowAnnouncement = Instance.new("RemoteEvent")
    remoteEvents.ShowAnnouncement.Name = "ShowAnnouncement"
    remoteEvents.ShowAnnouncement.Parent = remoteEventsFolder
    
    remoteEvents.ShowScoreboard = Instance.new("RemoteEvent")
    remoteEvents.ShowScoreboard.Name = "ShowScoreboard"
    remoteEvents.ShowScoreboard.Parent = remoteEventsFolder
end

function UIManager.createUITemplates()
    -- Create UI templates in StarterGui
    local starterGui = game:GetService("StarterGui")
    
    -- Main Game UI
    UIManager.createMainGameUI()
    
    -- Announcement UI
    UIManager.createAnnouncementUI()
    
    -- Scoreboard UI
    UIManager.createScoreboardUI()
end

function UIManager.createMainGameUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TagChaseUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("StarterGui")
    
    -- Role Display
    local roleFrame = Instance.new("Frame")
    roleFrame.Name = "RoleFrame"
    roleFrame.Size = UDim2.new(0, 300, 0, 100)
    roleFrame.Position = UDim2.new(0.5, -150, 0, 10)
    roleFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    roleFrame.BackgroundTransparency = 0.3
    roleFrame.BorderSizePixel = 0
    roleFrame.Parent = screenGui
    
    -- Role Label
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Name = "RoleLabel"
    roleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    roleLabel.Position = UDim2.new(0, 0, 0, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = "YOU ARE RUNNING!"
    roleLabel.TextColor3 = Color3.new(1, 1, 1)
    roleLabel.TextScaled = true
    roleLabel.Font = Enum.Font.SourceSansBold
    roleLabel.Parent = roleFrame
    
    -- Timer Label
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
    timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Time: 5:00"
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.SourceSans
    timerLabel.Parent = roleFrame
    
    -- Current Chaser Display
    local chaserFrame = Instance.new("Frame")
    chaserFrame.Name = "ChaserFrame"
    chaserFrame.Size = UDim2.new(0, 250, 0, 80)
    chaserFrame.Position = UDim2.new(1, -260, 0, 10)
    chaserFrame.BackgroundColor3 = Color3.new(1, 0, 0)
    chaserFrame.BackgroundTransparency = 0.3
    chaserFrame.BorderSizePixel = 0
    chaserFrame.Parent = screenGui
    
    local chaserLabel = Instance.new("TextLabel")
    chaserLabel.Name = "ChaserLabel"
    chaserLabel.Size = UDim2.new(1, 0, 1, 0)
    chaserLabel.BackgroundTransparency = 1
    chaserLabel.Text = "CHASER: None"
    chaserLabel.TextColor3 = Color3.new(1, 1, 1)
    chaserLabel.TextScaled = true
    chaserLabel.Font = Enum.Font.SourceSansBold
    chaserLabel.Parent = chaserFrame
end

function UIManager.createAnnouncementUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AnnouncementUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("StarterGui")
    
    local announcementFrame = Instance.new("Frame")
    announcementFrame.Name = "AnnouncementFrame"
    announcementFrame.Size = UDim2.new(0, 400, 0, 100)
    announcementFrame.Position = UDim2.new(0.5, -200, 0.3, 0)
    announcementFrame.BackgroundColor3 = Color3.new(1, 1, 0)
    announcementFrame.BackgroundTransparency = 0.2
    announcementFrame.BorderSizePixel = 2
    announcementFrame.BorderColor3 = Color3.new(1, 0, 0)
    announcementFrame.Visible = false
    announcementFrame.Parent = screenGui
    
    local announcementLabel = Instance.new("TextLabel")
    announcementLabel.Name = "AnnouncementLabel"
    announcementLabel.Size = UDim2.new(1, 0, 1, 0)
    announcementLabel.BackgroundTransparency = 1
    announcementLabel.Text = ""
    announcementLabel.TextColor3 = Color3.new(0, 0, 0)
    announcementLabel.TextScaled = true
    announcementLabel.Font = Enum.Font.SourceSansBold
    announcementLabel.Parent = announcementFrame
end

function UIManager.createScoreboardUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScoreboardUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("StarterGui")
    
    local scoreboardFrame = Instance.new("Frame")
    scoreboardFrame.Name = "ScoreboardFrame"
    scoreboardFrame.Size = UDim2.new(0, 400, 0, 300)
    scoreboardFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    scoreboardFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scoreboardFrame.BackgroundTransparency = 0.3
    scoreboardFrame.BorderSizePixel = 2
    scoreboardFrame.BorderColor3 = Color3.new(1, 1, 1)
    scoreboardFrame.Visible = false
    scoreboardFrame.Parent = screenGui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 0
    titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    titleLabel.Text = "FINAL SCOREBOARD"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = scoreboardFrame
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Size = UDim2.new(1, -10, 1, -60)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 55)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 10
    scrollingFrame.Parent = scoreboardFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollingFrame
end

function UIManager.updatePlayerUI(player, role, timeRemaining)
    if not player or not player.Parent == Players then return end
    
    -- Fire remote event to update player's UI
    remoteEvents.UpdateUI:FireClient(player, {
        role = role,
        timeRemaining = timeRemaining,
        currentChaser = UIManager.getCurrentChaserName()
    })
end

function UIManager.getCurrentChaserName()
    -- This would be called from the game manager
    -- For now, return a placeholder
    return "None"
end

function UIManager.announceToAll(message)
    print("Announcement: " .. message)
    
    -- Show announcement to all players
    for _, player in ipairs(Players:GetPlayers()) do
        remoteEvents.ShowAnnouncement:FireClient(player, message)
    end
    
    -- Also show in chat
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[TAG CHASE] " .. message,
        Color = Color3.new(1, 1, 0),
        Font = Enum.Font.SourceSansBold
    })
end

function UIManager.showFinalScoreboard(scoreboard)
    -- Convert scoreboard to array for sorting
    local scoreboardArray = {}
    for userId, data in pairs(scoreboard) do
        table.insert(scoreboardArray, data)
    end
    
    -- Sort by tags (descending)
    table.sort(scoreboardArray, function(a, b)
        return a.tags > b.tags
    end)
    
    -- Send to all players
    for _, player in ipairs(Players:GetPlayers()) do
        remoteEvents.ShowScoreboard:FireClient(player, scoreboardArray)
    end
end

function UIManager.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%d:%02d", minutes, remainingSeconds)
end

function UIManager.getRoleColor(role)
    if role == "Chaser" then
        return Color3.new(1, 0, 0)
    else
        return Color3.new(0, 0.5, 1)
    end
end

return UIManager