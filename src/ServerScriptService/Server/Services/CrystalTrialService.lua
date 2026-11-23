local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)

local CrystalTrialService = {}
local BOSS_MAX_HEALTH = 160
local PLAYER_HIT_DAMAGE = 20
local BOSS_DAMAGE = 22
local PLAYER_HIT_COOLDOWN = 1.0
local BOSS_ATTACK_COOLDOWN = 4.2
local BOSS_WINDUP_SECONDS = 1.55
local BOSS_ATTACK_RADIUS = 24
local REWARD_XP = 500

local PRISM_SEQUENCE = { "Azure", "Rose", "Crown" }
local PRISM_NAMES = {
    Azure = "Лазурный луч",
    Rose = "Розовый луч",
    Crown = "Золотой луч",
}

local function getState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    local progress = profile.QuestProgress
    progress.CrystalTrialPrisms = type(progress.CrystalTrialPrisms) == "table"
        and progress.CrystalTrialPrisms or {}
    progress.CrystalTrialBossHealth = math.clamp(
        math.floor(tonumber(progress.CrystalTrialBossHealth) or BOSS_MAX_HEALTH), 0, BOSS_MAX_HEALTH)
    profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
    return profile, progress
end

local function sequenceCount(sequence)
    local count = 0
    for index, expected in ipairs(PRISM_SEQUENCE) do
        if sequence[index] ~= expected then break end
        count += 1
    end
    return count
end

local function publish(player, profile, progress)
    local count = sequenceCount(progress.CrystalTrialPrisms)
    player:SetAttribute("CrystalTrialProgress", count)
    player:SetAttribute("CrystalTrialBossHealth", progress.CrystalTrialBossHealth)
    player:SetAttribute("CrystalTrialCompleted", profile.CompletedQuests.crystal_trial == true)
    player:SetAttribute("CrystalTrialBossUnlocked", count >= #PRISM_SEQUENCE)
end

local function validateAt(player, target, distance)
    if player:GetAttribute("CurrentBiome") ~= "CrystalRealm" then
        player:SetAttribute("LastNotice", "Испытание призмы доступно только в Хрустальном королевстве.")
        return false
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return false end
    if (root.Position - target.Position).Magnitude > distance + 2 then return false end
    return true, root, humanoid
end

function CrystalTrialService:Init()
    self._lastPlayerHit = {}
    self._lastBossAttack = {}
    self._windups = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local crystal = world and world:FindFirstChild("CrystalRealm")
    local trial = crystal and crystal:FindFirstChild("PrismTrial")
    if not trial then
        warn("[NEST RAIDERS] Crystal Prism Trial arena is missing.")
        return
    end

    for _, descendant in ipairs(trial:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "CrystalPrismPrompt" then
            descendant.Triggered:Connect(function(player)
                local valid = validateAt(player, descendant.Parent, descendant.MaxActivationDistance)
                if not valid then return end
                local allowed = ProgressionService:CanEnterZone(player, "CrystalRealm")
                if not allowed then
                    player:SetAttribute("LastNotice", "Сначала открой Хрустальное королевство.")
                    return
                end
                local profile, progress = getState(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                    return
                end
                if profile.CompletedQuests.crystal_trial == true then
                    player:SetAttribute("LastNotice", "Световая печать уже восстановлена.")
                    return
                end

                local prismId = descendant.Parent:GetAttribute("PrismId")
                local count = sequenceCount(progress.CrystalTrialPrisms)
                local expected = PRISM_SEQUENCE[count + 1]
                if prismId ~= expected then
                    table.clear(progress.CrystalTrialPrisms)
                    publish(player, profile, progress)
                    player:SetAttribute("LastNotice", "Луч рассеялся! Последовательность сброшена. Начни с лазурного, затем розовый и золотой.")
                    return
                end

                table.insert(progress.CrystalTrialPrisms, prismId)
                count += 1
                publish(player, profile, progress)
                if count >= #PRISM_SEQUENCE then
                    player:SetAttribute("LastNotice", "Три луча соединены! Пробуди Хранителя призмы.")
                else
                    player:SetAttribute("LastNotice", string.format("%s настроен. Луч %d из 3. Продолжай последовательность.", PRISM_NAMES[prismId], count))
                end
            end)
        elseif descendant:IsA("ProximityPrompt") and descendant.Name == "CrystalTrialBossPrompt" then
            descendant.Triggered:Connect(function(player)
                local valid = validateAt(player, descendant.Parent, descendant.MaxActivationDistance)
                if not valid then return end
                local profile, progress = getState(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                    return
                end
                if profile.CompletedQuests.crystal_trial == true then
                    player:SetAttribute("LastNotice", "Хранитель призмы уже признал твою силу.")
                    return
                end
                if sequenceCount(progress.CrystalTrialPrisms) < #PRISM_SEQUENCE then
                    player:SetAttribute("LastNotice", "Сначала восстанови последовательность трёх световых лучей.")
                    return
                end

                local now = os.clock()
                local lastHit = self._lastPlayerHit[player]
                if lastHit and now - lastHit < PLAYER_HIT_COOLDOWN then return end
                self._lastPlayerHit[player] = now

                local health = math.max(0, progress.CrystalTrialBossHealth - PLAYER_HIT_DAMAGE)
                progress.CrystalTrialBossHealth = health
                player:SetAttribute("CrystalTrialBossHealth", health)
                if health <= 0 then
                    profile.CompletedQuests.crystal_trial = true
                    player:SetAttribute("CrystalTrialCompleted", true)
                    player:SetAttribute("CrystalTrialBossUnlocked", false)
                    ProgressionService:AddXP(player, REWARD_XP)
                    ProgressionService:RefreshZoneUnlocks(player)
                    player:SetAttribute("LastNotice", "Хранитель призмы повержен! +500 опыта. Путь к Древним высотам открыт — осталось достичь 50 уровня!")
                    return
                end

                player:SetAttribute("LastNotice", string.format("Удар по Хранителю призмы! Здоровье: %d / %d.", health, BOSS_MAX_HEALTH))
                local lastAttack = self._lastBossAttack[player]
                if (not lastAttack or now - lastAttack >= BOSS_ATTACK_COOLDOWN)
                    and not self._windups[player] then
                    self._lastBossAttack[player] = now
                    self._windups[player] = true
                    player:SetAttribute("CrystalTrialBossWindup", true)
                    player:SetAttribute("LastNotice", "Хранитель собирает призматическую волну! Отойди от него!")
                    local bossCore = descendant.Parent
                    task.delay(BOSS_WINDUP_SECONDS, function()
                        self._windups[player] = nil
                        if not player.Parent then return end
                        player:SetAttribute("CrystalTrialBossWindup", false)
                        local character = player.Character
                        local root = character and character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        if player:GetAttribute("CurrentBiome") == "CrystalRealm"
                            and root and humanoid and humanoid.Health > 0
                            and (root.Position - bossCore.Position).Magnitude <= BOSS_ATTACK_RADIUS then
                            humanoid:TakeDamage(BOSS_DAMAGE)
                            player:SetAttribute("LastNotice", "Призматическая волна попала! Уклоняйся во время подготовки атаки.")
                        elseif player.Parent then
                            player:SetAttribute("LastNotice", "Ты уклонился от призматической волны!")
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
        player:SetAttribute("CrystalTrialProgress", 0)
        player:SetAttribute("CrystalTrialBossHealth", BOSS_MAX_HEALTH)
        player:SetAttribute("CrystalTrialCompleted", false)
        player:SetAttribute("CrystalTrialBossUnlocked", false)
        player:SetAttribute("CrystalTrialBossWindup", false)
        task.spawn(function()
            while player.Parent and not player:GetAttribute("ProfileLoaded") do task.wait(0.1) end
            if not player.Parent then return end
            local profile, progress = getState(player)
            if profile then publish(player, profile, progress) end
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

return CrystalTrialService
