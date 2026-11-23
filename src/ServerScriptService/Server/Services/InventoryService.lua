local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionService = require(ServerScriptService.Server.Services.CompanionService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)
local DisplayPetService = require(ServerScriptService.Server.Services.DisplayPetService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local PlotService = require(ServerScriptService.Server.Services.PlotService)

local InventoryService = {}
local MAX_ACTIVE_COMPANIONS = 3
local REQUEST_COOLDOWN = 0.2
InventoryService._lastRequest = {}

local MAX_COMPANION_LEVEL = 10
local TRAIN_XP = 75

local function getGrowthStage(level)
    if level >= 7 then return "Взрослый", 3 end
    if level >= 4 then return "Юный", 2 end
    return "Малыш", 1
end

local function getTrait(companion)
    local trait = type(companion.GeneticTrait) == "table" and companion.GeneticTrait or nil
    if not trait then
        trait = { Id = "Natural", Name = "Естественный", Rarity = "Обычный", IncomeBonus = 0 }
        companion.GeneticTrait = trait
    end
    trait.IncomeBonus = math.clamp(tonumber(trait.IncomeBonus) or 0, 0, 0.1)
    return trait
end

local function updateCompanionIncome(companion)
    local definition = CompanionCatalog[companion.Id]
    local baseIncome = definition and definition.Income or math.max(1, tonumber(companion.Income) or 1)
    local stars = math.clamp(math.floor(tonumber(companion.Stars) or 1), 1, 3)
    local level = math.clamp(math.floor(tonumber(companion.Level) or 1), 1, MAX_COMPANION_LEVEL)
    local starMultiplier = stars == 3 and 3 or (stars == 2 and 1.75 or 1)
    local levelMultiplier = 1 + (level - 1) * 0.04
    local trait = getTrait(companion)
    companion.Income = math.max(1, math.floor(baseIncome * starMultiplier * levelMultiplier * (1 + trait.IncomeBonus)))
end

local function activeSet(profile)
    local result = {}
    for _, instanceId in ipairs(profile.ActiveCompanions) do
        result[instanceId] = true
    end
    return result
end

local function normalizeProfile(profile)
    profile.ActiveCompanions = type(profile.ActiveCompanions) == "table" and profile.ActiveCompanions or {}
    local owned = {}
    for _, companion in ipairs(profile.Companions) do
        if type(companion.InstanceId) ~= "string" then
            companion.InstanceId = HttpService:GenerateGUID(false)
        end
        companion.Level = math.clamp(math.floor(tonumber(companion.Level) or 1), 1, MAX_COMPANION_LEVEL)
        companion.GrowthXP = math.max(0, math.floor(tonumber(companion.GrowthXP) or 0))
        getTrait(companion)
        updateCompanionIncome(companion)
        if type(companion.InstanceId) == "string" then
            owned[companion.InstanceId] = true
        end
    end

    local clean = {}
    local seen = {}
    for _, instanceId in ipairs(profile.ActiveCompanions) do
        if owned[instanceId] and not seen[instanceId] and #clean < MAX_ACTIVE_COMPANIONS then
            seen[instanceId] = true
            table.insert(clean, instanceId)
        end
    end

    profile.ActiveCompanions = clean
end

local function makeSnapshot(profile)
    local equipped = activeSet(profile)
    local speciesCounts = {}
    local displayed = {}
    for _, instanceId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do displayed[instanceId] = true end
    for _, companion in ipairs(profile.Companions) do
        if not displayed[companion.InstanceId] then
            local key = tostring(companion.Id) .. ":" .. tostring(companion.Stars or 1)
            speciesCounts[key] = (speciesCounts[key] or 0) + 1
        end
    end
    local companions = {}
    for _, companion in ipairs(profile.Companions) do
        table.insert(companions, {
            InstanceId = companion.InstanceId,
            Id = companion.Id,
            Name = companion.Name,
            Rarity = companion.Rarity,
            Origin = companion.Origin or "Hatch",
            ParentNames = (function()
                local names = {}
                for _, parentId in ipairs(type(companion.ParentSpecies) == "table" and companion.ParentSpecies or {}) do
                    local parentDefinition = CompanionCatalog[parentId]
                    table.insert(names, parentDefinition and parentDefinition.Name or parentId)
                end
                return names
            end)(),
            Level = companion.Level or 1,
            GrowthXP = companion.GrowthXP or 0,
            GrowthXPToNext = (companion.Level or 1) < MAX_COMPANION_LEVEL and (100 + ((companion.Level or 1) - 1) * 55) or 0,
            GrowthStage = getGrowthStage(companion.Level or 1),
            GeneticTrait = getTrait(companion),
            Ability = (function()
                local definition = CompanionCatalog[companion.Id]
                local ability = definition and definition.Ability
                if not ability then return nil end
                local level = math.clamp(math.floor(tonumber(companion.Level) or 1), 1, MAX_COMPANION_LEVEL)
                return {
                    Id = ability.Id,
                    Name = ability.Name,
                    Description = ability.Description,
                    UnlockLevel = ability.UnlockLevel or 7,
                    CooldownSeconds = ability.CooldownSeconds or 300,
                    Unlocked = level >= (ability.UnlockLevel or 7),
                    ReadyIn = math.max(0, (tonumber(companion.AbilityReadyAt) or 0) - os.time()),
                }
            end)(),
            TrainCost = (companion.Level or 1) < MAX_COMPANION_LEVEL and (30 + (companion.Level or 1) * 25) or 0,
            BreedReadyIn = math.max(0, (tonumber(companion.BreedReadyAt) or 0) - os.time()),
            Stars = companion.Stars or 1,
            MergeCount = (displayed[companion.InstanceId] and 0 or speciesCounts[tostring(companion.Id) .. ":" .. tostring(companion.Stars or 1)]) or 1,
            Displayed = displayed[companion.InstanceId] == true,
            Income = companion.Income or 0,
            Equipped = equipped[companion.InstanceId] == true,
        })
    end
    local eggs = {}
    for _, egg in ipairs(profile.EggInventory or {}) do
        local parentNames = {}
        for _, parentId in ipairs(type(egg.ParentSpecies) == "table" and egg.ParentSpecies or {}) do
            local parentDefinition = CompanionCatalog[parentId]
            table.insert(parentNames, parentDefinition and parentDefinition.Name or parentId)
        end
        local childDefinition = CompanionCatalog[egg.OffspringSpeciesId]
        table.insert(eggs, {
            InstanceId = egg.InstanceId,
            Id = egg.Id,
            Origin = egg.Origin or "World",
            ReadyIn = math.max(0, (tonumber(egg.IncubatesUntil) or 0) - os.time()),
            OffspringName = childDefinition and childDefinition.Name or nil,
            GeneticTrait = type(egg.GeneticTrait) == "table" and egg.GeneticTrait.Name or nil,
            ParentNames = parentNames,
        })
    end
    return {
        Companions = companions,
        Eggs = eggs,
        EggCount = #eggs,
        ActiveCount = #profile.ActiveCompanions,
        MaxActive = MAX_ACTIVE_COMPANIONS,
    }
end

function InventoryService:HandleRequest(player, payload)
    if type(payload) ~= "table" or type(payload.Action) ~= "string" then
        return { Ok = false, Message = "Некорректный запрос." }
    end
    -- Read-only snapshots must not consume the rate limit for gameplay actions.
    -- Otherwise immediately opening the inventory after equipping/hatching can fail.
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
    normalizeProfile(profile)

    if payload.Action == "Get" then
        return { Ok = true, Data = makeSnapshot(profile) }
    end
    if payload.Action ~= "Equip" and payload.Action ~= "Unequip" and payload.Action ~= "Merge" and payload.Action ~= "Train" and payload.Action ~= "UseAbility" and payload.Action ~= "Breed" then
        return { Ok = false, Message = "Неизвестное действие." }
    end
    if type(payload.InstanceId) ~= "string" or #payload.InstanceId > 80 then
        return { Ok = false, Message = "Некорректный питомец." }
    end

    local owned = false
    for _, companion in ipairs(profile.Companions) do
        if companion.InstanceId == payload.InstanceId then owned = true break end
    end
    if not owned then
        return { Ok = false, Message = "Этот питомец тебе не принадлежит." }
    end

    if payload.Action == "Breed" then
        local playerPlot = PlotService:GetPlayerPlot(player)
        local breedingStation = playerPlot and playerPlot.BreedingStation
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not breedingStation or not breedingStation.Parent or not root
            or (root.Position - breedingStation.Position).Magnitude > 18 then
            return { Ok = false, Message = "Для разведения подойди к алтарю в своём личном гнезде." }
        end

        if type(payload.PartnerInstanceId) ~= "string" or #payload.PartnerInstanceId > 80
            or payload.PartnerInstanceId == payload.InstanceId then
            return { Ok = false, Message = "Выбери двух разных питомцев." }
        end

        local parentA
        local parentB
        for _, companion in ipairs(profile.Companions) do
            if companion.InstanceId == payload.InstanceId then parentA = companion end
            if companion.InstanceId == payload.PartnerInstanceId then parentB = companion end
        end
        if not parentA or not parentB then
            return { Ok = false, Message = "Один из родителей не найден в коллекции." }
        end
        local levelA = math.clamp(math.floor(tonumber(parentA.Level) or 1), 1, MAX_COMPANION_LEVEL)
        local levelB = math.clamp(math.floor(tonumber(parentB.Level) or 1), 1, MAX_COMPANION_LEVEL)
        if levelA < 7 or levelB < 7 then
            return { Ok = false, Message = "Для разведения оба питомца должны быть взрослыми (уровень 7)." }
        end
        if parentA.Id == parentB.Id then
            return { Ok = false, Message = "Для выведения гибрида нужны питомцы разных видов." }
        end
        if activeSet(profile)[parentA.InstanceId] or activeSet(profile)[parentB.InstanceId] then
            return { Ok = false, Message = "Сначала убери родителей из активной команды." }
        end
        for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
            if displayedId == parentA.InstanceId or displayedId == parentB.InstanceId then
                return { Ok = false, Message = "Сними родителей с витрины перед разведением." }
            end
        end

        local now = os.time()
        local readyA = math.max(0, math.floor(tonumber(parentA.BreedReadyAt) or 0))
        local readyB = math.max(0, math.floor(tonumber(parentB.BreedReadyAt) or 0))
        local readyIn = math.max(readyA, readyB) - now
        if readyIn > 0 then
            return { Ok = false, Message = "Родители отдыхают ещё " .. readyIn .. " сек." }
        end

        local starsA = math.clamp(math.floor(tonumber(parentA.Stars) or 1), 1, 3)
        local starsB = math.clamp(math.floor(tonumber(parentB.Stars) or 1), 1, 3)
        local cost = 250 + (starsA + starsB) * 100
        if profile.Coins < cost then
            return { Ok = false, Message = "Для разведения нужно " .. cost .. " монет." }
        end
        if #profile.Companions + #profile.EggInventory >= 100 then
            return { Ok = false, Message = "Коллекция и инкубатор заполнены. Освободи место перед разведением." }
        end
        if #profile.EggInventory >= 20 then
            return { Ok = false, Message = "Инкубатор заполнен. Сначала вылупи готовые яйца." }
        end

        local traitA = getTrait(parentA)
        local traitB = getTrait(parentB)
        local inheritedTrait
        local mutationRoll = math.random()
        if mutationRoll <= 0.03 then
            inheritedTrait = { Id = "Prismatic", Name = "Призматический", Rarity = "Эпический", IncomeBonus = 0.08 }
        elseif mutationRoll <= 0.10 then
            inheritedTrait = { Id = "Luminous", Name = "Светящийся", Rarity = "Редкий", IncomeBonus = 0.05 }
        else
            local sourceTrait = math.random(1, 2) == 1 and traitA or traitB
            inheritedTrait = {
                Id = sourceTrait.Id,
                Name = sourceTrait.Name,
                Rarity = sourceTrait.Rarity,
                IncomeBonus = sourceTrait.IncomeBonus,
            }
        end

        local hybridByPair = {
            ["MeadowFox:SproutDragon"] = "EmberFox",
            ["MossTurtle:SproutDragon"] = "Fernshell",
            ["MeadowFox:MossTurtle"] = "BriarGuardian",
        }
        local speciesA, speciesB = parentA.Id, parentB.Id
        if speciesA > speciesB then speciesA, speciesB = speciesB, speciesA end
        local hybridId = hybridByPair[speciesA .. ":" .. speciesB]
        local childDefinition
        if hybridId then
            childDefinition = CompanionCatalog[hybridId]
        else
            childDefinition = math.random(1, 2) == 1 and CompanionCatalog[parentA.Id] or CompanionCatalog[parentB.Id]
        end
        if not childDefinition then
            return { Ok = false, Message = "Невозможно вывести потомство для этой пары." }
        end

        profile.Coins -= cost
        parentA.BreedReadyAt = now + 1800
        parentB.BreedReadyAt = now + 1800
        local egg = {
            InstanceId = HttpService:GenerateGUID(false),
            Id = "LineageEgg",
            CollectedAt = now,
            Origin = "Breeding",
            IncubatesUntil = now + 300,
            OffspringSpeciesId = childDefinition.Id,
            IsHybrid = childDefinition.Hybrid == true,
            GeneticTrait = inheritedTrait,
            ParentSpecies = { parentA.Id, parentB.Id },
        }
        table.insert(profile.EggInventory, egg)
        local previewFolder = Instance.new("Folder")
        previewFolder.Name = "BreedingPreview_" .. player.UserId
        previewFolder.Parent = Workspace
        local parentPreviewA = CompanionService:CreateRitualPreview(previewFolder, parentA, 1)
        local parentPreviewB = CompanionService:CreateRitualPreview(previewFolder, parentB, 2)
        PlotService:PlayBreedingSequence(player, parentA, parentB, egg, parentPreviewA, parentPreviewB, previewFolder)

        player:SetAttribute("Coins", profile.Coins)
        player:SetAttribute("EggCount", #profile.EggInventory)
        player:SetAttribute("LastNotice", "Родилось яйцо потомства! Инкубация займёт 5 минут.")
        return { Ok = true, Data = makeSnapshot(profile), Message = "Яйцо потомства помещено в инкубатор!" }
    end

    if payload.Action == "UseAbility" then
        local target
        for _, companion in ipairs(profile.Companions) do
            if companion.InstanceId == payload.InstanceId then target = companion break end
        end
        if not target then return { Ok = false, Message = "Питомец не найден." } end
        if not activeSet(profile)[target.InstanceId] then
            return { Ok = false, Message = "Способность доступна только активному питомцу." }
        end

        local definition = CompanionCatalog[target.Id]
        local ability = definition and definition.Ability
        if not ability then return { Ok = false, Message = "У этого питомца пока нет способности." } end
        local level = math.clamp(math.floor(tonumber(target.Level) or 1), 1, MAX_COMPANION_LEVEL)
        local unlockLevel = math.max(1, math.floor(tonumber(ability.UnlockLevel) or 7))
        if level < unlockLevel then
            return { Ok = false, Message = "Способность откроется на уровне " .. unlockLevel .. "." }
        end

        local now = os.time()
        local readyAt = math.max(0, math.floor(tonumber(target.AbilityReadyAt) or 0))
        if readyAt > now then
            return { Ok = false, Message = "Способность восстановится через " .. (readyAt - now) .. " сек." }
        end

        local stars = math.clamp(math.floor(tonumber(target.Stars) or 1), 1, 3)
        local message
        if ability.Id == "TrailFinder" then
            local reward = 40 + level * 10 + stars * 15
            if not EconomyService:GrantCoins(player, reward, "Следопыт") then
                return { Ok = false, Message = "Не удалось выдать награду." }
            end
            message = target.Name .. " нашёл тайник: +" .. reward .. " монет!"
        elseif ability.Id == "CinderDash" then
            local reward = 60 + level * 12 + stars * 20
            if not EconomyService:GrantCoins(player, reward, "Угольный рывок") then
                return { Ok = false, Message = "Не удалось выдать награду." }
            end
            message = target.Name .. " нашёл огненный тайник: +" .. reward .. " монет!"
        elseif ability.Id == "RootBlessing" then
            profile.Nest = type(profile.Nest) == "table" and profile.Nest or {}
            local reward = 100 + level * 20 + stars * 25
            local stored = math.max(0, math.floor(tonumber(profile.Nest.StoredCoins) or 0))
            profile.Nest.StoredCoins = math.min(2_000_000_000, stored + reward)
            message = target.Name .. " напитал корни: +" .. reward .. " монет в гнездо!"
        elseif ability.Id == "VerdantSpark" then
            local reward = 35 + level * 5 + stars * 10
            if not ProgressionService:AddXP(player, reward) then
                return { Ok = false, Message = "Не удалось начислить опыт." }
            end
            message = target.Name .. " поделился искрой роста: +" .. reward .. " XP!"
        elseif ability.Id == "FrostCache" then
            local reward = 80 + level * 12 + stars * 18
            if not EconomyService:GrantCoins(player, reward, "Морозный тайник") then
                return { Ok = false, Message = "Не удалось выдать награду." }
            end
            message = target.Name .. " нашёл под снегом тайник: +" .. reward .. " монет!"
        elseif ability.Id == "AuroraGaze" then
            local reward = 45 + level * 6 + stars * 12
            if not ProgressionService:AddXP(player, reward) then
                return { Ok = false, Message = "Не удалось начислить опыт." }
            end
            message = target.Name .. " увидел древнее сияние: +" .. reward .. " XP!"
        elseif ability.Id == "GlacierGuard" then
            profile.Nest = type(profile.Nest) == "table" and profile.Nest or {}
            local reward = 160 + level * 20 + stars * 30
            local stored = math.max(0, math.floor(tonumber(profile.Nest.StoredCoins) or 0))
            profile.Nest.StoredCoins = math.min(2_000_000_000, stored + reward)
            message = target.Name .. " укрепил гнездо: +" .. reward .. " монет в хранилище!"
        elseif ability.Id == "CinderHide" then
            player:SetAttribute("HeatHideUntil", os.clock() + 35)
            message = target.Name .. " укрыл тебя угольной шёрсткой на 35 секунд!"
        elseif ability.Id == "MagmaWard" then
            player:SetAttribute("HeatGuardUntil", os.clock() + 18)
            message = target.Name .. " создал магмовую защиту на 18 секунд!"
        elseif ability.Id == "PhoenixRenewal" then
            player:SetAttribute("HeatPhoenixReady", true)
            message = target.Name .. " готов возродить тебя при критическом перегреве!"
        else
            return { Ok = false, Message = "Неизвестная способность питомца." }
        end

        target.AbilityReadyAt = now + math.max(30, math.floor(tonumber(ability.CooldownSeconds) or 300))
        player:SetAttribute("LastNotice", message)
        return { Ok = true, Data = makeSnapshot(profile), Message = message }
    end

    if payload.Action == "Train" then
        local target
        for _, companion in ipairs(profile.Companions) do
            if companion.InstanceId == payload.InstanceId then target = companion break end
        end
        if not target then return { Ok = false, Message = "Питомец не найден." } end
        local level = math.clamp(math.floor(tonumber(target.Level) or 1), 1, MAX_COMPANION_LEVEL)
        if level >= MAX_COMPANION_LEVEL then
            return { Ok = false, Message = "Питомец достиг максимального уровня." }
        end
        local cost = 30 + level * 25
        if profile.Coins < cost then
            return { Ok = false, Message = "Для тренировки нужно " .. cost .. " монет." }
        end

        profile.Coins -= cost
        target.GrowthXP = math.max(0, math.floor(tonumber(target.GrowthXP) or 0)) + TRAIN_XP
        local levelsGained = 0
        while target.Level < MAX_COMPANION_LEVEL do
            local requiredXP = 100 + (target.Level - 1) * 55
            if target.GrowthXP < requiredXP then break end
            target.GrowthXP -= requiredXP
            target.Level += 1
            levelsGained += 1
        end
        updateCompanionIncome(target)
        player:SetAttribute("Coins", profile.Coins)
        CompanionService:RefreshPlayer(player)
        DisplayPetService:RefreshPlayer(player)
        local stageName = getGrowthStage(target.Level)
        local message = levelsGained > 0
            and (target.Name .. " вырос! Стадия: " .. stageName .. " · уровень " .. target.Level)
            or (target.Name .. " получил опыт тренировки.")
        player:SetAttribute("LastNotice", message)
        return { Ok = true, Data = makeSnapshot(profile), Message = message }
    end

    if payload.Action == "Merge" then
        local equipped = activeSet(profile)
        local target
        for _, companion in ipairs(profile.Companions) do
            if companion.InstanceId == payload.InstanceId then
                target = companion
                break
            end
        end
        if not target then
            return { Ok = false, Message = "Питомец не найден." }
        end

        for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
            if displayedId == target.InstanceId then
                return { Ok = false, Message = "Сними питомца с витрины перед слиянием." }
            end
        end
        local currentStars = math.clamp(math.floor(tonumber(target.Stars) or 1), 1, 3)
        if currentStars >= 3 then
            return { Ok = false, Message = "У этого питомца уже максимальный ранг." }
        end

        local consumed = {}
        for _, companion in ipairs(profile.Companions) do
            if companion ~= target
                and companion.Id == target.Id
                and (companion.Stars or 1) == currentStars
                and not (function()
                    for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
                        if displayedId == companion.InstanceId then return true end
                    end
                    return false
                end)()
                and #consumed < 2 then
                table.insert(consumed, companion)
            end
        end
        if #consumed < 2 then
            return { Ok = false, Message = "Для слияния нужны 3 одинаковых питомца одного ранга." }
        end

        local removedIds = {}
        for _, companion in ipairs(consumed) do
            removedIds[companion.InstanceId] = true
        end

        local nextActive = {}
        local targetWasActive = equipped[target.InstanceId] == true
        local transferSlot = false
        for _, instanceId in ipairs(profile.ActiveCompanions) do
            if removedIds[instanceId] then
                transferSlot = true
            elseif instanceId == target.InstanceId then
                targetWasActive = true
                table.insert(nextActive, instanceId)
            else
                table.insert(nextActive, instanceId)
            end
        end
        if transferSlot and not targetWasActive and #nextActive < MAX_ACTIVE_COMPANIONS then
            table.insert(nextActive, target.InstanceId)
        end
        profile.ActiveCompanions = nextActive

        for index = #profile.Companions, 1, -1 do
            if removedIds[profile.Companions[index].InstanceId] then
                table.remove(profile.Companions, index)
            end
        end

        target.Stars = currentStars + 1
        local definition = CompanionCatalog[target.Id]
        target.Level = math.clamp(math.floor(tonumber(target.Level) or 1), 1, MAX_COMPANION_LEVEL)
        target.GrowthXP = math.max(0, math.floor(tonumber(target.GrowthXP) or 0))
        updateCompanionIncome(target)

        CompanionService:RefreshPlayer(player)
        DisplayPetService:RefreshPlayer(player)
        player:SetAttribute("CompanionCount", #profile.Companions)
        player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
        player:SetAttribute("LastNotice", target.Name .. " достиг ранга " .. target.Stars .. " звезды!")
        return { Ok = true, Data = makeSnapshot(profile) }
    end

    local equipped = activeSet(profile)
    if payload.Action == "Equip" then
        for _, displayedId in pairs(profile.Nest and profile.Nest.DisplayedCompanions or {}) do
            if displayedId == payload.InstanceId then
                return { Ok = false, Message = "Сначала сними питомца с витрины." }
            end
        end
        if equipped[payload.InstanceId] then
            return { Ok = true, Data = makeSnapshot(profile) }
        end
        if #profile.ActiveCompanions >= MAX_ACTIVE_COMPANIONS then
            return { Ok = false, Message = "Можно взять с собой только 3 питомцев." }
        end
        table.insert(profile.ActiveCompanions, payload.InstanceId)
    else
        local nextActive = {}
        for _, instanceId in ipairs(profile.ActiveCompanions) do
            if instanceId ~= payload.InstanceId then table.insert(nextActive, instanceId) end
        end
        profile.ActiveCompanions = nextActive
    end

    CompanionService:RefreshPlayer(player)
    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
    return { Ok = true, Data = makeSnapshot(profile) }
end

function InventoryService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end
    local inventoryFunction = remotes:FindFirstChild("CompanionInventory")
    if not inventoryFunction then
        inventoryFunction = Instance.new("RemoteFunction")
        inventoryFunction.Name = "CompanionInventory"
        inventoryFunction.Parent = remotes
    end
    inventoryFunction.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

    local function bindPlayer(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then
                local profile = PlayerDataService:GetProfile(player)
                if profile then
                    normalizeProfile(profile)
                    player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
                    CompanionService:RefreshPlayer(player)
                end
            end
        end)
        if player:GetAttribute("ProfileLoaded") then
            local profile = PlayerDataService:GetProfile(player)
            if profile then
                normalizeProfile(profile)
                player:SetAttribute("ActiveCompanionCount", #profile.ActiveCompanions)
                CompanionService:RefreshPlayer(player)
            end
        end
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player) self._lastRequest[player] = nil end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return InventoryService
