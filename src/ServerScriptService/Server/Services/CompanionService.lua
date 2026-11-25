local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local NestToyCatalog = require(ReplicatedStorage.Shared.Config.NestToyCatalog)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local CompanionService = {}
CompanionService._folders = {}
CompanionService._displayFolders = {}
CompanionService._generations = {}
local MAX_VISIBLE_COMPANIONS = 3
local FOLLOW_INTERVAL = 0.1
local socialMomentCooldowns = {}
local pairGreetingLastAt = {}
local socialChaseCooldowns = {}
local sharedRestCooldowns = {}
local speciesMomentCooldowns = {}
local companionCareCooldowns = {}
local sharedDiscoveryCooldowns = {}
local pairedBallCooldowns = {}

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
    FrostFox = {
        Body = Color3.fromRGB(166, 218, 242),
        Accent = Color3.fromRGB(245, 252, 255),
        Detail = Color3.fromRGB(90, 142, 181),
        Kind = "Fox",
    },
    SnowOwl = {
        Body = Color3.fromRGB(226, 241, 250),
        Accent = Color3.fromRGB(116, 183, 218),
        Detail = Color3.fromRGB(70, 111, 151),
        Kind = "Owl",
    },
    GlacierBear = {
        Body = Color3.fromRGB(139, 190, 220),
        Accent = Color3.fromRGB(239, 248, 255),
        Detail = Color3.fromRGB(75, 119, 157),
        Kind = "Bear",
    },
    CinderFox = {
        Body = Color3.fromRGB(201, 85, 42), Accent = Color3.fromRGB(255, 186, 85),
        Detail = Color3.fromRGB(83, 51, 45), Kind = "EmberFox",
    },
    MagmaWhelp = {
        Body = Color3.fromRGB(85, 62, 60), Accent = Color3.fromRGB(255, 119, 48),
        Detail = Color3.fromRGB(255, 203, 91), Kind = "MagmaDragon",
    },
    AshPhoenix = {
        Body = Color3.fromRGB(226, 102, 47), Accent = Color3.fromRGB(255, 217, 120),
        Detail = Color3.fromRGB(161, 63, 52), Kind = "Phoenix",
    },
    CinderFox = {
        Body = Color3.fromRGB(201, 85, 42), Accent = Color3.fromRGB(255, 186, 85),
        Detail = Color3.fromRGB(83, 51, 45), Kind = "EmberFox",
    },
    MagmaWhelp = {
        Body = Color3.fromRGB(85, 62, 60), Accent = Color3.fromRGB(255, 119, 48),
        Detail = Color3.fromRGB(255, 203, 91), Kind = "MagmaDragon",
    },
    AshPhoenix = {
        Body = Color3.fromRGB(226, 102, 47), Accent = Color3.fromRGB(255, 217, 120),
        Detail = Color3.fromRGB(161, 63, 52), Kind = "Phoenix",
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
    AncientStag = {
        Body = Color3.fromRGB(132, 112, 79),
        Accent = Color3.fromRGB(189, 164, 112),
        Detail = Color3.fromRGB(105, 151, 91),
        Kind = "AncientStag",
    },
    RootSprite = {
        Body = Color3.fromRGB(104, 163, 103),
        Accent = Color3.fromRGB(184, 204, 119),
        Detail = Color3.fromRGB(82, 119, 76),
        Kind = "RootSprite",
    },
    SkySerpent = {
        Body = Color3.fromRGB(112, 167, 194),
        Accent = Color3.fromRGB(202, 225, 222),
        Detail = Color3.fromRGB(149, 130, 203),
        Kind = "SkySerpent",
    },
    CaveGlimmerbat = {
        Body = Color3.fromRGB(91, 119, 166),
        Accent = Color3.fromRGB(154, 224, 255),
        Detail = Color3.fromRGB(72, 78, 128),
        Kind = "CaveGlimmerbat",
    },
    CrystalProwler = {
        Body = Color3.fromRGB(116, 157, 167),
        Accent = Color3.fromRGB(195, 239, 244),
        Detail = Color3.fromRGB(103, 116, 185),
        Kind = "CrystalProwler",
    },
    HeartWisp = {
        Body = Color3.fromRGB(135, 109, 190),
        Accent = Color3.fromRGB(255, 222, 154),
        Detail = Color3.fromRGB(180, 239, 232),
        Kind = "HeartWisp",
    },
    ForgottenHeartGuardian = {
        Body = Color3.fromRGB(81, 111, 130),
        Accent = Color3.fromRGB(126, 224, 246),
        Detail = Color3.fromRGB(181, 147, 235),
        Kind = "ForgottenHeartGuardian",
    },
    HeartwoodGuardian = {
        Body = Color3.fromRGB(105, 145, 91),
        Accent = Color3.fromRGB(205, 190, 126),
        Detail = Color3.fromRGB(79, 105, 65),
        Kind = "HeartwoodGuardian",
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

local function getBondKey(firstId, secondId)
    local first = tostring(firstId or "")
    local second = tostring(secondId or "")
    if first == "" or second == "" or first == second then return nil end
    if first > second then first, second = second, first end
    return first .. "|" .. second
end

local GIFT_COOLDOWNS = {}

local BIOME_GIFTS = {
    MeadowEgg = { { Name = "Букет луговых цветов", Icon = "🌼" }, { Name = "Корзинка сладких ягод", Icon = "🫐" }, { Name = "Резной желудь", Icon = "🌰" } },
    EmeraldEgg = { { Name = "Светящийся лист", Icon = "🍃" }, { Name = "Лесной кристалл", Icon = "💎" }, { Name = "Живой росток", Icon = "🌱" } },
    FrostEgg = { { Name = "Снежная брошь", Icon = "❄️" }, { Name = "Ледяная звезда", Icon = "⭐" }, { Name = "Морозная ракушка", Icon = "🐚" } },
    EmberEgg = { { Name = "Тёплый уголь-сердечко", Icon = "🔥" }, { Name = "Солнечная бусина", Icon = "☀️" }, { Name = "Янтарный осколок", Icon = "🟠" } },
    CrystalEgg = { { Name = "Призматический осколок", Icon = "💠" }, { Name = "Лунная груша", Icon = "🍐" }, { Name = "Звёздный нектар", Icon = "✨" } },
    AncientEgg = { { Name = "Золотой желудь", Icon = "🌰" }, { Name = "Семя древнего дерева", Icon = "🌳" }, { Name = "Лепесток вечности", Icon = "🌸" } },
    ForgottenCaveEgg = { { Name = "Светящийся гриб", Icon = "🍄" }, { Name = "Камень эха", Icon = "🔮" }, { Name = "Осколок сердца пещеры", Icon = "💜" } },
    LineageEgg = { { Name = "Реликвия рода", Icon = "🏵️" }, { Name = "Семя предков", Icon = "🌿" }, { Name = "Семейный талисман", Icon = "🧿" } },
}
local PERSONALITY_GIFT_BONUS = {
    ["Заботливый"] = 0.10, ["Добродушный"] = 0.08, ["Дружелюбный"] = 0.08,
    ["Мечтательный"] = 0.05, ["Гордый"] = -0.04, ["Независимый"] = -0.05,
    ["Осторожный"] = -0.03,
}
local RARITY_SPECIAL_GIFT_BONUS = {
    ["Необычный"] = 0.02,
    ["Редкий"] = 0.04,
    ["Эпический"] = 0.07,
    ["Легендарный"] = 0.10,
    ["Мифический"] = 0.14,
}
local COMPANION_HABITS = {
    ["Любопытный"] = { Id = "SniffAround", Text = "Обнюхивает всё вокруг", Chance = 0.22 },
    ["Любознательный"] = { Id = "Inspect", Text = "Изучает интересную находку", Chance = 0.24 },
    ["Игривый"] = { Id = "PlayfulHop", Text = "Придумывает себе игру", Chance = 0.24 },
    ["Энергичный"] = { Id = "Stretch", Text = "Разминается перед приключением", Chance = 0.20 },
    ["Спокойный"] = { Id = "Groom", Text = "Умывается и приводит себя в порядок", Chance = 0.20 },
    ["Осторожный"] = { Id = "LookAround", Text = "Осторожно осматривается", Chance = 0.22 },
    ["Мечтательный"] = { Id = "Daydream", Text = "Мечтает о дальних островах", Chance = 0.22 },
    ["Наблюдательный"] = { Id = "WatchSky", Text = "Наблюдает за небом", Chance = 0.20 },
    ["Добродушный"] = { Id = "Sway", Text = "Довольно покачивается", Chance = 0.18 },
    ["Дружелюбный"] = { Id = "Wave", Text = "Ищет взглядом друзей", Chance = 0.20 },
    ["Заботливый"] = { Id = "Care", Text = "Проверяет, всё ли в порядке", Chance = 0.18 },
    ["Гордый"] = { Id = "Proud", Text = "Демонстрирует свою осанку", Chance = 0.18 },
}

local GIFT_RECEIVER_REACTIONS = {
    ["Игривый"] = { Animation = "Spin", Text = "Ура! Спасибо!" },
    ["Энергичный"] = { Animation = "Jump", Text = "Вау! Как здорово!" },
    ["Дружелюбный"] = { Animation = "Hug", Text = "Как мило! Спасибо!" },
    ["Добродушный"] = { Animation = "Hug", Text = "Ты такой хороший друг!" },
    ["Заботливый"] = { Animation = "Hug", Text = "Обнимашки!" },
    ["Осторожный"] = { Animation = "Shy", Text = "Ой… это мне?" },
    ["Спокойный"] = { Animation = "Sway", Text = "Как приятно…" },
    ["Мечтательный"] = { Animation = "Dream", Text = "Настоящее чудо!" },
    ["Гордый"] = { Animation = "Proud", Text = "Хм… мне нравится!" },
    ["Независимый"] = { Animation = "Shy", Text = "Спасибо, друг." },
    ["Любопытный"] = { Animation = "Spin", Text = "Что же это?" },
    ["Любознательный"] = { Animation = "Spin", Text = "Надо рассмотреть!" },
}
local GIFT_GIVER_REACTIONS = {
    ["Игривый"] = { Animation = "Bounce", Text = "Сюрприз!" },
    ["Энергичный"] = { Animation = "Jump", Text = "Я нашёл это для тебя!" },
    ["Заботливый"] = { Animation = "Proud", Text = "Я хотел тебя порадовать." },
    ["Дружелюбный"] = { Animation = "Sway", Text = "Рад поделиться!" },
    ["Добродушный"] = { Animation = "Sway", Text = "Это тебе, дружок!" },
    ["Осторожный"] = { Animation = "Shy", Text = "Я… приготовил кое-что." },
    ["Мечтательный"] = { Animation = "Dream", Text = "Маленькое чудо для тебя." },
}
local function setGiftReaction(model, reaction, duration, rare)
    if not model or not model.Parent then return end
    model:SetAttribute("GiftReaction", reaction.Animation)
    model:SetAttribute("GiftReactionText", rare and "Невероятно!" or reaction.Text)
    model:SetAttribute("GiftReactionUntil", os.clock() + duration)
    model:SetAttribute("GiftReactionRare", rare == true)
end

local function showCompanionGift(giverModel, receiverModel, gift, isRare)
    if not giverModel or not giverModel.Parent or not receiverModel or not receiverModel.Parent then return end
    receiverModel:SetAttribute("LastGiftReceived", gift.Name)
    receiverModel:SetAttribute("GiftReceivedAt", os.time())
    local adornee = receiverModel:FindFirstChild("Head") or receiverModel.PrimaryPart
    if not adornee then return end

    local bubble = Instance.new("BillboardGui")
    bubble.Name = "CompanionGiftMoment"
    bubble.Adornee = adornee
    bubble.Size = UDim2.fromOffset(204, 54)
    bubble.StudsOffset = Vector3.new(0, 1.8, 0)
    bubble.AlwaysOnTop = false
    bubble.Parent = receiverModel

    local card = Instance.new("TextLabel")
    card.Size = UDim2.fromScale(1, 1)
    card.BackgroundColor3 = Color3.fromRGB(35, 43, 55)
    card.BackgroundTransparency = 0.08
    card.BorderSizePixel = 0
    card.Font = Enum.Font.GothamBold
    card.TextSize = 12
    card.TextWrapped = true
    card.TextColor3 = isRare and Color3.fromRGB(255, 211, 125) or Color3.fromRGB(222, 245, 225)
    card.Text = gift.Icon .. " " .. (isRare and "Особенный подарок! " or "Подарок другу! ") .. gift.Name
    card.Parent = bubble
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card
    local stroke = Instance.new("UIStroke")
    stroke.Color = card.TextColor3
    stroke.Transparency = 0.25
    stroke.Thickness = 1.3
    stroke.Parent = card

    local light = Instance.new("PointLight")
    light.Name = "GiftMomentGlow"
    light.Color = isRare and Color3.fromRGB(255, 205, 112) or Color3.fromRGB(142, 226, 173)
    light.Range = 5
    light.Brightness = 0.8
    light.Parent = adornee
    task.delay(2.8, function()
        if bubble.Parent then bubble:Destroy() end
        if light.Parent then light:Destroy() end
    end)
end

local function tryGiveCompanionGift(player, profile, giverModel, receiverModel, giverDefinition, pairKey, bondScore, now, random)
    if not pairKey or not giverDefinition or not receiverModel then return end
    local cooldownKey = tostring(player.UserId) .. ":" .. pairKey
    if (GIFT_COOLDOWNS[cooldownKey] or 0) > now then return end

    local chance = bondScore >= 90 and 0.30
        or bondScore >= 60 and 0.22
        or bondScore >= 30 and 0.14
        or bondScore >= 10 and 0.08
        or 0.03
    chance = math.clamp(chance + (PERSONALITY_GIFT_BONUS[giverDefinition.Personality or ""] or 0), 0.02, 0.40)
    if random:NextNumber() > chance then return end

    local gifts = BIOME_GIFTS[giverDefinition.EggId] or BIOME_GIFTS.MeadowEgg
    local gift = gifts[random:NextInteger(1, #gifts)]
    local rareChance = bondScore >= 90 and 0.20
        or bondScore >= 60 and 0.14
        or bondScore >= 30 and 0.09
        or 0.04
    rareChance = math.clamp(rareChance + (RARITY_SPECIAL_GIFT_BONUS[giverDefinition.Rarity or ""] or 0), 0.02, 0.35)
    local isRare = random:NextNumber() <= rareChance
    if isRare then
        gift = { Name = "Особенный дар: " .. gift.Name, Icon = "💖" }
    end

    GIFT_COOLDOWNS[cooldownKey] = now + 90
    profile.Nest.DiscoveredCompanionGifts = profile.Nest.DiscoveredCompanionGifts or {}
    profile.Nest.CompanionGiftCount = math.max(0, math.floor(tonumber(profile.Nest.CompanionGiftCount) or 0)) + 1
    local giftKey = tostring(giverDefinition.EggId or "MeadowEgg") .. ":" .. gift.Name
    local isNewDiscovery = profile.Nest.DiscoveredCompanionGifts[giftKey] ~= true
    profile.Nest.DiscoveredCompanionGifts[giftKey] = true

    local receiverId = receiverModel:GetAttribute("CompanionInstanceId")
    local giverId = giverModel:GetAttribute("CompanionInstanceId")
    profile.Nest.CompanionMood = profile.Nest.CompanionMood or {}
    local receiverMood = math.clamp(math.floor(tonumber(profile.Nest.CompanionMood[receiverId])
        or tonumber(receiverModel:GetAttribute("Mood")) or 50) + 5, 0, 100)
    local giverMood = math.clamp(math.floor(tonumber(profile.Nest.CompanionMood[giverId])
        or tonumber(giverModel:GetAttribute("Mood")) or 50) + 2, 0, 100)
    profile.Nest.CompanionMood[receiverId] = receiverMood
    profile.Nest.CompanionMood[giverId] = giverMood
    receiverModel:SetAttribute("Mood", receiverMood)
    giverModel:SetAttribute("Mood", giverMood)

    showCompanionGift(giverModel, receiverModel, gift, isRare)
    local duration = isRare and 3.6 or 2.8
    local receiverPersonality = receiverModel:GetAttribute("Personality") or ""
    local giverPersonality = giverModel:GetAttribute("Personality") or ""
    local receiverReaction = GIFT_RECEIVER_REACTIONS[receiverPersonality]
        or { Animation = "Jump", Text = "Спасибо за подарок!" }
    local giverReaction = GIFT_GIVER_REACTIONS[giverPersonality]
        or { Animation = "Proud", Text = "Это для тебя!" }
    if isRare then
        receiverReaction = { Animation = "Amazed", Text = "Невероятный подарок!" }
        giverReaction = { Animation = "Proud", Text = "Я нашёл нечто особенное!" }
    end
    setGiftReaction(receiverModel, receiverReaction, duration, isRare)
    setGiftReaction(giverModel, giverReaction, duration * 0.9, isRare)
    player:SetAttribute("LastNotice", isNewDiscovery and ("Новое воспоминание: " .. gift.Name)
        or ("Питомец подарил другу: " .. gift.Name))
end

local function getBondLevel(score)
    if score >= 90 then return "Неразлучные" end
    if score >= 60 then return "Лучшие друзья" end
    if score >= 30 then return "Друзья" end
    if score >= 10 then return "Приятели" end
    return "Знакомство"
end

local BOND_MILESTONES = {
    [10] = { Title = "Первые друзья!", Color = Color3.fromRGB(116, 222, 174) },
    [30] = { Title = "Крепкая дружба!", Color = Color3.fromRGB(104, 194, 255) },
    [60] = { Title = "Неразлучная команда!", Color = Color3.fromRGB(194, 139, 255) },
    [80] = { Title = "Дружба без границ!", Color = Color3.fromRGB(225, 157, 255) },
    [90] = { Title = "Друзья навсегда!", Color = Color3.fromRGB(255, 205, 112) },
    [100] = { Title = "Вместе навеки!", Color = Color3.fromRGB(255, 225, 145) },
}
local PAIR_BOND_MEMORIES = {
    [60] = { Id = "TrustedPact", Title = "Тайный знак дружбы", Icon = "🤝", Color = Color3.fromRGB(194, 139, 255), Text = "Питомцы придумали собственный знак дружбы" },
    [80] = { Id = "UnbreakablePromise", Title = "Обещание неразлучности", Icon = "💞", Color = Color3.fromRGB(225, 157, 255), Text = "Друзья обещают всегда поддерживать друг друга" },
    [100] = { Id = "ForeverTogether", Title = "Друзья навеки", Icon = "🌟", Color = Color3.fromRGB(255, 225, 145), Text = "Их дружба стала по-настоящему особенной" },
}

local function showBondMilestone(player, firstModel, secondModel, milestone)
    if not firstModel or not secondModel or not milestone then return end
    for _, model in ipairs({ firstModel, secondModel }) do
        model:SetAttribute("BondMoment", milestone.Title)
        model:SetAttribute("BondMomentUntil", os.clock() + 2.4)
        local glow = Instance.new("Highlight")
        glow.Name = "FriendshipMilestoneGlow"
        glow.Adornee = model
        glow.FillColor = milestone.Color
        glow.OutlineColor = milestone.Color
        glow.FillTransparency = 0.48
        glow.OutlineTransparency = 0.05
        glow.DepthMode = Enum.HighlightDepthMode.Occluded
        glow.Parent = model
        task.delay(2.4, function()
            if glow.Parent then glow:Destroy() end
            if model.Parent and model:GetAttribute("BondMoment") == milestone.Title then
                model:SetAttribute("BondMoment", nil)
                model:SetAttribute("BondMomentUntil", nil)
            end
        end)
    end

    local root = firstModel.PrimaryPart
    if root then
        local banner = Instance.new("BillboardGui")
        banner.Name = "FriendshipMilestoneBanner"
        banner.Adornee = root
        banner.Size = UDim2.fromOffset(220, 42)
        banner.StudsOffset = Vector3.new(0, 4.1, 0)
        banner.AlwaysOnTop = true
        banner.Parent = firstModel
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundColor3 = Color3.fromRGB(28, 37, 49)
        label.BackgroundTransparency = 0.08
        label.BorderSizePixel = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextColor3 = milestone.Color
        label.Text = "✦ " .. milestone.Title .. " ✦"
        label.Parent = banner
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = label
        task.delay(2.4, function()
            if banner.Parent then banner:Destroy() end
        end)
    end
    player:SetAttribute("LastNotice", "Новый этап дружбы: " .. milestone.Title)
end

local function showSharedHeartMoment(firstModel, secondModel)
    for _, model in ipairs({ firstModel, secondModel }) do
        if model and model.Parent then
            local head = model:FindFirstChild("Head")
            local adornee = head or model.PrimaryPart
            if adornee then
                local bubble = Instance.new("BillboardGui")
                bubble.Name = "SharedFriendshipHeart"
                bubble.Adornee = adornee
                bubble.Size = UDim2.fromOffset(42, 42)
                bubble.StudsOffset = Vector3.new(0, 1.05, 0)
                bubble.AlwaysOnTop = true
                bubble.Parent = model
                local heart = Instance.new("TextLabel")
                heart.Name = "Heart"
                heart.Size = UDim2.fromScale(1, 1)
                heart.BackgroundTransparency = 1
                heart.Font = Enum.Font.GothamBold
                heart.Text = "♥"
                heart.TextColor3 = Color3.fromRGB(255, 112, 153)
                heart.TextStrokeColor3 = Color3.fromRGB(75, 35, 54)
                heart.TextStrokeTransparency = 0.25
                heart.TextScaled = true
                heart.Parent = bubble
                task.delay(1.6, function()
                    if bubble.Parent then bubble:Destroy() end
                end)
            end
        end
    end
end

local function showPairedBallGame(firstModel, secondModel, ownerUserId, pairKey, personality, now)
    if not firstModel or not secondModel or not firstModel.Parent or not secondModel.Parent then return false end
    if firstModel.Parent ~= secondModel.Parent then return false end
    local firstPosition = firstModel:GetPivot().Position
    local secondPosition = secondModel:GetPivot().Position
    if (firstPosition - secondPosition).Magnitude > 12 then return false end

    local ballColor = (personality == "Энергичный" or personality == "Игривый")
        and Color3.fromRGB(255, 205, 91)
        or personality == "Дружелюбный" and Color3.fromRGB(255, 132, 174)
        or personality == "Спокойный" and Color3.fromRGB(133, 221, 184)
        or Color3.fromRGB(117, 205, 245)

    local ball = Instance.new("Part")
    ball.Name = "CompanionFriendshipBall"
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(0.62, 0.62, 0.62)
    ball.Material = Enum.Material.Neon
    ball.Color = ballColor
    ball.Anchored = true
    ball.CanCollide = false
    ball.CanTouch = false
    ball.CanQuery = false
    ball.CastShadow = false
    ball:SetAttribute("OwnerUserId", ownerUserId)
    ball:SetAttribute("PairKey", pairKey)
    ball.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Color = ballColor
    light.Brightness = 0.7
    light.Range = 7
    light.Parent = ball

    local bubble = Instance.new("BillboardGui")
    bubble.Name = "CompanionBallGameLabel"
    bubble.Size = UDim2.fromOffset(76, 22)
    bubble.StudsOffset = Vector3.new(0, 0.72, 0)
    bubble.AlwaysOnTop = false
    bubble.Adornee = ball
    bubble.Parent = ball

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = "ПАС!"
    label.TextColor3 = Color3.fromRGB(255, 255, 244)
    label.TextStrokeColor3 = Color3.fromRGB(38, 54, 65)
    label.TextStrokeTransparency = 0.2
    label.TextScaled = true
    label.Parent = bubble

    local initial = (firstPosition + secondPosition) * 0.5 + Vector3.new(0, 1.25, 0)
    ball.Position = initial
    Debris:AddItem(ball, 4.5)

    task.spawn(function()
        for pass = 1, 5 do
            if not ball.Parent or not firstModel.Parent or not secondModel.Parent then break end
            local receiver = pass % 2 == 1 and secondModel or firstModel
            local targetPosition = receiver:GetPivot().Position + Vector3.new(0, 1.25, 0)
            local tween = TweenService:Create(
                ball,
                TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { Position = targetPosition }
            )
            tween:Play()
            local playbackState = tween.Completed:Wait()
            if playbackState ~= Enum.PlaybackState.Completed then break end
        end
        if ball.Parent then ball:Destroy() end
    end)
    return true
end

local GREETING_STYLES = {
    ["Дружелюбный"] = { Icon = "♥", Color = Color3.fromRGB(255, 125, 166), Text = "Рад тебя видеть!" },
    ["Добродушный"] = { Icon = "♥", Color = Color3.fromRGB(255, 174, 120), Text = "Привет, друг!" },
    ["Игривый"] = { Icon = "✦", Color = Color3.fromRGB(255, 218, 112), Text = "Поиграем?" },
    ["Энергичный"] = { Icon = "★", Color = Color3.fromRGB(255, 205, 105), Text = "Ура, ты здесь!" },
    ["Осторожный"] = { Icon = "…", Color = Color3.fromRGB(153, 205, 224), Text = "Привет…" },
    ["Спокойный"] = { Icon = "❀", Color = Color3.fromRGB(155, 213, 175), Text = "Рад встрече" },
    ["Мудрый"] = { Icon = "✧", Color = Color3.fromRGB(183, 177, 235), Text = "Снова вместе" },
    ["Мечтательный"] = { Icon = "☾", Color = Color3.fromRGB(173, 180, 255), Text = "Как хорошо…" },
}

local function showPersonalityGreeting(firstModel, secondModel, firstPersonality, secondPersonality, reunion)
    local models = {
        { Model = firstModel, Personality = firstPersonality },
        { Model = secondModel, Personality = secondPersonality },
    }
    for _, entry in ipairs(models) do
        local model = entry.Model
        if model and model.Parent then
            local style = GREETING_STYLES[entry.Personality] or {
                Icon = "♥", Color = Color3.fromRGB(255, 150, 175), Text = "Привет!"
            }
            local adornee = model:FindFirstChild("Head") or model.PrimaryPart
            if adornee then
                local bubble = Instance.new("BillboardGui")
                bubble.Name = reunion and "FriendshipReunionGreeting" or "PersonalityGreeting"
                bubble.Adornee = adornee
                bubble.Size = UDim2.fromOffset(154, reunion and 48 or 40)
                bubble.StudsOffset = Vector3.new(0, reunion and 1.45 or 1.15, 0)
                bubble.AlwaysOnTop = false
                bubble.Parent = model

                local label = Instance.new("TextLabel")
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundColor3 = Color3.fromRGB(28, 37, 49)
                label.BackgroundTransparency = 0.12
                label.BorderSizePixel = 0
                label.Font = Enum.Font.GothamBold
                label.TextScaled = true
                label.TextWrapped = true
                label.TextColor3 = style.Color
                label.Text = reunion and ("✦ " .. style.Text .. " ✦") or (style.Icon .. " " .. style.Text)
                label.Parent = bubble
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = label
                local stroke = Instance.new("UIStroke")
                stroke.Color = style.Color
                stroke.Transparency = 0.35
                stroke.Thickness = 1.2
                stroke.Parent = label
                task.delay(reunion and 3.2 or 2.1, function()
                    if bubble.Parent then bubble:Destroy() end
                end)
            end
        end
    end

    if reunion then
        for _, model in ipairs({ firstModel, secondModel }) do
            if model and model.Parent then
                local glow = Instance.new("Highlight")
                glow.Name = "FriendshipReunionGlow"
                glow.Adornee = model
                glow.FillColor = Color3.fromRGB(255, 211, 137)
                glow.OutlineColor = Color3.fromRGB(255, 230, 175)
                glow.FillTransparency = 0.72
                glow.OutlineTransparency = 0.12
                glow.DepthMode = Enum.HighlightDepthMode.Occluded
                glow.Parent = model
                task.delay(3.2, function()
                    if glow.Parent then glow:Destroy() end
                end)
            end
        end
    end
end

local SPECIES_BOND_MOMENTS = {
    ["Fox|Turtle"] = { Title = "Лесные хранители", Icon = "🍃", Color = Color3.fromRGB(151, 207, 119), Text = "Лис показывает черепахе тайную тропу" },
    ["Dragon|Owl"] = { Title = "Искра мудрости", Icon = "✨", Color = Color3.fromRGB(157, 190, 255), Text = "Дракон делится искоркой с мудрой совой" },
    ["EmberFox|MagmaDragon"] = { Title = "Тёплое пламя", Icon = "🔥", Color = Color3.fromRGB(255, 157, 91), Text = "Два огненных друга создают общий вихрь искр" },
    ["AncientStag|RootSprite"] = { Title = "Древний союз", Icon = "🌿", Color = Color3.fromRGB(177, 208, 125), Text = "Духи леса пробуждают маленький росток" },
}

local function getSpeciesMomentKey(firstKind, secondKind)
    if not firstKind or not secondKind then return nil end
    if firstKind > secondKind then firstKind, secondKind = secondKind, firstKind end
    return firstKind .. "|" .. secondKind
end

local function showSpeciesBondMoment(firstModel, secondModel, moment)
    for _, model in ipairs({ firstModel, secondModel }) do
        if model and model.Parent then
            model:SetAttribute("SpeciesBondMoment", moment.Title)
            model:SetAttribute("SpeciesBondMomentUntil", os.clock() + 3.4)
            local adornee = model:FindFirstChild("Head") or model.PrimaryPart
            if adornee then
                local bubble = Instance.new("BillboardGui")
                bubble.Name = "SpeciesBondMoment"
                bubble.Adornee = adornee
                bubble.Size = UDim2.fromOffset(178, 52)
                bubble.StudsOffset = Vector3.new(0, 1.65, 0)
                bubble.AlwaysOnTop = false
                bubble.Parent = model
                local label = Instance.new("TextLabel")
                label.Size = UDim2.fromScale(1, 1)
                label.BackgroundColor3 = Color3.fromRGB(27, 39, 48)
                label.BackgroundTransparency = 0.08
                label.BorderSizePixel = 0
                label.Font = Enum.Font.GothamBold
                label.TextScaled = true
                label.TextWrapped = true
                label.TextColor3 = moment.Color
                label.Text = moment.Icon .. " " .. moment.Title
                label.Parent = bubble
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = label
                local stroke = Instance.new("UIStroke")
                stroke.Color = moment.Color
                stroke.Transparency = 0.25
                stroke.Thickness = 1.4
                stroke.Parent = label
                task.delay(3.4, function()
                    if bubble.Parent then bubble:Destroy() end
                end)
            end
            local glow = Instance.new("Highlight")
            glow.Name = "SpeciesBondGlow"
            glow.Adornee = model
            glow.FillColor = moment.Color
            glow.OutlineColor = moment.Color
            glow.FillTransparency = 0.78
            glow.OutlineTransparency = 0.15
            glow.DepthMode = Enum.HighlightDepthMode.Occluded
            glow.Parent = model
            task.delay(3.4, function()
                if glow.Parent then glow:Destroy() end
                if model.Parent and model:GetAttribute("SpeciesBondMoment") == moment.Title then
                    model:SetAttribute("SpeciesBondMoment", nil)
                    model:SetAttribute("SpeciesBondMomentUntil", nil)
                end
            end)
        end
    end
end
local function buildPet(parent, companion, index)
    local definition = DEFINITIONS[companion.Id] or DEFINITIONS.MeadowFox
    local model = Instance.new("Model")
    model.Name = string.format("%s_%d", companion.Id, index)
    model:SetAttribute("CompanionId", companion.Id)
    model:SetAttribute("CompanionInstanceId", companion.InstanceId or "")
    model:SetAttribute("CompanionKind", definition.Kind or companion.Id)
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
    elseif definition.Kind == "MagmaDragon" then
        makeShape(model, "Snout", Vector3.new(0.8, 0.55, 0.65), Vector3.new(0, 1.55, 1.2), definition.Accent)
        makeShape(model, "LeftWing", Vector3.new(0.55, 1.25, 1.35), Vector3.new(-1.05, 1.55, -0.1), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightWing", Vector3.new(0.55, 1.25, 1.35), Vector3.new(1.05, 1.55, -0.1), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(0.5, 0.5, 1.5), Vector3.new(0, 1.0, -1.2), definition.Accent)
        makeShape(model, "LeftHorn", Vector3.new(0.25, 0.65, 0.25), Vector3.new(-0.45, 2.5, 0.25), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightHorn", Vector3.new(0.25, 0.65, 0.25), Vector3.new(0.45, 2.5, 0.25), definition.Detail, Enum.PartType.Wedge)
    elseif definition.Kind == "Phoenix" then
        makeShape(model, "Beak", Vector3.new(0.42, 0.55, 0.42), Vector3.new(0, 1.65, 1.15), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "LeftWing", Vector3.new(0.5, 1.25, 1.4), Vector3.new(-1.05, 1.25, -0.1), definition.Accent)
        makeShape(model, "RightWing", Vector3.new(0.5, 1.25, 1.4), Vector3.new(1.05, 1.25, -0.1), definition.Accent)
        makeShape(model, "Crest", Vector3.new(0.35, 0.8, 0.35), Vector3.new(0, 2.55, 0.35), definition.Detail, Enum.PartType.Wedge)
    elseif definition.Kind == "MagmaDragon" then
        makeShape(model, "Snout", Vector3.new(0.8, 0.55, 0.65), Vector3.new(0, 1.55, 1.2), definition.Accent)
        makeShape(model, "LeftWing", Vector3.new(0.55, 1.25, 1.35), Vector3.new(-1.05, 1.55, -0.1), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightWing", Vector3.new(0.55, 1.25, 1.35), Vector3.new(1.05, 1.55, -0.1), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(0.5, 0.5, 1.5), Vector3.new(0, 1.0, -1.2), definition.Accent)
        makeShape(model, "LeftHorn", Vector3.new(0.25, 0.65, 0.25), Vector3.new(-0.45, 2.5, 0.25), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightHorn", Vector3.new(0.25, 0.65, 0.25), Vector3.new(0.45, 2.5, 0.25), definition.Detail, Enum.PartType.Wedge)
    elseif definition.Kind == "Phoenix" then
        makeShape(model, "Beak", Vector3.new(0.42, 0.55, 0.42), Vector3.new(0, 1.65, 1.15), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "LeftWing", Vector3.new(0.5, 1.25, 1.4), Vector3.new(-1.05, 1.25, -0.1), definition.Accent)
        makeShape(model, "RightWing", Vector3.new(0.5, 1.25, 1.4), Vector3.new(1.05, 1.25, -0.1), definition.Accent)
        makeShape(model, "Crest", Vector3.new(0.35, 0.8, 0.35), Vector3.new(0, 2.55, 0.35), definition.Detail, Enum.PartType.Wedge)
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

    elseif definition.Kind == "AncientStag" then
        makeShape(model, "Muzzle", Vector3.new(0.8, 0.5, 0.6), Vector3.new(0, 1.6, 1.15), definition.Accent)
        makeShape(model, "LeftEar", Vector3.new(0.4, 0.65, 0.35), Vector3.new(-0.55, 2.35, 0.35), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightEar", Vector3.new(0.4, 0.65, 0.35), Vector3.new(0.55, 2.35, 0.35), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "LeftAntler", Vector3.new(0.25, 1.25, 0.25), Vector3.new(-0.42, 3.0, 0.15), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightAntler", Vector3.new(0.25, 1.25, 0.25), Vector3.new(0.42, 3.0, 0.15), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "LeafTail", Vector3.new(0.65, 0.8, 0.65), Vector3.new(0, 1.25, -1.05), definition.Detail)
    elseif definition.Kind == "RootSprite" then
        makeShape(model, "MossCap", Vector3.new(2.0, 0.55, 1.8), Vector3.new(0, 2.2, 0), definition.Accent)
        for index = 1, 3 do
            local angle = index * math.pi * 2 / 3
            makeShape(model, "RootVine", Vector3.new(0.3, 1.15, 0.3),
                Vector3.new(math.cos(angle) * 0.9, 0.75, math.sin(angle) * 0.9), definition.Detail)
        end
        makeShape(model, "Sprout", Vector3.new(0.45, 0.85, 0.3), Vector3.new(0, 2.85, 0), definition.Detail, Enum.PartType.Wedge)
    elseif definition.Kind == "CaveGlimmerbat" then
        makeShape(model, "BatEarLeft", Vector3.new(0.35, 1.0, 0.25), Vector3.new(-0.52, 2.55, 0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "BatEarRight", Vector3.new(0.35, 1.0, 0.25), Vector3.new(0.52, 2.55, 0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "WingLeft", Vector3.new(0.35, 1.2, 1.35), Vector3.new(-1.15, 1.35, -0.15), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "WingRight", Vector3.new(0.35, 1.2, 1.35), Vector3.new(1.15, 1.35, -0.15), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "GlowMark", Vector3.new(0.45, 0.45, 0.2), Vector3.new(0, 1.55, 1.05), definition.Accent)
    elseif definition.Kind == "CrystalProwler" then
        makeShape(model, "Muzzle", Vector3.new(0.8, 0.45, 0.6), Vector3.new(0, 1.58, 1.15), definition.Accent)
        makeShape(model, "EarLeft", Vector3.new(0.42, 0.85, 0.35), Vector3.new(-0.48, 2.55, 0.3), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "EarRight", Vector3.new(0.42, 0.85, 0.35), Vector3.new(0.48, 2.55, 0.3), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "CrystalCrest", Vector3.new(0.4, 1.05, 0.4), Vector3.new(0, 2.7, 0.15), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "CrystalTail", Vector3.new(0.55, 0.55, 1.45), Vector3.new(0, 1.25, -1.2), definition.Detail, Enum.PartType.Wedge)
    elseif definition.Kind == "ForgottenHeartGuardian" then
        makeShape(model, "ChestHeart", Vector3.new(0.95, 0.95, 0.55), Vector3.new(0, 1.75, 1.0), definition.Accent)
        makeShape(model, "ShoulderCrystalLeft", Vector3.new(0.65, 1.0, 0.65), Vector3.new(-1.05, 2.0, 0), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "ShoulderCrystalRight", Vector3.new(0.65, 1.0, 0.65), Vector3.new(1.05, 2.0, 0), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "CrownCrystal", Vector3.new(0.55, 1.15, 0.55), Vector3.new(0, 2.85, 0.15), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "LeftGauntlet", Vector3.new(0.75, 0.85, 0.75), Vector3.new(-1.25, 0.95, 0.3), definition.Detail)
        makeShape(model, "RightGauntlet", Vector3.new(0.75, 0.85, 0.75), Vector3.new(1.25, 0.95, 0.3), definition.Detail)
        local heartLight = Instance.new("PointLight")
        heartLight.Color = definition.Accent
        heartLight.Range = 11
        heartLight.Brightness = 1.4
        heartLight.Parent = body
    elseif definition.Kind == "HeartWisp" then
        makeShape(model, "Halo", Vector3.new(1.8, 0.22, 1.8), Vector3.new(0, 2.85, 0), definition.Accent, Enum.PartType.Cylinder)
        makeShape(model, "Core", Vector3.new(0.9, 0.9, 0.9), Vector3.new(0, 1.9, 0.1), definition.Detail)
        makeShape(model, "FlameTop", Vector3.new(0.5, 1.0, 0.5), Vector3.new(0, 3.25, 0), definition.Accent, Enum.PartType.Ball)
        local aura = Instance.new("PointLight")
        aura.Color = definition.Accent
        aura.Range = 12
        aura.Brightness = 1.5
        aura.Parent = body
    elseif definition.Kind == "SkySerpent" then
        makeShape(model, "SerpentSnout", Vector3.new(0.75, 0.45, 0.9), Vector3.new(0, 1.6, 1.15), definition.Accent)
        makeShape(model, "Crest", Vector3.new(0.3, 0.85, 0.3), Vector3.new(0, 2.55, 0.25), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "LeftFin", Vector3.new(0.5, 1.0, 1.4), Vector3.new(-1.05, 1.45, -0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightFin", Vector3.new(0.5, 1.0, 1.4), Vector3.new(1.05, 1.45, -0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "CloudTail", Vector3.new(0.65, 0.65, 1.5), Vector3.new(0, 1.0, -1.3), definition.Accent)
    elseif definition.Kind == "HeartwoodGuardian" then
        makeShape(model, "HeartwoodMuzzle", Vector3.new(0.8, 0.55, 0.65),
            Vector3.new(0, 1.55, 1.15), definition.Accent)
        makeShape(model, "HeartwoodCrown", Vector3.new(1.65, 0.5, 1.5),
            Vector3.new(0, 2.45, 0.1), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "LeftBranchAntler", Vector3.new(0.3, 1.25, 0.3),
            Vector3.new(-0.55, 3.0, 0.1), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightBranchAntler", Vector3.new(0.3, 1.25, 0.3),
            Vector3.new(0.55, 3.0, 0.1), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "HeartwoodCore", Vector3.new(0.9, 0.9, 0.55),
            Vector3.new(0, 1.25, 0.95), Color3.fromRGB(190, 239, 133), Enum.PartType.Ball)
        makeShape(model, "LeftLeafMantle", Vector3.new(0.55, 1.0, 1.35),
            Vector3.new(-1.0, 1.6, -0.1), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightLeafMantle", Vector3.new(0.55, 1.0, 1.35),
            Vector3.new(1.0, 1.6, -0.1), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RootTail", Vector3.new(0.65, 0.65, 1.45),
            Vector3.new(0, 1.0, -1.25), definition.Detail, Enum.PartType.Wedge)
    elseif definition.Kind == "Owl" then
        makeShape(model, "Beak", Vector3.new(0.42, 0.55, 0.42), Vector3.new(0, 1.65, 1.25), Color3.fromRGB(255, 193, 93), Enum.PartType.Wedge)
        makeShape(model, "LeftWing", Vector3.new(0.55, 1.15, 1.25), Vector3.new(-1.05, 1.25, -0.05), definition.Accent)
        makeShape(model, "RightWing", Vector3.new(0.55, 1.15, 1.25), Vector3.new(1.05, 1.25, -0.05), definition.Accent)
        makeShape(model, "LeftTuft", Vector3.new(0.38, 0.75, 0.38), Vector3.new(-0.45, 2.55, 0.35), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightTuft", Vector3.new(0.38, 0.75, 0.38), Vector3.new(0.45, 2.55, 0.35), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "ChestFeathers", Vector3.new(1.25, 0.9, 0.3), Vector3.new(0, 1.1, 0.95), definition.Accent)
    elseif definition.Kind == "Bear" then
        makeShape(model, "Muzzle", Vector3.new(0.85, 0.62, 0.62), Vector3.new(0, 1.58, 1.15), definition.Accent)
        makeShape(model, "LeftEar", Vector3.new(0.62, 0.62, 0.48), Vector3.new(-0.58, 2.48, 0.45), definition.Detail)
        makeShape(model, "RightEar", Vector3.new(0.62, 0.62, 0.48), Vector3.new(0.58, 2.48, 0.45), definition.Detail)
        makeShape(model, "BellyPatch", Vector3.new(1.25, 0.95, 0.28), Vector3.new(0, 1.05, 0.86), definition.Accent)
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

local BUILD_INTERESTS = {
    AppleTree = { Category = "Trees", Label = "Яблонька" },
    CloverBush = { Category = "Flowers", Label = "Клеверная полянка" },
    FlowerArch = { Category = "Flowers", Label = "Цветочная арка" },
    CrystalPond = { Category = "Water", Label = "Кристальный пруд" },
    MoonFountain = { Category = "Water", Label = "Лунный фонтан" },
    CozyCottage = { Category = "Shelter", Label = "Уютный домик" },
    Watchtower = { Category = "HighGround", Label = "Сторожевая башня" },
}
local DECOR_INTERESTS = {
    FlowerPot = { Category = "Flowers", Label = "Цветочный уголок" },
    WarmLantern = { Category = "Lanterns", Label = "Тёплый фонарь" },
    MeadowCrystal = { Category = "Crystals", Label = "Луговой кристалл" },
    MushroomSeat = { Category = "Resting", Label = "Грибная скамейка" },
}

local function collectInterestPoints(plotModel, home)
    local points = {}
    local seen = {}
    local function addPoint(key, position, category, label)
        if seen[key] then return end
        local target = Vector3.new(position.X, home.Y, position.Z)
        local distance = (target - home).Magnitude
        if distance < 2.2 or distance > 13 then return end
        seen[key] = true
        table.insert(points, {
            Id = key,
            Position = target,
            Category = category,
            Label = label,
            Distance = distance,
        })
    end

    for _, descendant in ipairs(plotModel:GetDescendants()) do
        if descendant:IsA("Model") then
            local buildId = descendant:GetAttribute("BuildId")
            local decorId = descendant:GetAttribute("DecorId")
            local interest = (type(buildId) == "string" and BUILD_INTERESTS[buildId])
                or (type(decorId) == "string" and DECOR_INTERESTS[decorId])
            if interest then
                addPoint(tostring(buildId or decorId) .. ":" .. descendant.Name,
                    descendant:GetPivot().Position, interest.Category, interest.Label)
            end
        elseif descendant:IsA("BasePart") and descendant.Parent
            and descendant.Parent.Name == "EnvironmentDecorations" then
            local name = descendant.Name
            if string.find(name, "^GardenTree_.+_Trunk$") then
                addPoint(name, descendant.Position, "Trees", "Старое дерево")
            elseif string.find(name, "^FlowerBed_.+_Soil$") then
                addPoint(name, descendant.Position, "Flowers", "Цветочная клумба")
            elseif string.find(name, "^GardenPathStone_") then
                addPoint(name, descendant.Position, "Paths", "Каменная дорожка")
            end
        end
    end
    table.sort(points, function(a, b) return a.Id < b.Id end)
    return points
end

local function chooseInterestPoint(points, favoritePlace, random, previousId)
    local totalWeight = 0
    local weighted = {}
    for _, point in ipairs(points) do
        local weight = point.Category == favoritePlace and 3.5 or 1
        if point.Id == previousId and #points > 1 then weight *= 0.12 end
        weight /= math.max(1, point.Distance * 0.35)
        totalWeight += weight
        table.insert(weighted, { Point = point, Weight = weight })
    end
    if totalWeight <= 0 then return nil end
    local roll = random:NextNumber(0, totalWeight)
    for _, entry in ipairs(weighted) do
        roll -= entry.Weight
        if roll <= 0 then return entry.Point end
    end
    return weighted[#weighted] and weighted[#weighted].Point or nil
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

    profile.Nest.CompanionGiftReadyAt = math.max(0, math.floor(tonumber(profile.Nest.CompanionGiftReadyAt) or 0))
    local nextTreasureAt = math.max(os.time() + 20, profile.Nest.CompanionGiftReadyAt)
    local giftCache = nil
    local giftCacheClaimed = false
    local treasureSearchOwner = nil
    local worldFolder = Workspace:FindFirstChild("NestRaidersWorld")

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
            local home = basePivot.Position
            local interestPoints = collectInterestPoints(plot.Model, home)
            local interestPointsUpdatedAt = os.clock()
            model:SetAttribute("DisplaySlot", slot)
            model:SetAttribute("NestHomePosition", home)
            local toyId = profile.Nest and profile.Nest.CompanionToys and profile.Nest.CompanionToys[instanceId]
            local toyDefinition = NestToyCatalog[toyId or ""]
            local toyPart = nil
            local toyPosition = nil
            local toyApproach = nil
            if toyDefinition then
                toyPosition = home + Vector3.new(2.8, -1.05, 0)
                toyApproach = home + Vector3.new(2.8, 0, 0)
                toyPart = makeShape(folder, "NestToy_" .. tostring(slot), Vector3.new(0.8, 0.8, 0.8), toyPosition, toyDefinition.Color, toyDefinition.Shape)
                toyPart.Material = toyId == "WindSpinner" and Enum.Material.Neon or Enum.Material.SmoothPlastic
                toyPart:SetAttribute("ToyId", toyDefinition.Id)
                toyPart:SetAttribute("ToyState", "Waiting")
            end
            local moodBillboard = Instance.new("BillboardGui")
            moodBillboard.Name = "MoodBubble"
            moodBillboard.Adornee = model.PrimaryPart
            moodBillboard.Size = UDim2.fromOffset(148, 28)
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

            -- Always-visible pair progress makes friendship a readable gameplay system.
            local friendshipBillboard = Instance.new("BillboardGui")
            friendshipBillboard.Name = "FriendshipProgress"
            friendshipBillboard.Adornee = model.PrimaryPart
            friendshipBillboard.Size = UDim2.fromOffset(148, 30)
            friendshipBillboard.StudsOffset = Vector3.new(0, 3.55, 0)
            friendshipBillboard.AlwaysOnTop = false
            friendshipBillboard.Enabled = false
            friendshipBillboard.Parent = model

            local friendshipCard = Instance.new("Frame")
            friendshipCard.Size = UDim2.fromScale(1, 1)
            friendshipCard.BackgroundColor3 = Color3.fromRGB(29, 39, 51)
            friendshipCard.BackgroundTransparency = 0.1
            friendshipCard.BorderSizePixel = 0
            friendshipCard.Parent = friendshipBillboard
            local friendshipCardCorner = Instance.new("UICorner")
            friendshipCardCorner.CornerRadius = UDim.new(0, 8)
            friendshipCardCorner.Parent = friendshipCard
            local friendshipCardStroke = Instance.new("UIStroke")
            friendshipCardStroke.Thickness = 1
            friendshipCardStroke.Transparency = 0.3
            friendshipCardStroke.Parent = friendshipCard

            local friendshipText = Instance.new("TextLabel")
            friendshipText.BackgroundTransparency = 1
            friendshipText.Position = UDim2.fromOffset(7, 1)
            friendshipText.Size = UDim2.new(1, -14, 0, 19)
            friendshipText.Font = Enum.Font.GothamBold
            friendshipText.TextSize = 10
            friendshipText.TextXAlignment = Enum.TextXAlignment.Center
            friendshipText.TextColor3 = Color3.fromRGB(214, 224, 234)
            friendshipText.Parent = friendshipCard

            local friendshipTrack = Instance.new("Frame")
            friendshipTrack.Position = UDim2.new(0, 8, 1, -7)
            friendshipTrack.Size = UDim2.new(1, -16, 0, 3)
            friendshipTrack.BackgroundColor3 = Color3.fromRGB(69, 79, 91)
            friendshipTrack.BorderSizePixel = 0
            friendshipTrack.Parent = friendshipCard
            local friendshipTrackCorner = Instance.new("UICorner")
            friendshipTrackCorner.CornerRadius = UDim.new(1, 0)
            friendshipTrackCorner.Parent = friendshipTrack
            local friendshipFill = Instance.new("Frame")
            friendshipFill.Size = UDim2.fromScale(0, 1)
            friendshipFill.BackgroundColor3 = Color3.fromRGB(116, 222, 174)
            friendshipFill.BorderSizePixel = 0
            friendshipFill.Parent = friendshipTrack
            local friendshipFillCorner = Instance.new("UICorner")
            friendshipFillCorner.CornerRadius = UDim.new(1, 0)
            friendshipFillCorner.Parent = friendshipFill

            profile.Nest.CompanionBonds = profile.Nest.CompanionBonds or {}
            local petDefinition = CompanionCatalog[companion.Id] or {}
            local activityPeriod = petDefinition.ActivityPeriod or "Any"
            local favoritePlace = petDefinition.FavoritePlace or "Any"
            local weatherPreference = petDefinition.WeatherPreference or "Neutral"
            local nightGlow = nil
            if activityPeriod == "Night" and model.PrimaryPart then
                nightGlow = Instance.new("PointLight")
                nightGlow.Name = "NocturnalGlow"
                nightGlow.Color = petDefinition.NightGlowColor or Color3.fromRGB(150, 220, 255)
                nightGlow.Range = 8
                nightGlow.Brightness = 0
                nightGlow.Shadows = false
                nightGlow.Parent = model.PrimaryPart
            end
            model:SetAttribute("ActivityPeriod", activityPeriod)
            local personality = petDefinition.Personality or "Обычный"
            local personalityProfiles = {
                ["Игривый"] = { SocialChance = 0.28, IdleMin = 0.7, IdleMax = 1.5, ToyChance = 0.58, TreasureChance = 0.09 },
                ["Энергичный"] = { SocialChance = 0.25, IdleMin = 0.6, IdleMax = 1.4, ToyChance = 0.62, TreasureChance = 0.11 },
                ["Любопытный"] = { SocialChance = 0.24, IdleMin = 0.8, IdleMax = 1.7, ToyChance = 0.55, TreasureChance = 0.24 },
                ["Любознательный"] = { SocialChance = 0.22, IdleMin = 0.8, IdleMax = 1.8, ToyChance = 0.52, TreasureChance = 0.22 },
                ["Дружелюбный"] = { SocialChance = 0.34, IdleMin = 0.8, IdleMax = 1.8, ToyChance = 0.42, TreasureChance = 0.1 },
                ["Спокойный"] = { SocialChance = 0.08, IdleMin = 1.8, IdleMax = 3.2, ToyChance = 0.24, TreasureChance = 0.04 },
                ["Мудрый"] = { SocialChance = 0.12, IdleMin = 1.6, IdleMax = 2.8, ToyChance = 0.28, TreasureChance = 0.16 },
                ["Осторожный"] = { SocialChance = 0.07, IdleMin = 1.7, IdleMax = 3.0, ToyChance = 0.2, TreasureChance = 0.05 },
                ["Мечтательный"] = { SocialChance = 0.14, IdleMin = 1.5, IdleMax = 2.8, ToyChance = 0.32, TreasureChance = 0.13 },
                ["Добродушный"] = { SocialChance = 0.3, IdleMin = 1.0, IdleMax = 2.0, ToyChance = 0.4, TreasureChance = 0.12 },
            }
            local personalityProfile = personalityProfiles[personality] or {
                SocialChance = 0.16, IdleMin = 1.0, IdleMax = 2.4, ToyChance = 0.38,
            }
            local phase = (slot * 1.7) % (math.pi * 2)
            local random = Random.new(player.UserId + slot * 97 + math.floor(os.clock() * 1000) % 100000)
            local currentPosition = home
            local targetPosition = home
            local facing = 0
            local idleUntil = os.clock() + random:NextNumber(personalityProfile.IdleMin, personalityProfile.IdleMax)
            local wanderRadius = 3.6
            local isAtTarget = true
            local targetIsToy = false
            local targetIsSocial = false
            local toyPlayUntil = 0
            local socialPlayUntil = 0
            local socialRewarded = false
            local targetIsCaring = false
            local careUntil = 0
            local careRewarded = false
            local isSharedDiscoveryFollower = false
            local sharedDiscoveryLeaderUntil = 0
            local sharedDiscoveryLeaderTarget = nil
            local targetIsChase = false
            local targetIsRestingTogether = false
            local restingTogetherUntil = 0
            local targetIsTreasure = false
            local targetIsShelter = false
            local shelterUntil = 0
            local targetIsInterest = false
            local interestUntil = 0
            local lastInterestId = nil
            local nextDiscoveryAt = 0
            local interestLabel = nil
            local activeHabit = nil
            local activeHabitUntil = 0
            local nextHabitAt = os.clock() + random:NextNumber(8, 16)
            local partnerSlot = slot % 2 == 1 and slot + 1 or slot - 1
            local behavior = sleeping and "Sleeping"
                or (hunger <= 20 and "Hungry")
                or (mood >= 80 and "Playful")
                or "Wandering"
            model:SetAttribute("Behavior", behavior)
            model:SetAttribute("Mood", mood)
            model:SetAttribute("Hunger", hunger)
            model:SetAttribute("Energy", energy)
            model:SetAttribute("Personality", personality)
            model:SetAttribute("FavoriteToy", petDefinition.FavoriteToy or "")
            task.spawn(function()
                local previousTime = os.clock()
                while model.Parent == folder and folder.Parent do
                    -- Read back profile-side mood changes made by other server systems
                    -- (for example paired adventures) before publishing the pet state.
                    local savedMood = profile.Nest and profile.Nest.CompanionMood
                        and profile.Nest.CompanionMood[instanceId]
                    if savedMood ~= nil then
                        mood = math.clamp(math.floor(tonumber(savedMood) or mood), 0, 100)
                    end
                    local now = os.clock()
                    local delta = math.clamp(now - previousTime, 0, 0.25)
                    if now - interestPointsUpdatedAt >= 5 and plot.Model and plot.Model.Parent then
                        interestPoints = collectInterestPoints(plot.Model, home)
                        interestPointsUpdatedAt = now
                    end
                    previousTime = now
                    local bob = 0
                    local yawOffset = 0
                    local partnerModel = nil
                    for _, candidate in ipairs(folder:GetChildren()) do
                        if candidate:IsA("Model") and candidate ~= model
                            and candidate:GetAttribute("DisplaySlot") == partnerSlot then
                            partnerModel = candidate
                            break
                        end
                    end
                    local partnerHome = partnerModel and partnerModel:GetAttribute("NestHomePosition")
                    local socialApproach = nil
                    if typeof(partnerHome) == "Vector3" then
                        local towardPartner = partnerHome - home
                        if towardPartner.Magnitude > 0.1 then
                            local sideOffset = slot < partnerSlot and -1.5 or 1.5
                            socialApproach = home:Lerp(partnerHome, 0.5) + towardPartner.Unit * sideOffset
                        end
                    end
                    local partnerBehavior = partnerModel and partnerModel:GetAttribute("Behavior")
                    local partnerPersonality = partnerModel and partnerModel:GetAttribute("Personality") or ""
                    local partnerSleeping = partnerModel and partnerModel:GetAttribute("IsSleeping") == true
                    if slot < partnerSlot and sharedDiscoveryLeaderUntil > now and typeof(sharedDiscoveryLeaderTarget) == "Vector3"
                        and (currentPosition - sharedDiscoveryLeaderTarget).Magnitude <= 6 and partnerModel
                        and partnerModel:GetAttribute("SharedDiscoveryLeader") == instanceId
                        and partnerModel:GetAttribute("SharedDiscoveryArrived") == true
                        and (partnerModel:GetPivot().Position - currentPosition).Magnitude <= 6 then
                        local partnerId = partnerModel:GetAttribute("CompanionInstanceId")
                        profile.Nest.CompanionMood = profile.Nest.CompanionMood or {}
                        local selfMood = math.clamp(mood + 3, 0, 100)
                        local partnerCurrentMood = math.clamp(
                            math.floor(tonumber(profile.Nest.CompanionMood[partnerId])
                                or tonumber(partnerModel:GetAttribute("Mood")) or 50), 0, 100
                        )
                        local partnerMoodAfter = math.clamp(partnerCurrentMood + 3, 0, 100)
                        mood = selfMood
                        profile.Nest.CompanionMood[instanceId] = selfMood
                        profile.Nest.CompanionMood[partnerId] = partnerMoodAfter
                        model:SetAttribute("Mood", selfMood)
                        partnerModel:SetAttribute("Mood", partnerMoodAfter)
                        local sharedLabel = tostring(model:GetAttribute("InterestTargetLabel") or "тайное место")
                        model:SetAttribute("LastDiscovery", "Открытие вместе: " .. sharedLabel)
                        partnerModel:SetAttribute("LastDiscovery", "Открытие вместе: " .. sharedLabel)
                        showSharedHeartMoment(model, partnerModel)
                        player:SetAttribute("LastNotice", "Вместе питомцы открыли: " .. sharedLabel .. "!")
                        partnerModel:SetAttribute("SharedDiscoveryTargetPosition", nil)
                        partnerModel:SetAttribute("SharedDiscoveryTargetUntil", nil)
                        partnerModel:SetAttribute("SharedDiscoveryTargetLabel", nil)
                        partnerModel:SetAttribute("SharedDiscoveryLeader", nil)
                        partnerModel:SetAttribute("SharedDiscoveryArrived", nil)
                        sharedDiscoveryLeaderUntil = 0
                        sharedDiscoveryLeaderTarget = nil
                    end
                    local pairBondKey = partnerModel and getBondKey(instanceId, partnerModel:GetAttribute("CompanionInstanceId"))
                    local pairBondScore = pairBondKey and profile.Nest and profile.Nest.CompanionBonds
                        and math.clamp(math.floor(tonumber(profile.Nest.CompanionBonds[pairBondKey]) or 0), 0, 100) or 0
                    local isCautious = personality == "Осторожный"
                    local isSocialLeader = personality == "Дружелюбный" or personality == "Добродушный"
                    local friendshipStyle = isCautious and (pairBondScore < 10 and "Привыкает постепенно" or "Доверяет другу")
                        or isSocialLeader and "Сам ищет друзей"
                        or personality == "Игривый" and "Любит совместные игры"
                        or "Спокойное общение"
                    if model:GetAttribute("FriendshipStyle") ~= friendshipStyle then
                        model:SetAttribute("FriendshipStyle", friendshipStyle)
                    end
                    local isSleeping = (tonumber(needs.RestingUntil) or 0) > os.time()
                    local clockTime = Lighting.ClockTime
                    local isNight = clockTime >= 19 or clockTime < 6
                    local weatherState = worldFolder and worldFolder:GetAttribute("WorldWeather") or "Clear"
                    local isWetWeather = weatherState == "Rain" or weatherState == "Storm"
                    local seeksShelter = weatherState == "Storm" and weatherPreference == "Shelter"
                    local enjoysRain = isWetWeather and weatherPreference == "Rain"
                    if model:GetAttribute("WeatherState") ~= weatherState then
                        model:SetAttribute("WeatherState", weatherState)
                    end
                    local isPreferredTime = activityPeriod == "Any"
                        or (activityPeriod == "Night" and isNight)
                        or (activityPeriod == "Day" and not isNight)
                    local activityState = activityPeriod == "Any" and "Anytime"
                        or (isPreferredTime and "Active" or "Resting")
                    if model:GetAttribute("ActivityState") ~= activityState then
                        model:SetAttribute("ActivityState", activityState)
                    end
                    if nightGlow and nightGlow.Parent then
                        nightGlow.Brightness = isNight and 0.8 or 0
                    end
                    model:SetAttribute("IsSleeping", isSleeping)

                    if isSleeping then
                        if careUntil > 0 and partnerModel
                            and partnerModel:GetAttribute("BeingComfortedBy") == instanceId then
                            partnerModel:SetAttribute("BeingComfortedUntil", nil)
                            partnerModel:SetAttribute("BeingComfortedBy", nil)
                        end
                        activeHabit = nil
                        activeHabitUntil = 0
                        model:SetAttribute("PersonalHabit", nil)
                        model:SetAttribute("PersonalHabitText", nil)
                        model:SetAttribute("PersonalHabitUntil", nil)
                        behavior = "Sleeping"
                        targetPosition = currentPosition
                        isAtTarget = true
                        targetIsToy = false
                        targetIsSocial = false
                        targetIsCaring = false
                        careUntil = 0
                        isSharedDiscoveryFollower = false
                        targetIsRestingTogether = false
                        restingTogetherUntil = 0
                        model:SetAttribute("RestingWithFriend", nil)
                        targetIsShelter = false
                        shelterUntil = 0
                        targetIsInterest = false
                        interestUntil = 0
                        if targetIsTreasure and treasureSearchOwner == instanceId then treasureSearchOwner = nil end
                        targetIsTreasure = false
                        toyPlayUntil = 0
                        socialPlayUntil = 0
                        if toyPart then toyPart:SetAttribute("ToyState", "Waiting") end
                        idleUntil = math.max(idleUntil, now + 0.2)
                        bob = math.sin(now * 1.2 + phase) * 0.025
                        yawOffset = math.sin(now * 0.35 + phase) * 0.025
                    else
                        if careUntil > 0 and now >= careUntil then
                            if not careRewarded and partnerModel and partnerModel.Parent
                                and (partnerModel:GetPivot().Position - currentPosition).Magnitude <= 8 then
                                local partnerId = partnerModel:GetAttribute("CompanionInstanceId")
                                profile.Nest.CompanionMood = profile.Nest.CompanionMood or {}
                                local savedPartnerMood = math.clamp(
                                    math.floor(tonumber(profile.Nest.CompanionMood[partnerId]) or tonumber(partnerModel:GetAttribute("Mood")) or 50), 0, 100
                                )
                                local comfortBoost = personality == "Заботливый" and 9 or 6
                                local updatedPartnerMood = math.clamp(savedPartnerMood + comfortBoost, 0, 100)
                                profile.Nest.CompanionMood[partnerId] = updatedPartnerMood
                                partnerModel:SetAttribute("Mood", updatedPartnerMood)
                                partnerModel:SetAttribute("BeingComfortedUntil", nil)
                                partnerModel:SetAttribute("BeingComfortedBy", nil)
                                mood = math.clamp(mood + 2, 0, 100)
                                profile.Nest.CompanionMood[instanceId] = mood
                                model:SetAttribute("Mood", mood)
                                player:SetAttribute("LastNotice", companion.Name .. " утешил друга: настроение +" .. comfortBoost .. "!")
                            end
                            careRewarded = true
                            careUntil = 0
                            idleUntil = now + random:NextNumber(2, 4)
                        end
                        if socialPlayUntil > 0 and now >= socialPlayUntil then
                            if not socialRewarded and partnerModel and not partnerSleeping
                                and (partnerModel:GetPivot().Position - currentPosition).Magnitude <= 10 then
                                mood = math.clamp(mood + 2, 0, 100)
                                profile.Nest.CompanionMood = profile.Nest.CompanionMood or {}
                                profile.Nest.CompanionMood[instanceId] = mood
                                model:SetAttribute("Mood", mood)
                                if slot < partnerSlot then
                                    local partnerId = partnerModel:GetAttribute("CompanionInstanceId")
                                    local bondKey = getBondKey(instanceId, partnerId)
                                    if bondKey then
                                        local bondScore = math.clamp(math.floor(tonumber(profile.Nest.CompanionBonds[bondKey]) or 0) + 1, 0, 100)
                                        profile.Nest.CompanionBonds[bondKey] = bondScore
                                        local bondLevel = getBondLevel(bondScore)
                                        model:SetAttribute("FriendshipScore", bondScore)
                                        model:SetAttribute("FriendshipLevel", bondLevel)
                                        partnerModel:SetAttribute("FriendshipScore", bondScore)
                                        partnerModel:SetAttribute("FriendshipLevel", bondLevel)
                                        local milestone = BOND_MILESTONES[bondScore]
                                        if milestone then
                                            showBondMilestone(player, model, partnerModel, milestone)
                                        end
                                        local pairMemory = PAIR_BOND_MEMORIES[bondScore]
                                        if pairMemory then
                                            profile.Nest.DiscoveredBondMoments = profile.Nest.DiscoveredBondMoments or {}
                                            local memoryKey = "Pair:" .. bondKey .. ":" .. pairMemory.Id
                                            if profile.Nest.DiscoveredBondMoments[memoryKey] ~= true then
                                                profile.Nest.DiscoveredBondMoments[memoryKey] = true
                                                showSharedHeartMoment(model, partnerModel)
                                                player:SetAttribute("LastNotice", "Новое воспоминание дружбы: " .. pairMemory.Title)
                                            end
                                        end
                                        local partnerDefinition = CompanionCatalog[partnerModel:GetAttribute("CompanionId")] or {}
                                        if random:NextNumber() < 0.5 then
                                            tryGiveCompanionGift(
                                                player, profile, model, partnerModel, petDefinition,
                                                bondKey, bondScore, now, random
                                            )
                                        else
                                            tryGiveCompanionGift(
                                                player, profile, partnerModel, model, partnerDefinition,
                                                bondKey, bondScore, now, random
                                            )
                                        end
                                    end
                                end
                            end
                            socialRewarded = true
                            socialPlayUntil = 0
                            targetIsSocial = false
                            -- Established friends sometimes turn a finished greeting into a short chase.
                            if slot < partnerSlot and partnerModel and pairBondScore >= 30
                                and mood >= 55 and energy >= 30 then
                                local partnerId = partnerModel:GetAttribute("CompanionInstanceId")
                                local pairId = getBondKey(instanceId, partnerId)
                                local chaseKey = tostring(player.UserId) .. ":" .. tostring(pairId)
                                if pairId and (socialChaseCooldowns[chaseKey] or 0) <= now then
                                    socialChaseCooldowns[chaseKey] = now + 35
                                    local chaseUntil = now + 4.5
                                    model:SetAttribute("CompanionChaseUntil", chaseUntil)
                                    partnerModel:SetAttribute("CompanionChaseUntil", chaseUntil)
                                end
                            end
                            idleUntil = now + random:NextNumber(personalityProfile.IdleMin, personalityProfile.IdleMax)
                        elseif socialPlayUntil > 0 and (not partnerModel or partnerSleeping) then
                            socialPlayUntil = 0
                            targetIsSocial = false
                            idleUntil = now + random:NextNumber(personalityProfile.IdleMin, personalityProfile.IdleMax)
                        end

                        if sharedDiscoveryLeaderUntil > 0 and sharedDiscoveryLeaderUntil <= now then
                            sharedDiscoveryLeaderUntil = 0
                            sharedDiscoveryLeaderTarget = nil
                        end
                        local sharedUntil = tonumber(model:GetAttribute("SharedDiscoveryTargetUntil")) or 0
                        if sharedUntil > 0 and sharedUntil <= now then
                            model:SetAttribute("SharedDiscoveryTargetPosition", nil)
                            model:SetAttribute("SharedDiscoveryTargetUntil", nil)
                            model:SetAttribute("SharedDiscoveryTargetLabel", nil)
                            model:SetAttribute("SharedDiscoveryLeader", nil)
                            model:SetAttribute("SharedDiscoveryArrived", nil)
                            isSharedDiscoveryFollower = false
                        end

                        if partnerBehavior == "SeekingFriend" and socialApproach and not targetIsSocial
                            and socialPlayUntil <= now and not partnerSleeping then
                            targetPosition = socialApproach
                            targetIsSocial = true
                            targetIsToy = false
                            isAtTarget = false
                            idleUntil = now
                        end

                        if not isAtTarget and (targetPosition - currentPosition).Magnitude < 0.2 then
                            currentPosition = targetPosition
                            isAtTarget = true
                            if targetIsCaring then
                                targetIsCaring = false
                                careUntil = now + random:NextNumber(2.8, 3.8)
                                careRewarded = false
                                idleUntil = careUntil
                                if partnerModel and partnerModel.Parent then
                                    partnerModel:SetAttribute("BeingComfortedUntil", careUntil)
                                    partnerModel:SetAttribute("BeingComfortedBy", instanceId)
                                end
                            elseif targetIsRestingTogether then
                                targetIsRestingTogether = false
                                restingTogetherUntil = now + random:NextNumber(4.5, 6.5)
                                idleUntil = restingTogetherUntil
                                model:SetAttribute("RestingWithFriend", true)
                            elseif targetIsToy then
                                targetIsToy = false
                                toyPlayUntil = now + random:NextNumber(2.8, 4.2)
                                idleUntil = toyPlayUntil
                            elseif targetIsTreasure then
                                targetIsTreasure = false
                                local cache = Instance.new("Part")
                                cache.Name = "CompanionGiftCache"
                                cache.Size = Vector3.new(1.5, 0.9, 1.15)
                                cache.CFrame = CFrame.new(currentPosition + Vector3.new(0, 0.55, 0))
                                cache.Anchored = true
                                cache.CanCollide = false
                                cache.Material = Enum.Material.WoodPlanks
                                cache.Color = Color3.fromRGB(145, 91, 48)
                                cache.Parent = folder
                                giftCache = cache
                                giftCacheClaimed = false
                                local lid = Instance.new("Part")
                                lid.Name = "CacheLid"
                                lid.Size = Vector3.new(1.58, 0.22, 1.2)
                                lid.CFrame = cache.CFrame * CFrame.new(0, 0.52, 0)
                                lid.Anchored = true
                                lid.CanCollide = false
                                lid.Material = Enum.Material.Wood
                                lid.Color = Color3.fromRGB(190, 132, 69)
                                lid.Parent = cache
                                local glow = Instance.new("PointLight")
                                glow.Color = Color3.fromRGB(255, 210, 105)
                                glow.Brightness = 1.2
                                glow.Range = 9
                                glow.Parent = cache
                                local prompt = Instance.new("ProximityPrompt")
                                prompt.Name = "CollectCompanionGift"
                                prompt.ActionText = "Забрать подарок"
                                prompt.ObjectText = "Находка питомца"
                                prompt.KeyboardKeyCode = Enum.KeyCode.E
                                prompt.HoldDuration = 0.35
                                prompt.MaxActivationDistance = 10
                                prompt.RequiresLineOfSight = false
                                prompt.Parent = cache
                                local finder = companion
                                prompt.Triggered:Connect(function(collector)
                                    if collector ~= player or not player.Parent or giftCache ~= cache or giftCacheClaimed then return end
                                    giftCacheClaimed = true
                                    local reward = 25 + math.clamp(math.floor(tonumber(finder.Level) or 1), 1, 10) * 2
                                        + math.clamp(math.floor(tonumber(finder.Stars) or 1), 1, 3) * 8
                                    if not EconomyService:GrantCoins(player, reward, "Подарок питомца") then
                                        giftCacheClaimed = false
                                        return
                                    end
                                    profile.Nest.CompanionGiftReadyAt = os.time() + 180
                                    nextTreasureAt = profile.Nest.CompanionGiftReadyAt
                                    mood = math.clamp(mood + 3, 0, 100)
                                    profile.Nest.CompanionMood[instanceId] = mood
                                    model:SetAttribute("Mood", mood)
                                    player:SetAttribute("LastNotice", finder.Name .. " принёс подарок: +" .. reward .. " монет!")
                                    treasureSearchOwner = nil
                                    giftCache = nil
                                    cache:Destroy()
                                end)
                                idleUntil = now + 2
                            elseif targetIsShelter then
                                targetIsShelter = false
                                shelterUntil = now + random:NextNumber(4, 7)
                                idleUntil = shelterUntil
                            elseif targetIsInterest then
                                targetIsInterest = false
                                lastInterestId = model:GetAttribute("InterestTargetId")
                                interestUntil = now + random:NextNumber(2.4, 4.2)
                                idleUntil = interestUntil
                                if isSharedDiscoveryFollower then
                                    model:SetAttribute("SharedDiscoveryArrived", true)
                                    isSharedDiscoveryFollower = false
                                elseif slot < partnerSlot and sharedDiscoveryLeaderUntil > now and typeof(sharedDiscoveryLeaderTarget) == "Vector3"
                                    and (currentPosition - sharedDiscoveryLeaderTarget).Magnitude <= 6
                                    and partnerModel and partnerModel:GetAttribute("SharedDiscoveryLeader") == instanceId then
                                    local partnerPosition = partnerModel:GetPivot().Position
                                    if (partnerPosition - currentPosition).Magnitude <= 6
                                        and partnerModel:GetAttribute("SharedDiscoveryArrived") == true then
                                        local partnerId = partnerModel:GetAttribute("CompanionInstanceId")
                                        profile.Nest.CompanionMood = profile.Nest.CompanionMood or {}
                                        local selfMood = math.clamp(mood + 3, 0, 100)
                                        local partnerCurrentMood = math.clamp(
                                            math.floor(tonumber(profile.Nest.CompanionMood[partnerId])
                                                or tonumber(partnerModel:GetAttribute("Mood")) or 50), 0, 100
                                        )
                                        local partnerMoodAfter = math.clamp(partnerCurrentMood + 3, 0, 100)
                                        mood = selfMood
                                        profile.Nest.CompanionMood[instanceId] = selfMood
                                        profile.Nest.CompanionMood[partnerId] = partnerMoodAfter
                                        model:SetAttribute("Mood", selfMood)
                                        partnerModel:SetAttribute("Mood", partnerMoodAfter)
                                        model:SetAttribute("LastDiscovery", "Открытие вместе: " .. tostring(interestLabel or "тайное место"))
                                        partnerModel:SetAttribute("LastDiscovery", "Открытие вместе: " .. tostring(interestLabel or "тайное место"))
                                        showSharedHeartMoment(model, partnerModel)
                                        player:SetAttribute("LastNotice", "Вместе питомцы открыли: " .. tostring(interestLabel or "тайное место") .. "!")
                                        partnerModel:SetAttribute("SharedDiscoveryTargetPosition", nil)
                                        partnerModel:SetAttribute("SharedDiscoveryTargetUntil", nil)
                                        partnerModel:SetAttribute("SharedDiscoveryTargetLabel", nil)
                                        partnerModel:SetAttribute("SharedDiscoveryLeader", nil)
                                        partnerModel:SetAttribute("SharedDiscoveryArrived", nil)
                                        sharedDiscoveryLeaderUntil = 0
                                        sharedDiscoveryLeaderTarget = nil
                                    end
                                end
                                if now >= nextDiscoveryAt and random:NextNumber() < 0.14 then
                                    nextDiscoveryAt = now + 90
                                    local discovery = interestLabel or "необычный след"
                                    model:SetAttribute("LastDiscovery", discovery)
                                    player:SetAttribute("LastNotice", companion.Name .. " заметил кое-что интересное: " .. discovery .. "!")
                                end
                            elseif targetIsSocial then
                                local partnerPosition = partnerModel and partnerModel:GetPivot().Position
                                if partnerPosition and (partnerPosition - currentPosition).Magnitude <= 10 then
                                    socialPlayUntil = now + random:NextNumber(3.2, 4.6)
                                    socialRewarded = false
                                    idleUntil = socialPlayUntil
                                else
                                    idleUntil = now + 0.25
                                end
                            else
                                idleUntil = now + random:NextNumber(personalityProfile.IdleMin, personalityProfile.IdleMax)
                            end
                        end

                        if isAtTarget and now >= idleUntil and socialPlayUntil <= now and not targetIsSocial then
                            local habit = COMPANION_HABITS[personality]
                            local canShowHabit = habit and now >= nextHabitAt and mood >= 25 and energy >= 20
                                and hunger >= 20 and not isSleeping and not targetIsRestingTogether
                                and not targetIsChase and (tonumber(model:GetAttribute("GiftReactionUntil")) or 0) <= now
                            if canShowHabit and random:NextNumber() < habit.Chance then
                                activeHabit = habit.Id
                                activeHabitUntil = now + random:NextNumber(2.2, 4.0)
                                nextHabitAt = now + random:NextNumber(28, 52)
                                idleUntil = activeHabitUntil
                                model:SetAttribute("PersonalHabit", habit.Id)
                                model:SetAttribute("PersonalHabitText", habit.Text)
                                model:SetAttribute("PersonalHabitUntil", activeHabitUntil)
                            else
                                nextHabitAt = math.max(nextHabitAt, now + 5)
                            end
                            if not (activeHabit and now < activeHabitUntil) then
                            local cautiousCanApproach = not isCautious or pairBondScore >= 10
                                or partnerPersonality == "Дружелюбный" or partnerPersonality == "Добродушный"
                                or random:NextNumber() < 0.035
                            local canSocialize = partnerModel and socialApproach and not partnerSleeping
                                and mood >= 45 and energy >= 20 and cautiousCanApproach
                            -- Familiarity makes cautious pets more willing to socialize,
                            -- while outgoing personalities are more likely to initiate first contact.
                            local bondSocialBonus = math.min(pairBondScore / 100, 1) * 0.18
                            local outgoingBonus = isSocialLeader and 0.12 or 0
                            local effectiveSocialChance = math.clamp(
                                (personalityProfile.SocialChance or 0.16) + bondSocialBonus + outgoingBonus,
                                0.03, 0.72
                            )
                            local socialTrigger = partnerBehavior == "SeekingFriend"
                                or random:NextNumber() < effectiveSocialChance
                            local canRestTogether = partnerModel and partnerSleeping and not isSleeping
                                and pairBondScore >= 30 and (isNight or energy <= 35)
                                and mood >= 20 and energy >= 10
                            local canPlay = toyPart and mood >= 35
                                and energy >= math.max(0, math.floor(tonumber(toyDefinition.EnergyCost) or 0))
                            local favoriteToy = toyId ~= nil and toyId == petDefinition.FavoriteToy
                            local toyChance = personalityProfile.ToyChance + (favoriteToy and 0.2 or 0)
                            local treasureChance = personalityProfile.TreasureChance or 0.08
                            if activityPeriod ~= "Any" then
                                treasureChance *= isPreferredTime and 1.25 or 0.55
                            end
                            if weatherState == "Storm" then treasureChance *= 0.35 end
                            local canSearch = not giftCache and not treasureSearchOwner
                                and os.time() >= nextTreasureAt and energy >= 35 and hunger >= 25
                            local canExplore = #interestPoints > 0 and energy >= 25 and hunger >= 25 and mood >= 30
                            local explorationChance = (personality == "Любопытный" or personality == "Любознательный") and 0.34 or 0.2
                            local restKey = pairBondKey and (tostring(player.UserId) .. ":" .. tostring(pairBondKey))
                            local sharedTarget = model:GetAttribute("SharedDiscoveryTargetPosition")
                            local sharedTargetUntil = tonumber(model:GetAttribute("SharedDiscoveryTargetUntil")) or 0
                            local followingSharedDiscovery = typeof(sharedTarget) == "Vector3"
                                and sharedTargetUntil > now
                                and model:GetAttribute("SharedDiscoveryArrived") ~= true and partnerModel
                                and model:GetAttribute("SharedDiscoveryLeader")
                                    == partnerModel:GetAttribute("CompanionInstanceId")
                            if followingSharedDiscovery
                                and partnerModel and model:GetAttribute("SharedDiscoveryLeader")
                                    == partnerModel:GetAttribute("CompanionInstanceId") then
                                targetPosition = sharedTarget
                                interestLabel = tostring(model:GetAttribute("SharedDiscoveryTargetLabel") or "секретное место")
                                targetIsInterest = true
                                targetIsSocial = false
                                targetIsToy = false
                                targetIsTreasure = false
                                targetIsShelter = false
                                isSharedDiscoveryFollower = true
                                model:SetAttribute("InterestTargetLabel", interestLabel)
                                model:SetAttribute("InterestTargetId", "Shared:" .. interestLabel)
                            end
                            local partnerMood = partnerModel and math.clamp(
                                math.floor(tonumber(partnerModel:GetAttribute("Mood")) or 50), 0, 100
                            ) or 100
                            local careKey = restKey
                            local canComfortFriend = slot < partnerSlot and partnerModel and not partnerSleeping
                                and partnerMood <= 35 and mood >= 45 and energy >= 20 and hunger >= 20
                                and pairBondScore >= 10 and socialApproach
                                and careKey and (companionCareCooldowns[careKey] or 0) <= now
                            if followingSharedDiscovery then
                                -- Keep the partner's shared destination; do not replace it with a solo activity.
                            elseif canComfortFriend and random:NextNumber() < (personality == "Заботливый" and 0.72 or 0.28) then
                                targetPosition = socialApproach
                                targetIsCaring = true
                                targetIsToy = false
                                targetIsSocial = false
                                targetIsTreasure = false
                                targetIsInterest = false
                                targetIsShelter = false
                                companionCareCooldowns[careKey] = now + 75
                            elseif canRestTogether and restKey and (sharedRestCooldowns[restKey] or 0) <= now
                                and random:NextNumber() < 0.32 then
                                local sleepingPosition = partnerModel:GetPivot().Position
                                local towardHome = home - sleepingPosition
                                local side = towardHome.Magnitude > 0.1 and towardHome.Unit or Vector3.new(1, 0, 0)
                                targetPosition = sleepingPosition + side * 1.8
                                targetIsRestingTogether = true
                                targetIsToy = false
                                targetIsSocial = false
                                targetIsTreasure = false
                                targetIsInterest = false
                                targetIsShelter = false
                                sharedRestCooldowns[restKey] = now + 55
                            elseif seeksShelter then
                                targetPosition = home + Vector3.new(random:NextNumber(-1.2, 1.2), 0, random:NextNumber(-1.2, 1.2))
                                targetIsShelter = true
                                targetIsToy = false
                                targetIsSocial = false
                                targetIsTreasure = false
                            elseif canSearch and random:NextNumber() < treasureChance then
                                treasureSearchOwner = instanceId
                                targetPosition = home + Vector3.new(random:NextNumber(-2.8, 2.8), 0, random:NextNumber(-2.8, 2.8))
                                targetIsTreasure = true
                                targetIsToy = false
                                targetIsSocial = false
                            elseif canSocialize and socialTrigger then
                                targetPosition = socialApproach
                                targetIsSocial = true
                                targetIsToy = false
                                targetIsInterest = false
                            elseif canExplore and random:NextNumber() < explorationChance then
                                local point = chooseInterestPoint(interestPoints, favoritePlace, random, lastInterestId)
                                if point then
                                    targetPosition = point.Position
                                    interestLabel = point.Label
                                    targetIsInterest = true
                                    targetIsToy = false
                                    targetIsSocial = false
                                    targetIsTreasure = false
                                    model:SetAttribute("InterestTargetId", point.Id)
                                    model:SetAttribute("InterestTargetLabel", point.Label)
                                    model:SetAttribute("FavoritePlace", favoritePlace)
                                    local sharedKey = pairBondKey and (tostring(player.UserId) .. ":" .. tostring(pairBondKey))
                                    local partnerCanJoin = slot < partnerSlot and partnerModel and not partnerSleeping
                                        and pairBondScore >= 20 and partnerBehavior ~= "Searching"
                                        and partnerBehavior ~= "PlayingWithToy" and sharedKey
                                        and (sharedDiscoveryCooldowns[sharedKey] or 0) <= now
                                    if partnerCanJoin and random:NextNumber() < 0.28 then
                                        sharedDiscoveryCooldowns[sharedKey] = now + 90
                                        sharedDiscoveryLeaderUntil = now + 18
                                        sharedDiscoveryLeaderTarget = point.Position
                                        partnerModel:SetAttribute("SharedDiscoveryTargetPosition", point.Position)
                                        partnerModel:SetAttribute("SharedDiscoveryTargetUntil", now + 18)
                                        partnerModel:SetAttribute("SharedDiscoveryTargetLabel", point.Label)
                                        partnerModel:SetAttribute("SharedDiscoveryLeader", instanceId)
                                        partnerModel:SetAttribute("SharedDiscoveryArrived", false)
                                    end
                                else
                                    targetPosition = home
                                    targetIsInterest = false
                                end
                            elseif canPlay and random:NextNumber() < math.min(toyChance, 0.85) then
                                targetPosition = toyApproach
                                targetIsToy = true
                                targetIsSocial = false
                            else
                                local angle = random:NextNumber(0, math.pi * 2)
                                local preferredRadius = activityPeriod ~= "Any" and not isPreferredTime
                                    and wanderRadius * 0.72 or wanderRadius
                                if weatherState == "Storm" then preferredRadius *= seeksShelter and 0.3 or 0.55 end
                                if weatherState == "Rain" and not enjoysRain then preferredRadius *= 0.72 end
                                if weatherState == "Fog" then preferredRadius *= 0.82 end
                                local radius = math.sqrt(random:NextNumber()) * preferredRadius
                                targetPosition = home + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                                targetIsToy = false
                                targetIsSocial = false
                                targetIsInterest = false
                            end
                            isAtTarget = false
                            end
                        end

                        if targetIsRestingTogether and (not partnerModel or not partnerSleeping) then
                            targetIsRestingTogether = false
                            targetPosition = currentPosition
                            isAtTarget = true
                            model:SetAttribute("RestingWithFriend", nil)
                        end
                        local chaseUntil = tonumber(model:GetAttribute("CompanionChaseUntil")) or 0
                        local partnerChaseUntil = partnerModel and (tonumber(partnerModel:GetAttribute("CompanionChaseUntil")) or 0) or 0
                        local partnerPositionForChase = partnerModel and partnerModel:GetPivot().Position
                        if chaseUntil > now and partnerChaseUntil > now and partnerPositionForChase
                            and not isSleeping and not partnerSleeping and mood >= 25 and energy >= 15 then
                            local orbitAngle = now * 2.8 + phase
                            local chaseRadius = 2.4
                            targetPosition = partnerPositionForChase
                                + Vector3.new(math.cos(orbitAngle) * chaseRadius, 0, math.sin(orbitAngle) * chaseRadius)
                            targetIsChase = true
                            targetIsSocial = false
                            targetIsToy = false
                            targetIsInterest = false
                            targetIsTreasure = false
                            targetIsShelter = false
                            isAtTarget = false
                        else
                            targetIsChase = false
                            if model:GetAttribute("CompanionChaseUntil") ~= nil and chaseUntil <= now then
                                model:SetAttribute("CompanionChaseUntil", nil)
                            end
                        end
                        local moving = not isAtTarget and (targetPosition - currentPosition).Magnitude >= 0.2
                        if moving then
                            local direction = targetPosition - currentPosition
                            local speed = energy <= 15 and 1.25 or (mood >= 80 and 3.4 or 2.5)
                            if weatherState == "Storm" then
                                speed *= seeksShelter and 0.82 or 0.68
                            elseif weatherState == "Rain" then
                                speed *= enjoysRain and 1.12 or 0.84
                            elseif weatherState == "Fog" then
                                speed *= 0.92
                            end
                            if activityPeriod ~= "Any" then
                                speed *= isPreferredTime and 1.18 or 0.72
                            end
                            if personality == "Энергичный" or personality == "Игривый" then speed *= 1.12 end
                            if personality == "Спокойный" or personality == "Осторожный" then speed *= 0.88 end
                            local step = math.min(direction.Magnitude, speed * delta)
                            currentPosition += direction.Unit * step
                            facing = math.atan2(direction.X, direction.Z)
                            behavior = targetIsChase and "ChasingFriend" or (targetIsTreasure and "Searching" or (targetIsShelter and "SeekingShelter" or (targetIsInterest and "Exploring" or (targetIsSocial and "SeekingFriend" or (mood >= 80 and "Playful" or "Wandering")))))
                            bob = math.abs(math.sin(now * 9 + phase)) * 0.1
                        else
                            local nearToy = toyPart and (currentPosition - toyApproach).Magnitude < 0.55
                            local partnerPosition = partnerModel and partnerModel:GetPivot().Position
                            local nearPartner = partnerPosition and (partnerPosition - currentPosition).Magnitude <= 10
                            if restingTogetherUntil > now and partnerSleeping and pairBondScore >= 30 then
                                behavior = "RestingWithFriend"
                                model:SetAttribute("RestingWithFriend", true)
                                local towardFriend = partnerPosition - currentPosition
                                if towardFriend.Magnitude > 0.05 then
                                    facing = math.atan2(towardFriend.X, towardFriend.Z)
                                end
                                bob = math.abs(math.sin(now * 1.5 + phase)) * 0.025
                            elseif restingTogetherUntil > 0 then
                                restingTogetherUntil = 0
                                model:SetAttribute("RestingWithFriend", nil)
                                idleUntil = now + 0.2
                            elseif socialPlayUntil > now and nearPartner then
                                behavior = "Socializing"
                                local towardFriend = partnerPosition - currentPosition
                                facing = math.atan2(towardFriend.X, towardFriend.Z)
                                bob = math.abs(math.sin(now * 6 + phase)) * 0.12
                                yawOffset = math.sin(now * 4 + phase) * 0.22
                            elseif targetIsSocial then
                                behavior = "SeekingFriend"
                                if nearPartner then
                                    socialPlayUntil = now + random:NextNumber(3.2, 4.6)
                                    socialRewarded = false
                                    idleUntil = socialPlayUntil
                                    local towardFriend = partnerPosition - currentPosition
                                    facing = math.atan2(towardFriend.X, towardFriend.Z)
                                    if slot < partnerSlot and partnerModel then
                                        local partnerId = partnerModel:GetAttribute("CompanionInstanceId")
                                        local pairId = getBondKey(instanceId, partnerId)
                                        local momentKey = tostring(player.UserId) .. ":" .. tostring(pairId)
                                        if pairId and (socialMomentCooldowns[momentKey] or 0) <= now then
                                            socialMomentCooldowns[momentKey] = now + 18
                                            local lastGreeting = pairGreetingLastAt[momentKey] or 0
                                            local isReunion = lastGreeting > 0 and (now - lastGreeting) >= 120
                                            pairGreetingLastAt[momentKey] = now
                                            showSharedHeartMoment(model, partnerModel)
                                            showPersonalityGreeting(
                                                model,
                                                partnerModel,
                                                personality,
                                                partnerPersonality,
                                                isReunion
                                            )
                                            -- Established pairs occasionally turn a normal reunion into a visible ball-passing game.
                                            if pairBondScore >= 10 then
                                                local ballGameKey = tostring(player.UserId) .. ":" .. tostring(pairId)
                                                local ballChance = (personality == "Игривый" or personality == "Энергичный"
                                                    or partnerPersonality == "Игривый" or partnerPersonality == "Энергичный") and 0.42 or 0.22
                                                if (pairedBallCooldowns[ballGameKey] or 0) <= now
                                                    and random:NextNumber() < ballChance
                                                    and showPairedBallGame(model, partnerModel, player.UserId, pairId, personality, now) then
                                                    pairedBallCooldowns[ballGameKey] = now + 45
                                                end
                                            end
                                            local firstKind = model:GetAttribute("CompanionKind")
                                            local secondKind = partnerModel:GetAttribute("CompanionKind")
                                            local speciesKey = getSpeciesMomentKey(firstKind, secondKind)
                                            local speciesMoment = speciesKey and SPECIES_BOND_MOMENTS[speciesKey]
                                            if speciesMoment and pairBondScore >= 30 then
                                                local speciesCooldownKey = momentKey .. ":" .. speciesKey
                                                if (speciesMomentCooldowns[speciesCooldownKey] or 0) <= now
                                                    and random:NextNumber() < 0.35 then
                                                    speciesMomentCooldowns[speciesCooldownKey] = now + 180
                                                    showSpeciesBondMoment(model, partnerModel, speciesMoment)
                                                    profile.Nest.DiscoveredBondMoments = profile.Nest.DiscoveredBondMoments or {}
                                                    local isNewDiscovery = profile.Nest.DiscoveredBondMoments[speciesKey] ~= true
                                                    profile.Nest.DiscoveredBondMoments[speciesKey] = true
                                                    if isNewDiscovery then
                                                        player:SetAttribute("LastNotice", "Открыто особое взаимодействие: " .. speciesMoment.Title)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                bob = math.sin(now * 2 + phase) * 0.045
                            elseif nearToy and toyPlayUntil > now and energy > 10 then
                                behavior = "PlayingWithToy"
                                bob = math.abs(math.sin(now * 7 + phase)) * 0.13
                                yawOffset = math.sin(now * 5 + phase) * 0.18
                                toyPart:SetAttribute("ToyState", "InUse")
                            elseif interestUntil > now then
                                behavior = "VisitingInterest"
                                bob = math.abs(math.sin(now * 2.8 + phase)) * 0.075
                                yawOffset = math.sin(now * 1.8 + phase) * 0.08
                            elseif shelterUntil > now then
                                behavior = "Sheltering"
                                bob = math.sin(now * 1.8 + phase) * 0.025
                                yawOffset = math.sin(now * 0.8 + phase) * 0.04
                            elseif giftCache and treasureSearchOwner == instanceId then
                                behavior = "FoundGift"
                                bob = math.abs(math.sin(now * 5 + phase)) * 0.07
                                yawOffset = math.sin(now * 3 + phase) * 0.12
                            else
                                behavior = energy <= 15 and "Resting" or (hunger <= 20 and "Hungry" or "Idle")
                                bob = math.sin(now * 2 + phase) * 0.055
                                yawOffset = math.sin(now * 1.1 + phase) * 0.09
                                if toyPart then toyPart:SetAttribute("ToyState", "Waiting") end
                            end
                        end

                        if isAtTarget and behavior == "Idle" then
                            local character = player.Character
                            local root = character and character:FindFirstChild("HumanoidRootPart")
                            if root and (root.Position - currentPosition).Magnitude <= 7 then
                                behavior = "Greeting"
                                local towardPlayer = root.Position - currentPosition
                                facing = math.atan2(towardPlayer.X, towardPlayer.Z)
                                bob = math.abs(math.sin(now * 6 + phase)) * 0.1
                            end
                        end
                    end

                    if toyPart and toyPart.Parent then
                        local toyBob = toyPart:GetAttribute("ToyState") == "InUse" and math.abs(math.sin(now * 7 + phase)) * 0.22 or math.sin(now * 2 + phase) * 0.035
                        local spin = toyId == "WindSpinner" and now * 2.8 or (toyPart:GetAttribute("ToyState") == "InUse" and math.sin(now * 6 + phase) * 0.35 or 0)
                        toyPart.CFrame = CFrame.new(toyPosition + Vector3.new(0, toyBob, 0)) * CFrame.Angles(0, spin, 0)
                    end

                    local partnerId = partnerModel and partnerModel:GetAttribute("CompanionInstanceId")
                    local bondKey = getBondKey(instanceId, partnerId)
                    local bondScore = bondKey and math.clamp(math.floor(tonumber(profile.Nest.CompanionBonds[bondKey]) or 0), 0, 100) or 0
                    local bondLevel = getBondLevel(bondScore)
                    model:SetAttribute("FriendshipScore", bondScore)
                    model:SetAttribute("FriendshipLevel", bondLevel)
                    friendshipBillboard.Enabled = bondKey ~= nil and bondScore > 0
                    local bondColor = bondScore >= 90 and Color3.fromRGB(255, 205, 112)
                        or bondScore >= 60 and Color3.fromRGB(194, 139, 255)
                        or bondScore >= 30 and Color3.fromRGB(104, 194, 255)
                        or bondScore >= 10 and Color3.fromRGB(116, 222, 174)
                        or Color3.fromRGB(160, 177, 194)
                    friendshipText.Text = string.format("♥ %s  ·  %d/100", bondLevel, bondScore)
                    friendshipText.TextColor3 = bondColor
                    friendshipCardStroke.Color = bondColor
                    friendshipFill.BackgroundColor3 = bondColor
                    friendshipFill.Size = UDim2.new(bondScore / 100, 0, 1, 0)
                    local habitActive = activeHabit ~= nil and now < activeHabitUntil and isAtTarget and not isSleeping
                    if activeHabit ~= nil and not habitActive then
                        activeHabit = nil
                        model:SetAttribute("PersonalHabit", nil)
                        model:SetAttribute("PersonalHabitText", nil)
                        model:SetAttribute("PersonalHabitUntil", nil)
                    end
                    local beingComfortedUntil = tonumber(model:GetAttribute("BeingComfortedUntil")) or 0
                    local beingComforted = beingComfortedUntil > now and not isSleeping
                    if beingComforted then
                        behavior = "BeingComforted"
                    elseif beingComfortedUntil > 0 then
                        model:SetAttribute("BeingComfortedUntil", nil)
                        model:SetAttribute("BeingComfortedBy", nil)
                    end
                    if careUntil > now and not isSleeping then
                        behavior = "ComfortingFriend"
                    end
                    local reactionUntil = tonumber(model:GetAttribute("GiftReactionUntil")) or 0
                    local giftReaction = model:GetAttribute("GiftReaction")
                    local reactionActive = giftReaction ~= nil and now < reactionUntil and not isSleeping
                    local reactionBob, reactionYaw, reactionRoll = 0, 0, 0
                    if beingComforted or careUntil > now then
                        local comfortPhase = now * 2.2 + phase
                        reactionBob = math.sin(comfortPhase) * 0.035
                        reactionRoll = math.sin(comfortPhase * 0.6) * 0.09
                    end
                    local habitBob, habitYaw, habitRoll = 0, 0, 0
                    if habitActive and not reactionActive then
                        local habitPhase = now * 2.4 + phase
                        if activeHabit == "PlayfulHop" then
                            habitBob = math.abs(math.sin(now * 4.8 + phase)) * 0.22
                        elseif activeHabit == "Stretch" then
                            habitBob = math.abs(math.sin(habitPhase)) * 0.08
                            habitRoll = math.sin(habitPhase * 0.5) * 0.12
                        elseif activeHabit == "Groom" or activeHabit == "Care" then
                            habitBob = math.sin(habitPhase * 0.8) * 0.035
                            habitRoll = math.sin(habitPhase) * 0.13
                        elseif activeHabit == "LookAround" or activeHabit == "WatchSky" or activeHabit == "Inspect" then
                            habitYaw = math.sin(habitPhase * 0.65) * 0.32
                            habitBob = math.sin(habitPhase) * 0.025
                        elseif activeHabit == "Daydream" or activeHabit == "Sway" then
                            habitBob = math.sin(habitPhase * 0.7) * 0.07
                            habitRoll = math.sin(habitPhase * 0.45) * 0.08
                        elseif activeHabit == "Wave" then
                            habitYaw = math.sin(habitPhase * 1.4) * 0.22
                            habitBob = math.abs(math.sin(habitPhase)) * 0.05
                        elseif activeHabit == "Proud" then
                            habitBob = math.abs(math.sin(habitPhase * 0.7)) * 0.08
                            habitRoll = math.sin(habitPhase * 0.5) * 0.035
                        elseif activeHabit == "SniffAround" then
                            habitBob = math.sin(habitPhase * 1.8) * 0.035
                            habitYaw = math.sin(habitPhase * 1.2) * 0.24
                        end
                        behavior = "PersonalHabit"
                    end
                    if reactionActive then
                        local reactionPhase = now * 8 + phase
                        if giftReaction == "Jump" or giftReaction == "Bounce" then
                            reactionBob = math.abs(math.sin(reactionPhase)) * (giftReaction == "Jump" and 0.58 or 0.34)
                        elseif giftReaction == "Spin" then
                            reactionBob = math.abs(math.sin(reactionPhase)) * 0.2
                            reactionYaw = math.sin(reactionPhase * 0.55) * 0.75
                        elseif giftReaction == "Hug" then
                            reactionBob = math.sin(reactionPhase * 0.55) * 0.07
                            reactionRoll = math.sin(reactionPhase * 0.55) * 0.11
                        elseif giftReaction == "Shy" then
                            reactionBob = math.sin(reactionPhase * 0.7) * 0.035
                            reactionRoll = math.sin(reactionPhase * 0.6) * 0.16
                            reactionYaw = math.sin(reactionPhase * 0.45) * 0.12
                        elseif giftReaction == "Sway" or giftReaction == "Dream" then
                            reactionBob = math.sin(reactionPhase * 0.65) * 0.09
                            reactionRoll = math.sin(reactionPhase * 0.5) * 0.09
                        elseif giftReaction == "Proud" then
                            reactionBob = math.abs(math.sin(reactionPhase * 0.8)) * 0.12
                            reactionRoll = math.sin(reactionPhase * 0.5) * 0.06
                        elseif giftReaction == "Amazed" then
                            reactionBob = math.abs(math.sin(reactionPhase * 1.25)) * 0.62
                            reactionYaw = math.sin(reactionPhase * 0.35) * 0.3
                        end
                        behavior = giftReaction == "Hug" and "HuggingFriend" or "CelebratingGift"
                    elseif giftReaction ~= nil then
                        model:SetAttribute("GiftReaction", nil)
                        model:SetAttribute("GiftReactionText", nil)
                        model:SetAttribute("GiftReactionUntil", nil)
                        model:SetAttribute("GiftReactionRare", nil)
                    end
                    moodLabel.Text = (reactionActive and model:GetAttribute("GiftReactionText"))
                        or (beingComforted and "Друг рядом, всё хорошо ♥")
                        or (careUntil > now and "Утешает друга ♥")
                        or (habitActive and model:GetAttribute("PersonalHabitText"))
                        or (isSleeping and "Zzz")
                        or (behavior == "Searching" and "Ищет сокровище")
                        or (behavior == "FoundGift" and "Нашёл подарок!")
                        or (behavior == "Exploring" and ("Исследует: " .. tostring(interestLabel or "остров")))
                        or (behavior == "VisitingInterest" and ("Любимое место: " .. tostring(interestLabel or "гнездо")))
                        or (behavior == "SeekingShelter" and "Ищет укрытие")
                        or (behavior == "Sheltering" and "Прячется от грозы")
                        or (weatherPreference == "Rain" and isWetWeather and behavior == "Idle" and "Радуется дождю")
                        or (activityPeriod ~= "Any" and not isPreferredTime
                            and (behavior == "Idle" or behavior == "Resting") and "Отдыхает до своего времени")
                        or (behavior == "Socializing" and string.format("♥♥  Дружба %d%%", bondScore))
                        or (behavior == "Greeting" and string.format("♥%d ✨", mood))
                        or string.format("♥%d  🍖%d  ⚡%d", mood, hunger, energy)
                    model:SetAttribute("Mood", mood)
                    model:SetAttribute("Behavior", behavior)
                    local hugOffset = Vector3.zero
                    if reactionActive and giftReaction == "Hug" and partnerModel and partnerModel.Parent then
                        local partnerPosition = partnerModel:GetPivot().Position
                        local towardFriend = partnerPosition - currentPosition
                        if towardFriend.Magnitude > 0.1 then
                            hugOffset = towardFriend.Unit * 0.38
                            facing = math.atan2(towardFriend.X, towardFriend.Z)
                        end
                    end
                    local position = currentPosition + hugOffset + Vector3.new(0, bob + reactionBob + habitBob, 0)
                    model:PivotTo(CFrame.new(position) * CFrame.Angles(0, facing + yawOffset + reactionYaw + habitYaw, reactionRoll + habitRoll))
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

function CompanionService:CreateRaidFollowers(player, parent)
    local profile = PlayerDataService:GetProfile(player)
    if not profile or not parent then return {}, nil end

    local ownedById = {}
    for _, companion in ipairs(profile.Companions or {}) do
        if type(companion.InstanceId) == "string" then
            ownedById[companion.InstanceId] = companion
        end
    end

    local followers = {}
    local primary = nil
    local roleLabels = {
        GUARDIAN = "СТРАЖ",
        HEALER = "ЦЕЛИТЕЛЬ",
        HUNTER = "ОХОТНИК",
    }
    local roleColors = {
        GUARDIAN = Color3.fromRGB(118, 196, 239),
        HEALER = Color3.fromRGB(130, 220, 155),
        HUNTER = Color3.fromRGB(255, 166, 105),
    }

    for _, instanceId in ipairs(profile.ActiveCompanions or {}) do
        if #followers >= MAX_VISIBLE_COMPANIONS then break end
        local companion = ownedById[instanceId]
        if companion then
            local model = buildPet(parent, companion, #followers + 1)
            model.Name = "RaidCompanion_" .. tostring(companion.Id) .. "_" .. tostring(#followers + 1)
            model:SetAttribute("RaidOwnerUserId", player.UserId)
            model:SetAttribute("RaidCompanion", true)

            local catalogEntry = CompanionCatalog[companion.Id]
            local raidAbility = catalogEntry and catalogEntry.RaidAbility or nil
            local role = raidAbility and raidAbility.Role or nil
            local petLevel = math.clamp(math.floor(tonumber(companion.Level) or 1), 1, 10)
            local displayName = companion.Name or (catalogEntry and catalogEntry.Name) or companion.Id
            model:SetAttribute("RaidBattleLevel", petLevel)

            local nameplate = Instance.new("BillboardGui")
            nameplate.Name = "RaidCompanionNameplate"
            nameplate.Size = UDim2.fromOffset(150, 30)
            nameplate.StudsOffset = Vector3.new(0, 3.2, 0)
            nameplate.AlwaysOnTop = false
            nameplate.Parent = model.PrimaryPart

            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.BackgroundColor3 = Color3.fromRGB(29, 42, 48)
            label.BackgroundTransparency = 0.16
            label.BorderSizePixel = 0
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = Color3.fromRGB(246, 246, 232)
            label.TextSize = 10
            label.Text = role
                and (displayName .. " · ур. " .. tostring(petLevel) .. " · " .. roleLabels[role])
                or (displayName .. " · ур. " .. tostring(petLevel))
            label.Parent = nameplate
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = label

            local entry = {
                Model = model,
                Companion = companion,
                Ability = raidAbility,
                Name = displayName,
                Role = role,
                Level = petLevel,
            }
            table.insert(followers, entry)

            if not primary and raidAbility and roleLabels[role] then
                primary = entry
                local highlight = Instance.new("Highlight")
                highlight.Name = "RaidPrimaryCompanionHighlight"
                highlight.Adornee = model
                highlight.FillColor = roleColors[role]
                highlight.OutlineColor = roleColors[role]
                highlight.FillTransparency = 0.78
                highlight.OutlineTransparency = 0.12
                highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                highlight.Parent = model
                label.Text = displayName .. " · ур. " .. tostring(petLevel) .. " · " .. roleLabels[role] .. " ★"
            end
        end
    end

    return followers, primary
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
            local side = (index - (#followers + 1) / 2) * 4.2
            local behind = 4 + math.floor((index - 1) / 2) * 2.6
            pet:PivotTo(spawnRoot.CFrame * CFrame.new(side, -2.2, behind) * CFrame.Angles(0, math.pi, 0))
        end
    end

    task.spawn(function()
        while player.Parent and self._generations[player] == generation do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                for index, pet in ipairs(followers) do
                    if pet.Parent then
                        local side = (index - (#followers + 1) / 2) * 4.2
                        local behind = 4 + math.floor((index - 1) / 2) * 2.6
                        local target = root.CFrame * CFrame.new(side, -2.2, behind) * CFrame.Angles(0, math.pi, 0)
                        local current = pet:GetPivot()
                        if (current.Position - target.Position).Magnitude > 0.06
                            or current.LookVector:Dot(target.LookVector) < 0.999 then
                            pet:PivotTo(current:Lerp(target, 0.3))
                        end
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
        local cooldownPrefix = tostring(player.UserId) .. ":"
        for key in pairs(socialMomentCooldowns) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                socialMomentCooldowns[key] = nil
            end
        end
        for key in pairs(pairGreetingLastAt) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                pairGreetingLastAt[key] = nil
            end
        end
        for key in pairs(speciesMomentCooldowns) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                speciesMomentCooldowns[key] = nil
            end
        end
        for key in pairs(GIFT_COOLDOWNS) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                GIFT_COOLDOWNS[key] = nil
            end
        end
        for key in pairs(socialChaseCooldowns) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                socialChaseCooldowns[key] = nil
            end
        end
        for key in pairs(sharedRestCooldowns) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                sharedRestCooldowns[key] = nil
            end
        end
        for key in pairs(pairedBallCooldowns) do
            if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then
                pairedBallCooldowns[key] = nil
            end
        end
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
