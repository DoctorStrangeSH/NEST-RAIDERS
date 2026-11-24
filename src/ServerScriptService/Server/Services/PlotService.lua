local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PlayerDataService = require(game:GetService("ServerScriptService").Server.Services.PlayerDataService)
local IslandStyleCatalog = require(game:GetService("ReplicatedStorage").Shared.Config.IslandStyleCatalog)

local PlotService = {}
PlotService._plots = {}
PlotService._owners = {}
PlotService._playerPlots = {}

local PLOT_DEFINITIONS = {
    { Id = "Nest01", Position = Vector3.new(-72, 11, -72) },
    { Id = "Nest02", Position = Vector3.new(0, 11, -84) },
    { Id = "Nest03", Position = Vector3.new(72, 11, -72) },
    { Id = "Nest04", Position = Vector3.new(-72, 11, 72) },
    { Id = "Nest05", Position = Vector3.new(0, 11, 84) },
    { Id = "Nest06", Position = Vector3.new(72, 11, 72) },
}

local function makePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function buildPlot(parent, definition)
    local plot = Instance.new("Model")
    plot.Name = definition.Id
    plot:SetAttribute("PlotId", definition.Id)
    plot.Parent = parent

    local center = definition.Position
    makePart(plot, "PlotFoundation", Vector3.new(38, 2, 38), CFrame.new(center), Color3.fromRGB(112, 91, 70), Enum.Material.WoodPlanks)
    makePart(plot, "PlotGrass", Vector3.new(36, 0.6, 36), CFrame.new(center + Vector3.new(0, 1.3, 0)), Color3.fromRGB(119, 190, 111), Enum.Material.Grass)

    -- Permanent garden dressing stays outside the 30x30 player building grid.
    -- Every decorative part is non-collidable so it cannot trap visitors.
    local garden = Instance.new("Folder")
    garden.Name = "EnvironmentDecorations"
    garden.Parent = plot
    local groundY = center.Y + 1.62
    local function gardenPart(name, size, offset, color, material, shape, rotation)
        local part = makePart(garden, name, size,
            CFrame.new(center + offset) * (rotation or CFrame.new()),
            color, material)
        if shape then part.Shape = shape end
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        return part
    end
    local function flowerCluster(prefix, x, z, palette)
        gardenPart(prefix .. "_Soil", Vector3.new(3.2, 0.16, 1.8),
            Vector3.new(x, groundY - center.Y, z), Color3.fromRGB(91, 72, 55), Enum.Material.Ground)
        for index, offset in ipairs({
            Vector3.new(-0.9, 0.28, -0.35),
            Vector3.new(0, 0.32, 0.25),
            Vector3.new(0.9, 0.27, -0.3),
        }) do
            local stem = gardenPart(prefix .. "_Leaf_" .. index, Vector3.new(0.22, 0.55, 0.22),
                Vector3.new(x + offset.X, groundY - center.Y + offset.Y / 2, z + offset.Z),
                Color3.fromRGB(78, 151, 86), Enum.Material.Grass)
            stem.Shape = Enum.PartType.Ball
            local bloom = gardenPart(prefix .. "_Bloom_" .. index, Vector3.new(0.48, 0.34, 0.48),
                Vector3.new(x + offset.X, groundY - center.Y + offset.Y, z + offset.Z),
                palette[index], Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        end
    end
    local function gardenTree(prefix, x, z, leafColor)
        gardenPart(prefix .. "_Trunk", Vector3.new(0.72, 3.4, 0.72),
            Vector3.new(x, groundY - center.Y + 1.7, z), Color3.fromRGB(112, 78, 52), Enum.Material.Wood, Enum.PartType.Cylinder)
        gardenPart(prefix .. "_Canopy", Vector3.new(3.8, 3.3, 3.8),
            Vector3.new(x, groundY - center.Y + 3.5, z), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
        gardenPart(prefix .. "_CanopyTop", Vector3.new(2.4, 2.3, 2.4),
            Vector3.new(x + 0.35, groundY - center.Y + 4.65, z - 0.2),
            Color3.fromRGB(135, 202, 119), Enum.Material.Grass, Enum.PartType.Ball)
    end
    gardenTree("GardenTree_NW", -15.5, -15.5, Color3.fromRGB(77, 157, 91))
    gardenTree("GardenTree_NE", 15.5, -15.5, Color3.fromRGB(92, 174, 103))
    gardenTree("GardenTree_SW", -15.5, 15.5, Color3.fromRGB(92, 174, 103))
    gardenTree("GardenTree_SE", 15.5, 15.5, Color3.fromRGB(77, 157, 91))
    flowerCluster("FlowerBed_W", -16.1, 0, {
        Color3.fromRGB(244, 157, 188), Color3.fromRGB(255, 218, 127), Color3.fromRGB(174, 158, 245),
    })
    flowerCluster("FlowerBed_E", 16.1, 0, {
        Color3.fromRGB(255, 218, 127), Color3.fromRGB(174, 158, 245), Color3.fromRGB(244, 157, 188),
    })
    flowerCluster("FlowerBed_S", 0, 16.1, {
        Color3.fromRGB(174, 158, 245), Color3.fromRGB(244, 157, 188), Color3.fromRGB(255, 218, 127),
    })
    for index = 1, 5 do
        local x = -8 + (index - 1) * 4
        gardenPart("GardenPathStone_" .. index, Vector3.new(2.5, 0.18, 2.5),
            Vector3.new(x, groundY - center.Y + 0.02, 16.2),
            Color3.fromRGB(151, 146, 130), Enum.Material.Slate, Enum.PartType.Cylinder)
    end

    local nest = makePart(plot, "NestBowl", Vector3.new(2, 13, 11), CFrame.new(center + Vector3.new(0, 3, 0)), Color3.fromRGB(153, 111, 69), Enum.Material.Wood)
    nest.Shape = Enum.PartType.Cylinder
    nest.CFrame = CFrame.new(center + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))

    local station = makePart(plot, "HatchStation", Vector3.new(5, 5, 5), CFrame.new(center + Vector3.new(0, 7, 0)), Color3.fromRGB(255, 194, 83), Enum.Material.Neon)
    station.Shape = Enum.PartType.Ball
    station.Transparency = 0.15
    station:SetAttribute("PlotId", definition.Id)

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "HatchPrompt"
    prompt.ActionText = "Вылупить"
    prompt.ObjectText = "Твоё гнездо"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = station

    -- Dedicated breeding altar: a clear landmark beside the hatch station.
    local breedingBase = makePart(plot, "BreedingStationBase", Vector3.new(9, 1.2, 8),
        CFrame.new(center + Vector3.new(11, 2.3, 0)), Color3.fromRGB(126, 91, 145), Enum.Material.WoodPlanks)
    breedingBase.CanCollide = true
    local breedingRing = makePart(plot, "BreedingStationRing", Vector3.new(0.45, 6.8, 6.8),
        CFrame.new(center + Vector3.new(11, 3.05, 0)), Color3.fromRGB(177, 125, 226), Enum.Material.Neon)
    breedingRing.Shape = Enum.PartType.Cylinder
    breedingRing.CFrame = CFrame.new(center + Vector3.new(11, 3.05, 0)) * CFrame.Angles(0, 0, math.rad(90))
    breedingRing.CanCollide = false
    breedingRing.Transparency = 0.12
    local breedingCore = makePart(plot, "BreedingStation", Vector3.new(2.8, 3.6, 2.8),
        CFrame.new(center + Vector3.new(11, 5.0, 0)), Color3.fromRGB(202, 157, 255), Enum.Material.Glass)
    breedingCore.Shape = Enum.PartType.Ball
    breedingCore.Transparency = 0.18
    breedingCore:SetAttribute("PlotId", definition.Id)
    local breedingLight = Instance.new("PointLight")
    breedingLight.Name = "BreedingGlow"
    breedingLight.Color = Color3.fromRGB(194, 143, 255)
    breedingLight.Brightness = 1.4
    breedingLight.Range = 14
    breedingLight.Shadows = false
    breedingLight.Parent = breedingCore
    local breedingPrompt = Instance.new("ProximityPrompt")
    breedingPrompt.Name = "BreedingPrompt"
    breedingPrompt.ActionText = "Разведение"
    breedingPrompt.ObjectText = "Алтарь потомства"
    breedingPrompt.KeyboardKeyCode = Enum.KeyCode.E
    breedingPrompt.HoldDuration = 0.35
    breedingPrompt.MaxActivationDistance = 12
    breedingPrompt.RequiresLineOfSight = false
    breedingPrompt.Parent = breedingCore

    for index, side in ipairs({-1, 1}) do
        local parentPad = makePart(plot, "BreedingParentPad_" .. index,
            Vector3.new(0.55, 3.4, 3.4),
            CFrame.new(center + Vector3.new(11 + side * 5.1, 2.8, 0)),
            Color3.fromRGB(100, 91, 130), Enum.Material.Slate)
        parentPad.Shape = Enum.PartType.Cylinder
        parentPad.CFrame = CFrame.new(center + Vector3.new(11 + side * 5.1, 2.8, 0))
            * CFrame.Angles(0, 0, math.rad(90))
        parentPad.CanCollide = false
        parentPad:SetAttribute("ParentSlot", index)
    end

    breedingPrompt.Triggered:Connect(function(player)
        if plot:GetAttribute("OwnerUserId") ~= player.UserId then
            player:SetAttribute("LastNotice", "Этот алтарь принадлежит другому игроку.")
            return
        end
        player:SetAttribute("LastNotice", "Алтарь готов. Открой коллекцию и выбери двух взрослых питомцев для разведения.")
    end)

    local sign = makePart(plot, "OwnerSign", Vector3.new(9, 5, 1), CFrame.new(center + Vector3.new(0, 4, -14)), Color3.fromRGB(105, 72, 47), Enum.Material.Wood)
    local surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Front
    surface.Parent = sign
    local label = Instance.new("TextLabel")
    label.Name = "OwnerLabel"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "СВОБОДНОЕ ГНЕЗДО"
    label.TextColor3 = Color3.fromRGB(255, 245, 210)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.Parent = surface

    return plot, station, label
end

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local TRAIT_COLORS = {
    Natural = Color3.fromRGB(255, 220, 145),
    Verdant = Color3.fromRGB(111, 238, 139),
    Luminous = Color3.fromRGB(111, 225, 255),
    Prismatic = Color3.fromRGB(220, 132, 255),
}

local SPECIES_COLORS = {
    MeadowFox = Color3.fromRGB(255, 164, 91),
    MossTurtle = Color3.fromRGB(115, 191, 125),
    SproutDragon = Color3.fromRGB(104, 194, 222),
    EmberFox = Color3.fromRGB(255, 117, 76),
    Fernshell = Color3.fromRGB(129, 206, 123),
    BriarGuardian = Color3.fromRGB(177, 148, 104),
}

local function makeRitualOrb(parent, name, position, color, size)
    local orb = Instance.new("Part")
    orb.Name = name
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(size, size, size)
    orb.Position = position
    orb.Anchored = true
    orb.CanCollide = false
    orb.CanTouch = false
    orb.CanQuery = false
    orb.Material = Enum.Material.Neon
    orb.Color = color
    orb.Parent = parent
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = 1.8
    light.Range = 10
    light.Shadows = false
    light.Parent = orb
    return orb
end

local function tweenModelPivot(model, targetCFrame, duration)
    if not model or not model.Parent then return end
    local pivotValue = Instance.new("CFrameValue")
    pivotValue.Value = model:GetPivot()
    local connection = pivotValue:GetPropertyChangedSignal("Value"):Connect(function()
        if model.Parent then model:PivotTo(pivotValue.Value) end
    end)
    local tween = TweenService:Create(pivotValue,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        { Value = targetCFrame })
    tween.Completed:Connect(function()
        connection:Disconnect()
        pivotValue:Destroy()
    end)
    tween:Play()
end

function PlotService:PlayBreedingSequence(player, parentA, parentB, egg, previewA, previewB, previewFolder)
    local plot = self._playerPlots[player]
    local station = plot and plot.BreedingStation
    if not station or not station.Parent or not parentA or not parentB or not egg then return false end
    if plot.Model:GetAttribute("OwnerUserId") ~= player.UserId then return false end

    local effects = Instance.new("Folder")
    effects.Name = "BreedingRitual_" .. player.UserId
    effects.Parent = Workspace
    if previewFolder and previewFolder.Parent then previewFolder.Parent = effects end
    Debris:AddItem(effects, 9)

    local center = station.Position
    local leftColor = SPECIES_COLORS[parentA.Id] or Color3.fromRGB(255, 190, 115)
    local rightColor = SPECIES_COLORS[parentB.Id] or Color3.fromRGB(125, 200, 230)
    local traitColor = TRAIT_COLORS[egg.GeneticTrait and egg.GeneticTrait.Id] or TRAIT_COLORS.Natural
    local left = previewA
    local right = previewB
    if not left or not left.PrimaryPart or not right or not right.PrimaryPart then
        effects:Destroy()
        return false
    end
    left.Parent = effects
    right.Parent = effects
    left:PivotTo(CFrame.new(center + Vector3.new(-5.1, -1.0, 0)))
    right:PivotTo(CFrame.new(center + Vector3.new(5.1, -1.0, 0)))
    local leftGlow = Instance.new("PointLight")
    leftGlow.Color = leftColor
    leftGlow.Brightness = 0.9
    leftGlow.Range = 7
    leftGlow.Parent = left.PrimaryPart
    local rightGlow = Instance.new("PointLight")
    rightGlow.Color = rightColor
    rightGlow.Brightness = 0.9
    rightGlow.Range = 7
    rightGlow.Parent = right.PrimaryPart
    local core = makeRitualOrb(effects, "RitualCore", center + Vector3.new(0, 0.3, 0), traitColor, 0.45)

    local leftAttachment = Instance.new("Attachment")
    leftAttachment.Position = Vector3.new(0, 0.7, 0)
    leftAttachment.Parent = left.PrimaryPart
    local rightAttachment = Instance.new("Attachment")
    rightAttachment.Position = Vector3.new(0, 0.7, 0)
    rightAttachment.Parent = right.PrimaryPart
    local coreLeft = Instance.new("Attachment")
    coreLeft.Parent = core
    local coreRight = Instance.new("Attachment")
    coreRight.Parent = core

    local function makeEnergyBeam(name, fromAttachment, color)
        local beam = Instance.new("Beam")
        beam.Name = name
        beam.Attachment0 = fromAttachment
        beam.Attachment1 = name == "EnergyFromA" and coreLeft or coreRight
        beam.Color = ColorSequence.new(color, traitColor)
        beam.Width0 = 0.42
        beam.Width1 = 0.12
        beam.LightEmission = 1
        beam.FaceCamera = true
        beam.CurveSize0 = 1.8
        beam.CurveSize1 = -1.8
        beam.Parent = effects
        return beam
    end

    local beamA = makeEnergyBeam("EnergyFromA", leftAttachment, leftColor)
    local beamB = makeEnergyBeam("EnergyFromB", rightAttachment, rightColor)
    local eggPart = Instance.new("Part")
    eggPart.Name = "NewLineageEgg"
    eggPart.Shape = Enum.PartType.Ball
    eggPart.Size = Vector3.new(0.12, 0.16, 0.12)
    eggPart.Position = center + Vector3.new(0, 0.2, 0)
    eggPart.Anchored = true
    eggPart.CanCollide = false
    eggPart.CanTouch = false
    eggPart.CanQuery = false
    eggPart.Material = Enum.Material.Neon
    eggPart.Color = traitColor
    eggPart.Parent = effects

    local hybridShards = {}
    if egg.IsHybrid then
        for shardIndex = 1, 4 do
            local angle = (math.pi * 2 / 4) * shardIndex
            local shard = Instance.new("Part")
            shard.Name = "HybridRevealShard_" .. shardIndex
            shard.Shape = Enum.PartType.Wedge
            shard.Size = Vector3.new(0.28, 0.9, 0.28)
            shard.Position = center + Vector3.new(math.cos(angle) * 1.8, 1.5, math.sin(angle) * 1.8)
            shard.Anchored = true
            shard.CanCollide = false
            shard.CanTouch = false
            shard.CanQuery = false
            shard.Material = Enum.Material.Neon
            shard.Color = Color3.fromRGB(255, 211, 116)
            shard.Transparency = 1
            shard.Parent = effects
            table.insert(hybridShards, shard)
        end
    end

    local shellLight = Instance.new("PointLight")
    shellLight.Color = traitColor
    shellLight.Brightness = 0
    shellLight.Range = 12
    shellLight.Parent = eggPart

    local particles = Instance.new("ParticleEmitter")
    particles.Name = "RitualSparkles"
    particles.Color = ColorSequence.new(leftColor, rightColor)
    particles.LightEmission = 0.9
    particles.Rate = 0
    particles.Lifetime = NumberRange.new(0.45, 1.1)
    particles.Speed = NumberRange.new(2, 5)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.18),
        NumberSequenceKeypoint.new(1, 0),
    })
    particles.Parent = eggPart

    tweenModelPivot(left, CFrame.new(center + Vector3.new(-1.15, 0.35, 0)), 1.1)
    tweenModelPivot(right, CFrame.new(center + Vector3.new(1.15, 0.35, 0)), 1.1)

    task.delay(1.1, function()
        if not effects.Parent then return end
        TweenService:Create(eggPart, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = Vector3.new(2.1, 2.7, 2.1),
            Position = center + Vector3.new(0, 1.5, 0),
        }):Play()
        TweenService:Create(shellLight, TweenInfo.new(0.55), { Brightness = egg.IsHybrid and 3.2 or 2.2 }):Play()
        particles:Emit(egg.IsHybrid and 56 or 32)
        for _, shard in ipairs(hybridShards) do
            local direction = (shard.Position - eggPart.Position).Unit
            TweenService:Create(shard, TweenInfo.new(0.18), { Transparency = 0.12 }):Play()
            task.delay(0.22, function()
                if not shard.Parent then return end
                TweenService:Create(shard, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = shard.Position + direction * 3.5,
                    Transparency = 1,
                    Size = Vector3.new(0.05, 0.05, 0.05),
                }):Play()
            end)
        end
        left:Destroy()
        right:Destroy()
        beamA:Destroy()
        beamB:Destroy()
        core:Destroy()
    end)

    task.delay(2.8, function()
        if not effects.Parent then return end
        local burst = Instance.new("Part")
        burst.Name = "RitualBurst"
        burst.Shape = Enum.PartType.Ball
        burst.Size = Vector3.new(2, 2, 2)
        burst.Position = eggPart.Position
        burst.Anchored = true
        burst.CanCollide = false
        burst.CanTouch = false
        burst.CanQuery = false
        burst.Material = Enum.Material.Neon
        burst.Color = traitColor
        burst.Transparency = 0.2
        burst.Parent = effects
        local burstTween = TweenService:Create(burst, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(12, 12, 12),
            Transparency = 1,
        })
        burstTween:Play()
        particles:Emit(54)
        task.delay(0.2, function()
            if eggPart.Parent then eggPart:Destroy() end
        end)
    end)

    return true
end

function PlotService:ApplyNestLevel(player, level)
    local plot = self._playerPlots[player]
    if not plot then return false end

    level = math.clamp(math.floor(tonumber(level) or 1), 1, 5)
    local previous = plot.Model:FindFirstChild("UpgradeDecorations")
    if previous then previous:Destroy() end

    local decorations = Instance.new("Folder")
    decorations.Name = "UpgradeDecorations"
    decorations.Parent = plot.Model
    local center = plot.Center

    local function decor(name, size, offset, color, material, shape)
        local part = makePart(
            decorations,
            name,
            size,
            CFrame.new(center + offset),
            color,
            material
        )
        if shape then part.Shape = shape end
        part.CanCollide = false
        return part
    end

    if level >= 2 then
        for _, x in ipairs({-8, 8}) do
            local pole = decor("NestLanternPole", Vector3.new(0.35, 4, 0.35),
                Vector3.new(x, 3.2, -8), Color3.fromRGB(105, 79, 57), Enum.Material.Wood)
            local lamp = decor("NestLantern", Vector3.new(1.15, 1.15, 1.15),
                Vector3.new(x, 5.45, -8), Color3.fromRGB(255, 205, 105), Enum.Material.Neon, Enum.PartType.Ball)
            local light = Instance.new("PointLight")
            light.Name = "WarmGardenLight"
            light.Color = Color3.fromRGB(255, 197, 112)
            light.Brightness = 0.85
            light.Range = 11
            light.Shadows = false
            light.Parent = lamp
        end
        for _, offset in ipairs({Vector3.new(-14, 0.2, 5), Vector3.new(14, 0.2, 5)}) do
            local shrub = decor("LevelTwoShrub", Vector3.new(2.1, 1.5, 2.1),
                offset, Color3.fromRGB(73, 151, 88), Enum.Material.Grass, Enum.PartType.Ball)
            shrub.CanTouch = false
            shrub.CanQuery = false
        end
    end
    if level >= 3 then
        for _, x in ipairs({-12, 12}) do
            local crystal = decor("GardenCrystal", Vector3.new(1.65, 2.6, 1.65),
                Vector3.new(x, 3.2, 7), Color3.fromRGB(104, 219, 163), Enum.Material.Glass, Enum.PartType.Ball)
            crystal.Transparency = 0.12
            local glow = Instance.new("PointLight")
            glow.Name = "GardenCrystalGlow"
            glow.Color = crystal.Color
            glow.Brightness = 0.65
            glow.Range = 9
            glow.Shadows = false
            glow.Parent = crystal
        end
        for _, x in ipairs({-7, 7}) do
            decor("LevelThreeFlower", Vector3.new(1.0, 0.55, 1.0),
                Vector3.new(x, 1.95, 15), Color3.fromRGB(244, 157, 198), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
        end
    end
    if level >= 4 then
        decor("NestBannerPole", Vector3.new(0.7, 9, 0.7), Vector3.new(0, 5.5, -15), Color3.fromRGB(230, 197, 125), Enum.Material.Metal)
        decor("NestBanner", Vector3.new(4.5, 2.8, 0.3), Vector3.new(0, 8.5, -15), Color3.fromRGB(119, 151, 211), Enum.Material.Fabric)
    end
    local displayPositions = {
        Vector3.new(-12, 2.0, 12),
        Vector3.new(12, 2.0, 12),
        Vector3.new(-12, 2.0, -12),
        Vector3.new(12, 2.0, -12),
    }
    for index = 1, math.max(0, level - 1) do
        local offset = displayPositions[index]
        decor("PetDisplayPedestal", Vector3.new(4, 1, 4), offset, Color3.fromRGB(164, 131, 91), Enum.Material.Wood, Enum.PartType.Cylinder)
        local crystal = decor("PetDisplayMarker", Vector3.new(1.2, 1.2, 1.2), offset + Vector3.new(0, 1.2, 0), Color3.fromRGB(145, 225, 190), Enum.Material.Neon, Enum.PartType.Ball)
        crystal.Transparency = 0.28
    end

    if level >= 5 then
        local crown = decor("MasterNestCrown", Vector3.new(5, 5, 5), Vector3.new(0, 8.5, 0), Color3.fromRGB(255, 205, 74), Enum.Material.Neon, Enum.PartType.Ball)
        crown.Transparency = 0.22
        local light = Instance.new("PointLight")
        light.Color = crown.Color
        light.Brightness = 1.8
        light.Range = 18
        light.Parent = crown
    end

    plot.Model:SetAttribute("NestLevel", level)
    return true
end

function PlotService:ApplyIslandStyle(player, styleId)
    local plot = self._playerPlots[player]
    if not plot or not plot.Model or not plot.Model.Parent then return false end
    local style = IslandStyleCatalog[styleId]
    if not style then return false end

    local grass = plot.Model:FindFirstChild("PlotGrass")
    if grass then
        grass.Color = style.Grass
        grass.Material = style.Material
    end

    local environment = plot.Model:FindFirstChild("EnvironmentDecorations")
    if environment then
        for _, part in ipairs(environment:GetDescendants()) do
            if part:IsA("BasePart") then
                if string.find(part.Name, "Canopy", 1, true) then
                    part.Color = style.Foliage
                elseif string.find(part.Name, "_Bloom_", 1, true) then
                    part.Color = style.Accent
                elseif string.find(part.Name, "GardenPathStone_", 1, true) then
                    part.Color = style.Stone
                    part.Material = style.Feature == "Ancient" and Enum.Material.Cobblestone or Enum.Material.Slate
                end
            end
        end
    end

    local previous = plot.Model:FindFirstChild("StyleDecorations")
    if previous then previous:Destroy() end
    local decorations = Instance.new("Folder")
    decorations.Name = "StyleDecorations"
    decorations:SetAttribute("StyleId", styleId)
    decorations.Parent = plot.Model
    local center = plot.Center
    local function stylePart(name, size, offset, color, material, shape)
        local part = makePart(decorations, name, size, CFrame.new(center + offset), color, material)
        if shape then part.Shape = shape end
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        return part
    end

    if style.Feature == "Arcane" then
        for index, offset in ipairs({
            Vector3.new(-14, 3.1, -7), Vector3.new(14, 3.1, -7),
            Vector3.new(-14, 3.1, 7), Vector3.new(14, 3.1, 7),
        }) do
            local crystal = stylePart("ArcanePrism_" .. index, Vector3.new(1.2, 3.4, 1.2),
                offset, style.Accent, Enum.Material.Neon, Enum.PartType.Wedge)
            local light = Instance.new("PointLight")
            light.Color = style.Accent
            light.Brightness = 0.7
            light.Range = 9
            light.Shadows = false
            light.Parent = crystal
        end
    elseif style.Feature == "Ancient" then
        for index, x in ipairs({-14, 14}) do
            for _, z in ipairs({-8, 8}) do
                stylePart("AncientColumn_" .. index .. "_" .. tostring(z),
                    Vector3.new(1.15, 4.8, 1.15), Vector3.new(x, 4.0, z),
                    Color3.fromRGB(174, 159, 126), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
                stylePart("AncientCapital_" .. index .. "_" .. tostring(z),
                    Vector3.new(1.8, 0.5, 1.8), Vector3.new(x, 6.55, z),
                    style.Accent, Enum.Material.Slate, Enum.PartType.Cylinder)
            end
        end
    elseif style.Feature == "Royal" then
        for index, x in ipairs({-11, 11}) do
            local post = stylePart("RoyalPost_" .. index, Vector3.new(0.55, 4.4, 0.55),
                Vector3.new(x, 3.8, -13), Color3.fromRGB(211, 169, 75), Enum.Material.Metal)
            local gem = stylePart("RoyalGem_" .. index, Vector3.new(1.1, 1.1, 1.1),
                Vector3.new(x, 6.2, -13), style.Accent, Enum.Material.Neon, Enum.PartType.Ball)
            local light = Instance.new("PointLight")
            light.Color = style.Accent
            light.Brightness = 0.8
            light.Range = 10
            light.Shadows = false
            light.Parent = gem
        end
        stylePart("RoyalGardenPlinth", Vector3.new(8, 0.35, 1.2),
            Vector3.new(0, 2.0, -15), Color3.fromRGB(211, 169, 75), Enum.Material.Metal)
    end

    plot.Model:SetAttribute("IslandStyle", styleId)
    return true
end

function PlotService:ApplyContestTrophies(player)
    local plot = self._playerPlots[player]
    local profile = PlayerDataService:GetProfile(player)
    if not plot or not profile or not profile.Nest then return false end

    local previous = plot.Model:FindFirstChild("ContestTrophies")
    if previous then previous:Destroy() end

    local trophies = profile.Nest.IslandTrophies or {}
    local entries = {}
    for _, trophy in pairs(trophies) do
        if type(trophy) == "table"
            and type(trophy.Week) == "string"
            and type(trophy.Category) == "string"
            and type(trophy.Place) == "number" then
            table.insert(entries, trophy)
        end
    end
    table.sort(entries, function(a, b)
        if (a.ClaimedAt or 0) == (b.ClaimedAt or 0) then
            return a.Week > b.Week
        end
        return (a.ClaimedAt or 0) > (b.ClaimedAt or 0)
    end)

    local folder = Instance.new("Folder")
    folder.Name = "ContestTrophies"
    folder.Parent = plot.Model

    local medalColors = {
        [1] = Color3.fromRGB(255, 205, 75),
        [2] = Color3.fromRGB(196, 210, 224),
        [3] = Color3.fromRGB(190, 126, 78),
    }
    local categoryNames = {
        Cozy = "УЮТ",
        Nature = "ПРИРОДА",
        Fantasy = "ФЭНТЕЗИ",
        AncientTemple = "СЕРДЦЕ ДРЕВА",
    }
    local categoryColors = {
        Cozy = Color3.fromRGB(245, 174, 115),
        Nature = Color3.fromRGB(116, 207, 137),
        Fantasy = Color3.fromRGB(166, 143, 240),
        AncientTemple = Color3.fromRGB(153, 211, 113),
    }

    for index = 1, math.min(#entries, 6) do
        local trophyData = entries[index]
        local award = Instance.new("Model")
        award.Name = "ContestTrophy_" .. tostring(index)
        award:SetAttribute("Week", trophyData.Week)
        award:SetAttribute("Category", trophyData.Category)
        award:SetAttribute("Place", trophyData.Place)
        award.Parent = folder

        local color = medalColors[trophyData.Place] or medalColors[3]
        local accent = categoryColors[trophyData.Category] or Color3.fromRGB(235, 220, 180)
        local x = -13 + (index - 1) * 5.2
        local origin = plot.Center + Vector3.new(x, 2.0, -13)

        local function trophyPart(name, size, offset, partColor, material, shape)
            local part = makePart(
                award,
                name,
                size,
                CFrame.new(origin + offset),
                partColor,
                material
            )
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            if shape then part.Shape = shape end
            return part
        end

        trophyPart("Pedestal", Vector3.new(3.8, 0.55, 3.2), Vector3.new(0, 0, 0), Color3.fromRGB(92, 72, 54), Enum.Material.Wood)
        trophyPart("MedalStem", Vector3.new(0.8, 1.5, 0.8), Vector3.new(0, 1.0, 0), color, Enum.Material.Metal)
        local cup = trophyPart("Cup", Vector3.new(2.0, 1.7, 1.5), Vector3.new(0, 2.3, 0), color, Enum.Material.Metal, Enum.PartType.Ball)
        cup.Size = Vector3.new(2.0, 1.35, 1.5)
        trophyPart("CategoryGem", Vector3.new(0.55, 0.55, 0.55), Vector3.new(0, 2.35, -0.9), accent, Enum.Material.Neon, Enum.PartType.Ball)
        trophyPart("HandleLeft", Vector3.new(0.35, 1.1, 0.35), Vector3.new(-1.05, 2.25, 0), color, Enum.Material.Metal, Enum.PartType.Ball)
        trophyPart("HandleRight", Vector3.new(0.35, 1.1, 0.35), Vector3.new(1.05, 2.25, 0), color, Enum.Material.Metal, Enum.PartType.Ball)

        local plaque = trophyPart("Plaque", Vector3.new(3.2, 0.65, 0.25), Vector3.new(0, 0.35, -1.65), accent, Enum.Material.SmoothPlastic)
        local surface = Instance.new("SurfaceGui")
        surface.Face = Enum.NormalId.Front
        surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surface.PixelsPerStud = 45
        surface.Parent = plaque
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Text = trophyData.Category == "AncientTemple"
            and "СЕРДЦЕ ДРЕВА"
            or ((categoryNames[trophyData.Category] or "КОНКУРС") .. " · " .. tostring(trophyData.Place))
        label.TextColor3 = Color3.fromRGB(255, 255, 245)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBlack
        label.Parent = surface
    end
    return true
end

function PlotService:GetPlayerPlot(player)
    return self._playerPlots[player]
end

function PlotService:IsOwner(player, plotId)
    local plot = self._playerPlots[player]
    return plot ~= nil and plot.Id == plotId
end

function PlotService:GetStation(player)
    local plot = self._playerPlots[player]
    return plot and plot.Station or nil
end

function PlotService:AssignPlot(player)
    if self._playerPlots[player] or not player.Parent then return end
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end

    local requestedId = profile.Nest and profile.Nest.PlotId
    local selected = requestedId and self._plots[requestedId] or nil
    if selected and self._owners[selected.Id] then selected = nil end

    if not selected then
        for _, definition in ipairs(PLOT_DEFINITIONS) do
            local candidate = self._plots[definition.Id]
            if candidate and not self._owners[candidate.Id] then
                selected = candidate
                break
            end
        end
    end

    if not selected then
        player:SetAttribute("LastNotice", "Все личные гнёзда заняты. Попробуй другой сервер.")
        player:Kick("Все гнёзда на сервере заняты. Попробуй подключиться ещё раз.")
        return
    end

    self._owners[selected.Id] = player
    self._playerPlots[player] = selected
    profile.Nest = profile.Nest or { Level = 1 }
    profile.Nest.PlotId = selected.Id
    selected.Model:SetAttribute("OwnerUserId", player.UserId)
    selected.Model:SetAttribute("OwnerName", player.DisplayName)
    selected.OwnerLabel.Text = "ГНЕЗДО: " .. player.DisplayName
    player:SetAttribute("PlotId", selected.Id)
    player:SetAttribute("PlotAssigned", true)
    self:ApplyNestLevel(player, profile.Nest.Level or 1)
    self:ApplyIslandStyle(player, profile.Nest.IslandStyle or "Meadow")
    self:ApplyContestTrophies(player)
    player:SetAttribute("LastNotice", "Твоё личное гнездо готово!")
end

function PlotService:ReleasePlot(player)
    local plot = self._playerPlots[player]
    if not plot then return end
    self._owners[plot.Id] = nil
    self._playerPlots[player] = nil
    local playerDecorations = plot.Model:FindFirstChild("PlayerDecorations")
    if playerDecorations then playerDecorations:Destroy() end
    local displayedCompanions = plot.Model:FindFirstChild("DisplayedCompanions")
    if displayedCompanions then displayedCompanions:Destroy() end
    local playerBuildings = plot.Model:FindFirstChild("PlayerBuildings")
    if playerBuildings then playerBuildings:Destroy() end
    local contestTrophies = plot.Model:FindFirstChild("ContestTrophies")
    if contestTrophies then contestTrophies:Destroy() end
    plot.Model:SetAttribute("OwnerUserId", nil)
    plot.Model:SetAttribute("OwnerName", nil)
    plot.OwnerLabel.Text = "СВОБОДНОЕ ГНЕЗДО"
    player:SetAttribute("PlotAssigned", false)
end

function PlotService:BindPlayer(player)
    player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
        if player:GetAttribute("ProfileLoaded") then self:AssignPlot(player) end
    end)
    if player:GetAttribute("ProfileLoaded") then
        task.defer(function() self:AssignPlot(player) end)
    end
end

function PlotService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local island = world and world:FindFirstChild("StarterIsland")
    if not island then
        warn("[NEST RAIDERS] StarterIsland missing; plot assignment disabled.")
        return false, "StarterIsland missing"
    end

    -- Keep the expected folder present even if an individual plot fails to
    -- build; diagnostics can then report the exact number of successful plots.
    local folder = island:FindFirstChild("PlayerPlots")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "PlayerPlots"
        folder.Parent = island
    end

    local created = 0
    for _, definition in ipairs(PLOT_DEFINITIONS) do
        local existing = folder:FindFirstChild(definition.Id)
        if existing and existing:IsA("Model") then
            local station = existing:FindFirstChild("HatchStation")
            local label = existing:FindFirstChild("OwnerSign")
                and existing.OwnerSign:FindFirstChildWhichIsA("SurfaceGui")
                and existing.OwnerSign:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel")
            self._plots[definition.Id] = {
                Id = definition.Id, Model = existing, Station = station,
                BreedingStation = existing:FindFirstChild("BreedingStation"),
                OwnerLabel = label, Center = definition.Position,
            }
            created += 1
        else
            local ok, model, station, ownerLabel = pcall(buildPlot, folder, definition)
            if ok and model and station then
                self._plots[definition.Id] = {
                    Id = definition.Id, Model = model, Station = station,
                    BreedingStation = model:FindFirstChild("BreedingStation"),
                    OwnerLabel = ownerLabel, Center = definition.Position,
                }
                created += 1
            else
                warn("[NEST RAIDERS] Plot build failed for " .. definition.Id .. ": " .. tostring(model))
            end
        end
    end

    self._initialized = created == #PLOT_DEFINITIONS
    folder:SetAttribute("CreatedCount", created)
    folder:SetAttribute("ExpectedCount", #PLOT_DEFINITIONS)
    if not self._initialized then
        warn(string.format("[NEST RAIDERS] Only %d/%d player plots were created.", created, #PLOT_DEFINITIONS))
    end

    Players.PlayerAdded:Connect(function(player) self:BindPlayer(player) end)
    Players.PlayerRemoving:Connect(function(player) self:ReleasePlot(player) end)
    for _, player in ipairs(Players:GetPlayers()) do self:BindPlayer(player) end
    return self._initialized, created
end

return PlotService
