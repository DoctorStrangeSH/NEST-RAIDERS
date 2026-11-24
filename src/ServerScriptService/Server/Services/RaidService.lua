local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local IslandVisitService = require(ServerScriptService.Server.Services.IslandVisitService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local NestBuildCatalog = require(ReplicatedStorage.Shared.Config.NestBuildCatalog)

local RaidService = {}
RaidService._joinedAt = {}
RaidService._studioRaidLevelOverride = {}
RaidService._lastRequest = {}
RaidService._lastChallengeAt = {}
RaidService._pendingByTarget = {}
RaidService._pendingByAttacker = {}
RaidService._matches = {}
RaidService._pendingReturns = {}
RaidService._arenaCounter = 0

local OPT_IN_WINDOW_SECONDS = 10 * 60
local CHALLENGE_TIMEOUT_SECONDS = 45
local MATCH_READY_TIMEOUT_SECONDS = 120
local RAID_DURATION_SECONDS = 150
local RAID_CORE_MAX_HEALTH = 100
local RAID_CORE_HIT_DAMAGE = 20
local RAID_ATTACK_COOLDOWN_SECONDS = 2.2
local RAID_REPAIR_AMOUNT = 10
local RAID_REPAIR_COOLDOWN_SECONDS = 8
local RAID_DUEL_STRIKE_DAMAGE = 24
local RAID_DUEL_STRIKE_COOLDOWN_SECONDS = 1.15
local RAID_DUEL_STRIKE_RANGE = 12
local RAID_PARRY_WINDOW_SECONDS = 0.9
local RAID_PARRY_COOLDOWN_SECONDS = 3.2
local RAID_PARRY_COUNTER_DAMAGE = 18
local RAID_DEFENSE_STRIKE_DAMAGE = 35
local RAID_DEFENSE_STRIKE_COOLDOWN_SECONDS = 1.15
local RAID_DEFENSE_REPAIR_AMOUNT = 30
local RAID_DEFENSE_REPAIR_COOLDOWN_SECONDS = 8
local MAX_ARENA_DEFENSES = 12
local RAID_REWARD_COOLDOWN_SECONDS = 10 * 60
local RAID_WIN_COINS = 150
local RAID_WIN_XP = 100
local RAID_PARTICIPATION_COINS = 50
local CHALLENGE_COOLDOWN_SECONDS = 30
local REQUEST_COOLDOWN_SECONDS = 0.25
local MAX_TARGETS = 20

local MINIMUM_LEVEL = 5
local NEWCOMER_PROTECTION_SECONDS = 15 * 60

local function now()
    return os.time()
end

local function getLevel(player)
    if RaidService._studioRaidLevelOverride[player] then return MINIMUM_LEVEL end
    return math.clamp(math.floor(tonumber(player:GetAttribute("Level")) or 1), 1, 100)
end

local function isWindowOpen(player, attribute)
    local expiresAt = tonumber(player:GetAttribute(attribute)) or 0
    return expiresAt > now(), math.max(0, expiresAt - now())
end

local function getRaidPetSynergy(followers)
    local roles = {}
    for _, follower in ipairs(followers or {}) do
        if follower.Role == "HUNTER" or follower.Role == "HEALER" or follower.Role == "GUARDIAN" then
            roles[follower.Role] = true
        end
    end

    local roleCount = (roles.HUNTER and 1 or 0) + (roles.HEALER and 1 or 0) + (roles.GUARDIAN and 1 or 0)
    if roleCount < 2 then return nil end

    if roleCount == 3 then
        return {
            Id = "TRIAD",
            Name = "Триада",
            Description = "+10% силы навыка · −8% входящего урона · +5% ударов",
            AbilityPowerMultiplier = 1.10,
            DamageReduction = 0.08,
            DuelDamageMultiplier = 1.05,
        }
    end

    if roles.GUARDIAN and roles.HEALER then
        return {
            Id = "LIVING_BASTION",
            Name = "Живой бастион",
            Description = "−12% входящего урона · +15% силы навыка",
            AbilityPowerMultiplier = 1.15,
            BoostRoles = { GUARDIAN = true, HEALER = true },
            DamageReduction = 0.12,
        }
    end

    if roles.HUNTER and roles.GUARDIAN then
        return {
            Id = "ASSAULT_FORMATION",
            Name = "Штурмовой строй",
            Description = "+15% навыка охотника · +10% ударов",
            AbilityPowerMultiplier = 1.15,
            BoostRoles = { HUNTER = true },
            DuelDamageMultiplier = 1.10,
        }
    end

    if roles.HUNTER and roles.HEALER then
        return {
            Id = "COORDINATED_ASSAULT",
            Name = "Согласованный натиск",
            Description = "+15% урона охотника и лечения",
            AbilityPowerMultiplier = 1.15,
            BoostRoles = { HUNTER = true, HEALER = true },
        }
    end

    return nil
end

local function getRaidPetProgression(pet, synergy)
    local companion = pet and pet.Companion
    local level = math.clamp(math.floor(tonumber(companion and companion.Level) or 1), 1, 10)
    local steps = math.floor((level - 1) / 2)
    local ability = pet and pet.Ability
    if not ability then return level, 0, "" end

    local role = ability.Role
    local power = 0
    local maximum = 0
    local label = ""
    if role == "HUNTER" then
        power = math.floor(tonumber(ability.Damage) or 14) + steps
        maximum = 30
    elseif role == "HEALER" then
        power = math.floor(tonumber(ability.HealAmount) or 20) + steps
        maximum = 35
    elseif role == "GUARDIAN" then
        local shieldBonus = math.floor((level - 1) * 2 / 3)
        power = math.floor(tonumber(ability.ShieldAmount) or 20) + shieldBonus
        maximum = 40
    end

    if synergy and synergy.AbilityPowerMultiplier
        and (not synergy.BoostRoles or synergy.BoostRoles[role]) then
        power = math.floor(power * synergy.AbilityPowerMultiplier + 0.5)
    end

    if role == "HUNTER" then
        power = math.clamp(power, 8, maximum)
        label = "УРОН " .. tostring(power)
    elseif role == "HEALER" then
        power = math.clamp(power, 5, maximum)
        label = "ЛЕЧЕНИЕ +" .. tostring(power)
    elseif role == "GUARDIAN" then
        power = math.clamp(power, 10, maximum)
        label = "ЩИТ " .. tostring(power)
    end
    return level, power, label
end

local function makeArenaPart(parent, name, size, position, color, material, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    if shape then part.Shape = shape end
    part.Parent = parent
    return part
end

local function buildArena(self, match)
    local folder = Workspace:FindFirstChild("NestRaidersRaidArenas")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "NestRaidersRaidArenas"
        folder.Parent = Workspace
    end

    self._arenaCounter += 1
    local slot = (self._arenaCounter - 1) % 3
    local center = Vector3.new((slot - 1) * 150, 260, 0)
    local model = Instance.new("Model")
    model.Name = "RaidArena_" .. match.Id
    model:SetAttribute("RaidMatchId", match.Id)
    model.Parent = folder

    makeArenaPart(model, "ArenaFloor", Vector3.new(100, 2, 80), center, Color3.fromRGB(72, 91, 83), Enum.Material.Slate)
    makeArenaPart(model, "ArenaBorderNorth", Vector3.new(100, 14, 2), center + Vector3.new(0, 8, -39), Color3.fromRGB(44, 59, 68), Enum.Material.Basalt)
    makeArenaPart(model, "ArenaBorderSouth", Vector3.new(100, 14, 2), center + Vector3.new(0, 8, 39), Color3.fromRGB(44, 59, 68), Enum.Material.Basalt)
    makeArenaPart(model, "ArenaBorderWest", Vector3.new(2, 14, 80), center + Vector3.new(-49, 8, 0), Color3.fromRGB(44, 59, 68), Enum.Material.Basalt)
    makeArenaPart(model, "ArenaBorderEast", Vector3.new(2, 14, 80), center + Vector3.new(49, 8, 0), Color3.fromRGB(44, 59, 68), Enum.Material.Basalt)

    for index, offset in ipairs({
        Vector3.new(-42, 5, -31), Vector3.new(42, 5, -31),
        Vector3.new(-42, 5, 31), Vector3.new(42, 5, 31),
    }) do
        local pillar = makeArenaPart(model, "ArenaBeacon_" .. index, Vector3.new(3, 10, 3),
            center + offset, Color3.fromRGB(105, 177, 151), Enum.Material.Neon)
        pillar.CanCollide = false
    end

    makeArenaPart(model, "CorePedestal", Vector3.new(16, 2, 16),
        center + Vector3.new(0, 2, 0), Color3.fromRGB(111, 86, 66), Enum.Material.Slate)
    local core = makeArenaPart(model, "RaidCore", Vector3.new(8, 8, 8),
        center + Vector3.new(0, 10, 0), Color3.fromRGB(255, 183, 92), Enum.Material.Neon, Enum.PartType.Ball)
    core.CanCollide = false
    core.CanTouch = false
    core.CanQuery = false
    local light = Instance.new("PointLight")
    light.Color = core.Color
    light.Brightness = 2
    light.Range = 24
    light.Parent = core

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CoreHealthBillboard"
    billboard.Size = UDim2.fromOffset(230, 54)
    billboard.StudsOffset = Vector3.new(0, 6, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = core
    local label = Instance.new("TextLabel")
    label.Name = "HealthText"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(28, 38, 42)
    label.BackgroundTransparency = 0.12
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.fromRGB(255, 236, 194)
    label.TextScaled = true
    label.Text = "ЯДРО ГНЕЗДА · 100 / 100"
    label.Parent = billboard
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label

    local defenseFolder = Instance.new("Folder")
    defenseFolder.Name = "NestDefenses"
    defenseFolder.Parent = model

    match.ArenaModel = model
    match.DefenseFolder = defenseFolder
    match.CorePart = core
    match.CoreLabel = label
    match.CorePosition = core.Position
    match.ArenaCenter = center
    return model
end

local function makeDefensePart(parent, name, size, cframe, color, material, canCollide, canTouch)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = canCollide == true
    part.CanTouch = canTouch == true
    part.CanQuery = false
    part.Color = color
    part.Material = material or Enum.Material.Slate
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function updateDefenseLabel(defense)
    if defense.HealthLabel and defense.HealthLabel.Parent then
        defense.HealthLabel.Text = string.format("%s · %d / %d",
            defense.Name, math.max(0, defense.Health), defense.MaxHealth)
    end
end

local function buildArenaDefenses(match, profile)
    match.Defenses = {}
    match.DefenseConnections = {}
    local nest = type(profile) == "table" and type(profile.Nest) == "table" and profile.Nest or nil
    local placed = nest and type(nest.PlacedBuildings) == "table" and nest.PlacedBuildings or {}
    local entries = {}
    for key, item in pairs(placed) do
        local def = type(item) == "table" and NestBuildCatalog[item.Id] or nil
        if def and def.DefenseType then
            table.insert(entries, { Key = tostring(key), Item = item, Definition = def })
        end
    end
    table.sort(entries, function(a, b) return a.Key < b.Key end)

    for index, entry in ipairs(entries) do
        if index > MAX_ARENA_DEFENSES then break end
        local item, def = entry.Item, entry.Definition
        local x = 12 + math.clamp(tonumber(item.X) or 0, -14, 14) * 0.65
        local z = math.clamp(tonumber(item.Z) or 0, -14, 14) * 1.1
        local rotation = math.rad(math.floor((tonumber(item.Rotation) or 0) / 15 + 0.5) * 15)
        local base = CFrame.new(match.ArenaCenter + Vector3.new(x, 1, z)) * CFrame.Angles(0, rotation, 0)
        local model = Instance.new("Model")
        model.Name = "NestDefense_" .. def.DefenseType .. "_" .. entry.Key
        model:SetAttribute("DefenseKey", entry.Key)
        model:SetAttribute("DefenseType", def.DefenseType)
        model.Parent = match.DefenseFolder

        local record = {
            Key = entry.Key,
            Type = def.DefenseType,
            Name = def.Name,
            Model = model,
            Health = def.DefenseHealth or 80,
            MaxHealth = def.DefenseHealth or 80,
            Damage = def.DefenseDamage or 0,
            Range = def.DefenseRange or 0,
            Interval = def.DefenseInterval or 0,
            Cooldown = def.DefenseCooldown or 0,
            Position = base.Position,
            LastTriggeredAt = nil,
        }

        if def.DefenseType == "Wall" then
            makeDefensePart(model, "BastionFoot", Vector3.new(2.2, 0.6, 8), base * CFrame.new(0, 0.3, 0),
                def.Accent, Enum.Material.Slate, false, false)
            local barrier = makeDefensePart(model, "BastionBarrier", Vector3.new(1.45, 5.2, 7.2),
                base * CFrame.new(0, 2.9, 0), def.Color, Enum.Material.Cobblestone, true, false)
            record.Barrier = barrier
            makeDefensePart(model, "BastionCrown", Vector3.new(2, 0.45, 8.2),
                base * CFrame.new(0, 5.55, 0), def.Accent, Enum.Material.Slate, false, false)
            for _, offset in ipairs({-2.7, 0, 2.7}) do
                makeDefensePart(model, "BastionMerlon", Vector3.new(1.8, 0.75, 1.1),
                    base * CFrame.new(0, 6.1, offset), def.Color, Enum.Material.Cobblestone, false, false)
            end
        elseif def.DefenseType == "Turret" then
            makeDefensePart(model, "TowerBase", Vector3.new(5, 0.7, 5), base * CFrame.new(0, 0.35, 0),
                def.Accent, Enum.Material.Slate, false, false)
            makeDefensePart(model, "TowerStem", Vector3.new(2.4, 5.2, 2.4), base * CFrame.new(0, 3, 0),
                def.Color, Enum.Material.WoodPlanks, false, false)
            makeDefensePart(model, "TowerDeck", Vector3.new(5.8, 0.6, 5.8), base * CFrame.new(0, 5.8, 0),
                def.Accent, Enum.Material.Wood, false, false)
            makeDefensePart(model, "TurretHead", Vector3.new(3.2, 2.1, 3.2), base * CFrame.new(0, 7.1, 0),
                def.Color, Enum.Material.WoodPlanks, false, false)
            record.Muzzle = makeDefensePart(model, "TurretMuzzle", Vector3.new(0.7, 0.7, 2.2),
                base * CFrame.new(-1.7, 7.1, 0), def.Accent, Enum.Material.Neon, false, false)
            local light = Instance.new("PointLight")
            light.Color = def.Accent
            light.Brightness = 1.2
            light.Range = 15
            light.Parent = record.Muzzle
        elseif def.DefenseType == "Trap" then
            makeDefensePart(model, "TrapPlate", Vector3.new(4.2, 0.25, 4.2), base * CFrame.new(0, 0.15, 0),
                def.Color, Enum.Material.Slate, false, false)
            for tx = -1, 1 do
                for tz = -1, 1 do
                    makeDefensePart(model, "Thorn", Vector3.new(0.45, 1.05, 0.45),
                        base * CFrame.new(tx * 1.05, 0.75, tz * 1.05), def.Accent, Enum.Material.Metal, false, false)
                end
            end
            local trigger = makeDefensePart(model, "TrapTrigger", Vector3.new(4, 2, 4),
                base * CFrame.new(0, 1, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, false, true)
            trigger.Transparency = 1
            record.Trigger = trigger
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DefenseHealthBillboard"
        billboard.Size = UDim2.fromOffset(190, 38)
        billboard.StudsOffset = Vector3.new(0, def.Height + 1.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = model.PrimaryPart or record.Muzzle or model:FindFirstChildWhichIsA("BasePart")
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundColor3 = Color3.fromRGB(28, 38, 42)
        label.BackgroundTransparency = 0.12
        label.BorderSizePixel = 0
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(242, 239, 221)
        label.TextScaled = true
        label.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        record.HealthLabel = label
        updateDefenseLabel(record)
        table.insert(match.Defenses, record)
    end
end

local function restoreParticipant(self, player, match)
    local returnCFrame = match.ReturnCFrames and match.ReturnCFrames[player]
    if not returnCFrame or not player or player.Parent ~= Players then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if root and humanoid and humanoid.Health > 0 then
        character:PivotTo(returnCFrame)
    else
        self._pendingReturns[player] = returnCFrame
    end
end

local function publishArenaState(match)
    local remaining = math.max(0, match.ExpiresAt - now())
    local timestamp = os.clock()
    for _, participant in ipairs({ match.Attacker, match.Defender }) do
        if participant and participant.Parent == Players then
            local opponent = participant == match.Attacker and match.Defender or match.Attacker
            participant:SetAttribute("RaidArenaCoreHealth", match.CoreHealth)
            participant:SetAttribute("RaidArenaTimeRemaining", remaining)
            participant:SetAttribute("RaidArenaCombatHealth", match.CombatHealth and match.CombatHealth[participant] or 100)
            participant:SetAttribute("RaidArenaOpponentCombatHealth", match.CombatHealth and match.CombatHealth[opponent] or 100)
            participant:SetAttribute("RaidArenaGuardActive", match.GuardUntil and (match.GuardUntil[participant] or 0) > timestamp or false)
            participant:SetAttribute("RaidArenaGuardCooldown", match.GuardCooldownUntil
                and math.max(0, math.ceil((match.GuardCooldownUntil[participant] or 0) - timestamp)) or 0)
            local defenseCount = 0
            for _, defense in ipairs(match.Defenses or {}) do
                if defense.Health > 0 and defense.Model and defense.Model.Parent then defenseCount += 1 end
            end
            participant:SetAttribute("RaidArenaDefenseCount", defenseCount)
            local pet = match.RaidPets and match.RaidPets[participant] or nil
            local ability = pet and pet.Ability or nil
            local synergy = match.RaidPetSynergy and match.RaidPetSynergy[participant] or nil
            local petLevel, petPower, petPowerLabel = getRaidPetProgression(pet, synergy)
            participant:SetAttribute("RaidArenaPetName", pet and pet.Name or "")
            participant:SetAttribute("RaidArenaPetAbilityName", ability and ability.Name or "")
            participant:SetAttribute("RaidArenaPetRole", ability and ability.Role or "")
            participant:SetAttribute("RaidArenaPetLevel", ability and petLevel or 0)
            participant:SetAttribute("RaidArenaPetPower", petPower)
            participant:SetAttribute("RaidArenaPetPowerLabel", petPowerLabel)
            participant:SetAttribute("RaidArenaSynergyName", synergy and synergy.Name or "")
            participant:SetAttribute("RaidArenaSynergyDescription", synergy and synergy.Description or "")
            participant:SetAttribute("RaidArenaPetCooldown", match.PetAbilityReadyAt
                and math.max(0, math.ceil((match.PetAbilityReadyAt[participant] or 0) - timestamp)) or 0)
            local shield = match.PetShields and match.PetShields[participant] or nil
            local shieldActive = shield and shield.ExpiresAt > timestamp and shield.Amount > 0
            participant:SetAttribute("RaidArenaPetShield", shieldActive and math.max(0, shield.Amount) or 0)
            participant:SetAttribute("RaidArenaPetShieldSeconds", shieldActive
                and math.max(0, math.ceil(shield.ExpiresAt - timestamp)) or 0)
        end
    end
    if match.CoreLabel and match.CoreLabel.Parent then
        match.CoreLabel.Text = string.format("ЯДРО ГНЕЗДА · %d / %d", match.CoreHealth, RAID_CORE_MAX_HEALTH)
    end
end

local function makeGearPart(parent, name, size, cframe, color, material, weldTo)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.Metal
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = weldTo
    weld.Part1 = part
    weld.Parent = part
    return part
end

local function equipRaidGear(player, role)
    local character = player.Character
    local rightHand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
    local leftHand = character and (character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"))
    if not character or not rightHand or not leftHand then return nil end

    local gear = Instance.new("Model")
    gear.Name = "RaidCombatGear"
    gear.Parent = character
    local accent = role == "ATTACKER" and Color3.fromRGB(255, 145, 91) or Color3.fromRGB(111, 203, 232)
    local dark = Color3.fromRGB(49, 58, 72)

    local handle = makeGearPart(gear, "RaidSwordHandle", Vector3.new(0.28, 1.05, 0.28),
        rightHand.CFrame * CFrame.new(0, -0.28, -0.08), dark, Enum.Material.Slate, rightHand)
    makeGearPart(gear, "RaidSwordBlade", Vector3.new(0.34, 2.25, 0.13),
        handle.CFrame * CFrame.new(0, 1.55, 0), accent, Enum.Material.Neon, handle)
    makeGearPart(gear, "RaidSwordGuard", Vector3.new(0.95, 0.16, 0.24),
        handle.CFrame * CFrame.new(0, 0.5, 0), Color3.fromRGB(226, 190, 119), Enum.Material.Metal, handle)

    local shield = makeGearPart(gear, "RaidShield", Vector3.new(0.28, 2.05, 1.45),
        leftHand.CFrame * CFrame.new(0, 0.05, -0.48), dark, Enum.Material.Metal, leftHand)
    makeGearPart(gear, "RaidShieldEmblem", Vector3.new(0.12, 1.05, 0.72),
        shield.CFrame * CFrame.new(-0.18, 0, 0), accent, Enum.Material.Neon, shield)
    return gear
end

local function showRaidCombatHit(character, parried)
    if not character or not character.Parent then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = parried and "RaidParryFlash" or "RaidHitFlash"
    highlight.Adornee = character
    highlight.FillColor = parried and Color3.fromRGB(105, 205, 255) or Color3.fromRGB(255, 105, 92)
    highlight.OutlineColor = parried and Color3.fromRGB(198, 239, 255) or Color3.fromRGB(255, 218, 169)
    highlight.FillTransparency = 0.28
    highlight.OutlineTransparency = 0.05
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character
    Debris:AddItem(highlight, 0.22)
end

function RaidService:GetProtection(player)
    if not player:GetAttribute("ProfileLoaded") or not PlayerDataService:GetProfile(player) then
        return true, "Профиль ещё загружается.", 0
    end
    if not PlotService:GetPlayerPlot(player) then
        return true, "Личное гнездо ещё не готово.", 0
    end
    local level = getLevel(player)
    if level < MINIMUM_LEVEL then
        return true, "Рейды открываются с 5 уровня. Твой уровень: " .. tostring(level) .. ".", 0
    end
    local joinedAt = self._joinedAt[player] or now()
    local remaining = math.max(0, NEWCOMER_PROTECTION_SECONDS - (now() - joinedAt))
    if remaining > 0 then
        local minutes = math.ceil(remaining / 60)
        return true, "Защита новичка: ещё примерно " .. tostring(minutes) .. " мин.", remaining
    end
    return false, "", 0
end

function RaidService:IsVisiting(player)
    return IslandVisitService._visitingPlot[player] ~= nil
end

function RaidService:CanParticipate(player)
    local protected, reason, remaining = self:GetProtection(player)
    if protected then return false, reason, remaining end
    if self:IsVisiting(player) then
        return false, "Сначала вернись на свой остров.", 0
    end
    if self._matches[player] then
        return false, "Сначала заверши или отмени текущий вызов.", 0
    end
    return true, "", 0
end

local function clearPlayerWindows(player)
    player:SetAttribute("RaidAttackUntil", nil)
    player:SetAttribute("RaidDefenseUntil", nil)
    player:SetAttribute("RaidAttackReady", false)
    player:SetAttribute("RaidDefenseOpen", false)
end

local function clearPending(self, pending, message)
    if not pending then return end
    local attacker = pending.Attacker
    local defender = pending.Defender
    if self._pendingByTarget[defender] == pending then self._pendingByTarget[defender] = nil end
    if self._pendingByAttacker[attacker] == pending then self._pendingByAttacker[attacker] = nil end
    if attacker and attacker.Parent == Players then
        attacker:SetAttribute("RaidOutgoingTargetUserId", nil)
        attacker:SetAttribute("RaidOutgoingTargetName", nil)
        if message then attacker:SetAttribute("LastNotice", message) end
    end
    if defender and defender.Parent == Players then
        defender:SetAttribute("RaidIncomingAttackerUserId", nil)
        defender:SetAttribute("RaidIncomingAttackerName", nil)
    end
end

local function clearMatch(self, match, message)
    if not match then return end
    local attacker = match.Attacker
    local defender = match.Defender
    if self._matches[attacker] == match then self._matches[attacker] = nil end
    if self._matches[defender] == match then self._matches[defender] = nil end

    if match.DeathConnections then
        for _, connection in ipairs(match.DeathConnections) do
            if connection.Connected then connection:Disconnect() end
        end
    end
    if match.DefenseConnections then
        for _, connection in ipairs(match.DefenseConnections) do
            if connection.Connected then connection:Disconnect() end
        end
    end
    restoreParticipant(self, attacker, match)
    restoreParticipant(self, defender, match)
    if match.Gear then
        for _, gear in pairs(match.Gear) do
            if gear and gear.Parent then gear:Destroy() end
        end
    end
    if match.ArenaModel and match.ArenaModel.Parent then match.ArenaModel:Destroy() end

    for _, participant in ipairs({ attacker, defender }) do
        if participant and participant.Parent == Players then
            participant:SetAttribute("RaidMatchId", nil)
            participant:SetAttribute("RaidMatchOpponent", nil)
            participant:SetAttribute("RaidMatchRole", nil)
            participant:SetAttribute("RaidMatchState", nil)
            participant:SetAttribute("RaidArenaActive", false)
            participant:SetAttribute("RaidArenaRole", nil)
            participant:SetAttribute("RaidArenaOpponentName", nil)
            participant:SetAttribute("RaidArenaCoreHealth", nil)
            participant:SetAttribute("RaidArenaTimeRemaining", nil)
            participant:SetAttribute("RaidArenaCombatHealth", nil)
            participant:SetAttribute("RaidArenaOpponentCombatHealth", nil)
            participant:SetAttribute("RaidArenaGuardActive", nil)
            participant:SetAttribute("RaidArenaGuardCooldown", nil)
            participant:SetAttribute("RaidArenaDefenseCount", nil)
            participant:SetAttribute("RaidArenaPetName", nil)
            participant:SetAttribute("RaidArenaPetAbilityName", nil)
            participant:SetAttribute("RaidArenaPetRole", nil)
            participant:SetAttribute("RaidArenaPetLevel", nil)
            participant:SetAttribute("RaidArenaPetPower", nil)
            participant:SetAttribute("RaidArenaPetPowerLabel", nil)
            participant:SetAttribute("RaidArenaSynergyName", nil)
            participant:SetAttribute("RaidArenaSynergyDescription", nil)
            participant:SetAttribute("RaidArenaPetCooldown", nil)
            participant:SetAttribute("RaidArenaPetShield", nil)
            participant:SetAttribute("RaidArenaPetShieldSeconds", nil)
            participant:SetAttribute("RaidArenaMatchId", nil)
            if message then participant:SetAttribute("LastNotice", message) end
        end
    end
end

local function grantRaidReward(player, won)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return false end
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    local cooldownUntil = math.max(0, math.floor(tonumber(profile.QuestProgress.RaidRewardCooldownUntil) or 0))
    if cooldownUntil > now() then
        player:SetAttribute("LastNotice", "Награда за рейд уже получена недавно. Повторный матч проходит без награды.")
        return false
    end

    profile.QuestProgress.RaidRewardCooldownUntil = now() + RAID_REWARD_COOLDOWN_SECONDS
    local coins = won and RAID_WIN_COINS or RAID_PARTICIPATION_COINS
    EconomyService:GrantCoins(player, coins, won and "Победа в рейде" or "Участие в рейде")
    if won then
        local _, awardedXP, researchBonus, extraXP = ProgressionService:AddXP(player, RAID_WIN_XP)
        local xpText = awardedXP and ProgressionService:FormatXPReward(awardedXP, researchBonus, extraXP) or ""
        player:SetAttribute("LastNotice", "Победа в рейде! +" .. tostring(coins) .. " монет · " .. xpText .. ".")
    else
        player:SetAttribute("LastNotice", "Рейд завершён. За участие получено +" .. tostring(coins) .. " монет.")
    end
    return true
end

local function finishMatch(self, match, winnerRole, message, awardRewards)
    if not match or match.Finished then return end
    match.Finished = true
    clearMatch(self, match, message)
    if not awardRewards or not winnerRole then return end

    local winner = winnerRole == "ATTACKER" and match.Attacker or match.Defender
    local loser = winner == match.Attacker and match.Defender or match.Attacker
    if winner and winner.Parent == Players then grantRaidReward(winner, true) end
    if loser and loser.Parent == Players then grantRaidReward(loser, false) end
end

local function applyRaidCombatDamage(self, match, target, amount, sourceName)
    if not match or match.State ~= "ACTIVE" or self._matches[target] ~= match then return true, 0, 0 end
    local timestamp = os.clock()
    local incomingDamage = math.max(0, tonumber(amount) or 0)
    local synergy = match.RaidPetSynergy and match.RaidPetSynergy[target] or nil
    local damageReduction = math.clamp(tonumber(synergy and synergy.DamageReduction) or 0, 0, 0.2)
    local reducedDamage = math.max(0, math.floor(incomingDamage * (1 - damageReduction) + 0.5))
    local remainingDamage = reducedDamage
    local absorbed = 0
    local shield = match.PetShields and match.PetShields[target] or nil
    if shield and shield.ExpiresAt > timestamp and shield.Amount > 0 then
        absorbed = math.min(remainingDamage, shield.Amount)
        shield.Amount -= absorbed
        remainingDamage -= absorbed
        if shield.Amount <= 0 then match.PetShields[target] = nil end
    elseif shield then
        match.PetShields[target] = nil
    end

    match.CombatHealth[target] = math.max(0, (match.CombatHealth[target] or 100) - remainingDamage)
    showRaidCombatHit(target.Character, absorbed > 0)
    local shieldText = absorbed > 0 and (" Щит питомца поглотил " .. tostring(absorbed) .. ".") or ""
    local synergyText = reducedDamage < incomingDamage
        and (" Синергия «" .. tostring(synergy.Name) .. "» смягчила удар.") or ""
    target:SetAttribute("LastNotice", sourceName .. ": получено " .. tostring(remainingDamage)
        .. " урона." .. shieldText .. synergyText .. " Здоровье: " .. tostring(match.CombatHealth[target]) .. " / 100.")
    publishArenaState(match)
    if match.CombatHealth[target] <= 0 then
        finishMatch(self, match, target == match.Attacker and "DEFENDER" or "ATTACKER",
            "Соперник выбыл из рейда!", true)
        return true, remainingDamage, absorbed
    end
    return false, remainingDamage, absorbed
end

local function applyDefenseDamage(self, match, target, amount, sourceName)
    return applyRaidCombatDamage(self, match, target, amount, sourceName)
end

local function startDefenseTurret(self, match, defense)
    task.spawn(function()
        while self._matches[match.Attacker] == match and match.State == "ACTIVE"
            and defense.Health > 0 and defense.Model and defense.Model.Parent do
            task.wait(math.max(1.3, defense.Interval - 0.22))
            if self._matches[match.Attacker] ~= match or match.State ~= "ACTIVE"
                or defense.Health <= 0 or not defense.Model or not defense.Model.Parent then
                break
            end
            local character = match.Attacker.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 and defense.Muzzle and defense.Muzzle.Parent
                and (root.Position - defense.Muzzle.Position).Magnitude <= defense.Range then
                local targetPosition = root.Position
                local bolt = Instance.new("Part")
                bolt.Name = "NestDefenseBolt"
                bolt.Shape = Enum.PartType.Ball
                bolt.Size = Vector3.new(0.55, 0.55, 0.55)
                bolt.Material = Enum.Material.Neon
                bolt.Color = Color3.fromRGB(120, 224, 255)
                bolt.Anchored = true
                bolt.CanCollide = false
                bolt.CanTouch = false
                bolt.CanQuery = false
                bolt.CFrame = CFrame.new(defense.Muzzle.Position)
                bolt.Parent = match.ArenaModel
                local tween = TweenService:Create(bolt, TweenInfo.new(0.22, Enum.EasingStyle.Linear),
                    { Position = targetPosition })
                tween:Play()
                tween.Completed:Wait()
                if bolt.Parent then bolt:Destroy() end
                local currentRoot = match.Attacker.Character and match.Attacker.Character:FindFirstChild("HumanoidRootPart")
                if currentRoot and (currentRoot.Position - targetPosition).Magnitude <= 7 then
                    applyDefenseDamage(self, match, match.Attacker, defense.Damage, "Сторожевая башня")
                end
            end
        end
    end)
end

local function activateArenaDefenses(self, match)
    for _, defense in ipairs(match.Defenses or {}) do
        if defense.Type == "Turret" then
            startDefenseTurret(self, match, defense)
        elseif defense.Type == "Trap" and defense.Trigger then
            local connection = defense.Trigger.Touched:Connect(function(hit)
                if match.State ~= "ACTIVE" or defense.Health <= 0
                    or (defense.LastTriggeredAt and os.clock() - defense.LastTriggeredAt < defense.Cooldown) then return end
                local character = hit and hit:FindFirstAncestorOfClass("Model")
                local touchingPlayer = character and Players:GetPlayerFromCharacter(character)
                if touchingPlayer ~= match.Attacker then return end
                defense.LastTriggeredAt = os.clock()
                applyDefenseDamage(self, match, match.Attacker, defense.Damage, "Ловушка из шипов")
            end)
            table.insert(match.DefenseConnections, connection)
        end
    end
end

local function findNearestDefense(match, root, maxDistance, damagedOnly)
    local nearest, nearestDistance
    for _, defense in ipairs(match.Defenses or {}) do
        if defense.Health > 0 and defense.Model and defense.Model.Parent
            and (not damagedOnly or defense.Health < defense.MaxHealth) then
            local distance = (root.Position - defense.Position).Magnitude
            if distance <= maxDistance and (not nearestDistance or distance < nearestDistance) then
                nearest, nearestDistance = defense, distance
            end
        end
    end
    return nearest, nearestDistance
end

local function followRaidCompanions(self, match, player, followers)
    task.spawn(function()
        while self._matches[player] == match and match.State == "ACTIVE" do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                for index, entry in ipairs(followers or {}) do
                    local model = entry.Model
                    if model and model.Parent then
                        local side = (index - (#followers + 1) / 2) * 3.2
                        local target = root.CFrame * CFrame.new(side, -2.15, 4.4)
                            * CFrame.Angles(0, math.pi, 0)
                        model:PivotTo(model:GetPivot():Lerp(target, 0.38))
                    end
                end
            end
            task.wait(0.12)
        end
    end)
end

function RaidService:StartArena(match)
    if not match or match.State ~= "READY" then
        return false, "Подтверждённый вызов больше недоступен."
    end
    local attackerCharacter = match.Attacker and match.Attacker.Character
    local defenderCharacter = match.Defender and match.Defender.Character
    local attackerRoot = attackerCharacter and attackerCharacter:FindFirstChild("HumanoidRootPart")
    local defenderRoot = defenderCharacter and defenderCharacter:FindFirstChild("HumanoidRootPart")
    local attackerHumanoid = attackerCharacter and attackerCharacter:FindFirstChildOfClass("Humanoid")
    local defenderHumanoid = defenderCharacter and defenderCharacter:FindFirstChildOfClass("Humanoid")
    if not attackerRoot or not defenderRoot or not attackerHumanoid or not defenderHumanoid
        or attackerHumanoid.Health <= 0 or defenderHumanoid.Health <= 0 then
        clearMatch(self, match, "Рейд не начался: один из игроков не готов к бою.")
        return false, "Оба игрока должны находиться в игре и быть живы."
    end

    match.ReturnCFrames = {
        [match.Attacker] = attackerCharacter:GetPivot(),
        [match.Defender] = defenderCharacter:GetPivot(),
    }
    match.DeathConnections = {}
    buildArena(self, match)
    buildArenaDefenses(match, PlayerDataService:GetProfile(match.Defender))
    match.State = "ACTIVE"
    match.CoreHealth = RAID_CORE_MAX_HEALTH
    match.ExpiresAt = now() + RAID_DURATION_SECONDS
    match.LastAttackAt = {}
    match.LastRepairAt = {}
    match.LastDefenseAttackAt = {}
    match.LastDefenseRepairAt = {}
    match.LastStrikeAt = {}
    match.GuardUntil = {}
    match.GuardCooldownUntil = {}
    match.PetAbilityReadyAt = {}
    match.PetShields = {}
    match.RaidPets = {}
    match.RaidPetModels = {}
    match.RaidPetSynergy = {}
    match.CombatHealth = {
        [match.Attacker] = 100,
        [match.Defender] = 100,
    }
    match.Gear = {}

    attackerCharacter:PivotTo(CFrame.lookAt(match.ArenaCenter + Vector3.new(-34, 5, 0), match.ArenaCenter + Vector3.new(0, 5, 0)))
    defenderCharacter:PivotTo(CFrame.lookAt(match.ArenaCenter + Vector3.new(34, 5, 0), match.ArenaCenter + Vector3.new(0, 5, 0)))
    match.Gear[match.Attacker] = equipRaidGear(match.Attacker, "ATTACKER")
    match.Gear[match.Defender] = equipRaidGear(match.Defender, "DEFENDER")

    for _, participant in ipairs({ match.Attacker, match.Defender }) do
        local folder = Instance.new("Folder")
        folder.Name = "RaidCompanions_" .. tostring(participant.UserId)
        folder.Parent = match.ArenaModel
        local followers, primary = CompanionService:CreateRaidFollowers(participant, folder)
        match.RaidFollowers = match.RaidFollowers or {}
        match.RaidFollowers[participant] = followers
        match.RaidPets[participant] = primary
        match.RaidPetModels[participant] = primary and primary.Model or nil
        match.RaidPetSynergy[participant] = getRaidPetSynergy(followers)
        if #followers > 0 then followRaidCompanions(self, match, participant, followers) end
    end

    for _, participant in ipairs({ match.Attacker, match.Defender }) do
        participant:SetAttribute("RaidMatchState", "ACTIVE")
        participant:SetAttribute("RaidArenaActive", true)
        participant:SetAttribute("RaidArenaMatchId", match.Id)
        participant:SetAttribute("RaidArenaCoreHealth", RAID_CORE_MAX_HEALTH)
        participant:SetAttribute("RaidArenaTimeRemaining", RAID_DURATION_SECONDS)
        participant:SetAttribute("RaidArenaOpponentName",
            participant == match.Attacker and match.Defender.DisplayName or match.Attacker.DisplayName)
        participant:SetAttribute("RaidArenaRole", participant == match.Attacker and "ATTACKER" or "DEFENDER")
    end

    table.insert(match.DeathConnections, attackerHumanoid.Died:Connect(function()
        if self._matches[match.Attacker] == match then
            finishMatch(self, match, nil, "Рейд прерван: участник выбыл. Награда не начислена.", false)
        end
    end))
    table.insert(match.DeathConnections, defenderHumanoid.Died:Connect(function()
        if self._matches[match.Defender] == match then
            finishMatch(self, match, nil, "Рейд прерван: участник выбыл. Награда не начислена.", false)
        end
    end))

    activateArenaDefenses(self, match)
    publishArenaState(match)
    match.Attacker:SetAttribute("LastNotice", #match.Defenses > 0
        and ("Рейд начался! На острове защитника подготовлено сооружений: " .. tostring(#match.Defenses) .. ".")
        or "Рейд начался! У защитника пока нет оборонительных сооружений.")
    match.Defender:SetAttribute("LastNotice", #match.Defenses > 0
        and ("Твоя оборона активирована! Сооружений: " .. tostring(#match.Defenses) .. ".")
        or "Твоё гнездо пока без оборонительных сооружений. В следующий раз построй защиту.")
    return true
end

function RaidService:AttackCore(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or match.Attacker ~= player then
        return { Ok = false, Message = "Сейчас ты не атакующий в активном рейде." }
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - match.CorePosition).Magnitude > 16 then
        return { Ok = false, Message = "Подойди ближе к ядру, чтобы ударить его." }
    end
    local timestamp = os.clock()
    local lastAttack = match.LastAttackAt[player]
    if lastAttack and timestamp - lastAttack < RAID_ATTACK_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Удар ещё восстанавливается." }
    end
    match.LastAttackAt[player] = timestamp
    match.CoreHealth = math.max(0, match.CoreHealth - RAID_CORE_HIT_DAMAGE)
    if match.CorePart and match.CorePart.Parent then
        match.CorePart.Color = match.CoreHealth <= 30 and Color3.fromRGB(255, 91, 91)
            or match.CoreHealth <= 60 and Color3.fromRGB(255, 151, 83)
            or Color3.fromRGB(255, 183, 92)
    end
    publishArenaState(match)
    if match.CoreHealth <= 0 then
        finishMatch(self, match, "ATTACKER", "Ядро разрушено! Атакующий победил.", true)
        return { Ok = true, Message = "Ядро разрушено! Победа в рейде." }
    end
    return { Ok = true, Message = "Удар по ядру! Прочность: " .. tostring(match.CoreHealth) .. " / " .. tostring(RAID_CORE_MAX_HEALTH) .. "." }
end

function RaidService:ReinforceCore(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or match.Defender ~= player then
        return { Ok = false, Message = "Сейчас ты не защитник в активном рейде." }
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - match.CorePosition).Magnitude > 16 then
        return { Ok = false, Message = "Подойди ближе к ядру, чтобы укрепить его." }
    end
    local timestamp = os.clock()
    local lastRepair = match.LastRepairAt[player]
    if lastRepair and timestamp - lastRepair < RAID_REPAIR_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Укрепление ещё восстанавливается." }
    end
    if match.CoreHealth >= RAID_CORE_MAX_HEALTH then
        return { Ok = false, Message = "Ядро уже полностью защищено." }
    end
    match.LastRepairAt[player] = timestamp
    match.CoreHealth = math.min(RAID_CORE_MAX_HEALTH, match.CoreHealth + RAID_REPAIR_AMOUNT)
    publishArenaState(match)
    return { Ok = true, Message = "Ядро укреплено: " .. tostring(match.CoreHealth) .. " / " .. tostring(RAID_CORE_MAX_HEALTH) .. "." }
end

function RaidService:AttackDefense(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or match.Attacker ~= player then
        return { Ok = false, Message = "Разрушать оборону может только атакующий." }
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return { Ok = false, Message = "Нельзя атаковать сооружение сейчас." }
    end
    local timestamp = os.clock()
    local lastDefenseAttack = match.LastDefenseAttackAt[player]
    if lastDefenseAttack and timestamp - lastDefenseAttack < RAID_DEFENSE_STRIKE_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Удар по сооружению ещё восстанавливается." }
    end
    local defense = findNearestDefense(match, root, RAID_DUEL_STRIKE_RANGE, false)
    if not defense then
        return { Ok = false, Message = "Подойди ближе к оборонительному сооружению." }
    end
    match.LastDefenseAttackAt[player] = timestamp
    defense.Health = math.max(0, defense.Health - RAID_DEFENSE_STRIKE_DAMAGE)
    updateDefenseLabel(defense)
    if defense.Health <= 0 then
        if defense.Model and defense.Model.Parent then defense.Model:Destroy() end
        player:SetAttribute("LastNotice", defense.Name .. " разрушено! Путь к ядру открыт.")
    else
        player:SetAttribute("LastNotice", defense.Name .. " повреждено: " .. tostring(defense.Health)
            .. " / " .. tostring(defense.MaxHealth) .. ".")
    end
    publishArenaState(match)
    return { Ok = true, Message = defense.Health <= 0
        and (defense.Name .. " уничтожено!")
        or (defense.Name .. ": " .. tostring(defense.Health) .. " / " .. tostring(defense.MaxHealth) .. " прочности.") }
end

function RaidService:RepairDefense(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or match.Defender ~= player then
        return { Ok = false, Message = "Ремонтировать оборону может только защитник." }
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return { Ok = false, Message = "Нельзя ремонтировать сооружение сейчас." }
    end
    local timestamp = os.clock()
    local lastDefenseRepair = match.LastDefenseRepairAt[player]
    if lastDefenseRepair and timestamp - lastDefenseRepair < RAID_DEFENSE_REPAIR_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Ремонт обороны ещё восстанавливается." }
    end
    local defense = findNearestDefense(match, root, RAID_DUEL_STRIKE_RANGE, true)
    if not defense then
        return { Ok = false, Message = "Рядом нет повреждённых сооружений для ремонта." }
    end
    match.LastDefenseRepairAt[player] = timestamp
    defense.Health = math.min(defense.MaxHealth, defense.Health + RAID_DEFENSE_REPAIR_AMOUNT)
    updateDefenseLabel(defense)
    publishArenaState(match)
    return { Ok = true, Message = defense.Name .. " восстановлено: " .. tostring(defense.Health)
        .. " / " .. tostring(defense.MaxHealth) .. "." }
end

function RaidService:UsePetAbility(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or (match.Attacker ~= player and match.Defender ~= player) then
        return { Ok = false, Message = "Боевые способности питомца доступны только в активном рейде." }
    end
    local primary = match.RaidPets and match.RaidPets[player] or nil
    local ability = primary and primary.Ability or nil
    if not ability then
        return { Ok = false, Message = "Среди активных питомцев нет боевого спутника. Выбери питомца-стража, целителя или охотника." }
    end
    if getLevel(player) < (ability.UnlockLevel or 5) then
        return { Ok = false, Message = "Боевой навык питомца откроется на " .. tostring(ability.UnlockLevel or 5) .. " уровне." }
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return { Ok = false, Message = "Питомец не может помочь: персонаж сейчас недоступен." }
    end

    local timestamp = os.clock()
    local readyAt = match.PetAbilityReadyAt[player] or 0
    if readyAt > timestamp then
        return { Ok = false, Message = "Способность питомца восстановится через " .. tostring(math.ceil(readyAt - timestamp)) .. " сек." }
    end

    local role = ability.Role
    local synergy = match.RaidPetSynergy and match.RaidPetSynergy[player] or nil
    local petLevel, power = getRaidPetProgression(primary, synergy)
    local opponent = match.Attacker == player and match.Defender or match.Attacker
    local opponentCharacter = opponent and opponent.Character
    local opponentRoot = opponentCharacter and opponentCharacter:FindFirstChild("HumanoidRootPart")
    local opponentHumanoid = opponentCharacter and opponentCharacter:FindFirstChildOfClass("Humanoid")
    local cooldown = math.clamp(math.floor(tonumber(ability.CooldownSeconds) or 20), 10, 60)

    if role == "HUNTER" then
        if not opponentRoot or not opponentHumanoid or opponentHumanoid.Health <= 0 then
            return { Ok = false, Message = "Цель для атаки питомца недоступна." }
        end
        local distance = (opponentRoot.Position - root.Position).Magnitude
        if distance > math.clamp(tonumber(ability.Range) or 22, 12, 30)
            or math.abs(opponentRoot.Position.Y - root.Position.Y) > 10 then
            return { Ok = false, Message = "Охотник должен видеть соперника в пределах дальности способности." }
        end
        local damage = power
        match.PetAbilityReadyAt[player] = timestamp + cooldown
        local petModel = match.RaidPetModels and match.RaidPetModels[player]
        local petRoot = petModel and petModel.PrimaryPart
        local projectile = Instance.new("Part")
        projectile.Name = "RaidPetAbilityProjectile"
        projectile.Shape = Enum.PartType.Ball
        projectile.Size = Vector3.new(0.8, 0.8, 0.8)
        projectile.Material = Enum.Material.Neon
        projectile.Color = Color3.fromRGB(255, 178, 102)
        projectile.Anchored = true
        projectile.CanCollide = false
        projectile.CanTouch = false
        projectile.CanQuery = false
        projectile.CFrame = CFrame.new(petRoot and petRoot.Position or root.Position)
        projectile.Parent = match.ArenaModel
        local tween = TweenService:Create(projectile, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = opponentRoot.Position })
        tween:Play()
        Debris:AddItem(projectile, 0.4)
        local ended = applyRaidCombatDamage(self, match, opponent, damage, ability.Name)
        if ended then return { Ok = true, Message = ability.Name .. "! Соперник выбыл." } end
        player:SetAttribute("LastNotice", primary.Name .. " · ур. " .. tostring(petLevel)
            .. " применяет " .. ability.Name .. " · " .. tostring(damage) .. " урона.")
    elseif role == "HEALER" then
        local currentHealth = match.CombatHealth[player] or 100
        local heal = power
        local restored = math.min(heal, 100 - currentHealth)
        if restored <= 0 then
            return { Ok = false, Message = "Боёвая выносливость уже полностью восстановлена." }
        end
        match.PetAbilityReadyAt[player] = timestamp + cooldown
        match.CombatHealth[player] = currentHealth + restored
        local highlight = Instance.new("Highlight")
        highlight.Name = "RaidPetHealFlash"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(112, 226, 155)
        highlight.OutlineColor = Color3.fromRGB(206, 255, 216)
        highlight.FillTransparency = 0.72
        highlight.OutlineTransparency = 0.08
        highlight.Parent = character
        Debris:AddItem(highlight, 1.1)
        player:SetAttribute("LastNotice", primary.Name .. " · ур. " .. tostring(petLevel)
            .. " применяет " .. ability.Name .. ": +" .. tostring(restored) .. " здоровья.")
    elseif role == "GUARDIAN" then
        local currentShield = match.PetShields[player]
        if currentShield and currentShield.ExpiresAt > timestamp and currentShield.Amount > 0 then
            return { Ok = false, Message = "Защитный барьер питомца ещё действует." }
        end
        local shieldAmount = power
        local duration = math.clamp(tonumber(ability.ShieldDuration) or 7, 4, 10)
        match.PetAbilityReadyAt[player] = timestamp + cooldown
        match.PetShields[player] = { Amount = shieldAmount, ExpiresAt = timestamp + duration }
        local highlight = Instance.new("Highlight")
        highlight.Name = "RaidPetGuardianShield"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(116, 190, 239)
        highlight.OutlineColor = Color3.fromRGB(211, 241, 255)
        highlight.FillTransparency = 0.78
        highlight.OutlineTransparency = 0.06
        highlight.Parent = character
        Debris:AddItem(highlight, duration)
        player:SetAttribute("LastNotice", primary.Name .. " · ур. " .. tostring(petLevel)
            .. " активирует " .. ability.Name .. ": щит " .. tostring(shieldAmount) .. " на " .. tostring(duration) .. " сек.")
    else
        return { Ok = false, Message = "У этого питомца пока нет боевой специализации." }
    end

    publishArenaState(match)
    return { Ok = true, Message = "Способность питомца: " .. ability.Name .. "." }
end

function RaidService:StrikeOpponent(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or (match.Attacker ~= player and match.Defender ~= player) then
        return { Ok = false, Message = "Нет активного соперника для удара." }
    end
    local opponent = match.Attacker == player and match.Defender or match.Attacker
    local character = player.Character
    local targetCharacter = opponent and opponent.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
    if not root or not targetRoot or not humanoid or not targetHumanoid
        or humanoid.Health <= 0 or targetHumanoid.Health <= 0 then
        return { Ok = false, Message = "Соперник сейчас недоступен." }
    end
    local offset = targetRoot.Position - root.Position
    if offset.Magnitude > RAID_DUEL_STRIKE_RANGE or math.abs(offset.Y) > 7 then
        return { Ok = false, Message = "Подойди ближе к сопернику для удара." }
    end

    local timestamp = os.clock()
    local lastStrike = match.LastStrikeAt[player] or 0
    if timestamp - lastStrike < RAID_DUEL_STRIKE_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Удар ещё восстанавливается." }
    end
    match.LastStrikeAt[player] = timestamp

    local targetGuardUntil = match.GuardUntil[opponent] or 0
    if targetGuardUntil > timestamp then
        match.GuardUntil[opponent] = 0
        local ended = applyRaidCombatDamage(self, match, player, RAID_PARRY_COUNTER_DAMAGE, "Контрудар парирования")
        if ended then
            return { Ok = true, Message = "Парирование! Ты отразил удар и победил." }
        end
        opponent:SetAttribute("LastNotice", "Идеальное парирование! Контрудар нанесён.")
    else
        local synergy = match.RaidPetSynergy and match.RaidPetSynergy[player] or nil
        local strikeMultiplier = math.clamp(tonumber(synergy and synergy.DuelDamageMultiplier) or 1, 1, 1.15)
        local strikeDamage = math.floor(RAID_DUEL_STRIKE_DAMAGE * strikeMultiplier + 0.5)
        local ended = applyRaidCombatDamage(self, match, opponent, strikeDamage, "Удар соперника")
        if ended then return { Ok = true, Message = "Соперник выбыл! Победа в рейде." } end
        player:SetAttribute("LastNotice", "Попадание! Урон: " .. tostring(strikeDamage)
            .. " · здоровье соперника: " .. tostring(match.CombatHealth[opponent]) .. " / 100.")
    end

    publishArenaState(match)
    return { Ok = true, Message = "Боевой удар выполнен." }
end

function RaidService:RaiseGuard(player)
    local match = self._matches[player]
    if not match or match.State ~= "ACTIVE" or (match.Attacker ~= player and match.Defender ~= player) then
        return { Ok = false, Message = "Блок доступен только во время активного рейда." }
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        return { Ok = false, Message = "Нельзя выставить блок сейчас." }
    end

    local timestamp = os.clock()
    local cooldownUntil = match.GuardCooldownUntil[player] or 0
    if cooldownUntil > timestamp then
        return { Ok = false, Message = "Парирование восстановится через " .. tostring(math.ceil(cooldownUntil - timestamp)) .. " сек." }
    end
    local guardUntil = timestamp + RAID_PARRY_WINDOW_SECONDS
    match.GuardUntil[player] = guardUntil
    match.GuardCooldownUntil[player] = timestamp + RAID_PARRY_COOLDOWN_SECONDS

    local highlight = Instance.new("Highlight")
    highlight.Name = "RaidGuardFlash"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(100, 193, 232)
    highlight.OutlineColor = Color3.fromRGB(218, 245, 255)
    highlight.FillTransparency = 0.68
    highlight.OutlineTransparency = 0.05
    highlight.Parent = character
    Debris:AddItem(highlight, RAID_PARRY_WINDOW_SECONDS)

    publishArenaState(match)
    task.delay(RAID_PARRY_WINDOW_SECONDS + 0.05, function()
        if self._matches[player] == match and match.GuardUntil[player] == guardUntil then
            match.GuardUntil[player] = 0
            publishArenaState(match)
        end
    end)
    return { Ok = true, Message = "Блок поднят! Окно парирования: 0,9 секунды." }
end

function RaidService:CleanupExpired()
    local timestamp = now()
    for _, pending in pairs(self._pendingByTarget) do
        if pending.ExpiresAt <= timestamp
            or not pending.Attacker or pending.Attacker.Parent ~= Players
            or not pending.Defender or pending.Defender.Parent ~= Players then
            clearPending(self, pending, "Время ожидания вызова истекло.")
        end
    end
    for _, match in pairs(self._matches) do
        if not match.Attacker or match.Attacker.Parent ~= Players
            or not match.Defender or match.Defender.Parent ~= Players then
            finishMatch(self, match, nil, "Соперник покинул сервер. Рейд отменён без награды.", false)
        elseif match.ExpiresAt <= timestamp then
            if match.State == "ACTIVE" then
                finishMatch(self, match, "DEFENDER", "Время вышло! Защитник сохранил ядро.", true)
            else
                clearMatch(self, match, "Время подготовки истекло. Можно создать новый вызов.")
            end
        elseif match.State == "ACTIVE" then
            publishArenaState(match)
        end
    end
end

function RaidService:SetAttackReady(player, enabled)
    if type(enabled) ~= "boolean" then
        return { Ok = false, Message = "Некорректный режим готовности." }
    end
    if self._matches[player] then
        return { Ok = false, Message = "Нельзя менять готовность во время подтверждённого вызова." }
    end
    if enabled then
        local allowed, reason = self:CanParticipate(player)
        if not allowed then return { Ok = false, Message = reason } end
        player:SetAttribute("RaidAttackUntil", now() + OPT_IN_WINDOW_SECONDS)
        player:SetAttribute("RaidAttackReady", true)
        return { Ok = true, Message = "Ты готов к рейдам на 10 минут." }
    end
    local pending = self._pendingByAttacker[player]
    if pending then clearPending(self, pending, "Ты отменил вызов на рейд.") end
    player:SetAttribute("RaidAttackUntil", nil)
    player:SetAttribute("RaidAttackReady", false)
    return { Ok = true, Message = "Готовность к рейдам выключена." }
end

function RaidService:SetDefenseOpen(player, enabled)
    if type(enabled) ~= "boolean" then
        return { Ok = false, Message = "Некорректный режим защиты." }
    end
    if self._matches[player] then
        return { Ok = false, Message = "Нельзя менять доступность во время подтверждённого вызова." }
    end
    if enabled then
        local allowed, reason = self:CanParticipate(player)
        if not allowed then return { Ok = false, Message = reason } end
        player:SetAttribute("RaidDefenseUntil", now() + OPT_IN_WINDOW_SECONDS)
        player:SetAttribute("RaidDefenseOpen", true)
        return { Ok = true, Message = "Твоё гнездо открыто для добровольных рейдов на 10 минут." }
    end
    local pending = self._pendingByTarget[player]
    if pending then clearPending(self, pending, "Владелец закрыл гнездо. Вызов отменён.") end
    player:SetAttribute("RaidDefenseUntil", nil)
    player:SetAttribute("RaidDefenseOpen", false)
    return { Ok = true, Message = "Гнездо закрыто для рейдов." }
end

function RaidService:GetSnapshot(player)
    self:CleanupExpired()
    local protected, protectionReason, protectionSeconds = self:GetProtection(player)
    local attackReady, attackSeconds = isWindowOpen(player, "RaidAttackUntil")
    local defenseOpen, defenseSeconds = isWindowOpen(player, "RaidDefenseUntil")
    player:SetAttribute("RaidAttackReady", attackReady)
    player:SetAttribute("RaidDefenseOpen", defenseOpen)

    local incoming
    local pendingIn = self._pendingByTarget[player]
    if pendingIn and pendingIn.ExpiresAt > now() then
        incoming = {
            UserId = pendingIn.Attacker.UserId,
            DisplayName = pendingIn.Attacker.DisplayName,
            ExpiresIn = math.max(0, pendingIn.ExpiresAt - now()),
        }
    end

    local outgoing
    local pendingOut = self._pendingByAttacker[player]
    if pendingOut and pendingOut.ExpiresAt > now() then
        outgoing = {
            UserId = pendingOut.Defender.UserId,
            DisplayName = pendingOut.Defender.DisplayName,
            ExpiresIn = math.max(0, pendingOut.ExpiresAt - now()),
        }
    end

    local matchData
    local match = self._matches[player]
    if match then
        local opponent = match.Attacker == player and match.Defender or match.Attacker
        matchData = {
            Id = match.Id,
            State = match.State,
            Role = match.Attacker == player and "ATTACKER" or "DEFENDER",
            Opponent = opponent.DisplayName,
            ExpiresIn = math.max(0, match.ExpiresAt - now()),
            CoreHealth = match.CoreHealth,
        }
    end

    local targets = {}
    if not protected and attackReady and not match and not self:IsVisiting(player)
        and not self._pendingByAttacker[player] and not self._pendingByTarget[player] then
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player and target:GetAttribute("ProfileLoaded")
                and PlotService:GetPlayerPlot(target) and not self._matches[target]
                and not self._pendingByTarget[target] and not self._pendingByAttacker[target]
                and not self:IsVisiting(target) then
                local targetProtected = self:GetProtection(target)
                local targetDefenseOpen, targetDefenseSeconds = isWindowOpen(target, "RaidDefenseUntil")
                if not targetProtected and targetDefenseOpen then
                    table.insert(targets, {
                        UserId = target.UserId,
                        DisplayName = target.DisplayName,
                        Level = getLevel(target),
                        SecondsRemaining = targetDefenseSeconds,
                    })
                end
            end
        end
        table.sort(targets, function(a, b)
            if a.Level ~= b.Level then return a.Level < b.Level end
            return a.DisplayName:lower() < b.DisplayName:lower()
        end)
        while #targets > MAX_TARGETS do table.remove(targets) end
    end

    return {
        Ok = true,
        Self = {
            Level = getLevel(player),
            StudioAccessOverride = self._studioRaidLevelOverride[player] == true,
            Protected = protected,
            ProtectionReason = protectionReason,
            ProtectionSeconds = protectionSeconds,
            AttackReady = attackReady,
            AttackSeconds = attackSeconds,
            DefenseOpen = defenseOpen,
            DefenseSeconds = defenseSeconds,
        },
        Targets = targets,
        Incoming = incoming,
        Outgoing = outgoing,
        Match = matchData,
        ServerPlayers = #Players:GetPlayers(),
    }
end

function RaidService:Challenge(player, targetUserId)
    if type(targetUserId) ~= "number" or targetUserId <= 0 or targetUserId == player.UserId then
        return { Ok = false, Message = "Выбран некорректный соперник." }
    end
    local allowed, reason = self:CanParticipate(player)
    if not allowed then return { Ok = false, Message = reason } end
    local attackReady = isWindowOpen(player, "RaidAttackUntil")
    if not attackReady then return { Ok = false, Message = "Сначала включи готовность к рейдам." } end
    if self._pendingByAttacker[player] or self._pendingByTarget[player] then
        return { Ok = false, Message = "Сначала ответь на текущий вызов или отмени его." }
    end
    if now() - (self._lastChallengeAt[player] or 0) < CHALLENGE_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Подожди перед следующим вызовом." }
    end

    local target = Players:GetPlayerByUserId(targetUserId)
    if not target or not target:GetAttribute("ProfileLoaded")
        or not PlotService:GetPlayerPlot(target) then
        return { Ok = false, Message = "Соперник больше недоступен." }
    end
    local targetAllowed, targetReason = self:CanParticipate(target)
    if not targetAllowed then return { Ok = false, Message = targetReason } end
    local defenseOpen = isWindowOpen(target, "RaidDefenseUntil")
    if not defenseOpen then return { Ok = false, Message = "Это гнездо больше не открыто для рейдов." } end
    if self._pendingByTarget[target] or self._pendingByAttacker[target] or self._matches[target] then
        return { Ok = false, Message = "Этот игрок уже рассматривает другой вызов." }
    end

    local pending = {
        Id = HttpService:GenerateGUID(false),
        Attacker = player,
        Defender = target,
        ExpiresAt = now() + CHALLENGE_TIMEOUT_SECONDS,
    }
    self._pendingByTarget[target] = pending
    self._pendingByAttacker[player] = pending
    self._lastChallengeAt[player] = now()
    player:SetAttribute("RaidOutgoingTargetUserId", target.UserId)
    player:SetAttribute("RaidOutgoingTargetName", target.DisplayName)
    target:SetAttribute("RaidIncomingAttackerUserId", player.UserId)
    target:SetAttribute("RaidIncomingAttackerName", player.DisplayName)
    target:SetAttribute("LastNotice", player.DisplayName .. " предлагает добровольный рейд. Открой меню рейдов, чтобы ответить.")
    return { Ok = true, Message = "Вызов отправлен игроку " .. target.DisplayName .. ". Он действует 45 секунд." }
end

function RaidService:AcceptChallenge(player)
    local pending = self._pendingByTarget[player]
    if not pending then return { Ok = false, Message = "Входящий вызов уже недоступен." } end
    local attacker = pending.Attacker
    if pending.ExpiresAt <= now() or not attacker or attacker.Parent ~= Players then
        clearPending(self, pending, "Вызов больше недоступен.")
        return { Ok = false, Message = "Время вызова истекло." }
    end
    local attackerAllowed, attackerReason = self:CanParticipate(attacker)
    local defenderAllowed, defenderReason = self:CanParticipate(player)
    local attackerReady = isWindowOpen(attacker, "RaidAttackUntil")
    local defenderOpen = isWindowOpen(player, "RaidDefenseUntil")
    if not attackerAllowed or not defenderAllowed or not attackerReady or not defenderOpen then
        clearPending(self, pending, "Вызов отменён: один из игроков больше не готов.")
        local reason = attackerReason ~= "" and attackerReason or defenderReason ~= "" and defenderReason or "Один из игроков закрыл окно рейда."
        return { Ok = false, Message = reason }
    end

    clearPending(self, pending)
    local match = {
        Id = HttpService:GenerateGUID(false),
        Attacker = attacker,
        Defender = player,
        State = "READY",
        ExpiresAt = now() + MATCH_READY_TIMEOUT_SECONDS,
    }
    self._matches[attacker] = match
    self._matches[player] = match
    attacker:SetAttribute("RaidAttackUntil", nil)
    attacker:SetAttribute("RaidAttackReady", false)
    player:SetAttribute("RaidDefenseUntil", nil)
    player:SetAttribute("RaidDefenseOpen", false)
    for _, participant in ipairs({ attacker, player }) do
        participant:SetAttribute("RaidMatchId", match.Id)
        participant:SetAttribute("RaidMatchState", "READY")
    end
    attacker:SetAttribute("RaidMatchOpponent", player.DisplayName)
    attacker:SetAttribute("RaidMatchRole", "ATTACKER")
    player:SetAttribute("RaidMatchOpponent", attacker.DisplayName)
    player:SetAttribute("RaidMatchRole", "DEFENDER")
    local started, startMessage = self:StartArena(match)
    if not started then
        return { Ok = false, Message = startMessage or "Не удалось открыть арену." }
    end
    return { Ok = true, Message = "Вызов принят! Арена открыта — атакуй ядро или защищай его." }
end

function RaidService:DeclineChallenge(player)
    local pending = self._pendingByTarget[player]
    if not pending then return { Ok = false, Message = "Входящий вызов уже недоступен." } end
    clearPending(self, pending, player.DisplayName .. " отклонил вызов на рейд.")
    player:SetAttribute("LastNotice", "Вызов отклонён. Твоё гнездо осталось защищённым.")
    return { Ok = true, Message = "Вызов отклонён. Никакие ресурсы не затронуты." }
end

function RaidService:CancelChallenge(player)
    local pending = self._pendingByAttacker[player]
    if not pending then return { Ok = false, Message = "Нет ожидающего вызова." } end
    clearPending(self, pending, "Соперник отменил вызов на рейд.")
    return { Ok = true, Message = "Вызов отменён." }
end

function RaidService:CancelMatch(player)
    local match = self._matches[player]
    if not match then return { Ok = false, Message = "Нет активного подтверждённого вызова." } end
    if match.State == "ACTIVE" then
        finishMatch(self, match, nil, "Игрок завершил рейд досрочно. Награда не начислена.", false)
    else
        clearMatch(self, match, "Подтверждённый вызов отменён одним из игроков.")
    end
    return { Ok = true, Message = "Рейд завершён. Награда за досрочный выход не начисляется." }
end

function RaidService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос рейда." }
    end
    if not player:GetAttribute("ProfileLoaded") or not PlayerDataService:GetProfile(player) then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    -- Read-only refreshes are cheap and must remain available immediately after a button action.
    -- Mutating actions retain a short server-side cooldown.
    if payload.Action ~= "Get" then
        local timestamp = os.clock()
        if timestamp - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN_SECONDS then
            return { Ok = false, Message = "Подожди немного перед следующим действием." }
        end
        self._lastRequest[player] = timestamp
    end

    if payload.Action == "DevGrantAccess" then
        if not RunService:IsStudio() then
            return { Ok = false, Message = "Тестовый доступ доступен только в Roblox Studio." }
        end
        self._studioRaidLevelOverride[player] = true
        self._joinedAt[player] = now() - NEWCOMER_PROTECTION_SECONDS
        return { Ok = true, Message = "Тестовый доступ к рейдам включён. Профиль и сохранённый уровень не изменены." }
    end
    if payload.Action == "DevResetAccess" then
        if not RunService:IsStudio() then
            return { Ok = false, Message = "Сброс тестового доступа доступен только в Roblox Studio." }
        end
        self._studioRaidLevelOverride[player] = nil
        self._joinedAt[player] = now()
        clearPlayerWindows(player)
        return { Ok = true, Message = "Тестовый доступ сброшен. Защита новичка снова активна." }
    end
    if payload.Action == "Get" then return self:GetSnapshot(player) end
    if payload.Action == "SetAttackReady" then return self:SetAttackReady(player, payload.Enabled) end
    if payload.Action == "SetDefenseOpen" then return self:SetDefenseOpen(player, payload.Enabled) end
    if payload.Action == "Challenge" then return self:Challenge(player, payload.TargetUserId) end
    if payload.Action == "Accept" then return self:AcceptChallenge(player) end
    if payload.Action == "Decline" then return self:DeclineChallenge(player) end
    if payload.Action == "CancelChallenge" then return self:CancelChallenge(player) end
    if payload.Action == "CancelMatch" then return self:CancelMatch(player) end
    if payload.Action == "AttackCore" then return self:AttackCore(player) end
    if payload.Action == "ReinforceCore" then return self:ReinforceCore(player) end
    if payload.Action == "StrikeOpponent" then return self:StrikeOpponent(player) end
    if payload.Action == "RaiseGuard" then return self:RaiseGuard(player) end
    if payload.Action == "AttackDefense" then return self:AttackDefense(player) end
    if payload.Action == "RepairDefense" then return self:RepairDefense(player) end
    if payload.Action == "UsePetAbility" then return self:UsePetAbility(player) end
    return { Ok = false, Message = "Неизвестное действие рейда." }
end

function RaidService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("RaidBoard")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "RaidBoard"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        local ok, result = pcall(function()
            return self:HandleRequest(player, payload)
        end)
        if not ok then
            warn("[NEST RAIDERS] Raid request failed:", result)
            return { Ok = false, Message = "Система рейдов временно недоступна." }
        end
        return result
    end

    local function bindPlayer(player)
        self._joinedAt[player] = now()
        self._studioRaidLevelOverride[player] = nil
        clearPlayerWindows(player)
        player:SetAttribute("RaidProtected", true)
        player:SetAttribute("RaidProtectionReason", "Защита новичка активна.")
        player:SetAttribute("RaidProtectionSeconds", NEWCOMER_PROTECTION_SECONDS)
        player.CharacterAdded:Connect(function(character)
            task.delay(0.25, function()
                local pendingReturn = self._pendingReturns[player]
                if pendingReturn and character.Parent and player.Parent == Players then
                    character:PivotTo(pendingReturn)
                    self._pendingReturns[player] = nil
                end
            end)
        end)
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        local incoming = self._pendingByTarget[player]
        if incoming then clearPending(self, incoming, "Соперник покинул сервер. Вызов отменён.") end
        local outgoing = self._pendingByAttacker[player]
        if outgoing then clearPending(self, outgoing, "Соперник покинул сервер. Вызов отменён.") end
        local match = self._matches[player]
        if match then clearMatch(self, match, "Соперник покинул сервер. Подтверждённый вызов отменён.") end
        self._joinedAt[player] = nil
        self._studioRaidLevelOverride[player] = nil
        self._lastRequest[player] = nil
        self._lastChallengeAt[player] = nil
        self._pendingReturns[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
    return true
end

function RaidService:Start()
    while true do
        task.wait(5)
        self:CleanupExpired()
        for _, player in ipairs(Players:GetPlayers()) do
            local protected, reason, remaining = self:GetProtection(player)
            player:SetAttribute("RaidProtected", protected)
            player:SetAttribute("RaidProtectionReason", reason)
            player:SetAttribute("RaidProtectionSeconds", remaining)
            local attackReady = isWindowOpen(player, "RaidAttackUntil")
            local defenseOpen = isWindowOpen(player, "RaidDefenseUntil")
            player:SetAttribute("RaidAttackReady", attackReady)
            player:SetAttribute("RaidDefenseOpen", defenseOpen)
        end
    end
end

return RaidService
