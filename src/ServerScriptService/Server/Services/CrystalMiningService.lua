local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)

local CrystalMiningService = {}
local NODE_COOLDOWN_SECONDS = 180

local function activeSpecies(profile)
    local active = {}
    for _, instanceId in ipairs(profile.ActiveCompanions or {}) do
        active[instanceId] = true
    end
    local species = {}
    for _, companion in ipairs(profile.Companions or {}) do
        if active[companion.InstanceId] then
            species[companion.Id] = true
        end
    end
    return species
end

function CrystalMiningService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local realm = world and world:FindFirstChild("CrystalRealm")
    local nodes = realm and realm:FindFirstChild("CrystalVeins")
    if not nodes then
        warn("[NEST RAIDERS] Crystal veins are missing; mining prompts were not connected.")
        return
    end

    for _, node in ipairs(nodes:GetChildren()) do
        local prompt = node:FindFirstChild("MineCrystalPrompt")
        if node:IsA("BasePart") and prompt and prompt:IsA("ProximityPrompt") then
            prompt.Triggered:Connect(function(player)
                if not player.Parent or player:GetAttribute("CurrentBiome") ~= "CrystalRealm" then
                    if player.Parent then player:SetAttribute("LastNotice", "Добывать кристаллы можно только в Хрустальном королевстве.") end
                    return
                end
                local allowed = ProgressionService:CanEnterZone(player, "CrystalRealm")
                if not allowed then
                    player:SetAttribute("LastNotice", "Сначала достигни 35 уровня и пройди Испытание Огненного сердца.")
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
                materials.CrystalNodeCooldowns = type(materials.CrystalNodeCooldowns) == "table"
                    and materials.CrystalNodeCooldowns or {}
                local nodeId = node:GetAttribute("CrystalNodeId")
                if type(nodeId) ~= "string" or nodeId == "" then
                    warn("[NEST RAIDERS] Ignored crystal node without a stable ID.")
                    return
                end

                local now = os.time()
                local readyAt = tonumber(materials.CrystalNodeCooldowns[nodeId]) or 0
                if readyAt > now then
                    local remaining = readyAt - now
                    player:SetAttribute("LastNotice", string.format("Жила восстанавливается. Осталось: %d мин. %d сек.", math.floor(remaining / 60), remaining % 60))
                    return
                end

                local species = activeSpecies(profile)
                local amount = math.random(2, 4)
                if species.PrismFox then amount += 1 end
                if species.CrystalDeer then amount += 1 end
                if species.AuroraDragon and math.random() < 0.35 then amount += 2 end

                materials.CrystalNodeCooldowns[nodeId] = now + NODE_COOLDOWN_SECONDS
                materials.CrystalShard = math.max(0, math.floor(tonumber(materials.CrystalShard) or 0)) + amount
                player:SetAttribute("CrystalShards", materials.CrystalShard)
                player:SetAttribute("LastNotice", string.format("Добыто кристальных осколков: +%d. Всего: %d.", amount, materials.CrystalShard))
            end)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local profile = PlayerDataService:GetProfile(player)
        local materials = profile and profile.Materials or {}
        player:SetAttribute("CrystalShards", math.max(0, math.floor(tonumber(materials.CrystalShard) or 0)))
    end
    Players.PlayerAdded:Connect(function(player)
        task.spawn(function()
            while player.Parent and not player:GetAttribute("ProfileLoaded") do task.wait(0.1) end
            if not player.Parent then return end
            local profile = PlayerDataService:GetProfile(player)
            local materials = profile and profile.Materials or {}
            player:SetAttribute("CrystalShards", math.max(0, math.floor(tonumber(materials.CrystalShard) or 0)))
        end)
    end)
end

return CrystalMiningService
