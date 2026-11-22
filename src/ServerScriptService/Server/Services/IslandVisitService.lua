local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlotService = require(ServerScriptService.Server.Services.PlotService)

local IslandVisitService = {}
IslandVisitService._lastRequest = {}
IslandVisitService._returnCFrames = {}
IslandVisitService._visitingPlot = {}
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
    for _, plot in pairs(PlotService._plots) do
        local owner = getOwner(plot)
        if owner and owner ~= player and owner:GetAttribute("ProfileLoaded") then
            table.insert(entries, {
                PlotId = plot.Id,
                DisplayName = owner.DisplayName,
                Level = math.clamp(math.floor(tonumber(owner:GetAttribute("Level")) or 1), 1, 100),
                Visitors = countVisitors(plot.Id),
                Capacity = MAX_VISITORS_PER_PLOT,
            })
        end
    end
    table.sort(entries, function(a,b)
        if a.Visitors == b.Visitors then return a.DisplayName:lower() < b.DisplayName:lower() end
        return a.Visitors > b.Visitors
    end)
    return { Ok = true, Islands = entries, Visiting = self._visitingPlot[player] ~= nil }
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
    if oldPlotId then
        local oldPlot = PlotService._plots[oldPlotId]
        if oldPlot then oldPlot.Model:SetAttribute("VisitorCount", countVisitors(oldPlotId)) end
    end
    self._visitingPlot[player] = nil
    self._returnCFrames[player] = nil
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
    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < COOLDOWN then
        return { Ok=false, Message="Подожди немного перед следующим переходом." }
    end
    self._lastRequest[player] = now

    if payload.Action == "List" then return self:List(player) end
    if payload.Action == "Visit" then return self:Visit(player, payload.PlotId) end
    if payload.Action == "Return" then return self:Return(player) end
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
        if plotId then
            local plot = PlotService._plots[plotId]
            if plot then plot.Model:SetAttribute("VisitorCount", math.max(0, countVisitors(plotId)-1)) end
        end
        self._visitingPlot[player] = nil
        self._returnCFrames[player] = nil
        self._lastRequest[player] = nil
    end)
    Players.PlayerRemoving:Connect(function(owner)
        for visitor, plotId in pairs(self._visitingPlot) do
            local plot = PlotService._plots[plotId]
            if plot and getOwner(plot) == owner then
                self:Return(visitor)
            end
        end
    end)
end

return IslandVisitService
