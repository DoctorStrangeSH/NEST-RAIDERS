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
    prompt.ActionText = "Собрать"
    prompt.ObjectText = "Яйцо луга"
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

    -- Personal nests are created and assigned by PlotService.
    -- Wayfinding path starts at the spawn and reaches the central egg grove.
    -- All pieces are decorative: egg prompts remain on the original collectible parts.
    local wayfinding = Instance.new("Folder")
    wayfinding.Name = "EggGroveWayfinding"
    wayfinding.Parent = island

    for index = 0, 13 do
        local z = -102 + index * 11
        local slab = part(wayfinding, "MosaicPath_" .. index,
            Vector3.new(index % 3 == 0 and 11 or 9, 0.25, 7.5),
            Vector3.new(0, 10.8, z),
            index % 2 == 0 and Color3.fromRGB(218, 193, 149) or Color3.fromRGB(235, 215, 170),
            Enum.Material.Sandstone)
        slab.CanCollide = false
    end

    -- Keep the central area open for players; visually frame the egg garden
    -- without blocking the three existing collectible egg parts.
    for _, grove in ipairs({
        {x = -24, z = 20}, {x = 25, z = 24}, {x = 0, z = 65},
    }) do
        local zone = Instance.new("Model")
        zone.Name = "EggGarden_" .. tostring(grove.x) .. "_" .. tostring(grove.z)
        zone.Parent = wayfinding
        local ring = part(zone, "GardenBase",
            Vector3.new(0.5, 12, 12), Vector3.new(grove.x, 10.4, grove.z),
            Color3.fromRGB(148, 177, 133), Enum.Material.Slate, Enum.PartType.Cylinder)
        ring.CFrame = CFrame.new(grove.x, 10.4, grove.z) * CFrame.Angles(0, 0, math.rad(90))
        ring.CanCollide = false
        -- Tall ambient glow allows players to recognize egg sites from afar.
        local beam = part(zone, "EggBeacon",
            Vector3.new(1.25, 9, 1.25), Vector3.new(grove.x + 4.5, 19.2, grove.z + 4.5),
            Color3.fromRGB(255, 222, 155), Enum.Material.Neon, Enum.PartType.Cylinder)
        beam.CanCollide = false
        beam.CanTouch = false
        beam.CanQuery = false
        beam.Transparency = 0.55
        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromRGB(255, 217, 147)
        glow.Range = 20
        glow.Brightness = 0.8
        glow.Parent = beam
        for index = 1, 6 do
            local angle = index * math.pi / 3
            local x = grove.x + math.cos(angle) * 7.2
            local z = grove.z + math.sin(angle) * 7.2
            local stone = part(zone, "GardenStone_" .. index,
                Vector3.new(2.2, 1.2, 2.2), Vector3.new(x, 11.2, z),
                Color3.fromRGB(192, 178, 150), Enum.Material.Slate, Enum.PartType.Ball)
            stone.CanCollide = false
        end
    end

    local function makeWayfindingSign(name, position, titleText, color)
        local board = part(wayfinding, name,
            Vector3.new(14, 6, 0.7), position, Color3.fromRGB(101, 75, 58),
            Enum.Material.WoodPlanks)
        board.CanCollide = false
        local gui = Instance.new("SurfaceGui")
        gui.Name = "WayfindingText"
        gui.Face = Enum.NormalId.Front
        gui.LightInfluence = 0
        gui.CanvasSize = Vector2.new(700, 300)
        gui.Parent = board
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = titleText
        label.TextColor3 = color
        label.TextScaled = true
        label.TextWrapped = true
        label.Font = Enum.Font.GothamBlack
        label.Parent = gui
    end
    makeWayfindingSign("EggGroveSign", Vector3.new(-18, 14, -39),
        "ЛУГ ЯИЦ\nСобери своё первое яйцо", Color3.fromRGB(255, 226, 164))
    makeWayfindingSign("NestDistrictSign", Vector3.new(27, 14, -39),
        "ЛИЧНЫЕ ГНЁЗДА\nВылупи питомца у себя", Color3.fromRGB(192, 245, 207))

    local sign = part(island, "WelcomeSign", Vector3.new(18, 10, 1), Vector3.new(0, 16, -91), Color3.fromRGB(105, 72, 47), Enum.Material.Wood)
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

    -- Decorative landing experience: readable paths, flower gardens and egg pedestals.
    -- These details are intentionally non-interactive and do not replace gameplay services.
    local gardens = Instance.new("Folder")
    gardens.Name = "WelcomeGardens"
    gardens.Parent = island
    local flowerColors = {
        Color3.fromRGB(255, 185, 209),
        Color3.fromRGB(255, 234, 153),
        Color3.fromRGB(200, 171, 255),
        Color3.fromRGB(245, 250, 255),
    }
    for index = 1, 64 do
        local side = index % 2 == 0 and -1 or 1
        local lane = math.floor((index - 1) / 2)
        local z = -94 + (lane % 32) * 6
        local x = side * (16 + (lane % 3) * 4)
        local y = 10.95
        local stem = part(gardens, "FlowerStem", Vector3.new(0.35, 1.2, 0.35),
            Vector3.new(x, y + 0.5, z), Color3.fromRGB(70, 153, 80), Enum.Material.Grass)
        stem.CanCollide = false
        local bloom = part(gardens, "FlowerBloom", Vector3.new(1.5, 1.5, 1.5),
            Vector3.new(x, y + 1.3, z), flowerColors[(lane % #flowerColors) + 1],
            Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        bloom.CanCollide = false
    end

    for _, z in ipairs({-76, -38, 0, 38, 76}) do
        for _, x in ipairs({-32, 32}) do
            local post = part(gardens, "PathLanternPost", Vector3.new(0.8, 6, 0.8),
                Vector3.new(x, 14, z), Color3.fromRGB(111, 76, 52), Enum.Material.Wood)
            post.CanCollide = false
            local lightOrb = part(gardens, "PathLanternGlow", Vector3.new(2.3, 2.3, 2.3),
                Vector3.new(x, 17.3, z), Color3.fromRGB(255, 220, 139),
                Enum.Material.Neon, Enum.PartType.Ball)
            lightOrb.CanCollide = false
            local pointLight = Instance.new("PointLight")
            pointLight.Range = 13
            pointLight.Brightness = 0.6
            pointLight.Color = Color3.fromRGB(255, 219, 156)
            pointLight.Parent = lightOrb
        end
    end

    for _, eggPosition in ipairs({
        Vector3.new(-24, 14, 20), Vector3.new(25, 14, 24), Vector3.new(0, 14, 65),
    }) do
        local pedestal = part(gardens, "EggPedestal", Vector3.new(1.4, 6, 6),
            Vector3.new(eggPosition.X, 11, eggPosition.Z),
            Color3.fromRGB(176, 146, 112), Enum.Material.Slate, Enum.PartType.Cylinder)
        pedestal.CFrame = CFrame.new(eggPosition.X, 11, eggPosition.Z)
            * CFrame.Angles(0, 0, math.rad(90))
        pedestal.CanCollide = false
    end

    return world
end

return WorldBuilder
