local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local IslandVisitService = require(ServerScriptService.Server.Services.IslandVisitService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)

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

    makeArenaPart(model, "CorePedestal", Vector3.new(2, 16, 16),
        center + Vector3.new(0, 2, 0), Color3.fromRGB(111, 86, 66), Enum.Material.Slate, Enum.PartType.Cylinder)
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

    match.ArenaModel = model
    match.CorePart = core
    match.CoreLabel = label
    match.CorePosition = core.Position
    match.ArenaCenter = center
    return model
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
    for _, participant in ipairs({ match.Attacker, match.Defender }) do
        if participant and participant.Parent == Players then
            participant:SetAttribute("RaidArenaCoreHealth", match.CoreHealth)
            participant:SetAttribute("RaidArenaTimeRemaining", remaining)
        end
    end
    if match.CoreLabel and match.CoreLabel.Parent then
        match.CoreLabel.Text = string.format("ЯДРО ГНЕЗДА · %d / %d", match.CoreHealth, RAID_CORE_MAX_HEALTH)
    end
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
    restoreParticipant(self, attacker, match)
    restoreParticipant(self, defender, match)
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
    match.State = "ACTIVE"
    match.CoreHealth = RAID_CORE_MAX_HEALTH
    match.ExpiresAt = now() + RAID_DURATION_SECONDS
    match.LastAttackAt = {}
    match.LastRepairAt = {}

    attackerCharacter:PivotTo(CFrame.lookAt(match.ArenaCenter + Vector3.new(-34, 5, 0), match.ArenaCenter + Vector3.new(0, 5, 0)))
    defenderCharacter:PivotTo(CFrame.lookAt(match.ArenaCenter + Vector3.new(34, 5, 0), match.ArenaCenter + Vector3.new(0, 5, 0)))

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

    publishArenaState(match)
    match.Attacker:SetAttribute("LastNotice", "Рейд начался! Доберись до ядра и разрушь его.")
    match.Defender:SetAttribute("LastNotice", "Рейд начался! Защищай ядро и восстанавливай его.")
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
