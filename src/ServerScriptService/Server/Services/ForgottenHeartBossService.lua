local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local ForgottenHeartBossService = {}
local MAX_HEALTH = 360
local HIT_DAMAGE = 30
local HIT_COOLDOWN = 0.8
local ATTACK_COOLDOWN = 4.2
local REWARD_COMPANION_ID = "ForgottenHeartGuardian"
local REWARD_XP = 800
local REWARD_COINS = 1200
local REWARD_STARSHARDS = 5

local ATTACKS = {
    {
        Id = "CrystalSlam",
        Warning = "Хранитель поднимает кристальный кулак! Уклоняйся!",
        Damage = 26,
        Radius = 9,
        Windup = 1.65,
        Pattern = "Target",
    },
    {
        Id = "EchoPulse",
        Warning = "Хранитель собирает эхо Сердца! Отбегай от него!",
        Damage = 22,
        Radius = 21,
        Windup = 1.35,
        Pattern = "Boss",
    },
    {
        Id = "ShardRain",
        Warning = "Кристальный дождь! Не стой на отмеченных местах!",
        Damage = 24,
        Radius = 7,
        Windup = 1.55,
        Pattern = "Triple",
    },
}

local function getState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.ForgottenHeartBossHealth = math.clamp(
        math.floor(tonumber(profile.QuestProgress.ForgottenHeartBossHealth) or MAX_HEALTH),
        0, MAX_HEALTH
    )
    profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
    profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
    profile.Materials.Starshard = math.max(0, math.floor(tonumber(profile.Materials.Starshard) or 0))
    return profile, profile.QuestProgress
end

local function publish(player, profile, progress)
    local completed = profile.CompletedQuests.forgotten_heart_boss == true
    local health = completed and 0 or progress.ForgottenHeartBossHealth
    player:SetAttribute("ForgottenHeartBossHealth", health)
    player:SetAttribute("ForgottenHeartBossPhase", health > 0 and health <= MAX_HEALTH / 2 and 2 or 1)
    player:SetAttribute("ForgottenHeartBossCompleted", completed)
    player:SetAttribute("ForgottenHeartBossUnlocked",
        profile.CompletedQuests.forgotten_cave_cache == true)
end

local function validPlayer(player, target, prompt)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
        if player.Parent then player:SetAttribute("LastNotice", "Хранитель ждёт в Пещере забытого сердца.") end
        return false
    end
    if not ProgressionService:CanEnterZone(player, "AncientHeights") then
        player:SetAttribute("LastNotice", "Сначала открой Древние высоты.")
        return false
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return root ~= nil and humanoid ~= nil and humanoid.Health > 0
        and (root.Position - target.Position).Magnitude <= prompt.MaxActivationDistance + 2
end

local function createWarning(position, radius, color, duration, targetUserId)
    local marker = Instance.new("Part")
    marker.Name = "ForgottenHeartAttackWarning"
    marker:SetAttribute("TargetUserId", targetUserId)
    marker.Shape = Enum.PartType.Cylinder
    marker.Size = Vector3.new(0.22, radius * 2, radius * 2)
    marker.CFrame = CFrame.new(position.X, position.Y + 0.22, position.Z) * CFrame.Angles(0, 0, math.rad(90))
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.Material = Enum.Material.Neon
    marker.Color = color
    marker.Transparency = 0.48
    marker.Parent = Workspace
    local tween = TweenService:Create(marker, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.12,
    })
    tween:Play()
    task.delay(duration + 0.2, function()
        if marker.Parent then marker:Destroy() end
    end)
end

local function grantBossCompanion(player, profile)
    local definition = CompanionCatalog[REWARD_COMPANION_ID]
    assert(definition, "Missing Forgotten Heart boss companion definition")
    profile.Companions = type(profile.Companions) == "table" and profile.Companions or {}
    profile.ActiveCompanions = type(profile.ActiveCompanions) == "table" and profile.ActiveCompanions or {}
    profile.DiscoveredSpecies = type(profile.DiscoveredSpecies) == "table" and profile.DiscoveredSpecies or {}
    profile.DiscoveredBiomes = type(profile.DiscoveredBiomes) == "table" and profile.DiscoveredBiomes or {}

    local owned
    for _, companion in ipairs(profile.Companions) do
        if companion.Id == REWARD_COMPANION_ID then owned = companion break end
    end
    if not owned then
        owned = {
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
            Origin = "ForgottenHeartBoss",
            OriginBiome = "ForgottenCave",
        }
        table.insert(profile.Companions, owned)
    end
    profile.DiscoveredSpecies[REWARD_COMPANION_ID] = true
    profile.DiscoveredBiomes[REWARD_COMPANION_ID] = "Пещера забытого сердца"

    local active = false
    for _, instanceId in ipairs(profile.ActiveCompanions) do
        if instanceId == owned.InstanceId then active = true break end
    end
    if not active and #profile.ActiveCompanions < 3 then
        table.insert(profile.ActiveCompanions, owned.InstanceId)
    end
    player:SetAttribute("CompanionCount", #profile.Companions)
    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
    local ok, err = pcall(function() CompanionService:RefreshPlayer(player) end)
    if not ok then warn("[NEST RAIDERS] Forgotten Heart reward follower refresh failed: " .. tostring(err)) end
end

function ForgottenHeartBossService:Init()
    self._locks = {}
    self._lastHit = {}
    self._lastAttack = {}
    self._attackIndex = {}
    self._windups = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local cave = ancient and ancient:FindFirstChild("ForgottenHeartCave")
    local guardian = cave and cave:FindFirstChild("ForgottenHeartGuardian")
    local core = guardian and guardian:FindFirstChild("ForgottenHeartCore")
    local prompt = core and core:FindFirstChild("ForgottenHeartBossPrompt")
    if not core or not prompt or not prompt:IsA("ProximityPrompt") then
        warn("[NEST RAIDERS] Forgotten Heart Guardian model or prompt is missing.")
        return
    end

    local function runAttack(player, attack, targetPosition, corePosition, phase)
        self._windups[player] = true
        player:SetAttribute("ForgottenHeartBossWindup", true)
        player:SetAttribute("ForgottenHeartBossAttackType", attack.Id)
        player:SetAttribute("LastNotice", attack.Warning)
        local markers = {}
        local floorY = 19.45
        local targetOnFloor = Vector3.new(targetPosition.X, floorY, targetPosition.Z)
        if attack.Pattern == "Boss" then
            table.insert(markers, Vector3.new(corePosition.X, floorY, corePosition.Z))
        elseif attack.Pattern == "Triple" then
            table.insert(markers, targetOnFloor)
            table.insert(markers, targetOnFloor + Vector3.new(8, 0, 0))
            table.insert(markers, targetOnFloor + Vector3.new(-8, 0, 0))
        else
            table.insert(markers, targetOnFloor)
        end
        local warningColor = attack.Id == "CrystalSlam"
            and Color3.fromRGB(105, 222, 255)
            or (attack.Id == "EchoPulse"
                and Color3.fromRGB(183, 139, 255)
                or Color3.fromRGB(255, 145, 207))
        for _, markerPosition in ipairs(markers) do
            createWarning(markerPosition, attack.Radius, warningColor, attack.Windup, player.UserId)
        end
        task.delay(attack.Windup, function()
            self._windups[player] = nil
            if not player.Parent then return end
            player:SetAttribute("ForgottenHeartBossWindup", false)
            player:SetAttribute("ForgottenHeartBossAttackType", "")
            local profile = PlayerDataService:GetProfile(player)
            if profile and profile.CompletedQuests and profile.CompletedQuests.forgotten_heart_boss then return end
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if player:GetAttribute("CurrentBiome") ~= "AncientHeights" or not root or not humanoid or humanoid.Health <= 0 then return end
            local hit = false
            if attack.Pattern == "Boss" then
                hit = (root.Position - corePosition).Magnitude <= attack.Radius
            elseif attack.Pattern == "Triple" then
                for _, markerPosition in ipairs(markers) do
                    if (root.Position - markerPosition).Magnitude <= attack.Radius then hit = true break end
                end
            else
                hit = (root.Position - targetPosition).Magnitude <= attack.Radius
            end
            if hit then
                humanoid:TakeDamage(attack.Damage + (phase == 2 and 5 or 0))
                player:SetAttribute("ForgottenHeartBossDamagePulse", (player:GetAttribute("ForgottenHeartBossDamagePulse") or 0) + 1)
                player:SetAttribute("LastNotice", "Кристальная атака задела тебя! Следи за метками на земле.")
            else
                player:SetAttribute("LastNotice", "Ты уклонился от атаки Хранителя!")
            end
        end)
    end

    prompt.Triggered:Connect(function(player)
        if self._locks[player] then return end
        self._locks[player] = true
        local ok, err = pcall(function()
            if not validPlayer(player, core, prompt) then return end
            local profile, progress = getState(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            publish(player, profile, progress)
            if profile.CompletedQuests.forgotten_heart_boss then
                player:SetAttribute("LastNotice", "Хранитель уже повержен. Его древняя сила теперь с тобой.")
                return
            end
            if profile.CompletedQuests.forgotten_cave_cache ~= true then
                player:SetAttribute("LastNotice", "Сначала реши загадку трёх кристаллов и открой сокровищницу.")
                return
            end
            local now = os.clock()
            if self._windups[player] then return end
            if self._lastHit[player] and now - self._lastHit[player] < HIT_COOLDOWN then return end
            self._lastHit[player] = now
            progress.ForgottenHeartBossHealth = math.max(0, progress.ForgottenHeartBossHealth - HIT_DAMAGE)
            player:SetAttribute("ForgottenHeartBossHitPulse", (player:GetAttribute("ForgottenHeartBossHitPulse") or 0) + 1)
            publish(player, profile, progress)

            if progress.ForgottenHeartBossHealth <= 0 then
                profile.CompletedQuests.forgotten_heart_boss = true
                publish(player, profile, progress)
                self._windups[player] = nil
                player:SetAttribute("ForgottenHeartBossWindup", false)
                player:SetAttribute("ForgottenHeartBossAttackType", "")
                grantBossCompanion(player, profile)
                profile.Materials.Starshard += REWARD_STARSHARDS
                player:SetAttribute("Starshard", profile.Materials.Starshard)
                EconomyService:GrantCoins(player, REWARD_COINS, "Победа над Хранителем забытого сердца")
                ProgressionService:AddXP(player, REWARD_XP)
                player:SetAttribute("ForgottenHeartBossRewardReveal", true)
                player:SetAttribute("LastNotice", "Хранитель повержен! Получен Страж забытого сердца, +1 200 монет, +5 звёздных осколков и +800 опыта!")
                return
            end

            player:SetAttribute("LastNotice", string.format(
                "Удар по Хранителю! Здоровье: %d / %d.", progress.ForgottenHeartBossHealth, MAX_HEALTH))
            if not self._lastAttack[player] or now - self._lastAttack[player] >= ATTACK_COOLDOWN then
                self._lastAttack[player] = now
                local phase = progress.ForgottenHeartBossHealth <= MAX_HEALTH / 2 and 2 or 1
                local available = {}
                for _, attack in ipairs(ATTACKS) do
                    if phase == 2 or attack.Id ~= "ShardRain" then table.insert(available, attack) end
                end
                local index = (self._attackIndex[player] or 0) % #available + 1
                self._attackIndex[player] = index
                local attack = available[index]
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then runAttack(player, attack, root.Position, core.Position, phase) end
            end
        end)
        self._locks[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Forgotten Heart boss interaction failed: " .. tostring(err))
            if player.Parent then player:SetAttribute("LastNotice", "Хранитель не ответил. Попробуй ещё раз.") end
        end
    end)

    local function bindPlayer(player)
        player:SetAttribute("ForgottenHeartBossWindup", false)
        player:SetAttribute("ForgottenHeartBossRewardReveal", false)
        player:SetAttribute("ForgottenHeartBossAttackType", "")
        player:SetAttribute("ForgottenHeartBossPhase", 1)
        local function sync()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            local profile, progress = getState(player)
            if profile then publish(player, profile, progress) end
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(sync)
        player:GetAttributeChangedSignal("ForgottenCaveCacheOpened"):Connect(sync)
        sync()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        self._locks[player] = nil
        self._lastHit[player] = nil
        self._lastAttack[player] = nil
        self._attackIndex[player] = nil
        self._windups[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return ForgottenHeartBossService
