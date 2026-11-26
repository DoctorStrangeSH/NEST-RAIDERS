local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ArtifactBonusService = require(ServerScriptService.Server.Services.ArtifactBonusService)

local VoidHarvestService = {}
local NODE_COOLDOWN_SECONDS = 180
local LOCKS = {}

local function activeSpecies(profile)
    local active = {}
    for _, instanceId in ipairs(profile.ActiveCompanions or {}) do active[instanceId] = true end
    local species = {}
    for _, companion in ipairs(profile.Companions or {}) do
        if active[companion.InstanceId] then species[companion.Id] = true end
    end
    return species
end

local function harvest(player, node, prompt)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "VoidFrontier" then
        if player.Parent then player:SetAttribute("LastNotice", "Звёздные жилы можно добывать только на Границе пустоты.") end
        return
    end
    if not ProgressionService:CanEnterZone(player, "VoidFrontier") then
        player:SetAttribute("LastNotice", "Сначала открой Границу пустоты.")
        return
    end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0
        or (root.Position - node.Position).Magnitude > prompt.MaxActivationDistance + 2 then return end

    local profile = PlayerDataService:GetProfile(player)
    if not profile then
        player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
        return
    end
    profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
    local materials = profile.Materials
    materials.VoidNodeCooldowns = type(materials.VoidNodeCooldowns) == "table"
        and materials.VoidNodeCooldowns or {}
    local nodeId = node:GetAttribute("VoidShardNodeId")
    if type(nodeId) ~= "string" or nodeId == "" then
        warn("[NEST RAIDERS] Ignored Void Starshard node without a stable ID.")
        return
    end

    local now = os.time()
    local readyAt = tonumber(materials.VoidNodeCooldowns[nodeId]) or 0
    if readyAt > now then
        local remaining = readyAt - now
        player:SetAttribute("LastNotice", string.format(
            "Звёздная жила восстанавливается. Осталось: %d мин. %d сек.",
            math.floor(remaining / 60), remaining % 60))
        return
    end

    local amount = math.random(1, 3)
    local species = activeSpecies(profile)
    local petBonus = species.StarEater and math.random() < 0.3
    if petBonus then amount += 1 end
    local baseAmount = amount
    local gatherBonus, extraMaterials = 0, 0
    amount, gatherBonus, extraMaterials = ArtifactBonusService:ApplyGatherBonus(profile, baseAmount)
    materials.VoidNodeCooldowns[nodeId] = now + NODE_COOLDOWN_SECONDS
    materials.Starshard = math.max(0, math.floor(tonumber(materials.Starshard) or 0)) + amount
    player:SetAttribute("Starshard", materials.Starshard)
    player:SetAttribute("LastNotice", string.format(
        "Добыто звёздных осколков: +%d%s%s. Всего: %d.",
        amount,
        petBonus and " · Звёздный Пожиратель нашёл ещё один!" or "",
        gatherBonus > 0 and string.format(" · артефакт: +%d дополнительно", extraMaterials) or "",
        materials.Starshard))
end

function VoidHarvestService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local void = world and world:FindFirstChild("VoidFrontier")
    local nodes = void and void:FindFirstChild("VoidStarshardNodes")
    if not nodes then
        warn("[NEST RAIDERS] Void Starshard nodes are missing; harvest prompts were not connected.")
        return
    end

    for _, node in ipairs(nodes:GetChildren()) do
        local prompt = node:FindFirstChild("MineVoidShardPrompt")
        if node:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt") then
            prompt.Triggered:Connect(function(player)
                if LOCKS[player] then return end
                LOCKS[player] = true
                local ok, err = pcall(harvest, player, node, prompt)
                LOCKS[player] = nil
                if not ok then
                    warn("[NEST RAIDERS] Void harvest failed: " .. tostring(err))
                    if player.Parent then player:SetAttribute("LastNotice", "Не удалось добыть осколки. Попробуй ещё раз.") end
                end
            end)
        end
    end

    local function bindPlayer(player)
        local function sync()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            local profile = PlayerDataService:GetProfile(player)
            local materials = profile and profile.Materials or {}
            player:SetAttribute("Starshard", math.max(0, math.floor(tonumber(materials.Starshard) or 0)))
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(sync)
        sync()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player) LOCKS[player] = nil end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return VoidHarvestService
