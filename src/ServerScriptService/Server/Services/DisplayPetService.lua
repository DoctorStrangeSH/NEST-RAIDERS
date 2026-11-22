local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local DisplayPetService = {}
DisplayPetService._lastRequest = {}
DisplayPetService._lastInteraction = {}
local REQUEST_COOLDOWN = 0.35
local INTERACTION_COOLDOWN = 3
local MOOD_GAIN = { Pet = 15, Play = 25 }
local FEED_COST = 10
local FEED_HUNGER = 35
local TREAT_COST = 15
local TREAT_MOOD = 15
local SLEEP_DURATION = 60
local NEEDS_DECAY = { Hunger = 300, Energy = 480, Mood = 600 }
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

local function getNeeds(profile, instanceId, now)
    profile.Nest.CompanionNeeds = type(profile.Nest.CompanionNeeds) == "table" and profile.Nest.CompanionNeeds or {}
    local needs = profile.Nest.CompanionNeeds[instanceId]
    if type(needs) ~= "table" then
        needs = { Hunger = 100, Energy = 100, LastUpdated = now }
        profile.Nest.CompanionNeeds[instanceId] = needs
    end

    local lastUpdated = math.min(tonumber(needs.LastUpdated) or now, now)
    local elapsed = math.max(0, now - lastUpdated)
    local restingUntil = tonumber(needs.RestingUntil) or 0
    local restedSeconds = math.clamp(math.min(now, restingUntil) - lastUpdated, 0, elapsed)

    needs.Hunger = math.clamp((tonumber(needs.Hunger) or 100) - elapsed / NEEDS_DECAY.Hunger, 0, 100)
    needs.Energy = math.clamp((tonumber(needs.Energy) or 100) - elapsed / NEEDS_DECAY.Energy + restedSeconds / 2, 0, 100)
    profile.Nest.CompanionMood[instanceId] = math.clamp(
        (tonumber(profile.Nest.CompanionMood[instanceId]) or 50) - elapsed / NEEDS_DECAY.Mood,
        0,
        100
    )
    needs.LastUpdated = now
    if restingUntil <= now then needs.RestingUntil = nil end
    return needs
end

local function getSnapshot(profile)
    profile.Nest = profile.Nest or { Level = 1, DisplayedCompanions = {}, StoredCoins = 0 }
    profile.Nest.DisplayedCompanions = type(profile.Nest.DisplayedCompanions) == "table" and profile.Nest.DisplayedCompanions or {}
    profile.Nest.CompanionMood = type(profile.Nest.CompanionMood) == "table" and profile.Nest.CompanionMood or {}
    profile.Nest.CompanionNeeds = type(profile.Nest.CompanionNeeds) == "table" and profile.Nest.CompanionNeeds or {}
    local now = os.time()
    local limit = getSlotLimit(profile)
    local active = {}
    for _, id in ipairs(profile.ActiveCompanions or {}) do active[id] = true end
    local displayed = {}
    local displayedSet = {}
    for slot = 1, limit do
        local instanceId = profile.Nest.DisplayedCompanions[tostring(slot)] or profile.Nest.DisplayedCompanions[slot]
        local companion = instanceId and findOwned(profile, instanceId) or nil
        if companion then
            displayedSet[instanceId] = true
            local needs = getNeeds(profile, instanceId, now)
            local definition = CompanionCatalog[companion.Id] or {}
            table.insert(displayed, {
                Slot = slot,
                InstanceId = instanceId,
                Id = companion.Id,
                Name = companion.Name,
                Rarity = companion.Rarity,
                Stars = companion.Stars or 1,
                Income = math.max(0, math.floor(tonumber(companion.Income) or 0)),
                Mood = math.floor(profile.Nest.CompanionMood[instanceId] or 50),
                Hunger = math.floor(needs.Hunger),
                Energy = math.floor(needs.Energy),
                IsSleeping = (tonumber(needs.RestingUntil) or 0) > now,
                Personality = definition.Personality or "Без характера",
                PersonalityDescription = definition.PersonalityDescription or "",
                FavoriteFood = definition.FavoriteFood or "Обычный корм",
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
    profile.Nest.CompanionMood = type(profile.Nest.CompanionMood) == "table" and profile.Nest.CompanionMood or {}

    if payload.Action == "Get" then
        local snapshot = getSnapshot(profile)
        self:RefreshPlayer(player)
        return { Ok = true, Data = snapshot }
    end

    if payload.Action == "Place" then
        if type(payload.InstanceId) ~= "string" or #payload.InstanceId > 80 then
            return { Ok = false, Message = "Некорректный питомец." }
        end
        if not PlotService:GetPlayerPlot(player) then
            return { Ok = false, Message = "Сначала дождись назначения личного гнезда." }
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
        for existingSlot, id in pairs(profile.Nest.DisplayedCompanions) do
            if id == payload.InstanceId then
                return { Ok = false, Message = "Этот питомец уже стоит на витрине №" .. tostring(existingSlot) .. "." }
            end
        end
        local slotKey = tostring(slot)
        if profile.Nest.DisplayedCompanions[slotKey] or profile.Nest.DisplayedCompanions[slot] then
            return { Ok = false, Message = "Эта витрина уже занята." }
        end
        profile.Nest.DisplayedCompanions[slotKey] = payload.InstanceId
        profile.Nest.DisplayedCompanions[slot] = nil
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", companion.Name .. " теперь живёт в твоём гнезде!")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "Remove" then
        if not PlotService:GetPlayerPlot(player) then
            return { Ok = false, Message = "Сначала дождись назначения личного гнезда." }
        end
        local slot = math.floor(tonumber(payload.Slot) or 0)
        if slot < 1 or slot > getSlotLimit(profile) then
            return { Ok = false, Message = "Некорректная витрина." }
        end
        local slotKey = tostring(slot)
        local instanceId = profile.Nest.DisplayedCompanions[slotKey] or profile.Nest.DisplayedCompanions[slot]
        if not instanceId then return { Ok = false, Message = "Витрина уже свободна." } end
        profile.Nest.DisplayedCompanions[slotKey] = nil
        profile.Nest.DisplayedCompanions[slot] = nil
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", "Питомец возвращён в коллекцию.")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "Interact" then
        if not PlotService:GetPlayerPlot(player) then
            return { Ok = false, Message = "Сначала дождись назначения личного гнезда." }
        end
        if type(payload.InstanceId) ~= "string" or #payload.InstanceId > 80 then
            return { Ok = false, Message = "Некорректный питомец." }
        end
        local interaction = payload.Interaction
        local isDisplayed = false
        for _, id in pairs(profile.Nest.DisplayedCompanions) do
            if id == payload.InstanceId then isDisplayed = true break end
        end
        if not isDisplayed then
            return { Ok = false, Message = "Питомец сейчас не находится в гнезде." }
        end
        local companion = findOwned(profile, payload.InstanceId)
        if not companion then
            return { Ok = false, Message = "Питомец не найден в коллекции." }
        end
        local interactionKey = tostring(player.UserId) .. ":" .. payload.InstanceId
        local lastInteraction = self._lastInteraction[interactionKey] or 0
        if now - lastInteraction < INTERACTION_COOLDOWN then
            return { Ok = false, Message = "Питомцу нужно немного времени перед новой игрой." }
        end
        local needs = getNeeds(profile, payload.InstanceId, os.time())
        local definition = CompanionCatalog[companion.Id] or {}
        if interaction == "Feed" or interaction == "Treat" then
            local isTreat = interaction == "Treat"
            local cost = isTreat and TREAT_COST or FEED_COST
            if profile.Coins < cost then
                return { Ok = false, Message = "Не хватает монет. Нужно " .. cost .. " монет." }
            end
            if needs.Hunger >= 95 then
                return { Ok = false, Message = companion.Name .. " пока не голоден." }
            end
            profile.Coins -= cost
            needs.Hunger = math.clamp(needs.Hunger + FEED_HUNGER, 0, 100)
            local moodGain = isTreat and TREAT_MOOD or 5
            profile.Nest.CompanionMood[payload.InstanceId] = math.clamp(
                (tonumber(profile.Nest.CompanionMood[payload.InstanceId]) or 50) + moodGain,
                0,
                100
            )
            player:SetAttribute("Coins", profile.Coins)
            self._lastInteraction[interactionKey] = now
            self:RefreshPlayer(player)
            local foodName = isTreat and (definition.FavoriteFood or "лакомство") or "корм"
            player:SetAttribute("LastNotice", companion.Name .. " с удовольствием съел: " .. foodName .. "!")
            return { Ok = true, Data = getSnapshot(profile) }
        elseif interaction == "Sleep" then
            if (tonumber(needs.RestingUntil) or 0) > os.time() then
                return { Ok = false, Message = companion.Name .. " уже отдыхает." }
            end
            if needs.Energy >= 95 then
                return { Ok = false, Message = companion.Name .. " полон энергии." }
            end
            needs.RestingUntil = os.time() + SLEEP_DURATION
            self._lastInteraction[interactionKey] = now
            self:RefreshPlayer(player)
            player:SetAttribute("LastNotice", companion.Name .. " устроился отдохнуть на минутку.")
            return { Ok = true, Data = getSnapshot(profile) }
        else
            local gain = MOOD_GAIN[interaction]
            if not gain then
                return { Ok = false, Message = "Неизвестное взаимодействие." }
            end
            if interaction == "Play" and needs.Energy < 10 then
                return { Ok = false, Message = companion.Name .. " устал. Дай ему отдохнуть." }
            end
            local personalityBonus = interaction == "Play"
                and (tonumber(definition.PlayMoodBonus) or 0)
                or (tonumber(definition.PetMoodBonus) or 0)
            profile.Nest.CompanionMood[payload.InstanceId] = math.clamp(
                (tonumber(profile.Nest.CompanionMood[payload.InstanceId]) or 50) + gain + personalityBonus,
                0,
                100
            )
            if interaction == "Play" then
                needs.Energy = math.max(0, needs.Energy - 10)
            end
            self._lastInteraction[interactionKey] = now
            self:RefreshPlayer(player)
            player:SetAttribute("LastNotice", interaction == "Pet" and (companion.Name .. " довольно мурлычет!") or (companion.Name .. " весело играет с тобой!"))
            return { Ok = true, Data = getSnapshot(profile) }
        end
    end

    if payload.Action == "Collect" then
        if not PlotService:GetPlayerPlot(player) then
            return { Ok = false, Message = "Сначала дождись назначения личного гнезда." }
        end
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
    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
        local prefix = tostring(player.UserId) .. ":"
        for key in pairs(self._lastInteraction) do
            if string.sub(key, 1, #prefix) == prefix then self._lastInteraction[key] = nil end
        end
    end)
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
