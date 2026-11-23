local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

local AncientSecretService = {}
local CLAIM_LOCKS = {}
local GROVE_RUNE_ORDER = { "Moon", "Leaf", "Dew", "Star" }

function AncientSecretService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local grove = ancient and ancient:FindFirstChild("WhisperingGrove")
    local altar = grove and grove:FindFirstChild("ElderHeartAltar")
    local prompt = altar and altar:FindFirstChild("ElderHeartPrompt")
    if not prompt then
        warn("[NEST RAIDERS] Whispering Grove altar is missing.")
        return
    end

    local runePrompts = {}
    for _, descendant in ipairs(grove:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant:GetAttribute("GroveCacheRuneId") then
            local runePrompt = descendant:FindFirstChild("GroveCacheRunePrompt")
            if runePrompt and runePrompt:IsA("ProximityPrompt") then
                table.insert(runePrompts, { Part = descendant, Prompt = runePrompt })
            end
        end
    end

    local cache = grove:FindFirstChild("WhisperingGroveCache")
    local cacheBase = cache and cache:FindFirstChild("WhisperingGroveCacheBase")
    local cachePrompt = cacheBase and cacheBase:FindFirstChild("WhisperingGroveCachePrompt")

    local function validateGrovePlayer(player, target, promptObject)
        if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
            if player.Parent then
                player:SetAttribute("LastNotice", "Секрет рощи можно раскрыть только в Древних высотах.")
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
            or (root.Position - target.Position).Magnitude > promptObject.MaxActivationDistance + 2 then
            return false
        end
        return true
    end

    local function getGroveProgress(profile)
        profile.QuestProgress = type(profile.QuestProgress) == "table" and profile.QuestProgress or {}
        profile.QuestProgress.GroveCacheRunes = type(profile.QuestProgress.GroveCacheRunes) == "table"
            and profile.QuestProgress.GroveCacheRunes or {}
        return profile.QuestProgress.GroveCacheRunes
    end

    for _, entry in ipairs(runePrompts) do
        entry.Prompt.Triggered:Connect(function(player)
            if CLAIM_LOCKS[player] then return end
            CLAIM_LOCKS[player] = true
            local ok, err = pcall(function()
                if not validateGrovePlayer(player, entry.Part, entry.Prompt) then return end
                local profile = PlayerDataService:GetProfile(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                    return
                end
                profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
                if profile.CompletedQuests.whispering_grove_cache == true then
                    player:SetAttribute("LastNotice", "Тайник четырёх рун уже открыт.")
                    return
                end
                local sequence = getGroveProgress(profile)
                local expectedIndex = #sequence + 1
                local runeId = entry.Part:GetAttribute("GroveCacheRuneId")
                if runeId == GROVE_RUNE_ORDER[expectedIndex] then
                    table.insert(sequence, runeId)
                    player:SetAttribute("WhisperingGroveRuneProgress", #sequence)
                    if #sequence == #GROVE_RUNE_ORDER then
                        player:SetAttribute("LastNotice", "Все четыре руны отозвались! Тайник спрятан за алтарём.")
                    else
                        player:SetAttribute("LastNotice", string.format(
                            "Руна %d из 4 пробуждена. Прислушайся к шёпоту рощи.", #sequence))
                    end
                else
                    profile.QuestProgress.GroveCacheRunes = {}
                    player:SetAttribute("WhisperingGroveRuneProgress", 0)
                    player:SetAttribute("LastNotice", "Роща затихла. Последовательность сброшена: Луна → Лист → Роса → Звезда.")
                end
            end)
            CLAIM_LOCKS[player] = nil
            if not ok then
                warn("[NEST RAIDERS] Grove rune interaction failed: " .. tostring(err))
                if player.Parent then player:SetAttribute("LastNotice", "Руна не откликнулась. Попробуй ещё раз.") end
            end
        end)
    end

    if cachePrompt and cacheBase then
        cachePrompt.Triggered:Connect(function(player)
            if CLAIM_LOCKS[player] then return end
            CLAIM_LOCKS[player] = true
            local ok, err = pcall(function()
                if not validateGrovePlayer(player, cacheBase, cachePrompt) then return end
                local profile = PlayerDataService:GetProfile(player)
                if not profile then
                    player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                    return
                end
                profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
                if profile.CompletedQuests.whispering_grove_cache == true then
                    player:SetAttribute("LastNotice", "Тайник уже опустел. Его сокровища принадлежат тебе.")
                    return
                end
                local sequence = getGroveProgress(profile)
                if #sequence < #GROVE_RUNE_ORDER then
                    player:SetAttribute("LastNotice", "Тайник запечатан. Сначала пробуди четыре руны: Луна → Лист → Роса → Звезда.")
                    return
                end
                profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
                profile.Materials.Moonpetal = math.max(0, math.floor(tonumber(profile.Materials.Moonpetal) or 0)) + 5
                profile.CompletedQuests.whispering_grove_cache = true
                player:SetAttribute("Moonpetal", profile.Materials.Moonpetal)
                player:SetAttribute("WhisperingGroveCacheOpened", true)
                player:SetAttribute("LastNotice", "Тайник открыт! +5 лунных лепестков · +400 монет · +200 опыта.")
                EconomyService:GrantCoins(player, 400, "Тайник четырёх рун")
                ProgressionService:AddXP(player, 200)
            end)
            CLAIM_LOCKS[player] = nil
            if not ok then
                warn("[NEST RAIDERS] Grove cache claim failed: " .. tostring(err))
                if player.Parent then player:SetAttribute("LastNotice", "Не удалось открыть тайник. Попробуй ещё раз.") end
            end
        end)
    else
        warn("[NEST RAIDERS] Whispering Grove rune cache is missing.")
    end

    prompt.Triggered:Connect(function(player)
        if CLAIM_LOCKS[player] then return end
        CLAIM_LOCKS[player] = true
        local ok, err = pcall(function()
            if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
                if player.Parent then player:SetAttribute("LastNotice", "Секрет рощи можно раскрыть только в Древних высотах.") end
                return
            end
            local allowed = ProgressionService:CanEnterZone(player, "AncientHeights")
            if not allowed then
                player:SetAttribute("LastNotice", "Сначала достигни 50 уровня и пройди Испытание призмы.")
                return
            end
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not root or not humanoid or humanoid.Health <= 0
                or (root.Position - altar.Position).Magnitude > prompt.MaxActivationDistance + 2 then
                return
            end
            local profile = PlayerDataService:GetProfile(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            profile.CompletedQuests = type(profile.CompletedQuests) == "table" and profile.CompletedQuests or {}
            if profile.CompletedQuests.ancient_grove_secret == true then
                player:SetAttribute("LastNotice", "Сердце рощи уже поделилось с тобой своей силой.")
                return
            end

            profile.CompletedQuests.ancient_grove_secret = true
            profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
            profile.Materials.Elderwood = math.max(0, math.floor(tonumber(profile.Materials.Elderwood) or 0)) + 8
            player:SetAttribute("Elderwood", profile.Materials.Elderwood)
            EconomyService:GrantCoins(player, 250, "Секрет древней рощи")
            ProgressionService:AddXP(player, 150)
            player:SetAttribute("AncientGroveSecretFound", true)
            player:SetAttribute("LastNotice", "Сердце древней рощи пробуждено! +250 монет · +150 опыта · +8 древесной эссенции.")
        end)
        CLAIM_LOCKS[player] = nil
        if not ok then
            warn("[NEST RAIDERS] Ancient secret claim failed: " .. tostring(err))
            if player.Parent then
                player:SetAttribute("LastNotice", "Не удалось пробудить сердце рощи. Попробуй ещё раз.")
            end
        end
    end)

    local Players = game:GetService("Players")
    local boundPlayers = {}
    local function bindPlayer(player)
        if boundPlayers[player] then return end
        boundPlayers[player] = true
        local function syncDiscovery()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            local profile = PlayerDataService:GetProfile(player)
            player:SetAttribute("AncientGroveSecretFound",
                profile and profile.CompletedQuests and profile.CompletedQuests.ancient_grove_secret == true or false)
            local progress = profile and profile.QuestProgress and profile.QuestProgress.GroveCacheRunes or {}
            player:SetAttribute("WhisperingGroveRuneProgress", type(progress) == "table" and #progress or 0)
            player:SetAttribute("WhisperingGroveCacheOpened",
                profile and profile.CompletedQuests and profile.CompletedQuests.whispering_grove_cache == true or false)
            local materials = profile and profile.Materials or {}
            player:SetAttribute("Moonpetal", math.max(0, math.floor(tonumber(materials.Moonpetal) or 0)) )
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(syncDiscovery)
        syncDiscovery()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        CLAIM_LOCKS[player] = nil
        boundPlayers[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return AncientSecretService
