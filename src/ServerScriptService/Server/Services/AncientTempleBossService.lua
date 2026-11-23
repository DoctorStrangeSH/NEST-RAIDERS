local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(game:GetService("ReplicatedStorage").Shared.Config.CompanionCatalog)

local AncientTempleBossService = {}
local BOSS_MAX_HEALTH = 240
local PLAYER_HIT_DAMAGE = 24
local BOSS_DAMAGE = 25
local PLAYER_HIT_COOLDOWN = 0.9
local BOSS_ATTACK_COOLDOWN = 4.5
local BOSS_WINDUP_SECONDS = 1.5
local BOSS_ATTACK_RADIUS = 19
local REWARD_XP = 600
local REWARD_COMPANION_ID = "HeartwoodGuardian"

local function getState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.AncientTempleRunes =
        type(profile.QuestProgress.AncientTempleRunes) == "table"
        and profile.QuestProgress.AncientTempleRunes or {}
    profile.QuestProgress.AncientTempleBossHealth = math.clamp(
        math.floor(tonumber(profile.QuestProgress.AncientTempleBossHealth) or BOSS_MAX_HEALTH),
        0, BOSS_MAX_HEALTH)
    profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
    return profile, profile.QuestProgress
end

local function sequenceCount(sequence)
    local expected = { "Root", "River", "Dawn" }
    local count = 0
    for index, runeId in ipairs(expected) do
        if sequence[index] ~= runeId then break end
        count += 1
    end
    return count
end

local function publish(player, profile, progress)
    player:SetAttribute("AncientTempleProgress", sequenceCount(progress.AncientTempleRunes))
    player:SetAttribute("AncientTempleBossHealth", progress.AncientTempleBossHealth)
    player:SetAttribute("AncientTempleCompleted",
        profile.CompletedQuests.ancient_temple_trial == true)
    player:SetAttribute("AncientTempleBossCompleted",
        profile.CompletedQuests.ancient_temple_boss == true)
end

local function validateAt(player, target, distance)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
        if player.Parent then
            player:SetAttribute("LastNotice", "Страж находится только в Храме Древнего древа.")
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

local function grantUniqueCompanion(player, profile)
    local definition = CompanionCatalog[REWARD_COMPANION_ID]
    if not definition then
        error("Missing boss-exclusive companion definition: " .. REWARD_COMPANION_ID)
    end
    profile.Companions = type(profile.Companions) == "table" and profile.Companions or {}
    profile.ActiveCompanions = type(profile.ActiveCompanions) == "table" and profile.ActiveCompanions or {}
    profile.DiscoveredSpecies = type(profile.DiscoveredSpecies) == "table" and profile.DiscoveredSpecies or {}
    profile.DiscoveredBiomes = type(profile.DiscoveredBiomes) == "table" and profile.DiscoveredBiomes or {}

    local alreadyOwned = false
    for _, companion in ipairs(profile.Companions) do
        if companion.Id == REWARD_COMPANION_ID then
            alreadyOwned = true
            break
        end
    end
    if not alreadyOwned then
        table.insert(profile.Companions, {
            InstanceId = HttpService:GenerateGUID(false),
            Id = definition.Id,
            Name = definition.Name,
            Rarity = definition.Rarity,
            Income = definition.Income,
            Level = 1,
            GrowthXP = 0,
            Stars = 1,
            GeneticTrait = { Id = "Natural", Name = "Естественный", Rarity = "Обычный", IncomeBonus = 0 },
            HatchedAt = os.time(),
            Origin = "TempleBoss",
            OriginBiome = "AncientHeights",
        })
    end
    profile.DiscoveredSpecies[REWARD_COMPANION_ID] = true
    profile.DiscoveredBiomes[REWARD_COMPANION_ID] = "Храм Древнего древа"

    local active = false
    for _, instanceId in ipairs(profile.ActiveCompanions) do
        for _, companion in ipairs(profile.Companions) do
            if companion.InstanceId == instanceId and companion.Id == REWARD_COMPANION_ID then
                active = true
                break
            end
        end
        if active then break end
    end
    if not active and #profile.ActiveCompanions < 3 then
        for _, companion in ipairs(profile.Companions) do
            if companion.Id == REWARD_COMPANION_ID then
                table.insert(profile.ActiveCompanions, companion.InstanceId)
                break
            end
        end
    end
    player:SetAttribute("CompanionCount", #profile.Companions)
    CompanionService:RefreshPlayer(player)
end

function AncientTempleBossService:Init()
    self._lastPlayerHit = {}
    self._lastBossAttack = {}
    self._windups = {}
    self._locks = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local temple = ancient and ancient:FindFirstChild("AncientTreeTemple")
    local guardian = temple and temple:FindFirstChild("AncientTempleGuardian")
    local core = guardian and guardian:FindFirstChild("GuardianHeartCore")
    local prompt = core and core:FindFirstChild("AncientTempleBossPrompt")
    if not core or not prompt or not prompt:IsA("ProximityPrompt") then
        warn("[NEST RAIDERS] Ancient Temple Guardian boss model or prompt is missing.")
        return
    end

    prompt.Triggered:Connect(function(player)
        if self._locks[player] then return end
        self._locks[player] = true
        local ok, err = pcall(function()
            local valid = validateAt(player, core, prompt.MaxActivationDistance)
            if not valid then return end
            local profile, progress = getState(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            publish(player, profile, progress)
            if profile.CompletedQuests.ancient_temple_boss == true then
                player:SetAttribute("LastNotice", "Страж уже признал твою силу. Его питомец ждёт в коллекции.")
                return
            end
            if profile.CompletedQuests.ancient_temple_trial ~= true
                or sequenceCount(progress.AncientTempleRunes) < 3 then
                player:SetAttribute("LastNotice", "Сначала пробуди руны храма: Корни → Река → Рассвет.")
                return
            end

            local now = os.clock()
            local lastHit = self._lastPlayerHit[player]
            if lastHit and now - lastHit < PLAYER_HIT_COOLDOWN then return end
            self._lastPlayerHit[player] = now

            progress.AncientTempleBossHealth = math.max(
                0, progress.AncientTempleBossHealth - PLAYER_HIT_DAMAGE)
            player:SetAttribute("AncientTempleBossHealth", progress.AncientTempleBossHealth)
            if progress.AncientTempleBossHealth <= 0 then
                profile.CompletedQuests.ancient_temple_boss = true
                self._windups[player] = nil
                player:SetAttribute("AncientTempleBossWindup", false)
                publish(player, profile, progress)
                grantUniqueCompanion(player, profile)
                ProgressionService:AddXP(player, REWARD_XP)
                player:SetAttribute("LastNotice",
                    "Страж повержен! +600 опыта. Получен уникальный питомец: Страж Сердцевины!")
                return
            end

            player:SetAttribute("LastNotice", string.format(
                "Удар по Стражу! Здоровье: %d / %d.", progress.AncientTempleBossHealth, BOSS_MAX_HEALTH))
            local lastAttack = self._lastBossAttack[player]
            if (not lastAttack or now - lastAttack >= BOSS_ATTACK_COOLDOWN)
                and not self._windups[player] then
                self._lastBossAttack[player] = now
                self._windups[player] = true
                player:SetAttribute("AncientTempleBossWindup", true)
                player:SetAttribute("LastNotice", "Страж собирает силу корней! Отойди от него!")
                task.delay(BOSS_WINDUP_SECONDS, function()
                    self._windups[player] = nil
                    if not player.Parent then return end
                    player:SetAttribute("AncientTempleBossWindup", false)
                    local character = player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if player:GetAttribute("CurrentBiome") == "AncientHeights"
                        and root and humanoid and humanoid.Health > 0
                        and (root.Position - core.Position).Magnitude <= BOSS_ATTACK_RADIUS then
                        humanoid:TakeDamage(BOSS_DAMAGE)
                        player:SetAttribute("LastNotice",
                            "Удар корней настиг тебя! Отходи во время предупреждения.")
                    elseif player.Parent then
                        player:SetAttribute("LastNotice", "Ты уклонился от удара Стража!")
                    end
                end)
            end
        end)
        self._locks[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Ancient Temple Guardian interaction failed: " .. tostring(err))
            if player.Parent then
                player:SetAttribute("LastNotice", "Страж не ответил. Попробуй ещё раз.")
            end
        end
    end)

    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true
        player:SetAttribute("AncientTempleBossWindup", false)
        local function sync()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            local profile, progress = getState(player)
            if profile then publish(player, profile, progress) end
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(sync)
        sync()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        boundPlayers[player] = nil
        self._lastPlayerHit[player] = nil
        self._lastBossAttack[player] = nil
        self._windups[player] = nil
        self._locks[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return AncientTempleBossService
