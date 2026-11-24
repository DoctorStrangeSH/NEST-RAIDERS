local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)
local NestDecorCatalog = require(ReplicatedStorage.Shared.Config.NestDecorCatalog)
local IslandStyleCatalog = require(ReplicatedStorage.Shared.Config.IslandStyleCatalog)

local NestDecorService = {}
NestDecorService._lastRequest = {}
local REQUEST_COOLDOWN = 0.35
local MAX_DECOR_PER_TYPE = 20
local SLOT_OFFSETS = {
    Vector3.new(-14, 1.7, 0),
    Vector3.new(14, 1.7, 0),
    Vector3.new(0, 1.7, -14),
    Vector3.new(0, 1.7, 14),
    Vector3.new(-14, 1.7, -14),
    Vector3.new(14, 1.7, 14),
}

local function ensureNest(profile)
    profile.Nest = profile.Nest or { Level = 1 }
    profile.Nest.DecorInventory = type(profile.Nest.DecorInventory) == "table" and profile.Nest.DecorInventory or {}
    profile.Nest.PlacedDecor = type(profile.Nest.PlacedDecor) == "table" and profile.Nest.PlacedDecor or {}
    for rawSlot, value in pairs(profile.Nest.PlacedDecor) do
        local slot = tonumber(rawSlot)
        if type(value) == "string" and NestDecorCatalog[value] and slot and SLOT_OFFSETS[slot] then
            local legacyOffset = SLOT_OFFSETS[slot]
            profile.Nest.PlacedDecor[rawSlot] = {
                Id = value,
                X = legacyOffset.X,
                Z = legacyOffset.Z,
                Rotation = 0,
            }
        elseif type(value) == "table" then
            local id = value.Id
            if not NestDecorCatalog[id] then
                profile.Nest.PlacedDecor[rawSlot] = nil
            else
                value.X = math.clamp(math.floor((tonumber(value.X) or 0) / 2 + 0.5) * 2, -14, 14)
                value.Z = math.clamp(math.floor((tonumber(value.Z) or 0) / 2 + 0.5) * 2, -14, 14)
                value.Rotation = (math.floor((tonumber(value.Rotation) or 0) / 15 + 0.5) * 15) % 360
            end
        else
            profile.Nest.PlacedDecor[rawSlot] = nil
        end
    end
    return profile.Nest
end

local function getSlotLimit(profile)
    local level = math.clamp(math.floor(tonumber(profile.Nest and profile.Nest.Level) or 1), 1, 5)
    return math.min(#SLOT_OFFSETS, level + 1)
end

local function getSnapshot(profile)
    local nest = ensureNest(profile)
    local inventory = {}
    for id, count in pairs(nest.DecorInventory) do
        local definition = NestDecorCatalog[id]
        if definition and tonumber(count) and count > 0 then
            table.insert(inventory, { Id = id, Name = definition.Name, Count = math.floor(count), Cost = definition.Cost })
        end
    end
    table.sort(inventory, function(a, b) return a.Name < b.Name end)

    local placed = {}
    for rawSlot, id in pairs(nest.PlacedDecor) do
        local slot = tonumber(rawSlot)
        local placement = type(id) == "table" and id or nil
        local definition = placement and NestDecorCatalog[placement.Id] or nil
        if slot and definition then
            table.insert(placed, {
                Slot = slot,
                Id = placement.Id,
                Name = definition.Name,
                X = placement.X,
                Z = placement.Z,
                Rotation = placement.Rotation,
            })
        end
    end
    table.sort(placed, function(a, b) return a.Slot < b.Slot end)

    local styles = {}
    local currentStyle = IslandStyleCatalog[nest.IslandStyle] and nest.IslandStyle or "Meadow"
    local nestLevel = math.clamp(math.floor(tonumber(nest.Level) or 1), 1, 5)
    for _, id in ipairs({"Meadow", "Arcane", "Ancient", "Royal"}) do
        local definition = IslandStyleCatalog[id]
        table.insert(styles, {
            Id = id,
            Name = definition.Name,
            Description = definition.Description,
            UnlockLevel = definition.UnlockLevel,
            Unlocked = nestLevel >= definition.UnlockLevel,
            IsSelected = currentStyle == id,
        })
    end

    return {
        Coins = math.max(0, math.floor(tonumber(profile.Coins) or 0)),
        NestLevel = nestLevel,
        CurrentStyle = currentStyle,
        Styles = styles,
        SlotLimit = getSlotLimit(profile),
        Inventory = inventory,
        Placed = placed,
        Catalog = {
            { Id = "FlowerPot", Name = NestDecorCatalog.FlowerPot.Name, Description = NestDecorCatalog.FlowerPot.Description, Cost = NestDecorCatalog.FlowerPot.Cost },
            { Id = "WarmLantern", Name = NestDecorCatalog.WarmLantern.Name, Description = NestDecorCatalog.WarmLantern.Description, Cost = NestDecorCatalog.WarmLantern.Cost },
            { Id = "MeadowCrystal", Name = NestDecorCatalog.MeadowCrystal.Name, Description = NestDecorCatalog.MeadowCrystal.Description, Cost = NestDecorCatalog.MeadowCrystal.Cost },
            { Id = "MushroomSeat", Name = NestDecorCatalog.MushroomSeat.Name, Description = NestDecorCatalog.MushroomSeat.Description, Cost = NestDecorCatalog.MushroomSeat.Cost },
        },
    }
end

local function buildDecoration(parent, definition, center, offset, slot, rotation)
    local model = Instance.new("Model")
    model.Name = "Decor_" .. definition.Id .. "_" .. tostring(slot)
    model:SetAttribute("DecorId", definition.Id)
    model:SetAttribute("DecorSlot", slot)
    model.Parent = parent

    local function part(name, size, position, color, shape, material)
        local item = Instance.new("Part")
        item.Name = name
        item.Size = size
        local base = CFrame.new(center + offset) * CFrame.Angles(0, math.rad(rotation or 0), 0)
        item.CFrame = base * CFrame.new(position)
        if shape == Enum.PartType.Cylinder then
            item.CFrame *= CFrame.Angles(0, 0, math.rad(90))
        end
        item.Anchored = true
        item.CanCollide = false
        item.CanTouch = false
        item.CanQuery = false
        item.Material = material or Enum.Material.SmoothPlastic
        item.Color = color
        item.Shape = shape or Enum.PartType.Block
        item.Parent = model
        return item
    end

    if definition.Id == "FlowerPot" then
        part("Pot", Vector3.new(1.5, 1.1, 1.5), Vector3.new(0, 0, 0), definition.Accent, Enum.PartType.Cylinder, Enum.Material.Wood)
        for index = 1, 3 do
            local angle = (index - 1) * math.pi * 2 / 3
            local flowerOffset = Vector3.new(math.cos(angle) * 0.42, 0.9, math.sin(angle) * 0.42)
            local stem = part("Stem", Vector3.new(0.12, 0.7, 0.12), flowerOffset + Vector3.new(0, -0.2, 0), Color3.fromRGB(91, 166, 96))
            stem.Shape = Enum.PartType.Cylinder
            part("Bloom", Vector3.new(0.62, 0.62, 0.62), flowerOffset + Vector3.new(0, 0.2, 0), definition.Color, Enum.PartType.Ball, Enum.Material.Neon)
        end
    elseif definition.Id == "WarmLantern" then
        part("Post", Vector3.new(0.28, 2.4, 0.28), Vector3.new(0, 1.2, 0), definition.Accent, Enum.PartType.Cylinder, Enum.Material.Wood)
        local glow = part("Lantern", Vector3.new(1.05, 1.05, 1.05), Vector3.new(0, 2.5, 0), definition.Color, Enum.PartType.Ball, Enum.Material.Neon)
        local light = Instance.new("PointLight")
        light.Color = definition.Color
        light.Brightness = 0.8
        light.Range = 10
        light.Parent = glow
    elseif definition.Id == "MeadowCrystal" then
        local crystal = part("Crystal", Vector3.new(1.25, 2.2, 1.25), Vector3.new(0, 1.1, 0), definition.Color, Enum.PartType.Ball, Enum.Material.Neon)
        crystal.Transparency = 0.12
        local light = Instance.new("PointLight")
        light.Color = definition.Color
        light.Brightness = 0.55
        light.Range = 8
        light.Parent = crystal
        part("Base", Vector3.new(1.8, 0.35, 1.8), Vector3.new(0, 0.15, 0), definition.Accent, Enum.PartType.Cylinder, Enum.Material.Slate)
    else
        part("Seat", Vector3.new(2.6, 0.55, 1.35), Vector3.new(0, 0.65, 0), definition.Accent, Enum.PartType.Block, Enum.Material.Wood)
        local cap = part("MushroomCap", Vector3.new(2.8, 0.8, 2.8), Vector3.new(0, 1.45, 0), definition.Color, Enum.PartType.Ball)
        cap.Size = Vector3.new(2.8, 0.8, 2.8)
        part("Stem", Vector3.new(0.7, 1.2, 0.7), Vector3.new(0, 0.2, 0), definition.Accent, Enum.PartType.Cylinder)
    end
    return model
end

function NestDecorService:RefreshPlayer(player)
    local profile = PlayerDataService:GetProfile(player)
    local plot = PlotService:GetPlayerPlot(player)
    if not profile or not plot or not plot.Model or not plot.Model.Parent then return end

    local nest = ensureNest(profile)
    local previous = plot.Model:FindFirstChild("PlayerDecorations")
    if previous then previous:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "PlayerDecorations"
    folder.Parent = plot.Model

    for rawSlot, id in pairs(nest.PlacedDecor) do
        local slot = tonumber(rawSlot)
        local placement = type(id) == "table" and id or nil
        local definition = placement and NestDecorCatalog[placement.Id] or nil
        if definition and slot and slot <= getSlotLimit(profile) then
            local offset = Vector3.new(placement.X, 1.7, placement.Z)
            buildDecoration(folder, definition, plot.Center, offset, slot, placement.Rotation)
        end
    end
end

function NestDecorService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос." }
    end
    local now = os.clock()
    if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then
        return { Ok = false, Message = "Подожди немного." }
    end
    self._lastRequest[player] = now

    local profile = PlayerDataService:GetProfile(player)
    local plot = PlotService:GetPlayerPlot(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    if not plot then
        return { Ok = false, Message = "Личное гнездо ещё не назначено." }
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - plot.Center).Magnitude > 65 then
        return { Ok = false, Message = "Подойди к своему гнезду, чтобы изменить декор." }
    end

    local nest = ensureNest(profile)
    if payload.Action == "Get" then
        self:RefreshPlayer(player)
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "SetStyle" then
        local styleId = payload.StyleId
        local definition = type(styleId) == "string" and IslandStyleCatalog[styleId] or nil
        if not definition then
            return { Ok = false, Message = "Такого стиля острова нет." }
        end
        local nestLevel = math.clamp(math.floor(tonumber(nest.Level) or 1), 1, 5)
        if nestLevel < definition.UnlockLevel then
            return { Ok = false, Message = "Этот стиль откроется на " .. tostring(definition.UnlockLevel) .. " уровне гнезда." }
        end
        nest.IslandStyle = styleId
        if not PlotService:ApplyIslandStyle(player, styleId) then
            return { Ok = false, Message = "Не удалось применить оформление. Попробуй ещё раз." }
        end
        player:SetAttribute("LastNotice", "Стиль острова изменён: " .. definition.Name .. "!")
        return { Ok = true, Data = getSnapshot(profile), Message = "Новое оформление применено!" }
    end

    if payload.Action == "Buy" then
        local id = payload.DecorId
        local definition = type(id) == "string" and NestDecorCatalog[id] or nil
        if not definition then return { Ok = false, Message = "Такого украшения нет в каталоге." } end
        local owned = math.max(0, math.floor(tonumber(nest.DecorInventory[id]) or 0))
        local placedCount = 0
        for _, placed in pairs(nest.PlacedDecor) do
            local placedId = type(placed) == "table" and placed.Id or placed
            if placedId == id then placedCount += 1 end
        end
        if owned + placedCount >= MAX_DECOR_PER_TYPE then
            return { Ok = false, Message = "У тебя уже достаточно таких украшений." }
        end
        if profile.Coins < definition.Cost then
            return { Ok = false, Message = "Не хватает монет. Нужно " .. definition.Cost .. " монет." }
        end
        profile.Coins -= definition.Cost
        nest.DecorInventory[id] = owned + 1
        player:SetAttribute("Coins", profile.Coins)
        player:SetAttribute("LastNotice", "Куплено: " .. definition.Name .. "!")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    local slot = math.floor(tonumber(payload.Slot) or 0)
    if slot < 1 or slot > getSlotLimit(profile) then
        return { Ok = false, Message = "Это место ещё закрыто. Улучши гнездо." }
    end
    local slotKey = tostring(slot)

    if payload.Action == "Place" then
        local id = payload.DecorId
        local definition = type(id) == "string" and NestDecorCatalog[id] or nil
        if not definition then return { Ok = false, Message = "Выбери украшение из каталога." } end
        if nest.PlacedDecor[slotKey] then return { Ok = false, Message = "Это место уже занято." } end
        local owned = math.max(0, math.floor(tonumber(nest.DecorInventory[id]) or 0))
        if owned < 1 then return { Ok = false, Message = "Сначала купи это украшение." } end
        nest.DecorInventory[id] = owned - 1
        local defaultOffset = SLOT_OFFSETS[slot]
        nest.PlacedDecor[slotKey] = {
            Id = id,
            X = defaultOffset.X,
            Z = defaultOffset.Z,
            Rotation = 0,
        }
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", definition.Name .. " украшает твоё гнездо!")
        return { Ok = true, Data = getSnapshot(profile) }
    elseif payload.Action == "Remove" then
        local placement = nest.PlacedDecor[slotKey]
        local id = type(placement) == "table" and placement.Id or placement
        if not id or not NestDecorCatalog[id] then return { Ok = false, Message = "Это место уже свободно." } end
        nest.PlacedDecor[slotKey] = nil
        nest.DecorInventory[id] = math.max(0, math.floor(tonumber(nest.DecorInventory[id]) or 0)) + 1
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", "Украшение возвращено в коллекцию.")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    if payload.Action == "Move" then
        local placement = nest.PlacedDecor[slotKey]
        if type(placement) ~= "table" or not NestDecorCatalog[placement.Id] then
            return { Ok = false, Message = "Сначала размести украшение." }
        end
        local requestedX = tonumber(payload.X)
        local requestedZ = tonumber(payload.Z)
        local requestedRotation = tonumber(payload.Rotation)
        if not requestedX or not requestedZ or not requestedRotation
            or requestedX ~= requestedX or requestedZ ~= requestedZ or requestedRotation ~= requestedRotation
            or math.abs(requestedX) == math.huge or math.abs(requestedZ) == math.huge
            or math.abs(requestedRotation) > 36000 then
            return { Ok = false, Message = "Некорректные координаты украшения." }
        end
        if math.abs(requestedX) > 15 or math.abs(requestedZ) > 15 then
            return { Ok = false, Message = "Нельзя размещать декор за границами гнезда." }
        end
        local snappedX = math.clamp(math.floor(requestedX / 2 + 0.5) * 2, -14, 14)
        local snappedZ = math.clamp(math.floor(requestedZ / 2 + 0.5) * 2, -14, 14)
        local snappedRotation = (math.floor(requestedRotation / 15 + 0.5) * 15) % 360
        placement.X = snappedX
        placement.Z = snappedZ
        placement.Rotation = snappedRotation
        self:RefreshPlayer(player)
        player:SetAttribute("LastNotice", "Положение украшения обновлено.")
        return { Ok = true, Data = getSnapshot(profile) }
    end

    return { Ok = false, Message = "Неизвестное действие." }
end

function NestDecorService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("NestDecor")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "NestDecor"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    local function bindPlayer(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then
                task.defer(function() self:RefreshPlayer(player) end)
            end
        end)
        if player:GetAttribute("ProfileLoaded") then task.defer(function() self:RefreshPlayer(player) end) end
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        self._lastRequest[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return NestDecorService
