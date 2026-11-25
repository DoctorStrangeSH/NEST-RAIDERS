local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local BondJournalService = {}

local MOMENTS = {
    {
        Id = "Fox|Turtle",
        Title = "Лесные хранители",
        Hint = "Некоторые друзья находят общий язык благодаря любви к природе.",
        Rarity = "Необычное",
        Icon = "🍃",
        Color = Color3.fromRGB(151, 207, 119),
    },
    {
        Id = "Dragon|Owl",
        Title = "Искра мудрости",
        Hint = "Попробуй познакомить любознательного и мудрого обитателя.",
        Rarity = "Редкое",
        Icon = "✨",
        Color = Color3.fromRGB(157, 190, 255),
    },
    {
        Id = "EmberFox|MagmaDragon",
        Title = "Тёплое пламя",
        Hint = "Жители жарких мест могут скрывать особенный секрет.",
        Rarity = "Эпическое",
        Icon = "🔥",
        Color = Color3.fromRGB(255, 157, 91),
    },
    {
        Id = "AncientStag|RootSprite",
        Title = "Древний союз",
        Hint = "Древние силы природы редко встречаются случайно.",
        Rarity = "Легендарное",
        Icon = "🌿",
        Color = Color3.fromRGB(177, 208, 125),
    },
}

local GIFT_COLLECTION = {
    MeadowEgg = { Biome = "Луговые острова", Gifts = { { "Букет луговых цветов", "🌼" }, { "Корзинка сладких ягод", "🫐" }, { "Резной желудь", "🌰" } } },
    EmeraldEgg = { Biome = "Изумрудные чащи", Gifts = { { "Светящийся лист", "🍃" }, { "Лесной кристалл", "💎" }, { "Живой росток", "🌱" } } },
    FrostEgg = { Biome = "Морозные вершины", Gifts = { { "Снежная брошь", "❄️" }, { "Ледяная звезда", "⭐" }, { "Морозная ракушка", "🐚" } } },
    EmberEgg = { Biome = "Пепельные земли", Gifts = { { "Тёплый уголь-сердечко", "🔥" }, { "Солнечная бусина", "☀️" }, { "Янтарный осколок", "🟠" } } },
    CrystalEgg = { Biome = "Кристальное царство", Gifts = { { "Призматический осколок", "💠" }, { "Лунная груша", "🍐" }, { "Звёздный нектар", "✨" } } },
    AncientEgg = { Biome = "Древние высоты", Gifts = { { "Золотой желудь", "🌰" }, { "Семя древнего дерева", "🌳" }, { "Лепесток вечности", "🌸" } } },
    ForgottenCaveEgg = { Biome = "Забытая пещера", Gifts = { { "Светящийся гриб", "🍄" }, { "Камень эха", "🔮" }, { "Осколок сердца пещеры", "💜" } } },
    LineageEgg = { Biome = "Наследие", Gifts = { { "Реликвия рода", "🏵️" }, { "Семя предков", "🌿" }, { "Семейный талисман", "🧿" } } },
}

local function buildSnapshot(profile)
    profile.Nest = type(profile.Nest) == "table" and profile.Nest or {}
    local discoveries = type(profile.Nest.DiscoveredBondMoments) == "table"
        and profile.Nest.DiscoveredBondMoments or {}
    profile.Nest.DiscoveredBondMoments = discoveries

    local giftDiscoveries = type(profile.Nest.DiscoveredCompanionGifts) == "table"
        and profile.Nest.DiscoveredCompanionGifts or {}
    profile.Nest.DiscoveredCompanionGifts = giftDiscoveries

    local entries = {}
    local discoveredCount = 0
    for _, definition in ipairs(MOMENTS) do
        local discovered = discoveries[definition.Id] == true
        if discovered then discoveredCount += 1 end
        table.insert(entries, {
            Id = definition.Id,
            Title = discovered and definition.Title or "???",
            Hint = discovered and "Секрет уже открыт. Его можно снова увидеть в игре." or definition.Hint,
            Rarity = definition.Rarity,
            Icon = discovered and definition.Icon or "🔒",
            Color = discovered and definition.Color or Color3.fromRGB(112, 126, 145),
            Discovered = discovered,
        })
    end

    local giftTotal = 0
    for eggId, biome in pairs(GIFT_COLLECTION) do
        for _, gift in ipairs(biome.Gifts) do
            local giftName, giftIcon = gift[1], gift[2]
            for _, isRare in ipairs({ false, true }) do
                local title = isRare and ("Особенный дар: " .. giftName) or giftName
                local key = eggId .. ":" .. title
                local discovered = giftDiscoveries[key] == true
                if discovered then discoveredCount += 1 end
                giftTotal += 1
                table.insert(entries, {
                    Id = "gift:" .. key,
                    Title = discovered and title or "???",
                    Hint = discovered and ("Подарок из биома «" .. biome.Biome .. "». Его можно снова увидеть в игре.")
                        or ("Питомцы из биома «" .. biome.Biome .. "» иногда делятся такими находками."),
                    Rarity = isRare and "Особенный" or "Подарок",
                    Icon = discovered and (isRare and "💖" or giftIcon) or "🔒",
                    Color = discovered and (isRare and Color3.fromRGB(255, 205, 112) or Color3.fromRGB(142, 210, 166))
                        or Color3.fromRGB(112, 126, 145),
                    Discovered = discovered,
                    Category = "Gift",
                })
            end
        end
    end

    local total = #MOMENTS + giftTotal
    return {
        Entries = entries,
        Discovered = discoveredCount,
        Total = total,
        CompletionPercent = math.floor(discoveredCount / total * 100 + 0.5),
    }
end

function BondJournalService:HandleRequest(player, payload)
    if type(payload) ~= "table" or payload.Action ~= "Get" then
        return { Ok = false, Message = "Некорректный запрос." }
    end
    local profile = PlayerDataService:GetProfile(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    return { Ok = true, Data = buildSnapshot(profile) }
end

function BondJournalService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("BondJournal")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "BondJournal"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end
end

return BondJournalService
