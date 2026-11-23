local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local ProfileTemplate = require(ReplicatedStorage.Shared.Config.ProfileTemplate)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local PlayerDataService = {}
PlayerDataService._profiles = {}
PlayerDataService._store = DataStoreService:GetDataStore(GameConfig.DataStoreName)
PlayerDataService._saving = {}
PlayerDataService._sessionTokens = {}
PlayerDataService._studioFallback = {}
local SESSION_LOCK_SECONDS = 150

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = deepCopy(child) end
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
        and type(data.EggInventory or {}) == "table"
        and type(data.Companions or {}) == "table"
end

-- Migrate older saves before publishing ProfileLoaded, independently of whether
-- the player ever opens the collection book.
local function restoreDiscoveredSpecies(data)
    local discovered = type(data.DiscoveredSpecies) == "table" and data.DiscoveredSpecies or {}
    for _, companion in ipairs(type(data.Companions) == "table" and data.Companions or {}) do
        if type(companion) == "table" and type(companion.Id) == "string"
            and CompanionCatalog[companion.Id] then
            discovered[companion.Id] = true
        end
    end
    data.DiscoveredSpecies = discovered
end

local function publishProfile(player, data)
    restoreDiscoveredSpecies(data)
    data._SessionLock = nil
    PlayerDataService._profiles[player] = data
    player:SetAttribute("Coins", data.Coins)
    local materials = type(data.Materials) == "table" and data.Materials or {}
    player:SetAttribute("AshCrystals", math.max(0, math.floor(tonumber(materials.AshCrystal) or 0)))
    player:SetAttribute("CrystalShards", math.max(0, math.floor(tonumber(materials.CrystalShard) or 0)))
    player:SetAttribute("Level", data.Level)
    player:SetAttribute("ProfilePersistence", PlayerDataService._studioFallback[player] and "TEMPORARY" or "SAVED")
    player:SetAttribute("ProfileLoaded", true)
end

function PlayerDataService:GetProfile(player)
    return self._profiles[player]
end

function PlayerDataService:Load(player)
    -- Default Studio mode is intentionally ephemeral so anyone can press Play
    -- without publishing a place or enabling DataStore API access.
    if RunService:IsStudio() and not GameConfig.UseStudioDataStore then
        local profile = deepCopy(ProfileTemplate)
        reconcile(profile, ProfileTemplate)
        profile.SchemaVersion = GameConfig.DataSchemaVersion
        self._studioFallback[player] = true
        publishProfile(player, profile)
        warn("[NEST RAIDERS] Studio test profile active; progress will not persist.")
        return
    end

    local key = "player_" .. player.UserId
    local token = game.JobId .. ":" .. HttpService:GenerateGUID(false)
    self._sessionTokens[player] = token

    local success, data
    local lockDenied = false
    for attempt = 1, 3 do
        success, data = pcall(function()
            return self._store:UpdateAsync(key, function(current)
                local now = os.time()
                if current ~= nil and not validProfile(current) then
                    error("Stored profile failed validation")
                end

                local existingLock = type(current) == "table" and current._SessionLock or nil
                if existingLock
                    and existingLock.Token ~= token
                    and type(existingLock.ExpiresAt) == "number"
                    and existingLock.ExpiresAt > now then
                    lockDenied = true
                    return current
                end

                local nextData = current and deepCopy(current) or deepCopy(ProfileTemplate)
                reconcile(nextData, ProfileTemplate)
                nextData.SchemaVersion = GameConfig.DataSchemaVersion
                nextData._SessionLock = {
                    Token = token,
                    ExpiresAt = now + SESSION_LOCK_SECONDS,
                }
                return nextData
            end)
        end)
        if success then break end
        task.wait(attempt * 2)
    end

    if not success then
        warn("[NEST RAIDERS] Profile load failed for", player.UserId, data)
        self._sessionTokens[player] = nil
        player:Kick("Your data could not be loaded safely. Please rejoin in a moment.")
        return
    end

    if lockDenied or not validProfile(data) or not data._SessionLock or data._SessionLock.Token ~= token then
        warn("[NEST RAIDERS] Profile is active in another server for", player.UserId)
        self._sessionTokens[player] = nil
        player:Kick("Your save is still active in another server. Please rejoin shortly.")
        return
    end

    publishProfile(player, data)
end

function PlayerDataService:Save(player, releaseLock)
    local profile = self._profiles[player]
    if not profile then return false end
    if self._studioFallback[player] then return true end

    local waitDeadline = os.clock() + 10
    while self._saving[player] and os.clock() < waitDeadline do task.wait(0.1) end
    if self._saving[player] then
        warn("[NEST RAIDERS] Timed out waiting for an existing save for", player.UserId)
        return false
    end

    profile = self._profiles[player]
    local token = self._sessionTokens[player]
    if not profile or not token then return false end

    self._saving[player] = true
    local snapshot = deepCopy(profile)
    local key = "player_" .. player.UserId
    local success, err = pcall(function()
        self._store:UpdateAsync(key, function(current)
            local lock = type(current) == "table" and current._SessionLock or nil
            if not lock or lock.Token ~= token then
                error("Session lock ownership lost; refusing to overwrite profile")
            end

            snapshot._SessionLock = nil
            if releaseLock then return snapshot end

            local nextData = deepCopy(snapshot)
            nextData._SessionLock = {
                Token = token,
                ExpiresAt = os.time() + SESSION_LOCK_SECONDS,
            }
            return nextData
        end)
    end)
    self._saving[player] = nil

    if not success then
        warn("[NEST RAIDERS] Profile save failed for", player.UserId, err)
        return false
    end

    if releaseLock then self._sessionTokens[player] = nil end
    return true
end

function PlayerDataService:Init()
    Players.PlayerAdded:Connect(function(player)
        self:Load(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:Save(player, true)
        self._profiles[player] = nil
        self._sessionTokens[player] = nil
        self._studioFallback[player] = nil
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function() self:Load(player) end)
    end

    game:BindToClose(function()
        local pending = 0
        for _, player in ipairs(Players:GetPlayers()) do
            pending += 1
            task.spawn(function()
                self:Save(player, true)
                pending -= 1
            end)
        end
        local deadline = os.clock() + 25
        while pending > 0 and os.clock() < deadline do task.wait(0.1) end
    end)
end

function PlayerDataService:Start()
    task.spawn(function()
        while true do
            task.wait(GameConfig.AutosaveIntervalSeconds)
            for player in pairs(self._profiles) do
                task.spawn(function() self:Save(player, false) end)
            end
        end
    end)
end

return PlayerDataService
