local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local ProfileTemplate = require(ReplicatedStorage.Shared.Config.ProfileTemplate)

local PlayerDataService = {}
PlayerDataService._profiles = {}
PlayerDataService._store = DataStoreService:GetDataStore(GameConfig.DataStoreName)
PlayerDataService._saving = {}

local function deepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, child in pairs(value) do
        copy[key] = deepCopy(child)
    end
    return copy
end

local function reconcile(target, template)
    for key, defaultValue in pairs(template) do
        if target[key] == nil then
            target[key] = deepCopy(defaultValue)
        elseif type(defaultValue) == "table" and type(target[key]) == "table" then
            reconcile(target[key], defaultValue)
        end
    end
end

local function validProfile(data)
    return type(data) == "table"
        and type(data.Coins) == "number"
        and type(data.XP) == "number"
        and type(data.Level) == "number"
        and type(data.UnlockedZones) == "table"
end

function PlayerDataService:GetProfile(player)
    return self._profiles[player]
end

function PlayerDataService:Load(player)
    local key = "player_" .. player.UserId
    local success, data

    for attempt = 1, 3 do
        success, data = pcall(function()
            return self._store:GetAsync(key)
        end)
        if success then
            break
        end
        task.wait(attempt * 2)
    end

    if not success then
        warn("[NEST RAIDERS] Profile load failed for", player.UserId, data)
        player:Kick("Your data could not be loaded safely. Please rejoin in a moment.")
        return
    end

    if data == nil then
        data = deepCopy(ProfileTemplate)
    elseif not validProfile(data) then
        warn("[NEST RAIDERS] Invalid profile rejected for", player.UserId)
        player:Kick("Your save data could not be validated. Please contact support.")
        return
    else
        reconcile(data, ProfileTemplate)
    end

    data.SchemaVersion = GameConfig.DataSchemaVersion
    self._profiles[player] = data

    player:SetAttribute("Coins", data.Coins)
    player:SetAttribute("Level", data.Level)
    player:SetAttribute("ProfileLoaded", true)
end

function PlayerDataService:Save(player)
    local profile = self._profiles[player]
    if not profile or self._saving[player] then
        return false
    end

    self._saving[player] = true
    local snapshot = deepCopy(profile)
    local key = "player_" .. player.UserId
    local success, err = pcall(function()
        self._store:UpdateAsync(key, function()
            return snapshot
        end)
    end)
    self._saving[player] = nil

    if not success then
        warn("[NEST RAIDERS] Profile save failed for", player.UserId, err)
        return false
    end
    return true
end

function PlayerDataService:Init()
    Players.PlayerAdded:Connect(function(player)
        self:Load(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:Save(player)
        self._profiles[player] = nil
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            self:Load(player)
        end)
    end

    game:BindToClose(function()
        local pending = 0
        for _, player in ipairs(Players:GetPlayers()) do
            pending += 1
            task.spawn(function()
                self:Save(player)
                pending -= 1
            end)
        end

        local deadline = os.clock() + 25
        while pending > 0 and os.clock() < deadline do
            task.wait(0.1)
        end
    end)
end

function PlayerDataService:Start()
    task.spawn(function()
        while true do
            task.wait(GameConfig.AutosaveIntervalSeconds)
            for player in pairs(self._profiles) do
                task.spawn(function()
                    self:Save(player)
                end)
            end
        end
    end)
end

return PlayerDataService
