local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local InventoryService = {}
local MAX_ACTIVE_COMPANIONS = 3
local REQUEST_COOLDOWN = 0.2
InventoryService._lastRequest = {}

local function activeSet(profile)
    local result = {}
    for _, instanceId in ipairs(profile.ActiveCompanions) do
        result[instanceId] = true
    end
    return result
end

local function normalizeProfile(profile)
    profile.ActiveCompanions = type(profile.ActiveCompanions) == "table" and profile.ActiveCompanions or {}
    local owned = {}
    for _, companion in ipairs(profile.Companions) do
        if type(companion.InstanceId) ~= "string" then
            companion.InstanceId = HttpService:GenerateGUID(false)
        end
        if type(companion.InstanceId) == "string" then
            owned[companion.InstanceId] = true
        end
    end

    local clean = {}
    local seen = {}
    for _, instanceId in ipairs(profile.ActiveCompanions) do
        if owned[instanceId] and not seen[instanceId] and #clean < MAX_ACTIVE_COMPANIONS then
            seen[instanceId] = true
            table.insert(clean, instanceId)
        end
    end

    profile.ActiveCompanions = clean
end

local function makeSnapshot(profile)
    local equipped = activeSet(profile)
    local speciesCounts = {}
    local displayed = {}
    for _, instanceId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do displayed[instanceId] = true end
    for _, companion in ipairs(profile.Companions) do
        local key = tostring(companion.Id) .. ":" .. tostring(companion.Stars or 1)
        speciesCounts[key] = (speciesCounts[key] or 0) + 1
    end
    local companions = {}
    for _, companion in ipairs(profile.Companions) do
        table.insert(companions, {
            InstanceId = companion.InstanceId,
            Id = companion.Id,
            Name = companion.Name,
            Rarity = companion.Rarity,
            Level = companion.Level or 1,
            Stars = companion.Stars or 1,
            MergeCount = (displayed[companion.InstanceId] and 0 or speciesCounts[tostring(companion.Id) .. ":" .. tostring(companion.Stars or 1)]) or 1,
            Displayed = displayed[companion.InstanceId] == true,
            Income = companion.Income or 0,
            Equipped = equipped[companion.InstanceId] == true,
        })
    end
    return { Companions = companions, ActiveCount = #profile.ActiveCompanions, MaxActive = MAX_ACTIVE_COMPANIONS }
end

function InventoryService:HandleRequest(player, payload)
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
    normalizeProfile(profile)

    if payload.Action == "Get" then
        return { Ok = true, Data = makeSnapshot(profile) }
    end
    if payload.Action ~= "Equip" and payload.Action ~= "Unequip" and payload.Action ~= "Merge" then
        return { Ok = false, Message = "Неизвестное действие." }
    end
    if type(payload.InstanceId) ~= "string" or #payload.InstanceId > 80 then
        return { Ok = false, Message = "Некорректный питомец." }
    end

    local owned = false
    for _, companion in ipairs(profile.Companions) do
        if companion.InstanceId == payload.InstanceId then owned = true break end
    end
    if not owned then
        return { Ok = false, Message = "Этот питомец тебе не принадлежит." }
    end

    if payload.Action == "Merge" then
        local equipped = activeSet(profile)
        local target
        for _, companion in ipairs(profile.Companions) do
            if companion.InstanceId == payload.InstanceId then
                target = companion
                break
            end
        end
        if not target then
            return { Ok = false, Message = "Питомец не найден." }
        end

        for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
            if displayedId == target.InstanceId then
                return { Ok = false, Message = "Сними питомца с витрины перед слиянием." }
            end
        end
        local currentStars = math.clamp(math.floor(tonumber(target.Stars) or 1), 1, 3)
        if currentStars >= 3 then
            return { Ok = false, Message = "У этого питомца уже максимальный ранг." }
        end

        local consumed = {}
        for _, companion in ipairs(profile.Companions) do
            if companion ~= target
                and companion.Id == target.Id
                and (companion.Stars or 1) == currentStars
                and not (function()
                    for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
                        if displayedId == companion.InstanceId then return true end
                    end
                    return false
                end)()
                and #consumed < 2 then
                table.insert(consumed, companion)
            end
        end
        if #consumed < 2 then
            return { Ok = false, Message = "Для слияния нужны 3 одинаковых питомца одного ранга." }
        end

        local removedIds = {}
        for _, companion in ipairs(consumed) do
            removedIds[companion.InstanceId] = true
        end

        local nextActive = {}
        local targetWasActive = equipped[target.InstanceId] == true
        local transferSlot = false
        for _, instanceId in ipairs(profile.ActiveCompanions) do
            if removedIds[instanceId] then
                transferSlot = true
            elseif instanceId == target.InstanceId then
                targetWasActive = true
                table.insert(nextActive, instanceId)
            else
                table.insert(nextActive, instanceId)
            end
        end
        if transferSlot and not targetWasActive and #nextActive < MAX_ACTIVE_COMPANIONS then
            table.insert(nextActive, target.InstanceId)
        end
        profile.ActiveCompanions = nextActive

        for index = #profile.Companions, 1, -1 do
            if removedIds[profile.Companions[index].InstanceId] then
                table.remove(profile.Companions, index)
            end
        end

        target.Stars = currentStars + 1
        local definition = CompanionCatalog[target.Id]
        local baseIncome = definition and definition.Income or target.Income or 1
        target.Income = math.floor(baseIncome * (target.Stars == 2 and 1.75 or 3))
        target.Level = target.Level or 1

        CompanionService:RefreshPlayer(player)
        player:SetAttribute("CompanionCount", #profile.Companions)
        player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
        player:SetAttribute("LastNotice", target.Name .. " достиг ранга " .. target.Stars .. " звезды!")
        return { Ok = true, Data = makeSnapshot(profile) }
    end

    local equipped = activeSet(profile)
    if payload.Action == "Equip" then
        for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
            if displayedId == payload.InstanceId then
                return { Ok = false, Message = "Сначала сними питомца с витрины." }
            end
        end
        if equipped[payload.InstanceId] then
            return { Ok = true, Data = makeSnapshot(profile) }
        end
        if #profile.ActiveCompanions >= MAX_ACTIVE_COMPANIONS then
            return { Ok = false, Message = "Можно взять с собой только 3 питомцев." }
        end
        table.insert(profile.ActiveCompanions, payload.InstanceId)
    else
        local nextActive = {}
        for _, instanceId in ipairs(profile.ActiveCompanions) do
            if instanceId ~= payload.InstanceId then table.insert(nextActive, instanceId) end
        end
        profile.ActiveCompanions = nextActive
    end

    CompanionService:RefreshPlayer(player)
    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
    return { Ok = true, Data = makeSnapshot(profile) }
end

function InventoryService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local inventoryFunction = remotes:FindFirstChild("CompanionInventory")
    if not inventoryFunction then
        inventoryFunction = Instance.new("RemoteFunction")
        inventoryFunction.Name = "CompanionInventory"
        inventoryFunction.Parent = remotes
    end
    inventoryFunction.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    local function bindPlayer(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then
                local profile = PlayerDataService:GetProfile(player)
                if profile then
                    normalizeProfile(profile)
                    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
                    CompanionService:RefreshPlayer(player)
                end
            end
        end)
        if player:GetAttribute("ProfileLoaded") then
            local profile = PlayerDataService:GetProfile(player)
            if profile then
                normalizeProfile(profile)
                player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
                CompanionService:RefreshPlayer(player)
            end
        end
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player) self._lastRequest[player] = nil end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return InventoryService
