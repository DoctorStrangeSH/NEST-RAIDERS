local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)

local FireTrialService = {}
local BOSS_MAX_HEALTH = 100
local PLAYER_HIT_DAMAGE = 25
local BOSS_DAMAGE = 18
local PLAYER_HIT_COOLDOWN = 1.25
local BOSS_ATTACK_COOLDOWN = 4.5
local BOSS_WINDUP_SECONDS = 1.4
local BOSS_ATTACK_RADIUS = 23
local REWARD_XP = 250

local RUNE_IDS = {
    Ember = true,
    Cinder = true,
    Inferno = true,
}

local function getRuneCount(runes)
    return (runes.Ember and 1 or 0)
        + (runes.Cinder and 1 or 0)
        + (runes.Inferno and 1 or 0)
end

local function getProfileState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.EmberTrialRunes = type(profile.QuestProgress.EmberTrialRunes) == "table"
        and profile.QuestProgress.EmberTrialRunes or {}
    local progress = profile.QuestProgress
    progress.EmberTrialBossHealth = math.clamp(
        math.floor(tonumber(progress.EmberTrialBossHealth) or BOSS_MAX_HEALTH), 0, BOSS_MAX_HEALTH)
    return profile, progress
end

local function publishState(player, profile, progress)
    local count = getRuneCount(progress.EmberTrialRunes)
    player:SetAttribute("EmberTrialProgress", count)
    player:SetAttribute("EmberTrialBossHealth", progress.EmberTrialBossHealth)
    player:SetAttribute("EmberTrialCompleted", profile.CompletedQuests.ember_trial == true)
    player:SetAttribute("EmberTrialBossUnlocked", count >= 3)
end

local function validatePlayerAt(player, target, distance)
    if player:GetAttribute("CurrentBiome") ~= "Emberlands" then
        player:SetAttribute("LastNotice", "Испытание Огненного сердца доступно только в Пепельных землях.")
        return false
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return false end
    if (root.Position - target.Position).Magnitude > distance + 2 then return false end
    return true, character, root, humanoid
end

function FireTrialService:Init()
    self._lastPlayerHit = {}
    self._lastBossAttack = {}
    self._windups = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ember = world and world:FindFirstChild("Emberlands")
    local trial = ember and ember:FindFirstChild("HeartOfFireTrial")
    if not trial then
        warn("[NEST RAIDERS] Heart of Fire trial arena is missing.")
        return
    end

    for _, descendant in ipairs(trial:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "EmberTrialRunePrompt" then
            descendant.Triggered:Connect(function(player)
                if not validatePlayerAt(player, descendant.Parent, descendant.MaxActivationDistance) then return end
                local profile, progress = getProfileState(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй немного позже.")
                    return
                end
                if profile.CompletedQuests.ember_trial == true then
                    player:SetAttribute("LastNotice", "Ты уже прошёл Испытание Огненного сердца.")
                    return
                end
                local runeId = descendant.Parent:GetAttribute("RuneId")
                if type(runeId) ~= "string" or not RUNE_IDS[runeId] then
                    warn("[NEST RAIDERS] Ignored invalid Ember trial rune.")
                    return
                end
                local runes = progress.EmberTrialRunes
                if runes[runeId] == true then
                    player:SetAttribute("LastNotice", "Эта руна уже пробуждена.")
                    return
                end
                runes[runeId] = true
                local count = getRuneCount(runes)
                publishState(player, profile, progress)
                if count >= 3 then
                    player:SetAttribute("LastNotice", "Три руны пробуждены! Сердце вулкана открыто. Иди к Огненному стражу!")
                else
                    player:SetAttribute("LastNotice", string.format("Руна %d из 3 пробуждена. Найди остальные!", count))
                end
            end)
        elseif descendant:IsA("ProximityPrompt") and descendant.Name == "EmberTrialBossPrompt" then
            descendant.Triggered:Connect(function(player)
                local valid, character, root, humanoid = validatePlayerAt(player, descendant.Parent, descendant.MaxActivationDistance)
                if not valid then return end
                local profile, progress = getProfileState(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй немного позже.")
                    return
                end
                if profile.CompletedQuests.ember_trial == true then
                    player:SetAttribute("LastNotice", "Огненный страж уже признал твою силу.")
                    return
                end
                if getRuneCount(progress.EmberTrialRunes) < 3 then
                    player:SetAttribute("LastNotice", "Сначала пробуди все три руны Огненного сердца.")
                    return
                end

                local now = os.clock()
                if now - (self._lastPlayerHit[player] or 0) < PLAYER_HIT_COOLDOWN then return end
                self._lastPlayerHit[player] = now

                local health = progress.EmberTrialBossHealth
                if health <= 0 then
                    health = BOSS_MAX_HEALTH
                    progress.EmberTrialBossHealth = health
                end
                health = math.max(0, health - PLAYER_HIT_DAMAGE)
                progress.EmberTrialBossHealth = health
                player:SetAttribute("EmberTrialBossHealth", health)

                if health <= 0 then
                    profile.CompletedQuests.ember_trial = true
                    player:SetAttribute("EmberTrialCompleted", true)
                    player:SetAttribute("EmberTrialBossUnlocked", false)
                    ProgressionService:AddXP(player, REWARD_XP)
                    ProgressionService:RefreshZoneUnlocks(player)
                    player:SetAttribute("LastNotice", "Огненный страж повержен! Испытание пройдено. +250 опыта. Путь в Хрустальное королевство открыт на 35 уровне!")
                    return
                end

                player:SetAttribute("LastNotice", string.format("Удар по Огненному стражу! Осталось здоровья: %d / %d. ГОТОВЬСЯ УКЛОНИТЬСЯ!", health, BOSS_MAX_HEALTH))
                if now - (self._lastBossAttack[player] or 0) >= BOSS_ATTACK_COOLDOWN
                    and not self._windups[player] then
                    self._lastBossAttack[player] = now
                    self._windups[player] = true
                    player:SetAttribute("EmberTrialBossWindup", true)
                    task.delay(BOSS_WINDUP_SECONDS, function()
                        self._windups[player] = nil
                        if not player.Parent then return end
                        player:SetAttribute("EmberTrialBossWindup", false)
                        local currentCharacter = player.Character
                        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
                        local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
                        if player:GetAttribute("CurrentBiome") == "Emberlands"
                            and currentRoot and currentHumanoid and currentHumanoid.Health > 0
                            and (currentRoot.Position - descendant.Parent.Position).Magnitude <= BOSS_ATTACK_RADIUS then
                            currentHumanoid:TakeDamage(BOSS_DAMAGE)
                            player:SetAttribute("LastNotice", "Огненный удар попал! Отходи от стража во время подготовки атаки.")
                        elseif player.Parent then
                            player:SetAttribute("LastNotice", "Ты уклонился от огненной волны!")
                        end
                    end)
                end
            end)
        end
    end

    local bound = {}
    local function bind(player)
        if bound[player] then return end
        bound[player] = true
        player:SetAttribute("EmberTrialProgress", 0)
        player:SetAttribute("EmberTrialBossHealth", BOSS_MAX_HEALTH)
        player:SetAttribute("EmberTrialCompleted", false)
        player:SetAttribute("EmberTrialBossUnlocked", false)
        player:SetAttribute("EmberTrialBossWindup", false)
        task.spawn(function()
            while player.Parent and not player:GetAttribute("ProfileLoaded") do task.wait(0.1) end
            if not player.Parent then return end
            local profile, progress = getProfileState(player)
            if profile then publishState(player, profile, progress) end
        end)
    end

    Players.PlayerAdded:Connect(bind)
    Players.PlayerRemoving:Connect(function(player)
        bound[player] = nil
        self._lastPlayerHit[player] = nil
        self._lastBossAttack[player] = nil
        self._windups[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bind(player) end
end

return FireTrialService
