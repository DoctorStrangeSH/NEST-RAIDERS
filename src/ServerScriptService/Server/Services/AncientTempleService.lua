local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

local AncientTempleService = {}
local SEQUENCE = { "Root", "River", "Dawn" }
local RUNE_NAMES = {
    Root = "Руна Корней",
    River = "Руна Реки",
    Dawn = "Руна Рассвета",
}
local REWARD_COINS = 500
local REWARD_XP = 300
local REWARD_ELDERWOOD = 20
local REQUEST_COOLDOWN = 0.8

local function getState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.AncientTempleRunes =
        type(profile.QuestProgress.AncientTempleRunes) == "table"
        and profile.QuestProgress.AncientTempleRunes or {}
    profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
    return profile, profile.QuestProgress.AncientTempleRunes
end

local function sequenceCount(sequence)
    local count = 0
    for index, expected in ipairs(SEQUENCE) do
        if sequence[index] ~= expected then break end
        count += 1
    end
    return count
end

local function publish(player, profile, sequence)
    player:SetAttribute("AncientTempleProgress", sequenceCount(sequence))
    player:SetAttribute("AncientTempleCompleted",
        profile.CompletedQuests.ancient_temple_trial == true)
end

local function validateAt(player, target, distance)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
        if player.Parent then
            player:SetAttribute("LastNotice", "Храм доступен только в Древних высотах.")
        end
        return false
    end
    if not ProgressionService:CanEnterZone(player, "AncientHeights") then
        player:SetAttribute("LastNotice", "Сначала открой Древние высоты.")
        return false
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - target.Position).Magnitude > distance + 2 then
        return false
    end
    return true
end

function AncientTempleService:Init()
    self._lastRequest = {}
    self._locks = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local temple = ancient and ancient:FindFirstChild("AncientTreeTemple")
    local runeFolder = temple and temple:FindFirstChild("TempleRunes")
    local treasure = temple and temple:FindFirstChild("AncientTempleTreasure")
    local chest = treasure and treasure:FindFirstChild("AncientTempleChest")
    local chestPrompt = chest and chest:FindFirstChild("AncientTempleChestPrompt")
    if not runeFolder or not chestPrompt or not chestPrompt:IsA("ProximityPrompt") then
        warn("[NEST RAIDERS] Ancient Tree Temple puzzle or treasure chest is missing.")
        return
    end

    for _, descendant in ipairs(runeFolder:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "AncientTempleRunePrompt" then
            descendant.Triggered:Connect(function(player)
                if self._locks[player] then return end
                local now = os.clock()
                if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then return end
                self._lastRequest[player] = now
                self._locks[player] = true
                local ok, err = pcall(function()
                    local valid = validateAt(player, descendant.Parent, descendant.MaxActivationDistance)
                    if not valid then return end
                    local profile, sequence = getState(player)
                    if not profile then
                        player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                        return
                    end
                    publish(player, profile, sequence)
                    if profile.CompletedQuests.ancient_temple_trial == true then
                        player:SetAttribute("LastNotice", "Руны храма уже пробуждены. Забери награду из сундука.")
                        return
                    end

                    local runeId = descendant.Parent:GetAttribute("TempleRuneId")
                    local count = sequenceCount(sequence)
                    if count >= #SEQUENCE then
                        player:SetAttribute("LastNotice", "Все руны пробуждены. Найди сундук в глубине храма.")
                        return
                    end
                    local expected = SEQUENCE[count + 1]
                    if runeId ~= expected then
                        table.clear(sequence)
                        publish(player, profile, sequence)
                        player:SetAttribute("LastNotice",
                            "Руны погасли! Начни заново: Корни → Река → Рассвет.")
                        return
                    end

                    table.insert(sequence, runeId)
                    count += 1
                    publish(player, profile, sequence)
                    if count == #SEQUENCE then
                        player:SetAttribute("LastNotice",
                            "Три руны отозвались! Сердце храма пробуждено — открой сундук.")
                    else
                        player:SetAttribute("LastNotice", string.format(
                            "%s пробуждена. Шаг %d из 3.", RUNE_NAMES[runeId] or "Руна", count))
                    end
                end)
                self._locks[player] = nil
                if not ok then
                    warn("[NEST RAIDERS] Ancient Temple rune interaction failed: " .. tostring(err))
                    if player.Parent then
                        player:SetAttribute("LastNotice", "Руна не ответила. Попробуй ещё раз.")
                    end
                end
            end)
        end
    end

    chestPrompt.Triggered:Connect(function(player)
        if self._locks[player] then return end
        local now = os.clock()
        if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then return end
        self._lastRequest[player] = now
        self._locks[player] = true
        local ok, err = pcall(function()
            local valid = validateAt(player, chest, chestPrompt.MaxActivationDistance)
            if not valid then return end
            local profile, sequence = getState(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            publish(player, profile, sequence)
            if profile.CompletedQuests.ancient_temple_trial == true then
                player:SetAttribute("LastNotice", "Сундук уже забран. Сердце храма помнит твою победу.")
                return
            end
            if sequenceCount(sequence) < #SEQUENCE then
                player:SetAttribute("LastNotice", "Сундук запечатан. Сначала пробуди руны: Корни → Река → Рассвет.")
                return
            end

            -- Mark the one-time claim before issuing rewards to prevent duplicate claims.
            profile.CompletedQuests.ancient_temple_trial = true
            profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
            profile.Materials.Elderwood =
                math.max(0, math.floor(tonumber(profile.Materials.Elderwood) or 0)) + REWARD_ELDERWOOD
            player:SetAttribute("Elderwood", profile.Materials.Elderwood)
            EconomyService:GrantCoins(player, REWARD_COINS, "Сокровище храма")
            ProgressionService:AddXP(player, REWARD_XP)
            publish(player, profile, sequence)
            player:SetAttribute("LastNotice", string.format(
                "Сердце храма пробуждено! +%d монет · +%d опыта · +%d древесной эссенции.",
                REWARD_COINS, REWARD_XP, REWARD_ELDERWOOD))
        end)
        self._locks[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Ancient Temple treasure claim failed: " .. tostring(err))
            if player.Parent then
                player:SetAttribute("LastNotice", "Сундук не открылся. Попробуй ещё раз.")
            end
        end
    end)

    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true
        local function sync()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            local profile, sequence = getState(player)
            if profile then publish(player, profile, sequence) end
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(sync)
        sync()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        self._locks[player] = nil
        self._lastRequest[player] = nil
        boundPlayers[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return AncientTempleService
