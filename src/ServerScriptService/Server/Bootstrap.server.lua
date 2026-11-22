local ServerScriptService = game:GetService("ServerScriptService")
local ServicesFolder = ServerScriptService:WaitForChild("Server"):WaitForChild("Services")

local serviceNames = {
    "PlayerDataService",
    "ProgressionService",
}

for _, serviceName in ipairs(serviceNames) do
    local moduleScript = ServicesFolder:WaitForChild(serviceName)
    local service = require(moduleScript)

    if type(service.Init) == "function" then
        service:Init()
    end
end

for _, serviceName in ipairs(serviceNames) do
    local service = require(ServicesFolder:WaitForChild(serviceName))

    if type(service.Start) == "function" then
        task.spawn(function()
            service:Start()
        end)
    end
end

print("[NEST RAIDERS] Server systems initialized.")
