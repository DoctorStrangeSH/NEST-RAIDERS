local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

local VoidTrialService = {}
local SEQUENCE = { "Rift", "Echo", "Star" }
local RUNE_NAMES = {
    Rift = "Руна Разлома",
    Echo = "Руна Эха",
    Star = "Руна Звезды",
}
local REWARD_COINS = 900
local REWARD_XP = 650
local REWARD_STARSHARD = 25
local REQUEST_COOLDOWN = 0.8

local function getState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.VoidTrialRunes =
        type(profile.QuestProgress.VoidTrialRunes) == "table" and profile.QuestProgress.VoidTrialRunes or {}
    profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
    return profile, profile.QuestProgress.VoidTrialRunes
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
    player:SetAttribute("VoidTrialProgress", sequenceCount(sequence))
    player:SetAttribute("VoidTrialCompleted", profile.CompletedQuests.void_trial == true)
end

local function validateAt(player, target, distance)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "VoidFrontier" then
        if player.Parent then player:SetAttribute("LastNotice", "Испытание доступно только на Границе пустоты.") end
        return false
    end
    if not ProgressionService:CanEnterZone(player, "VoidFrontier") then
        player:SetAttribute("LastNotice", "Сначала открой Границу пустоты.")
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

function VoidTrialService:Init()
    self._lastRequest = {}
    self._locks = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local void = world and world:FindFirstChild("VoidFrontier")
    local trial = void and void:FindFirstChild("VoidTrial")
    local runeFolder = trial and trial:FindFirstChild("VoidTrialRunes")
    local altar = trial and trial:FindFirstChild("VoidTrialAltar")
    local altarPrompt = altar and altar:FindFirstChild("VoidTrialAltarPrompt")
    if not runeFolder or not altarPrompt or not altarPrompt:IsA("ProximityPrompt") then
        warn("[NEST RAIDERS] Void Trial puzzle or altar is missing.")
        return
    end

    local function interact(player, callback)
        if self._locks[player] then return end
        local now = os.clock()
        if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then return end
        self._lastRequest[player] = now
        self._locks[player] = true
        local ok, err = pcall(callback)
        self._locks[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Void Trial interaction failed: " .. tostring(err))
            if player.Parent then player:SetAttribute("LastNotice", "Энергия пустоты не ответила. Попробуй ещё раз.") end
        end
    end

    for _, descendant in ipairs(runeFolder:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "VoidTrialRunePrompt" then
            descendant.Triggered:Connect(function(player)
                interact(player, function()
                    if not validateAt(player, descendant.Parent, descendant.MaxActivationDistance) then return end
                    local profile, sequence = getState(player)
                    if not profile then
                        player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                        return
                    end
                    publish(player, profile, sequence)
                    if profile.CompletedQuests.void_trial == true then
                        player:SetAttribute("LastNotice", "Руны уже пробуждены. Испытание завершено.")
                        return
                    end
                    local runeId = descendant.Parent:GetAttribute("VoidRuneId")
                    local count = sequenceCount(sequence)
                    if count >= #SEQUENCE then
                        player:SetAttribute("LastNotice", "Все руны пробуждены. Коснись алтаря пустоты.")
                        return
                    end
                    local expected = SEQUENCE[count + 1]
                    if runeId ~= expected then
                        table.clear(sequence)
                        publish(player, profile, sequence)
                        player:SetAttribute("LastNotice", "Руны рассеялись! Начни заново: Разлом → Эхо → Звезда.")
                        return
                    end
                    table.insert(sequence, runeId)
                    count += 1
                    publish(player, profile, sequence)
                    if count == #SEQUENCE then
                        player:SetAttribute("LastNotice", "Три руны отозвались! Подойди к алтарю пустоты.")
                    else
                        player:SetAttribute("LastNotice", string.format(
                            "%s пробуждена. Шаг %d из 3.", RUNE_NAMES[runeId] or "Руна", count))
                    end
                end)
            end)
        end
    end

    altarPrompt.Triggered:Connect(function(player)
        interact(player, function()
            if not validateAt(player, altar, altarPrompt.MaxActivationDistance) then return end
            local profile, sequence = getState(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            publish(player, profile, sequence)
            if profile.CompletedQuests.void_trial == true then
                player:SetAttribute("LastNotice", "Алтарь уже пробуждён. Награда получена.")
                return
            end
            if sequenceCount(sequence) < #SEQUENCE then
                player:SetAttribute("LastNotice", "Алтарь запечатан. Сначала пробуди руны: Разлом → Эхо → Звезда.")
                return
            end
            profile.CompletedQuests.void_trial = true
            profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
            profile.Materials.Starshard =
                math.max(0, math.floor(tonumber(profile.Materials.Starshard) or 0)) + REWARD_STARSHARD
            player:SetAttribute("Starshard", profile.Materials.Starshard)
            EconomyService:GrantCoins(player, REWARD_COINS, "Испытание пустоты")
            ProgressionService:AddXP(player, REWARD_XP)
            publish(player, profile, sequence)
            player:SetAttribute("LastNotice", string.format(
                "Испытание пустоты завершено! +%d монет · +%d опыта · +%d звёздных осколков.",
                REWARD_COINS, REWARD_XP, REWARD_STARSHARD))
        end)
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

return VoidTrialService
