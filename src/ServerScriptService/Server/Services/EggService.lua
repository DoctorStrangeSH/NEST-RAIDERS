local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local EggService = {}
local EGG_RESPAWN_SECONDS = 20
local EGG_CAPACITY = 20
EggService._hatching = {}
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

    local originalSize = egg.Size
    local originalCFrame = egg.CFrame
    egg.CanCollide = false
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
    if prompt then prompt.Enabled = false end

    -- Clear visual feedback: the egg flies toward the avatar and shrinks away.
    local collectTarget = root.CFrame * CFrame.new(0, 0.5, -1.5)
    local collectTween = TweenService:Create(
        egg,
        TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        { CFrame = collectTarget, Size = Vector3.new(0.15, 0.15, 0.15), Transparency = 1 }
    )
    collectTween:Play()

    task.delay(EGG_RESPAWN_SECONDS, function()
        if egg and egg.Parent then
            egg.CFrame = originalCFrame
            egg.Size = originalSize
            egg.Transparency = 1
            egg:SetAttribute("Collected", false)
            egg.CanCollide = true
            local respawnTween = TweenService:Create(
                egg,
                TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Transparency = 0, Size = originalSize }
            )
            respawnTween:Play()
            if prompt then prompt.Enabled = true end
        end
    end)
end

function EggService:_HatchUnlocked(player, station)
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

    -- Select the first hatchable egg without changing the order of inventory.
    -- An incubating breeding egg must not block a ready meadow/shop egg behind it.
    local now = os.time()
    local hatchIndex, egg
    local shortestWait
    for index, candidate in ipairs(profile.EggInventory) do
        if type(candidate) == "table" then
            local remaining = candidate.Origin == "Breeding"
                and math.max(0, (tonumber(candidate.IncubatesUntil) or 0) - now) or 0
            if remaining <= 0 then
                hatchIndex, egg = index, candidate
                break
            end
            shortestWait = shortestWait and math.min(shortestWait, remaining) or remaining
        end
    end
    if not egg then
        if shortestWait then
            local minutes = math.floor(shortestWait / 60)
            local seconds = math.floor(shortestWait % 60)
            player:SetAttribute("LastNotice", string.format(
                "Все яйца ещё инкубируются. Ближайшее: %d мин. %d сек.", minutes, seconds))
        else
            player:SetAttribute("LastNotice", "Не удалось прочитать яйца в сумке. Обратись к поддержке.")
        end
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

    -- Validate everything needed for the pet and confirmation BEFORE removing
    -- the egg. Malformed legacy breeding traits must not consume an egg and
    -- leave a partially created companion behind.
    if type(definition) ~= "table"
        or type(definition.Id) ~= "string"
        or type(definition.Name) ~= "string"
        or type(definition.Rarity) ~= "string"
        or type(definition.Income) ~= "number"
        or type(geneticTrait) ~= "table"
        or type(geneticTrait.Name) ~= "string" then
        warn("[NEST RAIDERS] Invalid hatch companion/trait data; retaining egg.")
        player:SetAttribute("LastNotice", "Данные яйца повреждены. Яйцо сохранено; обратись к поддержке.")
        return
    end
    table.remove(profile.EggInventory, hatchIndex)
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
    -- Register a discovery at the moment of hatching, regardless of whether
    -- this individual pet is later merged, bred or removed.
    profile.DiscoveredSpecies = type(profile.DiscoveredSpecies) == "table"
        and profile.DiscoveredSpecies or {}
    profile.DiscoveredSpecies[companion.Id] = true
    profile.ActiveCompanions = profile.ActiveCompanions or {}
    if #profile.ActiveCompanions < 3 then
        table.insert(profile.ActiveCompanions, companion.InstanceId)
    end

    syncAttributes(player, profile)
    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
    -- Commit the pet and counters first; visual refresh is a secondary effect.
    -- A broken model should not prevent the successful hatch notification.
    local xpCallOk, xpResult = pcall(function()
        return ProgressionService:AddXP(player, 15)
    end)
    local xpAwarded = xpCallOk and xpResult == true
    if not xpAwarded then
        warn("[NEST RAIDERS] Hatch XP update failed: " .. tostring(xpResult))
    end
    local visualOk, visualError = pcall(function()
        CompanionService:RefreshPlayer(player)
    end)
    if not visualOk then
        warn("[NEST RAIDERS] Hatch companion visual refresh failed: " .. tostring(visualError))
    end
    local originMessage = egg.Origin == "Breeding" and " · наследие родителей" or ""
    local xpMessage = xpAwarded and " +15 опыта" or ""
    player:SetAttribute("LastNotice", "Вылупился питомец: " .. definition.Name .. " (" .. definition.Rarity .. ") · " .. geneticTrait.Name .. originMessage .. "!" .. xpMessage)
end


-- Serialize hatch requests per player. ProximityPrompt can fire more than once
-- while a previous hatch is still refreshing the follower model.
function EggService:Hatch(player, station)
    if self._hatching[player] then return end
    self._hatching[player] = true
    local ok, err = pcall(function()
        self:_HatchUnlocked(player, station)
    end)
    self._hatching[player] = nil
    if not ok then
        warn("[NEST RAIDERS] Hatch request failed safely: " .. tostring(err))
        if player and player.Parent then
            player:SetAttribute("LastNotice", "Произошла ошибка при вылуплении. Проверь коллекцию питомцев и попробуй ещё раз.")
        end
    end
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
        self._hatching[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        bindPlayer(player)
    end
end

return EggService
