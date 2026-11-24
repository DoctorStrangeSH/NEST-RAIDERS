local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)
local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)
local ArtifactBonusService = require(ServerScriptService.Server.Services.ArtifactBonusService)

local EggShopService = {}
local MAX_EGGS = 20
local REQUEST_COOLDOWN = 0.5

local CATALOG = {
    MeadowEgg = {
        Id = "MeadowEgg",
        Name = "Яйцо луга",
        Description = "Первое яйцо для начинающих искателей приключений.",
        Price = 50,
        RequiredLevel = 1,
    },
}

EggShopService._lastRequest = {}

local function buildOdds(profile, eggId)
    local eggDefinition
    for _, biome in pairs(BiomeCatalog) do
        for _, egg in pairs(biome.Eggs or {}) do
            if egg.Id == eggId then eggDefinition = egg break end
        end
        if eggDefinition then break end
    end
    if not eggDefinition then return {} end

    local odds = {}
    for speciesId, weight in pairs(eggDefinition.SpeciesWeights or {}) do
        local companion = CompanionCatalog[speciesId]
        if companion and tonumber(weight) and weight > 0 then
            local actualChance, baseChance = ArtifactBonusService:GetHatchSpeciesChance(
                profile, eggDefinition.SpeciesWeights, speciesId)
            table.insert(odds, {
                Name = companion.Name,
                Rarity = companion.Rarity,
                Chance = math.floor(actualChance * 100 + 0.5),
                BaseChance = math.floor(baseChance * 100 + 0.5),
            })
        end
    end
    table.sort(odds, function(a, b)
        if a.Chance == b.Chance then return a.Name < b.Name end
        return a.Chance > b.Chance
    end)
    return odds
end

local function snapshot(profile)
    local items = {}
    for _, item in pairs(CATALOG) do
        table.insert(items, {
            Id = item.Id,
            Name = item.Name,
            Description = item.Description,
            Price = item.Price,
            RequiredLevel = item.RequiredLevel,
            Odds = buildOdds(profile, item.Id),
        })
    end
    table.sort(items, function(a, b) return a.Price < b.Price end)
    return {
        Items = items,
        Coins = profile.Coins,
        EggCount = #profile.EggInventory,
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
        return { Ok = true, Data = snapshot(profile) }
    end
    if payload.Action ~= "Buy" or type(payload.EggId) ~= "string" then
        return { Ok = false, Message = "Неизвестное действие." }
    end

    local item = CATALOG[payload.EggId]
    if not item then
        return { Ok = false, Message = "Такого яйца нет в магазине." }
    end
    if profile.Level < item.RequiredLevel then
        return { Ok = false, Message = "Нужен уровень " .. item.RequiredLevel .. "." }
    end
    if #profile.EggInventory >= MAX_EGGS then
        return { Ok = false, Message = "Сумка для яиц заполнена (20/20)." }
    end
    if profile.Coins < item.Price then
        return { Ok = false, Message = "Не хватает монет. Нужно: " .. item.Price .. "." }
    end

    profile.Coins -= item.Price
    table.insert(profile.EggInventory, {
        Id = item.Id,
        InstanceId = game:GetService("HttpService"):GenerateGUID(false),
        CollectedAt = os.time(),
        Source = "Shop",
    })

    player:SetAttribute("Coins", profile.Coins)
    player:SetAttribute("EggCount", #profile.EggInventory)
    player:SetAttribute("LastNotice", "Куплено: " .. item.Name .. "!")
    return { Ok = true, Data = snapshot(profile), Message = "Покупка успешна!" }
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
