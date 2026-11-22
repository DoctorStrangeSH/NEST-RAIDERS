local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local IslandContestService = {}
IslandContestService._lastRequest = {}
IslandContestService._lastListRequest = {}
IslandContestService._standingsCache = {}
IslandContestService._studioVotes = {}
IslandContestService._studioScores = {}
IslandContestService._studioHistory = {}
IslandContestService._finalizedWeeks = {}

local COOLDOWN = 2
local LIST_COOLDOWN = 2
local STANDINGS_CACHE_SECONDS = 10
local MAX_RESULTS = 10
local HISTORY_LIMIT = 12
local HISTORY_REFRESH_SECONDS = 60
local CATEGORY_ORDER = { "Cozy", "Nature", "Fantasy" }
local PLACE_NAMES = { "Золото", "Серебро", "Бронза" }
local CATEGORIES = {
    Cozy = { Name = "Уют", Description = "Самый тёплый и гостеприимный остров." },
    Nature = { Name = "Природа", Description = "Лучший сад, лес и природный ландшафт." },
    Fantasy = { Name = "Фэнтези", Description = "Самый волшебный и необычный остров." },
}
local function weekKey(timestamp)
    return os.date("!%Y-W%W", timestamp or os.time())
end

local function studioFallback()
    return RunService:IsStudio() and not GameConfig.UseStudioDataStore
end

local function getPlotOwner(plot)
    local userId = plot.Model:GetAttribute("OwnerUserId")
    if type(userId) ~= "number" then return nil end
    return Players:GetPlayerByUserId(userId)
end

local function isValidCategory(category)
    return type(category) == "string" and CATEGORIES[category] ~= nil
end

local function getStores(category, selectedWeek)
    local week = selectedWeek or weekKey()
    local suffix = week .. "_" .. category
    return DataStoreService:GetDataStore("NRAidVotes_" .. suffix),
        DataStoreService:GetOrderedDataStore("NRAidContest_" .. suffix),
        DataStoreService:GetDataStore("NRAidScores_" .. suffix)
end

function IslandContestService:GetOnlineNominees(player)
    local nominees = {}
    for _, plot in pairs(PlotService._plots) do
        local owner = getPlotOwner(plot)
        if owner and owner ~= player and owner:GetAttribute("ProfileLoaded") then
            table.insert(nominees, {
                UserId = owner.UserId,
                DisplayName = owner.DisplayName,
                Level = math.clamp(math.floor(tonumber(owner:GetAttribute("Level")) or 1), 1, 100),
            })
        end
    end
    table.sort(nominees, function(a, b) return a.DisplayName:lower() < b.DisplayName:lower() end)
    return nominees
end

function IslandContestService:GetStandings(category)
    local week = weekKey()
    self._standingsCache[week] = self._standingsCache[week] or {}
    local cached = self._standingsCache[week][category]
    if cached and cached.ExpiresAt > os.clock() then
        return cached.Results
    end
    local results = {}
    if studioFallback() then
        local scores = self._studioScores[week] and self._studioScores[week][category] or {}
        for userId, score in pairs(scores or {}) do
            table.insert(results, { UserId = tonumber(userId), Votes = score })
        end
        table.sort(results, function(a, b)
            if a.Votes == b.Votes then return a.UserId < b.UserId end
            return a.Votes > b.Votes
        end)
        while #results > MAX_RESULTS do table.remove(results) end
    else
        local _, orderedStore = getStores(category)
        local ok, pages = pcall(function()
            return orderedStore:GetSortedAsync(false, MAX_RESULTS)
        end)
        if not ok then
            warn("[NEST RAIDERS] Contest leaderboard read failed:", pages)
            return nil, "Таблица конкурса временно недоступна."
        end
        for _, item in ipairs(pages:GetCurrentPage()) do
            table.insert(results, { UserId = tonumber(item.key), Votes = item.value })
        end
    end

    local userIds = {}
    for _, entry in ipairs(results) do table.insert(userIds, entry.UserId) end
    local names = {}
    if #userIds > 0 then
        local ok, infos = pcall(function()
            return UserService:GetUserInfosByUserIdsAsync(userIds)
        end)
        if ok then
            for _, info in ipairs(infos) do names[info.Id] = info.DisplayName or info.Username end
        end
    end
    for index, entry in ipairs(results) do
        entry.Rank = index
        entry.DisplayName = names[entry.UserId] or ("Игрок " .. tostring(entry.UserId))
    end
    self._standingsCache[week][category] = {
        Results = results,
        ExpiresAt = os.clock() + STANDINGS_CACHE_SECONDS,
    }
    return results
end

function IslandContestService:ApplyPersistentVote(category, targetUserId, voterUserId)
    local week = weekKey()
    local _, orderedStore, scoreStore = getStores(category)
    local scoreKey = "owner_" .. tostring(targetUserId)
    local ok, scoreRecord = pcall(function()
        return scoreStore:UpdateAsync(scoreKey, function(current)
            local nextRecord = type(current) == "table" and current or { Votes = 0, Voters = {} }
            nextRecord.Voters = type(nextRecord.Voters) == "table" and nextRecord.Voters or {}
            nextRecord.Votes = math.max(0, math.floor(tonumber(nextRecord.Votes) or 0))
            local voterKey = tostring(voterUserId)
            if not nextRecord.Voters[voterKey] then
                nextRecord.Voters[voterKey] = true
                nextRecord.Votes += 1
            end
            return nextRecord
        end)
    end)
    if not ok or type(scoreRecord) ~= "table" then
        warn("[NEST RAIDERS] Contest score record update failed:", scoreRecord)
        return false
    end
    local orderedOk, orderedErr = pcall(function()
        orderedStore:SetAsync(tostring(targetUserId), scoreRecord.Votes)
    end)
    if not orderedOk then
        warn("[NEST RAIDERS] Contest leaderboard projection failed:", orderedErr)
        return false
    end
    local weekScores = self._standingsCache[week]
    if weekScores then weekScores[category] = nil end
    return true
end

function IslandContestService:HasVoted(player, category)
    local week = weekKey()
    if studioFallback() then
        return self._studioVotes[week]
            and self._studioVotes[week][category]
            and self._studioVotes[week][category][tostring(player.UserId)] ~= nil
            or false
    end
    local voteStore = getStores(category)
    local ok, record = pcall(function()
        return voteStore:GetAsync("voter_" .. tostring(player.UserId))
    end)
    if not ok then
        warn("[NEST RAIDERS] Contest vote status read failed:", record)
        return nil
    end
    if type(record) == "table" and type(record.TargetUserId) == "number" then
        if not self:ApplyPersistentVote(category, record.TargetUserId, player.UserId) then
            return nil
        end
        return true
    end
    return record ~= nil
end

local function getArchiveStore()
    return DataStoreService:GetDataStore("NRAidHallOfFame_v1")
end

local function archiveKey(week)
    return "week_" .. week
end

local function isClaimed(profile, week, category)
    local trophies = profile.Nest and profile.Nest.IslandTrophies
    return type(trophies) == "table" and trophies[week .. "_" .. category] ~= nil
end

function IslandContestService:BuildWeekArchive(week)
    local archive = { Week = week, Categories = {} }
    for _, category in ipairs(CATEGORY_ORDER) do
        local entries = {}
        if studioFallback() then
            local scores = self._studioScores[week] and self._studioScores[week][category] or {}
            for userId, votes in pairs(scores) do
                table.insert(entries, { UserId = tonumber(userId), Votes = votes })
            end
            table.sort(entries, function(a, b)
                if a.Votes == b.Votes then return a.UserId < b.UserId end
                return a.Votes > b.Votes
            end)
        else
            local _, orderedStore = getStores(category, week)
            local ok, pages = pcall(function()
                return orderedStore:GetSortedAsync(false, 3)
            end)
            if not ok then
                warn("[NEST RAIDERS] Previous contest standings unavailable:", pages)
                return nil
            end
            for _, item in ipairs(pages:GetCurrentPage()) do
                table.insert(entries, { UserId = tonumber(item.key), Votes = item.value })
            end
        end

        local ids = {}
        for _, entry in ipairs(entries) do table.insert(ids, entry.UserId) end
        local names = {}
        if #ids > 0 then
            local ok, infos = pcall(function()
                return UserService:GetUserInfosByUserIdsAsync(ids)
            end)
            if ok then
                for _, info in ipairs(infos) do
                    names[info.Id] = info.DisplayName or info.Username
                end
            end
        end

        local winners = {}
        for place, entry in ipairs(entries) do
            if place > 3 then break end
            table.insert(winners, {
                UserId = entry.UserId,
                DisplayName = names[entry.UserId] or ("Игрок " .. tostring(entry.UserId)),
                Votes = entry.Votes,
                Place = place,
            })
        end
        archive.Categories[category] = winners
    end
    return archive
end

function IslandContestService:FinalizePreviousWeek()
    local previousWeek = weekKey(os.time() - 7 * 24 * 60 * 60)
    if self._finalizedWeeks[previousWeek] then return true end
    if studioFallback() then
        self._studioHistory = self._studioHistory or {}
        if not self._studioHistory[previousWeek] then
            self._studioHistory[previousWeek] = self:BuildWeekArchive(previousWeek)
        end
        self._finalizedWeeks[previousWeek] = true
        return true
    end

    local archive = self:BuildWeekArchive(previousWeek)
    if not archive then return false end
    local store = getArchiveStore()
    local ok, err = pcall(function()
        store:UpdateAsync("history", function(current)
            local history = type(current) == "table" and current or {}
            for _, item in ipairs(history) do
                if item.Week == previousWeek then return history end
            end
            table.insert(history, 1, archive)
            while #history > HISTORY_LIMIT do table.remove(history) end
            return history
        end)
    end)
    if not ok then
        warn("[NEST RAIDERS] Hall of Fame archive failed:", err)
        return false
    end
    self._finalizedWeeks[previousWeek] = true
    return true
end

function IslandContestService:GetHistory(player)
    if studioFallback() then
        local history = {}
        for _, archive in pairs(self._studioHistory) do table.insert(history, archive) end
        table.sort(history, function(a, b) return a.Week > b.Week end)
        return history
    end
    local ok, history = pcall(function()
        return getArchiveStore():GetAsync("history")
    end)
    if not ok then
        warn("[NEST RAIDERS] Hall of Fame history read failed:", history)
        return nil
    end
    return type(history) == "table" and history or {}
end

function IslandContestService:ClaimTrophy(player, week, category)
    if type(week) ~= "string" or #week > 16 or not isValidCategory(category) then
        return { Ok=false, Message="Некорректная награда." }
    end
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return { Ok=false, Message="Профиль ещё загружается." } end
    profile.Nest = profile.Nest or {}
    profile.Nest.IslandTrophies = profile.Nest.IslandTrophies or {}
    local key = week .. "_" .. category
    if profile.Nest.IslandTrophies[key] then
        return { Ok=false, Message="Эта награда уже находится в твоём гнезде." }
    end

    local history = self:GetHistory(player)
    if not history then
        return { Ok=false, Message="Зал славы временно недоступен. Попробуй позже." }
    end
    local archive
    for _, item in ipairs(history) do
        if item.Week == week then archive = item break end
    end
    local winners = archive and archive.Categories and archive.Categories[category]
    local place
    for _, winner in ipairs(winners or {}) do
        if winner.UserId == player.UserId then place = winner.Place break end
    end
    if not place or place < 1 or place > 3 then
        return { Ok=false, Message="Для этого профиля нет доступной награды." }
    end

    profile.Nest.IslandTrophies[key] = {
        Week = week,
        Category = category,
        Place = place,
        ClaimedAt = os.time(),
    }
    if PlotService.ApplyContestTrophies then
        PlotService:ApplyContestTrophies(player)
    end
    return {
        Ok = true,
        Message = "Награда «" .. PLACE_NAMES[place] .. "» установлена в твоём гнезде!",
    }
end

function IslandContestService:List(player)
    local now = os.clock()
    local lastListRequest = self._lastListRequest[player]
    if lastListRequest and now - lastListRequest < LIST_COOLDOWN then
        return { Ok=false, Message="Список конкурса обновляется слишком часто. Подожди пару секунд." }
    end
    self._lastListRequest[player] = now
    self:FinalizePreviousWeek()
    local history = self:GetHistory(player)
    if not history then
        return { Ok=false, Message="Зал славы временно недоступен. Попробуй обновить список позже." }
    end
    local categories = {}
    for category, definition in pairs(CATEGORIES) do
        local hasVoted = self:HasVoted(player, category)
        if hasVoted == nil then
            return { Ok=false, Message="Не удалось проверить твой голос. Попробуй позже." }
        end
        local standings, err = self:GetStandings(category)
        if not standings then return { Ok=false, Message=err } end
        table.insert(categories, {
            Id = category,
            Name = definition.Name,
            Description = definition.Description,
            Standings = standings,
            HasVoted = hasVoted,
        })
    end
    table.sort(categories, function(a, b) return a.Id < b.Id end)
    return {
        Ok = true,
        Week = weekKey(),
        Categories = categories,
        Nominees = self:GetOnlineNominees(player),
        IsLocalTest = studioFallback(),
        History = history,
        ClaimedTrophies = PlayerDataService:GetProfile(player).Nest
            and PlayerDataService:GetProfile(player).Nest.IslandTrophies or {},
    }
end

function IslandContestService:Vote(player, category, targetUserId)
    if not isValidCategory(category) then
        return { Ok=false, Message="Выбери одну из доступных номинаций." }
    end
    if type(targetUserId) ~= "number" or targetUserId <= 0 or targetUserId == player.UserId then
        return { Ok=false, Message="Нельзя голосовать за собственный остров." }
    end
    local owner = Players:GetPlayerByUserId(targetUserId)
    if not owner or not owner:GetAttribute("ProfileLoaded") or not PlotService:GetPlayerPlot(owner) then
        return { Ok=false, Message="Этот остров больше недоступен для голосования." }
    end

    local week = weekKey()
    if studioFallback() then
        self._studioVotes[week] = self._studioVotes[week] or {}
        self._studioVotes[week][category] = self._studioVotes[week][category] or {}
        local voterKey = tostring(player.UserId)
        if self._studioVotes[week][category][voterKey] then
            return { Ok=false, Message="В этой номинации ты уже голосовал на этой неделе." }
        end
        self._studioVotes[week][category][voterKey] = targetUserId
        self._studioScores[week] = self._studioScores[week] or {}
        self._studioScores[week][category] = self._studioScores[week][category] or {}
        local scores = self._studioScores[week][category]
        scores[tostring(targetUserId)] = (scores[tostring(targetUserId)] or 0) + 1
    else
        local voteStore = getStores(category)
        local token = HttpService:GenerateGUID(false)
        local ok, record = pcall(function()
            return voteStore:UpdateAsync("voter_" .. tostring(player.UserId), function(current)
                if current ~= nil then return current end
                return { TargetUserId = targetUserId, Token = token, VotedAt = os.time() }
            end)
        end)
        if not ok then
            warn("[NEST RAIDERS] Contest vote save failed:", record)
            return { Ok=false, Message="Не удалось сохранить голос. Попробуй позже." }
        end
        if type(record) ~= "table" or record.Token ~= token then
            return { Ok=false, Message="В этой номинации ты уже голосовал на этой неделе." }
        end
        if not self:ApplyPersistentVote(category, targetUserId, player.UserId) then
            return { Ok=true, Message="Голос сохранён. Таблица результатов обновится после повторной синхронизации." }
        end
    end

    local weekScores = self._standingsCache[week]
    if weekScores then weekScores[category] = nil end
    return { Ok=true, Message="Голос принят! Спасибо за участие в конкурсе." }
end

function IslandContestService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok=false, Message="Некорректный запрос." }
    end
    if not player:GetAttribute("ProfileLoaded") then
        return { Ok=false, Message="Профиль ещё загружается." }
    end
    if payload.Action == "List" then return self:List(player) end
    local now = os.clock()
    local lastRequest = self._lastRequest[player]
    if lastRequest and now - lastRequest < COOLDOWN then
        return { Ok=false, Message="Подожди немного перед следующим действием." }
    end
    self._lastRequest[player] = now
    if payload.Action == "Vote" then
        return self:Vote(player, payload.Category, payload.UserId)
    end
    if payload.Action == "ClaimTrophy" then
        return self:ClaimTrophy(player, payload.Week, payload.Category)
    end
    return { Ok=false, Message="Неизвестное действие." }
end

function IslandContestService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("IslandContest")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "IslandContest"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end
    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
        self._lastListRequest[player] = nil
    end)
end

return IslandContestService
