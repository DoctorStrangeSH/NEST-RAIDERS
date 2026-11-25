local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local PublicProfileService = {}
PublicProfileService._lastRequest = {}
local REQUEST_COOLDOWN = 0.5
local MAX_ACHIEVEMENTS = 20

local TITLES = {
    FirstFriend = { Name = "Друг первого яйца", Icon = "🥚", Description = "Вылупи первого питомца." },
    Collector = { Name = "Коллекционер", Icon = "📚", Description = "Собери 10 питомцев." },
    Bestiary = { Name = "Хранитель бестиария", Icon = "🌿", Description = "Открой 5 разных видов." },
    NestBuilder = { Name = "Архитектор гнезда", Icon = "🏡", Description = "Улучши гнездо до 3 уровня." },
    IslandChampion = { Name = "Чемпион островов", Icon = "🏆", Description = "Займи призовое место в конкурсе островов." },
    PopularIsland = { Name = "Любимец островов", Icon = "⭐", Description = "Получи 10 отметок «Нравится»." },
    RisingStar = { Name = "Восходящая звезда", Icon = "✨", Description = "Достигни 10 уровня." },
}

local TITLE_ORDER = { "FirstFriend", "Collector", "Bestiary", "NestBuilder", "IslandChampion", "PopularIsland", "RisingStar" }

local function countTrue(values)
    local count = 0
    for _, value in pairs(values or {}) do
        if value == true then count += 1 end
    end
    return count
end

local function buildSnapshot(player, profile)
    local unique = {}
    for _, companion in ipairs(profile.Companions or {}) do
        if type(companion) == "table" and type(companion.Id) == "string" then
            unique[companion.Id] = true
        end
    end

    local totalSpecies = 0
    for _ in pairs(CompanionCatalog) do totalSpecies += 1 end
    local uniqueCount = countTrue(unique)
    local nest = profile.Nest or {}
    local trophies = nest.IslandTrophies or {}
    local trophyCount = 0
    for _, trophy in pairs(trophies) do
        if type(trophy) == "table" then trophyCount += 1 end
    end
    local likesReceived = countTrue(nest.IslandLikesByUserId)
    local level = math.max(1, math.floor(tonumber(profile.Level) or 1))
    local companionCount = #(profile.Companions or {})
    local nestLevel = math.max(1, math.floor(tonumber(nest.Level) or 1))

    local unlocked = {}
    if companionCount >= 1 then unlocked.FirstFriend = true end
    if companionCount >= 10 then unlocked.Collector = true end
    if uniqueCount >= 5 then unlocked.Bestiary = true end
    if nestLevel >= 3 then unlocked.NestBuilder = true end
    if trophyCount >= 1 then unlocked.IslandChampion = true end
    if likesReceived >= 10 then unlocked.PopularIsland = true end
    if level >= 10 then unlocked.RisingStar = true end

    local achievements = {}
    local availableTitles = {}
    for _, id in ipairs(TITLE_ORDER) do
        local definition = TITLES[id]
        local isUnlocked = unlocked[id] == true
        table.insert(achievements, {
            Id = id,
            Name = definition.Name,
            Icon = definition.Icon,
            Description = definition.Description,
            Unlocked = isUnlocked,
        })
        if isUnlocked then
            table.insert(availableTitles, {
                Id = id,
                Name = definition.Name,
                Icon = definition.Icon,
            })
        end
    end

    local equipped = type(nest.EquippedTitle) == "string" and nest.EquippedTitle or ""
    if equipped ~= "" and not unlocked[equipped] then equipped = "" end

    return {
        UserId = player.UserId,
        DisplayName = player.DisplayName,
        Username = player.Name,
        Level = level,
        NestLevel = nestLevel,
        CompanionCount = companionCount,
        UniqueCompanions = uniqueCount,
        TotalSpecies = totalSpecies,
        CollectionPercent = totalSpecies > 0 and math.floor(uniqueCount / totalSpecies * 100 + 0.5) or 0,
        LikesReceived = likesReceived,
        TrophyCount = trophyCount,
        Achievements = achievements,
        AvailableTitles = availableTitles,
        EquippedTitle = equipped,
        IsLocalServer = true,
    }
end

function PublicProfileService:ApplyOverhead(player)
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local old = head:FindFirstChild("NestRaidersTitle")
    if old then old:Destroy() end

    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end
    local snapshot = buildSnapshot(player, profile)
    local titleId = snapshot.EquippedTitle
    if titleId == "" then return end
    local definition = TITLES[titleId]
    if not definition then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NestRaidersTitle"
    billboard.Size = UDim2.fromOffset(220, 30)
    billboard.StudsOffset = Vector3.new(0, 3.15, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 80
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = definition.Icon .. "  " .. definition.Name
    label.TextColor3 = Color3.fromRGB(255, 229, 151)
    label.TextStrokeTransparency = 0.35
    label.TextStrokeColor3 = Color3.fromRGB(40, 38, 50)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.Parent = billboard
end

function PublicProfileService:GetProfile(viewer, targetUserId)
    if type(targetUserId) ~= "number" or targetUserId <= 0 then
        return { Ok = false, Message = "Некорректный игрок." }
    end
    local target = Players:GetPlayerByUserId(targetUserId)
    if not target or not target:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль доступен, когда игрок находится на этом сервере." }
    end
    local profile = PlayerDataService:GetProfile(target)
    if not profile then return { Ok = false, Message = "Профиль игрока ещё загружается." } end
    return { Ok = true, Data = buildSnapshot(target, profile) }
end

function PublicProfileService:EquipTitle(player, titleId)
    if type(titleId) ~= "string" or #titleId > 40 then
        return { Ok = false, Message = "Некорректный титул." }
    end
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return { Ok = false, Message = "Профиль ещё загружается." } end
    profile.Nest = profile.Nest or {}
    local snapshot = buildSnapshot(player, profile)
    if titleId ~= "" then
        local unlocked = false
        for _, title in ipairs(snapshot.AvailableTitles) do
            if title.Id == titleId then unlocked = true break end
        end
        if not unlocked then
            return { Ok = false, Message = "Этот титул ещё не открыт." }
        end
    end
    profile.Nest.EquippedTitle = titleId
    self:ApplyOverhead(player)
    return { Ok = true, Message = titleId == "" and "Титул снят." or "Титул установлен!" }
end

function PublicProfileService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос." }
    end
    if not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then
        return { Ok = false, Message = "Подожди немного." }
    end
    self._lastRequest[player] = now

    if payload.Action == "Get" then
        return self:GetProfile(player, payload.UserId or player.UserId)
    end
    if payload.Action == "EquipTitle" then
        return self:EquipTitle(player, payload.TitleId)
    end
    return { Ok = false, Message = "Неизвестное действие." }
end

function PublicProfileService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("PublicProfile")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "PublicProfile"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    local function bindPlayer(player)
        player.CharacterAdded:Connect(function()
            task.delay(1, function()
                if player.Parent then self:ApplyOverhead(player) end
            end)
        end)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then self:ApplyOverhead(player) end
        end)
        if player.Character then task.defer(function() self:ApplyOverhead(player) end) end
    end
    Players.PlayerAdded:Connect(bindPlayer)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
    end)
end

return PublicProfileService
