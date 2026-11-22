local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)

local DisplayPetService = {}
DisplayPetService._lastRequest = {}
local REQUEST_COOLDOWN = 0.35
local SLOT_OFFSETS = {
    Vector3.new(-12, 2, 12),
    Vector3.new(12, 2, 12),
    Vector3.new(-12, 2, -12),
    Vector3.new(12, 2, -12),
}

local function getSlotLimit(profile)
    local level = math.clamp(math.floor(tonumber(profile.Nest and profile.Nest.Level) or 1), 1, 5)
    return level - 1
end

local function findOwned(profile, instanceId)
    for _, companion in ipairs(profile.Companions or {}) do
        if companion.InstanceId == instanceId then return companion end
    end
    return nil
end

local function getSnapshot(profile)
    profile.Nest = profile.Nest or { Level = 1, DisplayedCompanions = {}, StoredCoins = 0 }
    profile.Nest.DisplayedCompanions = type(profile.Nest.DisplayedCompanions) == "table" and profile.Nest.DisplayedCompanions or {}
    local limit = getSlotLimit(profile)
    local active = {}
    for _, id in ipairs(profile.ActiveCompanions or {}) do active[id] = true end
    local displayed = {}
    local displayedSet = {}
    for slot = 1, limit do
        local instanceId = profile.Nest.DisplayedCompanions[slot]
        local companion = instanceId and findOwned(profile, instanceId) or nil
        if companion then
            displayedSet[instanceId] = true
            table.insert(displayed, {
                Slot = slot,
                InstanceId = instanceId,
                Id = companion.Id,
                Name = companion.Name,
                Rarity = companion.Rarity,
                Stars = companion.Stars or 1,
                Income = math.max(0, math.floor(tonumber(companion.Income) or 0)),
            })
        else
            table.insert(displayed, { Slot = slot, Empty = true })
        end
    end

    local available = {}
    for _, companion in ipairs(profile.Companions or {}) do
        if not displayedSet[companion.InstanceId] and not active[companion.InstanceId] then
            table.insert(available, {
                InstanceId = companion.InstanceId,
                Name = companion.Name,
                Rarity = companion.Rarity,
                Stars = companion.Stars or 1,
                Income = math.max(0, math.floor(tonumber(companion.Income) or 0)),
            })
        end
    end

    return {
        Level = profile.Nest.Level or 1,
        SlotLimit = limit,
        Displayed = displayed,
        Available = available,
        StoredCoins = math.max(0, math.floor(tonumber(profile.Nest.StoredCoins) or 0)),
        IncomePerTick = (function()
            local total = 0
            for _, item in ipairs(displayed) do total += item.Income or 0 end
            return total
        end)(),
        TickSeconds = 10,
    }
end

function DisplayPetService:RefreshPlayer(player)
    local profile = PlayerDataService:GetProfile(player)
    local plot = PlotService:GetPlayerPlot(player)
    if not profile or not plot then return end
    CompanionService:RefreshDisplayedPets(player, plot, profile.Nest and profile.Nest.DisplayedCompanions or {}, SLOT_OFFSETS)
end

function DisplayPetService:HandleRequest(player, payload)
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
    profile.Nest = profile.Nest or { Level = 1, DisplayedCompanions = {}, StoredCoins = 0 }
    profile.Nest.DisplayedCompanions = type(profile.Nest.DisplayedCompanions) == "table" and profile.Nest.DisplayedCompanions or {}
    profile.Nest.StoredCoins = math.max(0, math.floor(tonumber(profile.Nest.StoredCoins) or 0))

    if payload.Action == "Get" then
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "Place" then
        if type(payload.InstanceId) ~= "string" or #payload.InstanceId > 80 then
            return { Ok = false, Message = "Некорректный питомец." }
        end
        local limit = getSlotLimit(profile)
        local slot = math.floor(tonumber(payload.Slot) or 0)
        if slot < 1 or slot > limit then
            return { Ok = false, Message = "Эта витрина ещё не открыта. Улучши гнездо." }
        end
        local companion = findOwned(profile, payload.InstanceId)
        if not companion then
            return { Ok = false, Message = "Этот питомец тебе не принадлежит." }
        end
        for _, id in ipairs(profile.ActiveCompanions or {}) do
            if id == payload.InstanceId then
                return { Ok = false, Message = "Сначала сними питомца с активной команды." }
            end
        end
        for existingSlot, id in ipairs(profile.Nest.DisplayedCompanions) do
            if id == payload.InstanceId then
                return { Ok = false, Message = "Этот питомец уже стоит на витрине №" .. existingSlot .. "." }
            end
        end
        profile.Nest.DisplayedCompanions[slot] = payload.InstanceId
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", companion.Name .. " теперь живёт в твоём гнезде!")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "Remove" then
        local slot = math.floor(tonumber(payload.Slot) or 0)
        if slot < 1 or slot > getSlotLimit(profile) then
            return { Ok = false, Message = "Некорректная витрина." }
        end
        local instanceId = profile.Nest.DisplayedCompanions[slot]
        if not instanceId then return { Ok = false, Message = "Витрина уже свободна." } end
        profile.Nest.DisplayedCompanions[slot] = nil
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", "Питомец возвращён в коллекцию.")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "Collect" then
        local amount = profile.Nest.StoredCoins
        if amount <= 0 then
            return { Ok = false, Message = "Пока нечего собирать. Питомцы ещё копят монеты." }
        end
        local payout = math.min(amount, math.max(0, 2_000_000_000 - profile.Coins))
        if payout <= 0 then
            return { Ok = false, Message = "Баланс монет достиг максимума. Потрать часть монет и собери накопления позже." }
        end
        profile.Coins += payout
        profile.Nest.StoredCoins = amount - payout
        player:SetAttribute("Coins", profile.Coins)
        player:SetAttribute("LastNotice", "Собрано " .. payout .. " монет с витрин!")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    return { Ok = false, Message = "Неизвестное действие." }
end

function DisplayPetService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("DisplayPets")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "DisplayPets"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    local function bindPlayer(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then
                task.defer(function() self:RefreshPlayer(player) end)
            end
        end)
        if player:GetAttribute("ProfileLoaded") then task.defer(function() self:RefreshPlayer(player) end) end
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player) self._lastRequest[player] = nil end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

function DisplayPetService:Start()
    while true do
        task.wait(10)
        for _, player in ipairs(Players:GetPlayers()) do
            local profile = PlayerDataService:GetProfile(player)
            if profile and profile.Nest and type(profile.Nest.DisplayedCompanions) == "table" then
                local total = 0
                for _, instanceId in pairs(profile.Nest.DisplayedCompanions) do
                    local companion = findOwned(profile, instanceId)
                    if companion then
                        total += math.clamp(math.floor(tonumber(companion.Income) or 0), 0, 1000)
                    end
                end
                profile.Nest.StoredCoins = math.min(
                    (tonumber(profile.Nest.StoredCoins) or 0) + total,
                    2_000_000_000
                )
            end
        end
    end
end

return DisplayPetService
