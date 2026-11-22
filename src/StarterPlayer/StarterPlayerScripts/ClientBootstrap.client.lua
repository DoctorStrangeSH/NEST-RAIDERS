local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local inventoryRemote = ReplicatedStorage:WaitForChild("NestRaidersRemotes"):WaitForChild("CompanionInventory")

local gui = Instance.new("ScreenGui")
gui.Name = "NestRaidersHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = parent
end

local panel = Instance.new("Frame")
panel.Name = "StatusPanel"
panel.Position = UDim2.fromOffset(18, 18)
panel.Size = UDim2.fromOffset(250, 132)
panel.BackgroundColor3 = Color3.fromRGB(28, 45, 55)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui
addCorner(panel, 16)
addStroke(panel, Color3.fromRGB(123, 211, 163), 2)

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
stats.Text = "Загрузка гнезда..."
stats.Parent = panel

local inventoryButton = Instance.new("TextButton")
inventoryButton.Name = "InventoryButton"
inventoryButton.Position = UDim2.fromOffset(18, 162)
inventoryButton.Size = UDim2.fromOffset(250, 46)
inventoryButton.BackgroundColor3 = Color3.fromRGB(64, 132, 105)
inventoryButton.Text = "МОИ ПИТОМЦЫ"
inventoryButton.TextColor3 = Color3.fromRGB(255, 255, 245)
inventoryButton.TextSize = 15
inventoryButton.Font = Enum.Font.GothamBlack
inventoryButton.AutoButtonColor = true
inventoryButton.Parent = gui
addCorner(inventoryButton, 12)
addStroke(inventoryButton, Color3.fromRGB(155, 226, 178), 1.5)

local inventoryPanel = Instance.new("Frame")
inventoryPanel.Name = "CompanionInventory"
inventoryPanel.AnchorPoint = Vector2.new(0.5, 0.5)
inventoryPanel.Position = UDim2.fromScale(0.5, 0.5)
inventoryPanel.Size = UDim2.new(0.9, 0, 0.72, 0)
inventoryPanel.BackgroundColor3 = Color3.fromRGB(25, 42, 52)
inventoryPanel.BorderSizePixel = 0
inventoryPanel.Visible = false
inventoryPanel.Parent = gui
addCorner(inventoryPanel, 18)
addStroke(inventoryPanel, Color3.fromRGB(123, 211, 163), 2)

local sizeLimit = Instance.new("UISizeConstraint")
sizeLimit.MinSize = Vector2.new(290, 300)
sizeLimit.MaxSize = Vector2.new(460, 560)
sizeLimit.Parent = inventoryPanel

local inventoryTitle = Instance.new("TextLabel")
inventoryTitle.BackgroundTransparency = 1
inventoryTitle.Position = UDim2.fromOffset(18, 12)
inventoryTitle.Size = UDim2.new(1, -76, 0, 30)
inventoryTitle.Font = Enum.Font.GothamBlack
inventoryTitle.Text = "КОЛЛЕКЦИЯ ПИТОМЦЕВ"
inventoryTitle.TextColor3 = Color3.fromRGB(255, 224, 135)
inventoryTitle.TextSize = 18
inventoryTitle.TextXAlignment = Enum.TextXAlignment.Left
inventoryTitle.Parent = inventoryPanel

local closeButton = Instance.new("TextButton")
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -12, 0, 10)
closeButton.Size = UDim2.fromOffset(38, 34)
closeButton.BackgroundColor3 = Color3.fromRGB(74, 91, 101)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = inventoryPanel
addCorner(closeButton, 10)

local inventorySummary = Instance.new("TextLabel")
inventorySummary.BackgroundTransparency = 1
inventorySummary.Position = UDim2.fromOffset(18, 46)
inventorySummary.Size = UDim2.new(1, -36, 0, 24)
inventorySummary.Font = Enum.Font.GothamMedium
inventorySummary.Text = "Активные питомцы: 0 / 3"
inventorySummary.TextColor3 = Color3.fromRGB(194, 215, 211)
inventorySummary.TextSize = 14
inventorySummary.TextXAlignment = Enum.TextXAlignment.Left
inventorySummary.Parent = inventoryPanel

local list = Instance.new("ScrollingFrame")
list.Name = "CompanionList"
list.Position = UDim2.fromOffset(12, 78)
list.Size = UDim2.new(1, -24, 1, -92)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = inventoryPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list

local emptyLabel = Instance.new("TextLabel")
emptyLabel.Name = "EmptyState"
emptyLabel.Size = UDim2.new(1, -20, 0, 76)
emptyLabel.BackgroundTransparency = 1
emptyLabel.Font = Enum.Font.GothamMedium
emptyLabel.Text = "Питомцев пока нет. Найди яйцо и вылупи своего первого друга!"
emptyLabel.TextColor3 = Color3.fromRGB(194, 215, 211)
emptyLabel.TextSize = 15
emptyLabel.TextWrapped = true
emptyLabel.Visible = false
emptyLabel.Parent = list

local function showNotice(message)
    local notice = gui:FindFirstChild("Notice")
    if not notice then
        notice = Instance.new("TextLabel")
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
        addCorner(notice, 12)
    end
    notice.Text = message
    notice.Visible = true
    task.delay(2.5, function()
        if notice.Parent and notice.Text == message then notice.Visible = false end
    end)
end

local function invokeInventory(payload)
    local success, response = pcall(function()
        return inventoryRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось связаться с сервером.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Не удалось выполнить действие.")
        return nil
    end
    return response.Data
end

local function renderInventory(data)
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") or child == emptyLabel then
            if child ~= emptyLabel then child:Destroy() end
        end
    end

    if not data then return end
    inventorySummary.Text = string.format("Активные питомцы: %d / %d", data.ActiveCount or 0, data.MaxActive or 3)
    local companions = data.Companions or {}
    emptyLabel.Visible = #companions == 0

    for index, companion in ipairs(companions) do
        local card = Instance.new("Frame")
        card.Name = "CompanionCard"
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 82)
        card.BackgroundColor3 = Color3.fromRGB(43, 64, 72)
        card.BorderSizePixel = 0
        card.Parent = list
        addCorner(card, 12)

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(12, 8)
        name.Size = UDim2.new(1, -130, 0, 22)
        name.Font = Enum.Font.GothamBold
        name.Text = companion.Name or companion.Id or "Питомец"
        name.TextColor3 = Color3.fromRGB(255, 239, 198)
        name.TextSize = 15
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        local details = Instance.new("TextLabel")
        details.BackgroundTransparency = 1
        details.Position = UDim2.fromOffset(12, 34)
        details.Size = UDim2.new(1, -130, 0, 32)
        details.Font = Enum.Font.GothamMedium
        details.Text = string.format("%s  ·  Ур. %d  ·  +%d монет / 10 сек.", companion.Rarity or "Обычный", companion.Level or 1, companion.Income or 0)
        details.TextColor3 = Color3.fromRGB(187, 211, 203)
        details.TextSize = 12
        details.TextXAlignment = Enum.TextXAlignment.Left
        details.Parent = card

        local action = Instance.new("TextButton")
        action.AnchorPoint = Vector2.new(1, 0.5)
        action.Position = UDim2.new(1, -10, 0.5, 0)
        action.Size = UDim2.fromOffset(104, 38)
        action.BackgroundColor3 = companion.Equipped and Color3.fromRGB(115, 86, 65) or Color3.fromRGB(67, 139, 104)
        action.Text = companion.Equipped and "СНЯТЬ" or "ВЗЯТЬ"
        action.TextColor3 = Color3.fromRGB(255, 255, 245)
        action.TextSize = 13
        action.Font = Enum.Font.GothamBlack
        action.Parent = card
        addCorner(action, 9)

        action.Activated:Connect(function()
            action.Active = false
            local updated = invokeInventory({
                Action = companion.Equipped and "Unequip" or "Equip",
                InstanceId = companion.InstanceId,
            })
            if updated then renderInventory(updated) end
        end)
    end
end

local function openInventory()
    inventoryPanel.Visible = true
    local data = invokeInventory({ Action = "Get" })
    if data then renderInventory(data) end
end

inventoryButton.Activated:Connect(openInventory)
closeButton.Activated:Connect(function() inventoryPanel.Visible = false end)

local function updateStats()
    if not player:GetAttribute("ProfileLoaded") then
        stats.Text = "Загрузка гнезда..."
        return
    end
    stats.Text = string.format("Монеты: %d\nЯйца: %d    Питомцы: %d\nУровень: %d\nГнездо: %s",
        player:GetAttribute("Coins") or 0,
        player:GetAttribute("EggCount") or 0,
        player:GetAttribute("CompanionCount") or 0,
        player:GetAttribute("Level") or 1,
        player:GetAttribute("PlotId") or "Назначается...")
end

for _, attribute in ipairs({"ProfileLoaded", "Coins", "EggCount", "CompanionCount", "Level", "PlotId"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateStats)
end

local lastNotice
player:GetAttributeChangedSignal("LastNotice"):Connect(function()
    local message = player:GetAttribute("LastNotice")
    if not message or message == lastNotice then return end
    lastNotice = message
    showNotice(message)
end)
updateStats()
