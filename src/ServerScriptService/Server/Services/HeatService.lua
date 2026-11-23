local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local HeatService = {}
local TICK_SECONDS = 0.5
local MAX_HEAT = 100
local DEFAULT_COOLING = 6
local DAMAGE_PER_SECOND = 8

local function pointInside(part, point)
    local localPoint = part.CFrame:PointToObjectSpace(point)
    local half = part.Size * 0.5
    return math.abs(localPoint.X) <= half.X
        and math.abs(localPoint.Y) <= half.Y
        and math.abs(localPoint.Z) <= half.Z
end

local function activeProtection(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return 0 end
    local active = {}
    for _, instanceId in ipairs(profile.ActiveCompanions or {}) do active[instanceId] = true end
    local reduction = 0
    for _, companion in ipairs(profile.Companions or {}) do
        if active[companion.InstanceId] then
            if companion.Id == "CinderFox" then reduction = math.max(reduction, 0.12) end
            if companion.Id == "MagmaWhelp" then reduction = math.max(reduction, 0.22) end
            if companion.Id == "AshPhoenix" then reduction = math.max(reduction, 0.08) end
        end
    end
    return reduction
end

local function getZoneEffects(root, world)
    local heatRate = 0
    local coolingRate = DEFAULT_COOLING
    local inEmberlands = false
    local zones = world and world:FindFirstChild("Emberlands")
    local heatFolder = zones and zones:FindFirstChild("HeatZones")
    for _, zone in ipairs(heatFolder and heatFolder:GetChildren() or {}) do
        if zone:IsA("BasePart") and pointInside(zone, root.Position) then
            heatRate = math.max(heatRate, tonumber(zone:GetAttribute("HeatPerSecond")) or 0)
            inEmberlands = true
        end
    end
    local sanctuary = zones and zones:FindFirstChild("CoolingSanctuary")
    local base = sanctuary and sanctuary:FindFirstChild("CoolingZone")
    if base and pointInside(base, root.Position) then
        coolingRate = tonumber(base:GetAttribute("CoolingPerSecond")) or 24
        heatRate = 0
        inEmberlands = true
    end
    return heatRate, coolingRate, inEmberlands
end

function HeatService:Init()
    self._running = false
    self._lastDamage = {}
    local function bind(player)
        player:SetAttribute("Heat", 0)
        player:SetAttribute("HeatInDanger", false)
        player:SetAttribute("HeatInSanctuary", false)
        player:SetAttribute("HeatProtection", 0)
        player:SetAttribute("HeatPhoenixReady", true)
        player.CharacterAdded:Connect(function()
            player:SetAttribute("Heat", 0)
            player:SetAttribute("HeatInDanger", false)
            self._lastDamage[player] = 0
        end)
    end
    Players.PlayerAdded:Connect(bind)
    Players.PlayerRemoving:Connect(function(player)
        self._lastDamage[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do bind(player) end
end

function HeatService:Start()
    if self._running then return end
    self._running = true
    task.spawn(function()
        while self._running do
            local world = Workspace:FindFirstChild("NestRaidersWorld")
            for _, player in ipairs(Players:GetPlayers()) do
                if player:GetAttribute("ProfileLoaded") then
                    local character = player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if root and humanoid and humanoid.Health > 0 then
                        local heatRate, coolingRate, inEmberlands = getZoneEffects(root, world)
                        local reduction = activeProtection(player)
                        if (tonumber(player:GetAttribute("HeatGuardUntil")) or 0) > os.clock() then
                            reduction = 1
                        elseif (tonumber(player:GetAttribute("HeatHideUntil")) or 0) > os.clock() then
                            reduction = math.max(reduction, 0.55)
                        end
                        local current = math.clamp(tonumber(player:GetAttribute("Heat")) or 0, 0, MAX_HEAT)
                        if heatRate > 0 then
                            current = current + heatRate * (1 - reduction) * TICK_SECONDS
                        else
                            current = current - coolingRate * TICK_SECONDS
                        end
                        current = math.clamp(current, 0, MAX_HEAT)
                        player:SetAttribute("Heat", math.floor(current + 0.5))
                        player:SetAttribute("HeatInDanger", current >= 70)
                        player:SetAttribute("HeatInSanctuary", inEmberlands and heatRate == 0 and coolingRate > DEFAULT_COOLING)
                        player:SetAttribute("HeatProtection", math.floor(reduction * 100 + 0.5))
                        player:SetAttribute("HeatInEmberlands", inEmberlands)

                        if current >= MAX_HEAT and os.clock() - (self._lastDamage[player] or 0) >= 1 then
                            self._lastDamage[player] = os.clock()
                            local damage = DAMAGE_PER_SECOND
                            if player:GetAttribute("HeatPhoenixReady") == true then
                                local profile = PlayerDataService:GetProfile(player)
                                local activeIds = {}
                                for _, id in ipairs(profile and profile.ActiveCompanions or {}) do activeIds[id] = true end
                                local hasPhoenix = false
                                for _, pet in ipairs(profile and profile.Companions or {}) do
                                    if activeIds[pet.InstanceId] and pet.Id == "AshPhoenix" then hasPhoenix = true break end
                                end
                                if hasPhoenix then
                                    player:SetAttribute("HeatPhoenixReady", false)
                                    current = 65
                                    player:SetAttribute("Heat", current)
                                    player:SetAttribute("LastNotice", "Пепельный феникс спас тебя от перегрева!")
                                    damage = 0
                                end
                            end
                            if damage > 0 then
                                humanoid:TakeDamage(damage)
                                player:SetAttribute("LastNotice", "Критический перегрев! Срочно найди убежище!")
                            end
                        end
                    end
                end
            end
            task.wait(TICK_SECONDS)
        end
    end)
end

return HeatService
