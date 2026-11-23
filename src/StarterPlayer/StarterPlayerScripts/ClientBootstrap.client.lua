local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Stable, bounded camera zoom: prevent accidental infinite zoom in/out.
player.CameraMode = Enum.CameraMode.Classic
player.CameraMinZoomDistance = 7
player.CameraMaxZoomDistance = 24

-- Keep a visible boot diagnostic instead of leaving players in an empty world.
local bootGui = Instance.new("ScreenGui")
bootGui.Name = "NestRaidersBootDiagnostic"
bootGui.ResetOnSpawn = false
bootGui.DisplayOrder = 1000
bootGui.Parent = playerGui

local bootCard = Instance.new("Frame")
bootCard.AnchorPoint = Vector2.new(0.5, 0.5)
bootCard.Position = UDim2.fromScale(0.5, 0.5)
bootCard.Size = UDim2.fromOffset(420, 132)
bootCard.BackgroundColor3 = Color3.fromRGB(27, 39, 48)
bootCard.BorderSizePixel = 0
bootCard.Parent = bootGui
local bootCorner = Instance.new("UICorner")
bootCorner.CornerRadius = UDim.new(0, 14)
bootCorner.Parent = bootCard
local bootText = Instance.new("TextLabel")
bootText.BackgroundTransparency = 1
bootText.Position = UDim2.fromOffset(18, 14)
bootText.Size = UDim2.new(1, -36, 1, -28)
bootText.Font = Enum.Font.GothamBold
bootText.TextSize = 16
bootText.TextWrapped = true
bootText.TextColor3 = Color3.fromRGB(245, 242, 226)
bootText.Text = "NEST RAIDERS\nПодключаем игровые системы..."
bootText.Parent = bootCard

local remotes = ReplicatedStorage:WaitForChild("NestRaidersRemotes", 20)
if not remotes then
    bootText.Text = "NEST RAIDERS\nСервер не запустил игровые службы. Открой View → Output в Roblox Studio и проверь красные ошибки."
    warn("[NEST RAIDERS] Boot failed: NestRaidersRemotes was not created by the server.")
    return
end

local function waitRemote(name)
    local remote = remotes:WaitForChild(name, 20)
    if not remote then
        bootText.Text = "NEST RAIDERS\nНе создана серверная функция: " .. name .. ". Проверь ошибки в Output."
        warn("[NEST RAIDERS] Boot failed: missing RemoteFunction " .. name)
    end
    return remote
end

local inventoryRemote = waitRemote("CompanionInventory")
local shopRemote = waitRemote("EggShop")
local collectionRemote = waitRemote("CollectionBook")
local nestRemote = waitRemote("NestUpgrade")
local displayRemote = waitRemote("DisplayPets")
local decorRemote = waitRemote("NestDecor")
local buildRemote = waitRemote("NestBuild")
local visitRemote = waitRemote("IslandVisit")
local contestRemote = waitRemote("IslandContest")
local publicProfileRemote = waitRemote("PublicProfile")

if not (inventoryRemote and shopRemote and collectionRemote and nestRemote and displayRemote
    and decorRemote and buildRemote and visitRemote and contestRemote and publicProfileRemote) then
    return
end

bootGui:Destroy()

local gui = Instance.new("ScreenGui")
gui.Name = "NestRaidersHUD"
gui.ResetOnSpawn = false
gui:SetAttribute("ClientReady", false)
gui.Parent = playerGui

-- Scale the complete HUD to the available viewport, especially on phones.
local hudScale = Instance.new("UIScale")
hudScale.Name = "ResponsiveHudScale"
hudScale.Parent = gui
local camera = Workspace.CurrentCamera
local function updateHudScale()
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local scale = math.min(viewport.X / 900, viewport.Y / 620, 1)
    hudScale.Scale = math.clamp(scale, 0.72, 1)
end
updateHudScale()
if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateHudScale)
end

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

local hallButton = Instance.new("TextButton")
hallButton.Name = "IslandHallOfFameButton"
hallButton.Position = UDim2.fromOffset(18, 642)
hallButton.Size = UDim2.fromOffset(250, 42)
hallButton.BackgroundColor3 = Color3.fromRGB(90, 101, 145)
hallButton.Text = "ЗАЛ СЛАВЫ"
hallButton.TextColor3 = Color3.fromRGB(255, 245, 220)
hallButton.TextSize = 13
hallButton.Font = Enum.Font.GothamBlack
hallButton.Parent = gui
addCorner(hallButton, 12)
addStroke(hallButton, Color3.fromRGB(171, 184, 230), 1.5)

local profileButton = Instance.new("TextButton")
profileButton.Name = "MyPublicProfileButton"
profileButton.Position = UDim2.fromOffset(18, 692)
profileButton.Size = UDim2.fromOffset(250, 42)
profileButton.BackgroundColor3 = Color3.fromRGB(91, 132, 119)
profileButton.Text = "МОЙ ПРОФИЛЬ"
profileButton.TextColor3 = Color3.fromRGB(255, 255, 245)
profileButton.TextSize = 13
profileButton.Font = Enum.Font.GothamBlack
profileButton.Parent = gui
addCorner(profileButton, 12)
addStroke(profileButton, Color3.fromRGB(160, 220, 192), 1.5)

-- Compact responsive navigation: keep every feature reachable on desktop and mobile.
-- Previously the last buttons were fixed at Y=692 and disappeared off small screens.
local menuButtons = {
    inventoryButton, shopButton, collectionButton, nestButton, displayButton,
    decorButton, buildButton, visitButton, contestButton, hallButton, profileButton,
}
local navToggle = Instance.new("TextButton")
navToggle.Name = "MenuToggle"
navToggle.Position = UDim2.fromOffset(12, 162)
navToggle.Size = UDim2.fromOffset(184, 44)
navToggle.BackgroundColor3 = Color3.fromRGB(35, 61, 66)
navToggle.TextColor3 = Color3.fromRGB(255, 236, 183)
navToggle.TextSize = 14
navToggle.Font = Enum.Font.GothamBlack
navToggle.Text = "МЕНЮ"
navToggle.Parent = gui
addCorner(navToggle, 12)

local navScroll = Instance.new("ScrollingFrame")
navScroll.Name = "FeatureMenu"
navScroll.Position = UDim2.fromOffset(12, 212)
navScroll.Size = UDim2.fromOffset(250, 350)
navScroll.BackgroundColor3 = Color3.fromRGB(28, 45, 55)
navScroll.BackgroundTransparency = 0.12
navScroll.BorderSizePixel = 0
navScroll.ScrollBarThickness = 5
navScroll.ScrollingDirection = Enum.ScrollingDirection.Y
navScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
navScroll.Visible = false
navScroll.Parent = gui
addCorner(navScroll, 12)
local navPadding = Instance.new("UIPadding")
navPadding.PaddingTop = UDim.new(0, 8)
navPadding.PaddingBottom = UDim.new(0, 8)
navPadding.PaddingLeft = UDim.new(0, 8)
navPadding.PaddingRight = UDim.new(0, 8)
navPadding.Parent = navScroll
local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 7)
navLayout.Parent = navScroll

for index, button in ipairs(menuButtons) do
    button.Parent = navScroll
    button.LayoutOrder = index
    button.Position = UDim2.new()
    button.Size = UDim2.new(1, -2, 0, 42)
    -- Close the menu after choosing any feature; existing Activated handlers still run.
    button.Activated:Connect(function()
        navScroll.Visible = false
        navToggle.Text = "МЕНЮ"
    end)
end

navToggle.Activated:Connect(function()
    navScroll.Visible = not navScroll.Visible
    navToggle.Text = navScroll.Visible and "ЗАКРЫТЬ" or "МЕНЮ"
end)

local function resizeNavigation()
    local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(900, 650)
    local narrow = viewport.X < 600
    panel.Position = narrow and UDim2.fromOffset(12, 8) or UDim2.fromOffset(18, 18)
    panel.Size = narrow and UDim2.fromOffset(206, 112) or UDim2.fromOffset(250, 132)
    title.TextSize = narrow and 15 or 18
    stats.TextSize = narrow and 12 or 15
    stats.Position = narrow and UDim2.fromOffset(12, 32) or UDim2.fromOffset(14, 36)
    navToggle.Position = UDim2.fromOffset(narrow and 12 or 18, narrow and 126 or 162)
    navToggle.Size = UDim2.fromOffset(narrow and 206 or 250, 42)
    navScroll.Position = UDim2.fromOffset(narrow and 12 or 18, narrow and 172 or 210)
    navScroll.Size = UDim2.fromOffset(narrow and 206 or 250, math.max(110, math.min(460, viewport.Y - (narrow and 190 or 228))))
end
resizeNavigation()
if Workspace.CurrentCamera then
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resizeNavigation)
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(resizeNavigation)

local profilePanel = Instance.new("Frame")
profilePanel.Name = "PublicProfilePanel"
profilePanel.AnchorPoint = Vector2.new(0.5, 0.5)
profilePanel.Position = UDim2.fromScale(0.5, 0.5)
profilePanel.Size = UDim2.new(0.9, 0, 0.78, 0)
profilePanel.BackgroundColor3 = Color3.fromRGB(38, 51, 62)
profilePanel.BorderSizePixel = 0
profilePanel.Visible = false
profilePanel.Parent = gui
addCorner(profilePanel, 18)
addStroke(profilePanel, Color3.fromRGB(150, 213, 183), 2)
local profileSize = Instance.new("UISizeConstraint")
profileSize.MinSize = Vector2.new(290, 340)
profileSize.MaxSize = Vector2.new(470, 560)
profileSize.Parent = profilePanel

local profileTitle = Instance.new("TextLabel")
profileTitle.BackgroundTransparency = 1
profileTitle.Position = UDim2.fromOffset(18, 12)
profileTitle.Size = UDim2.new(1, -76, 0, 30)
profileTitle.Font = Enum.Font.GothamBlack
profileTitle.Text = "ПРОФИЛЬ ИГРОКА"
profileTitle.TextColor3 = Color3.fromRGB(191, 239, 210)
profileTitle.TextSize = 16
profileTitle.TextXAlignment = Enum.TextXAlignment.Left
profileTitle.Parent = profilePanel

local profileClose = Instance.new("TextButton")
profileClose.AnchorPoint = Vector2.new(1, 0)
profileClose.Position = UDim2.new(1, -12, 0, 10)
profileClose.Size = UDim2.fromOffset(38, 34)
profileClose.BackgroundColor3 = Color3.fromRGB(83, 91, 108)
profileClose.Text = "✕"
profileClose.TextColor3 = Color3.new(1, 1, 1)
profileClose.TextSize = 18
profileClose.Font = Enum.Font.GothamBold
profileClose.Parent = profilePanel
addCorner(profileClose, 10)

local profileList = Instance.new("ScrollingFrame")
profileList.Position = UDim2.fromOffset(12, 52)
profileList.Size = UDim2.new(1, -24, 1, -64)
profileList.BackgroundTransparency = 1
profileList.BorderSizePixel = 0
profileList.ScrollBarThickness = 6
profileList.AutomaticCanvasSize = Enum.AutomaticSize.Y
profileList.Parent = profilePanel
local profileLayout = Instance.new("UIListLayout")
profileLayout.Padding = UDim.new(0, 7)
profileLayout.SortOrder = Enum.SortOrder.LayoutOrder
profileLayout.Parent = profileList

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

-- Forward declarations keep early button callbacks bound to the real editor state.
local buildHint, buildRotateButton, buildCancelButton, buildConfirmButton
local activeBuildPlacement = nil
local buildRotation = 0
local stopBuildPlacement

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
buildRotateButton.AnchorPoint = Vector2.new(0.5, 1)
buildRotateButton.Position = UDim2.new(0.5, 0, 1, -18)
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

buildConfirmButton = Instance.new("TextButton")
buildConfirmButton.Name = "BuildPlacementConfirm"
buildConfirmButton.AnchorPoint = Vector2.new(1, 1)
buildConfirmButton.Position = UDim2.new(1, -18, 1, -18)
buildConfirmButton.Size = UDim2.fromOffset(112, 34)
buildConfirmButton.BackgroundColor3 = Color3.fromRGB(62, 145, 112)
buildConfirmButton.Text = "ПОСТАВИТЬ ✓"
buildConfirmButton.TextColor3 = Color3.new(1, 1, 1)
buildConfirmButton.TextSize = 10
buildConfirmButton.Font = Enum.Font.GothamBlack
buildConfirmButton.Visible = false
buildConfirmButton.Parent = gui
addCorner(buildConfirmButton, 8)

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

local geneticsHint = Instance.new("TextLabel")
geneticsHint.Name = "GeneticOdds"
geneticsHint.BackgroundTransparency = 1
geneticsHint.Position = UDim2.fromOffset(18, 68)
geneticsHint.Size = UDim2.new(1, -36, 0, 24)
geneticsHint.Font = Enum.Font.GothamMedium
geneticsHint.Text = "ГЕНЕТИКА · Естеств. 72% · Изумруд 18% · Свет 8% · Призма 2%"
geneticsHint.TextColor3 = Color3.fromRGB(171, 205, 191)
geneticsHint.TextSize = 9
geneticsHint.TextXAlignment = Enum.TextXAlignment.Left
geneticsHint.TextWrapped = true
geneticsHint.Parent = inventoryPanel

local incubatorSummary = Instance.new("TextLabel")
incubatorSummary.Name = "IncubatorSummary"
incubatorSummary.BackgroundTransparency = 1
incubatorSummary.Position = UDim2.fromOffset(18, 94)
incubatorSummary.Size = UDim2.new(1, -36, 0, 32)
incubatorSummary.Font = Enum.Font.GothamMedium
incubatorSummary.Text = "ИНКУБАТОР · Яиц пока нет"
incubatorSummary.TextColor3 = Color3.fromRGB(255, 205, 137)
incubatorSummary.TextSize = 10
incubatorSummary.TextXAlignment = Enum.TextXAlignment.Left
incubatorSummary.TextWrapped = true
incubatorSummary.Parent = inventoryPanel

local list = Instance.new("ScrollingFrame")
list.Name = "CompanionList"
list.Position = UDim2.fromOffset(12, 130)
list.Size = UDim2.new(1, -24, 1, -144)
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

-- Keep panels mutually exclusive regardless of which gameplay action opens them.
-- Picker is the sole nested dialog and retains its companion display underneath.
local modalPanels = {
    shopPanel, nestPanel, displayPanel, buildPanel, visitPanel,
    profilePanel, contestPanel, decorPanel, pickerPanel, bookPanel, inventoryPanel,
}
local closingOtherPanels = false
local closeAllButton = Instance.new("TextButton")
closeAllButton.Name = "CloseAllWindows"
closeAllButton.AnchorPoint = Vector2.new(1, 0)
closeAllButton.Position = UDim2.new(1, -12, 0, 12)
closeAllButton.Size = UDim2.fromOffset(132, 40)
closeAllButton.BackgroundColor3 = Color3.fromRGB(143, 68, 68)
closeAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeAllButton.Font = Enum.Font.GothamBold
closeAllButton.TextSize = 13
closeAllButton.Text = "ЗАКРЫТЬ ВСЁ"
closeAllButton.ZIndex = 50
closeAllButton.Visible = false
closeAllButton.Parent = gui
addCorner(closeAllButton, 10)

local function updateCloseAllButton()
    local anyVisible = false
    for _, modal in ipairs(modalPanels) do
        if modal.Visible then
            anyVisible = true
            break
        end
    end
    closeAllButton.Visible = anyVisible
end

for _, modal in ipairs(modalPanels) do
    modal:GetPropertyChangedSignal("Visible"):Connect(function()
        if closingOtherPanels then return end
        closingOtherPanels = true
        if modal.Visible then
            navScroll.Visible = false
            navToggle.Text = "МЕНЮ"
            for _, other in ipairs(modalPanels) do
                if other ~= modal and not (modal == pickerPanel and other == displayPanel) then
                    other.Visible = false
                end
            end
        end
        closingOtherPanels = false
        updateCloseAllButton()
    end)
end

closeAllButton.Activated:Connect(function()
    closingOtherPanels = true
    for _, modal in ipairs(modalPanels) do modal.Visible = false end
    closingOtherPanels = false
    updateCloseAllButton()
end)

-- Escape closes ordinary panels. Placement editors keep their own Escape behavior.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.Escape then return end
    if buildHint.Visible or dragHint.Visible then return end
    if pickerPanel.Visible then
        pickerPanel.Visible = false
        return
    end
    if closeAllButton.Visible then
        closingOtherPanels = true
        for _, modal in ipairs(modalPanels) do modal.Visible = false end
        closingOtherPanels = false
        updateCloseAllButton()
    end
end)

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

local selectedBreedingId = nil
local selectedBreedingPartnerId = nil

local function renderInventory(data)
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") or child == emptyLabel then
            if child ~= emptyLabel then child:Destroy() end
        end
    end

    if not data then return end
    inventorySummary.Text = string.format("Активные питомцы: %d / %d", data.ActiveCount or 0, data.MaxActive or 3)
    local eggs = data.Eggs or {}
    local breedingEggs = {}
    local regularEggCount = 0
    for _, egg in ipairs(eggs) do
        if egg.Origin == "Breeding" then
            table.insert(breedingEggs, egg)
        else
            regularEggCount += 1
        end
    end
    if #breedingEggs > 0 then
        local nextEgg = breedingEggs[1]
        local remaining = math.max(0, nextEgg.ReadyIn or 0)
        local timeText = remaining > 0
            and string.format("%d:%02d", math.floor(remaining / 60), remaining % 60)
            or "ГОТОВО К ВЫЛУПЛЕНИЮ"
        incubatorSummary.Text = string.format("ИНКУБАТОР · %d яиц потомства · %s · %s",
            #breedingEggs, timeText, nextEgg.OffspringName or "Неизвестный вид")
        if nextEgg.GeneticTrait then
            incubatorSummary.Text ..= " · " .. nextEgg.GeneticTrait
        end
    else
        incubatorSummary.Text = string.format("ИНКУБАТОР · Обычных яиц: %d · Яиц потомства: 0", regularEggCount)
    end
    local companions = data.Companions or {}
    emptyLabel.Visible = #companions == 0

    for index, companion in ipairs(companions) do
        local card = Instance.new("Frame")
        card.Name = "CompanionCard"
        card.LayoutOrder = index
        card.Size = UDim2.new(1, -8, 0, 218)
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
        details.Size = UDim2.new(1, -130, 0, 72)
        details.Font = Enum.Font.GothamMedium
        local trait = companion.GeneticTrait or { Name = "Естественный" }
        local traitBonus = math.floor((tonumber(trait.IncomeBonus) or 0) * 100 + 0.5)
        details.Text = string.format("%s  ·  %s  ·  %s\n%s (%s) · +%d%% дохода\nОпыт %d/%d · +%d монет / 10 сек.",
            companion.Rarity or "Обычный",
            string.rep("★", companion.Stars or 1),
            companion.GrowthStage or "Малыш",
            trait.Name or "Естественный",
            trait.Rarity or "Обычный",
            traitBonus,
            companion.GrowthXP or 0,
            companion.GrowthXPToNext or 0,
            companion.Income or 0)
        if companion.Origin == "Breeding" then
            details.Text ..= "\nПотомство: " .. table.concat(companion.ParentNames or {}, " + ")
        end
        details.TextColor3 = Color3.fromRGB(187, 211, 203)
        details.TextSize = 12
        details.TextXAlignment = Enum.TextXAlignment.Left
        details.Parent = card

        local action = Instance.new("TextButton")
        action.AnchorPoint = Vector2.new(1, 0)
        action.Position = UDim2.new(1, -10, 0, 8)
        action.Size = UDim2.fromOffset(96, 34)
        action.BackgroundColor3 = companion.Equipped and Color3.fromRGB(115, 86, 65) or Color3.fromRGB(67, 139, 104)
        action.Text = companion.Equipped and "СНЯТЬ" or "ВЗЯТЬ"
        action.TextColor3 = Color3.fromRGB(255, 255, 245)
        action.TextSize = 13
        action.Font = Enum.Font.GothamBlack
        action.Parent = card
        addCorner(action, 9)

        local mergeButton = Instance.new("TextButton")
        mergeButton.Name = "MergeButton"
        mergeButton.Position = UDim2.fromOffset(12, 96)
        mergeButton.Size = UDim2.fromOffset(116, 27)
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

        local trainButton = Instance.new("TextButton")
        trainButton.Name = "TrainButton"
        trainButton.Position = UDim2.fromOffset(136, 96)
        trainButton.Size = UDim2.fromOffset(116, 27)
        trainButton.BackgroundColor3 = Color3.fromRGB(66, 137, 151)
        trainButton.Text = (companion.Level or 1) >= 10 and "МАКС. УРОВЕНЬ" or ("ТРЕНИРОВКА · " .. tostring(companion.TrainCost or 0) .. "мон.")
        trainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        trainButton.TextSize = 9
        trainButton.Font = Enum.Font.GothamBlack
        trainButton.Parent = card
        trainButton.Active = (companion.Level or 1) < 10
        addCorner(trainButton, 8)
        trainButton.Activated:Connect(function()
            if (companion.Level or 1) >= 10 then return end
            trainButton.Active = false
            trainButton.Text = "ТРЕНИРОВКА..."
            local updated = invokeInventory({
                Action = "Train",
                InstanceId = companion.InstanceId,
            })
            if updated then
                renderInventory(updated)
            else
                trainButton.Active = true
                trainButton.Text = "ТРЕНИРОВКА · " .. tostring(companion.TrainCost or 0) .. "мон."
            end
        end)

        if companion.Ability then
            local ability = companion.Ability
            local abilityButton = Instance.new("TextButton")
            abilityButton.Name = "AbilityButton"
            abilityButton.Position = UDim2.fromOffset(12, 128)
            abilityButton.Size = UDim2.new(1, -24, 0, 26)
            abilityButton.BackgroundColor3 = ability.Unlocked and (ability.ReadyIn or 0) <= 0
                and Color3.fromRGB(111, 133, 73) or Color3.fromRGB(75, 87, 96)
            abilityButton.TextColor3 = Color3.fromRGB(255, 255, 245)
            abilityButton.TextSize = 10
            abilityButton.Font = Enum.Font.GothamBlack
            if not ability.Unlocked then
                abilityButton.Text = (ability.Name or "СПОСОБНОСТЬ") .. " · УР. " .. tostring(ability.UnlockLevel or 7)
            elseif (ability.ReadyIn or 0) > 0 then
                abilityButton.Text = (ability.Name or "СПОСОБНОСТЬ") .. " · " .. tostring(ability.ReadyIn) .. " СЕК."
            else
                abilityButton.Text = "✦ " .. (ability.Name or "СПОСОБНОСТЬ") .. " · ИСПОЛЬЗОВАТЬ"
            end
            abilityButton.Active = ability.Unlocked == true and (ability.ReadyIn or 0) <= 0 and companion.Equipped == true
            abilityButton.Parent = card
            addCorner(abilityButton, 8)
            abilityButton.Activated:Connect(function()
                if not abilityButton.Active then return end
                abilityButton.Active = false
                abilityButton.Text = "АКТИВАЦИЯ..."
                local updated = invokeInventory({
                    Action = "UseAbility",
                    InstanceId = companion.InstanceId,
                })
                if updated then
                    renderInventory(updated)
                else
                    abilityButton.Active = true
                    abilityButton.Text = "✦ " .. (ability.Name or "СПОСОБНОСТЬ") .. " · ИСПОЛЬЗОВАТЬ"
                end
            end)
        end

        if (companion.Level or 1) >= 7 then
            local breedButton = Instance.new("TextButton")
            breedButton.Name = "BreedButton"
            breedButton.Position = UDim2.fromOffset(12, 160)
            breedButton.Size = UDim2.new(1, -24, 0, 26)
            breedButton.BackgroundColor3 = selectedBreedingId == companion.InstanceId
                and Color3.fromRGB(166, 104, 75) or Color3.fromRGB(111, 101, 151)
            breedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            breedButton.TextSize = 10
            breedButton.Font = Enum.Font.GothamBlack
            if (companion.BreedReadyIn or 0) > 0 then
                breedButton.Text = "РАЗВЕДЕНИЕ · " .. tostring(companion.BreedReadyIn) .. " СЕК."
                breedButton.Active = false
            elseif selectedBreedingPartnerId == companion.InstanceId then
                breedButton.Text = "ПОДТВЕРДИТЬ РАЗВЕДЕНИЕ"
            elseif selectedBreedingId == companion.InstanceId then
                breedButton.Text = "ВЫБРАН · ВЫБРАТЬ ДРУГОГО"
            else
                breedButton.Text = "♥ " .. (selectedBreedingId and "ВЫБРАТЬ В ПАРУ" or "ВЫБРАТЬ ДЛЯ РАЗВЕДЕНИЯ")
            end
            breedButton.Parent = card
            addCorner(breedButton, 8)
            breedButton.Activated:Connect(function()
                if (companion.BreedReadyIn or 0) > 0 then return end
                if not selectedBreedingId then
                    selectedBreedingId = companion.InstanceId
                    selectedBreedingPartnerId = nil
                    renderInventory(data)
                    return
                end
                if selectedBreedingId == companion.InstanceId then
                    selectedBreedingId = nil
                    selectedBreedingPartnerId = nil
                    renderInventory(data)
                    return
                end
                if selectedBreedingPartnerId ~= companion.InstanceId then
                    selectedBreedingPartnerId = companion.InstanceId
                    renderInventory(data)
                    return
                end
                breedButton.Active = false
                breedButton.Text = "РАЗВЕДЕНИЕ..."
                local updated = invokeInventory({
                    Action = "Breed",
                    InstanceId = selectedBreedingId,
                    PartnerInstanceId = selectedBreedingPartnerId,
                })
                if updated then
                    selectedBreedingId = nil
                    selectedBreedingPartnerId = nil
                    renderInventory(updated)
                else
                    breedButton.Active = true
                    breedButton.Text = "ПОДТВЕРДИТЬ РАЗВЕДЕНИЕ"
                end
            end)
        end

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
        buy.Text = "КУПИТЬ · " .. tostring(item.Price) .. " мон."
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
        nestUpgrade.Text = "УЛУЧШИТЬ · " .. tostring(data.NextCost or 0) .. " мон."
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
        buy.Text = "КУПИТЬ " .. tostring(item.Cost) .. "мон."
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
local buildPreview = nil
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

stopBuildPlacement = function(reopen)
    activeBuildPlacement = nil
    buildScreenPosition = nil
    if buildPreview then buildPreview:Destroy(); buildPreview = nil end
    for _, connection in ipairs(buildInputConnections) do connection:Disconnect() end
    table.clear(buildInputConnections)
    buildHint.Visible = false
    buildRotateButton.Visible = false
    buildCancelButton.Visible = false
    buildConfirmButton.Visible = false
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

buildConfirmButton.Activated:Connect(function()
    if activeBuildPlacement and buildScreenPosition then
        confirmBuildPlacement(buildScreenPosition)
    end
end)

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
    buildScreenPosition = UserInputService.MouseEnabled and UserInputService:GetMouseLocation()
        or Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y / 2)
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
    updateBuildPreview(buildScreenPosition)

    buildHint.Text = "Выбери точку на острове · зелёный = можно · красный = занято"
    buildHint.Visible = true
    buildRotateButton.Visible = true
    buildCancelButton.Visible = true
    buildConfirmButton.Visible = true

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
            -- Touch sets the desired position; confirmation is always explicit.
            buildScreenPosition = input.Position
            updateBuildPreview(buildScreenPosition)
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
        buy.Text = "КУПИТЬ " .. tostring(item.Cost) .. "мон."
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

local function invokePublicProfile(payload)
    local success, response = pcall(function()
        return publicProfileRemote:InvokeServer(payload)
    end)
    if not success or type(response) ~= "table" then
        showNotice("Не удалось загрузить профиль.")
        return nil
    end
    if not response.Ok then
        showNotice(response.Message or "Профиль недоступен.")
        return nil
    end
    return response.Data
end

local function clearProfileList()
    for _, child in ipairs(profileList:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
end

local function addProfileLine(textValue, order, height, color, size)
    local label = Instance.new("TextLabel")
    label.LayoutOrder = order
    label.Size = UDim2.new(1, -8, 0, height or 28)
    label.BackgroundTransparency = 1
    label.Text = textValue
    label.TextColor3 = color or Color3.fromRGB(230, 237, 239)
    label.TextSize = size or 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.Parent = profileList
    return label
end

local function renderPublicProfile(data, isOwnProfile)
    clearProfileList()
    profileTitle.Text = data.DisplayName .. (isOwnProfile and " · МОЙ ПРОФИЛЬ" or "")
    local order = 1
    addProfileLine("@" .. tostring(data.Username) .. "   ·   Уровень " .. tostring(data.Level), order, 28, Color3.fromRGB(255, 222, 153), 14)
    order += 1
    addProfileLine(string.format("Питомцы: %d   ·   Виды: %d/%d (%d%%)", data.CompanionCount, data.UniqueCompanions, data.TotalSpecies, data.CollectionPercent), order, 30)
    order += 1
    addProfileLine(string.format("Гнездо: %d уровень   ·   Лайки: %d   ·   Кубки: %d", data.NestLevel, data.LikesReceived, data.TrophyCount), order, 30)
    order += 1
    addProfileLine("ДОСТИЖЕНИЯ", order, 24, Color3.fromRGB(174, 225, 195), 13)
    order += 1
    for _, achievement in ipairs(data.Achievements or {}) do
        local state = achievement.Unlocked and "✓" or "🔒"
        local color = achievement.Unlocked and Color3.fromRGB(255, 224, 151) or Color3.fromRGB(142, 153, 166)
        addProfileLine(state .. "  " .. achievement.Icon .. "  " .. achievement.Name .. " — " .. achievement.Description, order, 38, color, 11)
        order += 1
    end

    if isOwnProfile then
        addProfileLine("ТИТУЛ НАД ПЕРСОНАЖЕМ", order, 25, Color3.fromRGB(174, 225, 195), 13)
        order += 1
        local unequip = Instance.new("TextButton")
        unequip.LayoutOrder = order
        unequip.Size = UDim2.new(1, -8, 0, 34)
        unequip.BackgroundColor3 = data.EquippedTitle == "" and Color3.fromRGB(78, 116, 97) or Color3.fromRGB(75, 86, 99)
        unequip.Text = data.EquippedTitle == "" and "БЕЗ ТИТУЛА · ВЫБРАНО" or "СНЯТЬ ТИТУЛ"
        unequip.TextColor3 = Color3.new(1, 1, 1)
        unequip.TextSize = 10
        unequip.Font = Enum.Font.GothamBlack
        unequip.Parent = profileList
        addCorner(unequip, 8)
        unequip.Activated:Connect(function()
            local success, result = pcall(function()
                return publicProfileRemote:InvokeServer({ Action = "EquipTitle", TitleId = "" })
            end)
            if success and result and result.Ok then
                data.EquippedTitle = ""
                showNotice(result.Message or "Титул снят.")
                renderPublicProfile(data, true)
            else
                showNotice(result and result.Message or "Не удалось снять титул.")
            end
        end)
        order += 1

        for _, titleData in ipairs(data.AvailableTitles or {}) do
            local titleEntry = titleData
            local equipped = data.EquippedTitle == titleEntry.Id
            local button = Instance.new("TextButton")
            button.LayoutOrder = order
            button.Size = UDim2.new(1, -8, 0, 36)
            button.BackgroundColor3 = equipped and Color3.fromRGB(78, 116, 97) or Color3.fromRGB(72, 91, 108)
            button.Text = titleEntry.Icon .. "  " .. titleEntry.Name .. (equipped and " · ВЫБРАН" or " · НАДЕТЬ")
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextSize = 11
            button.Font = Enum.Font.GothamBold
            button.Parent = profileList
            addCorner(button, 8)
            button.Activated:Connect(function()
                local success, result = pcall(function()
                    return publicProfileRemote:InvokeServer({ Action = "EquipTitle", TitleId = titleEntry.Id })
                end)
                if success and result and result.Ok then
                    data.EquippedTitle = titleEntry.Id
                    showNotice(result.Message or "Титул установлен!")
                    renderPublicProfile(data, true)
                else
                    showNotice(result and result.Message or "Этот титул ещё не открыт.")
                end
            end)
            order += 1
        end
    end
    profilePanel.Visible = true
end

openPublicProfile = function(targetUserId)
    local data = invokePublicProfile({ Action = "Get", UserId = targetUserId })
    if data then renderPublicProfile(data, targetUserId == player.UserId) end
end

local openPublicProfile
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
        info.Text = string.format("%s\nУровень %d · Гостей %d/%d\n%s · ★ %d", entry.DisplayName, entry.Level or 1, entry.Visitors or 0, entry.Capacity or 8, entry.IsLocal and "ЭТОТ СЕРВЕР" or "ДРУГОЙ СЕРВЕР", entry.Likes or 0)
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
            local result = invokeVisit({
                Action = "VisitGlobal",
                UserId = entry.UserId,
                JobId = entry.JobId,
                PlaceId = entry.PlaceId,
            })
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

        if entry.IsLocal then
            local publicProfile = Instance.new("TextButton")
            publicProfile.Position = UDim2.new(1, -8, 0, 100)
            publicProfile.Size = UDim2.fromOffset(76, 25)
            publicProfile.BackgroundColor3 = Color3.fromRGB(76, 126, 105)
            publicProfile.Text = "ПРОФИЛЬ"
            publicProfile.TextColor3 = Color3.new(1, 1, 1)
            publicProfile.TextSize = 8
            publicProfile.Font = Enum.Font.GothamBlack
            publicProfile.Parent = card
            addCorner(publicProfile, 7)
            publicProfile.Activated:Connect(function()
                openPublicProfile(entry.UserId)
            end)
        end

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

profileButton.Activated:Connect(function() openPublicProfile(player.UserId) end)
profileClose.Activated:Connect(function() profilePanel.Visible = false end)

local function openVisitPanel()
    local response = invokeVisit({ Action = "ListGlobal" })
    if response then
        renderVisitList(response)
        if response.DirectoryStatus == "Unavailable" then
            visitStatus.Text = response.DirectoryMessage or "Глобальный каталог недоступен."
        elseif response.DirectoryStatus == "StudioLocalOnly" then
            visitStatus.Text = "Studio: показаны острова текущего сервера"
        end
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
                    category.HasVoted = true
                    renderContest()
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
        contestTabs.Visible = true
        contestTitle.Text = "ЕЖЕНЕДЕЛЬНЫЙ КОНКУРС"
        renderContest()
    end
end

local function openHallPanel()
    local response = invokeContest({ Action = "List" })
    if response then
        contestData = response
        contestPanel.Visible = true
        contestTabs.Visible = false
        contestTitle.Text = "ЗАЛ СЛАВЫ NEST RAIDERS"
        contestWeek.Text = "Победители прошлых недель · награды только за достижения"
        clearContestList()

        local history = response.History or {}
        if #history == 0 then
            addContestLabel("Пока нет завершённых конкурсов. Первые победители появятся после окончания недели!", 1, 64, Color3.fromRGB(255, 220, 151))
        else
            local order = 1
            for _, archive in ipairs(history) do
                addContestLabel("НЕДЕЛЯ " .. tostring(archive.Week), order, 25, Color3.fromRGB(255, 220, 151))
                order += 1
                local archiveWeek = archive.Week
                for _, categoryId in ipairs({"Cozy", "Nature", "Fantasy"}) do
                    local awardCategoryId = categoryId
                    local winners = archive.Categories and archive.Categories[awardCategoryId] or {}
                    local categoryNames = { Cozy = "Уют", Nature = "Природа", Fantasy = "Фэнтези" }
                    addContestLabel(categoryNames[awardCategoryId] or awardCategoryId, order, 21, Color3.fromRGB(208, 218, 238))
                    order += 1
                    if #winners == 0 then
                        addContestLabel("Нет призёров", order, 22)
                        order += 1
                    else
                        for _, winner in ipairs(winners) do
                            local winnerEntry = winner
                            local medal = winnerEntry.Place == 1 and "🥇" or (winnerEntry.Place == 2 and "🥈" or "🥉")
                            local awardKey = archiveWeek .. "_" .. awardCategoryId
                            local alreadyClaimed = response.ClaimedTrophies
                                and response.ClaimedTrophies[awardKey] ~= nil
                            local row = Instance.new("Frame")
                            row.LayoutOrder = order
                            row.Size = UDim2.new(1, -8, 0, 48)
                            row.BackgroundColor3 = Color3.fromRGB(62, 70, 88)
                            row.BorderSizePixel = 0
                            row.Parent = contestList
                            addCorner(row, 9)

                            local name = Instance.new("TextLabel")
                            name.BackgroundTransparency = 1
                            name.Position = UDim2.fromOffset(9, 4)
                            name.Size = UDim2.new(1, -112, 1, -8)
                            name.Text = string.format("%s %s · %d голосов", medal, winnerEntry.DisplayName, winnerEntry.Votes or 0)
                            name.TextColor3 = Color3.fromRGB(240, 242, 248)
                            name.TextSize = 10
                            name.TextWrapped = true
                            name.TextXAlignment = Enum.TextXAlignment.Left
                            name.Font = Enum.Font.GothamBold
                            name.Parent = row

                            if winnerEntry.UserId == player.UserId then
                                local claim = Instance.new("TextButton")
                                claim.AnchorPoint = Vector2.new(1, 0.5)
                                claim.Position = UDim2.new(1, -6, 0.5, 0)
                                claim.Size = UDim2.fromOffset(94, 34)
                                claim.BackgroundColor3 = alreadyClaimed and Color3.fromRGB(83, 91, 104) or Color3.fromRGB(166, 126, 64)
                                claim.Text = alreadyClaimed and "ПОЛУЧЕНО" or "ЗАБРАТЬ КУБОК"
                                claim.TextColor3 = Color3.new(1, 1, 1)
                                claim.TextSize = 8
                                claim.Font = Enum.Font.GothamBlack
                                claim.Active = not alreadyClaimed
                                claim.Parent = row
                                addCorner(claim, 8)
                                claim.Activated:Connect(function()
                                    if alreadyClaimed then return end
                                    claim.Active = false
                                    local result = invokeContest({
                                        Action = "ClaimTrophy",
                                        Week = archiveWeek,
                                        Category = awardCategoryId,
                                    })
                                    if result then
                                        response.ClaimedTrophies = response.ClaimedTrophies or {}
                                        response.ClaimedTrophies[awardKey] = {
                                            Week = archiveWeek,
                                            Category = awardCategoryId,
                                            Place = winnerEntry.Place,
                                        }
                                        claim.Text = "ПОЛУЧЕНО"
                                        claim.BackgroundColor3 = Color3.fromRGB(83, 91, 104)
                                        claim.Active = false
                                        showNotice(result.Message or "Кубок установлен в твоём гнезде!")
                                    else
                                        claim.Active = true
                                    end
                                end)
                            end
                            order += 1
                        end
                    end
                end
            end
        end
        contestPanel.Visible = true
    end
end

contestButton.Activated:Connect(openContestPanel)
hallButton.Activated:Connect(openHallPanel)
contestClose.Activated:Connect(function()
    contestPanel.Visible = false
    contestTabs.Visible = true
    contestTitle.Text = "ЕЖЕНЕДЕЛЬНЫЙ КОНКУРС"
end)

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
    collectDisplay.Text = "СОБРАТЬ · " .. tostring(data.StoredCoins or 0) .. " мон."
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
            addCareAction("КОРМ 10мон.", "Feed", -80, 77, Color3.fromRGB(183, 139, 70))
            addCareAction("СОН", "Sleep", -8, 77, Color3.fromRGB(91, 104, 153))
            addCareAction("ЛАКОМСТВО 15мон.", "Treat", -8, 110, Color3.fromRGB(180, 115, 65), 140)
            addCareAction("ИГРАТЬ С ИГРУШКОЙ", "ToyPlay", -8, 143, Color3.fromRGB(91, 133, 173), 140)

            local toyChoices = {
                { Id = "MeadowBall", Label = "МЯЧ 25мон.", X = -152, Color = Color3.fromRGB(204, 111, 83) },
                { Id = "CozyPlush", Label = "ПЛЮШ 40мон.", X = -80, Color = Color3.fromRGB(139, 108, 185) },
                { Id = "WindSpinner", Label = "ВЕРТУШКА 35мон.", X = -8, Color = Color3.fromRGB(74, 159, 153) },
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
        if entry.Discovered then
            local origin = entry.DiscoveredBiome and ("  ·  Найден: " .. tostring(entry.BiomeName)) or ""
            details.Text = string.format("%s  ·  В коллекции: %d  ·  +%d монет / 10 сек.%s",
                entry.Rarity, entry.OwnedCount, entry.Income, origin)
        elseif entry.HybridOnly then
            details.Text = string.format("%s  ·  Только через разведение", entry.Rarity)
        else
            details.Text = string.format("%s  ·  %s: %d%%",
                entry.Rarity, entry.EggName or "Яйцо", entry.HatchChance or 0)
        end
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

-- A hatched pet changes replicated CompanionCount. Keep already-open inventory
-- and collection windows synchronized without requiring players to close/reopen.
local refreshingCompanionWindows = false
player:GetAttributeChangedSignal("CompanionCount"):Connect(function()
    if not inventoryPanel.Visible and not bookPanel.Visible then return end
    if refreshingCompanionWindows then return end
    refreshingCompanionWindows = true
    task.defer(function()
        if inventoryPanel.Visible then
            local data = invokeInventory({ Action = "Get" })
            if data and inventoryPanel.Visible then renderInventory(data) end
        end
        if bookPanel.Visible then
            local data = invokeCollectionBook()
            if data and bookPanel.Visible then renderCollectionBook(data) end
        end
        refreshingCompanionWindows = false
    end)
end)

local function updateStats()
    if not player:GetAttribute("ProfileLoaded") then
        stats.Text = "Загрузка гнезда..."
        return
    end
    local persistence = player:GetAttribute("ProfilePersistence")
    local saveLabel = persistence == "SAVED" and "Сохранение: ВКЛ" or "Сохранение: ТЕСТ"
    stats.Text = string.format("Монеты: %d\nЯйца: %d    Питомцы: %d\nУровень: %d\nГнездо: %s\n%s",
        player:GetAttribute("Coins") or 0,
        player:GetAttribute("EggCount") or 0,
        player:GetAttribute("CompanionCount") or 0,
        player:GetAttribute("Level") or 1,
        player:GetAttribute("PlotId") or "Назначается...",
        saveLabel)
end

for _, attribute in ipairs({"ProfileLoaded", "ProfilePersistence", "Coins", "EggCount", "CompanionCount", "Level", "PlotId"}) do
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
-- First playable onboarding: guide the existing server-authoritative egg loop.
-- The client only highlights an object; it cannot grant eggs or hatch companions.
local guide = Instance.new("Frame")
guide.Name = "FirstPlayGuide"
guide.AnchorPoint = Vector2.new(1, 0)
guide.Position = UDim2.new(1, -12, 0, 66)
guide.Size = UDim2.fromOffset(236, 108)
guide.BackgroundColor3 = Color3.fromRGB(27, 51, 60)
guide.BackgroundTransparency = 0.06
guide.BorderSizePixel = 0
guide.Parent = gui
addCorner(guide, 13)
addStroke(guide, Color3.fromRGB(242, 201, 123), 1.5)

local guideText = Instance.new("TextLabel")
guideText.Name = "GuideText"
guideText.Position = UDim2.fromOffset(12, 8)
guideText.Size = UDim2.new(1, -24, 1, -16)
guideText.BackgroundTransparency = 1
guideText.Font = Enum.Font.GothamBold
guideText.TextSize = 13
guideText.TextColor3 = Color3.fromRGB(245, 236, 205)
guideText.TextWrapped = true
guideText.TextXAlignment = Enum.TextXAlignment.Left
guideText.TextYAlignment = Enum.TextYAlignment.Center
guideText.Parent = guide

-- The Emerald trial stays visible while exploring the second biome.
local trialPanel = Instance.new("Frame")
trialPanel.Name = "BiomeTrialPanel"
trialPanel.AnchorPoint = Vector2.new(1, 0)
trialPanel.Position = UDim2.new(1, -12, 0, 184)
trialPanel.Size = UDim2.fromOffset(236, 112)
trialPanel.BackgroundColor3 = Color3.fromRGB(30, 57, 51)
trialPanel.BackgroundTransparency = 0.04
trialPanel.BorderSizePixel = 0
trialPanel.Visible = false
trialPanel.Parent = gui
addCorner(trialPanel, 13)
addStroke(trialPanel, Color3.fromRGB(117, 225, 159), 1.5)

local trialTitle = Instance.new("TextLabel")
trialTitle.Position = UDim2.fromOffset(12, 8)
trialTitle.Size = UDim2.new(1, -24, 0, 22)
trialTitle.BackgroundTransparency = 1
trialTitle.Font = Enum.Font.GothamBlack
trialTitle.TextSize = 13
trialTitle.TextColor3 = Color3.fromRGB(188, 255, 202)
trialTitle.TextXAlignment = Enum.TextXAlignment.Left
trialTitle.Text = "ИСПЫТАНИЕ ДРЕВНЕЙ РОЩИ"
trialTitle.Parent = trialPanel

local trialDescription = Instance.new("TextLabel")
trialDescription.Position = UDim2.fromOffset(12, 33)
trialDescription.Size = UDim2.new(1, -24, 0, 38)
trialDescription.BackgroundTransparency = 1
trialDescription.Font = Enum.Font.GothamMedium
trialDescription.TextSize = 12
trialDescription.TextWrapped = true
trialDescription.TextYAlignment = Enum.TextYAlignment.Top
trialDescription.TextXAlignment = Enum.TextXAlignment.Left
trialDescription.TextColor3 = Color3.fromRGB(235, 245, 226)
trialDescription.Parent = trialPanel

local trialBarBack = Instance.new("Frame")
trialBarBack.Position = UDim2.fromOffset(12, 80)
trialBarBack.Size = UDim2.new(1, -24, 0, 9)
trialBarBack.BackgroundColor3 = Color3.fromRGB(18, 37, 34)
trialBarBack.BorderSizePixel = 0
trialBarBack.Parent = trialPanel
addCorner(trialBarBack, 5)

local trialBarFill = Instance.new("Frame")
trialBarFill.Size = UDim2.fromScale(0, 1)
trialBarFill.BackgroundColor3 = Color3.fromRGB(115, 235, 154)
trialBarFill.BorderSizePixel = 0
trialBarFill.Parent = trialBarBack
addCorner(trialBarFill, 5)

local trialStatus = Instance.new("TextLabel")
trialStatus.Position = UDim2.fromOffset(12, 92)
trialStatus.Size = UDim2.new(1, -24, 0, 14)
trialStatus.BackgroundTransparency = 1
trialStatus.Font = Enum.Font.GothamBold
trialStatus.TextSize = 10
trialStatus.TextColor3 = Color3.fromRGB(186, 226, 196)
trialStatus.TextXAlignment = Enum.TextXAlignment.Right
trialStatus.Parent = trialPanel

local bossBarBack = Instance.new("Frame")
bossBarBack.Position = UDim2.fromOffset(12, 112)
bossBarBack.Size = UDim2.new(1, -24, 0, 9)
bossBarBack.BackgroundColor3 = Color3.fromRGB(57, 28, 25)
bossBarBack.BorderSizePixel = 0
bossBarBack.Visible = false
bossBarBack.Parent = trialPanel
addCorner(bossBarBack, 5)

local bossBarFill = Instance.new("Frame")
bossBarFill.Size = UDim2.fromScale(1, 1)
bossBarFill.BackgroundColor3 = Color3.fromRGB(255, 111, 65)
bossBarFill.BorderSizePixel = 0
bossBarFill.Parent = bossBarBack
addCorner(bossBarFill, 5)

local bossStatus = Instance.new("TextLabel")
bossStatus.Position = UDim2.fromOffset(12, 124)
bossStatus.Size = UDim2.new(1, -24, 0, 14)
bossStatus.BackgroundTransparency = 1
bossStatus.Font = Enum.Font.GothamBold
bossStatus.TextSize = 10
bossStatus.TextColor3 = Color3.fromRGB(255, 190, 145)
bossStatus.TextXAlignment = Enum.TextXAlignment.Right
bossStatus.Visible = false
bossStatus.Parent = trialPanel

local function updateBiomeTrialPanel()
    local biomeId = player:GetAttribute("CurrentBiome")
    local isEmerald = biomeId == "EmeraldWilds"
    local isFrost = biomeId == "FrostHighlands"
    local isEmber = biomeId == "Emberlands"
    local isCrystal = biomeId == "CrystalRealm"
    local isAncient = biomeId == "AncientHeights"
    trialPanel.Visible = isEmerald or isFrost or isEmber or isCrystal or isAncient
    if not trialPanel.Visible then return end

    local countAttribute = isAncient and "AncientTempleProgress"
        or (isCrystal and "CrystalTrialProgress"
        or (isFrost and "FrostTrialProgress" or (isEmber and "EmberTrialProgress" or "EmeraldTrialProgress")))
    local completeAttribute = isAncient and "AncientTempleCompleted"
        or (isCrystal and "CrystalTrialCompleted"
        or (isFrost and "FrostTrialCompleted" or (isEmber and "EmberTrialCompleted" or "EmeraldTrialCompleted")))
    local count = math.clamp(tonumber(player:GetAttribute(countAttribute)) or 0, 0, 3)
    local completed = player:GetAttribute(completeAttribute) == true

    trialPanel.Position = (isEmber or isCrystal) and UDim2.new(1, -12, 0, 286) or UDim2.new(1, -12, 0, 184)
    trialPanel.Size = UDim2.fromOffset(236, (isEmber or isCrystal) and 142 or 112)
    trialPanel.BackgroundColor3 = isAncient and Color3.fromRGB(42, 61, 43)
        or (isCrystal and Color3.fromRGB(48, 39, 76)
        or (isEmber and Color3.fromRGB(62, 39, 34) or Color3.fromRGB(30, 57, 51)))

    trialTitle.Text = isAncient and "ХРАМ ДРЕВНЕГО ДРЕВА"
        or (isCrystal and "ИСПЫТАНИЕ ПРИЗМЫ"
        or (isEmber and "ИСПЫТАНИЕ ОГНЕННОГО СЕРДЦА"
        or (isFrost and "ИСПЫТАНИЕ СЕРДЦА ЗИМЫ" or "ИСПЫТАНИЕ ДРЕВНЕЙ РОЩИ")))
    trialTitle.TextColor3 = isAncient and Color3.fromRGB(220, 239, 179)
        or (isCrystal and Color3.fromRGB(216, 190, 255)
        or (isEmber and Color3.fromRGB(255, 183, 125)
        or (isFrost and Color3.fromRGB(190, 231, 255) or Color3.fromRGB(188, 255, 202))))

    if isAncient then
        trialDescription.Text = completed
            and "Сердце храма пробуждено! Сокровище уже твоё."
            or (count >= 3 and "Все руны отвечают. Открой сундук в глубине храма."
                or "Пробуди руны в порядке: Корни → Река → Рассвет. Ошибка сбросит цепочку.")
        trialBarFill.BackgroundColor3 = Color3.fromRGB(174, 218, 133)
        trialBarFill.Size = UDim2.fromScale(count / 3, 1)
        trialStatus.Text = completed and "СОКРОВИЩЕ ПОЛУЧЕНО"
            or string.format("ПРОБУЖДЕНО РУН: %d / 3", count)
        bossBarBack.Visible = false
        bossStatus.Visible = false
    elseif isCrystal then
        trialDescription.Text = completed and "Хранитель повержен! Путь к Древним высотам открыт. Осталось достичь 50 уровня."
            or (count >= 3 and "Три луча соединены! Атакуй Хранителя и уклоняйся от призматической волны."
                or "Настрой призмы по порядку: лазурная → розовая → золотая. Ошибка сбросит цепочку.")
        trialBarFill.BackgroundColor3 = Color3.fromRGB(186, 147, 255)
        trialBarFill.Size = UDim2.fromScale(count / 3, 1)
        trialStatus.Text = completed and "ИСПЫТАНИЕ ПРОЙДЕНО"
            or string.format("НАСТРОЕНО ПРИЗМ: %d / 3", count)
        bossBarBack.Visible = count >= 3 and not completed
        bossStatus.Visible = count >= 3
        local bossHealth = math.clamp(tonumber(player:GetAttribute("CrystalTrialBossHealth")) or 160, 0, 160)
        bossBarFill.Size = UDim2.fromScale(bossHealth / 160, 1)
        if player:GetAttribute("CrystalTrialBossWindup") == true then
            bossStatus.Text = "ПРИЗМАТИЧЕСКАЯ ВОЛНА! УВОРАЧИВАЙСЯ!"
            bossStatus.TextColor3 = Color3.fromRGB(255, 125, 220)
        else
            bossStatus.Text = completed and "ХРАНИТЕЛЬ ПОВЕРЖЕН"
                or string.format("ЗДОРОВЬЕ ХРАНИТЕЛЯ: %d / 160", bossHealth)
            bossStatus.TextColor3 = Color3.fromRGB(216, 190, 255)
        end
    elseif isEmber then
        trialDescription.Text = completed and "Огненный страж повержен! Ты выполнил испытание для Хрустального королевства. Осталось достичь 35 уровня."
            or (count >= 3 and "Руны пробуждены! Атакуй Огненного стража и уклоняйся от его огненной волны."
                or "Найди три руны на вершине вулкана. Затем сразись с Огненным стражем.")
        trialBarFill.BackgroundColor3 = Color3.fromRGB(255, 173, 91)
        trialBarFill.Size = UDim2.fromScale(count / 3, 1)
        trialStatus.Text = completed and "ИСПЫТАНИЕ ПРОЙДЕНО"
            or string.format("ПРОБУЖДЕНО РУН: %d / 3", count)
        bossBarBack.Visible = count >= 3 and not completed
        bossStatus.Visible = count >= 3
        local bossHealth = math.clamp(tonumber(player:GetAttribute("EmberTrialBossHealth")) or 100, 0, 100)
        bossBarFill.Size = UDim2.fromScale(bossHealth / 100, 1)
        if player:GetAttribute("EmberTrialBossWindup") == true then
            bossStatus.Text = "АТАКА СТРАЖА! УВОРАЧИВАЙСЯ!"
            bossStatus.TextColor3 = Color3.fromRGB(255, 105, 80)
        else
            bossStatus.Text = completed and "СТРАЖ ПОВЕРЖЕН"
                or string.format("ЗДОРОВЬЕ СТРАЖА: %d / 100", bossHealth)
            bossStatus.TextColor3 = Color3.fromRGB(255, 190, 145)
        end
    else
        bossBarBack.Visible = false
        bossStatus.Visible = false
        trialDescription.Text = isFrost
            and (completed and "Сердце зимы пробудилось. Испытание завершено!" or "Найди три ледяные руны и пробуди каждую.")
            or (completed and "Древняя роща признала тебя. Испытание завершено!" or "Найди три светящиеся руны и активируй каждую.")
        trialBarFill.BackgroundColor3 = isFrost and Color3.fromRGB(125, 211, 255) or Color3.fromRGB(115, 235, 154)
        trialBarFill.Size = UDim2.fromScale(count / 3, 1)
        trialStatus.Text = completed and "ИСПЫТАНИЕ ПРОЙДЕНО"
            or string.format("ПРОБУЖДЕНО РУН: %d / 3", count)
    end
end

for _, attribute in ipairs({
    "CurrentBiome", "EmeraldTrialProgress", "EmeraldTrialCompleted",
    "FrostTrialProgress", "FrostTrialCompleted", "EmberTrialProgress",
    "EmberTrialCompleted", "EmberTrialBossHealth", "EmberTrialBossWindup",
    "CrystalTrialProgress", "CrystalTrialCompleted", "CrystalTrialBossHealth", "CrystalTrialBossWindup",
    "AncientTempleProgress", "AncientTempleCompleted",
}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateBiomeTrialPanel)
end
updateBiomeTrialPanel()


-- Volcanic heat HUD: values are replicated from the server, never client-authoritative.
local heatPanel = Instance.new("Frame")
heatPanel.Name = "VolcanicHeatPanel"
heatPanel.AnchorPoint = Vector2.new(1, 0)
heatPanel.Position = UDim2.new(1, -24, 0, 110)
heatPanel.Size = UDim2.fromOffset(260, 78)
heatPanel.BackgroundColor3 = Color3.fromRGB(48, 35, 34)
heatPanel.BackgroundTransparency = 0.08
heatPanel.Visible = false
heatPanel.Parent = gui
addCorner(heatPanel, 14)
addStroke(heatPanel, Color3.fromRGB(255, 153, 88), 1.5)

local heatTitle = Instance.new("TextLabel")
heatTitle.BackgroundTransparency = 1
heatTitle.Position = UDim2.fromOffset(14, 7)
heatTitle.Size = UDim2.new(1, -28, 0, 22)
heatTitle.Font = Enum.Font.GothamBold
heatTitle.Text = "ТЕМПЕРАТУРА"
heatTitle.TextColor3 = Color3.fromRGB(255, 220, 190)
heatTitle.TextSize = 14
heatTitle.TextXAlignment = Enum.TextXAlignment.Left
heatTitle.Parent = heatPanel

local heatBarBack = Instance.new("Frame")
heatBarBack.Position = UDim2.fromOffset(14, 34)
heatBarBack.Size = UDim2.new(1, -28, 0, 13)
heatBarBack.BackgroundColor3 = Color3.fromRGB(91, 68, 62)
heatBarBack.Parent = heatPanel
addCorner(heatBarBack, 8)

local heatBar = Instance.new("Frame")
heatBar.Size = UDim2.fromScale(0, 1)
heatBar.BackgroundColor3 = Color3.fromRGB(255, 160, 70)
heatBar.Parent = heatBarBack
addCorner(heatBar, 8)

local heatStatus = Instance.new("TextLabel")
heatStatus.BackgroundTransparency = 1
heatStatus.Position = UDim2.fromOffset(14, 51)
heatStatus.Size = UDim2.new(1, -28, 0, 19)
heatStatus.Font = Enum.Font.GothamMedium
heatStatus.TextColor3 = Color3.fromRGB(255, 238, 220)
heatStatus.TextSize = 11
heatStatus.TextXAlignment = Enum.TextXAlignment.Left
heatStatus.Parent = heatPanel

local function updateHeatPanel()
    local inEmberlands = player:GetAttribute("CurrentBiome") == "Emberlands"
    heatPanel.Visible = inEmberlands
    if not inEmberlands then return end
    local heat = math.clamp(tonumber(player:GetAttribute("Heat")) or 0, 0, 100)
    local protection = math.clamp(tonumber(player:GetAttribute("HeatProtection")) or 0, 0, 100)
    heatBar.Size = UDim2.fromScale(heat / 100, 1)
    heatBar.BackgroundColor3 = heat >= 90 and Color3.fromRGB(255, 70, 48)
        or (heat >= 65 and Color3.fromRGB(255, 139, 48) or Color3.fromRGB(255, 190, 86))
    if player:GetAttribute("HeatInSanctuary") then
        heatStatus.Text = "ОХЛАЖДЕНИЕ · ЗАЩИТА " .. protection .. "%"
    elseif heat >= 90 then
        heatStatus.Text = "КРИТИЧЕСКИЙ ПЕРЕГРЕВ · ИЩИ УБЕЖИЩЕ!"
    elseif heat >= 65 then
        heatStatus.Text = "ОПАСНО · ОТСТУПИ ОТ ЛАВЫ"
    elseif heat > 0 then
        heatStatus.Text = "ЖАР НАКАПЛИВАЕТСЯ · ЗАЩИТА " .. protection .. "%"
    else
        heatStatus.Text = "ТЕМПЕРАТУРА В НОРМЕ"
    end
end
for _, attribute in ipairs({"CurrentBiome", "Heat", "HeatInSanctuary", "HeatProtection"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateHeatPanel)
end
updateHeatPanel()


-- Ashfall event HUD: event phase and saved crystal count are server-authoritative.
local ashfallPanel = Instance.new("Frame")
ashfallPanel.Name = "AshfallEventPanel"
ashfallPanel.AnchorPoint = Vector2.new(1, 0)
ashfallPanel.Position = UDim2.new(1, -24, 0, 198)
ashfallPanel.Size = UDim2.fromOffset(260, 78)
ashfallPanel.BackgroundColor3 = Color3.fromRGB(48, 35, 34)
ashfallPanel.BackgroundTransparency = 0.08
ashfallPanel.Visible = false
ashfallPanel.Parent = gui
addCorner(ashfallPanel, 14)
addStroke(ashfallPanel, Color3.fromRGB(255, 190, 92), 1.5)

local ashfallTitle = Instance.new("TextLabel")
ashfallTitle.BackgroundTransparency = 1
ashfallTitle.Position = UDim2.fromOffset(14, 7)
ashfallTitle.Size = UDim2.new(1, -28, 0, 22)
ashfallTitle.Font = Enum.Font.GothamBold
ashfallTitle.Text = "ВУЛКАНИЧЕСКОЕ СОБЫТИЕ"
ashfallTitle.TextColor3 = Color3.fromRGB(255, 220, 190)
ashfallTitle.TextSize = 13
ashfallTitle.TextXAlignment = Enum.TextXAlignment.Left
ashfallTitle.Parent = ashfallPanel

local ashfallStatus = Instance.new("TextLabel")
ashfallStatus.BackgroundTransparency = 1
ashfallStatus.Position = UDim2.fromOffset(14, 31)
ashfallStatus.Size = UDim2.new(1, -28, 0, 19)
ashfallStatus.Font = Enum.Font.GothamMedium
ashfallStatus.TextColor3 = Color3.fromRGB(255, 238, 220)
ashfallStatus.TextSize = 11
ashfallStatus.TextXAlignment = Enum.TextXAlignment.Left
ashfallStatus.Parent = ashfallPanel

local ashfallCrystals = Instance.new("TextLabel")
ashfallCrystals.BackgroundTransparency = 1
ashfallCrystals.Position = UDim2.fromOffset(14, 51)
ashfallCrystals.Size = UDim2.new(1, -28, 0, 18)
ashfallCrystals.Font = Enum.Font.GothamBold
ashfallCrystals.TextColor3 = Color3.fromRGB(255, 204, 119)
ashfallCrystals.TextSize = 11
ashfallCrystals.TextXAlignment = Enum.TextXAlignment.Left
ashfallCrystals.Parent = ashfallPanel

local function updateAshfallPanel()
    local inEmberlands = player:GetAttribute("CurrentBiome") == "Emberlands"
    ashfallPanel.Visible = inEmberlands
    if not inEmberlands then return end
    local phase = tostring(player:GetAttribute("AshfallPhase") or "IDLE")
    local seconds = math.max(0, tonumber(player:GetAttribute("AshfallSeconds")) or 0)
    if phase == "WARNING" then
        ashfallStatus.Text = "ИЗВЕРЖЕНИЕ ЧЕРЕЗ " .. seconds .. " СЕК. · ИЩИ УКРЫТИЕ!"
    elseif phase == "ERUPTION" then
        ashfallStatus.Text = "ИЗВЕРЖЕНИЕ! УКЛОНЯЙСЯ ОТ ЛАВОВЫХ ВОЛН!"
    elseif phase == "AFTERMATH" then
        ashfallStatus.Text = "ПОСЛЕДСТВИЯ · КРИСТАЛЛЫ ЕЩЁ " .. seconds .. " СЕК."
    else
        ashfallStatus.Text = "Следующее извержение примерно через " .. seconds .. " сек."
    end
    ashfallCrystals.Text = "Пепельные кристаллы: " .. math.max(0, tonumber(player:GetAttribute("AshCrystals")) or 0)
end
for _, attribute in ipairs({"CurrentBiome", "AshfallPhase", "AshfallSeconds", "AshCrystals"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateAshfallPanel)
end
updateAshfallPanel()

-- Crystal Realm mining HUD: the saved shard balance is replicated by the server.
local crystalPanel = Instance.new("Frame")
crystalPanel.Name = "CrystalMiningPanel"
crystalPanel.AnchorPoint = Vector2.new(1, 0)
crystalPanel.Position = UDim2.new(1, -24, 0, 110)
crystalPanel.Size = UDim2.fromOffset(260, 78)
crystalPanel.BackgroundColor3 = Color3.fromRGB(48, 40, 68)
crystalPanel.BackgroundTransparency = 0.08
crystalPanel.Visible = false
crystalPanel.Parent = gui
addCorner(crystalPanel, 14)
addStroke(crystalPanel, Color3.fromRGB(190, 157, 255), 1.5)

local crystalTitle = Instance.new("TextLabel")
crystalTitle.BackgroundTransparency = 1
crystalTitle.Position = UDim2.fromOffset(14, 8)
crystalTitle.Size = UDim2.new(1, -28, 0, 22)
crystalTitle.Font = Enum.Font.GothamBold
crystalTitle.Text = "ХРУСТАЛЬНОЕ КОРОЛЕВСТВО"
crystalTitle.TextColor3 = Color3.fromRGB(225, 205, 255)
crystalTitle.TextSize = 13
crystalTitle.TextXAlignment = Enum.TextXAlignment.Left
crystalTitle.Parent = crystalPanel

local crystalBalance = Instance.new("TextLabel")
crystalBalance.BackgroundTransparency = 1
crystalBalance.Position = UDim2.fromOffset(14, 33)
crystalBalance.Size = UDim2.new(1, -28, 0, 18)
crystalBalance.Font = Enum.Font.GothamBold
crystalBalance.TextColor3 = Color3.fromRGB(206, 229, 255)
crystalBalance.TextSize = 12
crystalBalance.TextXAlignment = Enum.TextXAlignment.Left
crystalBalance.Parent = crystalPanel

local crystalHint = Instance.new("TextLabel")
crystalHint.BackgroundTransparency = 1
crystalHint.Position = UDim2.fromOffset(14, 53)
crystalHint.Size = UDim2.new(1, -28, 0, 16)
crystalHint.Font = Enum.Font.GothamMedium
crystalHint.Text = "Ищи сияющие жилы и добывай осколки"
crystalHint.TextColor3 = Color3.fromRGB(190, 180, 215)
crystalHint.TextSize = 10
crystalHint.TextXAlignment = Enum.TextXAlignment.Left
crystalHint.Parent = crystalPanel

local function updateCrystalPanel()
    local visible = player:GetAttribute("CurrentBiome") == "CrystalRealm"
    crystalPanel.Visible = visible
    if visible then
        crystalBalance.Text = "Кристальные осколки: " .. math.max(0, tonumber(player:GetAttribute("CrystalShards")) or 0)
    end
end
for _, attribute in ipairs({"CurrentBiome", "CrystalShards"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateCrystalPanel)
end
updateCrystalPanel()

-- Ancient Heights resource HUD: Elderwood balance is saved server-side.
local ancientPanel = Instance.new("Frame")
ancientPanel.Name = "AncientHarvestPanel"
ancientPanel.AnchorPoint = Vector2.new(1, 0)
ancientPanel.Position = UDim2.new(1, -24, 0, 110)
ancientPanel.Size = UDim2.fromOffset(260, 78)
ancientPanel.BackgroundColor3 = Color3.fromRGB(42, 61, 43)
ancientPanel.BackgroundTransparency = 0.08
ancientPanel.Visible = false
ancientPanel.Parent = gui
addCorner(ancientPanel, 14)
addStroke(ancientPanel, Color3.fromRGB(174, 214, 130), 1.5)

local ancientTitle = Instance.new("TextLabel")
ancientTitle.BackgroundTransparency = 1
ancientTitle.Position = UDim2.fromOffset(14, 8)
ancientTitle.Size = UDim2.new(1, -28, 0, 22)
ancientTitle.Font = Enum.Font.GothamBold
ancientTitle.Text = "ДРЕВНИЕ ВЫСОТЫ"
ancientTitle.TextColor3 = Color3.fromRGB(220, 239, 179)
ancientTitle.TextSize = 13
ancientTitle.TextXAlignment = Enum.TextXAlignment.Left
ancientTitle.Parent = ancientPanel

local elderwoodBalance = Instance.new("TextLabel")
elderwoodBalance.BackgroundTransparency = 1
elderwoodBalance.Position = UDim2.fromOffset(14, 33)
elderwoodBalance.Size = UDim2.new(1, -28, 0, 18)
elderwoodBalance.Font = Enum.Font.GothamBold
elderwoodBalance.TextColor3 = Color3.fromRGB(236, 241, 210)
elderwoodBalance.TextSize = 12
elderwoodBalance.TextXAlignment = Enum.TextXAlignment.Left
elderwoodBalance.Parent = ancientPanel

local ancientHint = Instance.new("TextLabel")
ancientHint.BackgroundTransparency = 1
ancientHint.Position = UDim2.fromOffset(14, 53)
ancientHint.Size = UDim2.new(1, -28, 0, 16)
ancientHint.Font = Enum.Font.GothamMedium
ancientHint.Text = "Ищи светящиеся древние корни"
ancientHint.TextColor3 = Color3.fromRGB(190, 211, 166)
ancientHint.TextSize = 10
ancientHint.TextXAlignment = Enum.TextXAlignment.Left
ancientHint.Parent = ancientPanel

local function updateAncientPanel()
    local visible = player:GetAttribute("CurrentBiome") == "AncientHeights"
    ancientPanel.Visible = visible
    if visible then
        elderwoodBalance.Text = "Древесная эссенция: " .. math.max(0, tonumber(player:GetAttribute("Elderwood")) or 0)
    end
end
for _, attribute in ipairs({"CurrentBiome", "Elderwood"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateAncientPanel)
end
updateAncientPanel()

local guideHighlight = Instance.new("Highlight")
guideHighlight.Name = "FirstPlayTarget"
guideHighlight.FillColor = Color3.fromRGB(255, 216, 129)
guideHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
guideHighlight.FillTransparency = 0.65
guideHighlight.OutlineTransparency = 0
guideHighlight.Enabled = false
guideHighlight.Parent = Workspace.CurrentCamera or Workspace

local function firstPlayTarget()
    local world = Workspace:FindFirstChild("NestRaidersWorld")
    local island = world and world:FindFirstChild("StarterIsland")
    if not island then return nil end
    local eggs = tonumber(player:GetAttribute("EggCount")) or 0
    if eggs > 0 then
        local plots = island:FindFirstChild("PlayerPlots")
        for _, plot in ipairs(plots and plots:GetChildren() or {}) do
            if plot:GetAttribute("OwnerUserId") == player.UserId then
                return plot:FindFirstChild("HatchStation")
            end
        end
        return nil
    end
    local eggsFolder = island:FindFirstChild("EggSpawnPoints")
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local nearest, bestDistance
    for _, egg in ipairs(eggsFolder and eggsFolder:GetChildren() or {}) do
        if egg:GetAttribute("WorldEgg") and not egg:GetAttribute("Collected") then
            local distance = root and (root.Position - egg.Position).Magnitude or 0
            if not bestDistance or distance < bestDistance then
                nearest, bestDistance = egg, distance
            end
        end
    end
    return nearest
end

local function updateFirstPlayGuide()
    if remotes:GetAttribute("WorldHealth") == "DEGRADED" then
        local reason = tostring(remotes:GetAttribute("WorldHealthError") or "неизвестная ошибка")
        guideText.Text = "⚠ ОШИБКА МИРА\n" .. string.sub(reason, 1, 120)
        guideHighlight.Enabled = false
        return
    end
    if not player:GetAttribute("ProfileLoaded") then
        guideText.Text = "ПЕРВОЕ ПРИКЛЮЧЕНИЕ\nПодключаем сохранение..."
        guideHighlight.Enabled = false
        return
    end
    if (tonumber(player:GetAttribute("CompanionCount")) or 0) > 0 then
        guideText.Text = "✓ ПЕРВЫЙ ПИТОМЕЦ!\nОткрой ☰ МЕНЮ → МОИ ПИТОМЦЫ."
        guideHighlight.Enabled = false
        guide.Visible = true
        return
    end
    local hasEgg = (tonumber(player:GetAttribute("EggCount")) or 0) > 0
    guideText.Text = hasEgg
        and "ШАГ 2 / 2 · ВЫЛУПЛЕНИЕ\nИди к светящемуся гнезду на своём участке. Нажми E / коснись кнопки."
        or "ШАГ 1 / 2 · ПЕРВОЕ ЯЙЦО\nНайди подсвеченное яйцо на острове. Подойди и нажми E / коснись кнопки."
    local target = firstPlayTarget()
    guideHighlight.Adornee = target
    guideHighlight.Enabled = target ~= nil
end
for _, attribute in ipairs({"ProfileLoaded", "EggCount", "CompanionCount", "PlotId"}) do
    player:GetAttributeChangedSignal(attribute):Connect(updateFirstPlayGuide)
end
task.spawn(function()
    while guide.Parent do
        updateFirstPlayGuide()
        task.wait(2)
    end
    guideHighlight:Destroy()
end)

-- Mark the HUD usable only after every panel, action and event binding has finished.
-- A partially constructed ScreenGui is not proof that the client initialized.
gui:SetAttribute("ClientReady", true)
print("[NEST RAIDERS] Client HUD initialized.")
