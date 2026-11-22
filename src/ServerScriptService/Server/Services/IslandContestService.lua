local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")
local HttpService = game:GetService("HttpService")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local PlotService = require(ServerScriptService.Server.Services.PlotService)

local IslandContestService = {}
IslandContestService._lastRequest = {}
IslandContestService._studioVotes = {}
IslandContestService._studioScores = {}

local COOLDOWN = 2
local MAX_RESULTS = 10
local CATEGORIES = {
    Cozy = { Name = "Уют", Description = "Самый тёплый и гостеприимный остров." },
    Nature = { Name = "Природа", Description = "Лучший сад, лес и природный ландшафт." },
    Fantasy = { Name = "Фэнтези", Description = "Самый волшебный и необычный остров." },
}
local function weekKey()
    return os.date("!%Y-W%W", os.time())
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

local function getStores(category)
    local week = weekKey()
    local suffix = week .. "_" .. category
    return DataStoreService:GetDataStore("NRAidVotes_" .. suffix),
        DataStoreService:GetOrderedDataStore("NRAidContest_" .. suffix)
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
    return results
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
    return record ~= nil
end

function IslandContestService:List(player)
    local categories = {}
    for category, definition in pairs(CATEGORIES) do
        local standings, err = self:GetStandings(category)
        if not standings then return { Ok=false, Message=err } end
        local hasVoted = self:HasVoted(player, category)
        if hasVoted == nil then
            return { Ok=false, Message="Не удалось проверить твой голос. Попробуй позже." }
        end
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
        local voteStore, scoreStore = getStores(category)
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
        local scoreOk, scoreErr = pcall(function()
            scoreStore:IncrementAsync(tostring(targetUserId), 1)
        end)
        if not scoreOk then
            warn("[NEST RAIDERS] Contest score update failed:", scoreErr)
            return { Ok=false, Message="Голос принят, но таблица обновится с задержкой. Не голосуй повторно." }
        end
    end

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
    if now - (self._lastRequest[player] or 0) < COOLDOWN then
        return { Ok=false, Message="Подожди немного перед следующим действием." }
    end
    self._lastRequest[player] = now
    if payload.Action == "Vote" then
        return self:Vote(player, payload.Category, payload.UserId)
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
    end)
end

return IslandContestService
