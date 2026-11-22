local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local CompanionService = {}
CompanionService._folders = {}
CompanionService._generations = {}
local MAX_VISIBLE_COMPANIONS = 3
local FOLLOW_INTERVAL = 0.15

local DEFINITIONS = {
    MeadowFox = {
        Body = Color3.fromRGB(226, 132, 67),
        Accent = Color3.fromRGB(255, 225, 184),
        Detail = Color3.fromRGB(105, 66, 48),
        Kind = "Fox",
    },
    MossTurtle = {
        Body = Color3.fromRGB(111, 176, 112),
        Accent = Color3.fromRGB(119, 91, 62),
        Detail = Color3.fromRGB(226, 207, 143),
        Kind = "Turtle",
    },
    SproutDragon = {
        Body = Color3.fromRGB(81, 190, 174),
        Accent = Color3.fromRGB(178, 235, 144),
        Detail = Color3.fromRGB(106, 123, 210),
        Kind = "Dragon",
    },
}

local function makeShape(model, name, size, offset, color, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = shape or Enum.PartType.Ball
    part.Size = size
    part.CFrame = CFrame.new(offset)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = true
    part.Material = Enum.Material.SmoothPlastic
    part.Color = color
    part.Parent = model
    return part
end

local function buildPet(parent, companion, index)
    local definition = DEFINITIONS[companion.Id] or DEFINITIONS.MeadowFox
    local model = Instance.new("Model")
    model.Name = string.format("%s_%d", companion.Id, index)
    model:SetAttribute("CompanionId", companion.Id)
    model:SetAttribute("Rarity", companion.Rarity or "Common")
    model.Parent = parent

    local body = makeShape(model, "Body", Vector3.new(2.2, 1.45, 1.65), Vector3.new(0, 1.05, 0), definition.Body)
    model.PrimaryPart = body
    makeShape(model, "Head", Vector3.new(1.35, 1.25, 1.25), Vector3.new(0, 1.85, 0.65), definition.Body)

    if definition.Kind == "Fox" then
        makeShape(model, "Muzzle", Vector3.new(0.75, 0.48, 0.55), Vector3.new(0, 1.58, 1.2), definition.Accent)
        makeShape(model, "LeftEar", Vector3.new(0.48, 0.8, 0.42), Vector3.new(-0.42, 2.55, 0.55), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightEar", Vector3.new(0.48, 0.8, 0.42), Vector3.new(0.42, 2.55, 0.55), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(1.1, 1.1, 1.1), Vector3.new(0, 1.3, -1.15), definition.Accent)
    elseif definition.Kind == "Turtle" then
        makeShape(model, "Shell", Vector3.new(2.1, 1.15, 1.8), Vector3.new(0, 1.75, -0.05), definition.Accent)
        for _, x in ipairs({-0.7, 0.7}) do
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, 0.55), definition.Detail)
            makeShape(model, "Foot", Vector3.new(0.65, 0.45, 0.65), Vector3.new(x, 0.55, -0.55), definition.Detail)
        end
    else
        makeShape(model, "Muzzle", Vector3.new(0.85, 0.55, 0.6), Vector3.new(0, 1.6, 1.15), definition.Accent)
        makeShape(model, "LeftHorn", Vector3.new(0.35, 0.8, 0.35), Vector3.new(-0.45, 2.55, 0.45), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "RightHorn", Vector3.new(0.35, 0.8, 0.35), Vector3.new(0.45, 2.55, 0.45), definition.Accent, Enum.PartType.Wedge)
        makeShape(model, "LeftWing", Vector3.new(1.2, 0.18, 1.3), Vector3.new(-1.15, 1.7, -0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "RightWing", Vector3.new(1.2, 0.18, 1.3), Vector3.new(1.15, 1.7, -0.2), definition.Detail, Enum.PartType.Wedge)
        makeShape(model, "Tail", Vector3.new(0.55, 0.55, 1.2), Vector3.new(0, 1.1, -1.15), definition.Accent)
    end

    makeShape(model, "LeftEye", Vector3.new(0.16, 0.16, 0.12), Vector3.new(-0.28, 2.0, 1.22), Color3.fromRGB(35, 42, 48))
    makeShape(model, "RightEye", Vector3.new(0.16, 0.16, 0.12), Vector3.new(0.28, 2.0, 1.22), Color3.fromRGB(35, 42, 48))
    return model
end

function CompanionService:ClearPlayer(player)
    local folder = self._folders[player]
    if folder then folder:Destroy() end
    self._folders[player] = nil
end

function CompanionService:RefreshPlayer(player)
    local profile = PlayerDataService:GetProfile(player)
    if not profile then return end

    self._generations[player] = (self._generations[player] or 0) + 1
    local generation = self._generations[player]
    self:ClearPlayer(player)

    local rootFolder = Workspace:FindFirstChild("PlayerCompanions")
    if not rootFolder then
        rootFolder = Instance.new("Folder")
        rootFolder.Name = "PlayerCompanions"
        rootFolder.Parent = Workspace
    end

    local folder = Instance.new("Folder")
    folder.Name = "Player_" .. player.UserId
    folder.Parent = rootFolder
    self._folders[player] = folder

    local followers = {}
    for index, companion in ipairs(profile.Companions) do
        if index > MAX_VISIBLE_COMPANIONS then break end
        table.insert(followers, buildPet(folder, companion, index))
    end

    task.spawn(function()
        while player.Parent and self._generations[player] == generation do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                for index, pet in ipairs(followers) do
                    if pet.Parent then
                        local side = (index - (#followers + 1) / 2) * 2.6
                        local behind = 4 + math.floor((index - 1) / 2) * 2.1
                        local target = root.CFrame * CFrame.new(side, -1.4, behind)
                        pet:PivotTo(pet:GetPivot():Lerp(target, 0.35))
                    end
                end
            end
            task.wait(FOLLOW_INTERVAL)
        end
    end)
end

function CompanionService:Init()
    Players.PlayerAdded:Connect(function(player)
        player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
            if player:GetAttribute("ProfileLoaded") then self:RefreshPlayer(player) end
        end)
        player.CharacterAdded:Connect(function()
            task.delay(0.5, function()
                if player.Parent then self:RefreshPlayer(player) end
            end)
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self._generations[player] = nil
        self:ClearPlayer(player)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("ProfileLoaded") then
            task.defer(function() self:RefreshPlayer(player) end)
        else
            player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()
                if player:GetAttribute("ProfileLoaded") then self:RefreshPlayer(player) end
            end)
        end
    end
end

return CompanionService
