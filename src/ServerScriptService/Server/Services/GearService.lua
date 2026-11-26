local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local GearCatalog = require(ReplicatedStorage.Shared.Config.GearCatalog)

local GearService = {}
GearService._lastRequest = {}
local REQUEST_COOLDOWN = 0.2
local MAX_GEAR_ITEMS = 32
local SLOT_ORDER = { "Weapon", "Armor", "Helmet", "Accessory" }

local SLOT_NAMES = {
    Weapon = "Оружие", Armor = "Броня", Helmet = "Шлем", Accessory = "Аксессуар",
}
local MATERIAL_NAMES = {
    Starshard = "звёздных осколков", CrystalShard = "кристальных осколков",
    AshCrystal = "пепельных кристаллов", Moonpetal = "лунных лепестков",
    Elderwood = "древесной эссенции",
}
local ATTRIBUTE_NAMES = {
    Starshard = "Starshard", CrystalShard = "CrystalShards",
    AshCrystal = "AshCrystals", Moonpetal = "Moonpetal", Elderwood = "Elderwood",
}

local function normalize(profile)
    profile.GearInventory = type(profile.GearInventory) == "table" and profile.GearInventory or {}
    profile.EquippedGear = type(profile.EquippedGear) == "table" and profile.EquippedGear or {}
    local clean, owned, seen = {}, {}, {}
    for _, item in ipairs(profile.GearInventory) do
        if type(item) == "table" and type(item.InstanceId) == "string"
            and #item.InstanceId <= 80 and GearCatalog[item.Id]
            and not seen[item.InstanceId] then
            local definition = GearCatalog[item.Id]
            if item.Slot == nil or item.Slot == definition.Slot then
                item.Slot = definition.Slot
                seen[item.InstanceId] = true
                owned[item.InstanceId] = item
                table.insert(clean, item)
            end
        end
    end
    profile.GearInventory = clean
    local equipped = {}
    for _, slot in ipairs(SLOT_ORDER) do
        local instanceId = profile.EquippedGear[slot]
        local item = type(instanceId) == "string" and owned[instanceId] or nil
        if item and item.Slot == slot then equipped[slot] = instanceId end
    end
    profile.EquippedGear = equipped
end

local function getStats(profile)
    local stats = { DamageBonus = 0, DefenseBonus = 0, MaxHealthBonus = 0, WalkSpeedBonus = 0, SetPieces = 0, SetBonus = false }
    local setIds = {}
    for _, slot in ipairs(SLOT_ORDER) do
        local instanceId = profile.EquippedGear[slot]
        if instanceId then
            for _, item in ipairs(profile.GearInventory) do
                if item.InstanceId == instanceId then
                    local definition = GearCatalog[item.Id]
                    if definition then
                        stats.DamageBonus += definition.DamageBonus or 0
                        stats.DefenseBonus += definition.DefenseBonus or 0
                        stats.MaxHealthBonus += definition.MaxHealthBonus or 0
                        stats.WalkSpeedBonus += definition.WalkSpeedBonus or 0
                        setIds[definition.SetId] = (setIds[definition.SetId] or 0) + 1
                        stats.SetPieces += 1
                    end
                    break
                end
            end
        end
    end
    if setIds.Voidwalker == 4 then
        stats.SetBonus = true
        stats.DamageBonus += 0.10
        stats.DefenseBonus += 0.10
        stats.MaxHealthBonus += 20
    end
    stats.DamageBonus = math.clamp(stats.DamageBonus, 0, 0.6)
    stats.DefenseBonus = math.clamp(stats.DefenseBonus, 0, 0.5)
    stats.MaxHealthBonus = math.clamp(stats.MaxHealthBonus, 0, 100)
    stats.WalkSpeedBonus = math.clamp(stats.WalkSpeedBonus, 0, 4)
    return stats
end

local function makeSnapshot(profile)
    local equippedItems = {}
    for _, slot in ipairs(SLOT_ORDER) do
        local instanceId = profile.EquippedGear[slot]
        local found
        for _, item in ipairs(profile.GearInventory) do
            if item.InstanceId == instanceId then found = item break end
        end
        local definition = found and GearCatalog[found.Id]
        equippedItems[slot] = definition and {
            InstanceId = found.InstanceId, Id = definition.Id, Name = definition.Name,
            Rarity = definition.Rarity, Slot = slot,
        } or nil
    end
    local items = {}
    for _, item in ipairs(profile.GearInventory) do
        local definition = GearCatalog[item.Id]
        if definition then
            table.insert(items, {
                InstanceId = item.InstanceId, Id = definition.Id, Name = definition.Name,
                Slot = definition.Slot, SlotName = SLOT_NAMES[definition.Slot],
                Rarity = definition.Rarity, Description = definition.Description,
                DamageBonus = definition.DamageBonus or 0, DefenseBonus = definition.DefenseBonus or 0,
                MaxHealthBonus = definition.MaxHealthBonus or 0, WalkSpeedBonus = definition.WalkSpeedBonus or 0,
                Equipped = profile.EquippedGear[definition.Slot] == item.InstanceId,
                CraftedAt = item.CraftedAt,
            })
        end
    end
    table.sort(items, function(a, b)
        local order = { Weapon = 1, Armor = 2, Helmet = 3, Accessory = 4 }
        if order[a.Slot] ~= order[b.Slot] then return order[a.Slot] < order[b.Slot] end
        return a.Name < b.Name
    end)
    return { Items = items, Equipped = equippedItems, Stats = getStats(profile),
        SlotOrder = SLOT_ORDER, MaxItems = MAX_GEAR_ITEMS }
end

local function makeVisualPart(parent, name, size, color, material, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = material or Enum.Material.Metal
    if shape then part.Shape = shape end
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.CastShadow = false
    part.Parent = parent
    return part
end

local function weldTo(part, bodyPart, offset)
    part.CFrame = bodyPart.CFrame * offset
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = bodyPart
    weld.Part1 = part
    weld.Parent = part
end

local function applyVisuals(player, profile)
    local character = player.Character
    if not character then return end
    local old = character:FindFirstChild("VoidGearVisuals")
    if old then old:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "VoidGearVisuals"
    folder.Parent = character
    local equipped = {}
    for _, item in ipairs(profile.GearInventory) do
        for _, slot in ipairs(SLOT_ORDER) do
            if profile.EquippedGear[slot] == item.InstanceId then equipped[slot] = item end
        end
    end
    local weapon = equipped.Weapon and GearCatalog[equipped.Weapon.Id]
    local armor = equipped.Armor and GearCatalog[equipped.Armor.Id]
    local helmet = equipped.Helmet and GearCatalog[equipped.Helmet.Id]
    local accessory = equipped.Accessory and GearCatalog[equipped.Accessory.Id]
    local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local head = character:FindFirstChild("Head")

    if weapon and rightHand then
        local blade = makeVisualPart(folder, "VoidRiftblade", Vector3.new(0.28, 3.4, 0.55),
            weapon.Color, Enum.Material.Neon)
        weldTo(blade, rightHand, CFrame.new(0, -0.75, -0.45) * CFrame.Angles(math.rad(12), 0, math.rad(90)))
        local grip = makeVisualPart(folder, "VoidRiftbladeGrip", Vector3.new(0.38, 0.9, 0.38),
            Color3.fromRGB(47, 42, 68), Enum.Material.Metal)
        weldTo(grip, rightHand, CFrame.new(0, 0.9, -0.45) * CFrame.Angles(math.rad(12), 0, math.rad(90)))
    end
    if armor and torso then
        local chest = makeVisualPart(folder, "VoidChestplate", Vector3.new(2.35, 2.25, 0.38),
            armor.Color, Enum.Material.Metal)
        weldTo(chest, torso, CFrame.new(0, 0, -0.48))
        for side = -1, 1, 2 do
            local shoulder = makeVisualPart(folder, "VoidShoulder_" .. side, Vector3.new(0.9, 0.65, 0.9),
                Color3.fromRGB(126, 117, 178), Enum.Material.Metal)
            weldTo(shoulder, torso, CFrame.new(side * 1.05, 0.72, -0.35))
        end
    end
    if helmet and head then
        local crown = makeVisualPart(folder, "StarwatchCrown", Vector3.new(2.05, 0.42, 2.05),
            helmet.Color, Enum.Material.Neon, Enum.PartType.Cylinder)
        weldTo(crown, head, CFrame.new(0, 0.88, 0) * CFrame.Angles(0, 0, math.rad(90)))
        local crest = makeVisualPart(folder, "StarwatchCrest", Vector3.new(0.35, 0.95, 0.35),
            Color3.fromRGB(255, 235, 174), Enum.Material.Neon, Enum.PartType.Ball)
        weldTo(crest, head, CFrame.new(0, 1.35, 0))
    end
    if accessory and torso then
        local cloak = makeVisualPart(folder, "NebulaCloak", Vector3.new(2.25, 2.7, 0.18),
            accessory.Color, Enum.Material.Fabric)
        weldTo(cloak, torso, CFrame.new(0, -0.28, 0.52))
    end
end

local function applyPlayer(player, profile)
    local stats = getStats(profile)
    player:SetAttribute("GearDamageBonus", stats.DamageBonus)
    player:SetAttribute("GearDefenseBonus", stats.DefenseBonus)
    player:SetAttribute("GearMaxHealthBonus", stats.MaxHealthBonus)
    player:SetAttribute("GearWalkSpeedBonus", stats.WalkSpeedBonus)
    player:SetAttribute("GearSetBonus", stats.SetBonus)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local baseMax = tonumber(humanoid:GetAttribute("GearBaseMaxHealth")) or humanoid.MaxHealth
        local baseSpeed = tonumber(humanoid:GetAttribute("GearBaseWalkSpeed")) or humanoid.WalkSpeed
        humanoid:SetAttribute("GearBaseMaxHealth", baseMax)
        humanoid:SetAttribute("GearBaseWalkSpeed", baseSpeed)
        local healthRatio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 1
        humanoid.MaxHealth = baseMax + stats.MaxHealthBonus
        humanoid.Health = math.clamp(humanoid.MaxHealth * healthRatio, 0, humanoid.MaxHealth)
        humanoid.WalkSpeed = baseSpeed + stats.WalkSpeedBonus
    end
    applyVisuals(player, profile)
end

local function syncMaterials(player, profile)
    local materials = profile.Materials or {}
    player:SetAttribute("Coins", profile.Coins or 0)
    for id, attribute in pairs(ATTRIBUTE_NAMES) do
        player:SetAttribute(attribute, math.max(0, math.floor(tonumber(materials[id]) or 0)))
    end
end

function GearService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос экипировки." }
    end
    if payload.Action ~= "Get" then
        local now = os.clock()
        if now - (self._lastRequest[player] or 0) < REQUEST_COOLDOWN then
            return { Ok = false, Message = "Подожди немного." }
        end
        self._lastRequest[player] = now
    end
    local profile = PlayerDataService:GetProfile(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end
    normalize(profile)
    if payload.Action == "Get" then return { Ok = true, Data = makeSnapshot(profile) } end

    if payload.Action == "Craft" then
        profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
        if player:GetAttribute("CurrentBiome") ~= "VoidFrontier"
            or not ProgressionService:CanEnterZone(player, "VoidFrontier") then
            return { Ok = false, Message = "Снаряжение создаётся только на открытой Границе пустоты." }
        end
        local itemId = payload.ItemId
        if type(itemId) ~= "string" or #itemId > 48 then
            return { Ok = false, Message = "Неизвестный предмет." }
        end
        local definition = GearCatalog[itemId]
        if not definition then return { Ok = false, Message = "Такого чертежа нет в кузнице." } end
        local world = Workspace:FindFirstChild("NestRaidersWorld")
        local void = world and world:FindFirstChild("VoidFrontier")
        local forge = void and void:FindFirstChild("VoidForge")
        local station = forge and forge:FindFirstChild("VoidForgeAnvil")
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not station or not root or (root.Position - station.Position).Magnitude > 18 then
            return { Ok = false, Message = "Подойди к наковальне Кузницы пустоты." }
        end
        if #profile.GearInventory >= MAX_GEAR_ITEMS then
            return { Ok = false, Message = "Сумка снаряжения заполнена. Освободи место." }
        end
        for _, item in ipairs(profile.GearInventory) do
            if item.Id == itemId then
                return { Ok = false, Message = "Этот предмет уже есть в коллекции. Повторный крафт не нужен." }
            end
        end
        local costs, balances = definition.Cost, {}
        for resource, cost in pairs(costs) do
            local balance = resource == "Coins"
                and math.max(0, math.floor(tonumber(profile.Coins) or 0))
                or math.max(0, math.floor(tonumber(profile.Materials and profile.Materials[resource]) or 0))
            balances[resource] = balance
            if balance < cost then
                local label = resource == "Coins" and "монет" or (MATERIAL_NAMES[resource] or resource)
                return { Ok = false, Message = string.format("Не хватает %s: нужно %d, у тебя %d.", label, cost, balance) }
            end
        end
        for resource, cost in pairs(costs) do
            if resource == "Coins" then profile.Coins = balances.Coins - cost
            else
                profile.Materials[resource] = balances[resource] - cost
            end
        end
        table.insert(profile.GearInventory, {
            Id = itemId, Slot = definition.Slot, InstanceId = HttpService:GenerateGUID(false),
            CraftedAt = os.time(), SetId = definition.SetId,
        })
        syncMaterials(player, profile)
        player:SetAttribute("LastNotice", "Создано снаряжение: " .. definition.Name .. "!")
        return { Ok = true, Data = makeSnapshot(profile), Message = "Создано: " .. definition.Name .. "!" }
    end

    if payload.Action == "Equip" or payload.Action == "Unequip" then
        local slot = payload.Slot
        if type(slot) ~= "string" or not ({ Weapon = true, Armor = true, Helmet = true, Accessory = true })[slot] then
            return { Ok = false, Message = "Неизвестный слот экипировки." }
        end
        if payload.Action == "Equip" then
            local instanceId = payload.InstanceId
            local selected
            if type(instanceId) == "string" and #instanceId <= 80 then
                for _, item in ipairs(profile.GearInventory) do
                    if item.InstanceId == instanceId then selected = item break end
                end
            end
            if not selected or selected.Slot ~= slot then
                return { Ok = false, Message = "Предмет не принадлежит тебе или не подходит этому слоту." }
            end
            profile.EquippedGear[slot] = selected.InstanceId
        else
            profile.EquippedGear[slot] = nil
        end
        applyPlayer(player, profile)
        local message = payload.Action == "Equip" and "Снаряжение надето." or "Предмет снят."
        player:SetAttribute("LastNotice", message)
        return { Ok = true, Data = makeSnapshot(profile), Message = message }
    end
    return { Ok = false, Message = "Неизвестное действие экипировки." }
end

function GearService:RefreshPlayer(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end
    normalize(profile)
    applyPlayer(player, profile)
end

function GearService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local remote = remotes:FindFirstChild("GearInventory")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "GearInventory"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload) return self:HandleRequest(player, payload) end

    local function bindPlayer(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then self:RefreshPlayer(player) end
        end)
        player.CharacterAdded:Connect(function()
            task.delay(0.35, function()
                if player.Parent then self:RefreshPlayer(player) end
            end)
        end)
        if player:GetAttribute("ProfileLoaded") then self:RefreshPlayer(player) end
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player) self._lastRequest[player] = nil end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return GearService
