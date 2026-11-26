local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(game:GetService("ReplicatedStorage").Shared.Config.CompanionCatalog)
local PlotService = require(ServerScriptService.Server.Services.PlotService)

local AncientTempleBossService = {}
local BOSS_MAX_HEALTH = 240
local PLAYER_HIT_DAMAGE = 24
local PLAYER_HIT_COOLDOWN = 0.9
local BOSS_ATTACK_COOLDOWN = 4.5
local BOSS_ATTACKS = {
    {
        Id = "VineSlam",
        Warning = "Страж поднимает корни! Отойди от него!",
        Damage = 30,
        Radius = 15,
        WindupSeconds = 1.8,
        Phase = 1,
    },
    {
        Id = "RootWave",
        Warning = "Страж собирает волну корней! Уходи подальше!",
        Damage = 18,
        Radius = 26,
        WindupSeconds = 1.25,
        Phase = 1,
    },
    {
        Id = "ThornBurst",
        Warning = "Страж пробудил шипы! Отойди от него и держись подальше!",
        Damage = 22,
        Radius = 32,
        WindupSeconds = 2,
        Phase = 2,
    },
}
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
    player:SetAttribute("AncientTempleBossPhase",
        progress.AncientTempleBossHealth > 0 and progress.AncientTempleBossHealth <= BOSS_MAX_HEALTH / 2 and 2 or 1)
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

local function grantGuardianTrophy(player, profile)
    profile.Nest = type(profile.Nest) == "table" and profile.Nest or {}
    profile.Nest.IslandTrophies = type(profile.Nest.IslandTrophies) == "table"
        and profile.Nest.IslandTrophies or {}
    if profile.Nest.IslandTrophies.AncientTempleGuardian then return false end

    profile.Nest.IslandTrophies.AncientTempleGuardian = {
        Week = "TempleGuardian",
        Category = "AncientTemple",
        Place = 1,
        ClaimedAt = os.time(),
    }
    local ok, err = pcall(function()
        PlotService:ApplyContestTrophies(player)
    end)
    if not ok then
        warn("[NEST RAIDERS] Guardian trophy was saved but its nest display could not refresh: " .. tostring(err))
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
    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
    local ok, err = pcall(function()
        CompanionService:RefreshPlayer(player)
    end)
    if not ok then
        warn("[NEST RAIDERS] Guardian companion was saved but its follower model could not refresh: " .. tostring(err))
    end
end

function AncientTempleBossService:Init()
    self._lastPlayerHit = {}
    self._lastBossAttack = {}
    self._windups = {}
    self._attackIndex = {}
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

    -- The Guardian is a shared world model, so its physical animation is cosmetic and
    -- never controls per-player health, attack timing, or damage validation.
    local animationBase = {}
    for _, descendant in ipairs(guardian:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant ~= core then
            animationBase[descendant] = {
                CFrame = descendant.CFrame,
                Size = descendant.Size,
            }
        end
    end
    self._animationGeneration = 0
    self._animationTweens = {}

    local function animate(instance, duration, properties, style)
        if not instance or not instance.Parent then return end
        local tween = TweenService:Create(instance, TweenInfo.new(
            duration,
            style or Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ), properties)
        table.insert(self._animationTweens, tween)
        tween:Play()
    end

    local function restoreGuardian(generation, duration)
        if generation ~= self._animationGeneration then return end
        for instance, properties in pairs(animationBase) do
            if instance.Parent then
                local reset = {}
                if properties.CFrame then reset.CFrame = properties.CFrame end
                if properties.Size then reset.Size = properties.Size end
                animate(instance, duration or 0.35, reset)
            end
        end
    end

    local function playGuardianAttackAnimation(attackId)
        self._animationGeneration += 1
        local generation = self._animationGeneration
        for _, tween in ipairs(self._animationTweens) do tween:Cancel() end
        table.clear(self._animationTweens)

        local function part(name)
            return guardian:FindFirstChild(name)
        end
        local function base(name)
            local target = part(name)
            local saved = target and animationBase[target]
            return target, saved and saved.CFrame
        end
        local leftArm, leftArmBase = base("GuardianArm_-1")
        local rightArm, rightArmBase = base("GuardianArm_1")
        local leftBranch, leftBranchBase = base("GuardianBranch_-1")
        local rightBranch, rightBranchBase = base("GuardianBranch_1")
        local body, bodyBase = base("GuardianBody")
        local head, headBase = base("GuardianHead")
        local crown = {}
        for index = 1, 5 do
            local leaf, leafBase = base("GuardianCrownLeaf_" .. index)
            if leaf and leafBase then table.insert(crown, { Part = leaf, CFrame = leafBase, Index = index }) end
        end

        if attackId == "VineSlam" then
            if leftArm and leftArmBase then
                animate(leftArm, 0.5, { CFrame = leftArmBase * CFrame.Angles(math.rad(-58), 0, math.rad(-18)) }, Enum.EasingStyle.Back)
            end
            if rightArm and rightArmBase then
                animate(rightArm, 0.5, { CFrame = rightArmBase * CFrame.Angles(math.rad(-58), 0, math.rad(18)) }, Enum.EasingStyle.Back)
            end
            task.delay(0.55, function()
                if generation ~= self._animationGeneration then return end
                if leftArm and leftArmBase then
                    animate(leftArm, 0.18, { CFrame = leftArmBase * CFrame.Angles(math.rad(52), 0, math.rad(-12)) }, Enum.EasingStyle.Exponential)
                end
                if rightArm and rightArmBase then
                    animate(rightArm, 0.18, { CFrame = rightArmBase * CFrame.Angles(math.rad(52), 0, math.rad(12)) }, Enum.EasingStyle.Exponential)
                end
            end)
            task.delay(1.0, function() restoreGuardian(generation, 0.32) end)
        elseif attackId == "RootWave" then
            if body and bodyBase then
                animate(body, 0.32, { CFrame = bodyBase * CFrame.new(0, -1.2, 0) }, Enum.EasingStyle.Quad)
            end
            if head and headBase then
                animate(head, 0.32, { CFrame = headBase * CFrame.new(0, 1.1, 0) }, Enum.EasingStyle.Back)
            end
            if leftArm and leftArmBase then
                animate(leftArm, 0.3, { CFrame = leftArmBase * CFrame.Angles(0, 0, math.rad(-48)) })
            end
            if rightArm and rightArmBase then
                animate(rightArm, 0.3, { CFrame = rightArmBase * CFrame.Angles(0, 0, math.rad(48)) })
            end
            task.delay(0.55, function() restoreGuardian(generation, 0.48) end)
        elseif attackId == "ThornBurst" then
            if leftArm and leftArmBase then
                animate(leftArm, 0.62, { CFrame = leftArmBase * CFrame.Angles(math.rad(-24), 0, math.rad(-72)) }, Enum.EasingStyle.Back)
            end
            if rightArm and rightArmBase then
                animate(rightArm, 0.62, { CFrame = rightArmBase * CFrame.Angles(math.rad(-24), 0, math.rad(72)) }, Enum.EasingStyle.Back)
            end
            if leftBranch and leftBranchBase then
                animate(leftBranch, 0.62, { CFrame = leftBranchBase * CFrame.Angles(0, 0, math.rad(-42)) })
            end
            if rightBranch and rightBranchBase then
                animate(rightBranch, 0.62, { CFrame = rightBranchBase * CFrame.Angles(0, 0, math.rad(42)) })
            end
            for _, leaf in ipairs(crown) do
                local direction = leaf.Index % 2 == 0 and 1 or -1
                animate(leaf.Part, 0.62, {
                    CFrame = leaf.CFrame * CFrame.Angles(math.rad(direction * 24), 0, math.rad(direction * 18)),
                }, Enum.EasingStyle.Back)
            end
            task.delay(0.82, function() restoreGuardian(generation, 0.58) end)
        end
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

            local gearDamage = math.clamp(tonumber(player:GetAttribute("GearDamageBonus")) or 0, 0, 0.6)
            local dealtDamage = math.max(1, math.floor(PLAYER_HIT_DAMAGE * (1 + gearDamage) + 0.5))
            progress.AncientTempleBossHealth = math.max(0, progress.AncientTempleBossHealth - dealtDamage)
            player:SetAttribute("AncientTempleBossHealth", progress.AncientTempleBossHealth)
            player:SetAttribute("AncientTempleBossPhase",
                progress.AncientTempleBossHealth > 0
                    and progress.AncientTempleBossHealth <= BOSS_MAX_HEALTH / 2 and 2 or 1)
            if progress.AncientTempleBossHealth <= 0 then
                profile.CompletedQuests.ancient_temple_boss = true
                self._windups[player] = nil
                player:SetAttribute("AncientTempleBossWindup", false)
                player:SetAttribute("AncientTempleBossAttackType", "")
                publish(player, profile, progress)
                grantUniqueCompanion(player, profile)
                grantGuardianTrophy(player, profile)
                local _, awardedXP, researchBonus, extraXP = ProgressionService:AddXP(player, REWARD_XP)
                player:SetAttribute("LastNotice",
                    "Страж повержен! " .. ProgressionService:FormatXPReward(awardedXP, researchBonus, extraXP)
                    .. ". Получены Страж Сердцевины и трофей «Сердце Древа» для твоего гнезда!")
                return
            end

            player:SetAttribute("LastNotice", string.format(
                "Удар по Стражу! Здоровье: %d / %d.", progress.AncientTempleBossHealth, BOSS_MAX_HEALTH))
            local lastAttack = self._lastBossAttack[player]
            if (not lastAttack or now - lastAttack >= BOSS_ATTACK_COOLDOWN)
                and not self._windups[player] then
                self._lastBossAttack[player] = now
                local phase = progress.AncientTempleBossHealth <= BOSS_MAX_HEALTH / 2 and 2 or 1
                local availableAttacks = {}
                for _, definition in ipairs(BOSS_ATTACKS) do
                    if definition.Phase <= phase then
                        table.insert(availableAttacks, definition)
                    end
                end
                local attackIndex = (self._attackIndex[player] or 0) % #availableAttacks + 1
                self._attackIndex[player] = attackIndex
                local attack = availableAttacks[attackIndex]
                playGuardianAttackAnimation(attack.Id)
                self._windups[player] = true
                player:SetAttribute("AncientTempleBossWindup", true)
                player:SetAttribute("AncientTempleBossAttackType", attack.Id)
                player:SetAttribute("LastNotice", attack.Warning)
                task.delay(attack.WindupSeconds, function()
                    self._windups[player] = nil
                    if not player.Parent then return end
                    player:SetAttribute("AncientTempleBossWindup", false)
                    player:SetAttribute("AncientTempleBossAttackType", "")
                    local currentProfile = PlayerDataService:GetProfile(player)
                    if currentProfile and currentProfile.CompletedQuests
                        and currentProfile.CompletedQuests.ancient_temple_boss == true then
                        return
                    end
                    local character = player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if player:GetAttribute("CurrentBiome") == "AncientHeights"
                        and root and humanoid and humanoid.Health > 0
                        and (root.Position - core.Position).Magnitude <= attack.Radius then
                        local gearDefense = math.clamp(tonumber(player:GetAttribute("GearDefenseBonus")) or 0, 0, 0.5)
                        humanoid:TakeDamage(math.max(1, math.floor(attack.Damage * (1 - gearDefense) + 0.5)))
                        player:SetAttribute("LastNotice", attack.Id == "VineSlam"
                            and "Корни обрушились на тебя! В следующий раз уклонись от тяжёлого удара."
                            or (attack.Id == "ThornBurst"
                                and "Шипы Древа пронзили арену! Отходи дальше во время предупреждения."
                                or "Волна корней настигла тебя! Уходи за пределы арены во время подготовки."))
                    elseif player.Parent then
                        player:SetAttribute("LastNotice", "Ты уклонился от атаки Стража!")
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
        player:SetAttribute("AncientTempleBossAttackType", "")
        player:SetAttribute("AncientTempleBossPhase", 1)
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
        self._attackIndex[player] = nil
        self._locks[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return AncientTempleBossService
