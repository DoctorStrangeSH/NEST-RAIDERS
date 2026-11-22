local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local WorldBuilder = {}

local function part(parent, name, size, position, color, material, shape)
    local instance = Instance.new("Part")
    instance.Name = name
    instance.Size = size
    instance.Position = position
    instance.Anchored = true
    instance.Color = color
    instance.Material = material or Enum.Material.SmoothPlastic
    instance.TopSurface = Enum.SurfaceType.Smooth
    instance.BottomSurface = Enum.SurfaceType.Smooth
    if shape then instance.Shape = shape end
    instance.Parent = parent
    return instance
end

local function makeTree(parent, position, scale)
    part(parent, "TreeTrunk", Vector3.new(2, 9, 2) * scale, position + Vector3.new(0, 4.5, 0), Color3.fromRGB(112, 76, 48), Enum.Material.Wood)
    part(parent, "TreeCrown", Vector3.new(9, 9, 9) * scale, position + Vector3.new(0, 10, 0), Color3.fromRGB(83, 177, 105), Enum.Material.Grass, Enum.PartType.Ball)
    local accent = part(parent, "TreeCrownAccent", Vector3.new(5, 5, 5) * scale, position + Vector3.new(2, 12, 0), Color3.fromRGB(118, 207, 121), Enum.Material.Grass, Enum.PartType.Ball)
    accent.CanCollide = false
end

local function makeEgg(parent, position, color)
    local egg = part(parent, "MeadowEgg", Vector3.new(3.2, 4.2, 3.2), position, color, Enum.Material.Neon, Enum.PartType.Ball)
    egg:SetAttribute("WorldEgg", true)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "CollectEggPrompt"
    prompt.ActionText = "Collect"
    prompt.ObjectText = "Meadow Egg"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.35
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = egg
end

function WorldBuilder:Build()
    local existing = Workspace:FindFirstChild("NestRaidersWorld")
    if existing then existing:Destroy() end

    local world = Instance.new("Folder")
    world.Name = "NestRaidersWorld"
    world.Parent = Workspace

    Lighting.ClockTime = 14
    Lighting.Brightness = 2.2
    Lighting.EnvironmentDiffuseScale = 0.45
    Lighting.EnvironmentSpecularScale = 0.35
    Lighting.Ambient = Color3.fromRGB(145, 164, 180)
    Lighting.OutdoorAmbient = Color3.fromRGB(170, 190, 205)

    local island = Instance.new("Folder")
    island.Name = "StarterIsland"
    island.Parent = world

    part(island, "FloatingRockFoundation", Vector3.new(330, 46, 330), Vector3.new(0, -19, 0), Color3.fromRGB(111, 91, 75), Enum.Material.Slate, Enum.PartType.Ball)
    local grassTop = part(island, "GrassTop", Vector3.new(12, 300, 300), Vector3.new(0, 4, 0), Color3.fromRGB(103, 190, 112), Enum.Material.Grass, Enum.PartType.Cylinder)
    grassTop.CFrame = CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, math.rad(90))
    part(island, "CentralClearing", Vector3.new(104, 1, 82), Vector3.new(0, 10.2, 8), Color3.fromRGB(145, 205, 128), Enum.Material.Grass)

    for index = 1, 7 do
        part(island, "PathStone", Vector3.new(13, 0.7, 8), Vector3.new(0, 10.8, -66 + index * 13), Color3.fromRGB(218, 194, 147), Enum.Material.Sand)
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "StarterSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(0, 11, -112)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Duration = 0
    spawn.Color = Color3.fromRGB(255, 220, 112)
    spawn.Material = Enum.Material.Neon
    spawn.Parent = island

    local treePositions = {
        Vector3.new(-105, 11, -88), Vector3.new(-125, 11, -25), Vector3.new(-108, 11, 70),
        Vector3.new(110, 11, -88), Vector3.new(126, 11, -22), Vector3.new(105, 11, 75),
        Vector3.new(-60, 11, 115), Vector3.new(58, 11, 116), Vector3.new(-145, 11, 48),
        Vector3.new(145, 11, 44), Vector3.new(-145, 11, -100), Vector3.new(145, 11, -105),
    }
    for index, position in ipairs(treePositions) do
        makeTree(island, position, index % 3 == 0 and 1.15 or 1)
    end

    local distant = Instance.new("Folder")
    distant.Name = "DistantBiomeSilhouettes"
    distant.Parent = world
    local silhouettes = {
        {Vector3.new(0, -2, 275), Vector3.new(170, 26, 150), Color3.fromRGB(107, 160, 126)},
        {Vector3.new(285, -5, 40), Vector3.new(155, 35, 180), Color3.fromRGB(146, 178, 207)},
        {Vector3.new(-290, -5, 20), Vector3.new(180, 42, 175), Color3.fromRGB(186, 128, 93)},
    }
    for index, entry in ipairs(silhouettes) do
        local land = part(distant, "DistantIsland_" .. index, entry[2], entry[1], entry[3], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        land.CanCollide = false
        land.Transparency = 0.08
    end

    local eggFolder = Instance.new("Folder")
    eggFolder.Name = "EggSpawnPoints"
    eggFolder.Parent = island
    makeEgg(eggFolder, Vector3.new(-24, 14, 20), Color3.fromRGB(255, 222, 113))
    makeEgg(eggFolder, Vector3.new(25, 14, 24), Color3.fromRGB(255, 222, 113))
    makeEgg(eggFolder, Vector3.new(0, 14, 65), Color3.fromRGB(255, 222, 113))

    local nest = Instance.new("Folder")
    nest.Name = "StarterNest"
    nest.Parent = island
    part(nest, "NestPlatform", Vector3.new(34, 2, 28), Vector3.new(0, 12, -28), Color3.fromRGB(117, 81, 55), Enum.Material.WoodPlanks)
    part(nest, "NestBowl", Vector3.new(18, 3, 16), Vector3.new(0, 14, -28), Color3.fromRGB(157, 112, 67), Enum.Material.Wood)
    local station = part(nest, "HatchStation", Vector3.new(7, 5, 7), Vector3.new(0, 16, -28), Color3.fromRGB(255, 194, 83), Enum.Material.Neon, Enum.PartType.Ball)
    station.Transparency = 0.2
    local hatchPrompt = Instance.new("ProximityPrompt")
    hatchPrompt.Name = "HatchPrompt"
    hatchPrompt.ActionText = "Hatch Egg"
    hatchPrompt.ObjectText = "Your Nest"
    hatchPrompt.KeyboardKeyCode = Enum.KeyCode.E
    hatchPrompt.HoldDuration = 0.5
    hatchPrompt.MaxActivationDistance = 12
    hatchPrompt.RequiresLineOfSight = false
    hatchPrompt.Parent = station

    local sign = part(island, "WelcomeSign", Vector3.new(1, 10, 18), Vector3.new(0, 16, -91), Color3.fromRGB(105, 72, 47), Enum.Material.Wood)
    local surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Front
    surface.Parent = sign
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "NEST RAIDERS\nSTARTER ISLAND"
    label.TextColor3 = Color3.fromRGB(255, 245, 210)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.Parent = surface

    return world
end

return WorldBuilder
