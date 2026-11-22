local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("NestRaidersRemotes")
local inventoryRemote = remotes:WaitForChild("CompanionInventory")
local shopRemote = remotes:WaitForChild("EggShop")
local collectionRemote = remotes:WaitForChild("CollectionBook")
local nestRemote = remotes:WaitForChild("NestUpgrade")
local displayRemote = remotes:WaitForChild("DisplayPets")

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

local displayButton = Instance.new("TextButton")
displayButton.Name = "DisplayPetsButton"
displayButton.Position = UDim2.fromOffset(18, 376)
displayButton.Size = UDim2.fromOffset(250, 46)
displayButton.BackgroundColor3 = Color3.fromRGB(104, 133, 170)
displayButton.Text = "ПИТОМЦЫ НА ВИТРИНАХ"
displayButton.TextColor3 = Color3.fromRGB(255, 255, 245)
displayButton.TextSize = 13
displayButton.Font = Enum.Font.GothamBlack
displayButton.Parent = gui
addCorner(displayButton, 12)
addStroke(displayButton, Color3.fromRGB(177, 207, 239), 1.5)

local displayPanel = Instance.new("Frame")
displayPanel.Name = "DisplayPetsPanel"
displayPanel.AnchorPoint = Vector2.new(0.5, 0.5)
displayPanel.Position = UDim2.fromScale(0.5, 0.5)
displayPanel.Size = UDim2.new(0.9, 0, 0.76, 0)
displayPanel.BackgroundColor3 = Color3.fromRGB(31, 45, 59)
displayPanel.BorderSizePixel = 0
displayPanel.Visible = false
displayPanel.Parent = gui
addCorner(displayPanel, 18)
addStroke(displayPanel, Color3.fromRGB(148, 190, 227), 2)

local displaySize = Instance.new("UISizeConstraint")
displaySize.MinSize = Vector2.new(290, 330)
displaySize.MaxSize = Vector2.new(480, 580)
displaySize.Parent = displayPanel

local displayTitle = Instance.new("TextLabel")
displayTitle.BackgroundTransparency = 1
displayTitle.Position = UDim2.fromOffset(18, 12)
displayTitle.Size = UDim2.new(1, -76, 0, 30)
displayTitle.Font = Enum.Font.GothamBlack
displayTitle.Text = "ПИТОМЦЫ В ГНЕЗДЕ"
displayTitle.TextColor3 = Color3.fromRGB(213, 232, 255)
displayTitle.TextSize = 18
displayTitle.TextXAlignment = Enum.TextXAlignment.Left
displayTitle.Parent = displayPanel

local displayClose = Instance.new("TextButton")
displayClose.AnchorPoint = Vector2.new(1, 0)
displayClose.Position = UDim2.new(1, -12, 0, 10)
displayClose.Size = UDim2.fromOffset(38, 34)
displayClose.BackgroundColor3 = Color3.fromRGB(74, 91, 101)
displayClose.Text = "✕"
displayClose.TextColor3 = Color3.new(1, 1, 1)
displayClose.TextSize = 18
displayClose.Font = Enum.Font.GothamBold
displayClose.Parent = displayPanel
addCorner(displayClose, 10)

local displayIncome = Instance.new("TextLabel")
displayIncome.BackgroundTransparency = 1
displayIncome.Position = UDim2.fromOffset(18, 48)
displayIncome.Size = UDim2.new(1, -36, 0, 44)
displayIncome.Font = Enum.Font.GothamMedium
displayIncome.TextColor3 = Color3.fromRGB(199, 222, 212)
displayIncome.TextSize = 13
displayIncome.TextWrapped = true
displayIncome.TextXAlignment = Enum.TextXAlignment.Left
displayIncome.Parent = displayPanel

local collectDisplay = Instance.new("TextButton")
collectDisplay.Position = UDim2.fromOffset(14, 94)
collectDisplay.Size = UDim2.new(1, -28, 0, 38)
collectDisplay.BackgroundColor3 = Color3.fromRGB(185, 143, 65)
collectDisplay.Text = "СОБРАТЬ МОНЕТЫ"
collectDisplay.TextColor3 = Color3.fromRGB(255, 255, 245)
collectDisplay.TextSize = 14
collectDisplay.Font = Enum.Font.GothamBlack
collectDisplay.Parent = displayPanel
addCorner(collectDisplay, 10)

local displayList = Instance.new("ScrollingFrame")
displayList.Position = UDim2.fromOffset(12, 142)
displayList.Size = UDim2.new(1, -24, 1, -154)
displayList.BackgroundTransparency = 1
displayList.BorderSizePixel = 0
displayList.ScrollBarThickness = 6
displayList.AutomaticCanvasSize = Enum.AutomaticSize.Y
displayList.Parent = displayPanel

local displayLayout = Instance.new("UIListLayout")
displayLayout.Padding = UDim.new(0, 8)
displayLayout.SortOrder = Enum.SortOrder.LayoutOrder
displayLayout.Parent = displayList

local pickerPanel = Instance.new("Frame")
pickerPanel.Name = "DisplayPetPicker"
pickerPanel.AnchorPoint = Vector2.new(0.5, 0.5)
pickerPanel.Position = UDim2.fromScale(0.5, 0.5)
pickerPanel.Size = UDim2.new(0.86, 0, 0.68, 0)
pickerPanel.BackgroundColor3 = Color3.fromRGB(39, 50, 67)
pickerPanel.BorderSizePixel = 0
pickerPanel.Visible = false
pickerPanel.Parent = gui
addCorner(pickerPanel, 16)
addStroke(pickerPanel, Color3.fromRGB(169, 194, 231), 2)

local pickerTitle = Instance.new("TextLabel")
pickerTitle.BackgroundTransparency = 1
pickerTitle.Position = UDim2.fromOffset(16, 10)
pickerTitle.Size = UDim2.new(1, -70, 0, 30)
pickerTitle.Font = Enum.Font.GothamBlack
pickerTitle.Text = "ВЫБЕРИ ПИТОМЦА"
pickerTitle.TextColor3 = Color3.fromRGB(221, 231, 255)
pickerTitle.TextSize = 16
pickerTitle.TextXAlignment = Enum.TextXAlignment.Left
pickerTitle.Parent = pickerPanel

local pickerClose = Instance.new("TextButton")
pickerClose.AnchorPoint = Vector2.new(1, 0)
pickerClose.Position = UDim2.new(1, -10, 0, 8)
pickerClose.Size = UDim2.fromOffset(36, 32)
pickerClose.BackgroundColor3 = Color3.fromRGB(74, 91, 101)
pickerClose.Text = "✕"
pickerClose.TextColor3 = Color3.new(1, 1, 1)
pickerClose.TextSize = 17
pickerClose.Font = Enum.Font.GothamBold
pickerClose.Parent = pickerPanel
addCorner(pickerClose, 9)

local pickerList = Instance.new("ScrollingFrame")
pickerList.Position = UDim2.fromOffset(10, 48)
pickerList.Size = UDim2.new(1, -20, 1, -58)
pickerList.BackgroundTransparency = 1
pickerList.BorderSizePixel = 0
pickerList.ScrollBarThickness = 6
pickerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
pickerList.Parent = pickerPanel

local pickerLayout = Instance.new("UIListLayout")
pickerLayout.Padding = UDim.new(0, 7)
pickerLayout.SortOrder = Enum.SortOrder.LayoutOrder
pickerLayout.Parent = pickerList

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

local selectedDisplaySlot = nil
local latestDisplayData = nil

local function invokeDisplay(payload)
    local success, response = pcall(function()
        return displayRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось связаться с гнездом.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Действие не выполнено.")
        return nil
    end
    if response.Message then showNotice(response.Message) end
    return response.Data
end

local renderDisplay

local function renderPicker(data)
    for _, child in ipairs(pickerList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    if #(data.Available or {}) == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -8, 0, 56)
        empty.BackgroundTransparency = 1
        empty.Text = "Нет свободных питомцев. Сними питомца с команды или витрины."
        empty.TextColor3 = Color3.fromRGB(190, 204, 223)
        empty.TextWrapped = true
        empty.Font = Enum.Font.GothamMedium
        empty.TextSize = 13
        empty.Parent = pickerList
        return
    end
    for index, companion in ipairs(data.Available) do
        local card = Instance.new("Frame")
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 72)
        card.BackgroundColor3 = Color3.fromRGB(55, 70, 88)
        card.BorderSizePixel = 0
        card.Parent = pickerList
        addCorner(card, 10)

        local info = Instance.new("TextLabel")
        info.BackgroundTransparency = 1
        info.Position = UDim2.fromOffset(10, 6)
        info.Size = UDim2.new(1, -122, 1, -12)
        info.Text = string.format("%s  %s\n%s · Ур. %d · +%d / 10 сек.", companion.Name, string.rep("★", companion.Stars or 1), companion.Rarity or "Обычный", companion.Level or 1, companion.Income or 0)
        info.TextColor3 = Color3.fromRGB(235, 239, 247)
        info.TextSize = 12
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.GothamMedium
        info.Parent = card

        local choose = Instance.new("TextButton")
        choose.AnchorPoint = Vector2.new(1, 0.5)
        choose.Position = UDim2.new(1, -8, 0.5, 0)
        choose.Size = UDim2.fromOffset(104, 36)
        choose.BackgroundColor3 = Color3.fromRGB(83, 151, 103)
        choose.Text = "ПОСТАВИТЬ"
        choose.TextColor3 = Color3.new(1, 1, 1)
        choose.TextSize = 11
        choose.Font = Enum.Font.GothamBlack
        choose.Parent = card
        addCorner(choose, 8)
        choose.Activated:Connect(function()
            choose.Active = false
            local updated = invokeDisplay({ Action = "Place", Slot = selectedDisplaySlot, InstanceId = companion.InstanceId })
            if updated then
                pickerPanel.Visible = false
                latestDisplayData = updated
                renderDisplay(updated)
            else
                choose.Active = true
            end
        end)
    end
end

renderDisplay = function(data)
    if not data then return end
    latestDisplayData = data
    local filledSlots = 0
    for _, entry in ipairs(data.Displayed or {}) do
        if not entry.Empty then filledSlots += 1 end
    end
    displayIncome.Text = string.format("Занято витрин: %d / %d  ·  Доход: +%d монет каждые %d сек.\nНакоплено: %d монет", filledSlots, data.SlotLimit or 0, data.IncomePerTick or 0, data.TickSeconds or 10, data.StoredCoins or 0)
    collectDisplay.Text = "СОБРАТЬ · " .. tostring(data.StoredCoins or 0) .. " 🪙"
    collectDisplay.Active = (data.StoredCoins or 0) > 0
    collectDisplay.AutoButtonColor = collectDisplay.Active
    for _, child in ipairs(displayList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    for index, entry in ipairs(data.Displayed or {}) do
        local card = Instance.new("Frame")
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 108)
        card.BackgroundColor3 = Color3.fromRGB(49, 66, 83)
        card.BorderSizePixel = 0
        card.Parent = displayList
        addCorner(card, 10)

        local info = Instance.new("TextLabel")
        info.BackgroundTransparency = 1
        info.Position = UDim2.fromOffset(10, 7)
        info.Size = UDim2.new(1, -118, 1, -14)
        info.Text = entry.Empty and ("Витрина №" .. entry.Slot .. "\nСвободное место") or string.format("Витрина №%d · %s\n%s · +%d / 10 сек.\nНастроение: %d%%", entry.Slot, entry.Name, entry.Rarity or "Обычный", entry.Income or 0, entry.Mood or 50)
        info.TextColor3 = Color3.fromRGB(236, 241, 247)
        info.TextSize = 12
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.GothamMedium
        info.Parent = card

        local action = Instance.new("TextButton")
        action.AnchorPoint = Vector2.new(1, 0.5)
        action.Position = UDim2.new(1, -8, 0, 10)
        action.AnchorPoint = Vector2.new(1, 0)
        action.Size = UDim2.fromOffset(102, 34)
        action.BackgroundColor3 = entry.Empty and Color3.fromRGB(83, 151, 103) or Color3.fromRGB(154, 91, 77)
        action.Text = entry.Empty and "ВЫБРАТЬ" or "СНЯТЬ"
        action.TextColor3 = Color3.new(1, 1, 1)
        action.TextSize = 11
        action.Font = Enum.Font.GothamBlack
        action.Parent = card
        addCorner(action, 8)
        action.Activated:Connect(function()
            if entry.Empty then
                selectedDisplaySlot = entry.Slot
                renderPicker(latestDisplayData)
                pickerPanel.Visible = true
            else
                action.Active = false
                local updated = invokeDisplay({ Action = "Remove", Slot = entry.Slot })
                if updated then renderDisplay(updated) else action.Active = true end
            end
        end)

        if not entry.Empty then
            local interact = Instance.new("TextButton")
            interact.AnchorPoint = Vector2.new(1, 1)
            interact.Position = UDim2.new(1, -8, 1, -8)
            interact.Size = UDim2.fromOffset(102, 34)
            interact.BackgroundColor3 = Color3.fromRGB(89, 143, 112)
            interact.Text = "ПОГЛАДИТЬ"
            interact.TextColor3 = Color3.new(1, 1, 1)
            interact.TextSize = 11
            interact.Font = Enum.Font.GothamBlack
            interact.Parent = card
            addCorner(interact, 8)
            interact.Activated:Connect(function()
                interact.Active = false
                local updated = invokeDisplay({
                    Action = "Interact",
                    Interaction = "Pet",
                    InstanceId = entry.InstanceId,
                })
                if updated then renderDisplay(updated) else interact.Active = true end
            end)
        end
    end
end

local function openDisplay()
    displayPanel.Visible = true
    local data = invokeDisplay({ Action = "Get" })
    if data then renderDisplay(data) end
end

displayButton.Activated:Connect(openDisplay)
displayClose.Activated:Connect(function() displayPanel.Visible = false end)
pickerClose.Activated:Connect(function() pickerPanel.Visible = false end)
collectDisplay.Activated:Connect(function()
    collectDisplay.Active = false
    local data = invokeDisplay({ Action = "Collect" })
    if data then renderDisplay(data) else collectDisplay.Active = true end
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
