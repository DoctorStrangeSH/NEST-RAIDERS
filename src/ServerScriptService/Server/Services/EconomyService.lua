local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local ArtifactCatalog = require(ReplicatedStorage.Shared.Config.ArtifactCatalog)

local EconomyService = {}
local MAX_TICK_REWARD = 5000

local function getCompanionIncome(companion)
    local baseIncome = math.clamp(math.floor(tonumber(companion.Income) or 0), 0, 1000)
    local trait = type(companion.GeneticTrait) == "table" and companion.GeneticTrait or {}
    local bonus = math.clamp(tonumber(trait.IncomeBonus) or 0, 0, 0.25)
    return baseIncome * (1 + bonus)
end

function EconomyService:GrantCoins(player, amount, reason)
    local profile = PlayerDataService:GetProfile(player)
    if not profile or type(amount) ~= "number" or amount <= 0 then return false end
    local safeAmount = math.floor(math.min(amount, MAX_TICK_REWARD))
    profile.Coins = math.clamp(profile.Coins + safeAmount, 0, GameConfig.Economy.MaxCoins)
    player:SetAttribute("Coins", profile.Coins)
    player:SetAttribute("LastNotice", "+" .. safeAmount .. " монет" .. (reason and (" · " .. reason) or ""))
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
            total += getCompanionIncome(companion)
        end
    end
    local artifactBonus = 0
    local artifactsById = {}
    for _, artifact in ipairs(profile.Artifacts or {}) do
        if type(artifact.InstanceId) == "string" then artifactsById[artifact.InstanceId] = artifact end
    end
    for _, instanceId in ipairs(profile.EquippedArtifacts or {}) do
        local artifact = artifactsById[instanceId]
        local definition = artifact and ArtifactCatalog[artifact.Id]
        if definition then artifactBonus += math.clamp(tonumber(definition.IncomeBonus) or 0, 0, 0.10) end
    end
    artifactBonus = math.clamp(artifactBonus, 0, 0.20)
    total *= (1 + artifactBonus)
    local accumulated = total + math.clamp(tonumber(profile.CompanionIncomeRemainder) or 0, 0, 0.999999)
    local payout = math.min(math.floor(accumulated), MAX_TICK_REWARD)
    profile.CompanionIncomeRemainder = accumulated - payout
    return payout
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
