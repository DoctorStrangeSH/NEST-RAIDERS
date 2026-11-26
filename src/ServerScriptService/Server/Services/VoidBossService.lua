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

local VoidBossService = {}
local MAX_HEALTH = 540
local HIT_DAMAGE = 36
local HIT_COOLDOWN = 0.85
local ATTACK_COOLDOWN = 3.8
local REWARD_COMPANION_ID = "StarEater"
local REWARD_XP = 1200
local REWARD_COINS = 1800
local REWARD_STARSHARDS = 12

local ATTACKS = {
    {
        Id = "RiftSlam",
        Warning = "ПОЖИРАТЕЛЬ ЗВЁЗД ПОДНИМАЕТ КУЛАК! УХОДИ С ФИОЛЕТОВОЙ МЕТКИ!",
        Damage = 28,
        Radius = 10,
        Windup = 1.65,
        Pattern = "Target",
        Phase = 1,
        Color = Color3.fromRGB(190, 115, 255),
    },
    {
        Id = "VoidPulse",
        Warning = "ПУСТОТНАЯ ВОЛНА! ОТОЙДИ ОТ БОССА!",
        Damage = 24,
        Radius = 22,
        Windup = 1.45,
        Pattern = "Boss",
        Phase = 1,
        Color = Color3.fromRGB(128, 113, 255),
    },
    {
        Id = "Starfall",
        Warning = "ЗВЁЗДНЫЙ ДОЖДЬ! ПОКИНЬ ВСЕ ОТМЕЧЕННЫЕ ЗОНЫ!",
        Damage = 22,
        Radius = 7,
        Windup = 1.8,
        Pattern = "Triple",
        Phase = 2,
        Color = Color3.fromRGB(255, 199, 132),
    },
    {
        Id = "Collapse",
        Warning = "КОЛЛАПС ПУСТОТЫ! БЕГИ К КРАЮ АРЕНЫ!",
        Damage = 34,
        Radius = 28,
        Windup = 2.0,
        Pattern = "Boss",
        Phase = 3,
        Color = Color3.fromRGB(255, 106, 157),
    },
}

local function getState(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return nil end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.VoidBossHealth = math.clamp(
        math.floor(tonumber(profile.QuestProgress.VoidBossHealth) or MAX_HEALTH), 0, MAX_HEALTH)
    profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
    profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
    profile.Materials.Starshard = math.max(0, math.floor(tonumber(profile.Materials.Starshard) or 0))
    return profile, profile.QuestProgress
end

local function phaseFor(health)
    local ratio = health / MAX_HEALTH
    return ratio <= 0.3 and 3 or (ratio <= 0.65 and 2 or 1)
end

local function publish(player, profile, progress)
    local completed = profile.CompletedQuests.void_boss == true
    local health = completed and 0 or progress.VoidBossHealth
    player:SetAttribute("VoidBossHealth", health)
    player:SetAttribute("VoidBossPhase", completed and 3 or phaseFor(health))
    player:SetAttribute("VoidBossCompleted", completed)
    player:SetAttribute("VoidBossUnlocked", profile.CompletedQuests.void_trial == true)
end

local function validPlayer(player, target, prompt)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "VoidFrontier" then
        if player.Parent then player:SetAttribute("LastNotice", "Пожиратель звёзд ждёт на Границе пустоты.") end
        return false
    end
    if not ProgressionService:CanEnterZone(player, "VoidFrontier") then
        player:SetAttribute("LastNotice", "Сначала открой Границу пустоты.")
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
    marker.Name = "VoidBossAttackWarning"
    marker:SetAttribute("TargetUserId", targetUserId)
    marker.Shape = Enum.PartType.Cylinder
    marker.Size = Vector3.new(0.22, radius * 2, radius * 2)
    marker.CFrame = CFrame.new(position.X, 20.35, position.Z) * CFrame.Angles(0, 0, math.rad(90))
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.Material = Enum.Material.Neon
    marker.Color = color
    marker.Transparency = 0.5
    marker.Parent = Workspace
    TweenService:Create(marker, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.12,
    }):Play()
    task.delay(duration + 0.25, function()
        if marker.Parent then marker:Destroy() end
    end)
end

local function grantBossCompanion(player, profile)
    local definition = CompanionCatalog[REWARD_COMPANION_ID]
    assert(definition, "Missing Void boss companion definition")
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
            Origin = "VoidBoss",
            OriginBiome = "VoidFrontier",
        }
        table.insert(profile.Companions, owned)
    end
    profile.DiscoveredSpecies[REWARD_COMPANION_ID] = true
    profile.DiscoveredBiomes[REWARD_COMPANION_ID] = "Граница пустоты"
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
    if not ok then warn("[NEST RAIDERS] Void boss reward follower refresh failed: " .. tostring(err)) end
end

function VoidBossService:Init()
    self._locks = {}
    self._lastHit = {}
    self._lastAttack = {}
    self._attackIndex = {}
    self._windups = {}

    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local void = world and world:FindFirstChild("VoidFrontier")
    local arena = void and void:FindFirstChild("VoidBossArena")
    local boss = arena and arena:FindFirstChild("StarEater")
    local core = boss and boss:FindFirstChild("StarEaterCore")
    local prompt = core and core:FindFirstChild("VoidBossPrompt")
    if not core or not prompt or not prompt:IsA("ProximityPrompt") then
        warn("[NEST RAIDERS] Star Eater boss model or prompt is missing.")
        return
    end

    local function runAttack(player, attack, targetPosition, corePosition, phase)
        self._windups[player] = true
        player:SetAttribute("VoidBossWindup", true)
        player:SetAttribute("VoidBossAttackType", attack.Id)
        player:SetAttribute("LastNotice", attack.Warning)
        local markers = {}
        local floorY = 21.75
        local targetOnFloor = Vector3.new(targetPosition.X, floorY, targetPosition.Z)
        if attack.Pattern == "Boss" then
            markers[1] = Vector3.new(corePosition.X, floorY, corePosition.Z)
        elseif attack.Pattern == "Triple" then
            markers[1] = targetOnFloor
            markers[2] = targetOnFloor + Vector3.new(9, 0, 0)
            markers[3] = targetOnFloor + Vector3.new(-9, 0, 0)
        else
            markers[1] = targetOnFloor
        end
        for _, markerPosition in ipairs(markers) do
            createWarning(markerPosition, attack.Radius, attack.Color, attack.Windup, player.UserId)
        end
        task.delay(attack.Windup, function()
            self._windups[player] = nil
            if not player.Parent then return end
            player:SetAttribute("VoidBossWindup", false)
            player:SetAttribute("VoidBossAttackType", "")
            local currentProfile = PlayerDataService:GetProfile(player)
            if currentProfile and currentProfile.CompletedQuests and currentProfile.CompletedQuests.void_boss == true then return end
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if player:GetAttribute("CurrentBiome") ~= "VoidFrontier" or not root or not humanoid or humanoid.Health <= 0 then return end
            local hit = false
            if attack.Pattern == "Triple" then
                for _, markerPosition in ipairs(markers) do
                    if (root.Position - markerPosition).Magnitude <= attack.Radius then hit = true break end
                end
            elseif attack.Pattern == "Boss" then
                hit = (root.Position - corePosition).Magnitude <= attack.Radius
            else
                hit = (root.Position - targetPosition).Magnitude <= attack.Radius
            end
            if hit then
                local gearDefense = math.clamp(tonumber(player:GetAttribute("GearDefenseBonus")) or 0, 0, 0.5)
                local incomingDamage = attack.Damage + (phase == 3 and 8 or 0)
                humanoid:TakeDamage(math.max(1, math.floor(incomingDamage * (1 - gearDefense) + 0.5)))
                player:SetAttribute("VoidBossDamagePulse", (player:GetAttribute("VoidBossDamagePulse") or 0) + 1)
                player:SetAttribute("LastNotice", "Атака Пожирателя звёзд задела тебя! Следи за метками.")
            else
                player:SetAttribute("LastNotice", "Ты уклонился от атаки Пожирателя звёзд!")
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
            if profile.CompletedQuests.void_boss == true then
                player:SetAttribute("LastNotice", "Пожиратель звёзд повержен. Его свет теперь с тобой.")
                return
            end
            if profile.CompletedQuests.void_trial ~= true then
                player:SetAttribute("LastNotice", "Сначала заверши Испытание пустоты и пробуди три руны.")
                return
            end
            local now = os.clock()
            if self._windups[player] then return end
            if self._lastHit[player] and now - self._lastHit[player] < HIT_COOLDOWN then return end
            self._lastHit[player] = now
            local gearDamage = math.clamp(tonumber(player:GetAttribute("GearDamageBonus")) or 0, 0, 0.6)
            local dealtDamage = math.max(1, math.floor(HIT_DAMAGE * (1 + gearDamage) + 0.5))
            progress.VoidBossHealth = math.max(0, progress.VoidBossHealth - dealtDamage)
            player:SetAttribute("VoidBossHitPulse", (player:GetAttribute("VoidBossHitPulse") or 0) + 1)
            publish(player, profile, progress)
            if progress.VoidBossHealth <= 0 then
                profile.CompletedQuests.void_boss = true
                self._windups[player] = nil
                player:SetAttribute("VoidBossWindup", false)
                player:SetAttribute("VoidBossAttackType", "")
                publish(player, profile, progress)
                grantBossCompanion(player, profile)
                profile.Materials.Starshard += REWARD_STARSHARDS
                player:SetAttribute("Starshard", profile.Materials.Starshard)
                EconomyService:GrantCoins(player, REWARD_COINS, "Победа над Пожирателем звёзд")
                local _, awardedXP, researchBonus, extraXP = ProgressionService:AddXP(player, REWARD_XP)
                player:SetAttribute("VoidBossRewardReveal", true)
                player:SetAttribute("LastNotice", "Пожиратель звёзд повержен! Получен уникальный питомец, +1 800 монет, "
                    .. "+12 звёздных осколков и " .. ProgressionService:FormatXPReward(awardedXP, researchBonus, extraXP) .. "!")
                return
            end
            player:SetAttribute("LastNotice", string.format(
                "Удар по Пожирателю звёзд! Здоровье: %d / %d.", progress.VoidBossHealth, MAX_HEALTH))
            if not self._lastAttack[player] or now - self._lastAttack[player] >= ATTACK_COOLDOWN then
                self._lastAttack[player] = now
                local phase = phaseFor(progress.VoidBossHealth)
                local available = {}
                for _, attack in ipairs(ATTACKS) do
                    if attack.Phase <= phase then table.insert(available, attack) end
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
            warn("[NEST RAIDERS] Star Eater interaction failed: " .. tostring(err))
            if player.Parent then player:SetAttribute("LastNotice", "Пожиратель звёзд не ответил. Попробуй ещё раз.") end
        end
    end)

    local function bindPlayer(player)
        player:SetAttribute("VoidBossWindup", false)
        player:SetAttribute("VoidBossRewardReveal", false)
        player:SetAttribute("VoidBossAttackType", "")
        player:SetAttribute("VoidBossPhase", 1)
        local function sync()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            local profile, progress = getState(player)
            if profile then publish(player, profile, progress) end
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(sync)
        player:GetAttributeChangedSignal("VoidTrialCompleted"):Connect(sync)
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

return VoidBossService
