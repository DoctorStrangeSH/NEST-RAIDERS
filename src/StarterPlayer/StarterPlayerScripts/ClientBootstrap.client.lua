local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("NestRaidersRemotes")
local inventoryRemote = remotes:WaitForChild("CompanionInventory")
local shopRemote = remotes:WaitForChild("EggShop")
local collectionRemote = remotes:WaitForChild("CollectionBook")
local nestRemote = remotes:WaitForChild("NestUpgrade")

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

local shopButton = Instance.new("TextButton")
shopButton.Name = "EggShopButton"
shopButton.Position = UDim2.fromOffset(18, 216)
shopButton.Size = UDim2.fromOffset(250, 46)
shopButton.BackgroundColor3 = Color3.fromRGB(197, 143, 62)
shopButton.Text = "МАГАЗИН ЯИЦ"
shopButton.TextColor3 = Color3.fromRGB(255, 255, 245)
shopButton.TextSize = 15
shopButton.Font = Enum.Font.GothamBlack
shopButton.Parent = gui
addCorner(shopButton, 12)
addStroke(shopButton, Color3.fromRGB(255, 213, 133), 1.5)

local shopPanel = Instance.new("Frame")
shopPanel.Name = "EggShopPanel"
shopPanel.AnchorPoint = Vector2.new(0.5, 0.5)
shopPanel.Position = UDim2.fromScale(0.5, 0.5)
shopPanel.Size = UDim2.new(0.9, 0, 0.62, 0)
shopPanel.BackgroundColor3 = Color3.fromRGB(35, 43, 54)
shopPanel.BorderSizePixel = 0
shopPanel.Visible = false
shopPanel.Parent = gui
addCorner(shopPanel, 18)
addStroke(shopPanel, Color3.fromRGB(255, 198, 105), 2)

local shopSize = Instance.new("UISizeConstraint")
shopSize.MinSize = Vector2.new(290, 280)
shopSize.MaxSize = Vector2.new(460, 440)
shopSize.Parent = shopPanel

local shopTitle = Instance.new("TextLabel")
shopTitle.BackgroundTransparency = 1
shopTitle.Position = UDim2.fromOffset(18, 12)
shopTitle.Size = UDim2.new(1, -76, 0, 30)
shopTitle.Font = Enum.Font.GothamBlack
shopTitle.Text = "ЛАВКА ЯИЦ"
shopTitle.TextColor3 = Color3.fromRGB(255, 220, 145)
shopTitle.TextSize = 19
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent = shopPanel

local shopClose = Instance.new("TextButton")
shopClose.AnchorPoint = Vector2.new(1, 0)
shopClose.Position = UDim2.new(1, -12, 0, 10)
shopClose.Size = UDim2.fromOffset(38, 34)
shopClose.BackgroundColor3 = Color3.fromRGB(74, 91, 101)
shopClose.Text = "✕"
shopClose.TextColor3 = Color3.new(1, 1, 1)
shopClose.TextSize = 18
shopClose.Font = Enum.Font.GothamBold
shopClose.Parent = shopPanel
addCorner(shopClose, 10)

local shopBalance = Instance.new("TextLabel")
shopBalance.BackgroundTransparency = 1
shopBalance.Position = UDim2.fromOffset(18, 48)
shopBalance.Size = UDim2.new(1, -36, 0, 24)
shopBalance.Font = Enum.Font.GothamMedium
shopBalance.TextColor3 = Color3.fromRGB(210, 220, 211)
shopBalance.TextSize = 14
shopBalance.TextXAlignment = Enum.TextXAlignment.Left
shopBalance.Parent = shopPanel

local shopList = Instance.new("ScrollingFrame")
shopList.Position = UDim2.fromOffset(12, 80)
shopList.Size = UDim2.new(1, -24, 1, -94)
shopList.BackgroundTransparency = 1
shopList.BorderSizePixel = 0
shopList.ScrollBarThickness = 6
shopList.AutomaticCanvasSize = Enum.AutomaticSize.Y
shopList.Parent = shopPanel

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 10)
shopLayout.SortOrder = Enum.SortOrder.LayoutOrder
shopLayout.Parent = shopList

local collectionButton = Instance.new("TextButton")
collectionButton.Name = "CollectionBookButton"
collectionButton.Position = UDim2.fromOffset(18, 270)
collectionButton.Size = UDim2.fromOffset(250, 46)
collectionButton.BackgroundColor3 = Color3.fromRGB(91, 111, 157)
collectionButton.Text = "КНИГА КОЛЛЕКЦИОНЕРА"
collectionButton.TextColor3 = Color3.fromRGB(255, 255, 245)
collectionButton.TextSize = 14
collectionButton.Font = Enum.Font.GothamBlack
collectionButton.Parent = gui
addCorner(collectionButton, 12)
addStroke(collectionButton, Color3.fromRGB(167, 190, 238), 1.5)

local nestButton = Instance.new("TextButton")
nestButton.Name = "NestUpgradeButton"
nestButton.Position = UDim2.fromOffset(18, 324)
nestButton.Size = UDim2.fromOffset(250, 46)
nestButton.BackgroundColor3 = Color3.fromRGB(91, 143, 111)
nestButton.Text = "УЛУЧШИТЬ ГНЕЗДО"
nestButton.TextColor3 = Color3.fromRGB(255, 255, 245)
nestButton.TextSize = 14
nestButton.Font = Enum.Font.GothamBlack
nestButton.Parent = gui
addCorner(nestButton, 12)
addStroke(nestButton, Color3.fromRGB(164, 220, 169), 1.5)

local nestPanel = Instance.new("Frame")
nestPanel.Name = "NestUpgradePanel"
nestPanel.AnchorPoint = Vector2.new(0.5, 0.5)
nestPanel.Position = UDim2.fromScale(0.5, 0.5)
nestPanel.Size = UDim2.new(0.9, 0, 0.48, 0)
nestPanel.BackgroundColor3 = Color3.fromRGB(30, 49, 48)
nestPanel.BorderSizePixel = 0
nestPanel.Visible = false
nestPanel.Parent = gui
addCorner(nestPanel, 18)
addStroke(nestPanel, Color3.fromRGB(143, 206, 157), 2)

local nestSize = Instance.new("UISizeConstraint")
nestSize.MinSize = Vector2.new(290, 250)
nestSize.MaxSize = Vector2.new(440, 350)
nestSize.Parent = nestPanel

local nestTitle = Instance.new("TextLabel")
nestTitle.BackgroundTransparency = 1
nestTitle.Position = UDim2.fromOffset(18, 14)
nestTitle.Size = UDim2.new(1, -76, 0, 30)
nestTitle.Font = Enum.Font.GothamBlack
nestTitle.Text = "РАЗВИТИЕ ГНЕЗДА"
nestTitle.TextColor3 = Color3.fromRGB(203, 239, 190)
nestTitle.TextSize = 18
nestTitle.TextXAlignment = Enum.TextXAlignment.Left
nestTitle.Parent = nestPanel

local nestClose = Instance.new("TextButton")
nestClose.AnchorPoint = Vector2.new(1, 0)
nestClose.Position = UDim2.new(1, -12, 0, 10)
nestClose.Size = UDim2.fromOffset(38, 34)
nestClose.BackgroundColor3 = Color3.fromRGB(74, 91, 101)
nestClose.Text = "✕"
nestClose.TextColor3 = Color3.new(1, 1, 1)
nestClose.TextSize = 18
nestClose.Font = Enum.Font.GothamBold
nestClose.Parent = nestPanel
addCorner(nestClose, 10)

local nestLevel = Instance.new("TextLabel")
nestLevel.BackgroundTransparency = 1
nestLevel.Position = UDim2.fromOffset(18, 62)
nestLevel.Size = UDim2.new(1, -36, 0, 34)
nestLevel.Font = Enum.Font.GothamBlack
nestLevel.Text = "Уровень гнезда: 1 / 5"
nestLevel.TextColor3 = Color3.fromRGB(255, 231, 176)
nestLevel.TextSize = 21
nestLevel.TextXAlignment = Enum.TextXAlignment.Left
nestLevel.Parent = nestPanel

local nestDescription = Instance.new("TextLabel")
nestDescription.BackgroundTransparency = 1
nestDescription.Position = UDim2.fromOffset(18, 104)
nestDescription.Size = UDim2.new(1, -36, 0, 72)
nestDescription.Font = Enum.Font.GothamMedium
nestDescription.Text = "Улучшай своё гнездо: открывай новые украшения и места для питомцев."
nestDescription.TextColor3 = Color3.fromRGB(203, 220, 209)
nestDescription.TextSize = 14
nestDescription.TextWrapped = true
nestDescription.TextXAlignment = Enum.TextXAlignment.Left
nestDescription.TextYAlignment = Enum.TextYAlignment.Top
nestDescription.Parent = nestPanel

local nestUpgrade = Instance.new("TextButton")
nestUpgrade.Position = UDim2.new(0, 18, 1, -58)
nestUpgrade.Size = UDim2.new(1, -36, 0, 42)
nestUpgrade.BackgroundColor3 = Color3.fromRGB(83, 151, 103)
nestUpgrade.Text = "УЛУЧШИТЬ"
nestUpgrade.TextColor3 = Color3.fromRGB(255, 255, 245)
nestUpgrade.TextSize = 15
nestUpgrade.Font = Enum.Font.GothamBlack
nestUpgrade.Parent = nestPanel
addCorner(nestUpgrade, 11)

local bookPanel = Instance.new("Frame")
bookPanel.Name = "CollectionBookPanel"
bookPanel.AnchorPoint = Vector2.new(0.5, 0.5)
bookPanel.Position = UDim2.fromScale(0.5, 0.5)
bookPanel.Size = UDim2.new(0.9, 0, 0.76, 0)
bookPanel.BackgroundColor3 = Color3.fromRGB(27, 39, 58)
bookPanel.BorderSizePixel = 0
bookPanel.Visible = false
bookPanel.Parent = gui
addCorner(bookPanel, 18)
addStroke(bookPanel, Color3.fromRGB(147, 173, 224), 2)

local bookSize = Instance.new("UISizeConstraint")
bookSize.MinSize = Vector2.new(290, 320)
bookSize.MaxSize = Vector2.new(480, 590)
bookSize.Parent = bookPanel

local bookTitle = Instance.new("TextLabel")
bookTitle.BackgroundTransparency = 1
bookTitle.Position = UDim2.fromOffset(18, 12)
bookTitle.Size = UDim2.new(1, -76, 0, 30)
bookTitle.Font = Enum.Font.GothamBlack
bookTitle.Text = "КНИГА КОЛЛЕКЦИОНЕРА"
bookTitle.TextColor3 = Color3.fromRGB(226, 213, 255)
bookTitle.TextSize = 17
bookTitle.TextXAlignment = Enum.TextXAlignment.Left
bookTitle.Parent = bookPanel

local bookClose = Instance.new("TextButton")
bookClose.AnchorPoint = Vector2.new(1, 0)
bookClose.Position = UDim2.new(1, -12, 0, 10)
bookClose.Size = UDim2.fromOffset(38, 34)
bookClose.BackgroundColor3 = Color3.fromRGB(74, 91, 101)
bookClose.Text = "✕"
bookClose.TextColor3 = Color3.new(1, 1, 1)
bookClose.TextSize = 18
bookClose.Font = Enum.Font.GothamBold
bookClose.Parent = bookPanel
addCorner(bookClose, 10)

local bookProgress = Instance.new("TextLabel")
bookProgress.BackgroundTransparency = 1
bookProgress.Position = UDim2.fromOffset(18, 46)
bookProgress.Size = UDim2.new(1, -36, 0, 24)
bookProgress.Font = Enum.Font.GothamBold
bookProgress.TextColor3 = Color3.fromRGB(196, 211, 245)
bookProgress.TextSize = 14
bookProgress.TextXAlignment = Enum.TextXAlignment.Left
bookProgress.Parent = bookPanel

local bookList = Instance.new("ScrollingFrame")
bookList.Position = UDim2.fromOffset(12, 78)
bookList.Size = UDim2.new(1, -24, 1, -92)
bookList.BackgroundTransparency = 1
bookList.BorderSizePixel = 0
bookList.ScrollBarThickness = 6
bookList.AutomaticCanvasSize = Enum.AutomaticSize.Y
bookList.Parent = bookPanel

local bookLayout = Instance.new("UIListLayout")
bookLayout.Padding = UDim.new(0, 8)
bookLayout.SortOrder = Enum.SortOrder.LayoutOrder
bookLayout.Parent = bookList

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
        card.Size = UDim2.new(1, -8, 0, 104)
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
        details.Size = UDim2.new(1, -130, 0, 25)
        details.Font = Enum.Font.GothamMedium
        details.Text = string.format("%s  ·  Ур. %d  ·  %s  ·  +%d / 10 сек.", companion.Rarity or "Обычный", companion.Level or 1, string.rep("★", companion.Stars or 1), companion.Income or 0)
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

        local mergeButton = Instance.new("TextButton")
        mergeButton.Name = "MergeButton"
        mergeButton.Position = UDim2.fromOffset(12, 68)
        mergeButton.Size = UDim2.fromOffset(126, 27)
        mergeButton.BackgroundColor3 = Color3.fromRGB(127, 91, 174)
        mergeButton.Text = "СЛИЯТЬ ×3"
        mergeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        mergeButton.TextSize = 12
        mergeButton.Font = Enum.Font.GothamBlack
        mergeButton.Visible = (companion.MergeCount or 0) >= 3 and (companion.Stars or 1) < 3
        mergeButton.Parent = card
        addCorner(mergeButton, 8)

        local mergeArmed = false
        mergeButton.Activated:Connect(function()
            if not mergeArmed then
                mergeArmed = true
                mergeButton.Text = "ТОЧНО? −2"
                mergeButton.BackgroundColor3 = Color3.fromRGB(166, 104, 75)
                return
            end
            mergeButton.Active = false
            mergeButton.Text = "СЛИЯНИЕ..."
            local updated = invokeInventory({
                Action = "Merge",
                InstanceId = companion.InstanceId,
            })
            if updated then
                renderInventory(updated)
            else
                mergeButton.Active = true
                mergeButton.Text = "СЛИЯТЬ ×3"
                mergeButton.BackgroundColor3 = Color3.fromRGB(127, 91, 174)
                mergeArmed = false
            end
        end)

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

local function invokeShop(payload)
    local success, response = pcall(function()
        return shopRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось связаться с магазином.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Покупка не выполнена.")
        return nil
    end
    if response.Message then showNotice(response.Message) end
    return response.Data
end

local function renderShop(data)
    if not data then return end
    shopBalance.Text = string.format("Монеты: %d   ·   Яйца: %d / %d",
        data.Coins or 0, data.EggCount or 0, data.EggCapacity or 20)
    for _, child in ipairs(shopList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for index, item in ipairs(data.Items or {}) do
        local card = Instance.new("Frame")
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 178)
        card.BackgroundColor3 = Color3.fromRGB(54, 67, 77)
        card.BorderSizePixel = 0
        card.Parent = shopList
        addCorner(card, 13)

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(14, 10)
        name.Size = UDim2.new(1, -28, 0, 24)
        name.Font = Enum.Font.GothamBlack
        name.Text = item.Name
        name.TextColor3 = Color3.fromRGB(255, 229, 170)
        name.TextSize = 17
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        local description = Instance.new("TextLabel")
        description.BackgroundTransparency = 1
        description.Position = UDim2.fromOffset(14, 38)
        description.Size = UDim2.new(1, -28, 0, 30)
        description.Font = Enum.Font.Gotham
        description.Text = item.Description or ""
        description.TextColor3 = Color3.fromRGB(207, 218, 210)
        description.TextSize = 12
        description.TextWrapped = true
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.Parent = card

        local odds = Instance.new("TextLabel")
        odds.BackgroundTransparency = 1
        odds.Position = UDim2.fromOffset(14, 72)
        odds.Size = UDim2.new(1, -28, 0, 60)
        odds.Font = Enum.Font.GothamMedium
        odds.TextColor3 = Color3.fromRGB(226, 231, 218)
        odds.TextSize = 12
        odds.TextXAlignment = Enum.TextXAlignment.Left
        odds.TextYAlignment = Enum.TextYAlignment.Top
        local oddsLines = {}
        for _, outcome in ipairs(item.Odds or {}) do
            table.insert(oddsLines, string.format("%s — %d%%", outcome.Name, outcome.Chance))
        end
        odds.Text = "Шансы вылупления:\n" .. table.concat(oddsLines, "\n")
        odds.Parent = card

        local buy = Instance.new("TextButton")
        buy.AnchorPoint = Vector2.new(1, 1)
        buy.Position = UDim2.new(1, -12, 1, -10)
        buy.Size = UDim2.fromOffset(150, 34)
        buy.BackgroundColor3 = Color3.fromRGB(190, 135, 57)
        buy.Text = "КУПИТЬ · " .. tostring(item.Price) .. " 🪙"
        buy.TextColor3 = Color3.fromRGB(255, 255, 245)
        buy.TextSize = 13
        buy.Font = Enum.Font.GothamBlack
        buy.Parent = card
        addCorner(buy, 9)

        buy.Activated:Connect(function()
            buy.Active = false
            local updated = invokeShop({ Action = "Buy", EggId = item.Id })
            if updated then
                renderShop(updated)
            end
        end)
    end
end

local function openShop()
    shopPanel.Visible = true
    local data = invokeShop({ Action = "Get" })
    if data then renderShop(data) end
end

shopButton.Activated:Connect(openShop)
shopClose.Activated:Connect(function() shopPanel.Visible = false end)

local function invokeNest(payload)
    local success, response = pcall(function()
        return nestRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось связаться с гнездом.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Улучшение недоступно.")
        return nil
    end
    if response.Message then showNotice(response.Message) end
    return response.Data
end

local function renderNest(data)
    if not data then return end
    nestLevel.Text = string.format("Уровень гнезда: %d / %d", data.Level or 1, data.MaxLevel or 5)
    if data.IsMaxLevel then
        nestDescription.Text = string.format("Максимальный уровень! Открыто мест для питомцев: %d. Твоё гнездо сияет во всей красе.", data.DisplaySlots or 0)
        nestUpgrade.Text = "МАКСИМАЛЬНЫЙ УРОВЕНЬ"
        nestUpgrade.Active = false
        nestUpgrade.AutoButtonColor = false
        nestUpgrade.BackgroundColor3 = Color3.fromRGB(83, 101, 87)
    else
        nestDescription.Text = string.format("Следующее улучшение откроет новые украшения и места для питомцев. Доступно мест: %d.", data.DisplaySlots or 0)
        nestUpgrade.Text = "УЛУЧШИТЬ · " .. tostring(data.NextCost or 0) .. " 🪙"
        nestUpgrade.Active = true
        nestUpgrade.AutoButtonColor = true
        nestUpgrade.BackgroundColor3 = Color3.fromRGB(83, 151, 103)
    end
end

local function openNest()
    nestPanel.Visible = true
    local data = invokeNest({ Action = "Get" })
    if data then renderNest(data) end
end

nestButton.Activated:Connect(openNest)
nestClose.Activated:Connect(function() nestPanel.Visible = false end)
nestUpgrade.Activated:Connect(function()
    if not nestUpgrade.Active then return end
    nestUpgrade.Active = false
    local data = invokeNest({ Action = "Upgrade" })
    if data then renderNest(data) else nestUpgrade.Active = true end
end)

local function invokeCollectionBook()
    local success, response = pcall(function()
        return collectionRemote:InvokeServer({ Action = "Get" })
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось открыть книгу коллекционера.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Книга временно недоступна.")
        return nil
    end
    return response.Data
end

local function renderCollectionBook(data)
    if not data then return end
    bookProgress.Text = string.format("Открыто видов: %d / %d   ·   %d%%",
        data.Discovered or 0, data.Total or 0, data.CompletionPercent or 0)

    for _, child in ipairs(bookList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for index, entry in ipairs(data.Entries or {}) do
        local card = Instance.new("Frame")
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 78)
        card.BackgroundColor3 = entry.Discovered and Color3.fromRGB(49, 68, 91) or Color3.fromRGB(39, 48, 65)
        card.BorderSizePixel = 0
        card.Parent = bookList
        addCorner(card, 11)

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(12, 8)
        name.Size = UDim2.new(1, -24, 0, 22)
        name.Font = Enum.Font.GothamBold
        name.Text = entry.Discovered and entry.Name or "???  ·  Не найден"
        name.TextColor3 = entry.Discovered and Color3.fromRGB(255, 231, 174) or Color3.fromRGB(153, 164, 184)
        name.TextSize = 15
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        local details = Instance.new("TextLabel")
        details.BackgroundTransparency = 1
        details.Position = UDim2.fromOffset(12, 34)
        details.Size = UDim2.new(1, -24, 0, 34)
        details.Font = Enum.Font.GothamMedium
        details.Text = entry.Discovered
            and string.format("%s  ·  В коллекции: %d  ·  +%d монет / 10 сек.", entry.Rarity, entry.OwnedCount, entry.Income)
            or string.format("Редкость: %s  ·  Шанс из яйца луга: %d%%", entry.Rarity, entry.HatchChance)
        details.TextColor3 = Color3.fromRGB(190, 204, 223)
        details.TextSize = 12
        details.TextXAlignment = Enum.TextXAlignment.Left
        details.Parent = card
    end
end

local function openCollectionBook()
    bookPanel.Visible = true
    local data = invokeCollectionBook()
    if data then renderCollectionBook(data) end
end

collectionButton.Activated:Connect(openCollectionBook)
bookClose.Activated:Connect(function() bookPanel.Visible = false end)

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
