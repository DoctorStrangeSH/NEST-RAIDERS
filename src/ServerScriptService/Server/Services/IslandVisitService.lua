local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlotService = require(ServerScriptService.Server.Services.PlotService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local IslandVisitService = {}
IslandVisitService._lastRequest = {}
IslandVisitService._returnCFrames = {}
IslandVisitService._visitingPlot = {}
IslandVisitService._visitingOwner = {}
local COOLDOWN = 1
local MAX_VISITORS_PER_PLOT = 8

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

    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < COOLDOWN then
        return { Ok=false, Message="Подожди немного перед следующим действием." }
    end
    self._lastRequest[player] = now

    if payload.Action == "Visit" then return self:Visit(player, payload.PlotId) end
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
    Players.PlayerRemoving:Connect(function(player)
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
