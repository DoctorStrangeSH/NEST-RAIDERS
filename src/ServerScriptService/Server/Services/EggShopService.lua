local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)
local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local ArtifactBonusService = require(ServerScriptService.Server.Services.ArtifactBonusService)

local EggShopService = {}
local MAX_EGGS = 20
local REQUEST_COOLDOWN = 0.5

-- The hidden Forgotten Cave egg remains an exploration/cache reward.
-- Natural biome eggs are sold only after their biome has been unlocked.
local SHOP_ORDER = {
    "MeadowEgg",
    "EmeraldEgg",
    "FrostEgg",
    "EmberEgg",
    "CrystalEgg",
    "AncientEgg",
}

local SHOP_PRICES = {
    MeadowEgg = 50,
    EmeraldEgg = 250,
    FrostEgg = 700,
    EmberEgg = 1800,
    CrystalEgg = 4500,
    AncientEgg = 10000,
}

local ZONE_BY_BIOME = {
    Meadow = "StarterIsland",
    EmeraldWilds = "EmeraldWilds",
    FrostHighlands = "FrostHighlands",
    Emberlands = "Emberlands",
    CrystalRealm = "CrystalRealm",
    AncientHeights = "AncientHeights",
}

EggShopService._lastRequest = {}

local function findEgg(eggId)
    for biomeId, biome in pairs(BiomeCatalog) do
        for _, egg in pairs(biome.Eggs or {}) do
            if egg.Id == eggId then
                return biomeId, biome, egg
            end
        end
    end
    return nil, nil, nil
end

local function getRequiredLevel(zoneId)
    for _, zone in ipairs(GameConfig.Progression.Zones or {}) do
        if zone.Id == zoneId then
            return zone.RequiredLevel or 1, zone.RequiredQuest
        end
    end
    return 1, nil
end

local function buildOdds(profile, eggDefinition)
    local odds = {}
    local weights = eggDefinition and eggDefinition.SpeciesWeights or {}
    for speciesId, weight in pairs(weights) do
        local companion = CompanionCatalog[speciesId]
        if companion and (tonumber(weight) or 0) > 0 then
            local actualChance, baseChance = ArtifactBonusService:GetHatchSpeciesChance(
                profile, weights, speciesId)
            table.insert(odds, {
                Id = speciesId,
                Name = companion.Name,
                Rarity = companion.Rarity,
                Chance = math.max(0, actualChance * 100),
                BaseChance = math.max(0, baseChance * 100),
            })
        end
    end
    table.sort(odds, function(a, b)
        if a.Chance == b.Chance then return a.Name < b.Name end
        return a.Chance > b.Chance
    end)
    return odds
end

local function getLockReason(player, profile, zoneId, requiredLevel, requiredQuest)
    local unlocked = ProgressionService:CanEnterZone(player, zoneId)
    if unlocked then return true, nil end
    if (tonumber(profile.Level) or 1) < requiredLevel then
        return false, "Откроется с " .. tostring(requiredLevel) .. " уровня"
    end
    if requiredQuest and profile.CompletedQuests and profile.CompletedQuests[requiredQuest] ~= true then
        return false, "Сначала пройди испытание биома"
    end
    return false, "Сначала открой этот биом"
end

local function buildCatalogItem(eggId)
    local biomeId, biome, egg = findEgg(eggId)
    if not biome or not egg then return nil end
    local zoneId = ZONE_BY_BIOME[biomeId]
    if not zoneId then return nil end
    local requiredLevel, requiredQuest = getRequiredLevel(zoneId)
    return {
        Id = eggId,
        Name = egg.Name,
        Description = "Яйцо из биома «" .. biome.Name .. "». Внутри может оказаться один из трёх местных видов.",
        Rarity = egg.Rarity or "Обычное",
        Price = SHOP_PRICES[eggId],
        BiomeId = biomeId,
        BiomeName = biome.Name,
        ZoneId = zoneId,
        RequiredLevel = requiredLevel,
        RequiredQuest = requiredQuest,
        EggDefinition = egg,
    }
end

local function snapshot(player, profile)
    local items = {}
    for index, eggId in ipairs(SHOP_ORDER) do
        local item = buildCatalogItem(eggId)
        if item then
            local unlocked, lockReason = getLockReason(
                player, profile, item.ZoneId, item.RequiredLevel, item.RequiredQuest)
            local enoughCoins = (tonumber(profile.Coins) or 0) >= item.Price
            local hasCapacity = #(profile.EggInventory or {}) < MAX_EGGS
            local buyBlockReason = lockReason
            if unlocked and not hasCapacity then
                buyBlockReason = "Сумка заполнена · 20/20"
            elseif unlocked and not enoughCoins then
                buyBlockReason = "Нужно ещё " .. tostring(item.Price - (tonumber(profile.Coins) or 0)) .. " мон."
            end
            table.insert(items, {
                Id = item.Id,
                Name = item.Name,
                Description = item.Description,
                Rarity = item.Rarity,
                Price = item.Price,
                BiomeId = item.BiomeId,
                BiomeName = item.BiomeName,
                RequiredLevel = item.RequiredLevel,
                RequiredQuest = item.RequiredQuest,
                Unlocked = unlocked,
                CanBuy = unlocked and enoughCoins and hasCapacity,
                LockReason = lockReason,
                BuyBlockReason = buyBlockReason,
                Odds = buildOdds(profile, item.EggDefinition),
                LayoutOrder = index,
            })
        end
    end
    return {
        Items = items,
        Coins = profile.Coins,
        EggCount = #(profile.EggInventory or {}),
        EggCapacity = MAX_EGGS,
    }
end

function EggShopService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос." }
    end

    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then
        return { Ok = false, Message = "Подожди немного." }
    end
    self._lastRequest[player] = now

    local profile = PlayerDataService:GetProfile(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end

    if payload.Action == "Get" then
        return { Ok = true, Data = snapshot(player, profile) }
    end
    if payload.Action ~= "Buy" or type(payload.EggId) ~= "string" then
        return { Ok = false, Message = "Неизвестное действие." }
    end

    local item = buildCatalogItem(payload.EggId)
    if not item then
        return { Ok = false, Message = "Это яйцо нельзя купить в лавке. Ищи его в соответствующем приключении." }
    end

    local unlocked, lockReason = getLockReason(
        player, profile, item.ZoneId, item.RequiredLevel, item.RequiredQuest)
    if not unlocked then
        return { Ok = false, Message = lockReason .. "." }
    end
    if #(profile.EggInventory or {}) >= MAX_EGGS then
        return { Ok = false, Message = "Сумка для яиц заполнена (20/20)." }
    end
    if (tonumber(profile.Coins) or 0) < item.Price then
        return { Ok = false, Message = "Не хватает монет. Нужно: " .. tostring(item.Price) .. "." }
    end

    profile.Coins -= item.Price
    table.insert(profile.EggInventory, {
        Id = item.Id,
        BiomeId = item.BiomeId,
        InstanceId = HttpService:GenerateGUID(false),
        CollectedAt = os.time(),
        Source = "Shop",
    })

    player:SetAttribute("Coins", profile.Coins)
    player:SetAttribute("EggCount", #profile.EggInventory)
    player:SetAttribute("LastNotice", "В сумке новое яйцо: " .. item.Name .. "!")
    return {
        Ok = true,
        Data = snapshot(player, profile),
        Message = item.Name .. " добавлено в сумку!",
    }
end

function EggShopService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end

    local remote = remotes:FindFirstChild("EggShop")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "EggShop"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
    end)
end

return EggShopService
