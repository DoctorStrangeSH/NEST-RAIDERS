local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local ArtifactBonusService = require(ServerScriptService.Server.Services.ArtifactBonusService)

local AncientHarvestService = {}
local NODE_COOLDOWN_SECONDS = 180
local HARVEST_LOCKS = {}

local function syncBalance(player, profile)
    local materials = profile and profile.Materials or {}
    player:SetAttribute("Elderwood", math.max(0, math.floor(tonumber(materials.Elderwood) or 0)))
end

local function harvest(player, node, prompt)
    if not player.Parent or player:GetAttribute("CurrentBiome") ~= "AncientHeights" then
        if player.Parent then player:SetAttribute("LastNotice", "Древесную эссенцию можно собирать только в Древних высотах.") end
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
        or (root.Position - node.Position).Magnitude > prompt.MaxActivationDistance + 2 then
        return
    end

    local profile = PlayerDataService:GetProfile(player)
    if not profile then
        player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
        return
    end
    profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
    local materials = profile.Materials
    materials.ElderwoodNodeCooldowns = type(materials.ElderwoodNodeCooldowns) == "table"
        and materials.ElderwoodNodeCooldowns or {}
    local nodeId = node:GetAttribute("ElderwoodNodeId")
    if type(nodeId) ~= "string" or nodeId == "" then return end

    local now = os.time()
    local readyAt = tonumber(materials.ElderwoodNodeCooldowns[nodeId]) or 0
    if readyAt > now then
        local remaining = readyAt - now
        player:SetAttribute("LastNotice", string.format(
            "Древний корень восстанавливается. Осталось: %d мин. %d сек.",
            math.floor(remaining / 60), remaining % 60))
        return
    end

    local baseAmount = math.random(1, 3)
    local amount, gatherBonus, extraMaterials = ArtifactBonusService:ApplyGatherBonus(profile, baseAmount)
    materials.ElderwoodNodeCooldowns[nodeId] = now + NODE_COOLDOWN_SECONDS
    materials.Elderwood = math.max(0, math.floor(tonumber(materials.Elderwood) or 0)) + amount
    syncBalance(player, profile)
    player:SetAttribute("LastNotice", string.format(
        "Собрано древесной эссенции: +%d%s. Всего: %d.",
        amount, gatherBonus > 0 and string.format(" · артефакт: +%d ресурс(ов) (шанс +%d%%)",
            extraMaterials, math.floor(gatherBonus * 100 + 0.5)) or "",
        materials.Elderwood))
end

function AncientHarvestService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local ancient = world and world:FindFirstChild("AncientHeights")
    local nodes = ancient and ancient:FindFirstChild("ElderwoodNodes")
    if not nodes then
        warn("[NEST RAIDERS] Ancient Elderwood nodes are missing; harvest prompts were not connected.")
        return
    end

    for _, node in ipairs(nodes:GetChildren()) do
        local prompt = node:FindFirstChild("HarvestElderwoodPrompt")
        if node:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt") then
            prompt.Triggered:Connect(function(player)
                if HARVEST_LOCKS[player] then return end
                HARVEST_LOCKS[player] = true
                local ok, err = pcall(harvest, player, node, prompt)
                HARVEST_LOCKS[player] = nil
                if not ok then
                    warn("[NEST RAIDERS] Ancient harvest failed: " .. tostring(err))
                    if player.Parent then
                        player:SetAttribute("LastNotice", "Не удалось собрать эссенцию. Попробуй ещё раз.")
                    end
                end
            end)
        end
    end

    local function bindPlayer(player)
        local function sync()
            if not player.Parent or not player:GetAttribute("ProfileLoaded") then return end
            syncBalance(player, PlayerDataService:GetProfile(player))
        end
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(sync)
        sync()
    end
    Players.PlayerAdded:Connect(bindPlayer)
    Players.PlayerRemoving:Connect(function(player)
        HARVEST_LOCKS[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bindPlayer(player) end
end

return AncientHarvestService
