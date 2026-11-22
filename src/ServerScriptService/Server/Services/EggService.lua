local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local EggService = {}
local EGG_RESPAWN_SECONDS = 20
local EGG_CAPACITY = 20
local COMPANIONS = {
    { Id = "MeadowFox", Name = "Meadow Fox", Rarity = "Common", Income = 2, Weight = 55 },
    { Id = "MossTurtle", Name = "Moss Turtle", Rarity = "Uncommon", Income = 4, Weight = 30 },
    { Id = "SproutDragon", Name = "Sprout Dragon", Rarity = "Rare", Income = 8, Weight = 15 },
}

local function syncAttributes(player, profile)
    player:SetAttribute("EggCount", #profile.EggInventory)
    player:SetAttribute("CompanionCount", #profile.Companions)
    player:SetAttribute("Coins", profile.Coins)
end

local function chooseCompanion()
    local totalWeight = 0
    for _, companion in ipairs(COMPANIONS) do totalWeight += companion.Weight end
    local roll = math.random() * totalWeight
    local cursor = 0
    for _, companion in ipairs(COMPANIONS) do
        cursor += companion.Weight
        if roll <= cursor then return companion end
    end
    return COMPANIONS[1]
end

function EggService:Collect(player, egg)
    if not player:GetAttribute("ProfileLoaded") or not egg or not egg:IsDescendantOf(Workspace) then return end
    if egg:GetAttribute("Collected") or not egg:GetAttribute("WorldEgg") then return end
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - egg.Position).Magnitude > 14 then return end

    local profile = PlayerDataService:GetProfile(player)
    if not profile or #profile.EggInventory >= EGG_CAPACITY then
        player:SetAttribute("LastNotice", "Egg bag is full!")
        return
    end

    egg:SetAttribute("Collected", true)
    table.insert(profile.EggInventory, {
        Id = "MeadowEgg",
        InstanceId = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999)),
        CollectedAt = os.time(),
    })
    syncAttributes(player, profile)
    player:SetAttribute("LastNotice", "Meadow Egg collected!")

    egg.Transparency = 1
    egg.CanCollide = false
    local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
    if prompt then prompt.Enabled = false end

    task.delay(EGG_RESPAWN_SECONDS, function()
        if egg and egg.Parent then
            egg:SetAttribute("Collected", false)
            egg.Transparency = 0
            egg.CanCollide = true
            if prompt then prompt.Enabled = true end
        end
    end)
end

function EggService:Hatch(player)
    if not player:GetAttribute("ProfileLoaded") then return end
    local profile = PlayerDataService:GetProfile(player)
    if not profile or #profile.EggInventory == 0 then
        player:SetAttribute("LastNotice", "Find an egg before hatching!")
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local world = Workspace:FindFirstChild("NestRaidersWorld")
    local island = world and world:FindFirstChild("StarterIsland")
    local nest = island and island:FindFirstChild("StarterNest")
    local station = nest and nest:FindFirstChild("HatchStation")
    if not root or not station or (root.Position - station.Position).Magnitude > 16 then return end

    table.remove(profile.EggInventory, 1)
    local definition = chooseCompanion()
    table.insert(profile.Companions, {
        Id = definition.Id, Name = definition.Name, Rarity = definition.Rarity,
        Income = definition.Income, Level = 1, HatchedAt = os.time(),
    })
    syncAttributes(player, profile)
    player:SetAttribute("LastNotice", "You hatched a " .. definition.Rarity .. " " .. definition.Name .. "!")
end

function EggService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    if not world then
        warn("[NEST RAIDERS] World was not built before EggService initialized.")
        return
    end
    local eggFolder = world:WaitForChild("StarterIsland"):WaitForChild("EggSpawnPoints")
    for _, egg in ipairs(eggFolder:GetChildren()) do
        local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
        if prompt then prompt.Triggered:Connect(function(player) self:Collect(player, egg) end) end
    end
    local station = world.StarterIsland.StarterNest:WaitForChild("HatchStation")
    local hatchPrompt = station:FindFirstChildOfClass("ProximityPrompt")
    hatchPrompt.Triggered:Connect(function(player) self:Hatch(player) end)

    Players.PlayerAdded:Connect(function(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then
                local profile = PlayerDataService:GetProfile(player)
                if profile then syncAttributes(player, profile) end
            end
        end)
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        task.defer(function()
            local profile = PlayerDataService:GetProfile(player)
            if profile then syncAttributes(player, profile) end
        end)
    end
end

return EggService
