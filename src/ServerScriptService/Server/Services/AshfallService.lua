local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local AshfallService = {}
local WARNING_SECONDS = 20
local SURGE_COUNT = 3
local SURGE_DURATION = 7.5
local SURGE_START_Z = 1640
local SURGE_END_Z = 1505
local SURGE_DAMAGE = 25
local SURGE_DAMAGE_COOLDOWN = 1.5
local REWARD_LIFETIME = 75
local EVENT_INTERVAL = 150
local FIRST_EVENT_DELAY = 45
local REWARD_AMOUNT = 1

local function getEmberlands()
    local world = Workspace:FindFirstChild("NestRaidersWorld")
    return world and world:FindFirstChild("Emberlands")
end

local function setPlayerEventState(phase, seconds)
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("CurrentBiome") == "Emberlands" then
            player:SetAttribute("AshfallPhase", phase)
            player:SetAttribute("AshfallSeconds", math.max(0, math.ceil(seconds)))
        end
    end
end

local function anyPlayerInEmberlands()
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("CurrentBiome") == "Emberlands" then return true end
    end
    return false
end

local function makeSurge(parent, index)
    local wave = Instance.new("Part")
    wave.Name = "AshfallLavaSurge_" .. index
    wave.Anchored = true
    wave.CanCollide = false
    wave.CanTouch = false
    wave.CanQuery = false
    wave.Material = Enum.Material.Neon
    wave.Color = Color3.fromRGB(255, 105, 34)
    wave.Transparency = 0.12
    wave.Size = Vector3.new(150, 1.4, 13)
    wave.Position = Vector3.new(0, 18.2, SURGE_START_Z)
    wave.Parent = parent

    local light = Instance.new("PointLight")
    light.Color = wave.Color
    light.Range = 26
    light.Brightness = 2.2
    light.Parent = wave
    return wave
end

local function spawnAshCrystals(ember, eventFolder, eventId)
    local rewards = eventFolder:FindFirstChild("AshfallRewards")
    if not rewards then
        rewards = Instance.new("Folder")
        rewards.Name = "AshfallRewards"
        rewards.Parent = eventFolder
    end
    rewards:ClearAllChildren()

    local positions = {
        Vector3.new(-48, 18, 1530),
        Vector3.new(48, 18, 1530),
        Vector3.new(-48, 18, 1600),
        Vector3.new(48, 18, 1600),
    }
    for index, position in ipairs(positions) do
        local crystal = Instance.new("Part")
        crystal.Name = "AshCrystal_" .. index
        crystal.Shape = Enum.PartType.Ball
        crystal.Size = Vector3.new(2.8, 2.8, 2.8)
        crystal.Position = position
        crystal.Anchored = true
        crystal.CanCollide = false
        crystal.Material = Enum.Material.Neon
        crystal.Color = Color3.fromRGB(255, 190, 92)
        crystal:SetAttribute("AshfallEventId", eventId)
        crystal.Parent = rewards

        local light = Instance.new("PointLight")
        light.Color = crystal.Color
        light.Range = 13
        light.Brightness = 1.1
        light.Parent = crystal

        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "CollectAshCrystalPrompt"
        prompt.ActionText = "Подобрать"
        prompt.ObjectText = "Пепельный кристалл"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0.35
        prompt.MaxActivationDistance = 10
        prompt.RequiresLineOfSight = false
        prompt.Parent = crystal

        local claimed = {}
        prompt.Triggered:Connect(function(player)
            if not player.Parent or player:GetAttribute("CurrentBiome") ~= "Emberlands" then return end
            if claimed[player.UserId] then
                player:SetAttribute("LastNotice", "Ты уже подобрал этот кристалл после извержения.")
                return
            end
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root or (root.Position - crystal.Position).Magnitude > prompt.MaxActivationDistance + 2 then return end
            local profile = PlayerDataService:GetProfile(player)
            if not profile then
                player:SetAttribute("LastNotice", "Сохранение ещё загружается. Попробуй позже.")
                return
            end
            profile.Materials = type(profile.Materials) == "table" and profile.Materials or {}
            profile.Materials.AshCrystal = math.max(0, math.floor(tonumber(profile.Materials.AshCrystal) or 0)) + REWARD_AMOUNT
            claimed[player.UserId] = true
            player:SetAttribute("AshCrystals", profile.Materials.AshCrystal)
            player:SetAttribute("LastNotice", "Получен пепельный кристалл! Всего: " .. profile.Materials.AshCrystal)
        end)
    end

    task.delay(REWARD_LIFETIME, function()
        if rewards.Parent then rewards:Destroy() end
    end)
end

local function damagePlayersAt(z)
    local now = os.clock()
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("CurrentBiome") == "Emberlands" then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0
                and math.abs(root.Position.X) <= 74
                and math.abs(root.Position.Z - z) <= 9
                and root.Position.Y <= 34 then
                selfDamage = nil
            end
        end
    end
end

function AshfallService:Init()
    self._running = false
    self._lastSurgeDamage = {}
    self._eventCounter = 0
    self._lastEventAt = nil
    Players.PlayerAdded:Connect(function(player)
        player:SetAttribute("AshfallPhase", "IDLE")
        player:SetAttribute("AshfallSeconds", 0)
        player:SetAttribute("AshCrystals", 0)
    end)
    Players.PlayerRemoving:Connect(function(player)
        self._lastSurgeDamage[player] = nil
    end)
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("AshfallPhase", "IDLE")
        player:SetAttribute("AshfallSeconds", 0)
    end
end

function AshfallService:_damageAt(z)
    local now = os.clock()
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("CurrentBiome") == "Emberlands" then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0
                and math.abs(root.Position.X) <= 74
                and math.abs(root.Position.Z - z) <= 9
                and root.Position.Y <= 34 then
                local lastDamage = self._lastSurgeDamage[player] or 0
                if now - lastDamage >= SURGE_DAMAGE_COOLDOWN then
                    self._lastSurgeDamage[player] = now
                    humanoid:TakeDamage(SURGE_DAMAGE)
                    player:SetAttribute("LastNotice", "Лавовый поток задел тебя! Уклоняйся от следующей волны!")
                end
            end
        end
    end
end

function AshfallService:_runEvent()
    local ember = getEmberlands()
    if not ember then return end
    self._eventCounter += 1
    local eventId = self._eventCounter
    local eventFolder = ember:FindFirstChild("LiveAshfall")
    if not eventFolder then
        eventFolder = Instance.new("Folder")
        eventFolder.Name = "LiveAshfall"
        eventFolder.Parent = ember
    end
    eventFolder:ClearAllChildren()

    for remaining = WARNING_SECONDS, 1, -1 do
        setPlayerEventState("WARNING", remaining)
        task.wait(1)
    end

    setPlayerEventState("ERUPTION", SURGE_COUNT * SURGE_DURATION)
    for index = 1, SURGE_COUNT do
        local wave = makeSurge(eventFolder, index)
        local started = os.clock()
        local lastTick = started
        while os.clock() - started < SURGE_DURATION do
            local alpha = math.clamp((os.clock() - started) / SURGE_DURATION, 0, 1)
            local z = SURGE_START_Z + (SURGE_END_Z - SURGE_START_Z) * alpha
            wave.Position = Vector3.new(0, 18.2, z)
            self:_damageAt(z)
            local elapsed = os.clock() - lastTick
            setPlayerEventState("ERUPTION", (SURGE_COUNT - index) * SURGE_DURATION + SURGE_DURATION - (os.clock() - started))
            lastTick = os.clock()
            task.wait(0.12)
        end
        wave:Destroy()
        task.wait(0.5)
    end

    setPlayerEventState("AFTERMATH", REWARD_LIFETIME)
    spawnAshCrystals(ember, eventFolder, eventId)
    for remaining = REWARD_LIFETIME, 1, -1 do
        setPlayerEventState("AFTERMATH", remaining)
        task.wait(1)
    end
    if eventFolder.Parent then eventFolder:Destroy() end
    setPlayerEventState("IDLE", 0)
end

function AshfallService:Start()
    if self._running then return end
    self._running = true
    task.spawn(function()
        while self._running do
            if anyPlayerInEmberlands() then
                if not self._lastEventAt then
                    self._lastEventAt = os.clock() + FIRST_EVENT_DELAY - EVENT_INTERVAL
                end
                if os.clock() - self._lastEventAt >= EVENT_INTERVAL then
                    self._lastEventAt = os.clock()
                    self:_runEvent()
                else
                    local remaining = EVENT_INTERVAL - (os.clock() - self._lastEventAt)
                    setPlayerEventState("IDLE", remaining)
                    task.wait(1)
                end
            else
                self._lastEventAt = nil
                setPlayerEventState("IDLE", 0)
                task.wait(2)
            end
        end
    end)
end

return AshfallService
