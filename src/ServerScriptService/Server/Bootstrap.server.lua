local ServerScriptService = game:GetService("ServerScriptService")
local ServerFolder = ServerScriptService:WaitForChild("Server")
local ServicesFolder = ServerFolder:WaitForChild("Services")
local WorldBuilder = require(ServerFolder:WaitForChild("World"):WaitForChild("WorldBuilder"))

WorldBuilder:Build()

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
    if not remoteFolder:FindFirstChild(remoteName) then
        local remote = Instance.new("RemoteFunction")
        remote.Name = remoteName
        remote.Parent = remoteFolder
    end
end

local serviceNames = { "PlayerDataService", "ProgressionService", "PlotService", "NestService", "NestDecorService", "NestBuildService", "IslandVisitService", "IslandContestService", "PublicProfileService", "CompanionService", "DisplayPetService", "InventoryService", "EggShopService", "CollectionBookService", "EggService", "EconomyService" }
local services = {}
for _, serviceName in ipairs(serviceNames) do
    services[serviceName] = require(ServicesFolder:WaitForChild(serviceName))
end

for _, serviceName in ipairs(serviceNames) do
    local service = services[serviceName]
    if type(service.Init) == "function" then
        local ok, err = pcall(function() service:Init() end)
        if not ok then
            warn("[NEST RAIDERS] Service Init failed: " .. serviceName .. " | " .. tostring(err))
        end
    end
end

for _, serviceName in ipairs(serviceNames) do
    local service = services[serviceName]
    if type(service.Start) == "function" then
        task.spawn(function()
            local ok, err = pcall(function() service:Start() end)
            if not ok then
                warn("[NEST RAIDERS] Service Start failed: " .. serviceName .. " | " .. tostring(err))
            end
        end)
    end
end

print("[NEST RAIDERS] Starter Island and gameplay services initialized.")
