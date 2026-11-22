local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local ProgressionService = {}

function ProgressionService:GetZone(zoneId)
    for _, zone in ipairs(GameConfig.Progression.Zones) do
        if zone.Id == zoneId then
            return zone
        end
    end
    return nil
end

function ProgressionService:CanEnterZone(player, zoneId)
    local profile = PlayerDataService:GetProfile(player)
    local zone = self:GetZone(zoneId)

    if not profile or not zone then
        return false, "Profile or zone unavailable"
    end

    if profile.UnlockedZones[zoneId] == true then
        return true
    end

    if profile.Level < zone.RequiredLevel then
        return false, string.format("Reach level %d", zone.RequiredLevel)
    end

    if zone.RequiredQuest and profile.CompletedQuests[zone.RequiredQuest] ~= true then
        return false, "Complete the required trial"
    end

    return true
end

function ProgressionService:RefreshZoneUnlocks(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then
        return
    end

    for _, zone in ipairs(GameConfig.Progression.Zones) do
        if profile.Level >= zone.RequiredLevel
            and (zone.RequiredQuest == nil or profile.CompletedQuests[zone.RequiredQuest] == true) then
            profile.UnlockedZones[zone.Id] = true
        end
    end
end

function ProgressionService:AddXP(player, amount)
    local profile = PlayerDataService:GetProfile(player)
    if not profile or type(amount) ~= "number" or amount <= 0 then
        return false
    end

    local safeAmount = math.floor(math.min(amount, 10000))
    profile.XP += safeAmount

    while profile.Level < GameConfig.Progression.MaxLevel do
        local required = math.floor(GameConfig.Progression.BaseXPToNextLevel
            * (GameConfig.Progression.XPScalePerLevel ^ (profile.Level - 1)))
        if profile.XP < required then
            break
        end

        profile.XP -= required
        profile.Level += 1
    end

    player:SetAttribute("Level", profile.Level)
    self:RefreshZoneUnlocks(player)
    return true
end

function ProgressionService:Init()
    Players.PlayerAdded:Connect(function(player)
        player:SetAttribute("ProgressionReady", false)
        task.spawn(function()
            while player.Parent and not player:GetAttribute("ProfileLoaded") do
                task.wait(0.1)
            end
            if player.Parent then
                self:RefreshZoneUnlocks(player)
                player:SetAttribute("ProgressionReady", true)
            end
        end)
    end)
end

return ProgressionService
