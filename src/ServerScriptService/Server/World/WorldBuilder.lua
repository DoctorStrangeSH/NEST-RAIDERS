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
        {x = -42, z = -5}, {x = 42, z = -5},
        {x = -42, z = 40}, {x = 42, z = 40},
        {x = -35, z = 75}, {x = 35, z = 75},
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
        Vector3.new(-42, 14, -5), Vector3.new(42, 14, -5),
        Vector3.new(-42, 14, 40), Vector3.new(42, 14, 40),
        Vector3.new(-35, 14, 75), Vector3.new(35, 14, 75),
    }) do
        local pedestal = part(gardens, "EggPedestal", Vector3.new(1.4, 6, 6),
            Vector3.new(eggPosition.X, 11, eggPosition.Z),
            Color3.fromRGB(176, 146, 112), Enum.Material.Slate, Enum.PartType.Cylinder)
        pedestal.CFrame = CFrame.new(eggPosition.X, 11, eggPosition.Z)
            * CFrame.Angles(0, 0, math.rad(90))
        pedestal.CanCollide = false
    end


    -- Emerald Wilds is a real, reachable second play area, not a distant backdrop.
    local emerald = Instance.new("Folder")
    emerald.Name = "EmeraldWilds"
    emerald.Parent = world
    part(emerald, "EmeraldFloatingFoundation", Vector3.new(190, 30, 190),
        Vector3.new(0, -3, 520), Color3.fromRGB(75, 103, 75), Enum.Material.Slate, Enum.PartType.Ball)
    local emeraldTop = part(emerald, "EmeraldGrassTop", Vector3.new(8, 174, 174),
        Vector3.new(0, 13, 520), Color3.fromRGB(67, 145, 91), Enum.Material.Grass, Enum.PartType.Cylinder)
    emeraldTop.CFrame = CFrame.new(0, 13, 520) * CFrame.Angles(0, 0, math.rad(90))
    part(emerald, "AncientGroveClearing", Vector3.new(78, 1, 72),
        Vector3.new(0, 17.5, 520), Color3.fromRGB(91, 166, 103), Enum.Material.Grass)
    for index, offset in ipairs({
        Vector3.new(-62, 18, -55), Vector3.new(-70, 18, 0), Vector3.new(-55, 18, 62),
        Vector3.new(62, 18, -55), Vector3.new(70, 18, 0), Vector3.new(55, 18, 62),
        Vector3.new(-30, 18, -72), Vector3.new(35, 18, 72), Vector3.new(0, 18, -76),
    }) do
        local base = Vector3.new(offset.X, offset.Y, 520 + offset.Z)
        part(emerald, "AncientTreeTrunk", Vector3.new(4, 16, 4),
            base + Vector3.new(0, 8, 0), Color3.fromRGB(83, 65, 48), Enum.Material.Wood)
        local crown = part(emerald, "EmeraldCanopy", Vector3.new(18, 17, 18),
            base + Vector3.new(0, 18, 0), Color3.fromRGB(47, 133, 79), Enum.Material.Grass, Enum.PartType.Ball)
        crown.CanCollide = false
        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromRGB(117, 255, 164)
        glow.Range = 17
        glow.Brightness = 0.45
        glow.Parent = crown
    end
    local emeraldEggs = Instance.new("Folder")
    emeraldEggs.Name = "EggSpawnPoints"
    emeraldEggs.Parent = emerald
    for index, offset in ipairs({
        Vector3.new(-22, 20, 500), Vector3.new(22, 20, 500), Vector3.new(0, 20, 548),
    }) do
        local egg = part(emeraldEggs, "EmeraldEgg", Vector3.new(3.5, 4.5, 3.5),
            Vector3.new(offset.X, offset.Y, offset.Z), Color3.fromRGB(86, 255, 155),
            Enum.Material.Neon, Enum.PartType.Ball)
        egg:SetAttribute("WorldEgg", true)
        egg:SetAttribute("BiomeId", "EmeraldWilds")
        egg:SetAttribute("EggId", "EmeraldEgg")
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CollectEggPrompt"
        prompt.ActionText = "Собрать"
        prompt.ObjectText = "Яйцо Изумрудного леса"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.35
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = egg
    end

    -- Three persistent runes form the Emerald Wilds trial required by later biomes.
    local runeFolder = Instance.new("Folder")
    runeFolder.Name = "EmeraldTrialRunes"
    runeFolder.Parent = emerald
    local runeDefinitions = {
        { Id = "Grove", Name = "Руна рощи", Position = Vector3.new(-34, 19, 525), Color = Color3.fromRGB(125, 255, 173) },
        { Id = "River", Name = "Руна реки", Position = Vector3.new(34, 19, 525), Color = Color3.fromRGB(111, 226, 255) },
        { Id = "Dawn", Name = "Руна рассвета", Position = Vector3.new(0, 19, 485), Color = Color3.fromRGB(255, 224, 126) },
    }
    for _, definition in ipairs(runeDefinitions) do
        local pedestal = part(runeFolder, definition.Id .. "RunePedestal",
            Vector3.new(5, 2, 5), definition.Position - Vector3.new(0, 1, 0),
            Color3.fromRGB(92, 105, 82), Enum.Material.Slate)
        pedestal:SetAttribute("RuneId", definition.Id)
        local crystal = part(runeFolder, definition.Id .. "RuneCrystal",
            Vector3.new(2.2, 4.2, 2.2), definition.Position + Vector3.new(0, 2, 0),
            definition.Color, Enum.Material.Neon, Enum.PartType.Ball)
        crystal.CanCollide = false
        crystal:SetAttribute("RuneId", definition.Id)
        local light = Instance.new("PointLight")
        light.Color = definition.Color
        light.Range = 12
        light.Brightness = 0.8
        light.Parent = crystal
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "EmeraldRunePrompt"
        prompt.ActionText = "Активировать"
        prompt.ObjectText = definition.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.65
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Parent = crystal
    end

    local function makeBiomePortal(parent, name, position, color, zoneId, destination)
        local portal = part(parent, name, Vector3.new(4, 15, 15), position,
            color, Enum.Material.Neon, Enum.PartType.Cylinder)
        portal.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
        portal.CanCollide = false
        portal:SetAttribute("ZoneId", zoneId)
        portal:SetAttribute("Destination", destination)
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "ZoneTravelPrompt"
        prompt.ActionText = "Путешествовать"
        local zoneLabels = {
            EmeraldWilds = "Изумрудный лес · уровень 5",
            FrostHighlands = "Ледяные нагорья · уровень 12 + испытание",
            StarterIsland = "Стартовый остров",
        }
        prompt.ObjectText = zoneLabels[zoneId] or "Неизвестная область"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.5
        prompt.MaxActivationDistance = 13
        prompt.RequiresLineOfSight = false
        prompt.Parent = portal
        local light = Instance.new("PointLight")
        light.Color = color
        light.Range = 24
        light.Brightness = 1.1
        light.Parent = portal
    end
    makeBiomePortal(island, "EmeraldPortal", Vector3.new(0, 20, 132),
        Color3.fromRGB(80, 255, 153), "EmeraldWilds", Vector3.new(0, 16, 520))
    makeBiomePortal(emerald, "ReturnPortal", Vector3.new(0, 24, 430),
        Color3.fromRGB(255, 218, 126), "StarterIsland", Vector3.new(0, 11, -112))

    -- Frost Highlands is a reachable third island with its own egg table and trial.
    local frost = Instance.new("Folder")
    frost.Name = "FrostHighlands"
    frost.Parent = world
    part(frost, "FrostFloatingFoundation", Vector3.new(190, 30, 190),
        Vector3.new(0, -3, 1040), Color3.fromRGB(91, 112, 137), Enum.Material.Slate, Enum.PartType.Ball)
    local frostTop = part(frost, "FrostSnowTop", Vector3.new(8, 174, 174),
        Vector3.new(0, 13, 1040), Color3.fromRGB(205, 229, 244), Enum.Material.Snow, Enum.PartType.Cylinder)
    frostTop.CFrame = CFrame.new(0, 13, 1040) * CFrame.Angles(0, 0, math.rad(90))
    part(frost, "GlacierClearing", Vector3.new(82, 1, 76),
        Vector3.new(0, 17.5, 1040), Color3.fromRGB(224, 239, 248), Enum.Material.Ice)
    for _, offset in ipairs({
        Vector3.new(-65, 18, -58), Vector3.new(-72, 18, 0), Vector3.new(-58, 18, 62),
        Vector3.new(65, 18, -58), Vector3.new(72, 18, 0), Vector3.new(58, 18, 62),
        Vector3.new(-30, 18, -76), Vector3.new(34, 18, 76), Vector3.new(0, 18, -78),
    }) do
        local base = Vector3.new(offset.X, offset.Y, 1040 + offset.Z)
        local trunk = part(frost, "FrostPineTrunk", Vector3.new(3, 13, 3),
            base + Vector3.new(0, 6.5, 0), Color3.fromRGB(94, 105, 116), Enum.Material.Wood)
        trunk.CanCollide = false
        for layer = 1, 3 do
            local crown = part(frost, "SnowPineLayer", Vector3.new(13 - layer * 2, 8, 13 - layer * 2),
                base + Vector3.new(0, 10 + layer * 4, 0),
                layer == 1 and Color3.fromRGB(113, 157, 178) or Color3.fromRGB(211, 237, 247),
                Enum.Material.Snow, Enum.PartType.Ball)
            crown.CanCollide = false
        end
    end
    for index, position in ipairs({
        Vector3.new(-48, 19, 1000), Vector3.new(48, 19, 1000),
        Vector3.new(-52, 19, 1072), Vector3.new(52, 19, 1072),
    }) do
        local crystal = part(frost, "GlacierCrystal", Vector3.new(5, 13, 5),
            position, Color3.fromRGB(112, 219, 255), Enum.Material.Neon, Enum.PartType.Block)
        crystal.CanCollide = false
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(135, 220, 255)
        light.Range = 18
        light.Brightness = 0.8
        light.Parent = crystal
    end

    local frostEggs = Instance.new("Folder")
    frostEggs.Name = "EggSpawnPoints"
    frostEggs.Parent = frost
    for _, position in ipairs({
        Vector3.new(-22, 20, 1020), Vector3.new(22, 20, 1020), Vector3.new(0, 20, 1068),
    }) do
        local egg = part(frostEggs, "FrostEgg", Vector3.new(3.5, 4.5, 3.5),
            position, Color3.fromRGB(133, 226, 255), Enum.Material.Neon, Enum.PartType.Ball)
        egg:SetAttribute("WorldEgg", true)
        egg:SetAttribute("BiomeId", "FrostHighlands")
        egg:SetAttribute("EggId", "FrostEgg")
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CollectEggPrompt"
        prompt.ActionText = "Собрать"
        prompt.ObjectText = "Яйцо вечной зимы"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.35
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = egg
    end

    local frostRunes = Instance.new("Folder")
    frostRunes.Name = "FrostTrialRunes"
    frostRunes.Parent = frost
    local frostRuneDefinitions = {
        { Id = "Aurora", Name = "Руна сияния", Position = Vector3.new(-34, 19, 1045), Color = Color3.fromRGB(123, 239, 255) },
        { Id = "Glacier", Name = "Руна ледника", Position = Vector3.new(34, 19, 1045), Color = Color3.fromRGB(176, 205, 255) },
        { Id = "Winter", Name = "Руна зимы", Position = Vector3.new(0, 19, 1005), Color = Color3.fromRGB(232, 247, 255) },
    }
    for _, definition in ipairs(frostRuneDefinitions) do
        part(frostRunes, definition.Id .. "RunePedestal", Vector3.new(5, 2, 5),
            definition.Position - Vector3.new(0, 1, 0), Color3.fromRGB(93, 113, 133), Enum.Material.Slate)
        local crystal = part(frostRunes, definition.Id .. "RuneCrystal", Vector3.new(2.2, 4.2, 2.2),
            definition.Position + Vector3.new(0, 2, 0), definition.Color, Enum.Material.Neon, Enum.PartType.Block)
        crystal.CanCollide = false
        crystal:SetAttribute("RuneId", definition.Id)
        local light = Instance.new("PointLight")
        light.Color = definition.Color
        light.Range = 12
        light.Brightness = 0.9
        light.Parent = crystal
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "FrostRunePrompt"
        prompt.ActionText = "Пробудить"
        prompt.ObjectText = definition.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.65
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Parent = crystal
    end

    makeBiomePortal(emerald, "FrostPortal", Vector3.new(40, 24, 470),
        Color3.fromRGB(132, 224, 255), "FrostHighlands", Vector3.new(0, 16, 1040))
    makeBiomePortal(frost, "FrostReturnPortal", Vector3.new(40, 24, 970),
        Color3.fromRGB(113, 255, 180), "EmeraldWilds", Vector3.new(0, 16, 520))
    -- A walkable ice causeway makes the third biome physically connected;
    -- portals remain as optional fast travel, not the only route.
    local causeway = Instance.new("Folder")
    causeway.Name = "GlacierCauseway"
    causeway.Parent = world
    for index = 1, 9 do
        local z = 620 + (index - 1) * 40
        local x = index % 2 == 0 and 4 or -4
        local segment = part(causeway, "IceBridgeSegment_" .. index,
            Vector3.new(20, 2, 44), Vector3.new(x, 16.5, z),
            Color3.fromRGB(151, 207, 232), Enum.Material.Ice)
        segment.Material = Enum.Material.Ice
        local beacon = part(causeway, "BridgeBeacon_" .. index,
            Vector3.new(1.2, 3.2, 1.2), Vector3.new(x + (index % 2 == 0 and 8 or -8), 19, z),
            Color3.fromRGB(126, 221, 255), Enum.Material.Neon, Enum.PartType.Ball)
        beacon.CanCollide = false
        if index % 2 == 1 then
            local light = Instance.new("PointLight")
            light.Color = Color3.fromRGB(126, 221, 255)
            light.Range = 12
            light.Brightness = 0.35
            light.Parent = beacon
        end
    end

    local oddsSign = part(frost, "FrostEggOddsSign", Vector3.new(28, 10, 1),
        Vector3.new(0, 24, 1088), Color3.fromRGB(62, 93, 121), Enum.Material.WoodPlanks)
    oddsSign.CanCollide = false
    local oddsGui = Instance.new("SurfaceGui")
    oddsGui.Face = Enum.NormalId.Front
    oddsGui.Parent = oddsSign
    local oddsLabel = Instance.new("TextLabel")
    oddsLabel.Size = UDim2.fromScale(1, 1)
    oddsLabel.BackgroundTransparency = 1
    oddsLabel.Text = "ЯЙЦО ВЕЧНОЙ ЗИМЫ\\nСнежный лис · 60%\\nПолярная сова · 30%\\nЛедниковый медвежонок · 10%"
    oddsLabel.TextColor3 = Color3.fromRGB(230, 248, 255)
    oddsLabel.TextScaled = true
    oddsLabel.TextWrapped = true
    oddsLabel.Font = Enum.Font.GothamBlack
    oddsLabel.Parent = oddsGui

    local frostSign = part(frost, "FrostWelcomeSign", Vector3.new(22, 9, 1),
        Vector3.new(0, 25, 972), Color3.fromRGB(73, 101, 127), Enum.Material.WoodPlanks)
    local frostGui = Instance.new("SurfaceGui")
    frostGui.Face = Enum.NormalId.Front
    frostGui.Parent = frostSign
    local frostLabel = Instance.new("TextLabel")
    frostLabel.Size = UDim2.fromScale(1, 1)
    frostLabel.BackgroundTransparency = 1
    frostLabel.Text = "ЛЕДЯНЫЕ НАГОРЬЯ\\nЯйца вечной зимы"
    frostLabel.TextColor3 = Color3.fromRGB(230, 248, 255)
    frostLabel.TextScaled = true
    frostLabel.Font = Enum.Font.GothamBlack
    frostLabel.Parent = frostGui
    local emeraldSign = part(emerald, "EmeraldWelcomeSign", Vector3.new(22, 9, 1),
        Vector3.new(0, 25, 452), Color3.fromRGB(61, 91, 66), Enum.Material.WoodPlanks)
    local emeraldGui = Instance.new("SurfaceGui")
    emeraldGui.Face = Enum.NormalId.Front
    emeraldGui.Parent = emeraldSign
    local emeraldLabel = Instance.new("TextLabel")
    emeraldLabel.Size = UDim2.fromScale(1, 1)
    emeraldLabel.BackgroundTransparency = 1
    emeraldLabel.Text = "ИЗУМРУДНЫЙ ЛЕС\\nЯйца древней рощи"
    emeraldLabel.TextColor3 = Color3.fromRGB(214, 255, 220)
    emeraldLabel.TextScaled = true
    emeraldLabel.Font = Enum.Font.GothamBlack
    emeraldLabel.Parent = emeraldGui


    -- Emberlands: volcanic island with server-readable heat and cooling volumes.
    local ember = Instance.new("Folder")
    ember.Name = "Emberlands"
    ember.Parent = world
    part(ember, "EmberFloatingFoundation", Vector3.new(205, 34, 205),
        Vector3.new(0, -5, 1560), Color3.fromRGB(54, 48, 49), Enum.Material.Basalt, Enum.PartType.Ball)
    part(ember, "AshenPlateau", Vector3.new(172, 5, 172),
        Vector3.new(0, 12, 1560), Color3.fromRGB(89, 75, 70), Enum.Material.Slate)
    part(ember, "VolcanoRim", Vector3.new(72, 25, 72),
        Vector3.new(0, 25, 1560), Color3.fromRGB(47, 42, 43), Enum.Material.Rock, Enum.PartType.Ball)
    part(ember, "MagmaCore", Vector3.new(32, 4, 32),
        Vector3.new(0, 36, 1560), Color3.fromRGB(255, 104, 35), Enum.Material.Neon, Enum.PartType.Ball)
    for index = 1, 5 do
        local x = -64 + index * 26
        local lava = part(ember, "LavaRiver_" .. index, Vector3.new(10, 1.2, 112),
            Vector3.new(x, 15.5, 1560), Color3.fromRGB(255, 104, 30), Enum.Material.Neon)
        lava.CanCollide = false
        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromRGB(255, 102, 28)
        glow.Range = 22
        glow.Brightness = 1.4
        glow.Parent = lava
    end
    for index = 1, 12 do
        local angle = (math.pi * 2 * index) / 12
        local x, z = math.cos(angle) * 72, 1560 + math.sin(angle) * 72
        local rock = part(ember, "BasaltPillar_" .. index, Vector3.new(9, 13 + (index % 3) * 4, 9),
            Vector3.new(x, 18, z), Color3.fromRGB(65, 57, 57), Enum.Material.Basalt, Enum.PartType.Block)
        rock.CFrame *= CFrame.Angles(0, angle, math.rad((index % 2 == 0) and 8 or -8))
    end

    local heatZones = Instance.new("Folder")
    heatZones.Name = "HeatZones"
    heatZones.Parent = ember
    local function makeHeatZone(name, size, position, rate)
        local zone = part(heatZones, name, size, position, Color3.fromRGB(255, 90, 35), Enum.Material.ForceField)
        zone.Transparency = 1
        zone.CanCollide = false
        zone.CanTouch = false
        zone.CanQuery = false
        zone:SetAttribute("HeatPerSecond", rate)
        return zone
    end
    makeHeatZone("OuterAshHeat", Vector3.new(150, 28, 150), Vector3.new(0, 24, 1560), 4)
    makeHeatZone("MagmaRimHeat", Vector3.new(82, 34, 82), Vector3.new(0, 30, 1560), 9)
    makeHeatZone("LavaChannelHeat", Vector3.new(140, 18, 28), Vector3.new(0, 22, 1560), 13)

    local sanctuary = Instance.new("Folder")
    sanctuary.Name = "CoolingSanctuary"
    sanctuary.Parent = ember
    local sanctuaryBase = part(sanctuary, "CoolingSanctuaryBase", Vector3.new(34, 2, 30),
        Vector3.new(0, 15.5, 1480), Color3.fromRGB(91, 167, 174), Enum.Material.Glass)
    sanctuaryBase:SetAttribute("CoolingPerSecond", 24)
    local sanctuaryCrystal = part(sanctuary, "CoolingCrystal", Vector3.new(5, 13, 5),
        Vector3.new(0, 24, 1480), Color3.fromRGB(119, 235, 229), Enum.Material.Neon, Enum.PartType.Ball)
    sanctuaryCrystal.CanCollide = false
    local sanctuaryLight = Instance.new("PointLight")
    sanctuaryLight.Color = Color3.fromRGB(119, 235, 229)
    sanctuaryLight.Range = 34
    sanctuaryLight.Brightness = 2
    sanctuaryLight.Parent = sanctuaryCrystal
    local sanctuaryLabel = part(sanctuary, "CoolingSanctuarySign", Vector3.new(24, 7, 1),
        Vector3.new(0, 23, 1462), Color3.fromRGB(43, 87, 89), Enum.Material.WoodPlanks)
    local sanctuaryGui = Instance.new("SurfaceGui")
    sanctuaryGui.Face = Enum.NormalId.Front
    sanctuaryGui.Parent = sanctuaryLabel
    local sanctuaryText = Instance.new("TextLabel")
    sanctuaryText.Size = UDim2.fromScale(1, 1)
    sanctuaryText.BackgroundTransparency = 1
    sanctuaryText.Text = "УБЕЖИЩЕ\\nЗдесь можно остыть"
    sanctuaryText.TextColor3 = Color3.fromRGB(220, 255, 250)
    sanctuaryText.TextScaled = true
    sanctuaryText.Font = Enum.Font.GothamBlack
    sanctuaryText.Parent = sanctuaryGui

    local emberEggs = Instance.new("Folder")
    emberEggs.Name = "EggSpawnPoints"
    emberEggs.Parent = ember
    for _, position in ipairs({
        Vector3.new(-48, 16, 1520), Vector3.new(48, 16, 1520), Vector3.new(-48, 16, 1600),
        Vector3.new(48, 16, 1600), Vector3.new(0, 16, 1630),
    }) do
        local egg = part(emberEggs, "EmberEgg", Vector3.new(3.8, 4.8, 3.8),
            position, Color3.fromRGB(255, 126, 54), Enum.Material.Neon, Enum.PartType.Ball)
        egg:SetAttribute("WorldEgg", true)
        egg:SetAttribute("BiomeId", "Emberlands")
        egg:SetAttribute("EggId", "EmberEgg")
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CollectEggPrompt"
        prompt.ActionText = "Собрать"
        prompt.ObjectText = "Яйцо пепельного пламени"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.4
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = egg
    end

    makeBiomePortal(frost, "EmberPortal", Vector3.new(45, 24, 1480),
        Color3.fromRGB(255, 125, 55), "Emberlands", Vector3.new(0, 18, 1480))
    makeBiomePortal(ember, "EmberReturnPortal", Vector3.new(-45, 24, 1480),
        Color3.fromRGB(128, 225, 255), "FrostHighlands", Vector3.new(0, 16, 1040))
    local emberSign = part(ember, "EmberWelcomeSign", Vector3.new(25, 9, 1),
        Vector3.new(0, 25, 1438), Color3.fromRGB(88, 49, 42), Enum.Material.WoodPlanks)
    local emberGui = Instance.new("SurfaceGui")
    emberGui.Face = Enum.NormalId.Front
    emberGui.Parent = emberSign
    local emberText = Instance.new("TextLabel")
    emberText.Size = UDim2.fromScale(1, 1)
    emberText.BackgroundTransparency = 1
    emberText.Text = "ПЕПЕЛЬНЫЕ ЗЕМЛИ\\nБерегись жара!"
    emberText.TextColor3 = Color3.fromRGB(255, 224, 192)
    emberText.TextScaled = true
    emberText.Font = Enum.Font.GothamBlack
    emberText.Parent = emberGui

    return world
end

return WorldBuilder
