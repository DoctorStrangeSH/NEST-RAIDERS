local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local CompanionAdventureService = {}
local ACTIVE_INTERVAL = 12
local PAIR_COOLDOWN = 300
local MIN_BOND = 10
local MAX_DISTANCE = 42
local random = Random.new()
local activeEvents = {}

local function getPairKey(firstId, secondId)
    firstId, secondId = tostring(firstId or ""), tostring(secondId or "")
    if firstId == "" or secondId == "" or firstId == secondId then return nil end
    if firstId > secondId then firstId, secondId = secondId, firstId end
    return firstId .. "|" .. secondId
end

local function findCompanionModels(player)
    local root = Workspace:FindFirstChild("PlayerCompanions")
    local folder = root and root:FindFirstChild("Player_" .. player.UserId)
    local models = {}
    if not folder then return models end
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") and model.PrimaryPart then
            local instanceId = model:GetAttribute("CompanionInstanceId")
            if type(instanceId) == "string" and instanceId ~= "" then
                table.insert(models, model)
            end
        end
    end
    return models
end

local function createAdventureMarker(player, firstModel, secondModel, pairKey, rare)
    local firstRoot, secondRoot = firstModel.PrimaryPart, secondModel.PrimaryPart
    if not firstRoot or not secondRoot then return nil end

    local midpoint = (firstRoot.Position + secondRoot.Position) * 0.5
    local marker = Instance.new("Part")
    marker.Name = "PairedAdventureSecret"
    marker.Shape = Enum.PartType.Ball
    marker.Size = rare and Vector3.new(1.8, 1.8, 1.8) or Vector3.new(1.25, 1.25, 1.25)
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.Material = Enum.Material.Neon
    marker.Color = rare and Color3.fromRGB(255, 205, 91) or Color3.fromRGB(126, 226, 211)
    marker.Position = midpoint + Vector3.new(0, 1.3, 0)
    marker:SetAttribute("OwnerUserId", player.UserId)
    marker:SetAttribute("PairKey", pairKey)
    marker.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Color = marker.Color
    light.Range = rare and 16 or 11
    light.Brightness = rare and 2 or 1.25
    light.Parent = marker

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdventureLabel"
    billboard.Size = UDim2.fromOffset(190, 42)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = marker
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(28, 43, 51)
    label.BackgroundTransparency = 0.12
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(255, 248, 222)
    label.Text = rare and "РЕДКАЯ ТАЙНА ВДВОЁМ!" or "ПИТОМЦЫ НАШЛИ СЕКРЕТ"
    label.Parent = billboard
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ClaimPairedAdventure"
    prompt.ActionText = "Исследовать находку"
    prompt.ObjectText = "Секрет питомцев"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.45
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = marker

    local beamFolder = Instance.new("Folder")
    beamFolder.Name = "AdventureBondVisuals"
    beamFolder.Parent = marker
    local firstAttachment = Instance.new("Attachment")
    firstAttachment.Name = "AdventureLink"
    firstAttachment.Parent = firstRoot
    local secondAttachment = Instance.new("Attachment")
    secondAttachment.Name = "AdventureLink"
    secondAttachment.Parent = secondRoot
    local beam = Instance.new("Beam")
    beam.Attachment0 = firstAttachment
    beam.Attachment1 = secondAttachment
    beam.Width0 = 0.12
    beam.Width1 = 0.12
    beam.FaceCamera = true
    beam.LightEmission = 0.8
    beam.Color = ColorSequence.new(marker.Color)
    beam.Parent = beamFolder

    local pulse = TweenService:Create(marker, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Size = marker.Size * 1.28,
    })
    pulse:Play()

    local firstHighlight = Instance.new("Highlight")
    firstHighlight.Name = "PairedAdventureGlow"
    firstHighlight.Adornee = firstModel
    firstHighlight.FillColor = marker.Color
    firstHighlight.OutlineColor = marker.Color
    firstHighlight.FillTransparency = 0.72
    firstHighlight.OutlineTransparency = 0.18
    firstHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    firstHighlight.Parent = firstModel
    local secondHighlight = firstHighlight:Clone()
    secondHighlight.Adornee = secondModel
    secondHighlight.Parent = secondModel
    local glowPulse = TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    TweenService:Create(firstHighlight, glowPulse, { FillTransparency = 0.38 }):Play()
    TweenService:Create(secondHighlight, glowPulse, { FillTransparency = 0.38 }):Play()

    local claimed = false
    local connection
    connection = prompt.Triggered:Connect(function(collector)
        if claimed or collector ~= player or not player.Parent then return end
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root or (root.Position - marker.Position).Magnitude > 13 then return end
        local profile = PlayerDataService:GetProfile(player)
        if not profile or not marker.Parent then return end
        local currentPairKey = getPairKey(firstModel:GetAttribute("CompanionInstanceId"), secondModel:GetAttribute("CompanionInstanceId"))
        if currentPairKey ~= pairKey then return end
        claimed = true

        profile.Nest = profile.Nest or {}
        profile.Nest.CompanionBonds = profile.Nest.CompanionBonds or {}
        profile.Nest.CompanionMood = profile.Nest.CompanionMood or {}
        local score = math.clamp(math.floor(tonumber(profile.Nest.CompanionBonds[pairKey]) or 0) + (rare and 3 or 2), 0, 100)
        profile.Nest.CompanionBonds[pairKey] = score

        local firstId = firstModel:GetAttribute("CompanionInstanceId")
        local secondId = secondModel:GetAttribute("CompanionInstanceId")
        local firstMood = math.clamp(math.floor(tonumber(profile.Nest.CompanionMood[firstId]) or tonumber(firstModel:GetAttribute("Mood")) or 50), 0, 100)
        local secondMood = math.clamp(math.floor(tonumber(profile.Nest.CompanionMood[secondId]) or tonumber(secondModel:GetAttribute("Mood")) or 50), 0, 100)
        local firstGain, secondGain = 3, 3
        if firstMood <= secondMood then firstGain = 8 else secondGain = 8 end
        profile.Nest.CompanionMood[firstId] = math.min(100, firstMood + firstGain)
        profile.Nest.CompanionMood[secondId] = math.min(100, secondMood + secondGain)
        firstModel:SetAttribute("Mood", profile.Nest.CompanionMood[firstId])
        secondModel:SetAttribute("Mood", profile.Nest.CompanionMood[secondId])
        firstModel:SetAttribute("FriendshipScore", score)
        secondModel:SetAttribute("FriendshipScore", score)
        firstModel:SetAttribute("FriendshipLevel", score >= 90 and "Неразлучные"
            or score >= 60 and "Лучшие друзья" or score >= 30 and "Друзья"
            or score >= 10 and "Приятели" or "Знакомство")
        secondModel:SetAttribute("FriendshipLevel", firstModel:GetAttribute("FriendshipLevel"))

        player:SetAttribute("LastNotice", rare
            and "Питомцы вместе нашли редкий секрет! Их дружба стала крепче."
            or "Питомцы помогли друг другу и нашли общий секрет!")
        if connection then connection:Disconnect() end
        marker:Destroy()
    end)

    marker.Destroying:Connect(function()
        if firstAttachment.Parent then firstAttachment:Destroy() end
        if secondAttachment.Parent then secondAttachment:Destroy() end
        if firstHighlight.Parent then firstHighlight:Destroy() end
        if secondHighlight.Parent then secondHighlight:Destroy() end
    end)
    Debris:AddItem(marker, 90)
    return marker
end

local function tryStartAdventure(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile or not profile.Nest then return end
    profile.Nest.CompanionAdventureCooldowns = profile.Nest.CompanionAdventureCooldowns or {}
    local models = findCompanionModels(player)
    if #models < 2 then return end

    local candidates = {}
    for i = 1, #models - 1 do
        for j = i + 1, #models do
            local first, second = models[i], models[j]
            local firstId = first:GetAttribute("CompanionInstanceId")
            local secondId = second:GetAttribute("CompanionInstanceId")
            local key = getPairKey(firstId, secondId)
            local firstPosition = first:GetPivot().Position
            local secondPosition = second:GetPivot().Position
            local awake = first:GetAttribute("IsSleeping") ~= true and second:GetAttribute("IsSleeping") ~= true
            local mood = math.min(tonumber(first:GetAttribute("Mood")) or 50, tonumber(second:GetAttribute("Mood")) or 50)
            local bond = key and math.floor(tonumber(profile.Nest.CompanionBonds and profile.Nest.CompanionBonds[key]) or 0) or 0
            if key and awake and mood >= 25 and bond >= MIN_BOND and (firstPosition - secondPosition).Magnitude <= MAX_DISTANCE
                and (tonumber(profile.Nest.CompanionAdventureCooldowns[key]) or 0) <= os.time()
                and not activeEvents[key] then
                table.insert(candidates, { First = first, Second = second, Key = key })
            end
        end
    end
    if #candidates == 0 then return end
    local choice = candidates[random:NextInteger(1, #candidates)]
    local rare = random:NextNumber() <= 0.12
    local marker = createAdventureMarker(player, choice.First, choice.Second, choice.Key, rare)
    if not marker then return end

    profile.Nest.CompanionAdventureCooldowns[choice.Key] = os.time() + PAIR_COOLDOWN
    activeEvents[choice.Key] = marker
    choice.First:SetAttribute("AdventureState", "Вместе ищут секрет")
    choice.Second:SetAttribute("AdventureState", "Вместе ищут секрет")
    marker.Destroying:Connect(function()
        activeEvents[choice.Key] = nil
        if choice.First.Parent then choice.First:SetAttribute("AdventureState", nil) end
        if choice.Second.Parent then choice.Second:SetAttribute("AdventureState", nil) end
    end)
end

function CompanionAdventureService:Init()
    Players.PlayerRemoving:Connect(function(player)
        for _, child in ipairs(Workspace:GetChildren()) do
            if child.Name == "PairedAdventureSecret" and child:GetAttribute("OwnerUserId") == player.UserId then
                child:Destroy()
            end
        end
    end)
end

function CompanionAdventureService:Start()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            if player:GetAttribute("ProfileLoaded") then
                local ok, err = pcall(tryStartAdventure, player)
                if not ok then warn("[NEST RAIDERS] Paired adventure failed: " .. tostring(err)) end
            end
        end
        task.wait(ACTIVE_INTERVAL)
    end
end

return CompanionAdventureService
