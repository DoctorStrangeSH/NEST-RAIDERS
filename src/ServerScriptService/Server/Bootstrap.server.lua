local ServerScriptService = game:GetService("ServerScriptService")
local ServerFolder = ServerScriptService:WaitForChild("Server")
local ServicesFolder = ServerFolder:WaitForChild("Services")
-- Publish every client endpoint before loading optional gameplay services.
-- This prevents the client HUD from waiting forever when a later service fails.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteFolder = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "NestRaidersRemotes"
    remoteFolder.Parent = ReplicatedStorage
end

for _, remoteName in ipairs({
    "CompanionInventory", "EggShop", "CollectionBook", "NestUpgrade",
    "DisplayPets", "NestDecor", "NestBuild", "IslandVisit",
    "IslandContest", "PublicProfile",
}) do
    local remote = remoteFolder:FindFirstChild(remoteName)
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = remoteName
        remote.Parent = remoteFolder
    end
    -- A published endpoint without a handler makes InvokeServer yield forever.
    -- Services replace this fallback when their own request handlers initialize.
    if remote:IsA("RemoteFunction") then
        remote.OnServerInvoke = function()
            return {
                Ok = false,
                Message = "Система ещё загружается или временно недоступна. Попробуй ещё раз.",
            }
        end
    else
        warn("[NEST RAIDERS] Unexpected network object: " .. remoteName)
        remoteFolder:SetAttribute("ServiceError_Remote_" .. remoteName, "Not a RemoteFunction")
    end
end

-- Build the world after endpoints exist; world errors must never hide all UI.
local worldOk, worldError = pcall(function()
    local builder = require(ServerFolder:WaitForChild("World"):WaitForChild("WorldBuilder"))
    builder:Build()
end)
if not worldOk then
    warn("[NEST RAIDERS] World build failed: " .. tostring(worldError))
    remoteFolder:SetAttribute("WorldError", tostring(worldError))
end

local serviceNames = { "PlayerDataService", "ProgressionService", "PlotService", "NestService", "NestDecorService", "NestBuildService", "IslandVisitService", "IslandContestService", "PublicProfileService", "CompanionService", "DisplayPetService", "InventoryService", "EggShopService", "CollectionBookService", "EggService", "EconomyService" }
local services = {}
for _, serviceName in ipairs(serviceNames) do
    local ok, result = pcall(function()
        return require(ServicesFolder:WaitForChild(serviceName, 10))
    end)
    if ok and type(result) == "table" then
        services[serviceName] = result
    else
        local message = tostring(result)
        warn("[NEST RAIDERS] Service Load failed: " .. serviceName .. " | " .. message)
        remoteFolder:SetAttribute("ServiceError_" .. serviceName, message)
    end
end

for _, serviceName in ipairs(serviceNames) do
    local service = services[serviceName]
    if service and type(service.Init) == "function" then
        local ok, err = pcall(function() service:Init() end)
        if not ok then
            warn("[NEST RAIDERS] Service Init failed: " .. serviceName .. " | " .. tostring(err))
            remoteFolder:SetAttribute("ServiceError_" .. serviceName, tostring(err))
        end
    end
end

for _, serviceName in ipairs(serviceNames) do
    local service = services[serviceName]
    if service and type(service.Start) == "function" then
        task.spawn(function()
            local ok, err = pcall(function() service:Start() end)
            if not ok then
                warn("[NEST RAIDERS] Service Start failed: " .. serviceName .. " | " .. tostring(err))
                remoteFolder:SetAttribute("ServiceError_" .. serviceName, tostring(err))
            end
        end)
    end
end

print("[NEST RAIDERS] Boot sequence dispatched; check Output and NestRaidersRemotes attributes for service errors.")
