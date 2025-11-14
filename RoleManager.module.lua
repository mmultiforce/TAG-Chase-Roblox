-- RoleManager
-- Handles player role assignment and management

local RoleManager = {}
RoleManager.__index = RoleManager

-- Services
local Players = game:GetService("Players")

-- Player role storage
local playerRoles = {}

-- Role colors for visual identification
local ROLE_COLORS = {
    Chaser = BrickColor.new("Bright red"),
    Runner = BrickColor.new("Bright blue")
}

function RoleManager.setRole(player, role)
    if not player or not role then return end
    
    -- Validate role
    if role ~= "Chaser" and role ~= "Runner" then
        warn("Invalid role: " .. tostring(role))
        return
    end
    
    -- Store role
    playerRoles[player.UserId] = role
    
    -- Apply visual changes to character
    local character = player.Character
    if character then
        RoleManager.applyRoleVisuals(character, role)
    end
    
    print("Set " .. player.Name .. " role to: " .. role)
end

function RoleManager.getRole(player)
    if not player then return "Runner" end
    
    return playerRoles[player.UserId] or "Runner"
end

function RoleManager.applyRoleVisuals(character, role)
    -- Wait for character components
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Remove existing role visuals
    local existingIndicator = character:FindFirstChild("RoleIndicator")
    if existingIndicator then
        existingIndicator:Destroy()
    end
    
    -- Create role indicator (colored part on head)
    local head = character:FindFirstChild("Head")
    if head then
        local indicator = Instance.new("Part")
        indicator.Name = "RoleIndicator"
        indicator.Size = Vector3.new(1.1, 0.3, 1.1)
        indicator.BrickColor = ROLE_COLORS[role]
        indicator.Material = Enum.Material.Neon
        indicator.CanCollide = false
        indicator.Anchored = false
        indicator.TopSurface = Enum.SurfaceType.Smooth
        indicator.BottomSurface = Enum.SurfaceType.Smooth
        
        -- Weld to head
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = indicator
        weld.Part1 = head
        weld.Parent = indicator
        
        indicator.Parent = character
    end
    
    -- Apply body colors if available
    local bodyColors = character:FindFirstChild("Body Colors")
    if bodyColors then
        if role == "Chaser" then
            bodyColors.TorsoColor = ROLE_COLORS.Chaser
            bodyColors.LeftArmColor = ROLE_COLORS.Chaser
            bodyColors.RightArmColor = ROLE_COLORS.Chaser
            bodyColors.LeftLegColor = ROLE_COLORS.Chaser
            bodyColors.RightLegColor = ROLE_COLORS.Chaser
        else
            bodyColors.TorsoColor = ROLE_COLORS.Runner
            bodyColors.LeftArmColor = ROLE_COLORS.Runner
            bodyColors.RightArmColor = ROLE_COLORS.Runner
            bodyColors.LeftLegColor = ROLE_COLORS.Runner
            bodyColors.RightLegColor = ROLE_COLORS.Runner
        end
    end
    
    -- Create role glow effect
    local glow = Instance.new("PointLight")
    glow.Name = "RoleGlow"
    glow.Color = ROLE_COLORS[role].Color
    glow.Range = 10
    glow.Brightness = 0.5
    glow.Parent = rootPart
end

function RoleManager.getAllChasers()
    local chasers = {}
    
    for userId, role in pairs(playerRoles) do
        if role == "Chaser" then
            local player = Players:GetPlayerByUserId(userId)
            if player and player.Parent == Players then
                table.insert(chasers, player)
            end
        end
    end
    
    return chasers
end

function RoleManager.getAllRunners()
    local runners = {}
    
    for userId, role in pairs(playerRoles) do
        if role == "Runner" then
            local player = Players:GetPlayerByUserId(userId)
            if player and player.Parent == Players then
                table.insert(runners, player)
            end
        end
    end
    
    return runners
end

function RoleManager.resetAllRoles()
    playerRoles = {}
    
    -- Set all players to runners initially
    for _, player in ipairs(Players:GetPlayers()) do
        RoleManager.setRole(player, "Runner")
    end
end

function RoleManager.onCharacterAdded(player, character)
    -- Apply role visuals when character loads
    local role = RoleManager.getRole(player)
    RoleManager.applyRoleVisuals(character, role)
end

return RoleManager