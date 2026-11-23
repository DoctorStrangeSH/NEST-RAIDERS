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
            Enum.Material.Slate)
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
            Emberlands = "Пепельные земли · уровень 22 + испытание",
            CrystalRealm = "Хрустальное королевство · уровень 35 + испытание",
            AncientHeights = "Древние высоты · уровень 50 + испытание",
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
    local coolingVolume = part(sanctuary, "CoolingZone", Vector3.new(38, 18, 36),
        Vector3.new(0, 24, 1480), Color3.fromRGB(119, 235, 229), Enum.Material.ForceField)
    coolingVolume.Transparency = 1
    coolingVolume.CanCollide = false
    coolingVolume.CanTouch = false
    coolingVolume.CanQuery = false
    coolingVolume:SetAttribute("CoolingPerSecond", 24)
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

    -- Physical causeway from Frost Highlands: portals are optional shortcuts.
    local emberCauseway = Instance.new("Folder")
    emberCauseway.Name = "EmberCauseway"
    emberCauseway.Parent = world
    for index = 1, 9 do
        local z = 1130 + (index - 1) * 40
        local x = index % 2 == 0 and -3 or 3
        local segment = part(emberCauseway, "EmberBridgeSegment_" .. index,
            Vector3.new(20, 2, 44), Vector3.new(x, 16.5, z),
            Color3.fromRGB(92, 83, 82), Enum.Material.Basalt)
        local edgeGlow = part(emberCauseway, "BridgeLavaBeacon_" .. index,
            Vector3.new(1.1, 2.8, 1.1), Vector3.new(x + (index % 2 == 0 and 8 or -8), 18.5, z),
            Color3.fromRGB(255, 126, 56), Enum.Material.Neon, Enum.PartType.Ball)
        edgeGlow.CanCollide = false
        if index % 2 == 1 then
            local beaconLight = Instance.new("PointLight")
            beaconLight.Color = Color3.fromRGB(255, 126, 56)
            beaconLight.Range = 10
            beaconLight.Brightness = 0.45
            beaconLight.Parent = edgeGlow
        end
    end

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

    makeBiomePortal(frost, "EmberPortal", Vector3.new(45, 24, 1080),
        Color3.fromRGB(255, 125, 55), "Emberlands", Vector3.new(0, 18, 1480))
    makeBiomePortal(ember, "EmberReturnPortal", Vector3.new(-45, 24, 1480),
        Color3.fromRGB(128, 225, 255), "FrostHighlands", Vector3.new(0, 16, 1040))
    makeBiomePortal(ember, "CrystalPortal", Vector3.new(72, 22, 1560),
        Color3.fromRGB(180, 130, 255), "CrystalRealm", Vector3.new(0, 24, 2080))
    local emberOddsSign = part(ember, "EmberEggOddsSign", Vector3.new(28, 10, 1),
        Vector3.new(0, 24, 1638), Color3.fromRGB(91, 49, 38), Enum.Material.WoodPlanks)
    emberOddsSign.CanCollide = false
    local emberOddsGui = Instance.new("SurfaceGui")
    emberOddsGui.Face = Enum.NormalId.Front
    emberOddsGui.Parent = emberOddsSign
    local emberOddsText = Instance.new("TextLabel")
    emberOddsText.Size = UDim2.fromScale(1, 1)
    emberOddsText.BackgroundTransparency = 1
    emberOddsText.Text = "ЯЙЦО ПЕПЕЛЬНОГО ПЛАМЕНИ\\nУгольный лис · 60%\\nМагмовый дракончик · 30%\\nПепельный феникс · 10%"
    emberOddsText.TextColor3 = Color3.fromRGB(255, 229, 204)
    emberOddsText.TextScaled = true
    emberOddsText.TextWrapped = true
    emberOddsText.Font = Enum.Font.GothamBlack
    emberOddsText.Parent = emberOddsGui

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


    -- Heart of Fire trial arena: a raised basalt platform, three runes and a visible guardian.
    local trial = Instance.new("Folder")
    trial.Name = "HeartOfFireTrial"
    trial.Parent = ember

    local stairFolder = Instance.new("Folder")
    stairFolder.Name = "TrialApproach"
    stairFolder.Parent = trial
    for index = 1, 12 do
        local alpha = (index - 1) / 11
        local step = part(stairFolder, "BasaltTrialStep_" .. index,
            Vector3.new(13, 2.2, 12),
            Vector3.new(-66 + index * 5, 16 + alpha * 36, 1560),
            Color3.fromRGB(75, 65, 64), Enum.Material.Basalt)
        step.CFrame *= CFrame.Angles(0, 0, math.rad(-3))
    end

    local arena = part(trial, "HeartOfFireArena", Vector3.new(76, 3, 76),
        Vector3.new(0, 50.5, 1560), Color3.fromRGB(76, 60, 57), Enum.Material.Basalt)
    arena:SetAttribute("TrialArena", true)

    for index = 1, 12 do
        local angle = (math.pi * 2 * index) / 12
        local x, z = math.cos(angle) * 39, 1560 + math.sin(angle) * 39
        local marker = part(trial, "ArenaEmberMarker_" .. index,
            Vector3.new(2.2, 5, 2.2), Vector3.new(x, 54.2, z),
            Color3.fromRGB(255, 115, 54), Enum.Material.Neon, Enum.PartType.Ball)
        marker.CanCollide = false
        if index % 2 == 0 then
            local markerLight = Instance.new("PointLight")
            markerLight.Color = marker.Color
            markerLight.Range = 12
            markerLight.Brightness = 0.7
            markerLight.Parent = marker
        end
    end

    local runeFolder = Instance.new("Folder")
    runeFolder.Name = "TrialRunes"
    runeFolder.Parent = trial
    local runeDefinitions = {
        {Id = "Ember", Name = "Руна Углей", Position = Vector3.new(-23, 56, 1540), Color = Color3.fromRGB(255, 167, 79)},
        {Id = "Cinder", Name = "Руна Пепла", Position = Vector3.new(23, 56, 1540), Color = Color3.fromRGB(255, 105, 66)},
        {Id = "Inferno", Name = "Руна Пламени", Position = Vector3.new(0, 56, 1587), Color = Color3.fromRGB(255, 218, 112)},
    }
    for _, definition in ipairs(runeDefinitions) do
        local pedestal = part(runeFolder, definition.Id .. "RunePedestal",
            Vector3.new(8, 3, 8), definition.Position - Vector3.new(0, 3, 0),
            Color3.fromRGB(59, 49, 49), Enum.Material.Basalt)
        local rune = part(runeFolder, definition.Id .. "Rune",
            Vector3.new(3.2, 5.2, 1.4), definition.Position,
            definition.Color, Enum.Material.Neon, Enum.PartType.Ball)
        rune.CanCollide = false
        rune:SetAttribute("RuneId", definition.Id)
        local runeLight = Instance.new("PointLight")
        runeLight.Color = definition.Color
        runeLight.Range = 16
        runeLight.Brightness = 1.4
        runeLight.Parent = rune
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "EmberTrialRunePrompt"
        prompt.ActionText = "Пробудить"
        prompt.ObjectText = definition.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.7
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = rune
        pedestal:SetAttribute("RunePedestal", definition.Id)
    end

    local guardian = Instance.new("Model")
    guardian.Name = "HeartOfFireGuardian"
    guardian.Parent = trial
    local body = part(guardian, "GuardianCore", Vector3.new(12, 15, 10),
        Vector3.new(0, 59.5, 1560), Color3.fromRGB(100, 48, 39), Enum.Material.Basalt, Enum.PartType.Ball)
    body.CanCollide = false
    local core = part(guardian, "GuardianFlameCore", Vector3.new(6, 8, 6),
        Vector3.new(0, 60.5, 1554), Color3.fromRGB(255, 117, 44), Enum.Material.Neon, Enum.PartType.Ball)
    core.CanCollide = false
    local coreLight = Instance.new("PointLight")
    coreLight.Color = Color3.fromRGB(255, 117, 44)
    coreLight.Range = 30
    coreLight.Brightness = 2.5
    coreLight.Parent = core
    for side = -1, 1, 2 do
        local horn = part(guardian, "GuardianHorn_" .. side,
            Vector3.new(3, 9, 3), Vector3.new(side * 6, 68.5, 1562),
            Color3.fromRGB(61, 49, 48), Enum.Material.Basalt, Enum.PartType.Ball)
        horn.CFrame *= CFrame.Angles(0, 0, math.rad(side * 24))
        horn.CanCollide = false
        local arm = part(guardian, "GuardianArm_" .. side,
            Vector3.new(5, 11, 6), Vector3.new(side * 9, 55.5, 1560),
            Color3.fromRGB(78, 48, 43), Enum.Material.Basalt, Enum.PartType.Ball)
        arm.CanCollide = false
    end
    for index = 1, 8 do
        local angle = math.rad((index - 1) * 45)
        local crystalBase = Vector3.new(174 + math.cos(angle) * 14, 20.2, 2600 + math.sin(angle) * 9)
        local cluster = Instance.new("Model")
        cluster.Name = "ForgottenHeartArenaCrystal_" .. index
        cluster.Parent = forgottenCave
        local crystal = part(cluster, "CrystalCore",
            Vector3.new(2.1, 5.2, 2.1), crystalBase + Vector3.new(0, 2.6, 0),
            Color3.fromRGB(101, 194, 224), Enum.Material.Neon, Enum.PartType.Wedge)
        crystal.CanCollide = false
        local crystalGlow = Instance.new("PointLight")
        crystalGlow.Color = Color3.fromRGB(111, 204, 255)
        crystalGlow.Range = 9
        crystalGlow.Brightness = 0.65
        crystalGlow.Parent = crystal
        local crystalSmall = part(cluster, "CrystalShard",
            Vector3.new(1.1, 2.8, 1.1), crystalBase + Vector3.new(1.4, 1.4, -0.6),
            Color3.fromRGB(166, 135, 235), Enum.Material.Neon, Enum.PartType.Wedge)
        crystalSmall.CanCollide = false
    end

    local bossPrompt = Instance.new("ProximityPrompt")
    bossPrompt.Name = "EmberTrialBossPrompt"
    bossPrompt.ActionText = "Атаковать"
    bossPrompt.ObjectText = "Огненный страж"
    bossPrompt.KeyboardKeyCode = Enum.KeyCode.E
    bossPrompt.HoldDuration = 0.4
    bossPrompt.MaxActivationDistance = 12
    bossPrompt.RequiresLineOfSight = false
    bossPrompt.Parent = core

    local trialSign = part(trial, "HeartOfFireTrialSign", Vector3.new(26, 9, 1),
        Vector3.new(0, 58, 1516), Color3.fromRGB(73, 42, 37), Enum.Material.WoodPlanks)
    local trialGui = Instance.new("SurfaceGui")
    trialGui.Face = Enum.NormalId.Front
    trialGui.Parent = trialSign
    local trialLabel = Instance.new("TextLabel")
    trialLabel.Size = UDim2.fromScale(1, 1)
    trialLabel.BackgroundTransparency = 1
    trialLabel.Text = "ИСПЫТАНИЕ ОГНЕННОГО СЕРДЦА\\nПробуди три руны. Победи стража."
    trialLabel.TextColor3 = Color3.fromRGB(255, 225, 192)
    trialLabel.TextScaled = true
    trialLabel.TextWrapped = true
    trialLabel.Font = Enum.Font.GothamBlack
    trialLabel.Parent = trialGui


    -- Crystal Realm: a floating sanctuary of luminous quartz, gardens and mineable veins.
    local crystal = Instance.new("Folder")
    crystal.Name = "CrystalRealm"
    crystal.Parent = world
    part(crystal, "CrystalFloatingFoundation", Vector3.new(225, 38, 225),
        Vector3.new(0, -3, 2080), Color3.fromRGB(70, 69, 105), Enum.Material.Slate, Enum.PartType.Ball)
    local crystalTop = part(crystal, "PrismaticPlateau", Vector3.new(10, 205, 205),
        Vector3.new(0, 18, 2080), Color3.fromRGB(135, 119, 184), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
    crystalTop.CFrame = CFrame.new(0, 18, 2080) * CFrame.Angles(0, 0, math.rad(90))
    part(crystal, "RoyalCrystalClearing", Vector3.new(104, 1.5, 92),
        Vector3.new(0, 23.5, 2082), Color3.fromRGB(175, 159, 218), Enum.Material.SmoothPlastic)

    local crystalPalette = {
        Color3.fromRGB(115, 225, 255),
        Color3.fromRGB(190, 145, 255),
        Color3.fromRGB(255, 174, 225),
        Color3.fromRGB(171, 255, 218),
    }
    local spirePositions = {
        Vector3.new(-82, 22, 2010), Vector3.new(-88, 22, 2070), Vector3.new(-78, 22, 2140),
        Vector3.new(82, 22, 2010), Vector3.new(88, 22, 2070), Vector3.new(78, 22, 2140),
        Vector3.new(-42, 22, 2180), Vector3.new(42, 22, 2180), Vector3.new(0, 22, 1988),
    }
    for index, position in ipairs(spirePositions) do
        local height = 18 + (index % 4) * 7
        local spire = part(crystal, "RoyalCrystalSpire_" .. index,
            Vector3.new(8 + (index % 2) * 3, height, 8 + (index % 2) * 3),
            position + Vector3.new(0, height / 2, 0), crystalPalette[(index - 1) % #crystalPalette + 1],
            Enum.Material.Neon, Enum.PartType.Block)
        spire.CFrame *= CFrame.Angles(math.rad((index % 3 - 1) * 9), math.rad(index * 19), math.rad((index % 2 == 0) and 8 or -8))
        spire.CanCollide = false
        local light = Instance.new("PointLight")
        light.Color = spire.Color
        light.Range = 22
        light.Brightness = 0.8
        light.Parent = spire
    end

    local gardenFolder = Instance.new("Folder")
    gardenFolder.Name = "AuroraGardens"
    gardenFolder.Parent = crystal
    for index = 1, 32 do
        local angle = index * 2.399
        local radius = 42 + (index % 4) * 7
        local position = Vector3.new(math.cos(angle) * radius, 24.2, 2080 + math.sin(angle) * radius)
        local flower = part(gardenFolder, "AuroraBloom_" .. index,
            Vector3.new(1.5, 1.5, 1.5), position,
            crystalPalette[(index - 1) % #crystalPalette + 1], Enum.Material.Neon, Enum.PartType.Ball)
        flower.CanCollide = false
        if index % 4 == 0 then
            local glow = Instance.new("PointLight")
            glow.Color = flower.Color
            glow.Range = 8
            glow.Brightness = 0.35
            glow.Parent = flower
        end
    end

    local bridge = Instance.new("Folder")
    bridge.Name = "CrystalSkyway"
    bridge.Parent = world
    for index = 1, 8 do
        local z = 1660 + (index - 1) * 39
        local y = 20 + math.sin(index * 0.65) * 2
        local segment = part(bridge, "CrystalBridgeSegment_" .. index,
            Vector3.new(18, 2, 42), Vector3.new(0, y, z),
            Color3.fromRGB(129, 117, 157), Enum.Material.Glass)
        segment.Transparency = 0.12
        for side = -1, 1, 2 do
            local rail = part(bridge, "CrystalBridgeRail_" .. index .. "_" .. side,
                Vector3.new(1, 2.4, 40), Vector3.new(side * 8.5, y + 1.8, z),
                Color3.fromRGB(150, 222, 255), Enum.Material.Neon)
            rail.CanCollide = false
            rail.Transparency = 0.18
        end
    end

    local veins = Instance.new("Folder")
    veins.Name = "CrystalVeins"
    veins.Parent = crystal
    local veinPositions = {
        Vector3.new(-65, 25, 2040), Vector3.new(65, 25, 2040),
        Vector3.new(-70, 25, 2110), Vector3.new(70, 25, 2110),
        Vector3.new(-42, 25, 2160), Vector3.new(42, 25, 2160),
        Vector3.new(-88, 25, 2080), Vector3.new(88, 25, 2080),
    }
    for index, position in ipairs(veinPositions) do
        local color = crystalPalette[(index - 1) % #crystalPalette + 1]
        local node = part(veins, "CrystalVein_" .. index,
            Vector3.new(5, 8 + (index % 3) * 2, 5),
            position + Vector3.new(0, 4, 0), color, Enum.Material.Neon, Enum.PartType.Block)
        node.CanCollide = false
        node:SetAttribute("CrystalNodeId", "RoyalVein_" .. index)
        local glow = Instance.new("PointLight")
        glow.Color = color
        glow.Range = 15
        glow.Brightness = 1.1
        glow.Parent = node
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "MineCrystalPrompt"
        prompt.ActionText = "Добыть"
        prompt.ObjectText = "Кристальная жила"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 1.2
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = node
    end

    local crystalEggs = Instance.new("Folder")
    crystalEggs.Name = "EggSpawnPoints"
    crystalEggs.Parent = crystal
    for _, position in ipairs({
        Vector3.new(-25, 26, 2050), Vector3.new(25, 26, 2050),
        Vector3.new(0, 26, 2120), Vector3.new(-48, 26, 2110),
        Vector3.new(48, 26, 2110),
    }) do
        local egg = part(crystalEggs, "CrystalEgg", Vector3.new(4, 5, 4),
            position, Color3.fromRGB(175, 145, 255), Enum.Material.Neon, Enum.PartType.Ball)
        egg:SetAttribute("WorldEgg", true)
        egg:SetAttribute("BiomeId", "CrystalRealm")
        egg:SetAttribute("EggId", "CrystalEgg")
        local shimmer = Instance.new("PointLight")
        shimmer.Color = egg.Color
        shimmer.Range = 12
        shimmer.Brightness = 1.2
        shimmer.Parent = egg
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CollectEggPrompt"
        prompt.ActionText = "Собрать"
        prompt.ObjectText = "Яйцо призматического сияния"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.45
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = egg
    end

    makeBiomePortal(crystal, "CrystalReturnPortal", Vector3.new(-50, 27, 2080),
        Color3.fromRGB(255, 155, 140), "Emberlands", Vector3.new(0, 18, 1600))
    local crystalOddsSign = part(crystal, "CrystalEggOddsSign", Vector3.new(30, 11, 1),
        Vector3.new(0, 30, 2158), Color3.fromRGB(66, 55, 104), Enum.Material.Slate)
    crystalOddsSign.CanCollide = false
    local crystalOddsGui = Instance.new("SurfaceGui")
    crystalOddsGui.Face = Enum.NormalId.Front
    crystalOddsGui.Parent = crystalOddsSign
    local crystalOddsText = Instance.new("TextLabel")
    crystalOddsText.Size = UDim2.fromScale(1, 1)
    crystalOddsText.BackgroundTransparency = 1
    crystalOddsText.Text = "ЯЙЦО ПРИЗМАТИЧЕСКОГО СИЯНИЯ\\nПризматический лис · 60%\\nКристальный оленёнок · 30%\\nДракон авроры · 10%"
    crystalOddsText.TextColor3 = Color3.fromRGB(239, 226, 255)
    crystalOddsText.TextScaled = true
    crystalOddsText.TextWrapped = true
    crystalOddsText.Font = Enum.Font.GothamBlack
    crystalOddsText.Parent = crystalOddsGui

    local welcomeSign = part(crystal, "CrystalWelcomeSign", Vector3.new(27, 9, 1),
        Vector3.new(0, 30, 1990), Color3.fromRGB(67, 57, 102), Enum.Material.Slate)
    local welcomeGui = Instance.new("SurfaceGui")
    welcomeGui.Face = Enum.NormalId.Front
    welcomeGui.Parent = welcomeSign
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.fromScale(1, 1)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "ХРУСТАЛЬНОЕ КОРОЛЕВСТВО\\nДобывай жилы и ищи яйца"
    welcomeText.TextColor3 = Color3.fromRGB(239, 226, 255)
    welcomeText.TextScaled = true
    welcomeText.TextWrapped = true
    welcomeText.Font = Enum.Font.GothamBlack
    welcomeText.Parent = welcomeGui


    -- Crystal Prism Trial: three ordered reflectors converge on the dormant guardian.
    local prismTrial = Instance.new("Folder")
    prismTrial.Name = "PrismTrial"
    prismTrial.Parent = crystal
    local trialPlatform = part(prismTrial, "PrismTrialPlatform", Vector3.new(82, 3, 68),
        Vector3.new(0, 26, 2080), Color3.fromRGB(88, 76, 125), Enum.Material.Slate)
    local platformTrim = part(prismTrial, "PrismPlatformTrim", Vector3.new(76, 0.7, 62),
        Vector3.new(0, 27.8, 2080), Color3.fromRGB(129, 111, 177), Enum.Material.Neon)
    platformTrim.CanCollide = false

    local prismDefinitions = {
        { Id = "Azure", Name = "Лазурная призма", Position = Vector3.new(-27, 30, 2068), Color = Color3.fromRGB(92, 211, 255) },
        { Id = "Rose", Name = "Розовая призма", Position = Vector3.new(0, 30, 2068), Color = Color3.fromRGB(255, 137, 215) },
        { Id = "Crown", Name = "Золотая призма", Position = Vector3.new(27, 30, 2068), Color = Color3.fromRGB(255, 215, 112) },
    }
    for index, definition in ipairs(prismDefinitions) do
        local pedestal = part(prismTrial, "PrismPedestal_" .. definition.Id,
            Vector3.new(7, 3, 7), definition.Position + Vector3.new(0, -1.5, 0),
            Color3.fromRGB(63, 56, 89), Enum.Material.Slate)
        pedestal:SetAttribute("PrismId", definition.Id)
        local crystalGem = part(prismTrial, "PrismGem_" .. definition.Id,
            Vector3.new(4, 7, 4), definition.Position + Vector3.new(0, 3.5, 0),
            definition.Color, Enum.Material.Neon, Enum.PartType.Block)
        crystalGem.CFrame *= CFrame.Angles(math.rad(10), math.rad(index * 22), math.rad(12))
        crystalGem.CanCollide = false
        crystalGem:SetAttribute("PrismId", definition.Id)
        local glow = Instance.new("PointLight")
        glow.Color = definition.Color
        glow.Range = 20
        glow.Brightness = 1.6
        glow.Parent = crystalGem
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CrystalPrismPrompt"
        prompt.ActionText = "Настроить луч"
        prompt.ObjectText = definition.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.65
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = crystalGem
    end

    local beamNodes = {
        Vector3.new(-27, 35, 2068),
        Vector3.new(0, 35, 2088),
        Vector3.new(27, 35, 2068),
    }
    for index = 1, 2 do
        local startPoint, endPoint = beamNodes[index], beamNodes[index + 1]
        local delta = endPoint - startPoint
        local beam = part(prismTrial, "PrismLightBeam_" .. index,
            Vector3.new(1.1, 1.1, delta.Magnitude), (startPoint + endPoint) / 2,
            index == 1 and Color3.fromRGB(115, 205, 255) or Color3.fromRGB(255, 178, 205),
            Enum.Material.Neon)
        beam.CFrame = CFrame.lookAt((startPoint + endPoint) / 2, endPoint)
        beam.CanCollide = false
        beam.Transparency = 0.18
    end

    local convergence = part(prismTrial, "PrismConvergenceCore", Vector3.new(8, 8, 8),
        Vector3.new(0, 34, 2093), Color3.fromRGB(255, 232, 163), Enum.Material.Neon, Enum.PartType.Ball)
    convergence.CanCollide = false
    local convergenceLight = Instance.new("PointLight")
    convergenceLight.Color = Color3.fromRGB(210, 192, 255)
    convergenceLight.Range = 28
    convergenceLight.Brightness = 2
    convergenceLight.Parent = convergence

    local prismGuardian = Instance.new("Model")
    prismGuardian.Name = "PrismGuardian"
    prismGuardian.Parent = prismTrial
    local guardianBody = part(prismGuardian, "GuardianBody", Vector3.new(13, 16, 11),
        Vector3.new(0, 39, 2110), Color3.fromRGB(82, 72, 113), Enum.Material.Slate, Enum.PartType.Ball)
    guardianBody.CanCollide = false
    local guardianCore = part(prismGuardian, "GuardianPrismCore", Vector3.new(7, 9, 7),
        Vector3.new(0, 40, 2104), Color3.fromRGB(190, 160, 255), Enum.Material.Neon, Enum.PartType.Block)
    guardianCore.CFrame *= CFrame.Angles(math.rad(12), math.rad(25), math.rad(12))
    guardianCore.CanCollide = false
    local guardianGlow = Instance.new("PointLight")
    guardianGlow.Color = Color3.fromRGB(190, 160, 255)
    guardianGlow.Range = 34
    guardianGlow.Brightness = 2.4
    guardianGlow.Parent = guardianCore
    for side = -1, 1, 2 do
        local shard = part(prismGuardian, "GuardianShard_" .. side,
            Vector3.new(4, 10, 4), Vector3.new(side * 9, 43, 2110),
            side < 0 and Color3.fromRGB(106, 213, 255) or Color3.fromRGB(255, 169, 218),
            Enum.Material.Neon, Enum.PartType.Block)
        shard.CFrame *= CFrame.Angles(0, 0, math.rad(side * 18))
        shard.CanCollide = false
    end
    local guardianPrompt = Instance.new("ProximityPrompt")
    guardianPrompt.Name = "CrystalTrialBossPrompt"
    guardianPrompt.ActionText = "Атаковать"
    guardianPrompt.ObjectText = "Хранитель призмы"
    guardianPrompt.KeyboardKeyCode = Enum.KeyCode.E
    guardianPrompt.HoldDuration = 0.45
    guardianPrompt.MaxActivationDistance = 12
    guardianPrompt.RequiresLineOfSight = false
    guardianPrompt.Parent = guardianCore

    local trialSign = part(prismTrial, "CrystalTrialSign", Vector3.new(34, 10, 1),
        Vector3.new(0, 34, 2043), Color3.fromRGB(58, 48, 91), Enum.Material.Slate)
    trialSign.CanCollide = false
    local trialGui = Instance.new("SurfaceGui")
    trialGui.Face = Enum.NormalId.Front
    trialGui.Parent = trialSign
    local trialLabel = Instance.new("TextLabel")
    trialLabel.Size = UDim2.fromScale(1, 1)
    trialLabel.BackgroundTransparency = 1
    trialLabel.Text = "ИСПЫТАНИЕ ПРИЗМЫ\\nЛазурный → Розовый → Золотой\\nЗатем победи Хранителя"
    trialLabel.TextColor3 = Color3.fromRGB(239, 226, 255)
    trialLabel.TextScaled = true
    trialLabel.TextWrapped = true
    trialLabel.Font = Enum.Font.GothamBlack
    trialLabel.Parent = trialGui

    -- Ancient Heights becomes reachable after the trial; its full biome is a later slice.
    local ancient = Instance.new("Folder")
    ancient.Name = "AncientHeights"
    ancient.Parent = world
    part(ancient, "AncientFloatingFoundation", Vector3.new(105, 24, 105),
        Vector3.new(0, -1, 2600), Color3.fromRGB(91, 86, 75), Enum.Material.Rock, Enum.PartType.Ball)
    local ancientTop = part(ancient, "AncientLanding", Vector3.new(7, 90, 90),
        Vector3.new(0, 14, 2600), Color3.fromRGB(180, 164, 128), Enum.Material.Slate, Enum.PartType.Cylinder)
    ancientTop.CFrame = CFrame.new(0, 14, 2600) * CFrame.Angles(0, 0, math.rad(90))
    part(ancient, "AncientArrivalPad", Vector3.new(26, 1, 26),
        Vector3.new(0, 18, 2600), Color3.fromRGB(211, 193, 145), Enum.Material.Sandstone)
    makeBiomePortal(crystal, "AncientHeightsPortal", Vector3.new(50, 29, 2080),
        Color3.fromRGB(255, 219, 143), "AncientHeights", Vector3.new(0, 21, 2600))
    makeBiomePortal(ancient, "AncientReturnPortal", Vector3.new(0, 23, 2560),
        Color3.fromRGB(190, 170, 255), "CrystalRealm", Vector3.new(0, 30, 2080))
    local ancientSign = part(ancient, "AncientWelcomeSign", Vector3.new(26, 9, 1),
        Vector3.new(0, 28, 2642), Color3.fromRGB(76, 67, 57), Enum.Material.WoodPlanks)
    ancientSign.CanCollide = false
    local ancientGui = Instance.new("SurfaceGui")
    ancientGui.Face = Enum.NormalId.Front
    ancientGui.Parent = ancientSign
    local ancientLabel = Instance.new("TextLabel")
    ancientLabel.Size = UDim2.fromScale(1, 1)
    ancientLabel.BackgroundTransparency = 1
    ancientLabel.Text = "ДРЕВНИЕ ВЫСОТЫ\\nПервая площадка открыта"
    ancientLabel.TextColor3 = Color3.fromRGB(255, 238, 197)
    ancientLabel.TextScaled = true
    ancientLabel.TextWrapped = true
    ancientLabel.Font = Enum.Font.GothamBlack
    ancientLabel.Parent = ancientGui


    -- Ancient Heights exploration slice: an old canopy sanctuary with ruins,
    -- walkable garden paths and its own collectible Ancient Egg.
    local ancientGarden = Instance.new("Folder")
    ancientGarden.Name = "ElderCanopy"
    ancientGarden.Parent = ancient

    local path = part(ancientGarden, "ElderStonePath", Vector3.new(12, 1.2, 68),
        Vector3.new(0, 19.1, 2604), Color3.fromRGB(150, 133, 105), Enum.Material.Slate)
    path.CanCollide = true

    local elderwoodNodes = Instance.new("Folder")
    elderwoodNodes.Name = "ElderwoodNodes"
    elderwoodNodes.Parent = ancient
    local elderwoodPositions = {
        Vector3.new(-17, 20.2, 2585), Vector3.new(17, 20.2, 2585),
        Vector3.new(-19, 20.2, 2602), Vector3.new(19, 20.2, 2602),
        Vector3.new(0, 20.2, 2618), Vector3.new(0, 20.2, 2571),
    }
    for index, position in ipairs(elderwoodPositions) do
        local rootNode = part(elderwoodNodes, "ElderwoodNode_" .. index,
            Vector3.new(3.4, 1.8, 3.4), position,
            Color3.fromRGB(108, 133, 79), Enum.Material.Wood, Enum.PartType.Ball)
        rootNode:SetAttribute("ElderwoodNodeId", "ElderRoot_" .. index)
        local glow = part(elderwoodNodes, "ElderwoodGlow_" .. index,
            Vector3.new(1.15, 1.15, 1.15), position + Vector3.new(0, 1.1, 0),
            Color3.fromRGB(183, 226, 132), Enum.Material.Neon, Enum.PartType.Ball)
        glow.CanCollide = false
        glow.CanTouch = false
        glow.CanQuery = false
        local light = Instance.new("PointLight")
        light.Color = glow.Color
        light.Range = 9
        light.Brightness = 0.65
        light.Parent = glow
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "HarvestElderwoodPrompt"
        prompt.ActionText = "Собрать"
        prompt.ObjectText = "Древний корень"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.7
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Parent = rootNode
    end

    for index = 1, 8 do
        local side = index % 2 == 0 and -1 or 1
        local z = 2572 + math.floor((index - 1) / 2) * 17
        local trunkHeight = 13 + (index % 3) * 3
        local trunk = part(ancientGarden, "ElderTreeTrunk_" .. index,
            Vector3.new(3.2, trunkHeight, 3.2), Vector3.new(side * (27 + (index % 2) * 4), 18.5 + trunkHeight / 2, z),
            Color3.fromRGB(102, 79, 58), Enum.Material.Wood)
        local canopy = part(ancientGarden, "ElderTreeCanopy_" .. index,
            Vector3.new(15, 12, 15), trunk.Position + Vector3.new(0, trunkHeight / 2 + 5, 0),
            index % 2 == 0 and Color3.fromRGB(104, 153, 93) or Color3.fromRGB(128, 171, 103),
            Enum.Material.Grass, Enum.PartType.Ball)
        canopy.CanCollide = false
    end

    local ruinFolder = Instance.new("Folder")
    ruinFolder.Name = "ElderRuins"
    ruinFolder.Parent = ancientGarden
    for index = 1, 6 do
        local angle = index * math.pi * 2 / 6
        local position = Vector3.new(math.cos(angle) * 37, 18.5, 2600 + math.sin(angle) * 37)
        local pillar = part(ruinFolder, "AncientPillar_" .. index,
            Vector3.new(4, 13 + (index % 3) * 2, 4),
            position + Vector3.new(0, 6.5, 0), Color3.fromRGB(132, 119, 95), Enum.Material.Rock)
        pillar.CFrame *= CFrame.Angles(0, math.rad(index * 13), math.rad((index % 2 == 0) and 2 or -2))
        local rune = part(ruinFolder, "AncientRune_" .. index,
            Vector3.new(0.45, 3.5, 0.45), position + Vector3.new(0, 7, 2.1),
            Color3.fromRGB(182, 223, 143), Enum.Material.Neon)
        rune.CanCollide = false
        if index % 2 == 0 then
            local light = Instance.new("PointLight")
            light.Color = rune.Color
            light.Range = 10
            light.Brightness = 0.45
            light.Parent = rune
        end
    end

    local ancientEggs = Instance.new("Folder")
    ancientEggs.Name = "EggSpawnPoints"
    ancientEggs.Parent = ancient
    local ancientEggPositions = {
        Vector3.new(-22, 21, 2580), Vector3.new(22, 21, 2580),
        Vector3.new(0, 21, 2620), Vector3.new(-30, 21, 2600),
        Vector3.new(30, 21, 2600),
    }
    for index, position in ipairs(ancientEggPositions) do
        local egg = part(ancientEggs, "AncientEgg_" .. index, Vector3.new(4.5, 5.2, 4.5),
            position, Color3.fromRGB(183, 220, 143), Enum.Material.Neon, Enum.PartType.Ball)
        egg:SetAttribute("WorldEgg", true)
        egg:SetAttribute("BiomeId", "AncientHeights")
        egg:SetAttribute("EggId", "AncientEgg")
        local glow = Instance.new("PointLight")
        glow.Color = Color3.fromRGB(194, 236, 151)
        glow.Range = 14
        glow.Brightness = 1.25
        glow.Parent = egg
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CollectEggPrompt"
        prompt.ActionText = "Собрать"
        prompt.ObjectText = "Яйцо древнего древа"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.5
        prompt.MaxActivationDistance = 11
        prompt.RequiresLineOfSight = false
        prompt.Parent = egg
    end

    local ancientOddsSign = part(ancient, "AncientEggOddsSign", Vector3.new(31, 10, 1),
        Vector3.new(0, 27, 2640), Color3.fromRGB(77, 75, 57), Enum.Material.WoodPlanks)
    ancientOddsSign.CanCollide = false
    local ancientOddsGui = Instance.new("SurfaceGui")
    ancientOddsGui.Face = Enum.NormalId.Front
    ancientOddsGui.Parent = ancientOddsSign
    local ancientOddsText = Instance.new("TextLabel")
    ancientOddsText.Size = UDim2.fromScale(1, 1)
    ancientOddsText.BackgroundTransparency = 1
    ancientOddsText.Text = "ЯЙЦО ДРЕВНЕГО ДРЕВА\\nОлень-древень · 55%\\nДух корней · 30%\\nНебесный змей · 15%"
    ancientOddsText.TextColor3 = Color3.fromRGB(235, 239, 201)
    ancientOddsText.TextScaled = true
    ancientOddsText.TextWrapped = true
    ancientOddsText.Font = Enum.Font.GothamBlack
    ancientOddsText.Parent = ancientOddsGui

    -- Resource sink: a visible Elderwood workbench crafts one Ancient Egg.
    local elderwoodWorkshop = Instance.new("Folder")
    elderwoodWorkshop.Name = "ElderwoodWorkshop"
    elderwoodWorkshop.Parent = ancient
    local workbench = part(elderwoodWorkshop, "AncientEggCraftingStation",
        Vector3.new(9, 2.2, 5), Vector3.new(-29, 20.8, 2630),
        Color3.fromRGB(111, 83, 57), Enum.Material.WoodPlanks)
    local benchLegs = {
        Vector3.new(-3.4, -1.5, -1.6), Vector3.new(3.4, -1.5, -1.6),
        Vector3.new(-3.4, -1.5, 1.6), Vector3.new(3.4, -1.5, 1.6),
    }
    for index, offset in ipairs(benchLegs) do
        part(elderwoodWorkshop, "WorkshopLeg_" .. index, Vector3.new(0.8, 2.2, 0.8),
            workbench.Position + offset + Vector3.new(0, -0.7, 0), Color3.fromRGB(82, 61, 44), Enum.Material.Wood)
    end
    local workbenchCrystal = part(elderwoodWorkshop, "AncientEggCraftingCrystal",
        Vector3.new(2.2, 3.2, 2.2), workbench.Position + Vector3.new(0, 2.6, 0),
        Color3.fromRGB(190, 237, 140), Enum.Material.Neon, Enum.PartType.Ball)
    workbenchCrystal.CanCollide = false
    local workbenchLight = Instance.new("PointLight")
    workbenchLight.Color = workbenchCrystal.Color
    workbenchLight.Range = 12
    workbenchLight.Brightness = 1
    workbenchLight.Parent = workbenchCrystal
    local craftPrompt = Instance.new("ProximityPrompt")
    craftPrompt.Name = "CraftAncientEggPrompt"
    craftPrompt.ActionText = "Создать яйцо"
    craftPrompt.ObjectText = "Мастерская древнего древа"
    craftPrompt.KeyboardKeyCode = Enum.KeyCode.E
    craftPrompt.HoldDuration = 1
    craftPrompt.MaxActivationDistance = 11
    craftPrompt.RequiresLineOfSight = false
    craftPrompt.Parent = workbench
    local recipeSign = part(elderwoodWorkshop, "AncientEggRecipeSign",
        Vector3.new(14, 6, 1), Vector3.new(-29, 26, 2637),
        Color3.fromRGB(65, 78, 55), Enum.Material.WoodPlanks)
    recipeSign.CanCollide = false
    local recipeGui = Instance.new("SurfaceGui")
    recipeGui.Face = Enum.NormalId.Front
    recipeGui.Parent = recipeSign
    local recipeLabel = Instance.new("TextLabel")
    recipeLabel.Size = UDim2.fromScale(1, 1)
    recipeLabel.BackgroundTransparency = 1
    recipeLabel.Text = "РЕЦЕПТ ДРЕВНОГО ЯЙЦА\\n10 эссенции · 5 лунных лепестков\\n3 звёздных осколка · 300 монет"
    recipeLabel.TextColor3 = Color3.fromRGB(230, 241, 198)
    recipeLabel.TextScaled = true
    recipeLabel.TextWrapped = true
    recipeLabel.Font = Enum.Font.GothamBlack
    recipeLabel.Parent = recipeGui

    -- Temple of the Ancient Tree: a side-island reached by a solid stone causeway.
    local ancientTemple = Instance.new("Folder")
    ancientTemple.Name = "AncientTreeTemple"
    ancientTemple.Parent = ancient
    local templeFoundation = part(ancientTemple, "TempleFloatingFoundation",
        Vector3.new(62, 18, 58), Vector3.new(78, 8, 2600),
        Color3.fromRGB(75, 83, 67), Enum.Material.Rock, Enum.PartType.Ball)
    templeFoundation.CanCollide = false
    local templeApproach = part(ancientTemple, "TempleCauseway",
        Vector3.new(22, 2, 18), Vector3.new(43, 19.5, 2600),
        Color3.fromRGB(133, 126, 103), Enum.Material.Slate)
    for index = 1, 3 do
        local inlay = part(ancientTemple, "CausewayRune_" .. index,
            Vector3.new(1.1, 0.18, 12), Vector3.new(37 + index * 5, 20.6, 2600),
            Color3.fromRGB(174, 218, 133), Enum.Material.Neon)
        inlay.CanCollide = false
    end

    local templeFloor = part(ancientTemple, "TempleSanctuaryFloor",
        Vector3.new(52, 2, 48), Vector3.new(78, 20.5, 2600),
        Color3.fromRGB(143, 137, 112), Enum.Material.Slate)
    templeFloor:SetAttribute("TempleWalkable", true)
    local templeColors = {
        Stone = Color3.fromRGB(104, 111, 88),
        Rune = Color3.fromRGB(181, 226, 139),
        Gold = Color3.fromRGB(224, 190, 111),
    }
    local columnPositions = {
        Vector3.new(55, 28, 2583), Vector3.new(101, 28, 2583),
        Vector3.new(55, 28, 2617), Vector3.new(101, 28, 2617),
    }
    for index, position in ipairs(columnPositions) do
        local column = part(ancientTemple, "TemplePillar_" .. index,
            Vector3.new(5, 16, 5), position, templeColors.Stone, Enum.Material.Rock)
        local capital = part(ancientTemple, "TemplePillarCapital_" .. index,
            Vector3.new(7, 1.8, 7), position + Vector3.new(0, 8.4, 0),
            Color3.fromRGB(169, 157, 122), Enum.Material.Slate)
        local base = part(ancientTemple, "TemplePillarBase_" .. index,
            Vector3.new(7, 1.8, 7), position - Vector3.new(0, 8.4, 0),
            Color3.fromRGB(169, 157, 122), Enum.Material.Slate)
    end
    local lintel = part(ancientTemple, "TempleEntranceLintel",
        Vector3.new(52, 4, 5), Vector3.new(78, 37, 2583),
        Color3.fromRGB(121, 119, 94), Enum.Material.Rock)
    local rearWall = part(ancientTemple, "TempleRearWall",
        Vector3.new(4, 15, 40), Vector3.new(103, 28, 2600),
        Color3.fromRGB(101, 108, 87), Enum.Material.Rock)
    local roof = part(ancientTemple, "TempleCanopyRoof",
        Vector3.new(54, 3, 50), Vector3.new(78, 39.5, 2600),
        Color3.fromRGB(86, 105, 78), Enum.Material.Slate)
    roof.Transparency = 0.2
    roof.CanCollide = false

    local templeHeader = part(ancientTemple, "TempleWelcomeInscription",
        Vector3.new(25, 7, 1), Vector3.new(54.8, 29, 2600),
        Color3.fromRGB(65, 78, 57), Enum.Material.WoodPlanks)
    templeHeader.CFrame *= CFrame.Angles(0, math.rad(90), 0)
    templeHeader.CanCollide = false
    local headerGui = Instance.new("SurfaceGui")
    headerGui.Face = Enum.NormalId.Front
    headerGui.Parent = templeHeader
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.fromScale(1, 1)
    headerText.BackgroundTransparency = 1
    headerText.Text = "ХРАМ ДРЕВНЕГО ДРЕВА\\nТри руны пробудят сердце"
    headerText.TextColor3 = Color3.fromRGB(231, 242, 194)
    headerText.TextScaled = true
    headerText.TextWrapped = true
    headerText.Font = Enum.Font.GothamBlack
    headerText.Parent = headerGui

    local templeRuneFolder = Instance.new("Folder")
    templeRuneFolder.Name = "TempleRunes"
    templeRuneFolder.Parent = ancientTemple
    local templeRuneDefinitions = {
        {Id = "Root", Name = "Руна Корней", Hint = "Корни помнят начало", Position = Vector3.new(66, 25, 2590), Color = Color3.fromRGB(153, 211, 113)},
        {Id = "River", Name = "Руна Реки", Hint = "Река несёт жизнь", Position = Vector3.new(90, 25, 2590), Color = Color3.fromRGB(111, 202, 190)},
        {Id = "Dawn", Name = "Руна Рассвета", Hint = "Рассвет завершает круг", Position = Vector3.new(78, 25, 2610), Color = Color3.fromRGB(246, 207, 126)},
    }
    for index, definition in ipairs(templeRuneDefinitions) do
        local pedestal = part(templeRuneFolder, definition.Id .. "RunePedestal",
            Vector3.new(7, 2.5, 7), definition.Position - Vector3.new(0, 2.1, 0),
            Color3.fromRGB(85, 91, 72), Enum.Material.Slate)
        local rune = part(templeRuneFolder, definition.Id .. "RuneStone",
            Vector3.new(3, 4.2, 1.4), definition.Position,
            definition.Color, Enum.Material.Neon, Enum.PartType.Block)
        rune.CanCollide = false
        rune:SetAttribute("TempleRuneId", definition.Id)
        local runeLight = Instance.new("PointLight")
        runeLight.Color = definition.Color
        runeLight.Range = 13
        runeLight.Brightness = 1
        runeLight.Parent = rune
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "AncientTempleRunePrompt"
        prompt.ActionText = "Пробудить"
        prompt.ObjectText = definition.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.6
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Parent = rune
        pedestal:SetAttribute("TempleRuneId", definition.Id)
    end

    local templeClue = part(ancientTemple, "AncientTempleClueSign",
        Vector3.new(17, 6, 1), Vector3.new(61, 26, 2603),
        Color3.fromRGB(65, 78, 57), Enum.Material.WoodPlanks)
    templeClue.CFrame *= CFrame.Angles(0, math.rad(90), 0)
    templeClue.CanCollide = false
    local clueGui = Instance.new("SurfaceGui")
    clueGui.Face = Enum.NormalId.Front
    clueGui.Parent = templeClue
    local clueText = Instance.new("TextLabel")
    clueText.Size = UDim2.fromScale(1, 1)
    clueText.BackgroundTransparency = 1
    clueText.Text = "ПОРЯДОК ПРОБУЖДЕНИЯ\\nКОРНИ → РЕКА → РАССВЕТ"
    clueText.TextColor3 = Color3.fromRGB(240, 231, 188)
    clueText.TextScaled = true
    clueText.TextWrapped = true
    clueText.Font = Enum.Font.GothamBlack
    clueText.Parent = clueGui

    local templeTreasure = Instance.new("Model")
    templeTreasure.Name = "AncientTempleTreasure"
    templeTreasure.Parent = ancientTemple
    local chestBase = part(templeTreasure, "AncientTempleChest",
        Vector3.new(8, 4, 5), Vector3.new(94, 23.5, 2615),
        Color3.fromRGB(115, 79, 48), Enum.Material.WoodPlanks)
    local chestLid = part(templeTreasure, "AncientTempleChestLid",
        Vector3.new(8.2, 1.6, 5.2), Vector3.new(94, 26.3, 2615),
        Color3.fromRGB(193, 151, 75), Enum.Material.Metal)
    chestLid.CanCollide = false
    local chestGem = part(templeTreasure, "AncientTempleChestGem",
        Vector3.new(1.5, 1.5, 1.5), Vector3.new(94, 27.5, 2612.2),
        Color3.fromRGB(190, 238, 146), Enum.Material.Neon, Enum.PartType.Ball)
    chestGem.CanCollide = false
    local chestLight = Instance.new("PointLight")
    chestLight.Color = chestGem.Color
    chestLight.Range = 12
    chestLight.Brightness = 1
    chestLight.Parent = chestGem
    local chestPrompt = Instance.new("ProximityPrompt")
    chestPrompt.Name = "AncientTempleChestPrompt"
    chestPrompt.ActionText = "Открыть"
    chestPrompt.ObjectText = "Сундук Сердца рощи"
    chestPrompt.KeyboardKeyCode = Enum.KeyCode.E
    chestPrompt.HoldDuration = 1
    chestPrompt.MaxActivationDistance = 11
    chestPrompt.RequiresLineOfSight = false
    chestPrompt.Parent = chestBase

    -- The temple guardian wakes for each player only after their own rune trial.
    local templeGuardian = Instance.new("Model")
    templeGuardian.Name = "AncientTempleGuardian"
    templeGuardian.Parent = ancientTemple
    local guardianBody = part(templeGuardian, "GuardianBody",
        Vector3.new(11, 14, 9), Vector3.new(78, 29, 2598),
        Color3.fromRGB(105, 91, 65), Enum.Material.Wood)
    guardianBody.CanCollide = false
    local guardianHead = part(templeGuardian, "GuardianHead",
        Vector3.new(8, 7, 7), Vector3.new(78, 38, 2598),
        Color3.fromRGB(126, 111, 76), Enum.Material.Wood, Enum.PartType.Ball)
    guardianHead.CanCollide = false
    local guardianCore = part(templeGuardian, "GuardianHeartCore",
        Vector3.new(4, 4, 2), Vector3.new(78, 30, 2592.8),
        Color3.fromRGB(190, 239, 133), Enum.Material.Neon, Enum.PartType.Ball)
    guardianCore.CanCollide = false
    local guardianLight = Instance.new("PointLight")
    guardianLight.Color = guardianCore.Color
    guardianLight.Range = 28
    guardianLight.Brightness = 2
    guardianLight.Parent = guardianCore
    local guardianEffectAttachment = Instance.new("Attachment")
    guardianEffectAttachment.Name = "GuardianEffectAttachment"
    guardianEffectAttachment.Parent = guardianCore
    local guardianBurst = Instance.new("ParticleEmitter")
    guardianBurst.Name = "GuardianWindupBurst"
    guardianBurst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    guardianBurst.Enabled = false
    guardianBurst.Rate = 0
    guardianBurst.Lifetime = NumberRange.new(0.45, 0.9)
    guardianBurst.Speed = NumberRange.new(7, 13)
    guardianBurst.SpreadAngle = Vector2.new(180, 180)
    guardianBurst.Rotation = NumberRange.new(0, 360)
    guardianBurst.RotSpeed = NumberRange.new(-100, 100)
    guardianBurst.LightEmission = 0.8
    guardianBurst.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    guardianBurst.Parent = guardianEffectAttachment
    for side = -1, 1, 2 do
        local arm = part(templeGuardian, "GuardianArm_" .. side,
            Vector3.new(4, 10, 5), Vector3.new(78 + side * 8, 28, 2598),
            Color3.fromRGB(93, 111, 70), Enum.Material.Wood, Enum.PartType.Ball)
        arm.CanCollide = false
        local branch = part(templeGuardian, "GuardianBranch_" .. side,
            Vector3.new(2, 9, 2), Vector3.new(78 + side * 4, 44, 2598),
            Color3.fromRGB(113, 145, 82), Enum.Material.Wood, Enum.PartType.Wedge)
        branch.CFrame *= CFrame.Angles(0, 0, math.rad(side * 28))
        branch.CanCollide = false
        local leg = part(templeGuardian, "GuardianRootLeg_" .. side,
            Vector3.new(4, 7, 4), Vector3.new(78 + side * 3, 19, 2598),
            Color3.fromRGB(83, 74, 56), Enum.Material.Wood, Enum.PartType.Ball)
        leg.CanCollide = false
    end
    for index = 1, 5 do
        local angle = (index - 1) * math.pi * 2 / 5
        local leaf = part(templeGuardian, "GuardianCrownLeaf_" .. index,
            Vector3.new(2.2, 5.5, 1.8),
            Vector3.new(78 + math.cos(angle) * 4, 43, 2598 + math.sin(angle) * 4),
            index % 2 == 0 and Color3.fromRGB(128, 177, 91) or Color3.fromRGB(169, 201, 111),
            Enum.Material.Grass, Enum.PartType.Wedge)
        leaf.CFrame *= CFrame.Angles(0, -angle, math.rad(-18))
        leaf.CanCollide = false
    end
    local guardianPrompt = Instance.new("ProximityPrompt")
    guardianPrompt.Name = "AncientTempleBossPrompt"
    guardianPrompt.ActionText = "Ударить"
    guardianPrompt.ObjectText = "Страж Сердца Древа"
    guardianPrompt.KeyboardKeyCode = Enum.KeyCode.E
    guardianPrompt.HoldDuration = 0.35
    guardianPrompt.MaxActivationDistance = 12
    guardianPrompt.RequiresLineOfSight = false
    guardianPrompt.Parent = guardianCore

    -- A tucked-away ledge beyond the welcome sign rewards players who explore.
    local whisperingGrove = Instance.new("Folder")
    whisperingGrove.Name = "WhisperingGrove"
    whisperingGrove.Parent = ancient

    local steppingStones = {
        Vector3.new(0, 19.2, 2648),
        Vector3.new(5, 19.5, 2654),
        Vector3.new(10, 19.8, 2660),
        Vector3.new(15, 20.1, 2666),
    }
    for index, position in ipairs(steppingStones) do
        local stone = part(whisperingGrove, "GroveStep_" .. index,
            Vector3.new(7, 1.1, 6), position,
            Color3.fromRGB(143, 155, 117), Enum.Material.Slate)
        stone.CFrame *= CFrame.Angles(0, math.rad(index * 9), 0)
        local marker = part(whisperingGrove, "GroveStepGlow_" .. index,
            Vector3.new(0.35, 0.35, 3.2), position + Vector3.new(0, 0.65, 0),
            Color3.fromRGB(179, 224, 132), Enum.Material.Neon)
        marker.CanCollide = false
        marker.CanTouch = false
        marker.CanQuery = false
    end

    local groveRock = part(whisperingGrove, "WhisperingGroveFloatingRock",
        Vector3.new(38, 14, 36), Vector3.new(18, 10, 2680),
        Color3.fromRGB(83, 91, 73), Enum.Material.Rock, Enum.PartType.Ball)
    groveRock.CanCollide = false
    local grovePlatform = part(whisperingGrove, "WhisperingGrovePlatform",
        Vector3.new(38, 2, 36), Vector3.new(18, 18.5, 2680),
        Color3.fromRGB(117, 145, 95), Enum.Material.Grass)
    grovePlatform.CanCollide = true

    for index = 1, 4 do
        local angle = index * math.pi / 2
        local offset = Vector3.new(math.cos(angle) * 12, 0, math.sin(angle) * 12)
        local pillar = part(whisperingGrove, "GrovePillar_" .. index,
            Vector3.new(2.4, 8, 2.4), Vector3.new(18, 22.5, 2680) + offset,
            Color3.fromRGB(116, 105, 78), Enum.Material.Rock)
        local rune = part(whisperingGrove, "GroveRune_" .. index,
            Vector3.new(0.35, 4.2, 0.35), pillar.Position + Vector3.new(0, 0.2, 1.25),
            Color3.fromRGB(185, 235, 143), Enum.Material.Neon)
        rune.CanCollide = false
        rune.CanTouch = false
        rune.CanQuery = false
        local light = Instance.new("PointLight")
        light.Color = rune.Color
        light.Range = 12
        light.Brightness = 0.75
        light.Parent = rune
    end

    local elderHeart = part(whisperingGrove, "ElderHeartAltar",
        Vector3.new(5, 3, 5), Vector3.new(18, 20.8, 2680),
        Color3.fromRGB(119, 91, 65), Enum.Material.Wood)
    local heartCrystal = part(whisperingGrove, "ElderHeartCrystal",
        Vector3.new(2.2, 3.2, 2.2), elderHeart.Position + Vector3.new(0, 2.5, 0),
        Color3.fromRGB(190, 237, 140), Enum.Material.Neon, Enum.PartType.Ball)
    heartCrystal.CanCollide = false
    local heartLight = Instance.new("PointLight")
    heartLight.Color = heartCrystal.Color
    heartLight.Range = 18
    heartLight.Brightness = 1.4
    heartLight.Parent = heartCrystal
    local heartPrompt = Instance.new("ProximityPrompt")
    heartPrompt.Name = "ElderHeartPrompt"
    heartPrompt.ActionText = "Пробудить"
    heartPrompt.ObjectText = "Сердце древней рощи"
    heartPrompt.KeyboardKeyCode = Enum.KeyCode.E
    heartPrompt.HoldDuration = 1.2
    heartPrompt.MaxActivationDistance = 10
    heartPrompt.RequiresLineOfSight = false
    heartPrompt.Parent = elderHeart

    -- A second, optional grove secret: four runes reveal a cache hidden behind the altar.
    local groveCacheRunes = {
        { Id = "Moon", Name = "Луна", Color = Color3.fromRGB(176, 190, 255), Offset = Vector3.new(-7, 0, -7) },
        { Id = "Leaf", Name = "Лист", Color = Color3.fromRGB(154, 224, 125), Offset = Vector3.new(7, 0, -7) },
        { Id = "Dew", Name = "Роса", Color = Color3.fromRGB(126, 215, 235), Offset = Vector3.new(7, 0, 7) },
        { Id = "Star", Name = "Звезда", Color = Color3.fromRGB(255, 218, 135), Offset = Vector3.new(-7, 0, 7) },
    }
    for index, definition in ipairs(groveCacheRunes) do
        local runePosition = Vector3.new(18, 20.1, 2680) + definition.Offset
        local runeStone = part(whisperingGrove, "GroveCacheRune_" .. definition.Id,
            Vector3.new(2.6, 0.8, 2.6), runePosition,
            Color3.fromRGB(75, 88, 65), Enum.Material.Slate, Enum.PartType.Cylinder)
        runeStone:SetAttribute("GroveCacheRuneId", definition.Id)
        local runeGlow = part(whisperingGrove, "GroveCacheRuneGlow_" .. definition.Id,
            Vector3.new(1.35, 0.22, 1.35), runePosition + Vector3.new(0, 0.52, 0),
            definition.Color, Enum.Material.Neon, Enum.PartType.Cylinder)
        runeGlow.CanCollide = false
        runeGlow.CanTouch = false
        runeGlow.CanQuery = false
        local runeLight = Instance.new("PointLight")
        runeLight.Color = definition.Color
        runeLight.Range = 7
        runeLight.Brightness = 0.55
        runeLight.Parent = runeGlow
        local runePrompt = Instance.new("ProximityPrompt")
        runePrompt.Name = "GroveCacheRunePrompt"
        runePrompt.ActionText = "Коснуться"
        runePrompt.ObjectText = "Руна: " .. definition.Name
        runePrompt.KeyboardKeyCode = Enum.KeyCode.E
        runePrompt.HoldDuration = 0.35
        runePrompt.MaxActivationDistance = 8
        runePrompt.RequiresLineOfSight = false
        runePrompt.Parent = runeStone
    end

    local hiddenCache = Instance.new("Model")
    hiddenCache.Name = "WhisperingGroveCache"
    hiddenCache.Parent = whisperingGrove
    local cacheBase = part(hiddenCache, "WhisperingGroveCacheBase",
        Vector3.new(5, 2.8, 4), Vector3.new(18, 20.2, 2691),
        Color3.fromRGB(86, 72, 56), Enum.Material.WoodPlanks)
    local cacheLid = part(hiddenCache, "WhisperingGroveCacheLid",
        Vector3.new(5.2, 1.1, 4.2), Vector3.new(18, 22.1, 2691),
        Color3.fromRGB(128, 101, 68), Enum.Material.Wood)
    cacheLid.CanCollide = false
    local cacheGem = part(hiddenCache, "WhisperingGroveCacheGem",
        Vector3.new(1.2, 1.2, 1.2), Vector3.new(18, 23.1, 2689),
        Color3.fromRGB(176, 190, 255), Enum.Material.Neon, Enum.PartType.Ball)
    cacheGem.CanCollide = false
    local cacheLight = Instance.new("PointLight")
    cacheLight.Color = cacheGem.Color
    cacheLight.Range = 11
    cacheLight.Brightness = 0.8
    cacheLight.Parent = cacheGem
    local cachePrompt = Instance.new("ProximityPrompt")
    cachePrompt.Name = "WhisperingGroveCachePrompt"
    cachePrompt.ActionText = "Открыть"
    cachePrompt.ObjectText = "Тайник четырёх рун"
    cachePrompt.KeyboardKeyCode = Enum.KeyCode.E
    cachePrompt.HoldDuration = 0.9
    cachePrompt.MaxActivationDistance = 9
    cachePrompt.RequiresLineOfSight = false
    cachePrompt.Parent = cacheBase

    local groveSign = part(whisperingGrove, "WhisperingGroveSign",
        Vector3.new(18, 6, 1), Vector3.new(18, 25, 2700),
        Color3.fromRGB(66, 77, 55), Enum.Material.WoodPlanks)
    groveSign.CanCollide = false
    local groveGui = Instance.new("SurfaceGui")
    groveGui.Face = Enum.NormalId.Front
    groveGui.Parent = groveSign
    local groveLabel = Instance.new("TextLabel")
    groveLabel.Size = UDim2.fromScale(1, 1)
    groveLabel.BackgroundTransparency = 1
    groveLabel.Text = "ШЁПОТ ДРЕВНЕЙ РОЩИ\\nНайди её сердце\\nЛУНА → ЛИСТ → РОСА → ЗВЕЗДА"
    groveLabel.TextColor3 = Color3.fromRGB(224, 241, 192)
    groveLabel.TextScaled = true
    groveLabel.TextWrapped = true
    groveLabel.Font = Enum.Font.GothamBlack
    groveLabel.Parent = groveGui

    -- Forgotten Heart Cave: a small traversable side dungeon with its own crystal puzzle.
    local forgottenCave = Instance.new("Folder")
    forgottenCave.Name = "ForgottenHeartCave"
    forgottenCave.Parent = ancient

    local caveIsland = part(forgottenCave, "ForgottenCaveFloatingRock",
        Vector3.new(108, 20, 88), Vector3.new(145, 7, 2600),
        Color3.fromRGB(69, 74, 73), Enum.Material.Rock, Enum.PartType.Ball)
    caveIsland.CanCollide = false
    local caveFloor = part(forgottenCave, "ForgottenCaveFloor",
        Vector3.new(96, 2, 76), Vector3.new(145, 18, 2600),
        Color3.fromRGB(76, 83, 82), Enum.Material.Slate)
    local caveBridge = part(forgottenCave, "ForgottenCaveBridge",
        Vector3.new(66, 1.4, 9), Vector3.new(62, 19, 2600),
        Color3.fromRGB(117, 111, 96), Enum.Material.Slate)
    for index = 1, 9 do
        local railX = 30 + index * 7
        for _, side in ipairs({-1, 1}) do
            local rail = part(forgottenCave, "CaveBridgeRail_" .. index .. "_" .. side,
                Vector3.new(0.8, 2.4, 0.8), Vector3.new(railX, 20.5, 2600 + side * 4.2),
                Color3.fromRGB(93, 83, 68), Enum.Material.Wood)
            rail.CanCollide = true
        end
    end

    local caveWalls = {
        { Name = "CaveNorthWall", Size = Vector3.new(96, 24, 5), Position = Vector3.new(145, 30, 2562) },
        { Name = "CaveSouthWall", Size = Vector3.new(96, 24, 5), Position = Vector3.new(145, 30, 2638) },
        { Name = "CaveBackWall", Size = Vector3.new(5, 24, 81), Position = Vector3.new(192, 30, 2600) },
        { Name = "CaveEntryLeft", Size = Vector3.new(5, 24, 25), Position = Vector3.new(98, 30, 2574) },
        { Name = "CaveEntryRight", Size = Vector3.new(5, 24, 25), Position = Vector3.new(98, 30, 2626) },
    }
    for _, wall in ipairs(caveWalls) do
        local stoneWall = part(forgottenCave, wall.Name, wall.Size, wall.Position,
            Color3.fromRGB(78, 82, 78), Enum.Material.Rock)
        stoneWall.CanCollide = true
    end
    local caveCeiling = part(forgottenCave, "ForgottenCaveCeiling",
        Vector3.new(96, 5, 76), Vector3.new(145, 43, 2600),
        Color3.fromRGB(57, 62, 61), Enum.Material.Rock)
    caveCeiling.CanCollide = false
    for index = 1, 7 do
        local x = 106 + index * 11
        local stalactite = part(forgottenCave, "CaveStalactite_" .. index,
            Vector3.new(2.4, 7 + (index % 3) * 2, 2.4), Vector3.new(x, 38, 2570 + (index % 2) * 60),
            Color3.fromRGB(92, 96, 91), Enum.Material.Rock, Enum.PartType.Ball)
        stalactite.CanCollide = false
    end

    local caveCrystalDefinitions = {
        { Id = "Root", Name = "Корень", Position = Vector3.new(124, 20.5, 2584), Color = Color3.fromRGB(157, 220, 115) },
        { Id = "River", Name = "Река", Position = Vector3.new(145, 20.5, 2614), Color = Color3.fromRGB(111, 204, 231) },
        { Id = "Dawn", Name = "Рассвет", Position = Vector3.new(166, 20.5, 2584), Color = Color3.fromRGB(255, 190, 111) },
    }
    for _, definition in ipairs(caveCrystalDefinitions) do
        local crystal = part(forgottenCave, "CaveCrystal_" .. definition.Id,
            Vector3.new(3.2, 5.2, 3.2), definition.Position,
            definition.Color, Enum.Material.Neon, Enum.PartType.Ball)
        crystal:SetAttribute("CaveCrystalId", definition.Id)
        crystal.CanCollide = false
        local light = Instance.new("PointLight")
        light.Color = definition.Color
        light.Range = 13
        light.Brightness = 1.1
        light.Parent = crystal
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CaveCrystalPrompt"
        prompt.ActionText = "Коснуться"
        prompt.ObjectText = "Кристалл: " .. definition.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.55
        prompt.MaxActivationDistance = 9
        prompt.RequiresLineOfSight = false
        prompt.Parent = crystal
    end

    local caveClue = part(forgottenCave, "ForgottenCaveClue",
        Vector3.new(12, 6, 1), Vector3.new(108, 25, 2600),
        Color3.fromRGB(62, 68, 63), Enum.Material.WoodPlanks)
    caveClue.CFrame *= CFrame.Angles(0, math.rad(90), 0)
    caveClue.CanCollide = false
    local caveClueGui = Instance.new("SurfaceGui")
    caveClueGui.Face = Enum.NormalId.Front
    caveClueGui.Parent = caveClue
    local caveClueText = Instance.new("TextLabel")
    caveClueText.Size = UDim2.fromScale(1, 1)
    caveClueText.BackgroundTransparency = 1
    caveClueText.Text = "СЕРДЦЕ ПЕЩЕРЫ\\nКОРЕНЬ → РЕКА → РАССВЕТ"
    caveClueText.TextColor3 = Color3.fromRGB(224, 235, 205)
    caveClueText.TextScaled = true
    caveClueText.TextWrapped = true
    caveClueText.Font = Enum.Font.GothamBlack
    caveClueText.Parent = caveClueGui

    local caveOddsSign = part(forgottenCave, "ForgottenCaveEggOddsSign",
        Vector3.new(16, 7, 1), Vector3.new(145, 25, 2635),
        Color3.fromRGB(57, 69, 78), Enum.Material.WoodPlanks)
    caveOddsSign.CanCollide = false
    local caveOddsGui = Instance.new("SurfaceGui")
    caveOddsGui.Face = Enum.NormalId.Front
    caveOddsGui.Parent = caveOddsSign
    local caveOddsText = Instance.new("TextLabel")
    caveOddsText.Size = UDim2.fromScale(1, 1)
    caveOddsText.BackgroundTransparency = 1
    caveOddsText.Text = "ЯЙЦО ЗАБЫТОГО СЕРДЦА\\nНетопырь 65% · Рысь 25%\\nСвет Сердца 10%"
    caveOddsText.TextColor3 = Color3.fromRGB(208, 235, 249)
    caveOddsText.TextScaled = true
    caveOddsText.TextWrapped = true
    caveOddsText.Font = Enum.Font.GothamBold
    caveOddsText.Parent = caveOddsGui

    local bossArena = part(forgottenCave, "ForgottenHeartBossArena",
        Vector3.new(34, 0.5, 24), Vector3.new(174, 19.25, 2599),
        Color3.fromRGB(66, 79, 87), Enum.Material.Slate)
    bossArena.CanCollide = true
    bossArena.Transparency = 0.18

    local guardian = Instance.new("Model")
    guardian.Name = "ForgottenHeartGuardian"
    guardian.Parent = forgottenCave
    local guardianBody = part(guardian, "GuardianBody",
        Vector3.new(8, 7, 7), Vector3.new(174, 24, 2600),
        Color3.fromRGB(75, 94, 111), Enum.Material.Slate, Enum.PartType.Ball)
    guardianBody.CanCollide = false
    guardian.PrimaryPart = guardianBody
    local guardianHead = part(guardian, "GuardianHead",
        Vector3.new(5.2, 4.8, 4.8), Vector3.new(174, 29.2, 2600),
        Color3.fromRGB(88, 111, 132), Enum.Material.Slate, Enum.PartType.Ball)
    guardianHead.CanCollide = false
    local guardianCore = part(guardian, "ForgottenHeartCore",
        Vector3.new(3.2, 3.2, 2.2), Vector3.new(174, 25.5, 2595.8),
        Color3.fromRGB(118, 222, 255), Enum.Material.Neon, Enum.PartType.Ball)
    guardianCore.CanCollide = false
    local guardianLight = Instance.new("PointLight")
    guardianLight.Color = Color3.fromRGB(105, 213, 255)
    guardianLight.Range = 24
    guardianLight.Brightness = 2.2
    guardianLight.Parent = guardianCore
    for _, side in ipairs({-1, 1}) do
        local arm = part(guardian, "GuardianArm_" .. side,
            Vector3.new(3.4, 7.5, 3.4), Vector3.new(174 + side * 7.1, 22.8, 2600),
            Color3.fromRGB(78, 103, 119), Enum.Material.Slate, Enum.PartType.Ball)
        arm.CanCollide = false
        local shoulder = part(guardian, "GuardianShoulderCrystal_" .. side,
            Vector3.new(2.1, 3.1, 2.1), Vector3.new(174 + side * 7.5, 27, 2599.5),
            Color3.fromRGB(155, 207, 232), Enum.Material.Neon, Enum.PartType.Wedge)
        shoulder.CanCollide = false
    end
    for index = 1, 5 do
        local angle = math.rad((index - 1) * 72)
        local shard = part(guardian, "GuardianCrownShard_" .. index,
            Vector3.new(1.4, 3.4, 1.4),
            Vector3.new(174 + math.cos(angle) * 3.2, 32.1, 2600 + math.sin(angle) * 3.2),
            Color3.fromRGB(136, 225, 255), Enum.Material.Neon, Enum.PartType.Wedge)
        shard.CanCollide = false
    end
    local bossPrompt = Instance.new("ProximityPrompt")
    bossPrompt.Name = "ForgottenHeartBossPrompt"
    bossPrompt.ActionText = "Атаковать"
    bossPrompt.ObjectText = "Хранитель забытого сердца"
    bossPrompt.KeyboardKeyCode = Enum.KeyCode.E
    bossPrompt.HoldDuration = 0.25
    bossPrompt.MaxActivationDistance = 13
    bossPrompt.RequiresLineOfSight = false
    bossPrompt.Parent = guardianCore

    local bossTitle = part(forgottenCave, "ForgottenHeartBossSign",
        Vector3.new(15, 5, 1), Vector3.new(174, 24, 2565.2),
        Color3.fromRGB(44, 58, 70), Enum.Material.Metal)
    bossTitle.CanCollide = false
    local bossTitleGui = Instance.new("SurfaceGui")
    bossTitleGui.Face = Enum.NormalId.Front
    bossTitleGui.Parent = bossTitle
    local bossTitleText = Instance.new("TextLabel")
    bossTitleText.Size = UDim2.fromScale(1, 1)
    bossTitleText.BackgroundTransparency = 1
    bossTitleText.Text = "ХРАНИТЕЛЬ\\nЗАБЫТОГО СЕРДЦА"
    bossTitleText.TextColor3 = Color3.fromRGB(185, 232, 255)
    bossTitleText.TextScaled = true
    bossTitleText.TextWrapped = true
    bossTitleText.Font = Enum.Font.GothamBlack
    bossTitleText.Parent = bossTitleGui

    local caveCache = Instance.new("Model")
    caveCache.Name = "ForgottenCaveCache"
    caveCache.Parent = forgottenCave
    local caveChest = part(caveCache, "ForgottenCaveChest",
        Vector3.new(6, 3.2, 4.5), Vector3.new(178, 20.6, 2615),
        Color3.fromRGB(92, 75, 57), Enum.Material.WoodPlanks)
    local caveChestLid = part(caveCache, "ForgottenCaveChestLid",
        Vector3.new(6.2, 1.1, 4.7), Vector3.new(178, 22.7, 2615),
        Color3.fromRGB(117, 137, 128), Enum.Material.Metal)
    caveChestLid.CanCollide = false
    local caveChestGem = part(caveCache, "ForgottenCaveChestGem",
        Vector3.new(1.6, 1.6, 1.6), Vector3.new(178, 24, 2612.6),
        Color3.fromRGB(180, 220, 255), Enum.Material.Neon, Enum.PartType.Ball)
    caveChestGem.CanCollide = false
    local chestGlow = Instance.new("PointLight")
    chestGlow.Color = caveChestGem.Color
    chestGlow.Range = 15
    chestGlow.Brightness = 1.2
    chestGlow.Parent = caveChestGem
    local rewardEgg = part(caveCache, "ForgottenCaveRewardEgg",
        Vector3.new(2.8, 3.5, 2.8), Vector3.new(178, 24.8, 2615),
        Color3.fromRGB(135, 194, 222), Enum.Material.Neon, Enum.PartType.Ball)
    rewardEgg.CanCollide = false
    local rewardEggLight = Instance.new("PointLight")
    rewardEggLight.Color = Color3.fromRGB(164, 226, 255)
    rewardEggLight.Range = 10
    rewardEggLight.Brightness = 1.1
    rewardEggLight.Parent = rewardEgg
    local caveChestPrompt = Instance.new("ProximityPrompt")
    caveChestPrompt.Name = "ForgottenCaveChestPrompt"
    caveChestPrompt.ActionText = "Открыть"
    caveChestPrompt.ObjectText = "Сокровищница забытого сердца"
    caveChestPrompt.KeyboardKeyCode = Enum.KeyCode.E
    caveChestPrompt.HoldDuration = 1
    caveChestPrompt.MaxActivationDistance = 10
    caveChestPrompt.RequiresLineOfSight = false
    caveChestPrompt.Parent = caveChest

    return world
end

return WorldBuilder
