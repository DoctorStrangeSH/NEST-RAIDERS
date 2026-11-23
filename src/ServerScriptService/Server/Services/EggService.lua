local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local EggService = {}
local EGG_RESPAWN_SECONDS = 20
local EGG_CAPACITY = 20
local COMPANIONS = {}
for _, definition in pairs(CompanionCatalog) do
    if (tonumber(definition.Weight) or 0) > 0 then
        table.insert(COMPANIONS, definition)
    end
end
table.sort(COMPANIONS, function(a, b) return a.Id < b.Id end)

local GENETIC_TRAITS = {
    { Id = "Natural", Name = "Естественный", Rarity = "Обычный", Weight = 72, IncomeBonus = 0 },
    { Id = "Verdant", Name = "Изумрудный", Rarity = "Необычный", Weight = 18, IncomeBonus = 0.02 },
    { Id = "Luminous", Name = "Светящийся", Rarity = "Редкий", Weight = 8, IncomeBonus = 0.05 },
    { Id = "Prismatic", Name = "Призматический", Rarity = "Эпический", Weight = 2, IncomeBonus = 0.08 },
}

local function chooseGeneticTrait()
    local totalWeight = 0
    for _, trait in ipairs(GENETIC_TRAITS) do totalWeight += trait.Weight end
    local roll = math.random() * totalWeight
    local cursor = 0
    for _, trait in ipairs(GENETIC_TRAITS) do
        cursor += trait.Weight
        if roll <= cursor then
            return {
                Id = trait.Id,
                Name = trait.Name,
                Rarity = trait.Rarity,
                IncomeBonus = trait.IncomeBonus,
            }
        end
    end
    return { Id = "Natural", Name = "Естественный", Rarity = "Обычный", IncomeBonus = 0 }
end

local function syncAttributes(player, profile)
    player:SetAttribute("EggCount", #profile.EggInventory)
    player:SetAttribute("BreedingEggCount", (function()
        local count = 0
        for _, egg in ipairs(profile.EggInventory) do
            if egg.Origin == "Breeding" then count += 1 end
        end
        return count
    end)())
    player:SetAttribute("CompanionCount", #profile.Companions)
    player:SetAttribute("Coins", profile.Coins)
end

local function chooseCompanion()
    local totalWeight = 0
    for _, companion in ipairs(COMPANIONS) do totalWeight += companion.Weight end
    local roll = math.random() * totalWeight
    local cursor = 0
    for _, companion in ipairs(COMPANIONS) do
        cursor += companion.Weight
        if roll <= cursor then return companion end
    end
    return COMPANIONS[1]
end

function EggService:Collect(player, egg)
    if not player:GetAttribute("ProfileLoaded") or not egg or not egg:IsDescendantOf(Workspace) then return end
    if egg:GetAttribute("Collected") or not egg:GetAttribute("WorldEgg") then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - egg.Position).Magnitude > 14 then return end

    local profile = PlayerDataService:GetProfile(player)
    if not profile or #profile.EggInventory >= EGG_CAPACITY then
        player:SetAttribute("LastNotice", "Сумка для яиц заполнена!")
        return
    end

    egg:SetAttribute("Collected", true)
    table.insert(profile.EggInventory, {
        Id = "MeadowEgg",
        InstanceId = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999)),
        CollectedAt = os.time(),
    })
    syncAttributes(player, profile)
    player:SetAttribute("LastNotice", "Ты подобрал яйцо луга!")

    egg.Transparency = 1
    egg.CanCollide = false
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
    if prompt then prompt.Enabled = false end

    task.delay(EGG_RESPAWN_SECONDS, function()
        if egg and egg.Parent then
            egg:SetAttribute("Collected", false)
            egg.Transparency = 0
            egg.CanCollide = true
            if prompt then prompt.Enabled = true end
        end
    end)
end

function EggService:Hatch(player, station)
    if not player:GetAttribute("ProfileLoaded") then return end
    local profile = PlayerDataService:GetProfile(player)
    if not profile or #profile.EggInventory == 0 then
        player:SetAttribute("LastNotice", "Сначала найди или купи яйцо!")
        return
    end

    local plotId = station and station:GetAttribute("PlotId")
    if not plotId or not PlotService:IsOwner(player, plotId) then
        player:SetAttribute("LastNotice", "Это гнездо принадлежит другому игроку.")
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - station.Position).Magnitude > 14 then return end

    local egg = profile.EggInventory[1]
    if type(egg) ~= "table" then
        player:SetAttribute("LastNotice", "Яйцо повреждено. Обратись к поддержке.")
        return
    end
    local now = os.time()
    if egg.Origin == "Breeding" and (tonumber(egg.IncubatesUntil) or 0) > now then
        local remaining = math.max(1, math.floor(egg.IncubatesUntil - now))
        local minutes = math.floor(remaining / 60)
        local seconds = remaining % 60
        player:SetAttribute("LastNotice", string.format("Яйцо ещё инкубируется: %d мин. %d сек.", minutes, seconds))
        return
    end

    local definition
    local geneticTrait
    if egg.Origin == "Breeding" then
        definition = CompanionCatalog[egg.OffspringSpeciesId]
        if not definition or type(egg.GeneticTrait) ~= "table" then
            player:SetAttribute("LastNotice", "Не удалось определить наследство яйца.")
            return
        end
        geneticTrait = egg.GeneticTrait
    else
        definition = chooseCompanion()
        geneticTrait = chooseGeneticTrait()
    end
    table.remove(profile.EggInventory, 1)
    local companion = {
        InstanceId = HttpService:GenerateGUID(false),
        Id = definition.Id,
        Name = definition.Name,
        Rarity = definition.Rarity,
        Income = definition.Income,
        Level = 1,
        GrowthXP = 0,
        Stars = 1,
        GeneticTrait = geneticTrait,
        HatchedAt = now,
        Origin = egg.Origin or "Hatch",
        ParentSpecies = type(egg.ParentSpecies) == "table" and egg.ParentSpecies or nil,
    }
    table.insert(profile.Companions, companion)
    profile.ActiveCompanions = profile.ActiveCompanions or {}
    if #profile.ActiveCompanions < 3 then
        table.insert(profile.ActiveCompanions, companion.InstanceId)
    end

    syncAttributes(player, profile)
    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
    ProgressionService:AddXP(player, 15)
    CompanionService:RefreshPlayer(player)
    local originMessage = egg.Origin == "Breeding" and " · наследие родителей" or ""
    player:SetAttribute("LastNotice", "Вылупился питомец: " .. definition.Name .. " (" .. definition.Rarity .. ") · " .. geneticTrait.Name .. originMessage .. "! +15 опыта")
end

function EggService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    if not world then
        warn("[NEST RAIDERS] World was not built before EggService initialized.")
        return
    end

    local island = world:WaitForChild("StarterIsland")
    local eggFolder = island:WaitForChild("EggSpawnPoints")
    for _, egg in ipairs(eggFolder:GetChildren()) do
        local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
        if prompt then prompt.Triggered:Connect(function(player) self:Collect(player, egg) end) end
    end

    local plotsFolder = island:WaitForChild("PlayerPlots")
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local station = plot:FindFirstChild("HatchStation")
        local prompt = station and station:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            prompt.Triggered:Connect(function(player) self:Hatch(player, station) end)
        end
    end

    -- The first player can join before EggService:Init is reached.
    -- Bind the same load-complete signal for existing AND future players;
    -- reading the profile only once misses an in-flight DataStore load.
    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true
        local function syncWhenReady()
            if not player:GetAttribute("ProfileLoaded") then return end
            local profile = PlayerDataService:GetProfile(player)
            if profile then syncAttributes(player, profile) end
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(syncWhenReady)
        syncWhenReady()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        boundPlayers[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        bindPlayer(player)
    end
end

return EggService
