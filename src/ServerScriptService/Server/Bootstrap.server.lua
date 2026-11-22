local ServerScriptService = game:GetService("ServerScriptService")
local ServerFolder = ServerScriptService:WaitForChild("Server")
local ServicesFolder = ServerFolder:WaitForChild("Services")
local WorldBuilder = require(ServerFolder:WaitForChild("World"):WaitForChild("WorldBuilder"))

WorldBuilder:Build()

local serviceNames = { "PlayerDataService", "ProgressionService", "PlotService", "CompanionService", "InventoryService", "EggShopService", "EggService", "EconomyService" }
local services = {}
for _, serviceName in ipairs(serviceNames) do
    services[serviceName] = require(ServicesFolder:WaitForChild(serviceName))
end

for _, serviceName in ipairs(serviceNames) do
    local service = services[serviceName]
    if type(service.Init) == "function" then service:Init() end
end

for _, serviceName in ipairs(serviceNames) do
    local service = services[serviceName]
    if type(service.Start) == "function" then
        task.spawn(function() service:Start() end)
    end
end

print("[NEST RAIDERS] Starter Island and gameplay services initialized.")
