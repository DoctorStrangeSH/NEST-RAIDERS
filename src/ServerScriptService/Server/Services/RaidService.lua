local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local IslandVisitService = require(ServerScriptService.Server.Services.IslandVisitService)

local RaidService = {}
RaidService._joinedAt = {}
RaidService._lastRequest = {}
RaidService._lastChallengeAt = {}
RaidService._pendingByTarget = {}
RaidService._pendingByAttacker = {}
RaidService._matches = {}

local MINIMUM_LEVEL = 5
local NEWCOMER_PROTECTION_SECONDS = 15 * 60
local OPT_IN_WINDOW_SECONDS = 10 * 60
local CHALLENGE_TIMEOUT_SECONDS = 45
local MATCH_READY_TIMEOUT_SECONDS = 120
local CHALLENGE_COOLDOWN_SECONDS = 30
local REQUEST_COOLDOWN_SECONDS = 0.25
local MAX_TARGETS = 20

local function now()
    return os.time()
end

local function getLevel(player)
    return math.clamp(math.floor(tonumber(player:GetAttribute("Level")) or 1), 1, 100)
end

local function isWindowOpen(player, attribute)
    local expiresAt = tonumber(player:GetAttribute(attribute)) or 0
    return expiresAt > now(), math.max(0, expiresAt - now())
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
    for _, participant in ipairs({ attacker, defender }) do
        if participant and participant.Parent == Players then
            participant:SetAttribute("RaidMatchId", nil)
            participant:SetAttribute("RaidMatchOpponent", nil)
            participant:SetAttribute("RaidMatchRole", nil)
            participant:SetAttribute("RaidMatchState", nil)
            if message then participant:SetAttribute("LastNotice", message) end
        end
    end
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
        if match.ExpiresAt <= timestamp
            or not match.Attacker or match.Attacker.Parent ~= Players
            or not match.Defender or match.Defender.Parent ~= Players then
            clearMatch(self, match, "Готовность к рейду завершилась. Можно создать новый вызов.")
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
    attacker:SetAttribute("LastNotice", "Соперник подтвердил вызов. Следующий этап откроет саму арену.")
    player:SetAttribute("LastNotice", "Ты подтвердил вызов. Следующий этап откроет саму рейдовую арену.")
    return { Ok = true, Message = "Вызов принят! Оба игрока готовы к рейду." }
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
    clearMatch(self, match, "Подтверждённый вызов отменён одним из игроков.")
    return { Ok = true, Message = "Вызов отменён. Твоё гнездо в безопасности." }
end

function RaidService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос рейда." }
    end
    if not player:GetAttribute("ProfileLoaded") or not PlayerDataService:GetProfile(player) then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    local timestamp = os.clock()
    if timestamp - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN_SECONDS then
        return { Ok = false, Message = "Подожди немного перед следующим действием." }
    end
    self._lastRequest[player] = timestamp

    if payload.Action == "Get" then return self:GetSnapshot(player) end
    if payload.Action == "SetAttackReady" then return self:SetAttackReady(player, payload.Enabled) end
    if payload.Action == "SetDefenseOpen" then return self:SetDefenseOpen(player, payload.Enabled) end
    if payload.Action == "Challenge" then return self:Challenge(player, payload.TargetUserId) end
    if payload.Action == "Accept" then return self:AcceptChallenge(player) end
    if payload.Action == "Decline" then return self:DeclineChallenge(player) end
    if payload.Action == "CancelChallenge" then return self:CancelChallenge(player) end
    if payload.Action == "CancelMatch" then return self:CancelMatch(player) end
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
        clearPlayerWindows(player)
        player:SetAttribute("RaidProtected", true)
        player:SetAttribute("RaidProtectionReason", "Защита новичка активна.")
        player:SetAttribute("RaidProtectionSeconds", NEWCOMER_PROTECTION_SECONDS)
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
        self._lastRequest[player] = nil
        self._lastChallengeAt[player] = nil
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
