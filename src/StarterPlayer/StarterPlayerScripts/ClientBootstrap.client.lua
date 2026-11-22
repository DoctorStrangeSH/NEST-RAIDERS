local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "NestRaidersHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "StatusPanel"
panel.Position = UDim2.fromOffset(18, 18)
panel.Size = UDim2.fromOffset(250, 132)
panel.BackgroundColor3 = Color3.fromRGB(28, 45, 55)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(123, 211, 163)
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 7)
title.Size = UDim2.new(1, -28, 0, 25)
title.Font = Enum.Font.GothamBlack
title.Text = "NEST RAIDERS"
title.TextColor3 = Color3.fromRGB(255, 224, 135)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.BackgroundTransparency = 1
stats.Position = UDim2.fromOffset(14, 36)
stats.Size = UDim2.new(1, -28, 0, 84)
stats.Font = Enum.Font.GothamBold
stats.TextColor3 = Color3.fromRGB(241, 247, 236)
stats.TextSize = 15
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Top
stats.Text = "Loading your nest..."
stats.Parent = panel

local notice = Instance.new("TextLabel")
notice.Name = "Notice"
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.new(0.5, 0, 0, 28)
notice.Size = UDim2.fromOffset(420, 44)
notice.BackgroundColor3 = Color3.fromRGB(36, 65, 73)
notice.BackgroundTransparency = 0.08
notice.TextColor3 = Color3.fromRGB(255, 245, 220)
notice.Font = Enum.Font.GothamBold
notice.TextSize = 16
notice.Visible = false
notice.Parent = gui
local noticeCorner = Instance.new("UICorner")
noticeCorner.CornerRadius = UDim.new(0, 12)
noticeCorner.Parent = notice

local function updateStats()
    if not player:GetAttribute("ProfileLoaded") then
        stats.Text = "Loading your nest..."
        return
    end
    stats.Text = string.format("Coins: %d\nEggs: %d    Companions: %d\nLevel: %d\nNest: %s",
        player:GetAttribute("Coins") or 0,
        player:GetAttribute("EggCount") or 0,
        player:GetAttribute("CompanionCount") or 0,
        player:GetAttribute("Level") or 1,
        player:GetAttribute("PlotId") or "Assigning...")
end

for _, attribute in ipairs({"ProfileLoaded", "Coins", "EggCount", "CompanionCount", "Level", "PlotId"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateStats)
end

local lastNotice
player:GetAttributeChangedSignal("LastNotice"):Connect(function()
    local message = player:GetAttribute("LastNotice")
    if not message or message == lastNotice then return end
    lastNotice = message
    notice.Text = message
    notice.Visible = true
    task.delay(2.5, function()
        if notice.Parent and notice.Text == message then notice.Visible = false end
    end)
end)
updateStats()
