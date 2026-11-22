local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("NestRaidersRemotes")
local inventoryRemote = remotes:WaitForChild("CompanionInventory")
local shopRemote = remotes:WaitForChild("EggShop")
local collectionRemote = remotes:WaitForChild("CollectionBook")
local nestRemote = remotes:WaitForChild("NestUpgrade")
local displayRemote = remotes:WaitForChild("DisplayPets")
local decorRemote = remotes:WaitForChild("NestDecor")
local buildRemote = remotes:WaitForChild("NestBuild")
local visitRemote = remotes:WaitForChild("IslandVisit")
local contestRemote = remotes:WaitForChild("IslandContest")

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

local decorButton = Instance.new("TextButton")
decorButton.Name = "NestDecorButton"
decorButton.Position = UDim2.fromOffset(18, 430)
decorButton.Size = UDim2.fromOffset(250, 46)
decorButton.BackgroundColor3 = Color3.fromRGB(169, 111, 157)
decorButton.Text = "УКРАСИТЬ ГНЕЗДО"
decorButton.TextColor3 = Color3.fromRGB(255, 255, 245)
decorButton.TextSize = 14
decorButton.Font = Enum.Font.GothamBlack
decorButton.Parent = gui
addCorner(decorButton, 12)
addStroke(decorButton, Color3.fromRGB(226, 174, 214), 1.5)

local buildButton = Instance.new("TextButton")
buildButton.Name = "IslandBuildButton"
buildButton.Position = UDim2.fromOffset(18, 484)
buildButton.Size = UDim2.fromOffset(250, 46)
buildButton.BackgroundColor3 = Color3.fromRGB(77, 132, 165)
buildButton.Text = "СТРОИТЬ ОСТРОВ"
buildButton.TextColor3 = Color3.fromRGB(255, 255, 245)
buildButton.TextSize = 14
buildButton.Font = Enum.Font.GothamBlack
buildButton.Parent = gui
addCorner(buildButton, 12)
addStroke(buildButton, Color3.fromRGB(153, 207, 234), 1.5)

local buildPanel = Instance.new("Frame")
buildPanel.Name = "IslandBuildPanel"
buildPanel.AnchorPoint = Vector2.new(0.5, 0.5)
buildPanel.Position = UDim2.fromScale(0.5, 0.5)
buildPanel.Size = UDim2.new(0.9, 0, 0.76, 0)
buildPanel.BackgroundColor3 = Color3.fromRGB(43, 51, 64)
buildPanel.BorderSizePixel = 0
buildPanel.Visible = false
buildPanel.Parent = gui
addCorner(buildPanel, 18)
addStroke(buildPanel, Color3.fromRGB(135, 190, 220), 2)
local buildSize = Instance.new("UISizeConstraint")
buildSize.MinSize = Vector2.new(290, 340)
buildSize.MaxSize = Vector2.new(480, 570)
buildSize.Parent = buildPanel

local buildTitle = Instance.new("TextLabel")
buildTitle.BackgroundTransparency = 1
buildTitle.Position = UDim2.fromOffset(18, 12)
buildTitle.Size = UDim2.new(1, -76, 0, 30)
buildTitle.Font = Enum.Font.GothamBlack
buildTitle.Text = "СТРОИТЕЛЬСТВО ОСТРОВА"
buildTitle.TextColor3 = Color3.fromRGB(191, 226, 248)
buildTitle.TextSize = 16
buildTitle.TextXAlignment = Enum.TextXAlignment.Left
buildTitle.Parent = buildPanel

local buildClose = Instance.new("TextButton")
buildClose.AnchorPoint = Vector2.new(1, 0)
buildClose.Position = UDim2.new(1, -12, 0, 10)
buildClose.Size = UDim2.fromOffset(38, 34)
buildClose.BackgroundColor3 = Color3.fromRGB(83, 91, 108)
buildClose.Text = "✕"
buildClose.TextColor3 = Color3.new(1, 1, 1)
buildClose.TextSize = 18
buildClose.Font = Enum.Font.GothamBold
buildClose.Parent = buildPanel
addCorner(buildClose, 10)

local buildBalance = Instance.new("TextLabel")
buildBalance.BackgroundTransparency = 1
buildBalance.Position = UDim2.fromOffset(18, 48)
buildBalance.Size = UDim2.new(1, -36, 0, 24)
buildBalance.Font = Enum.Font.GothamMedium
buildBalance.TextColor3 = Color3.fromRGB(218, 225, 235)
buildBalance.TextSize = 13
buildBalance.TextXAlignment = Enum.TextXAlignment.Left
buildBalance.Parent = buildPanel

local buildList = Instance.new("ScrollingFrame")
buildList.Position = UDim2.fromOffset(12, 80)
buildList.Size = UDim2.new(1, -24, 1, -94)
buildList.BackgroundTransparency = 1
buildList.BorderSizePixel = 0
buildList.ScrollBarThickness = 6
buildList.AutomaticCanvasSize = Enum.AutomaticSize.Y
buildList.Parent = buildPanel
local buildLayout = Instance.new("UIListLayout")
buildLayout.Padding = UDim.new(0, 8)
buildLayout.SortOrder = Enum.SortOrder.LayoutOrder
buildLayout.Parent = buildList

local visitButton = Instance.new("TextButton")
visitButton.Name = "VisitIslandsButton"
visitButton.Position = UDim2.fromOffset(18, 538)
visitButton.Size = UDim2.fromOffset(250, 46)
visitButton.BackgroundColor3 = Color3.fromRGB(102, 130, 183)
visitButton.Text = "ПОСЕТИТЬ ОСТРОВЫ"
visitButton.TextColor3 = Color3.fromRGB(255, 255, 245)
visitButton.TextSize = 14
visitButton.Font = Enum.Font.GothamBlack
visitButton.Parent = gui
addCorner(visitButton, 12)
addStroke(visitButton, Color3.fromRGB(170, 196, 238), 1.5)

local visitPanel = Instance.new("Frame")
visitPanel.Name = "IslandVisitPanel"
visitPanel.AnchorPoint = Vector2.new(0.5, 0.5)
visitPanel.Position = UDim2.fromScale(0.5, 0.5)
visitPanel.Size = UDim2.new(0.9, 0, 0.66, 0)
visitPanel.BackgroundColor3 = Color3.fromRGB(43, 51, 64)
visitPanel.BorderSizePixel = 0
visitPanel.Visible = false
visitPanel.Parent = gui
addCorner(visitPanel, 18)
addStroke(visitPanel, Color3.fromRGB(150, 178, 225), 2)
local visitSize = Instance.new("UISizeConstraint")
visitSize.MinSize = Vector2.new(290, 280)
visitSize.MaxSize = Vector2.new(440, 480)
visitSize.Parent = visitPanel

local visitTitle = Instance.new("TextLabel")
visitTitle.BackgroundTransparency = 1
visitTitle.Position = UDim2.fromOffset(18, 12)
visitTitle.Size = UDim2.new(1, -76, 0, 30)
visitTitle.Font = Enum.Font.GothamBlack
visitTitle.Text = "ОСТРОВА ИГРОКОВ"
visitTitle.TextColor3 = Color3.fromRGB(201, 218, 255)
visitTitle.TextSize = 16
visitTitle.TextXAlignment = Enum.TextXAlignment.Left
visitTitle.Parent = visitPanel

local visitClose = Instance.new("TextButton")
visitClose.AnchorPoint = Vector2.new(1, 0)
visitClose.Position = UDim2.new(1, -12, 0, 10)
visitClose.Size = UDim2.fromOffset(38, 34)
visitClose.BackgroundColor3 = Color3.fromRGB(83, 91, 108)
visitClose.Text = "✕"
visitClose.TextColor3 = Color3.new(1, 1, 1)
visitClose.TextSize = 18
visitClose.Font = Enum.Font.GothamBold
visitClose.Parent = visitPanel
addCorner(visitClose, 10)

local visitStatus = Instance.new("TextLabel")
visitStatus.BackgroundTransparency = 1
visitStatus.Position = UDim2.fromOffset(18, 48)
visitStatus.Size = UDim2.new(1, -150, 0, 24)
visitStatus.Font = Enum.Font.GothamMedium
visitStatus.Text = "Выбери остров для посещения"
visitStatus.TextColor3 = Color3.fromRGB(218, 225, 235)
visitStatus.TextSize = 12
visitStatus.TextXAlignment = Enum.TextXAlignment.Left
visitStatus.Parent = visitPanel

local showFavoriteIslandsOnly = false
local visitFilterButton = Instance.new("TextButton")
visitFilterButton.Position = UDim2.new(1, -128, 0, 45)
visitFilterButton.Size = UDim2.fromOffset(110, 28)
visitFilterButton.BackgroundColor3 = Color3.fromRGB(89, 103, 136)
visitFilterButton.Text = "ВСЕ ОСТРОВА"
visitFilterButton.TextColor3 = Color3.new(1, 1, 1)
visitFilterButton.TextSize = 9
visitFilterButton.Font = Enum.Font.GothamBlack
visitFilterButton.Parent = visitPanel
addCorner(visitFilterButton, 8)

local visitList = Instance.new("ScrollingFrame")
visitList.Position = UDim2.fromOffset(12, 80)
visitList.Size = UDim2.new(1, -24, 1, -94)
visitList.BackgroundTransparency = 1
visitList.BorderSizePixel = 0
visitList.ScrollBarThickness = 6
visitList.AutomaticCanvasSize = Enum.AutomaticSize.Y
visitList.Parent = visitPanel
local visitLayout = Instance.new("UIListLayout")
visitLayout.Padding = UDim.new(0, 8)
visitLayout.SortOrder = Enum.SortOrder.LayoutOrder
visitLayout.Parent = visitList

local contestButton = Instance.new("TextButton")
contestButton.Name = "IslandContestButton"
contestButton.Position = UDim2.fromOffset(18, 592)
contestButton.Size = UDim2.fromOffset(250, 44)
contestButton.BackgroundColor3 = Color3.fromRGB(166, 119, 66)
contestButton.Text = "КОНКУРС ОСТРОВОВ"
contestButton.TextColor3 = Color3.fromRGB(255, 245, 220)
contestButton.TextSize = 13
contestButton.Font = Enum.Font.GothamBlack
contestButton.Parent = gui
addCorner(contestButton, 12)
addStroke(contestButton, Color3.fromRGB(231, 190, 111), 1.5)

local contestPanel = Instance.new("Frame")
contestPanel.Name = "IslandContestPanel"
contestPanel.AnchorPoint = Vector2.new(0.5, 0.5)
contestPanel.Position = UDim2.fromScale(0.5, 0.5)
contestPanel.Size = UDim2.new(0.9, 0, 0.8, 0)
contestPanel.BackgroundColor3 = Color3.fromRGB(44, 48, 65)
contestPanel.BorderSizePixel = 0
contestPanel.Visible = false
contestPanel.Parent = gui
addCorner(contestPanel, 18)
addStroke(contestPanel, Color3.fromRGB(222, 184, 112), 2)
local contestSize = Instance.new("UISizeConstraint")
contestSize.MinSize = Vector2.new(290, 340)
contestSize.MaxSize = Vector2.new(480, 570)
contestSize.Parent = contestPanel

local contestTitle = Instance.new("TextLabel")
contestTitle.BackgroundTransparency = 1
contestTitle.Position = UDim2.fromOffset(18, 12)
contestTitle.Size = UDim2.new(1, -76, 0, 28)
contestTitle.Font = Enum.Font.GothamBlack
contestTitle.Text = "ЕЖЕНЕДЕЛЬНЫЙ КОНКУРС"
contestTitle.TextColor3 = Color3.fromRGB(255, 220, 151)
contestTitle.TextSize = 15
contestTitle.TextXAlignment = Enum.TextXAlignment.Left
contestTitle.Parent = contestPanel

local contestClose = Instance.new("TextButton")
contestClose.AnchorPoint = Vector2.new(1, 0)
contestClose.Position = UDim2.new(1, -12, 0, 10)
contestClose.Size = UDim2.fromOffset(38, 34)
contestClose.BackgroundColor3 = Color3.fromRGB(83, 91, 108)
contestClose.Text = "✕"
contestClose.TextColor3 = Color3.new(1, 1, 1)
contestClose.TextSize = 18
contestClose.Font = Enum.Font.GothamBold
contestClose.Parent = contestPanel
addCorner(contestClose, 10)

local contestWeek = Instance.new("TextLabel")
contestWeek.BackgroundTransparency = 1
contestWeek.Position = UDim2.fromOffset(18, 42)
contestWeek.Size = UDim2.new(1, -36, 0, 22)
contestWeek.Font = Enum.Font.GothamMedium
contestWeek.Text = "Загрузка недели..."
contestWeek.TextColor3 = Color3.fromRGB(213, 218, 231)
contestWeek.TextSize = 11
contestWeek.TextXAlignment = Enum.TextXAlignment.Left
contestWeek.Parent = contestPanel

local contestTabs = Instance.new("Frame")
contestTabs.BackgroundTransparency = 1
contestTabs.Position = UDim2.fromOffset(12, 70)
contestTabs.Size = UDim2.new(1, -24, 0, 34)
contestTabs.Parent = contestPanel
local contestTabLayout = Instance.new("UIListLayout")
contestTabLayout.FillDirection = Enum.FillDirection.Horizontal
contestTabLayout.Padding = UDim.new(0, 6)
contestTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
contestTabLayout.Parent = contestTabs

local contestList = Instance.new("ScrollingFrame")
contestList.Position = UDim2.fromOffset(12, 112)
contestList.Size = UDim2.new(1, -24, 1, -124)
contestList.BackgroundTransparency = 1
contestList.BorderSizePixel = 0
contestList.ScrollBarThickness = 6
contestList.AutomaticCanvasSize = Enum.AutomaticSize.Y
contestList.Parent = contestPanel
local contestListLayout = Instance.new("UIListLayout")
contestListLayout.Padding = UDim.new(0, 7)
contestListLayout.SortOrder = Enum.SortOrder.LayoutOrder
contestListLayout.Parent = contestList

local decorPanel = Instance.new("Frame")
decorPanel.Name = "NestDecorPanel"
decorPanel.AnchorPoint = Vector2.new(0.5, 0.5)
decorPanel.Position = UDim2.fromScale(0.5, 0.5)
decorPanel.Size = UDim2.new(0.9, 0, 0.76, 0)
decorPanel.BackgroundColor3 = Color3.fromRGB(48, 43, 61)
decorPanel.BorderSizePixel = 0
decorPanel.Visible = false
decorPanel.Parent = gui
addCorner(decorPanel, 18)
addStroke(decorPanel, Color3.fromRGB(222, 165, 208), 2)

local decorSize = Instance.new("UISizeConstraint")
decorSize.MinSize = Vector2.new(290, 330)
decorSize.MaxSize = Vector2.new(470, 560)
decorSize.Parent = decorPanel

local decorTitle = Instance.new("TextLabel")
decorTitle.BackgroundTransparency = 1
decorTitle.Position = UDim2.fromOffset(18, 12)
decorTitle.Size = UDim2.new(1, -76, 0, 30)
decorTitle.Font = Enum.Font.GothamBlack
decorTitle.Text = "УЮТНОЕ ГНЕЗДО"
decorTitle.TextColor3 = Color3.fromRGB(255, 213, 237)
decorTitle.TextSize = 18
decorTitle.TextXAlignment = Enum.TextXAlignment.Left
decorTitle.Parent = decorPanel

local decorClose = Instance.new("TextButton")
decorClose.AnchorPoint = Vector2.new(1, 0)
decorClose.Position = UDim2.new(1, -12, 0, 10)
decorClose.Size = UDim2.fromOffset(38, 34)
decorClose.BackgroundColor3 = Color3.fromRGB(83, 75, 99)
decorClose.Text = "✕"
decorClose.TextColor3 = Color3.new(1, 1, 1)
decorClose.TextSize = 18
decorClose.Font = Enum.Font.GothamBold
decorClose.Parent = decorPanel
addCorner(decorClose, 10)

local decorBalance = Instance.new("TextLabel")
decorBalance.BackgroundTransparency = 1
decorBalance.Position = UDim2.fromOffset(18, 48)
decorBalance.Size = UDim2.new(1, -36, 0, 24)
decorBalance.Font = Enum.Font.GothamMedium
decorBalance.TextColor3 = Color3.fromRGB(224, 213, 232)
decorBalance.TextSize = 13
decorBalance.TextXAlignment = Enum.TextXAlignment.Left
decorBalance.Parent = decorPanel

local decorList = Instance.new("ScrollingFrame")
decorList.Position = UDim2.fromOffset(12, 78)
decorList.Size = UDim2.new(1, -24, 1, -130)
decorList.BackgroundTransparency = 1
decorList.BorderSizePixel = 0
decorList.ScrollBarThickness = 6
decorList.AutomaticCanvasSize = Enum.AutomaticSize.Y
decorList.Parent = decorPanel

local dragHint = Instance.new("TextLabel")
dragHint.Name = "PlacementHint"
dragHint.BackgroundColor3 = Color3.fromRGB(54, 104, 85)
dragHint.BackgroundTransparency = 0.08
dragHint.AnchorPoint = Vector2.new(0.5, 1)
dragHint.Position = UDim2.new(0.5, 0, 1, -58)
dragHint.Size = UDim2.fromOffset(320, 28)
dragHint.Font = Enum.Font.GothamBold
dragHint.Text = "Режим размещения"
dragHint.TextColor3 = Color3.new(1, 1, 1)
dragHint.TextSize = 10
dragHint.Visible = false
dragHint.Parent = gui
addCorner(dragHint, 8)

local dragRotateButton = Instance.new("TextButton")
dragRotateButton.Name = "PlacementRotate"
dragRotateButton.AnchorPoint = Vector2.new(1, 1)
dragRotateButton.Position = UDim2.new(1, -18, 1, -18)
dragRotateButton.Size = UDim2.fromOffset(112, 34)
dragRotateButton.BackgroundColor3 = Color3.fromRGB(112, 101, 164)
dragRotateButton.Text = "ПОВОРОТ ↻"
dragRotateButton.TextColor3 = Color3.new(1, 1, 1)
dragRotateButton.TextSize = 10
dragRotateButton.Font = Enum.Font.GothamBlack
dragRotateButton.Visible = false
dragRotateButton.Parent = gui
addCorner(dragRotateButton, 8)

local dragCancelButton = Instance.new("TextButton")
dragCancelButton.Name = "PlacementCancel"
dragCancelButton.AnchorPoint = Vector2.new(0, 1)
dragCancelButton.Position = UDim2.new(0, 18, 1, -18)
dragCancelButton.Size = UDim2.fromOffset(112, 34)
dragCancelButton.BackgroundColor3 = Color3.fromRGB(151, 86, 91)
dragCancelButton.Text = "ОТМЕНА"
dragCancelButton.TextColor3 = Color3.new(1, 1, 1)
dragCancelButton.TextSize = 10
dragCancelButton.Font = Enum.Font.GothamBlack
dragCancelButton.Visible = false
dragCancelButton.Parent = gui
addCorner(dragCancelButton, 8)

buildHint = Instance.new("TextLabel")
buildHint.Name = "BuildPlacementHint"
buildHint.AnchorPoint = Vector2.new(0.5, 1)
buildHint.Position = UDim2.new(0.5, 0, 1, -58)
buildHint.Size = UDim2.fromOffset(320, 28)
buildHint.BackgroundColor3 = Color3.fromRGB(54, 104, 85)
buildHint.BackgroundTransparency = 0.08
buildHint.Font = Enum.Font.GothamBold
buildHint.Text = "Режим строительства"
buildHint.TextColor3 = Color3.new(1, 1, 1)
buildHint.TextSize = 10
buildHint.Visible = false
buildHint.Parent = gui
addCorner(buildHint, 8)

buildRotateButton = Instance.new("TextButton")
buildRotateButton.Name = "BuildPlacementRotate"
buildRotateButton.AnchorPoint = Vector2.new(1, 1)
buildRotateButton.Position = UDim2.new(1, -138, 1, -18)
buildRotateButton.Size = UDim2.fromOffset(112, 34)
buildRotateButton.BackgroundColor3 = Color3.fromRGB(112, 101, 164)
buildRotateButton.Text = "ПОВОРОТ ↻"
buildRotateButton.TextColor3 = Color3.new(1, 1, 1)
buildRotateButton.TextSize = 10
buildRotateButton.Font = Enum.Font.GothamBlack
buildRotateButton.Visible = false
buildRotateButton.Parent = gui
addCorner(buildRotateButton, 8)
buildRotateButton.Activated:Connect(function()
    if activeBuildPlacement then buildRotation = (buildRotation + 15) % 360 end
end)

buildCancelButton = Instance.new("TextButton")
buildCancelButton.Name = "BuildPlacementCancel"
buildCancelButton.AnchorPoint = Vector2.new(0, 1)
buildCancelButton.Position = UDim2.new(0, 18, 1, -18)
buildCancelButton.Size = UDim2.fromOffset(112, 34)
buildCancelButton.BackgroundColor3 = Color3.fromRGB(151, 86, 91)
buildCancelButton.Text = "ОТМЕНА"
buildCancelButton.TextColor3 = Color3.new(1, 1, 1)
buildCancelButton.TextSize = 10
buildCancelButton.Font = Enum.Font.GothamBlack
buildCancelButton.Visible = false
buildCancelButton.Parent = gui
addCorner(buildCancelButton, 8)
buildCancelButton.Activated:Connect(function()
    if activeBuildPlacement then stopBuildPlacement(true) end
end)

local decorLayout = Instance.new("UIListLayout")
decorLayout.Padding = UDim.new(0, 8)
decorLayout.SortOrder = Enum.SortOrder.LayoutOrder
decorLayout.Parent = decorList

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

local function invokeDecor(payload)
    local success, response = pcall(function()
        return decorRemote:InvokeServer(payload)
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

local function clearDecorList()
    for _, child in ipairs(decorList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local function renderDecor(data)
    if not data then return end
    decorBalance.Text = string.format("Монеты: %d  ·  Открыто мест: %d", data.Coins or 0, data.SlotLimit or 0)
    clearDecorList()

    local inventoryById = {}
    for _, item in ipairs(data.Inventory or {}) do inventoryById[item.Id] = item.Count end
    local occupiedBySlot = {}
    for _, item in ipairs(data.Placed or {}) do occupiedBySlot[item.Slot] = item end

    for index, item in ipairs(data.Catalog or {}) do
        local card = Instance.new("Frame")
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 76)
        card.BackgroundColor3 = Color3.fromRGB(66, 57, 78)
        card.BorderSizePixel = 0
        card.Parent = decorList
        addCorner(card, 10)

        local info = Instance.new("TextLabel")
        info.BackgroundTransparency = 1
        info.Position = UDim2.fromOffset(10, 6)
        info.Size = UDim2.new(1, -158, 1, -12)
        info.Text = string.format("%s\n%s\nВ наличии: %d", item.Name, item.Description or "", inventoryById[item.Id] or 0)
        info.TextColor3 = Color3.fromRGB(246, 237, 247)
        info.TextSize = 11
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.GothamMedium
        info.Parent = card

        local buy = Instance.new("TextButton")
        buy.AnchorPoint = Vector2.new(1, 0)
        buy.Position = UDim2.new(1, -8, 0, 7)
        buy.Size = UDim2.fromOffset(92, 28)
        buy.BackgroundColor3 = Color3.fromRGB(181, 132, 69)
        buy.Text = "КУПИТЬ " .. tostring(item.Cost) .. "🪙"
        buy.TextColor3 = Color3.new(1, 1, 1)
        buy.TextSize = 9
        buy.Font = Enum.Font.GothamBlack
        buy.Parent = card
        addCorner(buy, 8)
        buy.Activated:Connect(function()
            buy.Active = false
            local updated = invokeDecor({ Action = "Buy", DecorId = item.Id })
            if updated then renderDecor(updated) else buy.Active = true end
        end)

        local place = Instance.new("TextButton")
        place.AnchorPoint = Vector2.new(1, 0)
        place.Position = UDim2.new(1, -8, 0, 41)
        place.Size = UDim2.fromOffset(92, 28)
        place.BackgroundColor3 = Color3.fromRGB(83, 151, 103)
        place.Text = "ПОСТАВИТЬ"
        place.TextColor3 = Color3.new(1, 1, 1)
        place.TextSize = 9
        place.Font = Enum.Font.GothamBlack
        place.Parent = card
        addCorner(place, 8)
        place.Active = (inventoryById[item.Id] or 0) > 0
        place.AutoButtonColor = place.Active
        place.Activated:Connect(function()
            if not place.Active then return end
            local freeSlot = nil
            for slot = 1, data.SlotLimit or 0 do
                if not occupiedBySlot[slot] then freeSlot = slot break end
            end
            if not freeSlot then
                showNotice("Все места заняты. Сними украшение или улучши гнездо.")
                return
            end
            place.Active = false
            local updated = invokeDecor({ Action = "Place", DecorId = item.Id, Slot = freeSlot })
            if updated then renderDecor(updated) else place.Active = true end
        end)
    end

    local heading = Instance.new("TextLabel")
    heading.LayoutOrder = 20
    heading.Size = UDim2.new(1, -8, 0, 28)
    heading.BackgroundTransparency = 1
    heading.Text = "ТВОИ УКРАШЕНИЯ"
    heading.TextColor3 = Color3.fromRGB(255, 213, 237)
    heading.TextSize = 13
    heading.Font = Enum.Font.GothamBlack
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = decorList

    for slot = 1, data.SlotLimit or 0 do
        local currentSlot = slot
        local item = occupiedBySlot[currentSlot]
        local currentItem = item
        local row = Instance.new("Frame")
        row.LayoutOrder = 20 + slot
        row.Size = UDim2.new(1, -8, 0, 76)
        row.BackgroundColor3 = Color3.fromRGB(58, 54, 72)
        row.BorderSizePixel = 0
        row.Parent = decorList
        addCorner(row, 8)

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(10, 3)
        label.Size = UDim2.new(1, -112, 0, 30)
        label.Text = item and string.format("%s\nX:%d  Z:%d  ·  %d°", currentItem.Name, currentItem.X or 0, currentItem.Z or 0, currentItem.Rotation or 0) or ("Место " .. slot .. " · Свободно")
        label.TextWrapped = true
        label.TextColor3 = Color3.fromRGB(235, 229, 239)
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamMedium
        label.Parent = row

        if item then
            local controls = {
                { Text = "↑", X = 8, DX = 0, DZ = -2 },
                { Text = "←", X = 38, DX = -2, DZ = 0 },
                { Text = "↓", X = 68, DX = 0, DZ = 2 },
                { Text = "→", X = 98, DX = 2, DZ = 0 },
                { Text = "↻", X = 128, Rotate = 15 },
            }
            for _, control in ipairs(controls) do
                local currentControl = control
                local moveButton = Instance.new("TextButton")
                moveButton.Position = UDim2.fromOffset(currentControl.X, 43)
                moveButton.Size = UDim2.fromOffset(26, 25)
                moveButton.BackgroundColor3 = currentControl.Rotate and Color3.fromRGB(112, 101, 164) or Color3.fromRGB(77, 119, 139)
                moveButton.Text = currentControl.Text
                moveButton.TextColor3 = Color3.new(1, 1, 1)
                moveButton.TextSize = 14
                moveButton.Font = Enum.Font.GothamBlack
                moveButton.Parent = row
                addCorner(moveButton, 7)
                moveButton.Activated:Connect(function()
                    moveButton.Active = false
                    local updated = invokeDecor({
                        Action = "Move",
                        Slot = currentSlot,
                        X = (currentItem.X or 0) + (currentControl.DX or 0),
                        Z = (currentItem.Z or 0) + (currentControl.DZ or 0),
                        Rotation = (currentItem.Rotation or 0) + (currentControl.Rotate or 0),
                    })
                    if updated then renderDecor(updated) else moveButton.Active = true end
                end)
            end

            local dragButton = Instance.new("TextButton")
            dragButton.Position = UDim2.fromOffset(160, 43)
            dragButton.Size = UDim2.fromOffset(82, 25)
            dragButton.BackgroundColor3 = Color3.fromRGB(62, 145, 112)
            dragButton.Text = "ТАЩИТЬ"
            dragButton.TextColor3 = Color3.new(1, 1, 1)
            dragButton.TextSize = 9
            dragButton.Font = Enum.Font.GothamBlack
            dragButton.Parent = row
            addCorner(dragButton, 7)
            dragButton.Activated:Connect(function()
                startDecorDrag(currentSlot, currentItem)
            end)

            local remove = Instance.new("TextButton")
            remove.AnchorPoint = Vector2.new(1, 0.5)
            remove.Position = UDim2.new(1, -6, 0, 7)
            remove.Size = UDim2.fromOffset(92, 30)
            remove.BackgroundColor3 = Color3.fromRGB(151, 86, 91)
            remove.Text = "УБРАТЬ"
            remove.TextColor3 = Color3.new(1, 1, 1)
            remove.TextSize = 10
            remove.Font = Enum.Font.GothamBlack
            remove.Parent = row
            addCorner(remove, 8)
            remove.Activated:Connect(function()
                remove.Active = false
                local updated = invokeDecor({ Action = "Remove", Slot = currentSlot })
                if updated then renderDecor(updated) else remove.Active = true end
            end)
        end
    end
end

local function invokeBuild(payload)
    local success, response = pcall(function()
        return buildRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось связаться со строительством.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Действие не выполнено.")
        return nil
    end
    if response.Message then showNotice(response.Message) end
    return response.Data
end

local renderBuild
local buildHint, buildRotateButton, buildCancelButton
local activeBuildPlacement = nil
local buildPreview = nil
local buildRotation = 0
local buildScreenPosition = nil
local buildInputConnections = {}

local function getBuildGrass()
    local world = Workspace:FindFirstChild("NestRaidersWorld")
    local island = world and world:FindFirstChild("StarterIsland")
    local plots = island and island:FindFirstChild("PlayerPlots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == player.UserId then
            return plot:FindFirstChild("PlotGrass")
        end
    end
    return nil
end

local function stopBuildPlacement(reopen)
    activeBuildPlacement = nil
    buildScreenPosition = nil
    if buildPreview then buildPreview:Destroy(); buildPreview = nil end
    for _, connection in ipairs(buildInputConnections) do connection:Disconnect() end
    table.clear(buildInputConnections)
    buildHint.Visible = false
    buildRotateButton.Visible = false
    buildCancelButton.Visible = false
    if reopen then
        buildPanel.Visible = true
        local latest = invokeBuild({ Action = "Get" })
        if latest then renderBuild(latest) end
    end
end

local function getBuildPlacement(screenPosition)
    if not activeBuildPlacement then return nil end
    local grass = activeBuildPlacement.Grass
    local camera = Workspace.CurrentCamera
    if not grass or not camera then return nil end
    local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { grass }
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if not result then return nil end

    local center = grass.Position
    local x = math.clamp(math.floor((result.Position.X - center.X) / 2 + 0.5) * 2, -14, 14)
    local z = math.clamp(math.floor((result.Position.Z - center.Z) / 2 + 0.5) * 2, -14, 14)
    local footprint = activeBuildPlacement.Footprint
    local valid = math.abs(x) + footprint / 2 <= 15 and math.abs(z) + footprint / 2 <= 15
    for _, other in ipairs(activeBuildPlacement.Placed or {}) do
        if not (activeBuildPlacement.Mode == "Move" and other.Key == activeBuildPlacement.Key) then
            local gap = (footprint + (other.Footprint or 2)) / 2
            if math.abs(x - other.X) < gap and math.abs(z - other.Z) < gap then
                valid = false
                break
            end
        end
    end
    return {
        X = x, Z = z, Valid = valid,
        WorldPosition = Vector3.new(center.X + x, grass.Position.Y + grass.Size.Y / 2 + 0.16, center.Z + z),
    }
end

local function updateBuildPreview(screenPosition)
    if not activeBuildPlacement or not buildPreview then return end
    local placement = getBuildPlacement(screenPosition)
    if not placement then
        buildPreview.Transparency = 0.82
        return
    end
    buildPreview.CFrame = CFrame.new(placement.WorldPosition) * CFrame.Angles(0, math.rad(buildRotation), 0)
    buildPreview.Color = placement.Valid and Color3.fromRGB(93, 231, 153) or Color3.fromRGB(238, 91, 91)
    buildPreview.Transparency = 0.35
end

local function confirmBuildPlacement(screenPosition)
    if not activeBuildPlacement then return end
    local placement = getBuildPlacement(screenPosition)
    if not placement or not placement.Valid then
        showNotice("Это место занято или выходит за границы острова.")
        return
    end
    local state = activeBuildPlacement
    local payload = {
        Action = state.Mode,
        X = placement.X,
        Z = placement.Z,
        Rotation = buildRotation,
    }
    if state.Mode == "Place" then
        payload.BuildId = state.BuildId
    else
        payload.Key = state.Key
    end
    local updated = invokeBuild(payload)
    if updated then
        stopBuildPlacement(true)
        renderBuild(updated)
    end
end

local function startBuildPlacement(state)
    stopBuildPlacement(false)
    local grass = getBuildGrass()
    if not grass then
        showNotice("Не удалось найти твой остров.")
        return
    end
    activeBuildPlacement = state
    activeBuildPlacement.Grass = grass
    buildRotation = state.Rotation or 0
    buildScreenPosition = UserInputService:GetMouseLocation()
    buildPanel.Visible = false

    buildPreview = Instance.new("Part")
    buildPreview.Name = "IslandBuildPlacementPreview"
    buildPreview.Size = Vector3.new(state.Footprint, 0.22, state.Footprint)
    buildPreview.Anchored = true
    buildPreview.CanCollide = false
    buildPreview.CanTouch = false
    buildPreview.CanQuery = false
    buildPreview.Material = Enum.Material.Neon
    buildPreview.Color = Color3.fromRGB(93, 231, 153)
    buildPreview.Transparency = 0.35
    buildPreview.Parent = Workspace

    buildHint.Text = "Выбери место · R — поворот · Esc — отмена"
    buildHint.Visible = true
    buildRotateButton.Visible = true
    buildCancelButton.Visible = true

    table.insert(buildInputConnections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            buildScreenPosition = input.Position
            updateBuildPreview(buildScreenPosition)
        end
    end))
    table.insert(buildInputConnections, UserInputService.InputBegan:Connect(function(input, processed)
        if not activeBuildPlacement then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            stopBuildPlacement(true)
            return
        elseif input.KeyCode == Enum.KeyCode.R then
            buildRotation = (buildRotation + 15) % 360
            return
        end
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            confirmBuildPlacement(UserInputService:GetMouseLocation())
        elseif input.UserInputType == Enum.UserInputType.Touch then
            confirmBuildPlacement(input.Position)
        end
    end))
    table.insert(buildInputConnections, RunService.RenderStepped:Connect(function()
        if activeBuildPlacement then
            if UserInputService.MouseEnabled then
                buildScreenPosition = UserInputService:GetMouseLocation()
            end
            if buildScreenPosition then updateBuildPreview(buildScreenPosition) end
        end
    end))
    showNotice(state.Mode == "Place" and "Выбери место для новой постройки." or "Перемести постройку на острове.")
end

local function clearBuildList()
    for _, child in ipairs(buildList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local function findBuildPosition(data, footprint)
    local occupied = {}
    for _, item in ipairs(data.Placed or {}) do
        occupied[#occupied + 1] = {
            X = item.X, Z = item.Z,
            Footprint = (item.Footprint or 2),
        }
    end
    for z = -14, 14, 2 do
        for x = -14, 14, 2 do
            local free = true
            for _, item in ipairs(occupied) do
                local gap = (footprint + item.Footprint) / 2
                if math.abs(x - item.X) < gap and math.abs(z - item.Z) < gap then
                    free = false
                    break
                end
            end
            if free then return x, z end
        end
    end
    return nil, nil
end

renderBuild = function(data)
    if not data then return end
    buildBalance.Text = string.format("Монеты: %d  ·  Построек: %d / 100", data.Coins or 0, #(data.Placed or {}))
    clearBuildList()
    local inventory = {}
    for _, item in ipairs(data.Inventory or {}) do inventory[item.Id] = item.Count end

    local section = Instance.new("TextLabel")
    section.LayoutOrder = 0
    section.Size = UDim2.new(1, -8, 0, 26)
    section.BackgroundTransparency = 1
    section.Text = "КАТАЛОГ"
    section.TextColor3 = Color3.fromRGB(191, 226, 248)
    section.TextSize = 13
    section.Font = Enum.Font.GothamBlack
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = buildList

    for index, item in ipairs(data.Catalog or {}) do
        local card = Instance.new("Frame")
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 82)
        card.BackgroundColor3 = Color3.fromRGB(61, 70, 84)
        card.BorderSizePixel = 0
        card.Parent = buildList
        addCorner(card, 10)

        local info = Instance.new("TextLabel")
        info.BackgroundTransparency = 1
        info.Position = UDim2.fromOffset(10, 6)
        info.Size = UDim2.new(1, -170, 1, -12)
        info.Text = string.format("%s\n%s\nВ наличии: %d", item.Name, item.Description or "", inventory[item.Id] or 0)
        info.TextColor3 = Color3.fromRGB(239, 241, 246)
        info.TextSize = 11
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.GothamMedium
        info.Parent = card

        local buy = Instance.new("TextButton")
        buy.AnchorPoint = Vector2.new(1, 0)
        buy.Position = UDim2.new(1, -8, 0, 8)
        buy.Size = UDim2.fromOffset(102, 30)
        buy.BackgroundColor3 = Color3.fromRGB(183, 137, 67)
        buy.Text = "КУПИТЬ " .. tostring(item.Cost) .. "🪙"
        buy.TextColor3 = Color3.new(1, 1, 1)
        buy.TextSize = 10
        buy.Font = Enum.Font.GothamBlack
        buy.Parent = card
        addCorner(buy, 8)
        buy.Activated:Connect(function()
            buy.Active = false
            local updated = invokeBuild({ Action = "Buy", BuildId = item.Id })
            if updated then renderBuild(updated) else buy.Active = true end
        end)

        local place = Instance.new("TextButton")
        place.AnchorPoint = Vector2.new(1, 0)
        place.Position = UDim2.new(1, -8, 0, 44)
        place.Size = UDim2.fromOffset(102, 30)
        place.BackgroundColor3 = Color3.fromRGB(67, 143, 112)
        place.Text = "ПОСТАВИТЬ"
        place.TextColor3 = Color3.new(1, 1, 1)
        place.TextSize = 10
        place.Font = Enum.Font.GothamBlack
        place.Parent = card
        addCorner(place, 8)
        place.Active = (inventory[item.Id] or 0) > 0
        place.AutoButtonColor = place.Active
        place.Activated:Connect(function()
            if not place.Active then return end
            startBuildPlacement({
                Mode = "Place",
                BuildId = item.Id,
                Footprint = item.Footprint or 2,
                Placed = data.Placed or {},
            })
        end)
    end

    local placedTitle = Instance.new("TextLabel")
    placedTitle.LayoutOrder = 20
    placedTitle.Size = UDim2.new(1, -8, 0, 26)
    placedTitle.BackgroundTransparency = 1
    placedTitle.Text = "ТВОИ ПОСТРОЙКИ"
    placedTitle.TextColor3 = Color3.fromRGB(191, 226, 248)
    placedTitle.TextSize = 13
    placedTitle.Font = Enum.Font.GothamBlack
    placedTitle.TextXAlignment = Enum.TextXAlignment.Left
    placedTitle.Parent = buildList

    for index, item in ipairs(data.Placed or {}) do
        local currentItem = item
        local row = Instance.new("Frame")
        row.LayoutOrder = 20 + index
        row.Size = UDim2.new(1, -8, 0, 74)
        row.BackgroundColor3 = Color3.fromRGB(55, 63, 77)
        row.BorderSizePixel = 0
        row.Parent = buildList
        addCorner(row, 9)

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(10, 5)
        label.Size = UDim2.new(1, -120, 0, 27)
        label.Text = string.format("%s · X:%d Z:%d", item.Name, item.X, item.Z)
        label.TextColor3 = Color3.fromRGB(238, 239, 245)
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamMedium
        label.Parent = row

        local controls = {
            { Text = "←", X = 8, DX = -2 },
            { Text = "→", X = 40, DX = 2 },
            { Text = "↑", X = 72, DZ = -2 },
            { Text = "↓", X = 104, DZ = 2 },
            { Text = "↻", X = 136, Rotate = 15 },
        }
        for _, control in ipairs(controls) do
            local currentControl = control
            local move = Instance.new("TextButton")
            move.Position = UDim2.fromOffset(currentControl.X, 40)
            move.Size = UDim2.fromOffset(27, 25)
            move.BackgroundColor3 = Color3.fromRGB(76, 119, 145)
            move.Text = currentControl.Text
            move.TextColor3 = Color3.new(1, 1, 1)
            move.TextSize = 12
            move.Font = Enum.Font.GothamBlack
            move.Parent = row
            addCorner(move, 7)
            move.Activated:Connect(function()
                local updated = invokeBuild({
                    Action = "Move", Key = currentItem.Key,
                    X = currentItem.X + (currentControl.DX or 0),
                    Z = currentItem.Z + (currentControl.DZ or 0),
                    Rotation = (currentItem.Rotation or 0) + (currentControl.Rotate or 0),
                })
                if updated then renderBuild(updated) end
            end)
        end

        local movePlacement = Instance.new("TextButton")
        movePlacement.Position = UDim2.fromOffset(168, 40)
        movePlacement.Size = UDim2.fromOffset(76, 25)
        movePlacement.BackgroundColor3 = Color3.fromRGB(62, 145, 112)
        movePlacement.Text = "ТАЩИТЬ"
        movePlacement.TextColor3 = Color3.new(1, 1, 1)
        movePlacement.TextSize = 9
        movePlacement.Font = Enum.Font.GothamBlack
        movePlacement.Parent = row
        addCorner(movePlacement, 7)
        movePlacement.Activated:Connect(function()
            startBuildPlacement({
                Mode = "Move",
                Key = currentItem.Key,
                Footprint = currentItem.Footprint or 2,
                Rotation = currentItem.Rotation or 0,
                Placed = data.Placed or {},
            })
        end)

        local remove = Instance.new("TextButton")
        remove.AnchorPoint = Vector2.new(1, 0)
        remove.Position = UDim2.new(1, -7, 0, 7)
        remove.Size = UDim2.fromOffset(92, 27)
        remove.BackgroundColor3 = Color3.fromRGB(151, 86, 91)
        remove.Text = "УБРАТЬ"
        remove.TextColor3 = Color3.new(1, 1, 1)
        remove.TextSize = 10
        remove.Font = Enum.Font.GothamBlack
        remove.Parent = row
        addCorner(remove, 7)
        remove.Activated:Connect(function()
            local updated = invokeBuild({ Action = "Remove", Key = currentItem.Key })
            if updated then renderBuild(updated) end
        end)
    end
end

local function openBuild()
    buildPanel.Visible = true
    local data = invokeBuild({ Action = "Get" })
    if data then renderBuild(data) end
end

buildButton.Activated:Connect(openBuild)
buildClose.Activated:Connect(function() buildPanel.Visible = false end)

local function invokeVisit(payload)
    local success, response = pcall(function()
        return visitRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось связаться со списком островов.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Переход не выполнен.")
        return nil
    end
    if response.Message then showNotice(response.Message) end
    return response
end

local function clearVisitList()
    for _, child in ipairs(visitList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local lastVisitResponse
local function renderVisitList(response)
    lastVisitResponse = response
    clearVisitList()
    local allIslands = response.Islands or {}
    local islands = {}
    for _, island in ipairs(allIslands) do
        if not showFavoriteIslandsOnly or island.IsFavoriteByMe then
            table.insert(islands, island)
        end
    end
    visitFilterButton.Text = showFavoriteIslandsOnly and "ИЗБРАННОЕ ★" or "ВСЕ ОСТРОВА"
    visitStatus.Text = showFavoriteIslandsOnly
        and ("В избранном: " .. #islands)
        or ("Доступно островов: " .. #allIslands)

    if response.Visiting then
        local returnCard = Instance.new("Frame")
        returnCard.LayoutOrder = 0
        returnCard.Size = UDim2.new(1, -8, 0, 64)
        returnCard.BackgroundColor3 = Color3.fromRGB(73, 111, 96)
        returnCard.BorderSizePixel = 0
        returnCard.Parent = visitList
        addCorner(returnCard, 10)
        local returnLabel = Instance.new("TextLabel")
        returnLabel.BackgroundTransparency = 1
        returnLabel.Position = UDim2.fromOffset(10, 5)
        returnLabel.Size = UDim2.new(1, -130, 1, -10)
        returnLabel.Text = "Ты в гостях\nВернись в своё гнездо"
        returnLabel.TextColor3 = Color3.new(1,1,1)
        returnLabel.TextSize = 12
        returnLabel.TextXAlignment = Enum.TextXAlignment.Left
        returnLabel.Font = Enum.Font.GothamBold
        returnLabel.Parent = returnCard
        local returnButton = Instance.new("TextButton")
        returnButton.AnchorPoint = Vector2.new(1, 0.5)
        returnButton.Position = UDim2.new(1, -8, 0.5, 0)
        returnButton.Size = UDim2.fromOffset(112, 38)
        returnButton.BackgroundColor3 = Color3.fromRGB(218, 174, 91)
        returnButton.Text = "МОЁ ГНЕЗДО"
        returnButton.TextColor3 = Color3.fromRGB(45, 48, 55)
        returnButton.TextSize = 10
        returnButton.Font = Enum.Font.GothamBlack
        returnButton.Parent = returnCard
        addCorner(returnButton, 8)
        returnButton.Activated:Connect(function()
            local result = invokeVisit({ Action = "Return" })
            if result then
                visitPanel.Visible = false
                visitButton.Text = "ПОСЕТИТЬ ОСТРОВЫ"
            end
        end)
    end

    if #islands == 0 then
        local empty = Instance.new("TextLabel")
        empty.LayoutOrder = 1
        empty.Size = UDim2.new(1, -8, 0, 54)
        empty.BackgroundTransparency = 1
        empty.Text = "Когда другие игроки появятся на сервере, их острова будут здесь."
        empty.TextColor3 = Color3.fromRGB(202, 210, 222)
        empty.TextSize = 12
        empty.TextWrapped = true
        empty.Font = Enum.Font.GothamMedium
        empty.Parent = visitList
    end

    for index, island in ipairs(islands) do
        local entry = island
        local card = Instance.new("Frame")
        card.LayoutOrder = index + 1
        card.Size = UDim2.new(1, -8, 0, 104)
        card.BackgroundColor3 = Color3.fromRGB(61, 70, 84)
        card.BorderSizePixel = 0
        card.Parent = visitList
        addCorner(card, 10)

        local info = Instance.new("TextLabel")
        info.BackgroundTransparency = 1
        info.Position = UDim2.fromOffset(10, 6)
        info.Size = UDim2.new(1, -104, 1, -12)
        info.Text = string.format("%s\nУровень %d · Гостей %d/%d\n★ %d отметок", entry.DisplayName, entry.Level or 1, entry.Visitors or 0, entry.Capacity or 8, entry.Likes or 0)
        info.TextColor3 = Color3.fromRGB(239, 241, 246)
        info.TextSize = 12
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.GothamMedium
        info.Parent = card

        local visit = Instance.new("TextButton")
        visit.AnchorPoint = Vector2.new(1, 0.5)
        visit.Position = UDim2.new(1, -8, 0, 8)
        visit.Size = UDim2.fromOffset(76, 28)
        visit.BackgroundColor3 = Color3.fromRGB(91, 139, 188)
        visit.Text = "В ГОСТИ"
        visit.TextColor3 = Color3.new(1, 1, 1)
        visit.TextSize = 9
        visit.Font = Enum.Font.GothamBlack
        visit.Parent = card
        addCorner(visit, 8)
        visit.Activated:Connect(function()
            visit.Active = false
            local result = invokeVisit({ Action = "Visit", PlotId = entry.PlotId })
            if result then
                visitPanel.Visible = false
                visitButton.Text = "ВЕРНУТЬСЯ ДОМОЙ"
            else
                visit.Active = true
            end
        end)

        local likeButton = Instance.new("TextButton")
        likeButton.Position = UDim2.new(1, -8, 0, 42)
        likeButton.Size = UDim2.fromOffset(76, 25)
        likeButton.BackgroundColor3 = entry.IsLikedByMe and Color3.fromRGB(190, 116, 102) or Color3.fromRGB(90, 100, 116)
        likeButton.Text = entry.IsLikedByMe and "★ НРАВИТСЯ" or "☆ ЛАЙК"
        likeButton.TextColor3 = Color3.new(1, 1, 1)
        likeButton.TextSize = 8
        likeButton.Font = Enum.Font.GothamBlack
        likeButton.Parent = card
        addCorner(likeButton, 7)
        likeButton.Activated:Connect(function()
            likeButton.Active = false
            local result = invokeVisit({ Action = "Like", UserId = entry.UserId })
            if result then
                entry.IsLikedByMe = result.Liked
                entry.Likes = result.Likes
                likeButton.Text = result.Liked and "★ НРАВИТСЯ" or "☆ ЛАЙК"
                likeButton.BackgroundColor3 = result.Liked and Color3.fromRGB(190, 116, 102) or Color3.fromRGB(90, 100, 116)
                info.Text = string.format("%s\nУровень %d · Гостей %d/%d\n★ %d отметок", entry.DisplayName, entry.Level or 1, entry.Visitors or 0, entry.Capacity or 8, entry.Likes or 0)
            end
            likeButton.Active = true
        end)

        local favoriteButton = Instance.new("TextButton")
        favoriteButton.Position = UDim2.new(1, -8, 0, 72)
        favoriteButton.Size = UDim2.fromOffset(76, 25)
        favoriteButton.BackgroundColor3 = entry.IsFavoriteByMe and Color3.fromRGB(184, 151, 82) or Color3.fromRGB(90, 100, 116)
        favoriteButton.Text = entry.IsFavoriteByMe and "★ СОХРАНЁН" or "☆ В ИЗБРАННОЕ"
        favoriteButton.TextColor3 = Color3.new(1, 1, 1)
        favoriteButton.TextSize = 7
        favoriteButton.Font = Enum.Font.GothamBlack
        favoriteButton.Parent = card
        addCorner(favoriteButton, 7)
        favoriteButton.Activated:Connect(function()
            favoriteButton.Active = false
            local result = invokeVisit({ Action = "Favorite", UserId = entry.UserId })
            if result then
                entry.IsFavoriteByMe = result.Favorite
                favoriteButton.Text = result.Favorite and "★ СОХРАНЁН" or "☆ В ИЗБРАННОЕ"
                favoriteButton.BackgroundColor3 = result.Favorite and Color3.fromRGB(184, 151, 82) or Color3.fromRGB(90, 100, 116)
                if showFavoriteIslandsOnly and not result.Favorite then
                    renderVisitList(lastVisitResponse)
                end
            end
            favoriteButton.Active = true
        end)
    end
end

visitFilterButton.Activated:Connect(function()
    showFavoriteIslandsOnly = not showFavoriteIslandsOnly
    if lastVisitResponse then renderVisitList(lastVisitResponse) end
end)

local function openVisitPanel()
    local response = invokeVisit({ Action = "List" })
    if response then
        renderVisitList(response)
        visitPanel.Visible = true
    end
end

visitButton.Activated:Connect(function()
    if visitButton.Text == "ВЕРНУТЬСЯ ДОМОЙ" then
        local result = invokeVisit({ Action = "Return" })
        if result then visitButton.Text = "ПОСЕТИТЬ ОСТРОВЫ" end
    else
        openVisitPanel()
    end
end)
visitClose.Activated:Connect(function() visitPanel.Visible = false end)

local function invokeContest(payload)
    local success, response = pcall(function()
        return contestRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось загрузить конкурс островов.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Действие конкурса не выполнено.")
        return nil
    end
    if response.Message then showNotice(response.Message) end
    return response
end

local contestData
local selectedContestCategory = "Cozy"
local function clearContestList()
    for _, child in ipairs(contestList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local function addContestLabel(text, order, height, color)
    local label = Instance.new("TextLabel")
    label.LayoutOrder = order
    label.Size = UDim2.new(1, -8, 0, height or 28)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(226, 231, 241)
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.Parent = contestList
    return label
end

local function renderContest()
    if not contestData then return end
    clearContestList()
    for _, child in ipairs(contestTabs:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local category
    for _, item in ipairs(contestData.Categories or {}) do
        if item.Id == selectedContestCategory then category = item end
    end
    if not category then
        category = (contestData.Categories or {})[1]
        if not category then return end
        selectedContestCategory = category.Id
    end

    for index, item in ipairs(contestData.Categories or {}) do
        local categoryItem = item
        local tab = Instance.new("TextButton")
        tab.LayoutOrder = index
        tab.Size = UDim2.new(1/3, -5, 1, 0)
        tab.BackgroundColor3 = categoryItem.Id == selectedContestCategory and Color3.fromRGB(155, 112, 62) or Color3.fromRGB(75, 83, 103)
        tab.Text = categoryItem.Name
        tab.TextColor3 = Color3.new(1, 1, 1)
        tab.TextSize = 10
        tab.Font = Enum.Font.GothamBlack
        tab.Parent = contestTabs
        addCorner(tab, 8)
        tab.Activated:Connect(function()
            selectedContestCategory = categoryItem.Id
            renderContest()
        end)
    end

    local testNote = contestData.IsLocalTest and "Локальный тест" or "Общая таблица"
    contestWeek.Text = "Неделя " .. tostring(contestData.Week or "—") .. " · " .. testNote
    addContestLabel(category.Description, 1, 34, Color3.fromRGB(235, 213, 173))
    addContestLabel("ЛУЧШИЕ ОСТРОВА НЕДЕЛИ", 2, 24, Color3.fromRGB(255, 220, 151))

    local standings = category.Standings or {}
    if #standings == 0 then
        addContestLabel("Пока нет голосов. Стань первым участником!", 3, 42)
    else
        for index, entry in ipairs(standings) do
            local medal = index == 1 and "🥇" or (index == 2 and "🥈" or (index == 3 and "🥉" or tostring(index) .. "."))
            addContestLabel(string.format("%s  %s  —  %d голосов", medal, entry.DisplayName, entry.Votes or 0), index + 2, 28)
        end
    end

    local nomineeOrder = #standings + 4
    addContestLabel("ОСТРОВА ЭТОГО СЕРВЕРА", nomineeOrder, 24, Color3.fromRGB(255, 220, 151))
    local nominees = contestData.Nominees or {}
    if #nominees == 0 then
        addContestLabel("Другие игроки появятся здесь, когда присоединятся к серверу.", nomineeOrder + 1, 44)
    else
        for index, nominee in ipairs(nominees) do
            local nomineeEntry = nominee
            local row = Instance.new("Frame")
            row.LayoutOrder = nomineeOrder + index
            row.Size = UDim2.new(1, -8, 0, 54)
            row.BackgroundColor3 = Color3.fromRGB(62, 70, 88)
            row.BorderSizePixel = 0
            row.Parent = contestList
            addCorner(row, 9)

            local name = Instance.new("TextLabel")
            name.BackgroundTransparency = 1
            name.Position = UDim2.fromOffset(10, 5)
            name.Size = UDim2.new(1, -120, 1, -10)
            name.Text = nomineeEntry.DisplayName .. " · ур. " .. tostring(nomineeEntry.Level or 1)
            name.TextColor3 = Color3.fromRGB(240, 242, 248)
            name.TextSize = 11
            name.TextWrapped = true
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Font = Enum.Font.GothamMedium
            name.Parent = row

            local vote = Instance.new("TextButton")
            vote.AnchorPoint = Vector2.new(1, 0.5)
            vote.Position = UDim2.new(1, -7, 0.5, 0)
            vote.Size = UDim2.fromOffset(104, 36)
            vote.BackgroundColor3 = category.HasVoted and Color3.fromRGB(83, 91, 104) or Color3.fromRGB(93, 142, 112)
            vote.Text = category.HasVoted and "ГОЛОС ОТДАН" or "ГОЛОСОВАТЬ"
            vote.TextColor3 = Color3.new(1, 1, 1)
            vote.TextSize = 9
            vote.Font = Enum.Font.GothamBlack
            vote.Active = not category.HasVoted
            vote.Parent = row
            addCorner(vote, 8)
            vote.Activated:Connect(function()
                if category.HasVoted then return end
                vote.Active = false
                local result = invokeContest({
                    Action = "Vote",
                    Category = selectedContestCategory,
                    UserId = nomineeEntry.UserId,
                })
                if result then
                    local refreshed = invokeContest({ Action = "List" })
                    if refreshed then
                        contestData = refreshed
                        renderContest()
                    end
                else
                    vote.Active = true
                end
            end)
        end
    end
end

local function openContestPanel()
    local response = invokeContest({ Action = "List" })
    if response then
        contestData = response
        contestPanel.Visible = true
        renderContest()
    end
end

contestButton.Activated:Connect(openContestPanel)
contestClose.Activated:Connect(function() contestPanel.Visible = false end)

local activeDecorDrag = nil
local dragPreview = nil
local dragRotation = 0
local function getOwnedPlotGrass()
    local world = Workspace:FindFirstChild("NestRaidersWorld")
    local island = world and world:FindFirstChild("StarterIsland")
    local plots = island and island:FindFirstChild("PlayerPlots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserId") == player.UserId then
            return plot:FindFirstChild("PlotGrass")
        end
    end
    return nil
end

local function stopDecorDrag(reopenPanel)
    activeDecorDrag = nil
    dragRotation = 0
    if dragPreview then dragPreview:Destroy(); dragPreview = nil end
    if dragHint then dragHint.Visible = false end
    if dragRotateButton then dragRotateButton.Visible = false end
    if dragCancelButton then dragCancelButton.Visible = false end
    if reopenPanel then decorPanel.Visible = true end
end

local function startDecorDrag(slot, item)
    stopDecorDrag()
    local grass = getOwnedPlotGrass()
    if not grass then
        showNotice("Не удалось найти твоё гнездо.")
        return
    end
    activeDecorDrag = { Slot = slot, Item = item, Grass = grass }
    dragRotation = item.Rotation or 0
    decorPanel.Visible = false

    dragPreview = Instance.new("Part")
    dragPreview.Name = "NestDecorPlacementPreview"
    dragPreview.Size = Vector3.new(2.2, 0.25, 2.2)
    dragPreview.Anchored = true
    dragPreview.CanCollide = false
    dragPreview.CanTouch = false
    dragPreview.CanQuery = false
    dragPreview.Material = Enum.Material.Neon
    dragPreview.Color = Color3.fromRGB(105, 238, 176)
    dragPreview.Transparency = 0.38
    dragPreview.Parent = Workspace

    if dragHint then
        dragHint.Text = "Выбери место на своём острове · R — поворот · Esc — отмена"
        dragHint.Visible = true
    end
    if dragRotateButton then dragRotateButton.Visible = true end
    if dragCancelButton then dragCancelButton.Visible = true end
    showNotice("Режим размещения: нажми на остров, чтобы переместить украшение.")
end

local function getDecorPlacementFromScreen(screenPosition)
    if not activeDecorDrag or not activeDecorDrag.Grass then return nil end
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { activeDecorDrag.Grass }
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if not result then return nil end

    local center = activeDecorDrag.Grass.Position
    local x = math.clamp(math.floor((result.Position.X - center.X) / 2 + 0.5) * 2, -14, 14)
    local z = math.clamp(math.floor((result.Position.Z - center.Z) / 2 + 0.5) * 2, -14, 14)
    return {
        X = x,
        Z = z,
        WorldPosition = Vector3.new(center.X + x, activeDecorDrag.Grass.Position.Y + activeDecorDrag.Grass.Size.Y / 2 + 0.2, center.Z + z),
    }
end

local function updateDecorPreview(screenPosition)
    if not activeDecorDrag or not dragPreview then return nil end
    local placement = getDecorPlacementFromScreen(screenPosition)
    if placement then
        dragPreview.CFrame = CFrame.new(placement.WorldPosition) * CFrame.Angles(0, math.rad(dragRotation), 0)
        dragPreview.Transparency = 0.38
        return placement
    end
    dragPreview.Transparency = 0.78
    return nil
end

local function confirmDecorDrag(screenPosition)
    if not activeDecorDrag then return end
    local placement = getDecorPlacementFromScreen(screenPosition)
    if not placement then
        showNotice("Выбери поверхность своего острова.")
        return
    end
    local drag = activeDecorDrag
    local updated = invokeDecor({
        Action = "Move",
        Slot = drag.Slot,
        X = placement.X,
        Z = placement.Z,
        Rotation = dragRotation,
    })
    if updated then
        stopDecorDrag(true)
        renderDecor(updated)
    end
end

local function openDecor()
    decorPanel.Visible = true
    local data = invokeDecor({ Action = "Get" })
    if data then renderDecor(data) end
end

decorButton.Activated:Connect(openDecor)
decorClose.Activated:Connect(function() stopDecorDrag(false); decorPanel.Visible = false end)

UserInputService.InputChanged:Connect(function(input)
    if not activeDecorDrag then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDecorPreview(UserInputService:GetMouseLocation())
    elseif input.UserInputType == Enum.UserInputType.Touch then
        updateDecorPreview(input.Position)
    end
end)

dragRotateButton.Activated:Connect(function()
    if not activeDecorDrag then return end
    dragRotation = (dragRotation + 15) % 360
end)

dragCancelButton.Activated:Connect(function()
    stopDecorDrag(true)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not activeDecorDrag then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        stopDecorDrag(true)
        return
    end
    if input.KeyCode == Enum.KeyCode.R then
        dragRotation = (dragRotation + 15) % 360
        return
    end
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        confirmDecorDrag(UserInputService:GetMouseLocation())
    elseif input.UserInputType == Enum.UserInputType.Touch then
        confirmDecorDrag(input.Position)
    end
end)

RunService.RenderStepped:Connect(function()
    if activeDecorDrag then
        updateDecorPreview(UserInputService:GetMouseLocation())
    end
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
        card.Size = UDim2.new(1, -8, 0, 210)
        card.BackgroundColor3 = Color3.fromRGB(49, 66, 83)
        card.BorderSizePixel = 0
        card.Parent = displayList
        addCorner(card, 10)

        local info = Instance.new("TextLabel")
        info.BackgroundTransparency = 1
        info.Position = UDim2.fromOffset(10, 7)
        info.Size = UDim2.new(1, -160, 1, -14)
        info.Text = entry.Empty and ("Витрина №" .. entry.Slot .. "\nСвободное место") or string.format("Витрина №%d · %s\n%s · +%d / 10 сек.\nХарактер: %s\nЛюбит: %s\nИгрушка: %s\n♥ %d%%  ·  🍖 %d%%  ·  ⚡ %d%%\n%s", entry.Slot, entry.Name, entry.Rarity or "Обычный", entry.Income or 0, entry.Personality or "Без характера", entry.FavoriteFood or "Обычный корм", entry.ToyName or "нет", entry.Mood or 50, entry.Hunger or 100, entry.Energy or 100, entry.IsSleeping and "Спит…" or "Бодрствует")
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
            local function addCareAction(label, interaction, xOffset, yOffset, color, width)
                local interact = Instance.new("TextButton")
                interact.AnchorPoint = Vector2.new(1, 0)
                interact.Position = UDim2.new(1, xOffset, 0, yOffset)
                interact.Size = UDim2.fromOffset(width or 68, 27)
                interact.BackgroundColor3 = color
                interact.Text = label
                interact.TextColor3 = Color3.new(1, 1, 1)
                interact.TextSize = 9
                interact.Font = Enum.Font.GothamBlack
                interact.Parent = card
                addCorner(interact, 8)
                interact.Activated:Connect(function()
                    interact.Active = false
                    local updated = invokeDisplay({
                        Action = "Interact",
                        Interaction = interaction,
                        InstanceId = entry.InstanceId,
                    })
                    if updated then renderDisplay(updated) else interact.Active = true end
                end)
            end
            addCareAction("ЛАСКА", "Pet", -80, 44, Color3.fromRGB(89, 143, 112))
            addCareAction("ИГРА", "Play", -8, 44, Color3.fromRGB(91, 126, 174))
            addCareAction("КОРМ 10🪙", "Feed", -80, 77, Color3.fromRGB(183, 139, 70))
            addCareAction("СОН", "Sleep", -8, 77, Color3.fromRGB(91, 104, 153))
            addCareAction("ЛАКОМСТВО 15🪙", "Treat", -8, 110, Color3.fromRGB(180, 115, 65), 140)
            addCareAction("ИГРАТЬ С ИГРУШКОЙ", "ToyPlay", -8, 143, Color3.fromRGB(91, 133, 173), 140)

            local toyChoices = {
                { Id = "MeadowBall", Label = "МЯЧ 25🪙", X = -152, Color = Color3.fromRGB(204, 111, 83) },
                { Id = "CozyPlush", Label = "ПЛЮШ 40🪙", X = -80, Color = Color3.fromRGB(139, 108, 185) },
                { Id = "WindSpinner", Label = "ВЕРТУШКА 35🪙", X = -8, Color = Color3.fromRGB(74, 159, 153) },
            }
            for _, toy in ipairs(toyChoices) do
                local toyButton = Instance.new("TextButton")
                toyButton.AnchorPoint = Vector2.new(1, 0)
                toyButton.Position = UDim2.new(1, toy.X, 0, 176)
                toyButton.Size = UDim2.fromOffset(68, 27)
                toyButton.BackgroundColor3 = toy.Color
                toyButton.Text = toy.Label
                toyButton.TextColor3 = Color3.new(1, 1, 1)
                toyButton.TextSize = 8
                toyButton.Font = Enum.Font.GothamBlack
                toyButton.Parent = card
                addCorner(toyButton, 8)
                toyButton.Activated:Connect(function()
                    toyButton.Active = false
                    local updated = invokeDisplay({
                        Action = "Interact",
                        Interaction = "EquipToy",
                        InstanceId = entry.InstanceId,
                        ToyId = toy.Id,
                    })
                    if updated then renderDisplay(updated) else toyButton.Active = true end
                end)
            end
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
