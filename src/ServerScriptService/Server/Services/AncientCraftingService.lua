local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)

local AncientCraftingService = {}
local CRAFT_LOCKS = {}
local LAST_REQUEST_AT = {}
local REQUEST_COOLDOWN_SECONDS = 1.5
local EGG_CAPACITY = 20
local ELDERWOOD_COST = 10
local COIN_COST = 300
local EGG_ID = "AncientEgg"

local function getEggDefinition()
    local biome = BiomeCatalog.AncientHeights
    return biome and biome.Eggs and biome.Eggs[EGG_ID]
end

local function craft(player, station, prompt)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
        if player.Parent then
            player:SetAttribute("LastNotice", "Мастерская работает только в Древних высотах.")
        end
        return
    end

    local allowed = ProgressionService:CanEnterZone(player, "AncientHeights")
    if not allowed then
        player:SetAttribute("LastNotice", "Сначала открой Древние высоты.")
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - station.Position).Magnitude > prompt.MaxActivationDistance + 2 then
        return
    end

    local profile = PlayerDataService:GetProfile(player)
    if not profile then
        player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
        return
    end

    local eggDefinition = getEggDefinition()
    if not eggDefinition or eggDefinition.Id ~= EGG_ID then
        warn("[NEST RAIDERS] Ancient Egg crafting catalog entry is missing.")
        player:SetAttribute("LastNotice", "Рецепт древнего яйца временно недоступен.")
        return
    end

    profile.EggInventory = type(profile.EggInventory) == "table" and profile.EggInventory or {}
    if #profile.EggInventory >= EGG_CAPACITY then
        player:SetAttribute("LastNotice", "Сумка для яиц заполнена. Освободи место.")
        return
    end

    profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
    local elderwood = math.max(0, math.floor(tonumber(profile.Materials.Elderwood) or 0))
    local coins = math.max(0, math.floor(tonumber(profile.Coins) or 0))
    if elderwood < ELDERWOOD_COST then
        player:SetAttribute("LastNotice", string.format(
            "Не хватает эссенции: нужно %d, у тебя %d.", ELDERWOOD_COST, elderwood))
        return
    end
    if coins < COIN_COST then
        player:SetAttribute("LastNotice", string.format(
            "Не хватает монет: нужно %d, у тебя %d.", COIN_COST, coins))
        return
    end

    -- Spend only after every requirement and the target catalog entry are validated.
    profile.Materials.Elderwood = elderwood - ELDERWOOD_COST
    profile.Coins = coins - COIN_COST
    table.insert(profile.EggInventory, {
        Id = EGG_ID,
        BiomeId = "AncientHeights",
        InstanceId = HttpService:GenerateGUID(false),
        Origin = "Crafting",
        CollectedAt = os.time(),
    })

    player:SetAttribute("Elderwood", profile.Materials.Elderwood)
    player:SetAttribute("Coins", profile.Coins)
    player:SetAttribute("EggCount", #profile.EggInventory)
    player:SetAttribute("LastNotice", "Создано Яйцо древнего древа! Оно ждёт тебя на станции вылупления.")
end

function AncientCraftingService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local workshop = ancient and ancient:FindFirstChild("ElderwoodWorkshop")
    local station = workshop and workshop:FindFirstChild("AncientEggCraftingStation")
    local prompt = station and station:FindFirstChild("CraftAncientEggPrompt")
    if not prompt or not prompt:IsA("ProximityPrompt") then
        warn("[NEST RAIDERS] Ancient Egg crafting station is missing.")
        return
    end

    prompt.Triggered:Connect(function(player)
        if CRAFT_LOCKS[player] then return end
        local now = os.clock()
        if now - (LAST_REQUEST_AT[player] or 0) < REQUEST_COOLDOWN_SECONDS then return end
        LAST_REQUEST_AT[player] = now
        CRAFT_LOCKS[player] = true
        local ok, err = pcall(craft, player, station, prompt)
        CRAFT_LOCKS[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Ancient Egg crafting failed: " .. tostring(err))
            if player.Parent then
                player:SetAttribute("LastNotice", "Не удалось создать яйцо. Попробуй ещё раз.")
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        CRAFT_LOCKS[player] = nil
        LAST_REQUEST_AT[player] = nil
    end)
end

return AncientCraftingService
