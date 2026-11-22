local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local EconomyService = {}
local MAX_TICK_REWARD = 5000

function EconomyService:GrantCoins(player, amount, reason)
    local profile = PlayerDataService:GetProfile(player)
    if not profile or type(amount) ~= "number" or amount <= 0 then return false end
    local safeAmount = math.floor(math.min(amount, MAX_TICK_REWARD))
    profile.Coins = math.clamp(profile.Coins + safeAmount, 0, GameConfig.Economy.MaxCoins)
    player:SetAttribute("Coins", profile.Coins)
    player:SetAttribute("LastNotice", "+" .. safeAmount .. " Coins" .. (reason and (" · " .. reason) or ""))
    return true
end

function EconomyService:GetPassiveIncome(profile)
    local total = 0
    local ownedById = {}
    for _, companion in ipairs(profile.Companions) do
        if type(companion.InstanceId) == "string" then
            ownedById[companion.InstanceId] = companion
        end
    end

    for _, instanceId in ipairs(profile.ActiveCompanions or {}) do
        local companion = ownedById[instanceId]
        if companion and type(companion.Income) == "number" then
            total += math.clamp(math.floor(companion.Income), 0, 1000)
        end
    end
    return math.min(total, MAX_TICK_REWARD)
end

function EconomyService:Start()
    while true do
        task.wait(GameConfig.Economy.PassiveIncomeIntervalSeconds)
        for _, player in ipairs(Players:GetPlayers()) do
            local profile = PlayerDataService:GetProfile(player)
            if profile and #profile.ActiveCompanions > 0 then
                self:GrantCoins(player, self:GetPassiveIncome(profile), "Companion income")
            end
        end
    end
end

return EconomyService
