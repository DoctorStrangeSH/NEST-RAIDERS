local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local NestToyCatalog = require(ReplicatedStorage.Shared.Config.NestToyCatalog)

local CompanionService = {}
CompanionService._folders = {}
CompanionService._displayFolders = {}
CompanionService._generations = {}
local MAX_VISIBLE_COMPANIONS = 3
local FOLLOW_INTERVAL = 0.15

local DEFINITIONS = {
    MeadowFox = {
        Body = Color3.fromRGB(226, 132, 67),
        Accent = Color3.fromRGB(255, 225, 184),
        Detail = Color3.fromRGB(105, 66, 48),
        Kind = "Fox",
    },
    MossTurtle = {
        Body = Color3.fromRGB(111, 176, 112),
        Accent = Color3.fromRGB(119, 91, 62),
        Detail = Color3.fromRGB(226, 207, 143),
        Kind = "Turtle",
    },
    SproutDragon = {
        Body = Color3.fromRGB(81, 190, 174),
        Accent = Color3.fromRGB(178, 235, 144),
        Detail = Color3.fromRGB(106, 123, 210),
        Kind = "Dragon",
    },
    EmberFox = {
        Body = Color3.fromRGB(224, 105, 55),
        Accent = Color3.fromRGB(255, 190, 93),
        Detail = Color3.fromRGB(121, 62, 45),
        Kind = "EmberFox",
    },
    Fernshell = {
        Body = Color3.fromRGB(93, 157, 105),
        Accent = Color3.fromRGB(155, 192, 107),
        Detail = Color3.fromRGB(104, 119, 76),
        Kind = "Fernshell",
    },
    BriarGuardian = {
        Body = Color3.fromRGB(117, 148, 91),
        Accent = Color3.fromRGB(183, 151, 105),
        Detail = Color3.fromRGB(82, 102, 66),
        Kind = "BriarGuardian",
    },
}

local function makeShape(model, name, size, offset, color, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = shape or Enum.PartType.Ball
    part.Size = size
    part.CFrame = CFrame.new(offset)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = true
    part.Material = Enum.Material.SmoothPlastic
    part.Color = color
    part.Parent = model
    return part
end

local function buildPet(parent, companion, index)
    local definition = DEFINITIONS[companion.Id] or DEFINITIONS.MeadowFox
    local model = Instance.new("Model")
    model.Name = string.format("%s_%d", companion.Id, index)
    model:SetAttribute("CompanionId", companion.Id)
    model:SetAttribute("Rarity", companion.Rarity or "Обычный")
    model:SetAttribute("Stars", companion.Stars or 1)
    model.Parent = parent

    local body = makeShape(model, "Body", Vector3.new(2.2, 1.45, 1.65), Vector3.new(0, 1.05, 0), definition.Body)
    model.PrimaryPart = body
    makeShape(model, "Head", Vector3.new(1.35, 1.25, 1.25), Vector3.new(0, 1.85, 0.65), definition.Body)

    if definition.Kind == "EmberFox" then
        makeShape(model, "Muzzle", Vector3.new(0.75, 0.48, 0.55), Vector3.new(0, 1.58, 1.2), definition.Accent)
        makeShape(model, "LeftEar", Vector3.new(0.48, 0.8, 0.42), Vector3.new(-0.42, 2.55, 0.55), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightEar", Vector3.new(0.48, 0.8, 0.42), Vector3.new(0.42, 2.55, 0.55), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(1.15, 1.15, 1.1), Vector3.new(0, 1.3, -1.15), definition.Accent)
        makeShape(model, "LeftHorn", Vector3.new(0.25, 0.55, 0.25), Vector3.new(-0.3, 2.7, 0.3), Color3.fromRGB(255, 216, 119), Enum.PartType.Wedge)
        makeShape(model, "RightHorn", Vector3.new(0.25, 0.55, 0.25), Vector3.new(0.3, 2.7, 0.3), Color3.fromRGB(255, 216, 119), Enum.PartType.Wedge)
    elseif definition.Kind == "Fernshell" then
        makeShape(model, "Shell", Vector3.new(2.1, 1.15, 1.8), Vector3.new(0, 1.75, -0.05), definition.Accent)
        for _, x in ipairs({-0.7, 0.7}) do
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, 0.55), definition.Detail)
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, -0.55), definition.Detail)
        end
        makeShape(model, "LeftHorn", Vector3.new(0.3, 0.7, 0.3), Vector3.new(-0.4, 2.55, 0.45), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightHorn", Vector3.new(0.3, 0.7, 0.3), Vector3.new(0.4, 2.55, 0.45), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "LeafCrest", Vector3.new(0.75, 0.25, 0.8), Vector3.new(0, 2.45, -0.15), Color3.fromRGB(119, 204, 115), Enum.PartType.Wedge)
    elseif definition.Kind == "BriarGuardian" then
        makeShape(model, "Muzzle", Vector3.new(0.75, 0.48, 0.55), Vector3.new(0, 1.58, 1.2), definition.Accent)
        makeShape(model, "Shell", Vector3.new(2.1, 1.15, 1.8), Vector3.new(0, 1.75, -0.05), definition.Detail)
        makeShape(model, "LeftEar", Vector3.new(0.4, 0.7, 0.35), Vector3.new(-0.42, 2.55, 0.55), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightEar", Vector3.new(0.4, 0.7, 0.35), Vector3.new(0.42, 2.55, 0.55), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(0.75, 0.75, 0.95), Vector3.new(0, 1.25, -1.15), definition.Accent)
        for _, x in ipairs({-0.7, 0.7}) do
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, 0.55), definition.Detail)
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, -0.55), definition.Detail)
        end
    elseif definition.Kind == "Fox" then
        makeShape(model, "Muzzle", Vector3.new(0.75, 0.48, 0.55), Vector3.new(0, 1.58, 1.2), definition.Accent)
        makeShape(model, "LeftEar", Vector3.new(0.48, 0.8, 0.42), Vector3.new(-0.42, 2.55, 0.55), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightEar", Vector3.new(0.48, 0.8, 0.42), Vector3.new(0.42, 2.55, 0.55), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(1.1, 1.1, 1.1), Vector3.new(0, 1.3, -1.15), definition.Accent)
    elseif definition.Kind == "Turtle" then
        makeShape(model, "Shell", Vector3.new(2.1, 1.15, 1.8), Vector3.new(0, 1.75, -0.05), definition.Accent)
        for _, x in ipairs({-0.7, 0.7}) do
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, 0.55), definition.Detail)
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, -0.55), definition.Detail)
        end
    else
        makeShape(model, "Muzzle", Vector3.new(0.85, 0.55, 0.6), Vector3.new(0, 1.6, 1.15), definition.Accent)
        makeShape(model, "LeftHorn", Vector3.new(0.35, 0.8, 0.35), Vector3.new(-0.45, 2.55, 0.45), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightHorn", Vector3.new(0.35, 0.8, 0.35), Vector3.new(0.45, 2.55, 0.45), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "LeftWing", Vector3.new(1.2, 0.18, 1.3), Vector3.new(-1.15, 1.7, -0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightWing", Vector3.new(1.2, 0.18, 1.3), Vector3.new(1.15, 1.7, -0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(0.55, 0.55, 1.2), Vector3.new(0, 1.1, -1.15), definition.Accent)
    end

    makeShape(model, "LeftEye", Vector3.new(0.16, 0.16, 0.12), Vector3.new(-0.28, 2.0, 1.22), Color3.fromRGB(35, 42, 48))
    makeShape(model, "RightEye", Vector3.new(0.16, 0.16, 0.12), Vector3.new(0.28, 2.0, 1.22), Color3.fromRGB(35, 42, 48))

    local stars = math.clamp(math.floor(tonumber(companion.Stars) or 1), 1, 3)
    if stars >= 2 then
        local aura = Instance.new("Highlight")
        aura.Name = "EvolutionAura"
        aura.Adornee = model
        aura.FillColor = stars == 3 and Color3.fromRGB(255, 190, 92) or Color3.fromRGB(125, 211, 255)
        aura.OutlineColor = stars == 3 and Color3.fromRGB(255, 232, 160) or Color3.fromRGB(205, 240, 255)
        aura.FillTransparency = stars == 3 and 0.72 or 0.84
        aura.OutlineTransparency = 0.12
        aura.DepthMode = Enum.HighlightDepthMode.Occluded
        aura.Parent = model
        local orbCount = stars == 3 and 3 or 1
        for index = 1, orbCount do
            local x = (index - (orbCount + 1) / 2) * 0.48
            local orb = makeShape(model, "EvolutionStar", Vector3.new(0.3, 0.3, 0.3), Vector3.new(x, 3.0, 0.35), aura.OutlineColor)
            orb.Material = Enum.Material.Neon
        end
    end
    local level = math.clamp(math.floor(tonumber(companion.Level) or 1), 1, 10)
    local growthStage = level >= 7 and "Adult" or (level >= 4 and "Young" or "Hatchling")
    local growthScale = growthStage == "Adult" and 1.16 or (growthStage == "Young" and 1.08 or 1)
    model:SetAttribute("GrowthStage", growthStage)
    model:SetAttribute("GrowthLevel", level)

    local trait = type(companion.GeneticTrait) == "table" and companion.GeneticTrait or {}
    local traitId = trait.Id or "Natural"
    model:SetAttribute("GeneticTrait", traitId)
    local traitColors = {
        Verdant = Color3.fromRGB(113, 220, 137),
        Luminous = Color3.fromRGB(102, 222, 255),
        Prismatic = Color3.fromRGB(230, 132, 255),
    }
    local traitColor = traitColors[traitId]
    if traitColor then
        local geneticAura = Instance.new("Highlight")
        geneticAura.Name = "GeneticAura"
        geneticAura.Adornee = model
        geneticAura.FillColor = traitColor
        geneticAura.OutlineColor = traitColor
        geneticAura.FillTransparency = traitId == "Prismatic" and 0.78 or 0.88
        geneticAura.OutlineTransparency = 0.18
        geneticAura.DepthMode = Enum.HighlightDepthMode.Occluded
        geneticAura.Parent = model
        if traitId == "Verdant" then
            -- Leaf-like crystal growths make Verdant visibly different from a simple aura.
            for leafIndex, offset in ipairs({
                Vector3.new(-0.62, 2.72, -0.35),
                Vector3.new(0, 2.94, -0.48),
                Vector3.new(0.62, 2.72, -0.35),
            }) do
                local leaf = makeShape(model, "VerdantCrystal_" .. leafIndex,
                    Vector3.new(0.34, 0.82, 0.22), offset, traitColor, Enum.PartType.Wedge)
                leaf.Material = Enum.Material.Neon
            end
            local gem = makeShape(model, "VerdantHeart", Vector3.new(0.38, 0.38, 0.38),
                Vector3.new(0, 2.05, 0.98), Color3.fromRGB(184, 255, 193))
            gem.Material = Enum.Material.Neon
        elseif traitId == "Luminous" then
            -- Soft cyan lantern orbs are attached around the pet's silhouette.
            for orbIndex, offset in ipairs({
                Vector3.new(-1.12, 2.35, 0),
                Vector3.new(1.12, 2.35, 0),
                Vector3.new(0, 2.92, -0.55),
            }) do
                local orb = makeShape(model, "LuminousOrb_" .. orbIndex,
                    Vector3.new(0.24, 0.24, 0.24), offset, traitColor)
                orb.Material = Enum.Material.Neon
                local light = Instance.new("PointLight")
                light.Name = "GeneticGlow"
                light.Color = traitColor
                light.Range = 5
                light.Brightness = 0.65
                light.Shadows = false
                light.Parent = orb
            end
        elseif traitId == "Prismatic" then
            -- Three colored facets communicate the rare multi-color mutation.
            local facets = {
                { Offset = Vector3.new(-0.58, 2.82, -0.35), Color = Color3.fromRGB(255, 111, 126) },
                { Offset = Vector3.new(0, 3.02, -0.42), Color = Color3.fromRGB(112, 226, 255) },
                { Offset = Vector3.new(0.58, 2.82, -0.35), Color = Color3.fromRGB(218, 143, 255) },
            }
            for facetIndex, facet in ipairs(facets) do
                local shard = makeShape(model, "PrismaticFacet_" .. facetIndex,
                    Vector3.new(0.28, 0.72, 0.2), facet.Offset, facet.Color, Enum.PartType.Wedge)
                shard.Material = Enum.Material.Neon
            end
            local spark = makeShape(model, "PrismaticCore", Vector3.new(0.3, 0.3, 0.3),
                Vector3.new(0, 2.05, 1.02), traitColor)
            spark.Material = Enum.Material.Neon
        end
    end
    if growthScale > 1 then
        model:ScaleTo(growthScale)
    end
    return model
end

function CompanionService:RefreshDisplayedPets(player, plot, displayedIds, slotOffsets)
    local previous = self._displayFolders[player]
    if previous then previous:Destroy() end
    self._displayFolders[player] = nil
    if not plot or not plot.Model or not plot.Model.Parent then return end

    local folder = Instance.new("Folder")
    folder.Name = "DisplayedCompanions"
    folder.Parent = plot.Model
    self._displayFolders[player] = folder

    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end
    local ownedById = {}
    for _, companion in ipairs(profile.Companions or {}) do
        if type(companion.InstanceId) == "string" then
            ownedById[companion.InstanceId] = companion
        end
    end

    for rawSlot, instanceId in pairs(displayedIds or {}) do
        local slot = tonumber(rawSlot)
        local companion = ownedById[instanceId]
        local offset = slot and slotOffsets[slot]
        if companion and offset then
            local model = buildPet(folder, companion, slot)
            model.Name = "Display_" .. tostring(companion.Id) .. "_" .. tostring(slot)
            local basePivot = CFrame.new(plot.Center + offset + Vector3.new(0, 1.5, 0))
            model:PivotTo(basePivot)

            local mood = math.clamp(math.floor(tonumber(profile.Nest and profile.Nest.CompanionMood and profile.Nest.CompanionMood[instanceId]) or 50), 0, 100)
            local needs = profile.Nest and profile.Nest.CompanionNeeds and profile.Nest.CompanionNeeds[instanceId] or {}
            local hunger = math.clamp(math.floor(tonumber(needs.Hunger) or 100), 0, 100)
            local energy = math.clamp(math.floor(tonumber(needs.Energy) or 100), 0, 100)
            local sleeping = (tonumber(needs.RestingUntil) or 0) > os.time()
            local toyId = profile.Nest and profile.Nest.CompanionToys and profile.Nest.CompanionToys[instanceId]
            local toyDefinition = NestToyCatalog[toyId or ""]
            if toyDefinition then
                local toyPart = makeShape(model, "EquippedNestToy", Vector3.new(0.8, 0.8, 0.8), Vector3.new(1.35, 0.85, 0.75), toyDefinition.Color, toyDefinition.Shape)
                toyPart.Material = Enum.Material.Neon
                toyPart:SetAttribute("ToyId", toyDefinition.Id)
            end
            local moodBillboard = Instance.new("BillboardGui")
            moodBillboard.Name = "MoodBubble"
            moodBillboard.Adornee = model.PrimaryPart
            moodBillboard.Size = UDim2.fromOffset(104, 28)
            moodBillboard.StudsOffset = Vector3.new(0, 2.9, 0)
            moodBillboard.AlwaysOnTop = false
            moodBillboard.Parent = model

            local moodLabel = Instance.new("TextLabel")
            moodLabel.Size = UDim2.fromScale(1, 1)
            moodLabel.BackgroundColor3 = Color3.fromRGB(35, 52, 48)
            moodLabel.BackgroundTransparency = 0.12
            moodLabel.TextColor3 = Color3.fromRGB(240, 250, 228)
            moodLabel.TextSize = 13
            moodLabel.Font = Enum.Font.GothamBold
            moodLabel.Text = sleeping and "Zzz" or string.format("♥%d  🍖%d  ⚡%d", mood, hunger, energy)
            moodLabel.Parent = moodBillboard
            local bubbleCorner = Instance.new("UICorner")
            bubbleCorner.CornerRadius = UDim.new(0, 8)
            bubbleCorner.Parent = moodLabel

            local phase = (slot * 1.7) % (math.pi * 2)
            task.spawn(function()
                while model.Parent == folder and folder.Parent do
                    local elapsed = os.clock()
                    local bob = math.sin(elapsed * 2 + phase) * 0.12
                    local turn = math.sin(elapsed * 1.1 + phase) * 0.06
                    model:PivotTo(basePivot * CFrame.new(0, bob, 0) * CFrame.Angles(0, turn, 0))
                    task.wait(0.12)
                end
            end)
        end
    end
end

function CompanionService:CreateRitualPreview(parent, companion, index)
    if not parent or type(companion) ~= "table" then return nil end
    local preview = buildPet(parent, companion, index or 1)
    preview.Name = "BreedingParent_" .. tostring(index or 1)
    preview:SetAttribute("RitualPreview", true)
    return preview
end

function CompanionService:ClearPlayer(player)
    local folder = self._folders[player]
    if folder then folder:Destroy() end
    self._folders[player] = nil
end

function CompanionService:RefreshPlayer(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end

    self._generations[player] = (self._generations[player] or 0) + 1
    local generation = self._generations[player]
    self:ClearPlayer(player)

    local rootFolder = Workspace:FindFirstChild("PlayerCompanions")
    if not rootFolder then
        rootFolder = Instance.new("Folder")
        rootFolder.Name = "PlayerCompanions"
        rootFolder.Parent = Workspace
    end

    local folder = Instance.new("Folder")
    folder.Name = "Player_" .. player.UserId
    folder.Parent = rootFolder
    self._folders[player] = folder

    local ownedById = {}
    for _, companion in ipairs(profile.Companions) do
        if type(companion.InstanceId) == "string" then
            ownedById[companion.InstanceId] = companion
        end
    end

    local followers = {}
    for _, instanceId in ipairs(profile.ActiveCompanions or {}) do
        if #followers >= MAX_VISIBLE_COMPANIONS then break end
        local companion = ownedById[instanceId]
        if companion then
            table.insert(followers, buildPet(folder, companion, #followers + 1))
        end
    end

    -- Newly hatched followers should appear beside their owner immediately.
    -- Otherwise each model starts around world origin and slowly lerps across
    -- the entire island, looking as though the hatch did nothing.
    local character = player.Character
    local spawnRoot = character and character:FindFirstChild("HumanoidRootPart")
    if spawnRoot then
        for index, pet in ipairs(followers) do
            local side = (index - (#followers + 1) / 2) * 2.6
            local behind = 4 + math.floor((index - 1) / 2) * 2.1
            pet:PivotTo(spawnRoot.CFrame * CFrame.new(side, -2.2, behind))
        end
    end

    task.spawn(function()
        while player.Parent and self._generations[player] == generation do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                for index, pet in ipairs(followers) do
                    if pet.Parent then
                        local side = (index - (#followers + 1) / 2) * 2.6
                        local behind = 4 + math.floor((index - 1) / 2) * 2.1
                        local target = root.CFrame * CFrame.new(side, -2.2, behind)
                        pet:PivotTo(pet:GetPivot():Lerp(target, 0.35))
                    end
                end
            end
            task.wait(FOLLOW_INTERVAL)
        end
    end)
end

function CompanionService:Init()
    -- A player may already exist when this service starts. Register identical
    -- profile and respawn listeners for both existing and new players.
    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true

        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player.Parent and player:GetAttribute("ProfileLoaded") then
                self:RefreshPlayer(player)
            end
        end)
        player.CharacterAdded:Connect(function()
            task.delay(0.5, function()
                if player.Parent and player:GetAttribute("ProfileLoaded") then
                    self:RefreshPlayer(player)
                end
            end)
        end)

        if player:GetAttribute("ProfileLoaded") then
            task.defer(function()
                if player.Parent then self:RefreshPlayer(player) end
            end)
        end
    end

    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        boundPlayers[player] = nil
        self._generations[player] = nil
        self:ClearPlayer(player)
        local displayFolder = self._displayFolders[player]
        if displayFolder then displayFolder:Destroy() end
        self._displayFolders[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        bindPlayer(player)
    end
end

return CompanionService
