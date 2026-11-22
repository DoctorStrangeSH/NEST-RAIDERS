local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local PlotService = require(ServerScriptService.Server.Services.PlotService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local IslandVisitService = {}
IslandVisitService._lastRequest = {}
IslandVisitService._returnCFrames = {}
IslandVisitService._visitingPlot = {}
IslandVisitService._visitingOwner = {}
IslandVisitService._directory = nil
IslandVisitService._directoryReady = false
IslandVisitService._lastDirectoryRefresh = 0
IslandVisitService._pendingArrivals = {}
local COOLDOWN = 1
local MAX_VISITORS_PER_PLOT = 8
local DIRECTORY_REFRESH_SECONDS = 30
local DIRECTORY_ENTRY_TTL = 100
local DIRECTORY_LIMIT = 50
local ARRIVAL_TIMEOUT_SECONDS = 45

local function getRoot(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getOwner(plot)
    local userId = plot.Model:GetAttribute("OwnerUserId")
    if type(userId) ~= "number" then return nil end
    return Players:GetPlayerByUserId(userId)
end

local function countVisitors(plotId)
    local count = 0
    for _, destination in pairs(IslandVisitService._visitingPlot) do
        if destination == plotId then count += 1 end
    end
    return count
end

local function ensureSocial(profile)
    profile.Nest = profile.Nest or {}
    profile.Nest.IslandLikesByUserId = profile.Nest.IslandLikesByUserId or {}
    profile.Nest.FavoriteIslandUserIds = profile.Nest.FavoriteIslandUserIds or {}
    return profile.Nest
end

local function countLikes(likes)
    local count = 0
    for _, liked in pairs(likes) do
        if liked == true then count += 1 end
    end
    return count
end

local function isFavorite(favorites, userId)
    return favorites[tostring(userId)] == true
end

local function moveCharacter(player, target)
    local root = getRoot(player)
    if not root or not player.Character then return false end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    player.Character:PivotTo(target)
    return true
end

local function getDirectory()
    if not IslandVisitService._directory then
        IslandVisitService._directory = MemoryStoreService:GetSortedMap("NRAidLiveIslands_v1")
    end
    return IslandVisitService._directory
end

local function isDirectoryAvailable()
    return not RunService:IsStudio()
end

function IslandVisitService:PublishDirectory()
    if not isDirectoryAvailable() or not self._directoryReady then return end
    local directory = getDirectory()
    for _, plot in pairs(PlotService._plots) do
        local owner = getOwner(plot)
        if owner and owner:GetAttribute("ProfileLoaded") then
            local value = {
                UserId = owner.UserId,
                DisplayName = owner.DisplayName,
                Level = math.clamp(math.floor(tonumber(owner:GetAttribute("Level")) or 1), 1, 100),
                PlotId = plot.Id,
                JobId = game.JobId,
                PlaceId = game.PlaceId,
                Visitors = countVisitors(plot.Id),
                Capacity = MAX_VISITORS_PER_PLOT,
                Likes = math.max(0, math.floor(tonumber(plot.Model:GetAttribute("IslandLikes")) or 0)),
                UpdatedAt = os.time(),
            }
            local ok, err = pcall(function()
                directory:SetAsync(tostring(owner.UserId), value, DIRECTORY_ENTRY_TTL, value.UpdatedAt)
            end)
            if not ok then
                warn("[NEST RAIDERS] Live island directory publish failed:", err)
            end
        end
    end
end

function IslandVisitService:ListGlobal(player)
    local response = self:List(player)
    if not response.Ok then return response end
    if not isDirectoryAvailable() then
        response.DirectoryStatus = "StudioLocalOnly"
        return response
    end

    local ok, entries = pcall(function()
        return getDirectory():GetRangeAsync(Enum.SortDirection.Descending, DIRECTORY_LIMIT)
    end)
    if not ok then
        warn("[NEST RAIDERS] Live island directory read failed:", entries)
        response.DirectoryStatus = "Unavailable"
        response.DirectoryMessage = "Глобальный каталог временно недоступен. Показаны острова этого сервера."
        return response
    end

    local viewerProfile = PlayerDataService:GetProfile(player)
    local viewerNest = viewerProfile and ensureSocial(viewerProfile) or { FavoriteIslandUserIds = {} }
    local byUserId = {}
    for _, island in ipairs(response.Islands or {}) do
        island.IsLocal = true
        island.JobId = game.JobId
        island.PlaceId = game.PlaceId
        byUserId[tostring(island.UserId)] = island
    end

    for _, item in ipairs(entries) do
        local value = item.value
        if type(value) == "table" and type(value.UserId) == "number"
            and value.UserId ~= player.UserId and type(value.JobId) == "string"
            and type(value.PlaceId) == "number" and type(value.PlotId) == "string" then
            local key = tostring(value.UserId)
            if not byUserId[key] then
                byUserId[key] = {
                    UserId = value.UserId,
                    DisplayName = tostring(value.DisplayName or ("Игрок " .. key)),
                    Level = math.clamp(math.floor(tonumber(value.Level) or 1), 1, 100),
                    PlotId = value.PlotId,
                    JobId = value.JobId,
                    PlaceId = value.PlaceId,
                    Visitors = math.max(0, math.floor(tonumber(value.Visitors) or 0)),
                    Capacity = MAX_VISITORS_PER_PLOT,
                    Likes = math.max(0, math.floor(tonumber(value.Likes) or 0)),
                    IsLikedByMe = false,
                    IsFavoriteByMe = isFavorite(viewerNest.FavoriteIslandUserIds, value.UserId),
                    IsLocal = value.JobId == game.JobId,
                }
            end
        end
    end

    local merged = {}
    for _, island in pairs(byUserId) do table.insert(merged, island) end
    table.sort(merged, function(a, b)
        if a.Likes ~= b.Likes then return a.Likes > b.Likes end
        if a.Visitors ~= b.Visitors then return a.Visitors > b.Visitors end
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    response.Islands = merged
    response.DirectoryStatus = "Available"
    return response
end

function IslandVisitService:VisitGlobal(player, targetUserId, jobId, placeId)
    if type(targetUserId) ~= "number" or targetUserId <= 0 or targetUserId == player.UserId
        or type(jobId) ~= "string" or #jobId < 8 or type(placeId) ~= "number" then
        return { Ok=false, Message="Некорректный адрес острова." }
    end

    if jobId == game.JobId then
        local targetPlot
        for _, plot in pairs(PlotService._plots) do
            local owner = getOwner(plot)
            if owner and owner.UserId == targetUserId then targetPlot = plot break end
        end
        if not targetPlot then return { Ok=false, Message="Остров больше недоступен." } end
        return self:Visit(player, targetPlot.Id)
    end

    if not isDirectoryAvailable() then
        return { Ok=false, Message="Переход между серверами проверяется только в опубликованной игре." }
    end
    local ok, entry = pcall(function()
        return getDirectory():GetAsync(tostring(targetUserId))
    end)
    if not ok or type(entry) ~= "table" or entry.JobId ~= jobId
        or entry.PlaceId ~= placeId or entry.UserId ~= targetUserId then
        return { Ok=false, Message="Этот остров уже покинул каталог. Обнови список." }
    end
    if (tonumber(entry.Visitors) or 0) >= MAX_VISITORS_PER_PLOT then
        return { Ok=false, Message="На острове сейчас слишком много гостей." }
    end

    local teleportData = {
        VisitIsland = true,
        TargetUserId = targetUserId,
        TargetPlotId = entry.PlotId,
    }
    local teleportOk, teleportErr = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player, nil, teleportData)
    end)
    if not teleportOk then
        warn("[NEST RAIDERS] Cross-server island teleport failed:", teleportErr)
        return { Ok=false, Message="Не удалось перейти на другой сервер. Попробуй ещё раз." }
    end
    return { Ok=true, Message="Переносим тебя на остров игрока " .. tostring(entry.DisplayName or "—") .. "..." }
end

function IslandVisitService:HandleArrival(player)
    local joinData
    local ok, result = pcall(function() return player:GetJoinData() end)
    if ok then joinData = result end
    local teleportData = joinData and joinData.TeleportData
    if type(teleportData) ~= "table" or teleportData.VisitIsland ~= true
        or type(teleportData.TargetUserId) ~= "number" then
        return
    end

    task.spawn(function()
        local deadline = os.clock() + ARRIVAL_TIMEOUT_SECONDS
        while player.Parent and os.clock() < deadline do
            if player:GetAttribute("ProfileLoaded") and PlotService:GetPlayerPlot(player) and getRoot(player) then
                local targetPlotId = teleportData.TargetPlotId
                local targetPlot = type(targetPlotId) == "string" and PlotService._plots[targetPlotId] or nil
                local owner = targetPlot and getOwner(targetPlot)
                if owner and owner.UserId == teleportData.TargetUserId then
                    local result = self:Visit(player, targetPlotId)
                    if not result.Ok then
                        player:SetAttribute("LastNotice", result.Message or "Остров больше недоступен.")
                    end
                else
                    player:SetAttribute("LastNotice", "Игрок покинул остров до твоего прибытия.")
                end
                return
            end
            task.wait(0.5)
        end
        if player.Parent then
            player:SetAttribute("LastNotice", "Не удалось загрузить остров. Ты остался в своём гнезде.")
        end
    end)
end

function IslandVisitService:List(player)
    local entries = {}
    local viewerProfile = PlayerDataService:GetProfile(player)
    if not viewerProfile then return { Ok=false, Message="Профиль ещё загружается." } end
    local viewerNest = ensureSocial(viewerProfile)

    for _, plot in pairs(PlotService._plots) do
        local owner = getOwner(plot)
        if owner and owner ~= player and owner:GetAttribute("ProfileLoaded") then
            local ownerProfile = PlayerDataService:GetProfile(owner)
            local ownerNest = ownerProfile and ensureSocial(ownerProfile)
            local likes = ownerNest and ownerNest.IslandLikesByUserId or {}
            table.insert(entries, {
                PlotId = plot.Id,
                UserId = owner.UserId,
                DisplayName = owner.DisplayName,
                Level = math.clamp(math.floor(tonumber(owner:GetAttribute("Level")) or 1), 1, 100),
                Visitors = countVisitors(plot.Id),
                Capacity = MAX_VISITORS_PER_PLOT,
                Likes = countLikes(likes),
                IsLikedByMe = likes[tostring(player.UserId)] == true,
                IsFavoriteByMe = isFavorite(viewerNest.FavoriteIslandUserIds, owner.UserId),
            })
        end
    end
    table.sort(entries, function(a,b)
        if a.Likes ~= b.Likes then return a.Likes > b.Likes end
        if a.Visitors ~= b.Visitors then return a.Visitors > b.Visitors end
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    return { Ok = true, Islands = entries, Visiting = self._visitingPlot[player] ~= nil }
end

function IslandVisitService:ToggleLike(player, targetUserId)
    if type(targetUserId) ~= "number" or targetUserId <= 0 or targetUserId == player.UserId then
        return { Ok=false, Message="Нельзя поставить отметку этому острову." }
    end
    local owner = Players:GetPlayerByUserId(targetUserId)
    if not owner or not owner:GetAttribute("ProfileLoaded") then
        return { Ok=false, Message="Владелец острова больше недоступен." }
    end
    local targetPlot = PlotService:GetPlayerPlot(owner)
    if not targetPlot then return { Ok=false, Message="Остров сейчас недоступен." } end

    local ownerProfile = PlayerDataService:GetProfile(owner)
    if not ownerProfile then return { Ok=false, Message="Профиль владельца недоступен." } end
    local ownerNest = ensureSocial(ownerProfile)
    local key = tostring(player.UserId)
    ownerNest.IslandLikesByUserId[key] = not (ownerNest.IslandLikesByUserId[key] == true)
    local liked = ownerNest.IslandLikesByUserId[key]
    targetPlot.Model:SetAttribute("IslandLikes", countLikes(ownerNest.IslandLikesByUserId))
    return { Ok=true, Liked=liked, Likes=countLikes(ownerNest.IslandLikesByUserId), Message=liked and "Остров добавлен в понравившиеся!" or "Отметка «Нравится» снята." }
end

function IslandVisitService:ToggleFavorite(player, targetUserId)
    if type(targetUserId) ~= "number" or targetUserId <= 0 or targetUserId == player.UserId then
        return { Ok=false, Message="Нельзя добавить этот остров в избранное." }
    end
    local owner = Players:GetPlayerByUserId(targetUserId)
    if not owner or not owner:GetAttribute("ProfileLoaded") or not PlotService:GetPlayerPlot(owner) then
        return { Ok=false, Message="Остров сейчас недоступен." }
    end
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return { Ok=false, Message="Профиль ещё загружается." } end
    local nest = ensureSocial(profile)
    local key = tostring(targetUserId)
    local isSaved = nest.FavoriteIslandUserIds[key] == true
    if not isSaved then
        local total = 0
        for _, saved in pairs(nest.FavoriteIslandUserIds) do
            if saved == true then total += 1 end
        end
        if total >= 30 then return { Ok=false, Message="В избранном уже 30 островов. Удали один, чтобы добавить новый." } end
    end
    nest.FavoriteIslandUserIds[key] = not isSaved
    local saved = nest.FavoriteIslandUserIds[key]
    return { Ok=true, Favorite=saved, Message=saved and "Остров добавлен в избранное." or "Остров удалён из избранного." }
end

function IslandVisitService:Return(player)
    local homePlot = PlotService:GetPlayerPlot(player)
    local target = self._returnCFrames[player]
    if not target and homePlot then
        target = CFrame.new(homePlot.Center + Vector3.new(0, 6, 12))
    end
    if not target then return { Ok=false, Message="Не удалось найти твоё гнездо." } end
    if not moveCharacter(player, target) then return { Ok=false, Message="Персонаж ещё не готов." } end
    local oldPlotId = self._visitingPlot[player]
    self._visitingPlot[player] = nil
    self._visitingOwner[player] = nil
    self._returnCFrames[player] = nil
    if oldPlotId then
        local oldPlot = PlotService._plots[oldPlotId]
        if oldPlot then oldPlot.Model:SetAttribute("VisitorCount", countVisitors(oldPlotId)) end
    end
    return { Ok=true, Message="Ты вернулся в своё гнездо." }
end

function IslandVisitService:Visit(player, plotId)
    if type(plotId) ~= "string" then return { Ok=false, Message="Неизвестное гнездо." } end
    local destination = PlotService._plots[plotId]
    local home = PlotService:GetPlayerPlot(player)
    if not destination or not home then return { Ok=false, Message="Остров больше недоступен." } end
    local owner = getOwner(destination)
    if not owner or owner == player or not owner:GetAttribute("ProfileLoaded") then
        return { Ok=false, Message="Владелец острова уже недоступен." }
    end
    if countVisitors(plotId) >= MAX_VISITORS_PER_PLOT then
        return { Ok=false, Message="На острове сейчас слишком много гостей." }
    end
    local root = getRoot(player)
    if not root then return { Ok=false, Message="Персонаж ещё не готов." } end

    local oldPlotId = self._visitingPlot[player]
    if oldPlotId then
        local oldPlot = PlotService._plots[oldPlotId]
        if oldPlot then oldPlot.Model:SetAttribute("VisitorCount", countVisitors(oldPlotId)-1) end
    else
        self._returnCFrames[player] = root.CFrame
    end

    local target = CFrame.new(destination.Center + Vector3.new(0, 6, 12))
    if not moveCharacter(player, target) then return { Ok=false, Message="Не удалось перейти на остров." } end
    self._visitingPlot[player] = plotId
    self._visitingOwner[player] = owner.UserId
    destination.Model:SetAttribute("VisitorCount", countVisitors(plotId))
    return { Ok=true, Message="Добро пожаловать на остров "..owner.DisplayName.."!" }
end

function IslandVisitService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok=false, Message="Некорректный запрос." }
    end
    if not player:GetAttribute("ProfileLoaded") then
        return { Ok=false, Message="Профиль ещё загружается." }
    end
    if payload.Action == "List" then return self:List(player) end
    if payload.Action == "ListGlobal" then return self:ListGlobal(player) end

    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < COOLDOWN then
        return { Ok=false, Message="Подожди немного перед следующим действием." }
    end
    self._lastRequest[player] = now

    if payload.Action == "Visit" then return self:Visit(player, payload.PlotId) end
    if payload.Action == "VisitGlobal" then
        return self:VisitGlobal(player, payload.UserId, payload.JobId, payload.PlaceId)
    end
    if payload.Action == "Return" then return self:Return(player) end
    if payload.Action == "Like" then return self:ToggleLike(player, payload.UserId) end
    if payload.Action == "Favorite" then return self:ToggleFavorite(player, payload.UserId) end
    return { Ok=false, Message="Неизвестное действие." }
end

function IslandVisitService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("IslandVisit")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "IslandVisit"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end
    self._directoryReady = true
    Players.PlayerAdded:Connect(function(player)
        self:HandleArrival(player)
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        self:HandleArrival(player)
    end
    task.spawn(function()
        while self._directoryReady do
            self:PublishDirectory()
            task.wait(DIRECTORY_REFRESH_SECONDS)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if isDirectoryAvailable() then
            local directory = getDirectory()
            local ok, entry = pcall(function()
                return directory:GetAsync(tostring(player.UserId))
            end)
            if ok and type(entry) == "table" and entry.JobId == game.JobId then
                pcall(function() directory:RemoveAsync(tostring(player.UserId)) end)
            end
        end
        local plotId = self._visitingPlot[player]
        self._visitingPlot[player] = nil
        self._visitingOwner[player] = nil
        if plotId then
            local plot = PlotService._plots[plotId]
            if plot then plot.Model:SetAttribute("VisitorCount", countVisitors(plotId)) end
        end
        self._returnCFrames[player] = nil
        self._lastRequest[player] = nil
    end)
    Players.PlayerRemoving:Connect(function(owner)
        for visitor, ownerUserId in pairs(self._visitingOwner) do
            if ownerUserId == owner.UserId and visitor.Parent then
                self:Return(visitor)
            end
        end
    end)
end

return IslandVisitService
