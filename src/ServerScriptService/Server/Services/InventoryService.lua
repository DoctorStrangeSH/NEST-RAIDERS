local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)

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
    local companions = {}
    for _, companion in ipairs(profile.Companions) do
        table.insert(companions, {
            InstanceId = companion.InstanceId,
            Id = companion.Id,
            Name = companion.Name,
            Rarity = companion.Rarity,
            Level = companion.Level or 1,
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
    if payload.Action ~= "Equip" and payload.Action ~= "Unequip" then
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

    local equipped = activeSet(profile)
    if payload.Action == "Equip" then
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
