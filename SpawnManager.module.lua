-- SpawnManager
-- Handles player spawning and spawn point management

local SpawnManager = {}
SpawnManager.__index = SpawnManager

-- Services
local Workspace = game:GetService("Workspace")
local DebrisService = game:GetService("Debris")

-- Spawn point storage
local spawnPoints = {
    Chaser = {},
    Survivor = {}
}

-- Spawn zone configuration
local SPAWN_ZONE_SIZE = Vector3.new(50, 20, 50)
local SPAWN_ZONE_DISTANCE = 100 -- Distance between zones

function SpawnManager.initialize()
    print("Initializing Spawn Manager...")
    
    -- Create spawn zones
    SpawnManager.createSpawnZones()
    
    -- Create spawn points
    SpawnManager.createSpawnPoints()
end

function SpawnManager.createSpawnZones()
    -- Create spawn zone folder
    local spawnZones = Instance.new("Folder")
    spawnZones.Name = "SpawnZones"
    spawnZones.Parent = Workspace
    
    -- Create Chaser spawn zone (red)
    local chaserZone = SpawnManager.createZone("ChaserZone", SPAWN_ZONE_SIZE, Vector3.new(0, 10, 0), BrickColor.new("Bright red"))
    chaserZone.Parent = spawnZones
    
    -- Create Survivor spawn zone (green)
    local survivorZone = SpawnManager.createZone("SurvivorZone", SPAWN_ZONE_SIZE, Vector3.new(0, 10, SPAWN_ZONE_DISTANCE), BrickColor.new("Bright green"))
    survivorZone.Parent = spawnZones
    
    -- Create ground for both zones
    SpawnManager.createGround("ChaserGround", Vector3.new(60, 1, 60), Vector3.new(0, 0, 0), BrickColor.new("Dark stone"))
    SpawnManager.createGround("SurvivorGround", Vector3.new(60, 1, 60), Vector3.new(0, 0, SPAWN_ZONE_DISTANCE), BrickColor.new("Dark stone"))
    
    -- Create barriers between zones (initially)
    SpawnManager.createBarriers()
end

function SpawnManager.createZone(name, size, position, color)
    local zone = Instance.new("Part")
    zone.Name = name
    zone.Size = size
    zone.Position = position
    zone.BrickColor = color
    zone.Material = Enum.Material.Neon
    zone.Transparency = 0.8
    zone.Anchored = true
    zone.CanCollide = false
    zone.TopSurface = Enum.SurfaceType.Smooth
    zone.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Add zone label
    local label = Instance.new("BillboardGui")
    label.Name = "ZoneLabel"
    label.Size = UDim2.new(0, 100, 0, 50)
    label.StudsOffset = Vector3.new(0, 5, 0)
    label.Parent = zone
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name:gsub("Zone", "") .. " SPAWN"
    textLabel.TextColor3 = color.Color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = label
    
    return zone
end

function SpawnManager.createGround(name, size, position, color)
    local ground = Instance.new("Part")
    ground.Name = name
    ground.Size = size
    ground.Position = position
    ground.BrickColor = color
    ground.Material = Enum.Material.Concrete
    ground.Anchored = true
    ground.CanCollide = true
    ground.TopSurface = Enum.SurfaceType.Smooth
    ground.BottomSurface = Enum.SurfaceType.Smooth
    ground.Parent = Workspace
    
    return ground
end

function SpawnManager.createBarriers()
    -- Create temporary barriers that will be removed after grace period
    local barriers = Instance.new("Folder")
    barriers.Name = "Barriers"
    barriers.Parent = Workspace
    
    -- Create walls between zones
    for x = -25, 25, 10 do
        for y = 0, 20, 5 do
            local barrier = Instance.new("Part")
            barrier.Name = "Barrier"
            barrier.Size = Vector3.new(2, 5, 2)
            barrier.Position = Vector3.new(x, y, SPAWN_ZONE_DISTANCE / 2)
            barrier.BrickColor = BrickColor.new("Bright yellow")
            barrier.Material = Enum.Material.Neon
            barrier.Transparency = 0.3
            barrier.Anchored = true
            barrier.CanCollide = true
            barrier.Parent = barriers
            
            -- Remove barriers after grace period
            DebrisService:AddItem(barrier, 10)
        end
    end
end

function SpawnManager.createSpawnPoints()
    -- Clear existing spawn points
    spawnPoints.Chaser = {}
    spawnPoints.Survivor = {}
    
    -- Create Chaser spawn points (in a circle)
    local chaserCenter = Vector3.new(0, 5, 0)
    local chaserRadius = 15
    
    for i = 1, 8 do
        local angle = (i - 1) * (2 * math.pi / 8)
        local x = chaserCenter.X + chaserRadius * math.cos(angle)
        local z = chaserCenter.Z + chaserRadius * math.sin(angle)
        
        local spawnPoint = SpawnManager.createSpawnPoint("ChaserSpawn" .. i, Vector3.new(x, chaserCenter.Y, z))
        table.insert(spawnPoints.Chaser, spawnPoint)
    end
    
    -- Create Survivor spawn points (in a grid)
    local survivorCenter = Vector3.new(0, 5, SPAWN_ZONE_DISTANCE)
    local survivorSpacing = 8
    
    for x = -15, 15, survivorSpacing do
        for z = -15, 15, survivorSpacing do
            local spawnPoint = SpawnManager.createSpawnPoint("SurvivorSpawn" .. #spawnPoints.Survivor + 1, 
                Vector3.new(survivorCenter.X + x, survivorCenter.Y, survivorCenter.Z + z))
            table.insert(spawnPoints.Survivor, spawnPoint)
        end
    end
end

function SpawnManager.createSpawnPoint(name, position)
    local spawnPoint = Instance.new("SpawnLocation")
    spawnPoint.Name = name
    spawnPoint.Position = position
    spawnPoint.Size = Vector3.new(4, 1, 4)
    spawnPoint.BrickColor = BrickColor.new("Really black")
    spawnPoint.Material = Enum.Material.Neon
    spawnPoint.Anchored = true
    spawnPoint.CanCollide = false
    spawnPoint.Duration = 0
    spawnPoint.TeamColor = BrickColor.new("Really black")
    spawnPoint.Parent = Workspace
    
    -- Add spawn point indicator
    local indicator = Instance.new("CylinderMesh")
    indicator.Scale = Vector3.new(0.5, 0.1, 0.5)
    indicator.Parent = spawnPoint
    
    return spawnPoint
end

function SpawnManager.spawnPlayer(player, character, role)
    if not player or not character or not role then return end
    
    -- Get appropriate spawn points
    local roleSpawnPoints = spawnPoints[role]
    if #roleSpawnPoints == 0 then
        warn("No spawn points available for role: " .. role)
        return
    end
    
    -- Select random spawn point
    local spawnPoint = roleSpawnPoints[math.random(1, #roleSpawnPoints)]
    
    -- Get character's HumanoidRootPart
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("Character missing HumanoidRootPart")
        return
    end
    
    -- Teleport character to spawn point
    rootPart.CFrame = CFrame.new(spawnPoint.Position + Vector3.new(0, 3, 0))
    
    -- Reset character health and state
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
        humanoid:TakeDamage(0) -- Reset any damage states
    end
    
    print("Spawned " .. player.Name .. " at " .. role .. " spawn point")
end

function SpawnManager.getSpawnPoints(role)
    return spawnPoints[role] or {}
end

function SpawnManager.removeBarriers()
    local barriers = Workspace:FindFirstChild("Barriers")
    if barriers then
        barriers:Destroy()
        print("Barriers removed - game can begin!")
    end
end

return SpawnManager