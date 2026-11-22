local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local CollectionBookService = {}
CollectionBookService._lastRequest = {}
local REQUEST_COOLDOWN = 0.35

local function buildSnapshot(profile)
    local ownedCounts = {}
    for _, companion in ipairs(profile.Companions) do
        if type(companion.Id) == "string" then
            ownedCounts[companion.Id] = (ownedCounts[companion.Id] or 0) + 1
        end
    end

    local entries = {}
    local discovered = 0
    local total = 0
    for _, definition in pairs(CompanionCatalog) do
        total += 1
        local count = ownedCounts[definition.Id] or 0
        if count > 0 then discovered += 1 end
        table.insert(entries, {
            Id = definition.Id,
            Name = definition.Name,
            Rarity = definition.Rarity,
            Description = definition.Description,
            Income = definition.Income,
            HatchChance = definition.Weight,
            OwnedCount = count,
            Discovered = count > 0,
        })
    end
    table.sort(entries, function(a, b)
        if a.HatchChance == b.HatchChance then return a.Name < b.Name end
        return a.HatchChance > b.HatchChance
    end)

    return {
        Entries = entries,
        Discovered = discovered,
        Total = total,
        CompletionPercent = total > 0 and math.floor(discovered / total * 100 + 0.5) or 0,
    }
end

function CollectionBookService:HandleRequest(player, payload)
    if type(payload) ~= "table" or payload.Action ~= "Get" then
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

    return { Ok = true, Data = buildSnapshot(profile) }
end

function CollectionBookService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end

    local remote = remotes:FindFirstChild("CollectionBook")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "CollectionBook"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
    end)
end

return CollectionBookService
