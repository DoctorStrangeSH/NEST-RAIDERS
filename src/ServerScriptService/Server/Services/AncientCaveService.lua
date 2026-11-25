local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

local AncientCaveService = {}
local INTERACTION_LOCKS = {}
local CRYSTAL_ORDER = { "Root", "River", "Dawn" }

local function validatePlayer(player, target, prompt)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
        if player.Parent then
            player:SetAttribute("LastNotice", "Сердце пещеры откликается только в Древних высотах.")
        end
        return false
    end
    if not ProgressionService:CanEnterZone(player, "AncientHeights") then
        player:SetAttribute("LastNotice", "Сначала открой Древние высоты.")
        return false
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - target.Position).Magnitude > prompt.MaxActivationDistance + 2 then
        return false
    end
    return true
end

local function getProgress(profile)
    profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
    profile.QuestProgress.ForgottenCaveCrystals = type(profile.QuestProgress.ForgottenCaveCrystals) == "table"
        and profile.QuestProgress.ForgottenCaveCrystals or {}
    return profile.QuestProgress.ForgottenCaveCrystals
end

local function syncPlayer(player)
    if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
    local profile = PlayerDataService:GetProfile(player)
    local progress = profile and profile.QuestProgress and profile.QuestProgress.ForgottenCaveCrystals or {}
    player:SetAttribute("ForgottenCaveCrystalProgress", type(progress) == "table" and #progress or 0)
    player:SetAttribute("ForgottenCaveCacheOpened",
        profile and profile.CompletedQuests and profile.CompletedQuests.forgotten_cave_cache == true or false)
    local materials = profile and profile.Materials or {}
    player:SetAttribute("Starshard", math.max(0, math.floor(tonumber(materials.Starshard) or 0)))
end

function AncientCaveService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local cave = ancient and ancient:FindFirstChild("ForgottenHeartCave")
    if not cave then
        warn("[NEST RAIDERS] Forgotten Heart Cave is missing.")
        return
    end

    local crystalEntries = {}
    for _, descendant in ipairs(cave:GetChildren()) do
        if descendant:IsA("BasePart") and descendant:GetAttribute("CaveCrystalId") then
            local prompt = descendant:FindFirstChild("CaveCrystalPrompt")
            if prompt and prompt:IsA("ProximityPrompt") then
                table.insert(crystalEntries, { Part = descendant, Prompt = prompt })
            end
        end
    end
    local cache = cave:FindFirstChild("ForgottenCaveCache")
    local chest = cache and cache:FindFirstChild("ForgottenCaveChest")
    local chestPrompt = chest and chest:FindFirstChild("ForgottenCaveChestPrompt")
    if #crystalEntries ~= 3 or not chestPrompt then
        warn("[NEST RAIDERS] Forgotten Cave puzzle objects are incomplete.")
        return
    end

    local function withPlayerLock(player, callback, failureMessage)
        if INTERACTION_LOCKS[player] then return end
        INTERACTION_LOCKS[player] = true
        local ok, err = pcall(callback)
        INTERACTION_LOCKS[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Forgotten Cave interaction failed: " .. tostring(err))
            if player.Parent then player:SetAttribute("LastNotice", failureMessage) end
        end
    end

    for _, entry in ipairs(crystalEntries) do
        entry.Prompt.Triggered:Connect(function(player)
            withPlayerLock(player, function()
                if not validatePlayer(player, entry.Part, entry.Prompt) then return end
                local profile = PlayerDataService:GetProfile(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                    return
                end
                profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
                if profile.CompletedQuests.forgotten_cave_cache == true then
                    player:SetAttribute("LastNotice", "Сердце пещеры уже пробуждено.")
                    return
                end
                local sequence = getProgress(profile)
                local expected = CRYSTAL_ORDER[#sequence + 1]
                local crystalId = entry.Part:GetAttribute("CaveCrystalId")
                if crystalId == expected then
                    table.insert(sequence, crystalId)
                    player:SetAttribute("ForgottenCaveCrystalProgress", #sequence)
                    player:SetAttribute("LastNotice", #sequence == #CRYSTAL_ORDER
                        and "Три кристалла запели в унисон. Сокровищница разблокирована!"
                        or string.format("Кристалл пробуждён: %d / 3. Пещера отвечает эхом.", #sequence))
                else
                    profile.QuestProgress.ForgottenCaveCrystals = {}
                    player:SetAttribute("ForgottenCaveCrystalProgress", 0)
                    player:SetAttribute("LastNotice", "Кристаллы погасли. Начни заново: Корень → Река → Рассвет.")
                end
            end, "Кристалл не откликнулся. Попробуй ещё раз.")
        end)
    end

    chestPrompt.Triggered:Connect(function(player)
        withPlayerLock(player, function()
            if not validatePlayer(player, chest, chestPrompt) then return end
            local profile = PlayerDataService:GetProfile(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
            if profile.CompletedQuests.forgotten_cave_cache == true then
                player:SetAttribute("LastNotice", "Сокровищница уже открыта. Сокровище сохранено в твоём профиле.")
                return
            end
            local sequence = getProgress(profile)
            if #sequence < #CRYSTAL_ORDER then
                player:SetAttribute("LastNotice", "Сокровищница запечатана. Пробуди кристаллы: Корень → Река → Рассвет.")
                return
            end
            profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
            if #profile.EggInventory >= 20 then
                player:SetAttribute("LastNotice", "Сумка для яиц заполнена. Освободи место и открой сокровищницу снова.")
                return
            end
            profile.Materials.Starshard = math.max(0, math.floor(tonumber(profile.Materials.Starshard) or 0)) + 3
            table.insert(profile.EggInventory, {
                Id = "ForgottenCaveEgg",
                BiomeId = "ForgottenCave",
                InstanceId = HttpService:GenerateGUID(false),
                CollectedAt = os.time(),
                Source = "ForgottenCaveCache",
            })
            profile.CompletedQuests.forgotten_cave_cache = true
            player:SetAttribute("Starshard", profile.Materials.Starshard)
            player:SetAttribute("EggCount", #profile.EggInventory)
            player:SetAttribute("ForgottenCaveCacheOpened", true)
            player:SetAttribute("LastNotice", "Сокровищница открыта! Особое яйцо пещеры · +3 звёздных осколка · +600 монет · +300 опыта.")
            EconomyService:GrantCoins(player, 600, "Сокровищница забытого сердца")
            ProgressionService:AddXP(player, 300)
        end, "Сокровищница не открылась. Попробуй ещё раз.")
    end)

    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            syncPlayer(player)
        end)
        syncPlayer(player)
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        INTERACTION_LOCKS[player] = nil
        boundPlayers[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return AncientCaveService
