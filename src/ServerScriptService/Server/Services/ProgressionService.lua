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
    local world = workspace:WaitForChild("NestRaidersWorld", 30)
    if world then
        for _, descendant in ipairs(world:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Name == "EmeraldRunePrompt" then
                descendant.Triggered:Connect(function(player)
                    if player:GetAttribute("CurrentBiome") ~= "EmeraldWilds" then
                        player:SetAttribute("LastNotice", "Эти руны откликаются только в Изумрудном лесу.")
                        return
                    end
                    local profile = PlayerDataService:GetProfile(player)
                    if not profile then
                        player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй немного позже.")
                        return
                    end
                    local runeId = descendant.Parent:GetAttribute("RuneId")
                    if type(runeId) ~= "string"
                        or (runeId ~= "Grove" and runeId ~= "River" and runeId ~= "Dawn") then
                        warn("[NEST RAIDERS] Ignored invalid Emerald trial rune.")
                        return
                    end
                    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
                    profile.QuestProgress.EmeraldTrialRunes = type(profile.QuestProgress.EmeraldTrialRunes) == "table"
                        and profile.QuestProgress.EmeraldTrialRunes or {}
                    if profile.QuestProgress.EmeraldTrialRunes[runeId] then
                        player:SetAttribute("LastNotice", "Эта древняя руна уже пробуждена.")
                        return
                    end
                    profile.QuestProgress.EmeraldTrialRunes[runeId] = true
                    local runes = profile.QuestProgress.EmeraldTrialRunes
                    local count = (runes.Grove and 1 or 0) + (runes.River and 1 or 0) + (runes.Dawn and 1 or 0)
                    player:SetAttribute("EmeraldTrialProgress", count)
                    if count >= 3 and profile.CompletedQuests.emerald_trial ~= true then
                        profile.CompletedQuests.emerald_trial = true
                        player:SetAttribute("EmeraldTrialCompleted", true)
                        self:AddXP(player, 100)
                        self:RefreshZoneUnlocks(player)
                        player:SetAttribute("LastNotice", "Испытание Изумрудной рощи пройдено! Все три руны пробуждены. +100 опыта. Путь к Северным высотам открыт при достижении 12 уровня.")
                    else
                        player:SetAttribute("LastNotice", string.format("Древняя руна пробуждена! Испытание: %d / 3", count))
                    end
                end)
            end
        end
        for _, descendant in ipairs(world:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Name == "ZoneTravelPrompt" then
                descendant.Triggered:Connect(function(player)
                    local zoneId = descendant.Parent:GetAttribute("ZoneId")
                    local destination = descendant.Parent:GetAttribute("Destination")
                    if type(zoneId) ~= "string" or typeof(destination) ~= "Vector3" then return end
                    local allowed, reason = self:CanEnterZone(player, zoneId)
                    if not allowed then
                        local zone = self:GetZone(zoneId)
                        local required = zone and zone.RequiredLevel or 1
                        player:SetAttribute("LastNotice", string.format("Нужно достичь %d уровня, чтобы открыть эту область.", required))
                        return
                    end
                    local character = player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    if not root then
                        player:SetAttribute("LastNotice", "Персонаж ещё загружается. Попробуй снова.")
                        return
                    end
                    character:PivotTo(CFrame.new(destination + Vector3.new(0, 4, 0)))
                    player:SetAttribute("CurrentBiome", zoneId)
                    player:SetAttribute("LastNotice", zoneId == "EmeraldWilds"
                        and "Добро пожаловать в Изумрудный лес!" or "Ты вернулся на стартовый остров.")
                end)
            end
        end
    else
        warn("[NEST RAIDERS] World unavailable; biome portals were not connected.")
    end

    -- Players may join while Bootstrap is still initializing services.
    -- Reconcile both existing and future players without duplicate workers.
    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true
        player:SetAttribute("ProgressionReady", false)
        task.spawn(function()
            while player.Parent and not player:GetAttribute("ProfileLoaded") do
                task.wait(0.1)
            end
            if not player.Parent then return end
            self:RefreshZoneUnlocks(player)
            local profile = PlayerDataService:GetProfile(player)
            local runes = profile and profile.QuestProgress and profile.QuestProgress.EmeraldTrialRunes or {}
            local count = (runes.Grove and 1 or 0) + (runes.River and 1 or 0) + (runes.Dawn and 1 or 0)
            player:SetAttribute("EmeraldTrialProgress", count)
            player:SetAttribute("EmeraldTrialCompleted", profile and profile.CompletedQuests.emerald_trial == true or false)
            player:SetAttribute("CurrentBiome", "StarterIsland")
            player:SetAttribute("ProgressionReady", true)
        end)
    end

    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        boundPlayers[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        bindPlayer(player)
    end
end

return ProgressionService
