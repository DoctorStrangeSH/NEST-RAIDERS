local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PlayerDataService = require(game:GetService("ServerScriptService").Server.Services.PlayerDataService)

local PlotService = {}
PlotService._plots = {}
PlotService._owners = {}
PlotService._playerPlots = {}

local PLOT_DEFINITIONS = {
    { Id = "Nest01", Position = Vector3.new(-72, 11, -72) },
    { Id = "Nest02", Position = Vector3.new(0, 11, -84) },
    { Id = "Nest03", Position = Vector3.new(72, 11, -72) },
    { Id = "Nest04", Position = Vector3.new(-72, 11, 72) },
    { Id = "Nest05", Position = Vector3.new(0, 11, 84) },
    { Id = "Nest06", Position = Vector3.new(72, 11, 72) },
}

local function makePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function buildPlot(parent, definition)
    local plot = Instance.new("Model")
    plot.Name = definition.Id
    plot:SetAttribute("PlotId", definition.Id)
    plot.Parent = parent

    local center = definition.Position
    makePart(plot, "PlotFoundation", Vector3.new(38, 2, 38), CFrame.new(center), Color3.fromRGB(112, 91, 70), Enum.Material.WoodPlanks)
    makePart(plot, "PlotGrass", Vector3.new(36, 0.6, 36), CFrame.new(center + Vector3.new(0, 1.3, 0)), Color3.fromRGB(119, 190, 111), Enum.Material.Grass)

    local nest = makePart(plot, "NestBowl", Vector3.new(13, 2, 11), CFrame.new(center + Vector3.new(0, 3, 0)), Color3.fromRGB(153, 111, 69), Enum.Material.Wood)
    nest.Shape = Enum.PartType.Cylinder
    nest.CFrame = CFrame.new(center + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))

    local station = makePart(plot, "HatchStation", Vector3.new(5, 5, 5), CFrame.new(center + Vector3.new(0, 7, 0)), Color3.fromRGB(255, 194, 83), Enum.Material.Neon)
    station.Shape = Enum.PartType.Ball
    station.Transparency = 0.15
    station:SetAttribute("PlotId", definition.Id)

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "HatchPrompt"
    prompt.ActionText = "Hatch Egg"
    prompt.ObjectText = "Personal Nest"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = station

    local sign = makePart(plot, "OwnerSign", Vector3.new(1, 5, 9), CFrame.new(center + Vector3.new(0, 4, -14)), Color3.fromRGB(105, 72, 47), Enum.Material.Wood)
    local surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Front
    surface.Parent = sign
    local label = Instance.new("TextLabel")
    label.Name = "OwnerLabel"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "СВОБОДНОЕ ГНЕЗДО"
    label.TextColor3 = Color3.fromRGB(255, 245, 210)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.Parent = surface

    return plot, station, label
end

function PlotService:ApplyNestLevel(player, level)
    local plot = self._playerPlots[player]
    if not plot then return false end

    level = math.clamp(math.floor(tonumber(level) or 1), 1, 5)
    local previous = plot.Model:FindFirstChild("UpgradeDecorations")
    if previous then previous:Destroy() end

    local decorations = Instance.new("Folder")
    decorations.Name = "UpgradeDecorations"
    decorations.Parent = plot.Model
    local center = plot.Center

    local function decor(name, size, offset, color, material, shape)
        local part = makePart(
            decorations,
            name,
            size,
            CFrame.new(center + offset),
            color,
            material
        )
        if shape then part.Shape = shape end
        part.CanCollide = false
        return part
    end

    if level >= 2 then
        for _, x in ipairs({-8, 8}) do
            decor("NestLantern", Vector3.new(1.2, 4, 1.2), Vector3.new(x, 4, -8), Color3.fromRGB(255, 205, 105), Enum.Material.Neon)
        end
    end
    if level >= 3 then
        for _, x in ipairs({-12, 12}) do
            decor("GardenCrystal", Vector3.new(2.2, 3.5, 2.2), Vector3.new(x, 3.2, 7), Color3.fromRGB(104, 219, 163), Enum.Material.Glass, Enum.PartType.Ball)
        end
    end
    if level >= 4 then
        decor("NestBannerPole", Vector3.new(0.7, 9, 0.7), Vector3.new(0, 5.5, -15), Color3.fromRGB(230, 197, 125), Enum.Material.Metal)
        decor("NestBanner", Vector3.new(4.5, 2.8, 0.3), Vector3.new(0, 8.5, -15), Color3.fromRGB(119, 151, 211), Enum.Material.Fabric)
    end
    local displayPositions = {
        Vector3.new(-12, 2.0, 12),
        Vector3.new(12, 2.0, 12),
        Vector3.new(-12, 2.0, -12),
        Vector3.new(12, 2.0, -12),
    }
    for index = 1, math.max(0, level - 1) do
        local offset = displayPositions[index]
        decor("PetDisplayPedestal", Vector3.new(4, 1, 4), offset, Color3.fromRGB(164, 131, 91), Enum.Material.Wood, Enum.PartType.Cylinder)
        local crystal = decor("PetDisplayMarker", Vector3.new(1.2, 1.2, 1.2), offset + Vector3.new(0, 1.2, 0), Color3.fromRGB(145, 225, 190), Enum.Material.Neon, Enum.PartType.Ball)
        crystal.Transparency = 0.28
    end

    if level >= 5 then
        local crown = decor("MasterNestCrown", Vector3.new(5, 5, 5), Vector3.new(0, 8.5, 0), Color3.fromRGB(255, 205, 74), Enum.Material.Neon, Enum.PartType.Ball)
        crown.Transparency = 0.22
        local light = Instance.new("PointLight")
        light.Color = crown.Color
        light.Brightness = 1.8
        light.Range = 18
        light.Parent = crown
    end

    plot.Model:SetAttribute("NestLevel", level)
    return true
end

function PlotService:GetPlayerPlot(player)
    return self._playerPlots[player]
end

function PlotService:IsOwner(player, plotId)
    local plot = self._playerPlots[player]
    return plot ~= nil and plot.Id == plotId
end

function PlotService:GetStation(player)
    local plot = self._playerPlots[player]
    return plot and plot.Station or nil
end

function PlotService:AssignPlot(player)
    if self._playerPlots[player] or not player.Parent then return end
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end

    local requestedId = profile.Nest and profile.Nest.PlotId
    local selected = requestedId and self._plots[requestedId] or nil
    if selected and self._owners[selected.Id] then selected = nil end

    if not selected then
        for _, definition in ipairs(PLOT_DEFINITIONS) do
            local candidate = self._plots[definition.Id]
            if candidate and not self._owners[candidate.Id] then
                selected = candidate
                break
            end
        end
    end

    if not selected then
        player:SetAttribute("LastNotice", "Все личные гнёзда заняты. Попробуй другой сервер.")
        player:Kick("Все гнёзда на сервере заняты. Попробуй подключиться ещё раз.")
        return
    end

    self._owners[selected.Id] = player
    self._playerPlots[player] = selected
    profile.Nest = profile.Nest or { Level = 1 }
    profile.Nest.PlotId = selected.Id
    selected.Model:SetAttribute("OwnerUserId", player.UserId)
    selected.Model:SetAttribute("OwnerName", player.DisplayName)
    selected.OwnerLabel.Text = "ГНЕЗДО: " .. player.DisplayName
    player:SetAttribute("PlotId", selected.Id)
    player:SetAttribute("PlotAssigned", true)
    self:ApplyNestLevel(player, profile.Nest.Level or 1)
    player:SetAttribute("LastNotice", "Твоё личное гнездо готово!")
end

function PlotService:ReleasePlot(player)
    local plot = self._playerPlots[player]
    if not plot then return end
    self._owners[plot.Id] = nil
    self._playerPlots[player] = nil
    plot.Model:SetAttribute("OwnerUserId", nil)
    plot.Model:SetAttribute("OwnerName", nil)
    plot.OwnerLabel.Text = "AVAILABLE NEST"
    player:SetAttribute("PlotAssigned", false)
end

function PlotService:BindPlayer(player)
    player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
        if player:GetAttribute("ProfileLoaded") then self:AssignPlot(player) end
    end)
    if player:GetAttribute("ProfileLoaded") then
        task.defer(function() self:AssignPlot(player) end)
    end
end

function PlotService:Init()
    local world = Workspace:WaitForChild("NestRaidersWorld", 30)
    local island = world and world:FindFirstChild("StarterIsland")
    if not island then
        warn("[NEST RAIDERS] StarterIsland missing; plot assignment disabled.")
        return
    end

    local folder = Instance.new("Folder")
    folder.Name = "PlayerPlots"
    folder.Parent = island

    for _, definition in ipairs(PLOT_DEFINITIONS) do
        local model, station, ownerLabel = buildPlot(folder, definition)
        self._plots[definition.Id] = {
            Id = definition.Id,
            Model = model,
            Station = station,
            OwnerLabel = ownerLabel,
            Center = definition.Position,
        }
    end

    Players.PlayerAdded:Connect(function(player) self:BindPlayer(player) end)
    Players.PlayerRemoving:Connect(function(player) self:ReleasePlot(player) end)
    for _, player in ipairs(Players:GetPlayers()) do self:BindPlayer(player) end
end

return PlotService
