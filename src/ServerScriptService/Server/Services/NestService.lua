local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)

local NestService = {}
NestService._lastRequest = {}
local MAX_LEVEL = 5
local REQUEST_COOLDOWN = 0.5
local UPGRADE_COSTS = { 250, 750, 2000, 5000 }
local DISPLAY_SLOTS = { 0, 1, 2, 3, 4 }

local function getSnapshot(profile)
    local level = math.clamp(math.floor(tonumber(profile.Nest and profile.Nest.Level) or 1), 1, MAX_LEVEL)
    return {
        Level = level,
        MaxLevel = MAX_LEVEL,
        Coins = profile.Coins,
        NextCost = level < MAX_LEVEL and UPGRADE_COSTS[level] or nil,
        DisplaySlots = DISPLAY_SLOTS[level],
        IsMaxLevel = level >= MAX_LEVEL,
    }
end

function NestService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос." }
    end
    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then
        return { Ok = false, Message = "Подожди немного." }
    end
    self._lastRequest[player] = now

    local profile = PlayerDataService:GetProfile(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    profile.Nest = profile.Nest or { Level = 1, PlotId = nil }
    profile.Nest.Level = math.clamp(math.floor(tonumber(profile.Nest.Level) or 1), 1, MAX_LEVEL)

    if payload.Action == "Get" then
        return { Ok = true, Data = getSnapshot(profile) }
    end
    if payload.Action ~= "Upgrade" then
        return { Ok = false, Message = "Неизвестное действие." }
    end
    if not PlotService:GetPlayerPlot(player) then
        return { Ok = false, Message = "Личное гнездо ещё не назначено." }
    end

    local level = profile.Nest.Level
    if level >= MAX_LEVEL then
        return { Ok = false, Message = "Гнездо уже достигло максимального уровня." }
    end
    local cost = UPGRADE_COSTS[level]
    if profile.Coins < cost then
        return { Ok = false, Message = "Не хватает монет. Нужно: " .. cost .. "." }
    end

    profile.Coins -= cost
    profile.Nest.Level = level + 1
    player:SetAttribute("Coins", profile.Coins)
    PlotService:ApplyNestLevel(player, profile.Nest.Level)
    player:SetAttribute("LastNotice", "Гнездо улучшено до " .. profile.Nest.Level .. " уровня!")
    return { Ok = true, Data = getSnapshot(profile) }
end

function NestService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("NestUpgrade")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "NestUpgrade"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
    end)
end

return NestService
