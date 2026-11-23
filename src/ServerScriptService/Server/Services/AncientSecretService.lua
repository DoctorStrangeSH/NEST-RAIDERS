local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)

local AncientSecretService = {}
local CLAIM_LOCKS = {}

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
    Players.PlayerRemoving:Connect(function(player)
        CLAIM_LOCKS[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        local profile = PlayerDataService:GetProfile(player)
        player:SetAttribute("AncientGroveSecretFound",
            profile and profile.CompletedQuests and profile.CompletedQuests.ancient_grove_secret == true or false)
    end
    Players.PlayerAdded:Connect(function(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if not player:GetAttribute("ProfileLoaded") then return end
            local profile = PlayerDataService:GetProfile(player)
            player:SetAttribute("AncientGroveSecretFound",
                profile and profile.CompletedQuests and profile.CompletedQuests.ancient_grove_secret == true or false)
        end)
    end)
end

return AncientSecretService
