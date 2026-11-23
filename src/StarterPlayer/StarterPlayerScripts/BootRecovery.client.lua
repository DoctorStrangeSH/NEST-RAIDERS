-- Independently running watchdog: a failure in ClientBootstrap must never leave a silent empty screen.
-- This script does not replace gameplay UI and disappears as soon as the real HUD is present.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function hasHud()
    return playerGui:FindFirstChild("NestRaidersHUD") ~= nil
end

task.wait(12)
if hasHud() then return end

local screen = Instance.new("ScreenGui")
screen.Name = "NestRaidersRecovery"
screen.ResetOnSpawn = false
screen.DisplayOrder = 1500
screen.IgnoreGuiInset = false
screen.Parent = playerGui

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.42)
card.Size = UDim2.new(0.88, 0, 0, 210)
card.BackgroundColor3 = Color3.fromRGB(26, 40, 51)
card.BorderSizePixel = 0
card.Parent = screen
local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MaxSize = Vector2.new(480, 240)
sizeLimit.MinSize = Vector2.new(260, 180)
sizeLimit.Parent = card
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = card
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 191, 111)
stroke.Thickness = 2
stroke.Parent = card

local heading = Instance.new("TextLabel")
heading.Size = UDim2.new(1, -28, 0, 36)
heading.Position = UDim2.fromOffset(14, 10)
heading.BackgroundTransparency = 1
heading.Font = Enum.Font.GothamBlack
heading.TextSize = 21
heading.TextColor3 = Color3.fromRGB(255, 216, 135)
heading.Text = "NEST RAIDERS"
heading.Parent = card

local details = Instance.new("TextLabel")
details.Position = UDim2.fromOffset(16, 50)
details.Size = UDim2.new(1, -32, 1, -110)
details.BackgroundTransparency = 1
details.TextWrapped = true
details.TextYAlignment = Enum.TextYAlignment.Top
details.Font = Enum.Font.GothamMedium
details.TextSize = 14
details.TextColor3 = Color3.fromRGB(241, 245, 244)
details.Parent = card

local retry = Instance.new("TextButton")
retry.Position = UDim2.new(0, 16, 1, -52)
retry.Size = UDim2.new(1, -32, 0, 38)
retry.BackgroundColor3 = Color3.fromRGB(79, 150, 116)
retry.TextColor3 = Color3.new(1, 1, 1)
retry.Font = Enum.Font.GothamBold
retry.TextSize = 14
retry.Text = "ПРОВЕРИТЬ ПОВТОРНО"
retry.Parent = card
local retryCorner = Instance.new("UICorner")
retryCorner.CornerRadius = UDim.new(0, 9)
retryCorner.Parent = retry

local function report()
    if hasHud() then
        screen:Destroy()
        return
    end
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        details.Text = "Сервер не подготовил сетевые функции. Открой View → Output и пришли первую красную ошибку."
        return
    end
    local failures = {}
    for name, value in pairs(remotes:GetAttributes()) do
        if name == "WorldError" or string.sub(name, 1, 13) == "ServiceError_" then
            table.insert(failures, name .. ": " .. tostring(value))
        end
    end
    table.sort(failures)
    if #failures > 0 then
        details.Text = "Ошибка запуска:\n" .. string.sub(table.concat(failures, "\n"), 1, 500)
    else
        details.Text = "Интерфейс не появился за 12 секунд. Проверь красные ошибки ClientBootstrap в View → Output. Системы на сервере могут быть загружены, но клиентский скрипт завершился с ошибкой."
    end
end
retry.Activated:Connect(report)
report()
playerGui.ChildAdded:Connect(function(child)
    if child.Name == "NestRaidersHUD" and screen.Parent then
        screen:Destroy()
    end
end)
