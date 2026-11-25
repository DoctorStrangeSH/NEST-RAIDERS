"""Static regression checks for the playable Roblox Studio package.

These checks catch known UI boot and placement mistakes; they do not replace Studio Play tests.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

client = Path("src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua").read_text()
assert 'player.CameraMinZoomDistance = 7' in client
assert 'player.CameraMaxZoomDistance = 24' in client
assert 'ResponsiveHudScale' in client and 'bindHudCamera()' in client
assert 'currentCamera:GetPropertyChangedSignal("ViewportSize")' in client
assert 'Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindHudCamera)' in client
assert 'МЕНЮ' in client and '☰  МЕНЮ' not in client
assert '🪙' not in client, "Avoid unsupported currency emoji glyphs in UI"

server = Path("src/ServerScriptService/Server/Bootstrap.server.lua").read_text()
watchdog = Path("src/StarterPlayer/StarterPlayerScripts/BootRecovery.client.lua").read_text()
world = Path("src/ServerScriptService/Server/World/WorldBuilder.lua").read_text()
game_config = Path("src/ReplicatedStorage/Shared/Config/GameConfig.lua").read_text()
plots = Path("src/ServerScriptService/Server/Services/PlotService.lua").read_text()
companion_service = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
companion_catalog = Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
display_pet_service = Path("src/ServerScriptService/Server/Services/DisplayPetService.lua").read_text()
build_service = Path("src/ServerScriptService/Server/Services/NestBuildService.lua").read_text()
nest_build_catalog = Path("src/ReplicatedStorage/Shared/Config/NestBuildCatalog.lua").read_text()
assert 'local folder = island:FindFirstChild("PlayerPlots")' in plots
assert 'local ok, model, station, ownerLabel = pcall(buildPlot, folder, definition)' in plots
assert 'folder:SetAttribute("CreatedCount", created)' in plots
assert 'folder:SetAttribute("ExpectedCount", #PLOT_DEFINITIONS)' in plots
assert 'return self._initialized, created' in plots

# Sprint 4.69 — synchronized world clock and species-specific activity windows.
assert 'GameConfig.WorldCycle = {' in game_config
assert 'SecondsPerGameHour = 60' in game_config
assert 'StartClockTime = 14' in game_config
assert 'DayStartsAt = 6' in game_config and 'NightStartsAt = 19' in game_config
assert 'local cycleConfig = GameConfig.WorldCycle or {}' in world
assert 'while world.Parent == Workspace do' in world
assert 'Lighting.ClockTime = clockTime' in world
assert 'world:SetAttribute("WorldTimePhase", isNight and "Night" or "Day")' in world
assert 'world:SetAttribute("WorldTimeLabel", isNight and "Ночь" or "День")' in world
assert 'local isNight = clockTime >= nightStartsAt or clockTime < dayStartsAt' in world
assert 'ActivityPeriod = "Day"' in companion_catalog
assert companion_catalog.count('ActivityPeriod = "Night"') >= 4
assert 'NightGlowColor = Color3.fromRGB' in companion_catalog
assert 'local activityPeriod = petDefinition.ActivityPeriod or "Any"' in companion_service
assert 'local isPreferredTime = activityPeriod == "Any"' in companion_service
assert 'nightGlow.Brightness = isNight and 0.8 or 0' in companion_service
assert 'treasureChance *= isPreferredTime and 1.25 or 0.55' in companion_service
assert 'speed *= isPreferredTime and 1.18 or 0.72' in companion_service
assert 'ActivityState' in companion_service

# Sprint 4.70 — dynamic weather, species reactions and live HUD status.
assert 'GameConfig.Weather = {' in game_config
assert 'MinDurationSeconds = 120' in game_config
assert 'MaxDurationSeconds = 210' in game_config
for weather_id in ('Clear', 'Rain', 'Fog', 'Storm'):
    assert f'{weather_id} =' in world
assert 'local weatherConfig = GameConfig.Weather or {}' in world
assert 'Instance.new("Atmosphere")' in world
assert 'Instance.new("Clouds")' in world
assert 'rbxasset://textures/particles/sparkles_main.dds' in world
assert 'emitter.Squash = NumberSequence.new(3)' in world
assert 'emitter.Parent = rainAnchor' in world
assert 'emitter.ShapeSize = Vector3.new(100, 1, 100)' in world
assert 'world:SetAttribute("WorldWeather", weatherId)' in world
assert 'world:SetAttribute("WorldWeatherLabel"' in world
assert 'weatherId == "Storm" and random:NextNumber() < 0.035' in world
assert 'WeatherPreference = "Rain"' in companion_catalog
assert companion_catalog.count('WeatherPreference = "Shelter"') >= 4
assert 'local weatherState = worldFolder and worldFolder:GetAttribute("WorldWeather") or "Clear"' in companion_service
assert 'local seeksShelter = weatherState == "Storm" and weatherPreference == "Shelter"' in companion_service
assert 'local enjoysRain = isWetWeather and weatherPreference == "Rain"' in companion_service
assert 'targetIsShelter = true' in companion_service
assert 'behavior == "SeekingShelter" and "Ищет укрытие"' in companion_service
assert 'behavior == "Sheltering" and "Прячется от грозы"' in companion_service
assert 'local worldInfo = Instance.new("Frame")' in client
assert 'worldInfo.Name = "WorldInfo"' in client
assert 'Lighting:GetPropertyChangedSignal("ClockTime"):Connect(updateWorldInfo)' in client
assert 'GetAttributeChangedSignal("WorldWeatherLabel")' in client
assert 'worldInfo.Size = UDim2.fromOffset(narrow and 188 or 252, 32)' in client
world_health = Path("src/ServerScriptService/Server/World/WorldHealthCheck.lua").read_text()
grove_secret = Path("src/ServerScriptService/Server/Services/AncientSecretService.lua").read_text()
ancient_cave = Path("src/ServerScriptService/Server/Services/AncientCaveService.lua").read_text()
forgotten_boss = Path("src/ServerScriptService/Server/Services/ForgottenHeartBossService.lua").read_text()
collection_book = Path("src/ServerScriptService/Server/Services/CollectionBookService.lua").read_text()
companion_catalog = Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
biome_catalog = Path("src/ReplicatedStorage/Shared/Config/BiomeCatalog.lua").read_text()
companion_service = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
profile_template = Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
assert 'FrostHighlands' in world_health and 'FrostRunePrompt' in world_health
assert 'GlacierCauseway' in world_health and 'FrostEggOddsSign' in world_health


assert 'Создано участков: %d из 6' in world_health
assert 'Папка PlayerPlots не создана службой PlotService' in world_health

economy = Path("src/ServerScriptService/Server/Services/EconomyService.lua").read_text()
display_pets = Path("src/ServerScriptService/Server/Services/DisplayPetService.lua").read_text()
assert 'local function getCompanionIncome(companion)' in economy
assert 'trait.IncomeBonus' in economy and 'profile.CompanionIncomeRemainder' in economy
assert 'local payout = math.min(math.floor(accumulated), MAX_TICK_REWARD)' in economy
assert 'local function getCompanionIncome(companion)' in display_pets
assert 'trait.IncomeBonus' in display_pets
assert 'IncomeBonusPercent' in display_pets
assert 'profile.Nest.StoredIncomeRemainder' in display_pets
assert 'local payout = math.floor(accumulated)' in display_pets
assert 'return math.floor(total * 100 + 0.5) / 100' in display_pets

eggs = Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()
biomes = Path("src/ReplicatedStorage/Shared/Config/BiomeCatalog.lua").read_text()
assert 'local BiomeCatalog = {' in biomes
assert 'DefaultEggId = "MeadowEgg"' in biomes
assert 'SpeciesWeights' in biomes and 'MeadowFox = 55' in biomes
assert 'local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)' in eggs
assert 'chooseCompanion(egg.Id or "MeadowEgg", profile)' in eggs
assert 'ArtifactBonusService:ChooseHatchSpecies(profile, eggDefinition.SpeciesWeights, math.random())' in eggs
assert 'BiomeId = egg:GetAttribute("BiomeId") or "Meadow"' in eggs
assert 'OriginBiome = egg.BiomeId or "Meadow"' in eggs



companions = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
inventory = Path("src/ServerScriptService/Server/Services/InventoryService.lua").read_text()
book = Path("src/ServerScriptService/Server/Services/CollectionBookService.lua").read_text()
assert 'profile.DiscoveredBiomes[companion.Id] = companion.OriginBiome or "Meadow"' in eggs
assert 'local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)' in book
assert 'BiomeName = biomeName' in book and 'DiscoveredBiome = profile.DiscoveredBiomes[definition.Id]' in book
assert 'ArtifactBonusService:GetHatchSpeciesChance(' in book and 'profile, egg.SpeciesWeights, definition.Id)' in book
assert 'BaseHatchChance = baseBiomeChance' in book
shop_service = Path("src/ServerScriptService/Server/Services/EggShopService.lua").read_text()
assert 'local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)' in shop_service
assert 'ArtifactBonusService:GetHatchSpeciesChance(' in shop_service and 'profile, weights, speciesId)' in shop_service
assert 'Odds = buildOdds(profile, item.EggDefinition)' in shop_service and 'BaseChance = math.max(0, baseChance * 100)' in shop_service
assert 'entry.DiscoveredBiome' in client and 'entry.EggName' in client
assert 'CollectionSearch' in client and 'Поиск питомца или редкости...' in client
assert 'bookFilterButtons' in client and 'Открытые' in client and 'Не найдены' in client
assert 'string.find(searchable, query, 1, true)' in client
assert 'rarityColors' in client and 'details.TextWrapped = true' in client
assert '["Обычный"]' in client and '["Легендарный"]' in client and '["Мифический"]' in client
assert 'entry.Discovered and entry.Name or ""' in client, "Collection search must not reveal undiscovered species"
assert 'NestOverviewStats' in client and 'МОЁ ГНЕЗДО' in client
assert 'NestDisplayShortcut' in client and 'NestDecorShortcut' in client and 'NestBuildShortcut' in client
assert 'NestUpgradeShortcut' in client and 'refreshNestIncome = function()' in client
assert 'snapshot.IncomePerTick' in client and 'player:GetAttributeChangedSignal("CompanionCount")' in client
assert 'player:GetAttributeChangedSignal("Coins")' in client
assert 'nestPanel.Visible = false' in client and 'openDisplay()' in client and 'openDecor()' in client and 'openBuild()' in client
assert 'база %d%%' in client
assert 'local oddsText = ""' in client and 'entry.HatchChance' in client

profile_template = Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
assert 'CompanionIncomeRemainder = 0' in profile_template
assert 'StoredIncomeRemainder = 0' in profile_template
player_data = Path("src/ServerScriptService/Server/Services/PlayerDataService.lua").read_text()
progression = Path("src/ServerScriptService/Server/Services/ProgressionService.lua").read_text()
game_config = Path("src/ReplicatedStorage/Shared/Config/GameConfig.lua").read_text()
assert 'ProfilePersistence' in player_data
assert 'and "TEMPORARY" or "SAVED"' in player_data
assert 'player:GetAttribute("ProfilePersistence")' in client
assert 'Сохранение: ВКЛ' in client and 'Сохранение: ТЕСТ' in client
assert 'local FOLLOW_INTERVAL = 0.1' in companions
assert '* 4.2' in companions, "Active pets need more lateral spacing"
assert 'current:Lerp(target, 0.3)' in companions
assert 'current.LookVector:Dot(target.LookVector)' in companions

assert 'Players.PlayerAdded:Connect(bindPlayer)' in progression
assert 'EmeraldWilds = {' in biomes and 'EmeraldEgg' in biomes
assert 'EmeraldFox = 50' in biomes and 'GlowMoth = 32' in biomes and 'AncientSprout = 18' in biomes
assert 'emerald.Name = "EmeraldWilds"' in world
assert 'ZoneTravelPrompt' in world and 'EmeraldPortal' in world and 'ReturnPortal' in world
assert 'EmeraldFloatingFoundation' in world and 'EmeraldEgg' in world
assert 'EmeraldWilds = {' in eggs and 'spawnPositions = EGG_SPAWN_POSITIONS[biomeId]' in eggs
assert 'for biomeId, spawnPositions in pairs(EGG_SPAWN_POSITIONS) do' in eggs
assert 'local allowed, reason = self:CanEnterZone(player, zoneId)' in progression
assert 'character:PivotTo(CFrame.new(destination + Vector3.new(0, 4, 0)))' in progression
assert '{ Id = "EmeraldWilds", DisplayName = "Изумрудный лес", RequiredLevel = 5, RequiredQuest = nil }' in game_config

assert 'EmeraldTrialRunes = {}' in profile_template
assert 'EmeraldTrialRunes' in world and 'EmeraldRunePrompt' in world
assert 'Руна рощи' in world and 'Руна реки' in world and 'Руна рассвета' in world
assert 'profile.QuestProgress.EmeraldTrialRunes[runeId] = true' in progression
assert 'profile.CompletedQuests.emerald_trial = true' in progression
assert 'self:AddXP(player, 100)' in progression
assert 'EmeraldTrialProgress' in progression and 'EmeraldTrialCompleted' in progression
assert 'RequiredQuest = "emerald_trial"' in game_config
assert 'DisplayName = "Ледяные нагорья"' in game_config
assert 'BiomeTrialPanel' in client and 'updateBiomeTrialPanel' in client

assert 'root.Position - descendant.Parent.Position).Magnitude > descendant.MaxActivationDistance + 2' in progression
assert 'Vector3.new(0, 16, 520)' in world and 'Vector3.new(0, 11, -112)' in world

assert 'CurrentBiome' in client and 'ПРОБУЖДЕНО РУН' in client

# Frost Highlands: biome-specific egg table, collection gate, world content and trial.
assert 'FrostHighlands = {' in biomes and 'FrostEgg' in biomes
assert 'FrostFox = 60' in biomes and 'SnowOwl = 30' in biomes and 'GlacierBear = 10' in biomes
assert 'FrostFox = {' in Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
assert 'SnowOwl = {' in Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
assert 'GlacierBear = {' in Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()

companion_models = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
assert 'FrostFox = {' in companion_models and 'Kind = "Fox"' in companion_models
assert 'SnowOwl = {' in companion_models and 'Kind = "Owl"' in companion_models
assert 'GlacierBear = {' in companion_models and 'Kind = "Bear"' in companion_models
assert 'definition.Kind == "Owl"' in companion_models and 'definition.Kind == "Bear"' in companion_models
assert 'Id = "FrostCache"' in Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
assert 'Id = "AuroraGaze"' in Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
assert 'Id = "GlacierGuard"' in Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
assert 'ability.Id == "FrostCache"' in inventory
assert 'ability.Id == "AuroraGaze"' in inventory
assert 'ability.Id == "GlacierGuard"' in inventory
assert '{ Id = "FrostHighlands", DisplayName = "Ледяные нагорья", RequiredLevel = 12, RequiredQuest = "emerald_trial" }' in game_config
assert '{ Id = "Emberlands", DisplayName = "Пепельные земли", RequiredLevel = 22, RequiredQuest = "frost_trial" }' in game_config

assert 'FrostHighlands = {' in eggs and 'Vector3.new(-22, 20, 1020)' in eggs
assert '(player:GetAttribute("CurrentBiome") or "StarterIsland") ~= requiredZone' in eggs
assert 'ProgressionService:CanEnterZone(player, requiredZone)' in eggs
assert 'frost.Name = "FrostHighlands"' in world
assert 'FrostSnowTop' in world and 'FrostPineTrunk' in world and 'GlacierCrystal' in world
assert 'FrostRunePrompt' in world and 'Руна сияния' in world and 'Руна ледника' in world and 'Руна зимы' in world
assert 'FrostPortal' in world and 'FrostReturnPortal' in world
assert 'GlacierCauseway' in world and 'IceBridgeSegment_' in world
assert 'FrostEggOddsSign' in world and 'Снежный лис · 60%' in world
assert 'FrostTrialRunes = {}' in profile_template
assert 'profile.QuestProgress.FrostTrialRunes' in progression
assert 'profile.CompletedQuests.frost_trial = true' in progression
assert 'self:AddXP(player, 180)' in progression
assert 'FrostTrialProgress' in progression and 'FrostTrialCompleted' in progression
assert 'updateBiomeTrialPanel' in client and 'FrostTrialProgress' in client


assert 'for _, player in ipairs(Players:GetPlayers()) do' in progression
assert 'if boundPlayers[player] then return end' in progression
assert 'self:RefreshZoneUnlocks(player)' in progression
assert 'player:SetAttribute("ProgressionReady", true)' in progression
assert 'local visualOk, visualError = pcall(function()' in eggs
assert 'CompanionService:RefreshPlayer(player)' in eggs
assert 'local xpCallOk, xpResult = pcall(function()' in eggs
assert 'return ProgressionService:AddXP(player, 15)' in eggs
assert 'local xpAwarded = xpCallOk and xpResult == true' in eggs
assert 'local xpMessage = xpAwarded and " +15 опыта" or ""' in eggs
assert 'local xpMessage = xpOk and' not in eggs
assert 'Hatch companion visual refresh failed' in eggs

assert 'local function restoreDiscoveredSpecies(data)' in player_data
assert 'restoreDiscoveredSpecies(data)' in player_data
assert player_data.index('restoreDiscoveredSpecies(data)', player_data.index('local function publishProfile')) < player_data.index('player:SetAttribute("ProfileLoaded", true)')
assert 'discovered[companion.Id] = true' in player_data
assert 'CompanionCatalog[companion.Id]' in player_data

assert 'DiscoveredSpecies = {}' in profile_template
assert 'profile.DiscoveredSpecies[companion.Id] = true' in eggs
assert 'profile.DiscoveredSpecies[speciesId] = true' in book
assert 'Discovered = isDiscovered' in book
assert 'Discovered = count > 0' not in book
assert 'REQUEST_COOLDOWN' not in book, "Read-only collection must not throttle the first-play flow"
assert 'OwnedCount = count' in book, "Collection should still show current owned count"

assert 'if payload.Action ~= "Get" then' in inventory, "Read-only inventory snapshots must bypass cooldown"
assert 'REQUEST_COOLDOWN' in inventory, "Mutation cooldown must remain active"
assert 'GetAttributeChangedSignal("CompanionCount"):Connect(function()' in client
assert 'if inventoryPanel.Visible then' in client and 'if bookPanel.Visible then' in client
assert 'refreshingCompanionWindows = false' in client

assert 'local function bindPlayer(player)' in companions, "Companion service must bind early joiners"
assert 'Players.PlayerAdded:Connect(bindPlayer)' in companions
assert 'player.CharacterAdded:Connect(function()' in companions
assert 'local spawnRoot = character and character:FindFirstChild("HumanoidRootPart")' in companions
assert 'pet:PivotTo(spawnRoot.CFrame * CFrame.new(side, -2.2, behind) * CFrame.Angles(0, math.pi, 0))' in companions
assert 'CFrame.Angles(0, math.pi, 0)' in companions
assert '* 4.2' in companions
assert 'current:Lerp(target, 0.3)' in companions
assert 'local collectTween = TweenService:Create(' in eggs
assert 'collectTween:Play()' in eggs and 'respawnTween:Play()' in eggs
assert 'local EGG_SPAWN_POSITIONS = {' in eggs
assert 'ACTIVE_WORLD_EGGS = 3' in eggs
assert 'local shuffledSlots = {}' in eggs and 'shuffledSlots[swap]' in eggs
assert 'egg:SetAttribute("SpawnSlot", slot)' in eggs
assert 'local occupied = {}' in eggs and 'if not occupied[slot] then' in eggs
assert world.count('{x =') >= 9, "Egg grove should expose at least nine candidate spawn sites"
assert 'for slot = 1, #spawnPositions do' in eggs

assert companions.index('pet:PivotTo(spawnRoot.CFrame') < companions.index('task.spawn(function()', companions.index('function CompanionService:RefreshPlayer'))

assert 'player:GetAttributeChangedSignal("ProfileLoaded"):Connect(function()' in companions
assert 'for _, player in ipairs(Players:GetPlayers()) do' in companions
assert 'if player.Parent and player:GetAttribute("ProfileLoaded") then' in companions

assert 'local function bindPlayer(player)' in eggs, "EggService must bind loading players"
assert 'Players.PlayerAdded:Connect(bindPlayer)' in eggs
assert 'for _, player in ipairs(Players:GetPlayers()) do' in eggs
assert 'player:GetAttributeChangedSignal("ProfileLoaded"):Connect(syncWhenReady)' in eggs
assert 'if profile then syncAttributes(player, profile) end' in eggs
assert 'Players.PlayerRemoving:Connect(function(player)' in eggs
assert 'for index, candidate in ipairs(profile.EggInventory) do' in eggs, "Hatch should scan inventory"
assert 'hatchIndex, egg = index, candidate' in eggs
assert 'table.remove(profile.EggInventory, hatchIndex)' in eggs, "Hatch should consume selected egg"
assert 'function EggService:_HatchUnlocked(player, station)' in eggs
assert 'function EggService:Hatch(player, station)' in eggs
assert 'if self._hatching[player] then return end' in eggs
assert 'self._hatching[player] = nil' in eggs
assert 'local ok, err = pcall(function()' in eggs
assert 'type(geneticTrait.Name) ~= "string"' in eggs
assert 'type(definition.Name) ~= "string"' in eggs
assert 'type(definition.Income) ~= "number"' in eggs
assert 'Данные яйца повреждены. Яйцо сохранено' in eggs
assert eggs.index('type(geneticTrait.Name) ~= "string"') < eggs.index('table.remove(profile.EggInventory, hatchIndex)')

assert 'table.remove(profile.EggInventory, 1)' not in eggs, "Incubating first egg blocks other eggs"
assert 'Все яйца ещё инкубируются.' in eggs


health = Path("src/ServerScriptService/Server/World/WorldHealthCheck.lua").read_text()
assert 'function WorldHealthCheck:Check()' in health
for required in ['StarterSpawn', 'EggSpawnPoints', 'CollectEggPrompt', 'PlayerPlots', 'HatchStation', 'HatchPrompt', 'PlotGrass']:
    assert required in health, f"World health validation missing {required}"
assert 'WorldHealth", "READY"' in server
assert 'WorldHealth", "DEGRADED"' in server
assert 'WorldHealthError' in server and 'WorldHealthError' in client
assert 'remotes:GetAttribute("WorldHealth") == "DEGRADED"' in client

assert 'Vector3.new(18, 10, 1)' in world, "Welcome sign should have a readable front face"
assert 'Vector3.new(9, 5, 1)' in plots, "Personal nest signs should have a readable front face"
assert 'EggGroveWayfinding' in world
assert 'EggGroveSign' in world and 'NestDistrictSign' in world
assert 'GardenBase' in world and 'EggBeacon' in world
# Cylinder geometry: Roblox cylinders are X-axis aligned before rotation.
# A 90-degree Z rotation makes the X dimension the vertical thickness.
assert 'Vector3.new(0.5, 12, 12)' in world, "Egg garden platforms must be flat"
assert 'CFrame.new(grove.x, 10.4, grove.z) * CFrame.Angles(0, 0, math.rad(90))' in world
assert 'Vector3.new(1.4, 6, 6)' in world, "Egg pedestals must be horizontal"
assert 'Vector3.new(2, 13, 11)' in plots, "Nest bowl cylinder must be shallow"
assert 'Vector3.new(0.45, 6.8, 6.8)' in plots, "Breeding ring must be flat"
assert 'Vector3.new(0.55, 3.4, 3.4)' in plots, "Breeding parent pads must be flat"
assert 'CollectEggPrompt' in world and 'WorldEgg' in world
assert 'prompt.ActionText = "Вылупить"' in plots


def before(first, second, content=client):
    assert first in content, f"Missing: {first}"
    assert second in content, f"Missing: {second}"
    assert content.index(first) < content.index(second), f"Order incorrect: {first} must precede {second}"

before("local activeBuildPlacement = nil", 'buildRotateButton.Activated:Connect(')
before("local stopBuildPlacement", 'buildCancelButton.Activated:Connect(')
before("local buildRotation = 0", 'buildRotateButton.Activated:Connect(')
before("local buildHint, buildRotateButton, buildCancelButton, buildConfirmButton", 'buildHint = Instance.new(')
assert 'if payload.Action=="Get" then' in build_service
assert build_service.index('if payload.Action=="Get" then') < build_service.index('if payload.Action=="Place" or payload.Action=="Move" or payload.Action=="Remove" then')
assert 'Подойди к своему острову, чтобы строить.' in build_service
assert 'local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")' in build_service
assert 'if payload.Action=="Buy" then' in build_service
assert "stopBuildPlacement = function(reopen)" in client
assert "buildConfirmButton.Activated:Connect(" in client
assert 'buildConfirmButton.Visible = true' in client
assert 'Touch sets the desired position; confirmation is always explicit' in client
assert 'navScroll = Instance.new("ScrollingFrame")' in client
assert 'local modalPanels = {' in client
assert 'CloseAllWindows' in client
before('remoteFolder.Name = "NestRaidersRemotes"', 'builder:Build()', server)
assert 'ServiceError_' in server
assert 'remote.OnServerInvoke = function()' in server, "Uninitialized remotes must fail quickly"
assert 'Ok = false' in server and 'Message = "Система ещё загружается' in server
assert 'NestRaidersHUD' in watchdog
assert 'gui:SetAttribute("ClientReady", false)' in client
assert 'gui:SetAttribute("ClientReady", true)' in client
assert client.rindex('gui:SetAttribute("ClientReady", true)') > client.rindex('updateStats()')
assert 'hud:GetAttribute("ClientReady") == true' in watchdog
assert 'GetAttributeChangedSignal("ClientReady")' in watchdog
assert 'FirstPlayGuide' in client, "First-play onboarding missing"
assert 'FirstPlayTarget' in client, "Egg/hatch target highlight missing"
assert 'function firstPlayTarget()' in client
assert 'function updateFirstPlayGuide()' in client
assert 'WorldEgg' in client and 'HatchStation' in client
assert client.index('function updateFirstPlayGuide()') < client.index('gui:SetAttribute("ClientReady", true)')

assert 'if hasHud() then return end' not in watchdog


path = Path("NEST-RAIDERS.rbxlx")
if path.exists():
    root = ET.parse(path).getroot()
    assert root.tag == "roblox", "Rojo output must be a Roblox place XML"
    names = [
        (item.findtext('./Properties/string[@name="Name"]') or "")
        for item in root.findall(".//Item")
    ]
    assert "ClientBootstrap" in names, "Client HUD missing in built place"
    assert "BootRecovery" in names, "Recovery UI missing in built place"
    assert "Bootstrap" in names, "Server bootstrap missing in built place"
# Emberlands vertical slice: biome-specific eggs, heat/cooling volumes and HUD.
ember_biomes = Path("src/ReplicatedStorage/Shared/Config/BiomeCatalog.lua").read_text()
ember_companions = Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
heat_service = Path("src/ServerScriptService/Server/Services/HeatService.lua").read_text()
assert '{ Id = "Emberlands", DisplayName = "Пепельные земли", RequiredLevel = 22, RequiredQuest = "frost_trial" }' in game_config
assert 'EmberEgg' in ember_biomes and 'CinderFox = 60' in ember_biomes
assert 'MagmaWhelp = 30' in ember_biomes and 'AshPhoenix = 10' in ember_biomes
assert 'CinderFox = {' in ember_companions and 'MagmaWhelp = {' in ember_companions and 'AshPhoenix = {' in ember_companions
assert 'Id = "CinderHide"' in ember_companions and 'Id = "MagmaWard"' in ember_companions
assert 'Id = "PhoenixRenewal"' in ember_companions
assert 'Emberlands = {' in eggs and 'Vector3.new(-48, 16, 1520)' in eggs
assert 'Emberlands' in world and 'HeatZones' in world and 'CoolingSanctuary' in world
assert 'HeatPerSecond' in world and 'CoolingPerSecond' in world and 'CoolingZone' in world
assert 'EmberPortal' in world and 'EmberReturnPortal' in world
assert 'EmberCauseway' in world and 'EmberBridgeSegment_' in world
assert 'EmberEggOddsSign' in world and 'Угольный лис · 60%' in world
assert 'EmberCauseway' in world_health and 'EmberBridgeSegment_' in world_health
assert '"HeatService"' in server and 'function HeatService:Start()' in heat_service
assert 'TakeDamage' in heat_service and 'HeatPhoenixReady' in heat_service
assert 'HeatHideUntil' in inventory and 'HeatGuardUntil' in inventory and 'HeatPhoenixReady' in inventory
assert 'VolcanicHeatPanel' in client and 'ТЕМПЕРАТУРА' in client
assert 'FrostHighlands = "Ледяные нагорья · уровень 12 + испытание"' in world
assert 'Emberlands = "Пепельные земли · уровень 22 + испытание"' in world
assert 'CoolingZone' in world_health and 'HeatZones' in world_health



# Emberlands ashfall event: server-owned warnings, moving surges and persistent rewards.
ashfall = Path("src/ServerScriptService/Server/Services/AshfallService.lua").read_text()
profile_template = Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
player_data = Path("src/ServerScriptService/Server/Services/PlayerDataService.lua").read_text()
assert '"AshfallService"' in server and 'function AshfallService:Start()' in ashfall
assert 'WARNING_SECONDS = 20' in ashfall and 'SURGE_COUNT = 3' in ashfall
assert 'AshfallPhase' in ashfall and '"WARNING"' in ashfall and '"ERUPTION"' in ashfall
assert 'AshfallLavaSurge_' in ashfall and 'wave.Position = Vector3.new(0, 18.2, z)' in ashfall
assert 'self:_damageAt(z)' in ashfall and 'humanoid:TakeDamage(SURGE_DAMAGE)' in ashfall
assert 'root.Position.Z > 1500' in ashfall, "Lava surges must not damage players in the cooling sanctuary"
assert 'CollectAshCrystalPrompt' in ashfall and 'AshfallClaimedNodes[nodeKey]' in ashfall
assert 'LastAshfallClaimEventId' in ashfall and 'AshfallClaimedNodes' in ashfall
assert 'materials.AshCrystal' in ashfall and 'AshCrystal = 0' in profile_template
assert 'LastAshfallClaimEventId = ""' in profile_template and 'AshfallClaimedNodes = {}' in profile_template
assert 'player:SetAttribute("AshCrystals"' in player_data
assert 'AshfallEventPanel' in client and 'updateAshfallPanel' in client
assert 'Пепельные кристаллы:' in client and 'ИЗВЕРЖЕНИЕ ЧЕРЕЗ' in client


# Heart of Fire trial: persistent runes, individual boss encounter, dodge and one-time reward.
fire_trial = Path("src/ServerScriptService/Server/Services/FireTrialService.lua").read_text()
assert '"FireTrialService"' in server and 'function FireTrialService:Init()' in fire_trial
assert 'EmberTrialRunes = {}' in Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
assert 'EmberTrialBossHealth = 100' in Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
assert 'EmberTrialRunePrompt' in fire_trial and 'EmberTrialBossPrompt' in fire_trial
assert 'profile.CompletedQuests.ember_trial = true' in fire_trial
assert 'REWARD_XP = 250' in fire_trial and 'ProgressionService:AddXP(player, REWARD_XP)' in fire_trial
assert 'BOSS_WINDUP_SECONDS = 1.4' in fire_trial and 'BOSS_ATTACK_RADIUS = 23' in fire_trial
assert 'currentHumanoid:TakeDamage(BOSS_DAMAGE)' in fire_trial and 'EmberTrialBossWindup' in fire_trial
assert 'EmberTrialBossHealth' in client and 'EmberTrialBossWindup' in client
assert 'ИСПЫТАНИЕ ОГНЕННОГО СЕРДЦА' in client and 'ЗДОРОВЬЕ СТРАЖА:' in client
assert 'HeartOfFireTrial' in world and 'HeartOfFireGuardian' in world
assert 'EmberTrialRunePrompt' in world and 'EmberTrialBossPrompt' in world
assert 'EmberTrialRunePrompt' in world_health and 'EmberTrialBossPrompt' in world_health
assert 'BasaltTrialStep_' in world and 'Подъём к алтарю:' in world_health


# Crystal Realm: gated destination, mineable veins, saved shards, unique egg table and species.
crystal_mining = Path("src/ServerScriptService/Server/Services/CrystalMiningService.lua").read_text()
biomes = Path("src/ReplicatedStorage/Shared/Config/BiomeCatalog.lua").read_text()
companions = Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
assert '"CrystalMiningService"' in server and 'function CrystalMiningService:Init()' in crystal_mining
assert 'CrystalNodeCooldowns' in crystal_mining and 'materials.CrystalShard' in crystal_mining
assert 'CrystalShard = 0' in profile_template and 'CrystalNodeCooldowns = {}' in profile_template
assert 'player:SetAttribute("CrystalShards"' in player_data
assert 'CrystalRealm = {' in biomes and 'CrystalEgg' in biomes
assert 'PrismFox = {' in companions and 'CrystalDeer = {' in companions and 'AuroraDragon = {' in companions
assert 'CrystalRealm = {' in Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()
assert 'CrystalPortal' in world and 'CrystalReturnPortal' in world and 'CrystalSkyway' in world
assert 'CrystalVeins' in world and 'MineCrystalPrompt' in world
assert 'CrystalMiningPanel' in client and 'CrystalShards' in client
assert 'CrystalRealm' in world_health and 'Кристальные жилы:' in world_health
assert 'Enum.Material.Crystal' not in world and 'Enum.PartType.Crystal' not in world


# Crystal Prism Trial: ordered puzzle, per-player persistent boss, reward and next biome gate.
crystal_trial = Path("src/ServerScriptService/Server/Services/CrystalTrialService.lua").read_text()
assert '"CrystalTrialService"' in server and 'function CrystalTrialService:Init()' in crystal_trial
assert 'PRISM_SEQUENCE = { "Azure", "Rose", "Crown" }' in crystal_trial
assert 'table.clear(progress.CrystalTrialPrisms)' in crystal_trial
assert 'CrystalTrialPrisms = {}' in profile_template and 'CrystalTrialBossHealth = 160' in profile_template
assert 'CrystalTrialBossHealth' in crystal_trial and 'CrystalTrialBossWindup' in crystal_trial
assert 'REWARD_XP = 500' in crystal_trial and 'ProgressionService:AddXP(player, REWARD_XP)' in crystal_trial
assert 'profile.CompletedQuests.crystal_trial = true' in crystal_trial
assert 'CrystalPrismPrompt' in crystal_trial and 'CrystalTrialBossPrompt' in crystal_trial
assert 'PrismTrial' in world and '"PrismGem_" .. definition.Id' in world and 'Id = "Azure"' in world and 'Id = "Rose"' in world and 'Id = "Crown"' in world
assert '"PrismLightBeam_" .. index' in world and 'for index = 1, 2 do' in world and 'PrismGuardian' in world
assert 'CrystalTrialBossPrompt' in world and 'Лазурный → Розовый → Золотой' in world
assert 'AncientHeights' in game_config and 'RequiredLevel = 50, RequiredQuest = "crystal_trial"' in game_config
assert 'AncientHeightsPortal' in world and 'AncientReturnPortal' in world
assert 'AncientLanding' in world and 'AncientWelcomeSign' in world
assert 'CrystalTrialProgress' in client and 'CrystalTrialBossWindup' in client
assert 'ИСПЫТАНИЕ ПРИЗМЫ' in client and 'ХРАНИТЕЛЯ' in client
assert 'CrystalTrial' in world_health and 'AncientLanding' in world_health


# Ancient Heights: first explorable biome slice, its own egg table and follower species.
assert 'AncientHeights = {' in biomes and 'AncientEgg' in biomes
assert 'AncientStag = 55' in biomes and 'RootSprite = 30' in biomes and 'SkySerpent = 15' in biomes
assert 'AncientStag = {' in companions and 'RootSprite = {' in companions and 'SkySerpent = {' in companions
assert 'AncientHeights = {' in Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()
assert 'AncientHeights' in world and 'ElderCanopy' in world and 'ElderRuins' in world
assert 'AncientEggOddsSign' in world and 'Яйцо древнего древа' in world
assert 'AncientHeights' in world_health and 'Яйца Древних высот:' in world_health
ancient_models = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
for kind in ("AncientStag", "RootSprite", "SkySerpent"):
    assert f'Kind = "{kind}"' in ancient_models
    assert f'definition.Kind == "{kind}"' in ancient_models


# Ancient Heights harvesting: saved resource balance, per-player cooldowns and responsive HUD.
ancient_harvest = Path("src/ServerScriptService/Server/Services/AncientHarvestService.lua").read_text()
assert '"AncientHarvestService"' in server and 'function AncientHarvestService:Init()' in ancient_harvest
assert 'ElderwoodNodeCooldowns' in ancient_harvest and 'materials.Elderwood' in ancient_harvest
assert 'ProgressionService:CanEnterZone(player, "AncientHeights")' in ancient_harvest
assert 'Elderwood = 0' in profile_template and 'ElderwoodNodeCooldowns = {}' in profile_template
assert 'ElderwoodNodeId' in world and 'HarvestElderwoodPrompt' in world
assert 'AncientHarvestPanel' in client and 'Elderwood' in client
assert 'Древние корни:' in world_health


# Whispering Grove: secret traversal and a persistent one-time server reward.
ancient_secret = Path("src/ServerScriptService/Server/Services/AncientSecretService.lua").read_text()
assert '"AncientSecretService"' in server and 'function AncientSecretService:Init()' in ancient_secret
assert 'ancient_grove_secret' in ancient_secret and 'EconomyService:GrantCoins(player, 250' in ancient_secret
assert 'ProgressionService:AddXP(player, 150)' in ancient_secret
assert 'WhisperingGrove' in world and 'GroveStep_' in world and 'ElderHeartAltar' in world
assert 'ElderHeartPrompt' in world_health and 'Тайная тропа рощи:' in world_health


# Ancient Egg crafting: resource sink, exact recipe, capacity guard and server-side station validation.
ancient_crafting = Path("src/ServerScriptService/Server/Services/AncientCraftingService.lua").read_text()
assert '"AncientCraftingService"' in server and 'function AncientCraftingService:Init()' in ancient_crafting
assert 'ELDERWOOD_COST = 10' in ancient_crafting and 'MOONPETAL_COST = 5' in ancient_crafting
assert 'STARSHARD_COST = 3' in ancient_crafting and 'COIN_COST = 300' in ancient_crafting
assert 'profile.Materials.Moonpetal = moonpetals - MOONPETAL_COST' in ancient_crafting
assert 'profile.Materials.Starshard = starshards - STARSHARD_COST' in ancient_crafting
assert 'SetAttribute("Moonpetal", profile.Materials.Moonpetal)' in ancient_crafting
assert 'SetAttribute("Starshard", profile.Materials.Starshard)' in ancient_crafting
assert 'Не хватает лунных лепестков' in ancient_crafting and 'Не хватает звёздных осколков' in ancient_crafting
assert 'EGG_CAPACITY = 20' in ancient_crafting and 'profile.EggInventory' in ancient_crafting
assert 'ProgressionService:CanEnterZone(player, "AncientHeights")' in ancient_crafting
assert 'CraftAncientEggPrompt' in ancient_crafting and 'MaxActivationDistance + 2' in ancient_crafting
assert 'REQUEST_COOLDOWN_SECONDS = 1.5' in ancient_crafting and 'LAST_REQUEST_AT' in ancient_crafting
assert 'Id = EGG_ID' in ancient_crafting and 'BiomeId = "AncientHeights"' in ancient_crafting
assert 'profile.Materials.Elderwood = elderwood - ELDERWOOD_COST' in ancient_crafting
assert 'profile.Coins = coins - COIN_COST' in ancient_crafting
assert 'EggCount' in ancient_crafting and 'Elderwood' in ancient_crafting and 'Coins' in ancient_crafting
assert 'ElderwoodWorkshop' in world and 'AncientEggCraftingStation' in world
assert 'CraftAncientEggPrompt' in world and 'AncientEggRecipeSign' in world
assert 'ЯЙЦО: 10 эссенции · 5 лепестков' in world and '3 звёздных осколка · 300 монет' in world
assert 'АРТЕФАКТ: 4 лепестка' in world and '2 кристальных · 1 пепельный · 250 монет' in world
assert 'Нет мастерской создания древних яиц' in world_health


# Artifact crafting, saved collection, two equipment slots and passive-income bonus.
artifact_catalog = Path("src/ReplicatedStorage/Shared/Config/ArtifactCatalog.lua").read_text()
assert 'RootSigil' in artifact_catalog and 'MoonPendant' in artifact_catalog and 'StarPrism' in artifact_catalog
assert 'IncomeBonus = 0.03' in artifact_catalog and 'IncomeBonus = 0.06' in artifact_catalog and 'IncomeBonus = 0.10' in artifact_catalog
assert 'Artifacts = {}' in profile_template and 'EquippedArtifacts = {}' in profile_template
assert 'ArtifactCatalog' in inventory and 'payload.Action == "CraftArtifact"' in inventory
assert 'payload.Action == "EquipArtifact" or payload.Action == "UnequipArtifact"' in inventory
assert '#profile.EquippedArtifacts >= 2' in inventory and 'ArtifactInstanceId' in inventory
assert 'CrystalShard = 2' in inventory and 'AshCrystal = 1' in inventory
assert 'ProgressionService:CanEnterZone(player, "AncientHeights")' in inventory
assert 'Artifacts = artifacts' in inventory and 'MaxEquippedArtifacts = 2' in inventory
assert 'ArtifactCatalog' in economy and 'artifactBonus' in economy and 'total *= (1 + artifactBonus)' in economy
assert 'ArtifactsButton' in client and 'ArtifactsPanel' in client and 'CraftArtifact' in client
assert 'EquipArtifact' in client and 'UnequipArtifact' in client and 'artifactsPanel,' in client
assert 'artifactsPanel.Size = UDim2.new(0.92, 0, 0.82, 0)' in client
assert 'artifactsSize.MinSize = Vector2.new(280, 320)' in client
assert 'artifactsSize.MaxSize = Vector2.new(520, 620)' in client
assert 'artifactsList.Position = UDim2.fromOffset(14, 192)' in client
assert 'artifactsList.Size = UDim2.new(1, -28, 1, -206)' in client
for fixture_name, order in (
    ("artifactsTestButton", -6),
    ("researcherTestButton", -5),
    ("hunterTestButton", -4),
):
    assert f'{fixture_name}.LayoutOrder = {order}' in client
    assert f'{fixture_name}.Parent = artifactsList' in client
assert 'artifactsTestButton.Position = UDim2.fromOffset' not in client
assert 'researcherTestButton.Position = UDim2.fromOffset' not in client
assert 'hunterTestButton.Position = UDim2.fromOffset' not in client
assert 'АРТЕФАКТ' in world and '2 кристальных' in world and '1 пепельный' in world

# Artifact upgrade tiers and safe three-to-one merging.
assert 'artifact.Level = math.clamp(math.floor(tonumber(artifact.Level) or 1), 1, 6)' in inventory
assert 'payload.Action == "MergeArtifacts"' in inventory
assert 'type(payload.ArtifactInstanceIds) ~= "table" or #payload.ArtifactInstanceIds ~= 3' in inventory
assert 'selectedSet[instanceId]' in inventory and 'seenArtifactIds' in inventory
assert 'artifact.Id ~= first.Id' in inventory and 'targetLevel >= 6' in inventory
assert 'equippedSet[artifact.InstanceId]' in inventory
assert 'Level = targetLevel + 1' in inventory
assert 'Level = 1' in inventory and 'TierName = tierNames[level]' in inventory
assert 'IncomeBonus = incomeBonus' in inventory and 'total *= (1 + artifactBonus)' in economy
assert 'scaledBonus = (tonumber(definition.IncomeBonus) or 0) * (1 + (level - 1) * 0.25)' in economy
assert 'Action = "MergeArtifacts"' in client and 'ArtifactInstanceIds' in client
assert 'ОБЪЕДИНИТЬ ×3' in client and 'not artifact.Equipped' in client
assert 'tostring(artifact.DevOnly == true)' in client
assert 'local groupKey = tostring(artifact.Id) .. ":" .. tostring(level) .. ":" .. tostring(artifact.DevOnly == true)' in client
assert 'ArtifactMergeConfirm' in client and 'ОБЪЕДИНИТЬ ТРИ АРТЕФАКТА?' in client
assert 'Результат:' in client and 'УЛУЧШИТЬ' in client
assert 'СЛОТЫ:' in client and 'artifact.TierName' in client

# Gatherer artifact family: equipped relics increase server-side Elderwood and crystal yields.
artifact_bonus = Path("src/ServerScriptService/Server/Services/ArtifactBonusService.lua").read_text()
assert 'ArtifactBonusService' in Path("src/ServerScriptService/Server/Services/AncientHarvestService.lua").read_text()
assert 'ArtifactBonusService' in Path("src/ServerScriptService/Server/Services/CrystalMiningService.lua").read_text()
assert 'function ArtifactBonusService:GetGatherBonus(profile)' in artifact_bonus
assert 'function ArtifactBonusService:ApplyGatherBonus(profile, baseAmount, rollValue)' in artifact_bonus
assert 'MAX_GATHER_BONUS = 0.50' in artifact_bonus
assert 'definition.GatherBonus' in artifact_bonus and 'profile.EquippedArtifacts' in artifact_bonus
assert 'RootHarvester' in artifact_catalog and 'MoonForager' in artifact_catalog and 'StarProspector' in artifact_catalog
assert 'GatherBonus = 0.05' in artifact_catalog and 'GatherBonus = 0.10' in artifact_catalog and 'GatherBonus = 0.15' in artifact_catalog
assert 'Weight = 36' in artifact_catalog and 'Weight = 18' in artifact_catalog and 'Weight = 6' in artifact_catalog
assert 'Weight = 12' in artifact_catalog and 'Weight = 6' in artifact_catalog and 'Weight = 2' in artifact_catalog
assert 'FieldJournal' in artifact_catalog and 'MoonAtlas' in artifact_catalog and 'StarCompass' in artifact_catalog
assert 'ResearchBonus = 0.05' in artifact_catalog and 'ResearchBonus = 0.10' in artifact_catalog and 'ResearchBonus = 0.15' in artifact_catalog
assert 'Weight = 6' in artifact_catalog and 'Weight = 3' in artifact_catalog and 'Weight = 1' in artifact_catalog
assert 'HunterTrophy' in artifact_catalog and 'MoonTracker' in artifact_catalog and 'HunterCrown' in artifact_catalog
assert 'HatchBonus = 0.05' in artifact_catalog and 'HatchBonus = 0.10' in artifact_catalog and 'HatchBonus = 0.15' in artifact_catalog
assert 'function ArtifactBonusService:GetResearchBonus(profile)' in artifact_bonus
assert 'function ArtifactBonusService:ApplyResearchBonus(profile, baseAmount, rollValue)' in artifact_bonus
assert 'MAX_RESEARCH_BONUS = 0.50' in artifact_bonus
assert 'definition.ResearchBonus' in artifact_bonus
assert 'ApplyGatherBonus(profile, baseAmount)' in ancient_harvest
assert 'gatherBonus > 0' in ancient_harvest and 'артефакт: +%d дополнительно (средний бонус +%d%%)' in ancient_harvest
assert 'local amount, gatherBonus, extraMaterials = ArtifactBonusService:ApplyGatherBonus(profile, baseAmount)' in ancient_harvest
crystal_mining = Path("src/ServerScriptService/Server/Services/CrystalMiningService.lua").read_text()
assert 'ApplyGatherBonus(profile, baseAmount)' in crystal_mining
assert 'gatherBonus > 0' in crystal_mining and 'артефакт: +%d дополнительно (средний бонус +%d%%)' in crystal_mining
assert 'amount, gatherBonus, extraMaterials = ArtifactBonusService:ApplyGatherBonus(profile, baseAmount)' in crystal_mining
assert 'NODE_COOLDOWN_SECONDS = 180' in ancient_harvest and 'NODE_COOLDOWN_SECONDS = 180' in crystal_mining
assert 'CurrentBiome") ~= "AncientHeights"' in ancient_harvest
assert 'CurrentBiome") ~= "CrystalRealm"' in crystal_mining
assert 'GatherBonus = math.min(0.50' in inventory
assert 'ResearchBonus = math.min(0.50' in inventory
assert 'EquippedIncomeBonus' in inventory and 'EquippedGatherBonus' in inventory and 'EquippedResearchBonus' in inventory
assert 'return math.clamp(total, 0, 0.20)' in inventory
assert 'EquippedIncomeBonus' in client and 'GatherBonus' in client and 'ResearchBonus' in client
assert 'ДОХОД +%d%%' in client and 'ДОБЫЧА +%d%%' in client and 'ОПЫТ +%d%%' in client and 'ОХОТА +%d%%' in client
assert 'Добыча +%d%%' in client and 'Опыт +%d%%' in client

# The collection summary itself must render all four server-calculated equipped effects.
artifact_summary_start = client.index('artifactsSlots.Text = string.format("СЛОТЫ:')
artifact_summary_end = client.index('    if #artifacts == 0 then', artifact_summary_start)
artifact_summary = client[artifact_summary_start:artifact_summary_end]
for summary_field in (
    "EquippedIncomeBonus",
    "EquippedGatherBonus",
    "EquippedResearchBonus",
    "EquippedHatchBonus",
):
    assert summary_field in artifact_summary, f"Missing {summary_field} in artifact collection summary"
for summary_label in ("ДОХОД +%d%%", "ДОБЫЧА +%d%%", "ОПЫТ +%d%%", "ОХОТА +%d%%"):
    assert summary_label in artifact_summary, f"Missing {summary_label} in artifact collection summary"
assert artifact_summary.count("math.floor(((data and data.Equipped") == 4

# Ancient Tree Temple: walkable side-island, ordered runes, personal treasure claim and objective HUD.
ancient_temple = Path("src/ServerScriptService/Server/Services/AncientTempleService.lua").read_text()
assert '"AncientTempleService"' in server and 'function AncientTempleService:Init()' in ancient_temple
assert 'AncientTempleRunes = {}' in profile_template and 'AncientTempleRunes' in ancient_temple
assert 'SEQUENCE = { "Root", "River", "Dawn" }' in ancient_temple
assert 'table.clear(sequence)' in ancient_temple and 'sequenceCount(sequence)' in ancient_temple
assert 'ProgressionService:CanEnterZone(player, "AncientHeights")' in ancient_temple
assert 'descendant.MaxActivationDistance' in ancient_temple and 'chestPrompt.MaxActivationDistance' in ancient_temple
assert 'CurrentBiome") ~= "AncientHeights"' in ancient_temple
assert 'distance + 2' in ancient_temple
assert 'profile.CompletedQuests.ancient_temple_trial = true' in ancient_temple
assert 'REWARD_COINS = 500' in ancient_temple and 'REWARD_XP = 300' in ancient_temple
assert 'REWARD_ELDERWOOD = 20' in ancient_temple and 'ancient_temple_trial' in ancient_temple
assert 'AncientTreeTemple' in world and 'TempleSanctuaryFloor' in world and 'TempleCauseway' in world
assert 'AncientTempleRunePrompt' in world and 'AncientTempleChestPrompt' in world
assert 'КОРНИ → РЕКА → РАССВЕТ' in world and 'Сундук Сердца рощи' in world
assert 'Нет пола Храма Древнего древа' in world_health and 'Руны храма:' in world_health
assert 'AncientTempleProgress' in client and 'AncientTempleCompleted' in client
assert 'ХРАМ ДРЕВНЕГО ДРЕВА' in client and 'AncientTempleProgress' in client


# Ancient Temple Guardian: persistent solo boss combat, dodge telegraph and exclusive companion reward.
ancient_boss = Path("src/ServerScriptService/Server/Services/AncientTempleBossService.lua").read_text()
companion_catalog = Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
companion_service = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
collection_service = Path("src/ServerScriptService/Server/Services/CollectionBookService.lua").read_text()
assert '"AncientTempleBossService"' in server and 'function AncientTempleBossService:Init()' in ancient_boss
assert 'AncientTempleBossHealth = 240' in profile_template and 'AncientTempleBossHealth' in ancient_boss
assert 'BOSS_MAX_HEALTH = 240' in ancient_boss and 'PLAYER_HIT_DAMAGE = 24' in ancient_boss
assert 'Id = "VineSlam"' in ancient_boss and 'Id = "RootWave"' in ancient_boss
assert 'Damage = 30' in ancient_boss and 'Damage = 18' in ancient_boss
assert 'WindupSeconds = 1.8' in ancient_boss and 'WindupSeconds = 1.25' in ancient_boss
assert 'humanoid:TakeDamage(attack.Damage)' in ancient_boss and 'AncientTempleBossWindup' in ancient_boss
assert 'CompletedQuests.ancient_temple_trial' in ancient_boss
assert 'CompletedQuests.ancient_temple_boss = true' in ancient_boss
assert 'REWARD_COMPANION_ID = "HeartwoodGuardian"' in ancient_boss
assert 'HeartwoodGuardian = {' in companion_catalog and 'BossExclusive = true' in companion_catalog
assert 'Kind = "HeartwoodGuardian"' in companion_service and 'definition.Kind == "HeartwoodGuardian"' in companion_service
assert 'BossExclusive = definition.BossExclusive == true' in collection_service
assert 'BossExclusive' in inventory and 'не участвует в разведении' in inventory
assert 'entry.BossExclusive' in client and 'AncientTempleBossHealth' in client
assert 'AncientTempleBossPrompt' in world and 'GuardianHeartCore' in world
assert 'Нет Стража Сердца Древа' in world_health
assert 'GuardianWindupBurst' in world and 'ParticleEmitter' in world_health
assert 'Id = "ThornBurst"' in ancient_boss and 'Phase = 2' in ancient_boss
assert 'Damage = 22' in ancient_boss and 'Radius = 32' in ancient_boss and 'WindupSeconds = 2' in ancient_boss
assert 'AncientTempleBossPhase' in ancient_boss and 'BOSS_MAX_HEALTH / 2' in ancient_boss
assert 'grantGuardianTrophy' in ancient_boss and 'Category = "AncientTemple"' in ancient_boss
assert 'EnvironmentDecorations' in plots
assert 'GardenTree_NW' in plots and 'GardenTree_NE' in plots and 'GardenTree_SW' in plots and 'GardenTree_SE' in plots
assert 'FlowerBed_W' in plots and 'FlowerBed_E' in plots and 'FlowerBed_S' in plots
assert 'GardenPathStone_' in plots and 'part.CanCollide = false' in plots
assert 'NestLanternPole' in plots and 'WarmGardenLight' in plots
assert 'GardenCrystalGlow' in plots and 'LevelThreeFlower' in plots
island_styles = Path("src/ReplicatedStorage/Shared/Config/IslandStyleCatalog.lua").read_text()
decor_service = Path("src/ServerScriptService/Server/Services/NestDecorService.lua").read_text()
assert 'IslandStyleCatalog' in plots and 'PlotService:ApplyIslandStyle' in plots
assert 'ArcanePrism_' in plots and 'AncientColumn_' in plots and 'RoyalPost_' in plots
assert all(style in island_styles for style in ['Meadow', 'Arcane', 'Ancient', 'Royal'])
assert 'IslandStyle = "Meadow"' in profile_template
assert 'Action == "SetStyle"' in decor_service
assert 'definition.UnlockLevel' in decor_service and 'nest.IslandStyle = styleId' in decor_service
assert 'CurrentStyle = currentStyle' in decor_service and 'Styles = styles' in decor_service
assert 'СТИЛЬ ТВОЕГО ОСТРОВА' in client and 'КАТАЛОГ УКРАШЕНИЙ' in client
assert 'Action = "SetStyle", StyleId = style.Id' in client

assert 'ApplyNestLevel(player, profile.Nest.Level or 1)' in plots
assert 'PlotService:ApplyContestTrophies(player)' in ancient_boss
assert 'AncientTemple = "СЕРДЦЕ ДРЕВА"' in plots and 'СЕРДЦЕ ДРЕВА' in plots
assert 'TweenService' in client and 'playGuardianTelegraph' in client
assert 'GuardianWindupBurst' in client and 'AncientTempleBossPhase' in client
assert 'ШИПЫ ДРЕВА! ОТОЙДИ ОТ СТРАЖА!' in client
assert 'Size = Vector3.new(4, 4, 2)' in client
assert 'Шипы Древа пронзили арену!' in ancient_boss
assert 'TweenService = game:GetService("TweenService")' in ancient_boss
assert 'playGuardianAttackAnimation(attack.Id)' in ancient_boss
assert 'GuardianArm_-1' in ancient_boss and 'GuardianArm_1' in ancient_boss
assert 'GuardianBranch_-1' in ancient_boss and 'GuardianBranch_1' in ancient_boss
assert 'Id = "VineSlam"' in ancient_boss and 'Id = "RootWave"' in ancient_boss and 'Id = "ThornBurst"' in ancient_boss
assert 'local function playGuardianVictoryEffect()' in client
assert 'burst:Emit(84)' in client and 'AncientTempleBossCompleted' in client
assert 'Нет анимируемой части Стража:' in world_health
assert '"GuardianArm_" .. side' in world and '"GuardianBranch_" .. side' in world
assert '"GuardianBody"' in world and '"GuardianHead"' in world
assert 'GroveCacheRune_' in world and 'WhisperingGroveCache' in world
assert 'GroveCacheRunePrompt' in world and 'WhisperingGroveCachePrompt' in world
assert 'ЛУНА → ЛИСТ → РОСА → ЗВЕЗДА' in world
assert 'Нет подсказки к четырём рунам тайника рощи' in world_health
assert 'GROVE_RUNE_ORDER = { "Moon", "Leaf", "Dew", "Star" }' in grove_secret
assert 'profile.QuestProgress.GroveCacheRunes' in grove_secret
assert 'whispering_grove_cache' in grove_secret and 'Moonpetal' in grove_secret
assert 'EconomyService:GrantCoins(player, 400' in grove_secret
assert 'ProgressionService:AddXP(player, 200)' in grove_secret
assert 'WhisperingGroveRuneProgress' in client and 'WhisperingGroveCacheOpened' in client
assert 'СЕКРЕТ РОЩИ: РУНЫ %d / 4' in client
assert 'Whispering Grove four-rune cache' not in client
assert 'GroveCacheRunes = {}' in profile_template and 'Moonpetal = 0' in profile_template
assert 'Нет тайника четырёх рун в Шепчущей роще' in world_health
assert 'Руны тайника рощи:' in world_health
assert 'ForgottenHeartCave' in world and 'ForgottenCaveBridge' in world
assert 'ForgottenCaveFloor' in world and 'CaveStalactite_' in world
assert '"CaveCrystal_" .. definition.Id' in world and 'Id = "Root"' in world and 'Id = "River"' in world and 'Id = "Dawn"' in world
assert 'КОРНИ → РЕКА → РАССВЕТ' in world
assert 'ForgottenCaveChestPrompt' in world
assert 'CRYSTAL_ORDER = { "Root", "River", "Dawn" }' in ancient_cave
assert 'ForgottenCaveCrystals' in ancient_cave and 'forgotten_cave_cache' in ancient_cave
assert 'Materials.Starshard' in ancient_cave
assert 'GrantCoins(player, 600' in ancient_cave and 'AddXP(player, 300)' in ancient_cave
assert 'ForgottenCaveCrystalProgress' in ancient_cave and 'ForgottenCaveCacheOpened' in ancient_cave
assert 'AncientCaveService' in server
assert 'ForgottenCaveCrystals = {}' in profile_template and 'Starshard = 0' in profile_template
assert 'ForgottenCaveCrystalProgress' in client and 'ForgottenCaveCacheOpened' in client
assert 'ПЕЩЕРА: КРИСТАЛЛЫ %d / 3' in client
assert 'Нет моста или пола пещеры забытого сердца' in world_health
assert 'Кристаллы пещеры: %d из 3' in world_health
assert 'Нет сокровищницы забытого сердца' in world_health
assert 'ForgottenCaveEggOddsSign' in world and 'Нет таблицы вероятностей яйца забытого сердца' in world_health
assert 'ForgottenCaveEgg' in biome_catalog
assert 'CaveGlimmerbat = 65' in biome_catalog and 'CrystalProwler = 25' in biome_catalog and 'HeartWisp = 10' in biome_catalog
assert 'Id = "CaveGlimmerbat"' in companion_catalog and 'EggId = "ForgottenCaveEgg"' in companion_catalog
assert 'Id = "CrystalProwler"' in companion_catalog and 'Id = "HeartWisp"' in companion_catalog
assert 'Kind = "CaveGlimmerbat"' in companion_service and 'Kind = "CrystalProwler"' in companion_service and 'Kind = "HeartWisp"' in companion_service
assert 'BatEarLeft' in companion_service and 'CrystalCrest' in companion_service and 'HeartWisp' in companion_service
assert 'Id = "ForgottenCaveEgg"' in ancient_cave and 'Source = "ForgottenCaveCache"' in ancient_cave
assert 'player:SetAttribute("EggCount", #profile.EggInventory)' in ancient_cave
assert 'local function chooseCompanion(eggId, profile)' in Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()

assert 'ForgottenHeartBossService' in server
assert 'ForgottenHeartGuardian' in companion_catalog
assert 'BossExclusive = true' in companion_catalog and 'AcquisitionBiome = "Пещера забытого сердца"' in companion_catalog
assert 'ForgottenHeartBossHealth = 360' in profile_template
assert 'ForgottenHeartBossGuardian' not in companion_catalog
assert 'ForgottenHeartBossPrompt' in world and 'ForgottenHeartBossArena' in world and 'ForgottenHeartBossSign' in world
assert 'Нет арены или взаимодействия с Хранителем забытого сердца' in world_health
assert 'ForgottenHeartBossHealth' in forgotten_boss and 'MAX_HEALTH = 360' in forgotten_boss
assert 'Id = "CrystalSlam"' in forgotten_boss and 'Id = "EchoPulse"' in forgotten_boss and 'Id = "ShardRain"' in forgotten_boss
assert 'Pattern = "Target"' in forgotten_boss and 'Pattern = "Boss"' in forgotten_boss and 'Pattern = "Triple"' in forgotten_boss
assert 'forgotten_cave_cache' in forgotten_boss and 'forgotten_heart_boss' in forgotten_boss
assert 'TargetUserId' in forgotten_boss and 'ForgottenHeartAttackWarning' in client
assert 'ForgottenHeartBossUnlocked' in client and 'ForgottenHeartBossHealth' in client
assert 'ХРАНИТЕЛЬ ЗАБЫТОГО СЕРДЦА' in client and 'КРИСТАЛЬНЫЙ ДОЖДЬ' in client
assert 'ForgottenHeartGuardian' in companion_service and 'ChestHeart' in companion_service
assert 'AcquisitionBiome' in collection_book
assert 'ForgottenHeartArenaCrystal_' in world and 'CrystalCore' in world and 'CrystalShard' in world
assert 'bossArenaCrystalCount ~= 8' in world_health
assert 'playForgottenBossTelegraph' in client and 'CrystalSlam' in client and 'EchoPulse' in client and 'ShardRain' in client
assert 'breakForgottenBossArenaCrystals' in client and 'createForgottenBossDebris' in client
assert 'playForgottenBossPhaseTwo' in client and 'playForgottenBossVictory' in client
assert 'showForgottenHeartRewardReveal' in client and 'ЗАБРАТЬ НАГРАДУ' in client
assert 'ForgottenHeartBossRewardReveal' in forgotten_boss and 'ForgottenHeartBossRewardReveal' in client
assert 'forgottenBossArmBaseCache' in client
assert 'ForgottenHeartBossHitPulse' in forgotten_boss and 'ForgottenHeartBossDamagePulse' in forgotten_boss
assert 'playForgottenBossHitReaction' in client and 'ForgottenHeartDamageFlash' in client
assert 'ForgottenHeartBossCameraShake' in client and 'requestForgottenBossCameraShake' in client
assert 'createForgottenBossDebris = function' in client
assert 'warningColor = attack.Id == "CrystalSlam"' in forgotten_boss
assert 'Color3.fromRGB(183, 139, 255)' in forgotten_boss and 'Color3.fromRGB(255, 145, 207)' in forgotten_boss
assert 'showForgottenBossDamageNumber' in client and 'ForgottenHeartDamageNumber' in client
assert 'if lastForgottenBossHealth == nil then' in client
assert 'TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)' in client
assert 'Size = UDim2.fromScale(caveBossHealth / 360, 1)' in client

# Unified material inventory: profile load publishes every saved resource and UI binds all balances.
assert 'MaterialsInventoryButton' in client and 'local menuButtons = {' in client and 'materialsButton, artifactsButton, bondJournalButton, profileButton' in client
assert 'MaterialsInventoryPanel' in client and 'local materialDefinitions = {' in client
for material_attribute in ("Elderwood", "Moonpetal", "Starshard", "CrystalShards", "AshCrystals"):
    assert f'Attribute = "{material_attribute}"' in client
    assert f'GetAttributeChangedSignal(definition.Attribute)' in client
for saved_material, published_attribute in (
    ("Elderwood", "Elderwood"),
    ("Moonpetal", "Moonpetal"),
    ("Starshard", "Starshard"),
):
    assert f'materials.{saved_material}' in Path("src/ServerScriptService/Server/Services/PlayerDataService.lua").read_text()
    assert f'SetAttribute("{published_attribute}"' in Path("src/ServerScriptService/Server/Services/PlayerDataService.lua").read_text()
assert 'materialsPanel, }' not in client
assert 'materialsPanel,' in client[client.index('local modalPanels = {'):client.index('local closingOtherPanels')]

# Gatherer artifact balance invariants: catalog weights, per-level scaling and caps.
artifact_catalog = Path("src/ReplicatedStorage/Shared/Config/ArtifactCatalog.lua").read_text()
artifact_bonus = Path("src/ServerScriptService/Server/Services/ArtifactBonusService.lua").read_text()
inventory_service = Path("src/ServerScriptService/Server/Services/InventoryService.lua").read_text()
gatherer_definitions = {
    "RootHarvester": (0.05, 12),
    "MoonForager": (0.10, 6),
    "StarProspector": (0.15, 2),
}
for artifact_id, (base_bonus, weight) in gatherer_definitions.items():
    match = re.search(
        rf'{artifact_id} = \{{.*?GatherBonus = ([0-9.]+), Weight = (\d+),',
        artifact_catalog,
        re.S,
    )
    assert match, f"Missing gatherer catalog entry: {artifact_id}"
    assert float(match.group(1)) == base_bonus
    assert int(match.group(2)) == weight

all_weights = [int(value) for value in re.findall(r'Weight = (\d+)', artifact_catalog)]
assert sum(all_weights) == 100
assert sum(weight for _, weight in gatherer_definitions.values()) == 20
assert 'local MAX_GATHER_BONUS = 0.50' in artifact_bonus
assert 'local level = math.clamp(math.floor(tonumber(artifact.Level) or 1), 1, 6)' in artifact_bonus
assert '1 + (level - 1) * 0.25' in artifact_bonus
assert 'return math.clamp(totalBonus, 0, MAX_GATHER_BONUS)' in artifact_bonus
assert 'math.clamp(total, 0, 0.50)' in inventory_service

for artifact_id, (base_bonus, _) in gatherer_definitions.items():
    level_bonuses = [base_bonus * (1 + (level - 1) * 0.25) for level in range(1, 7)]
    assert level_bonuses[0] == base_bonus
    assert level_bonuses[-1] == base_bonus * 2.25
    assert all(level_bonuses[index] < level_bonuses[index + 1] for index in range(5))
assert min(0.50, 0.3375 + 0.225) == 0.50
assert min(0.50, 0.3375 + 0.3375) == 0.50

researcher_definitions = {
    "FieldJournal": (0.05, 6),
    "MoonAtlas": (0.10, 3),
    "StarCompass": (0.15, 1),
}
for artifact_id, (base_bonus, weight) in researcher_definitions.items():
    match = re.search(
        rf'{artifact_id} = \{{.*?ResearchBonus = ([0-9.]+), Weight = (\d+),',
        artifact_catalog,
        re.S,
    )
    assert match, f"Missing researcher catalog entry: {artifact_id}"
    assert float(match.group(1)) == base_bonus
    assert int(match.group(2)) == weight
assert sum(weight for _, weight in researcher_definitions.values()) == 10
assert sum(weight for _, weight in gatherer_definitions.values()) == 20
assert sum(weight for _, weight in researcher_definitions.values()) + sum(weight for _, weight in gatherer_definitions.values()) == 30
assert 'local MAX_RESEARCH_BONUS = 0.50' in artifact_bonus

hunter_definitions = {
    "HunterTrophy": (0.05, 6),
    "MoonTracker": (0.10, 3),
    "HunterCrown": (0.15, 1),
}
for artifact_id, (base_bonus, weight) in hunter_definitions.items():
    match = re.search(
        rf'{artifact_id} = \{{.*?HatchBonus = ([0-9.]+), Weight = (\d+),',
        artifact_catalog,
        re.S,
    )
    assert match, f"Missing Hunter catalog entry: {artifact_id}"
    assert float(match.group(1)) == base_bonus
    assert int(match.group(2)) == weight
assert sum(weight for _, weight in hunter_definitions.values()) == 10
assert sum(weight for _, weight in gatherer_definitions.values()) == 20
assert sum(weight for _, weight in researcher_definitions.values()) == 10
assert sum(weight for _, weight in hunter_definitions.values()) + sum(weight for _, weight in researcher_definitions.values()) + sum(weight for _, weight in gatherer_definitions.values()) == 40
assert 'local MAX_HATCH_BONUS = 0.30' in artifact_bonus
assert 'function ArtifactBonusService:GetHatchBonus(profile)' in artifact_bonus
assert 'function ArtifactBonusService:ChooseHatchSpecies(profile, speciesWeights, rollValue)' in artifact_bonus
assert 'function ArtifactBonusService:GetHatchSpeciesChance(profile, speciesWeights, speciesId)' in artifact_bonus
assert 'local function buildHatchWeightEntries(profile, speciesWeights)' in artifact_bonus
assert 'buildHatchWeightEntries(profile, speciesWeights)' in artifact_bonus
assert 'return entry.AdjustedWeight / adjustedTotal, entry.Weight / baseTotal, bonus' in artifact_bonus
world_builder = Path("src/ServerScriptService/Server/World/WorldBuilder.lua").read_text()
assert world_builder.count("БАЗА · БЕЗ ОХОТНИКА") >= 5
assert 'HATCH_RARITY_RANK' in artifact_bonus
assert 'HATCH_RARITY_RANK[definition.Rarity] or 1' in artifact_bonus
assert 'entry.Rank == highestRank' in artifact_bonus
assert 'adjustedWeight *= (1 + bonus)' in artifact_bonus
assert 'return entry.Id, bonus, baseChance, adjustedChance, entry.Rank == highestRank' in artifact_bonus

egg_service = Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()
assert 'ArtifactBonusService:ChooseHatchSpecies(profile, eggDefinition.SpeciesWeights, math.random())' in egg_service
assert 'definition, hatchBonus, baseTopChance, boostedTopChance = chooseCompanion(egg.Id or "MeadowEgg", profile)' in egg_service
assert 'local hunterMessage = hatchBonus > 0 and string.format(' in egg_service
assert 'высшая редкость %.1f%% → %.1f%%' in egg_service
hatch_selection = egg_service[egg_service.index('    local definition\n    local geneticTrait'):egg_service.index('    -- Validate everything needed for the pet')]
assert hatch_selection.index('if egg.Origin == "Breeding" then') < hatch_selection.index('definition, hatchBonus, baseTopChance, boostedTopChance = chooseCompanion')
assert 'definition, hatchBonus, baseTopChance, boostedTopChance = chooseCompanion(egg.Id or "MeadowEgg", profile)' in hatch_selection

assert 'HatchBonus = math.min(0.30' in inventory_service
assert 'EquippedHatchBonus' in inventory_service
assert 'payload.Action == "DevSeedHunterArtifacts"' in inventory_service
assert 'payload.Action == "DevSimulateHatchBonus"' in inventory_service
assert 'local simulationRandom = Random.new(446)' in inventory_service
assert 'local samplesPerEgg = 1000' in inventory_service
assert 'ArtifactBonusService:ChooseHatchSpecies(' in inventory_service
assert 'profile, eggDefinition.SpeciesWeights, roll)' in inventory_service
assert 'baselineProfile, eggDefinition.SpeciesWeights, roll)' in inventory_service
assert 'HunterArtifactTestButton' in client
assert 'Action = "DevSeedHunterArtifacts"' in client
assert 'HunterSimulationButton' in client
assert 'Action = "DevSimulateHatchBonus"' in client
assert 'EquippedHatchBonus' in client and 'ОХОТА +%d%%' in client and 'Охота +%d%%' in client
assert 'ТЕСТ: 7000 ВЫЛУПЛЕНИЙ БЕЗ НАГРАД' in client
assert 'local hunterMessage = hatchBonus > 0 and string.format(' in egg_service

biome_catalog = Path("src/ReplicatedStorage/Shared/Config/BiomeCatalog.lua").read_text()
companion_catalog = Path("src/ReplicatedStorage/Shared/Config/CompanionCatalog.lua").read_text()
rarity_rank = {
    "Обычный": 1,
    "Необычный": 2,
    "Редкий": 3,
    "Эпический": 4,
    "Легендарный": 5,
    "Мифический": 6,
}
companion_rarities = dict(re.findall(
    r'^\s{4}(\w+)\s*=\s*\{.*?\bRarity\s*=\s*"([^"]+)"',
    companion_catalog,
    re.M | re.S,
))
egg_tables = re.findall(
    r'(\w+)\s*=\s*\{\s*Id\s*=\s*"[^"]+",\s*Name\s*=\s*"[^"]+",\s*Rarity\s*=\s*"[^"]+",\s*SpeciesWeights\s*=\s*\{(.*?)\},\s*\},',
    biome_catalog,
    re.S,
)
assert len(egg_tables) == 7, f"Expected seven natural biome egg tables, found {len(egg_tables)}"
for egg_id, weight_source in egg_tables:
    weights = {species: int(weight) for species, weight in re.findall(r'(\w+)\s*=\s*(\d+)', weight_source)}
    assert weights, f"No species weights found for {egg_id}"
    assert all(species in companion_rarities for species in weights), f"Unknown species in {egg_id}"
    ranks = {species: rarity_rank[companion_rarities[species]] for species in weights}
    highest_rank = max(ranks.values())
    base_total = sum(weights.values())
    base_top_weight = sum(weight for species, weight in weights.items() if ranks[species] == highest_rank)
    base_chance = base_top_weight / base_total
    for bonus in (0.05, 0.10, 0.15, 0.30):
        adjusted_weights = {
            species: weight * (1 + bonus if ranks[species] == highest_rank else 1)
            for species, weight in weights.items()
        }
        adjusted_total = sum(adjusted_weights.values())
        adjusted_chance = base_top_weight * (1 + bonus) / adjusted_total
        assert adjusted_chance > base_chance, f"Hunter bonus did not improve {egg_id} top-tier odds"
        assert adjusted_chance < 1.0
        assert abs(sum(weight / adjusted_total for weight in adjusted_weights.values()) - 1.0) < 1e-9
        for species, weight in weights.items():
            base_species_chance = weight / base_total
            adjusted_species_chance = adjusted_weights[species] / adjusted_total
            if ranks[species] == highest_rank:
                assert adjusted_species_chance > base_species_chance
            else:
                assert adjusted_species_chance < base_species_chance

hunter_sim_start = inventory_service.index('if payload.Action == "DevSimulateHatchBonus" then')
hunter_sim_end = inventory_service.index('if payload.Action == "Get" then', hunter_sim_start)
hunter_simulation = inventory_service[hunter_sim_start:hunter_sim_end]
assert hunter_simulation.index('if not RunService:IsStudio()') < hunter_simulation.index('Random.new(446)')
assert 'local baselineProfile = { Artifacts = {}, EquippedArtifacts = {} }' in hunter_simulation
assert 'local samplesPerEgg = 1000' in hunter_simulation
assert 'totalSamples += 1' in hunter_simulation
assert not any(token in hunter_simulation for token in (
    'table.remove(profile.EggInventory', 'table.insert(profile.Companions',
    'profile.XP', 'ProgressionService:AddXP', 'profile.Materials',
))
assert 'payload.Action == "DevSeedHunterArtifacts"' in inventory_service
assert 'if not RunService:IsStudio() then' in inventory_service
assert '1 + (level - 1) * 0.25' in artifact_bonus
assert 'local expectedExtra = safeBase * bonus' in artifact_bonus
assert 'if fraction > 0 then' in artifact_bonus
assert 'local roll = type(rollValue) == "number" and math.clamp(rollValue, 0, 0.999999999) or math.random()' in artifact_bonus
assert 'local fraction = expectedExtra - extra' in artifact_bonus
assert 'if fraction > 0 and roll < fraction then' in artifact_bonus
assert 'or math.random()' in artifact_bonus
assert 'return safeBase + extra, bonus, extra' in artifact_bonus
assert 'if safeBase == 0 then return 0, 0, 0 end' in artifact_bonus
assert 'local RunService = game:GetService("RunService")' in inventory_service
assert 'payload.Action == "DevSeedGathererArtifacts"' in inventory_service
assert 'if not RunService:IsStudio() then' in inventory_service
assert 'DevOnly = true' in inventory_service
assert '(artifact.DevOnly == true) ~= (first.DevOnly == true)' in inventory_service
assert 'artifact.DevOnly == true then count += 1 end' in inventory_service
assert 'DevOnly = artifact.DevOnly == true' in inventory_service
assert 'tostring(artifact.DevOnly == true)' in client
assert 'artifact.DevOnly and " · ТЕСТ" or ""' in client
assert 'DevOnly = first.DevOnly == true or nil' in inventory_service
assert 'if RunService:IsStudio() then' in player_data
assert 'if artifact.DevOnly == true then' in player_data
assert 'if not testArtifactIds[instanceId] then' in player_data
assert 'requiredSlots' in inventory_service and '#profile.Artifacts + requiredSlots > 40' in inventory_service
assert 'artifactsTestButton' in client and 'RunService:IsStudio() then' in client
assert 'local showNotice, invokeInventory, renderArtifacts' in client
assert client.index('local showNotice, invokeInventory, renderArtifacts') < client.index('local artifactsTestButton')
assert 'renderArtifacts = function(data)' in client
assert 'showNotice = function(message)' in client
assert 'invokeInventory = function(payload)' in client
assert 'local function renderArtifacts(data)' not in client
assert 'local function showNotice(message)' not in client
assert 'local function invokeInventory(payload)' not in client
assert 'Action = "DevSeedGathererArtifacts"' in client
assert 'payload.Action == "DevSimulateGatherBonus"' in inventory_service
assert 'for sample = 1, 1000 do' in inventory_service
assert 'ArtifactBonusService:ApplyGatherBonus(profile, baseAmount, simulationRandom:NextNumber())' in inventory_service
assert 'totalExtra += extra' in inventory_service
assert 'function ArtifactBonusService:ApplyGatherBonus(profile, baseAmount, rollValue)' in artifact_bonus
assert 'type(rollValue) == "number" and math.clamp(rollValue, 0, 0.999999999) or math.random()' in artifact_bonus
assert 'local simulationRandom = Random.new(444)' in inventory_service
assert 'simulationRandom:NextNumber()' in inventory_service
sim_start = inventory_service.index('if payload.Action == "DevSimulateGatherBonus" then')
sim_end = inventory_service.index('if payload.Action == "Get" then', sim_start)
simulation_block = inventory_service[sim_start:sim_end]
assert simulation_block.index('if not RunService:IsStudio()') < simulation_block.index('Random.new(444)')
assert 'makeSnapshot(profile)' in simulation_block
assert not any(token in simulation_block for token in (
    'profile.Materials', 'NodeCooldowns', 'materials.Elderwood +=', 'materials.CrystalShard +='
))
assert 'GathererSimulationButton' in client
assert 'Action = "DevSimulateGatherBonus"' in client
assert 'return response.Data, response.Message' in client
assert 'ТЕСТ: ВЫДАТЬ ×3 СОБИРАТЕЛЕЙ' in client
assert 'Добыча +%d%%' in client

# Researcher artifacts add server-authoritative XP through the single progression entry point.
progression_service = Path("src/ServerScriptService/Server/Services/ProgressionService.lua").read_text()
assert 'ArtifactBonusService:ApplyResearchBonus(profile, safeAmount)' in progression_service
assert 'profile.XP += awardedAmount' in progression_service
assert 'player:SetAttribute("LastXPBonusAmount", extraXP)' in progression_service
assert 'return true, awardedAmount, researchBonus, extraXP' in progression_service
assert 'if safeAmount <= 0 then return false end' in progression_service
assert 'function ProgressionService:FormatXPReward(awardedAmount, researchBonus, extraXP)' in progression_service
assert 'self:FormatXPReward(awardedXP, researchBonus, extraXP)' in progression_service
assert 'бонус +%d%%' in progression_service

xp_reward_sources = {
    "AncientSecretService": Path("src/ServerScriptService/Server/Services/AncientSecretService.lua").read_text(),
    "CrystalTrialService": Path("src/ServerScriptService/Server/Services/CrystalTrialService.lua").read_text(),
    "FireTrialService": Path("src/ServerScriptService/Server/Services/FireTrialService.lua").read_text(),
    "AncientTempleBossService": Path("src/ServerScriptService/Server/Services/AncientTempleBossService.lua").read_text(),
    "ForgottenHeartBossService": Path("src/ServerScriptService/Server/Services/ForgottenHeartBossService.lua").read_text(),
}
for source_name, source_content in xp_reward_sources.items():
    assert 'local _, awardedXP, researchBonus, extraXP = ProgressionService:AddXP' in source_content, source_name
    assert 'ProgressionService:FormatXPReward(awardedXP, researchBonus, extraXP)' in source_content, source_name
assert 'local ok, awardedXP, researchBonus, extraXP = ProgressionService:AddXP(player, reward)' in inventory_service
assert 'ProgressionService:FormatXPReward(awardedXP, researchBonus, extraXP)' in inventory_service
assert 'EquippedResearchBonus' in inventory_service
assert 'payload.Action == "DevSeedResearcherArtifacts"' in inventory_service
assert 'payload.Action == "DevSimulateResearchBonus"' in inventory_service
assert 'local simulationRandom = Random.new(445)' in inventory_service
assert 'for sample = 1, 1000 do' in inventory_service
assert 'ArtifactBonusService:ApplyResearchBonus(profile, baseAmount, simulationRandom:NextNumber())' in inventory_service
assert 'ResearcherArtifactTestButton' in client
assert 'Action = "DevSeedResearcherArtifacts"' in client
assert 'ResearcherSimulationButton' in client
assert 'Action = "DevSimulateResearchBonus"' in client

research_start = inventory_service.index('if payload.Action == "DevSimulateResearchBonus" then')
research_end = inventory_service.index('if payload.Action == "Get" then', research_start)
research_simulation_block = inventory_service[research_start:research_end]
assert research_simulation_block.index('if not RunService:IsStudio()') < research_simulation_block.index('Random.new(445)')
assert 'makeSnapshot(profile)' in research_simulation_block
assert not any(token in research_simulation_block for token in (
    'profile.XP', 'profile.Level', 'ProgressionService:AddXP', 'profile.Materials', 'NodeCooldowns'
))

# Gatherer bonuses must run only after every harvest guard and the existing cooldown.
ancient_harvest = Path("src/ServerScriptService/Server/Services/AncientHarvestService.lua").read_text()
crystal_mining = Path("src/ServerScriptService/Server/Services/CrystalMiningService.lua").read_text()

def assert_gatherer_flow_order(source, fragments, label):
    positions = [source.index(fragment) for fragment in fragments]
    assert positions == sorted(positions), f"{label}: gatherer bonus moved outside the validated harvest flow"

assert_gatherer_flow_order(ancient_harvest, [
    'player:GetAttribute("CurrentBiome") ~= "AncientHeights"',
    'ProgressionService:CanEnterZone(player, "AncientHeights")',
    'humanoid.Health <= 0',
    'PlayerDataService:GetProfile(player)',
    'if readyAt > now then',
    'ArtifactBonusService:ApplyGatherBonus(profile, baseAmount)',
    'materials.ElderwoodNodeCooldowns[nodeId] = now + NODE_COOLDOWN_SECONDS',
    'materials.Elderwood = math.max(0, math.floor(tonumber(materials.Elderwood) or 0)) + amount',
    '\n    syncBalance(player, profile)\n    player:SetAttribute("LastNotice", string.format(',
], "Ancient Heights harvest")

assert_gatherer_flow_order(crystal_mining, [
    'player:GetAttribute("CurrentBiome") ~= "CrystalRealm"',
    'ProgressionService:CanEnterZone(player, "CrystalRealm")',
    'humanoid.Health <= 0',
    'PlayerDataService:GetProfile(player)',
    'if readyAt > now then',
    'local species = activeSpecies(profile)',
    'if species.PrismFox then amount += 1 end',
    'if species.CrystalDeer then amount += 1 end',
    'if species.AuroraDragon and math.random() < 0.35 then amount += 2 end',
    'local baseAmount = amount',
    'ArtifactBonusService:ApplyGatherBonus(profile, baseAmount)',
    'materials.CrystalNodeCooldowns[nodeId] = now + NODE_COOLDOWN_SECONDS',
    'materials.CrystalShard = math.max(0, math.floor(tonumber(materials.CrystalShard) or 0)) + amount',
], "Crystal Realm mining")

assert 'local NODE_COOLDOWN_SECONDS = 180' in ancient_harvest
assert 'local NODE_COOLDOWN_SECONDS = 180' in crystal_mining
assert 'local HARVEST_LOCKS = {}' in ancient_harvest
assert 'if HARVEST_LOCKS[player] then return end' in ancient_harvest

print("Playable-first static regression checks passed. Roblox Studio runtime still required.")


# Sprint 4.47: opt-in raid matchmaking and newcomer protection.
raid_service = Path("src/ServerScriptService/Server/Services/RaidService.lua").read_text()
assert '"RaidBoard"' in server
assert '"RaidService"' in server and '"PlotService"' in server
assert 'local raidRemote = waitRemote("RaidBoard")' in client
assert 'raidRemote:InvokeServer(payload)' in client
assert 'RaidBoardButton' in client and 'RaidBoardPanel' in client
assert 'raidButton' in client[client.index('local menuButtons = {'):client.index('local navToggle =')]
assert 'raidPanel' in client[client.index('local modalPanels = {'):client.index('local closingOtherPanels')]
assert 'MINIMUM_LEVEL = 5' in raid_service
assert 'NEWCOMER_PROTECTION_SECONDS = 15 * 60' in raid_service
assert 'OPT_IN_WINDOW_SECONDS = 10 * 60' in raid_service
assert 'CHALLENGE_TIMEOUT_SECONDS = 45' in raid_service
assert 'MATCH_READY_TIMEOUT_SECONDS = 120' in raid_service
assert 'function RaidService:SetAttackReady' in raid_service
assert 'function RaidService:SetDefenseOpen' in raid_service
assert 'function RaidService:Challenge' in raid_service
assert 'function RaidService:AcceptChallenge' in raid_service
assert 'function RaidService:DeclineChallenge' in raid_service
assert 'RaidAttackUntil' in raid_service and 'RaidDefenseUntil' in raid_service
assert 'self:CanParticipate(target)' in raid_service
assert 'self._pendingByAttacker[player] or self._pendingByTarget[player]' in raid_service
assert 'not self._pendingByAttacker[target]' in raid_service
assert 'PlotService:GetPlayerPlot(target)' in raid_service
assert 'IslandVisitService._visitingPlot[player]' in raid_service
assert 'participant:SetAttribute("RaidMatchState", "READY")' in raid_service
assert 'raidAttackToggle.Activated' in client and 'raidDefenseToggle.Activated' in client
assert 'raidAccept.Activated' in client and 'raidDecline.Activated' in client
assert 'raidPanel.Visible' in client and 'task.wait(4)' in client
for forbidden in ('profile.Coins', 'profile.Companions', 'profile.EggInventory', 'profile.Artifacts'):
    assert forbidden not in raid_service, f"Raid matchmaking must not mutate player loot: {forbidden}"

assert 'local RunService = game:GetService("RunService")' in raid_service
assert 'if not RunService:IsStudio() then' in raid_service
assert 'payload.Action == "DevGrantAccess"' in raid_service
assert 'payload.Action == "DevResetAccess"' in raid_service
assert 'if payload.Action ~= "Get" then' in raid_service
assert 'self._studioRaidLevelOverride[player] = true' in raid_service
assert 'RaidStudioAccessTest' in client and 'Visible = RunService:IsStudio()' in client
assert 'Action = action' in client and 'StudioAccessOverride' in client

# Sprint 4.48 — bounded opt-in raid arena, objective, recovery and rewards.
assert 'function RaidService:StartArena(match)' in raid_service
assert 'function RaidService:AttackCore(player)' in raid_service
assert 'function RaidService:ReinforceCore(player)' in raid_service
assert 'RAID_DURATION_SECONDS = 150' in raid_service
assert 'RAID_CORE_MAX_HEALTH = 100' in raid_service
assert 'RAID_CORE_HIT_DAMAGE = 20' in raid_service
assert 'RAID_REPAIR_AMOUNT = 10' in raid_service
assert 'RAID_REPAIR_COOLDOWN_SECONDS = 8' in raid_service
assert 'NestRaidersRaidArenas' in raid_service and 'RaidArena_' in raid_service
assert 'match.Attacker.Character' in raid_service and 'match.Defender.Character' in raid_service
assert 'ReturnCFrames' in raid_service and 'restoreParticipant' in raid_service
assert 'participant:SetAttribute("RaidArenaActive", true)' in raid_service
assert 'participant:SetAttribute("RaidArenaActive", false)' in raid_service
assert 'payload.Action == "AttackCore"' in raid_service
assert 'payload.Action == "ReinforceCore"' in raid_service
assert 'self:AttackCore(player)' in raid_service and 'self:ReinforceCore(player)' in raid_service
assert 'finishMatch(self, match, "ATTACKER"' in raid_service
assert 'finishMatch(self, match, "DEFENDER"' in raid_service
assert 'RaidRewardCooldownUntil' in raid_service
assert 'EconomyService:GrantCoins(player, coins' in raid_service
assert 'ProgressionService:AddXP(player, RAID_WIN_XP)' in raid_service
assert 'raidArenaHud.Name = "RaidArenaHUD"' in client
assert 'raidArenaAttack.Activated' in client and 'raidArenaRepair.Activated' in client
assert 'raidArenaExit.Activated' in client
assert 'Action = "AttackCore"' in client and 'Action = "ReinforceCore"' in client
assert 'RaidArenaCoreHealth' in client and 'RaidArenaTimeRemaining' in client

# Sprint 4.49 — role-neutral duel combat, short parry window and arena gear.
assert 'function RaidService:StrikeOpponent(player)' in raid_service
assert 'function RaidService:RaiseGuard(player)' in raid_service
assert 'RAID_DUEL_STRIKE_DAMAGE = 24' in raid_service
assert 'RAID_DUEL_STRIKE_COOLDOWN_SECONDS = 1.15' in raid_service
assert 'RAID_DUEL_STRIKE_RANGE = 12' in raid_service
assert 'RAID_PARRY_WINDOW_SECONDS = 0.9' in raid_service
assert 'RAID_PARRY_COOLDOWN_SECONDS = 3.2' in raid_service
assert 'RAID_PARRY_COUNTER_DAMAGE = 18' in raid_service
assert 'match.CombatHealth = {' in raid_service
assert 'match.LastStrikeAt = {}' in raid_service
assert 'match.GuardUntil = {}' in raid_service and 'match.GuardCooldownUntil = {}' in raid_service
assert 'if targetGuardUntil > timestamp then' in raid_service
assert 'applyRaidCombatDamage(self, match, opponent, strikeDamage, "Удар соперника")' in raid_service
assert 'applyRaidCombatDamage(self, match, player, RAID_PARRY_COUNTER_DAMAGE' in raid_service
assert 'finishMatch(self, match, target == match.Attacker and "DEFENDER" or "ATTACKER"' in raid_service
assert 'function RaidService:RaiseGuard(player)' in raid_service
assert 'match.GuardUntil[player] = guardUntil' in raid_service
assert 'match.GuardCooldownUntil[player] = timestamp + RAID_PARRY_COOLDOWN_SECONDS' in raid_service
assert 'local function equipRaidGear(player, role)' in raid_service
assert 'RaidCombatGear' in raid_service and 'RaidSwordBlade' in raid_service and 'RaidShield' in raid_service
assert 'local function showRaidCombatHit(character, parried)' in raid_service
assert 'RaidParryFlash' in raid_service and 'RaidHitFlash' in raid_service
assert 'participant:SetAttribute("RaidArenaCombatHealth", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaOpponentCombatHealth", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaGuardActive", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaGuardCooldown", nil)' in raid_service
assert 'payload.Action == "StrikeOpponent"' in raid_service
assert 'payload.Action == "RaiseGuard"' in raid_service
assert 'self:StrikeOpponent(player)' in raid_service and 'self:RaiseGuard(player)' in raid_service
assert 'raidArenaStrike.Name = "StrikeOpponent"' in client
assert 'raidArenaGuard.Name = "RaiseGuard"' in client
assert 'raidArenaCombatStatus.Name = "CombatStatus"' in client
assert 'Action = "StrikeOpponent"' in client and 'Action = "RaiseGuard"' in client
assert 'raidArenaStrike.Activated' in client and 'raidArenaGuard.Activated' in client
assert 'RaidArenaCombatHealth' in client and 'RaidArenaOpponentCombatHealth' in client
assert 'RaidArenaGuardActive' in client and 'RaidArenaGuardCooldown' in client

# Sprint 4.50 — persistent nest defenses materialized as temporary raid defenses.
assert 'Id = "StoneBastion"' in nest_build_catalog and 'DefenseType = "Wall"' in nest_build_catalog
assert 'DefenseHealth = 140' in nest_build_catalog and 'MaxOwned = 6' in nest_build_catalog
assert 'Id = "Watchtower"' in nest_build_catalog and 'DefenseType = "Turret"' in nest_build_catalog
assert 'DefenseDamage = 8' in nest_build_catalog and 'DefenseRange = 38' in nest_build_catalog
assert 'DefenseInterval = 2.5' in nest_build_catalog and 'MaxOwned = 3' in nest_build_catalog
assert 'Id = "ThornTrap"' in nest_build_catalog and 'DefenseType = "Trap"' in nest_build_catalog
assert 'DefenseDamage = 12' in nest_build_catalog and 'DefenseCooldown = 6' in nest_build_catalog
assert 'MAX_DEFENSE_TOTAL = 12' in build_service
assert 'local function countDefenseOwned(nest)' in build_service
assert 'countDefenseOwned(nest)>=MAX_DEFENSE_TOTAL' in build_service
assert 'local typeLimit = def.MaxOwned or MAX_PER_TYPE' in build_service
assert 'DefenseCount=countDefenseOwned(nest)' in build_service
assert 'def.Kind == "DefenseWall"' in build_service
assert 'def.Kind == "DefenseTower"' in build_service
assert 'def.Kind == "DefenseTrap"' in build_service
assert 'Category=def.Category, DefenseType=def.DefenseType' in build_service
assert 'item.Category and ("[" .. item.Category .. "] ")' in client
assert 'Оборона: %d / %d' in client

assert 'local NestBuildCatalog = require(ReplicatedStorage.Shared.Config.NestBuildCatalog)' in raid_service
assert 'local function buildArenaDefenses(match, profile)' in raid_service
assert 'profile.Nest' in raid_service and 'nest.PlacedBuildings' in raid_service
assert 'MAX_ARENA_DEFENSES = 12' in raid_service
assert 'DefenseWall' not in raid_service  # raid behavior is keyed by catalog DefenseType
assert 'if def.DefenseType == "Wall" then' in raid_service
assert 'if def.DefenseType == "Turret" then' in raid_service
assert 'if def.DefenseType == "Trap" then' in raid_service
assert 'function RaidService:AttackDefense(player)' in raid_service
assert 'function RaidService:RepairDefense(player)' in raid_service
assert 'RAID_DEFENSE_STRIKE_DAMAGE = 35' in raid_service
assert 'RAID_DEFENSE_REPAIR_AMOUNT = 30' in raid_service
assert 'RAID_DEFENSE_STRIKE_COOLDOWN_SECONDS = 1.15' in raid_service
assert 'RAID_DEFENSE_REPAIR_COOLDOWN_SECONDS = 8' in raid_service
assert 'local function startDefenseTurret(self, match, defense)' in raid_service
assert 'NestDefenseBolt' in raid_service and 'TweenService:Create' in raid_service
assert 'defense.Trigger.Touched:Connect' in raid_service
assert 'applyDefenseDamage(self, match, match.Attacker, defense.Damage' in raid_service
assert 'local function findNearestDefense(match, root, maxDistance, damagedOnly)' in raid_service
assert 'defense.Health = math.max(0, defense.Health - RAID_DEFENSE_STRIKE_DAMAGE)' in raid_service
assert 'defense.Health = math.min(defense.MaxHealth, defense.Health + RAID_DEFENSE_REPAIR_AMOUNT)' in raid_service
assert 'if defense.Model and defense.Model.Parent then defense.Model:Destroy() end' in raid_service
assert 'participant:SetAttribute("RaidArenaDefenseCount", defenseCount)' in raid_service
assert 'participant:SetAttribute("RaidArenaDefenseCount", nil)' in raid_service
assert 'payload.Action == "AttackDefense"' in raid_service
assert 'payload.Action == "RepairDefense"' in raid_service
assert 'self:AttackDefense(player)' in raid_service and 'self:RepairDefense(player)' in raid_service
assert 'buildArenaDefenses(match, PlayerDataService:GetProfile(match.Defender))' in raid_service
assert 'activateArenaDefenses(self, match)' in raid_service
assert 'while self._matches[match.Attacker] == match and match.State == "ACTIVE"' in raid_service
assert 'RaidArenaDefenseCount' in client
assert 'raidArenaDefenseStatus.Name = "DefenseStatus"' in client
assert 'raidArenaDefenseAttack.Name = "AttackDefense"' in client
assert 'raidArenaDefenseRepair.Name = "RepairDefense"' in client
assert 'raidArenaDefenseAttack.Activated' in client and 'raidArenaDefenseRepair.Activated' in client
assert 'Action = "AttackDefense"' in client and 'Action = "RepairDefense"' in client
assert 'raidArenaDefenseStatus.Text' in client

# Sprint 4.51 — active companions join raids and unlock role-based combat abilities.
assert 'RaidAbility = { Id = "FoxPounce"' in companion_catalog and 'Role = "HUNTER"' in companion_catalog
assert 'RaidAbility = { Id = "MossShell"' in companion_catalog and 'Role = "GUARDIAN"' in companion_catalog
assert 'RaidAbility = { Id = "VerdantMend"' in companion_catalog and 'Role = "HEALER"' in companion_catalog
assert 'Id = "AuroraMend"' in companion_catalog and 'HealAmount = 26' in companion_catalog
assert 'Id = "GlacierBulwark"' in companion_catalog and 'ShieldAmount = 32' in companion_catalog
assert 'Id = "PhoenixDive"' in companion_catalog and 'Damage = 22' in companion_catalog
assert 'Id = "CrystalBloom"' in companion_catalog and 'HealAmount = 30' in companion_catalog
assert 'Id = "AuroraBreath"' in companion_catalog and 'Damage = 26' in companion_catalog
assert 'Id = "BriarAegis"' in companion_catalog and 'ShieldAmount = 28' in companion_catalog
assert 'UnlockLevel = 5' in companion_catalog and 'CooldownSeconds = 28' in companion_catalog

assert 'local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)' in companion_service
assert 'function CompanionService:CreateRaidFollowers(player, parent)' in companion_service
assert 'profile.ActiveCompanions' in companion_service
assert 'buildPet(parent, companion, #followers + 1)' in companion_service
assert 'RaidPrimaryCompanionHighlight' in companion_service
assert 'RaidCompanionNameplate' in companion_service

assert 'local CompanionService = require(ServerScriptService.Server.Services.CompanionService)' in raid_service
assert 'local function followRaidCompanions(self, match, player, followers)' in raid_service
assert 'CompanionService:CreateRaidFollowers(participant, folder)' in raid_service
assert 'match.RaidPets[participant] = primary' in raid_service
assert 'match.PetAbilityReadyAt = {}' in raid_service and 'match.PetShields = {}' in raid_service
assert 'function RaidService:UsePetAbility(player)' in raid_service
assert 'role == "HUNTER"' in raid_service and 'role == "HEALER"' in raid_service and 'role == "GUARDIAN"' in raid_service
assert 'match.PetAbilityReadyAt[player] = timestamp + cooldown' in raid_service
assert 'local function applyRaidCombatDamage(self, match, target, amount, sourceName)' in raid_service
assert 'absorbed = math.min(remainingDamage, shield.Amount)' in raid_service
assert 'remainingDamage -= absorbed' in raid_service
assert 'return applyRaidCombatDamage(self, match, target, amount, sourceName)' in raid_service
assert 'applyDefenseDamage(self, match, match.Attacker, defense.Damage' in raid_service
assert 'applyRaidCombatDamage(self, match, opponent, strikeDamage, "Удар соперника")' in raid_service
assert 'applyRaidCombatDamage(self, match, player, RAID_PARRY_COUNTER_DAMAGE' in raid_service
assert 'payload.Action == "UsePetAbility"' in raid_service and 'self:UsePetAbility(player)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetAbilityName", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetShield", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetCooldown"' in raid_service
assert 'participant:SetAttribute("RaidArenaPetShieldSeconds"' in raid_service

assert 'raidArenaPetStatus.Name = "PetAbilityStatus"' in client
assert 'raidArenaPetAbility.Name = "UsePetAbility"' in client
assert 'raidArenaPetAbility.Activated' in client and 'Action = "UsePetAbility"' in client
assert 'RaidArenaPetAbilityName' in client and 'RaidArenaPetCooldown' in client
assert 'RaidArenaPetShield' in client and 'RaidArenaPetShieldSeconds' in client
assert 'raidArenaHud.Size = UDim2.new(0.9, 0, 0, 286)' in client
assert 'raidArenaSynergyStatus.Name = "TeamSynergyStatus"' in client
assert 'RaidArenaSynergyName' in client and 'RaidArenaSynergyDescription' in client

# Sprint 4.52 — companion species-role alignment and level-scaled raid abilities.
cinder_fox_block = companion_catalog[companion_catalog.index("    CinderFox = {"):companion_catalog.index("    MagmaWhelp = {")]
ash_phoenix_block = companion_catalog[companion_catalog.index("    AshPhoenix = {"):companion_catalog.index("    FrostFox = {")]
frost_fox_block = companion_catalog[companion_catalog.index("    FrostFox = {"):companion_catalog.index("    SnowOwl = {")]
snow_owl_block = companion_catalog[companion_catalog.index("    SnowOwl = {"):companion_catalog.index("    GlacierBear = {")]
glacier_bear_block = companion_catalog[companion_catalog.index("    GlacierBear = {"):companion_catalog.index("    PrismFox = {")]
assert 'RaidAbility' not in cinder_fox_block
assert 'RaidAbility' not in frost_fox_block
assert 'Id = "PhoenixDive"' in ash_phoenix_block and 'Role = "HUNTER"' in ash_phoenix_block
assert 'Id = "AuroraMend"' in snow_owl_block and 'Role = "HEALER"' in snow_owl_block
assert 'Id = "GlacierBulwark"' in glacier_bear_block and 'Role = "GUARDIAN"' in glacier_bear_block

assert 'local function getRaidPetProgression(pet, synergy)' in raid_service
assert 'local steps = math.floor((level - 1) / 2)' in raid_service
assert 'power = math.floor(tonumber(ability.Damage) or 14) + steps' in raid_service
assert 'power = math.floor(tonumber(ability.HealAmount) or 20) + steps' in raid_service
assert 'local shieldBonus = math.floor((level - 1) * 2 / 3)' in raid_service
assert 'power = math.floor(tonumber(ability.ShieldAmount) or 20) + shieldBonus' in raid_service
assert 'power = math.clamp(power, 8, maximum)' in raid_service
assert 'power = math.clamp(power, 5, maximum)' in raid_service
assert 'power = math.clamp(power, 10, maximum)' in raid_service
assert 'local petLevel, power = getRaidPetProgression(primary, synergy)' in raid_service
assert 'local damage = power' in raid_service
assert 'local heal = power' in raid_service
assert 'local shieldAmount = power' in raid_service
assert 'participant:SetAttribute("RaidArenaPetLevel", ability and petLevel or 0)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetPower", petPower)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetPowerLabel", petPowerLabel)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetLevel", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaPetPowerLabel", nil)' in raid_service

assert 'model:SetAttribute("RaidBattleLevel", petLevel)' in companion_service
assert 'Level = petLevel' in companion_service
assert '" · ур. " .. tostring(petLevel)' in companion_service
assert 'RaidArenaPetLevel' in client and 'RaidArenaPetPowerLabel' in client
assert 'СПУТНИК · %s · ур.%d · %s · %s%s' in client

# Sprint 4.53 — server-authoritative companion team synergies.
assert 'local function getRaidPetSynergy(followers)' in raid_service
assert 'roles[follower.Role] = true' in raid_service, "Duplicate species roles must not stack synergy"
assert 'if roleCount < 2 then return nil end' in raid_service
assert 'if roleCount == 3 then' in raid_service
assert 'Id = "TRIAD"' in raid_service and 'Name = "Триада"' in raid_service
assert 'if roles.GUARDIAN and roles.HEALER then' in raid_service
assert 'Id = "LIVING_BASTION"' in raid_service and 'DamageReduction = 0.12' in raid_service
assert 'if roles.HUNTER and roles.GUARDIAN then' in raid_service
assert 'Id = "ASSAULT_FORMATION"' in raid_service and 'DuelDamageMultiplier = 1.10' in raid_service
assert 'BoostRoles = { HUNTER = true, GUARDIAN = true }' in raid_service
assert 'if roles.HUNTER and roles.HEALER then' in raid_service
assert 'Id = "COORDINATED_ASSAULT"' in raid_service
assert raid_service.index('if roleCount == 3 then') < raid_service.index('if roles.GUARDIAN and roles.HEALER then'), "The full trio must replace, not stack with, pair bonuses"
assert 'match.RaidPetSynergy = {}' in raid_service
assert 'match.RaidPetSynergy[participant] = getRaidPetSynergy(followers)' in raid_service
assert 'local synergy = match.RaidPetSynergy and match.RaidPetSynergy[target] or nil' in raid_service
assert 'local damageReduction = math.clamp(tonumber(synergy and synergy.DamageReduction) or 0, 0, 0.2)' in raid_service
assert 'local reducedDamage = math.max(0, math.floor(incomingDamage * (1 - damageReduction) + 0.5))' in raid_service
assert 'local strikeMultiplier = math.clamp(tonumber(synergy and synergy.DuelDamageMultiplier) or 1, 1, 1.15)' in raid_service
assert 'participant:SetAttribute("RaidArenaSynergyName", synergy and synergy.Name or "")' in raid_service
assert 'participant:SetAttribute("RaidArenaSynergyDescription", synergy and synergy.Description or "")' in raid_service
assert 'participant:SetAttribute("RaidArenaSynergyName", nil)' in raid_service
assert 'participant:SetAttribute("RaidArenaSynergyDescription", nil)' in raid_service
assert 'raidArenaSynergyStatus.Text = synergyName ~= ""' in client
assert 'СИНЕРГИЯ · НЕТ · нужны 2 разные роли' in client
assert 'RaidArenaSynergyName' in client and 'RaidArenaSynergyDescription' in client

# Sprint 4.54 — role-colored companion auras and authoritative combat cues.
assert 'local RAID_SYNERGY_PALETTES = {' in raid_service
for synergy_id in ("LIVING_BASTION", "ASSAULT_FORMATION", "COORDINATED_ASSAULT", "TRIAD"):
    assert synergy_id in raid_service and synergy_id in client
assert 'local function getRaidSynergyColor(synergy, role)' in raid_service
assert 'local function applyRaidSynergyVisuals(match, player, synergy)' in raid_service
assert 'model:SetAttribute("RaidSynergyId", synergy.Id)' in raid_service
assert 'aura.Name = "RaidTeamSynergyAura"' in raid_service
assert 'aura.FillTransparency = 0.94' in raid_service
assert 'local function pulseRaidCompanions(match, player, cueKind, force)' in raid_service
assert 'if not force and timestamp - lastCue < 0.32 then return false end' in raid_service
assert 'flash.Name = "RaidSynergyCue_" .. tostring(cueKind)' in raid_service
assert 'TweenService:Create(flash, TweenInfo.new(duration' in raid_service
assert 'Debris:AddItem(flash, duration + 0.08)' in raid_service
assert 'light.Name = "RaidSynergyCueLight"' in raid_service
assert 'match.RaidFollowers = {}' in raid_service
assert 'applyRaidSynergyVisuals(match, participant, match.RaidPetSynergy[participant])' in raid_service
assert 'pulseRaidCompanions(match, participant, "ACTIVATION", true)' in raid_service
assert 'pulseRaidCompanions(match, player, "ATTACK")' in raid_service
assert 'pulseRaidCompanions(match, player, "ABILITY")' in raid_service
assert 'pulseRaidCompanions(match, target, "DEFEND")' in raid_service
assert 'pulseRaidCompanions(match, opponent, "DEFEND")' in raid_service
assert 'participant:SetAttribute("RaidArenaSynergyPulse", nil)' in raid_service
assert 'raidSynergyToast.Name = "RaidSynergyActivationToast"' in client
assert 'local function showRaidSynergyToast(synergyId, synergyName, description)' in client
assert 'local lastRaidSynergyPulse = ""' in client
assert 'synergyPulse ~= lastRaidSynergyPulse' in client
assert 'showRaidSynergyToast(synergyId, synergyName, synergyDescription)' in client
assert '"RaidArenaSynergyId", "RaidArenaSynergyName", "RaidArenaSynergyDescription"' in client
assert '"RaidArenaSynergyPulse", "RaidArenaPetCooldown"' in client

# Sprint 4.55 — server-replicated procedural companion combat motion.
assert 'local function getRaidCompanionCombatMotion(match, player, entry, root, index, now)' in raid_service
assert 'follower.CombatCue = {' in raid_service
assert 'Kind = cueKind' in raid_service and 'StartedAt = timestamp + (index - 1) * 0.055' in raid_service
assert 'if not synergy then return true end' in raid_service, "Combat motion must also work for teams without a synergy"
assert 'local windup = math.max(0, 1 - math.abs(progress - 0.2) / 0.2)' in raid_service
assert 'local strike = math.max(0, 1 - math.abs(progress - 0.57) / 0.25)' in raid_service
assert 'local towardOpponent = opponentRoot and (opponentRoot.Position - root.Position)' in raid_service
assert 'local reach = role == "HUNTER" and 3.25 or (role == "GUARDIAN" and 1.8 or 0.85)' in raid_service
assert 'if role == "HUNTER" then' in raid_service and '3.9 * strike' in raid_service
assert 'elseif role == "GUARDIAN" then' in raid_service and '0.72 * pulse' in raid_service
assert 'offset += Vector3.new(0, 1.3 * pulse, 0)' in raid_service, "Healer ability should use a distinct rising motion"
assert 'elseif cue.Kind == "DEFEND" then' in raid_service
assert 'offset += towardOwner * (1.05 * pulse)' in raid_service
assert 'local sideStep = root.CFrame.RightVector' in raid_service
assert 'local idleBob = math.sin(now * 2.15 + index * 1.65) * 0.075' in raid_service
assert 'local motionOffset, motionRotation = getRaidCompanionCombatMotion(' in raid_service
assert 'model:PivotTo(model:GetPivot():Lerp(target, 0.42))' in raid_service
assert 'pulseRaidCompanions(match, participant, "ACTIVATION", true)' in raid_service
assert 'if synergy then\n            pulseRaidCompanions(match, participant' not in raid_service, "Raid start should animate teams without a synergy"
assert 'entry.CombatCue = nil' in raid_service, "Completed motion cues must be cleared"

# Sprint 4.56 — responsive UI foundation and camera rebinding.
assert 'bootCard.Size = UDim2.new(0.9, 0, 0, 132)' in client
assert 'bootCardSize.MinSize = Vector2.new(260, 132)' in client
assert 'local cameraViewportConnection' in client
assert 'local function bindHudCamera()' in client
assert 'Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindHudCamera)' in client
assert 'local compactFit = math.min(viewport.X / 300, viewport.Y / 340, 1)' in client
assert 'hudScale.Scale = math.clamp(scale, minimumScale, 1)' in client
assert 'local function bindNavigationCamera()' in client
assert 'Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindNavigationCamera)' in client
assert 'materialsPanel, artifactsPanel, raidPanel, raidPanel' not in client, "Modal list must not register raid panel twice"

# Sprint 4.57 — polished island navigation and native vector icons.
assert 'local setNavigationOpen' in client
assert 'setNavigationOpen = function(open)' in client
assert client.index('local setNavigationOpen') < client.index('for index, button in ipairs(menuButtons) do')
assert 'local navHeader = Instance.new("Frame")' in client
assert 'navHeaderTitle.Text = "ЦЕНТР ОСТРОВА"' in client
assert 'navHeaderSubtitle.Text = "УПРАВЛЕНИЕ · ПРИКЛЮЧЕНИЯ · КОЛЛЕКЦИЯ"' in client
assert 'local function addIconShape(' in client
assert 'local function drawMenuIcon(parent, kind)' in client
assert 'drawMenuIcon(iconBadge, iconStyle.Kind)' in client
for icon_kind in ("paw", "egg", "book", "nest", "star", "flower", "hammer", "arrow", "swords", "trophy", "podium", "gem", "crystal", "profile"):
    assert f'Kind = "{icon_kind}"' in client, f"Missing native navigation icon: {icon_kind}"
assert 'buttonGradient.Parent = button' in client
assert 'button.MouseEnter:Connect(function()' in client
assert 'button.MouseLeave:Connect(function()' in client
assert 'setNavigationOpen(not navScroll.Visible)' in client
assert 'Order = 120' in client, "Collection section must have a unique position after adventure buttons"
assert 'navHeader.LayoutOrder = 0' in client
assert 'iconText.Name = "MenuIconFallback"' not in client, "Old text-only placeholder badges should be removed"


# Sprint 4.58 — companion inventory cards and compact-screen readability.
assert 'inventoryPanel.Size = UDim2.new(0.94, 0, 0.82, 0)' in client
assert 'sizeLimit.MinSize = Vector2.new(300, 340)' in client
assert 'sizeLimit.MaxSize = Vector2.new(560, 660)' in client
assert 'local inventorySummaryFrame = Instance.new("Frame")' in client
assert 'local incubatorFrame = Instance.new("Frame")' in client
assert 'local companionRarityColors = {' in client
assert 'local function addPetPortraitShape(' in client
assert 'local function drawCompanionPortrait(parent, companion, rarityColor)' in client
assert 'drawCompanionPortrait(portrait, companion, rarityColor)' in client
assert 'local cardHeight = 176 + (hasAbility and 32 or 0) + (canBreed and 32 or 0)' in client
assert 'card.Name = "CompanionCard"' in client
assert 'portrait.Name = "PetPortrait"' in client
assert 'rarityPill.Name = "RarityPill"' in client
assert 'xpTrack.Name = "GrowthXPTrack"' in client
assert 'xpFill.Name = "GrowthXPFill"' in client
assert 'action.Name = "EquipButton"' in client
assert 'action.Text = companion.Equipped and "УБРАТЬ ИЗ КОМАНДЫ" or "ВЫСТАВИТЬ В КОМАНДУ"' in client
assert 'abilityButton.Position = UDim2.fromOffset(12, 174)' in client
assert 'breedButton.Position = UDim2.fromOffset(12, companion.Ability and 206 or 174)' in client
assert 'emptyLabel.Text = "ПОКА НЕТ ПИТОМЦЕВ\\nНайди яйцо на острове и вылупи своего первого друга!"' in client
assert 'inventorySummary.Text = string.format("В КОМАНДЕ · %d / %d     ВСЕГО · %d"' in client

# Sprint 4.59 — biome egg shop, server-confirmed purchases and hatch reveal.
for egg_id in ("MeadowEgg", "EmeraldEgg", "FrostEgg", "EmberEgg", "CrystalEgg", "AncientEgg"):
    assert f'"{egg_id}"' in shop_service, f"Missing natural biome egg from shop: {egg_id}"
assert 'local SHOP_ORDER = {' in shop_service
assert 'local SHOP_PRICES = {' in shop_service
assert 'local ZONE_BY_BIOME = {' in shop_service
assert 'local ProgressionService = require(ServerScriptService.Server.Services.ProgressionService)' in shop_service
assert 'ProgressionService:CanEnterZone(player, zoneId)' in shop_service
assert 'CanBuy = unlocked and enoughCoins and hasCapacity' in shop_service
assert 'BuyBlockReason = buyBlockReason' in shop_service
assert 'BiomeId = item.BiomeId' in shop_service
assert 'Source = "Shop"' in shop_service
assert 'HttpService:GenerateGUID(false)' in shop_service
assert 'EggCount = #(profile.EggInventory or {})' in shop_service
assert 'profile.Coins -= item.Price' in shop_service
assert 'local unlocked, lockReason = getLockReason(' in shop_service
assert 'local function getRequiredLevel(zoneId)' in shop_service
assert 'RequiredQuest = requiredQuest' in shop_service

assert 'shopPanel.Size = UDim2.new(0.94, 0, 0.82, 0)' in client
assert 'shopSize.MinSize = Vector2.new(300, 340)' in client
assert 'shopSize.MaxSize = Vector2.new(620, 680)' in client
assert 'local eggBiomeColors = {' in client
assert 'local eggRarityColors = {' in client
assert 'local function drawEggShopPortrait(parent, item, accent)' in client
assert 'local function formatEggChance(value)' in client
assert 'oddsHeader.Text = "ВОЗМОЖНЫЕ ПИТОМЦЫ"' in client
assert 'item.BuyBlockReason or "ДОСТУПНО К ПОКУПКЕ"' in client
assert 'buy.Active = item.CanBuy == true' in client
assert 'ЯЙЦА В СУМКЕ' in client
assert 'EggShopCard_' in client
assert 'EggRarityPill' in client
assert 'OddsRarityDot' in client

assert 'local hatchRevealRemote = remotes:WaitForChild("HatchReveal", 20)' in client
assert 'HatchRevealOverlay' in client
assert 'local function finishHatchReveal()' in client
assert 'hatchSkip.Text = "ПРОПУСТИТЬ АНИМАЦИЮ"' in client
assert 'hatchSkip.Text = "ЗАБРАТЬ ПИТОМЦА"' in client
assert 'hatchRevealRemote.OnClientEvent:Connect(function(payload)' in client
assert 'drawCompanionPortrait(hatchPetPortrait, payload, rarityColor)' in client
assert 'hatchEggVisual.Rotation = 0' in client
assert 'hatchCrackA.BackgroundTransparency = 1' in client

assert 'local hatchRevealRemote' in eggs
assert 'hatchRevealRemote:FireClient(player, {' in eggs
assert 'hatchRevealRemote = Instance.new("RemoteEvent")' in eggs
assert 'hatchRevealRemote.Name = "HatchReveal"' in eggs
assert 'prompt.ObjectText = eggDefinition and eggDefinition.Name or "Яйцо биома"' in eggs
assert eggs.index('table.insert(profile.Companions, companion)') < eggs.index('hatchRevealRemote:FireClient(player, {')
assert eggs.index('syncAttributes(player, profile)') < eggs.index('hatchRevealRemote:FireClient(player, {')

assert 'local function attachDetail(name, size, offset, detailColor, shape, material)' in world
assert 'EggDecorBand' in world
assert 'EggRune_Left' in world and 'EggRune_Right' in world and 'EggRune_Center' in world
assert 'EggCrownGem' in world
assert 'EggGlow' in world and 'EggHighlight' in world
assert 'detail.Parent = egg' in world, "Egg ornaments must follow their collectible shell"
assert 'local detailStates = {}' in eggs
assert 'local collectInfo = TweenInfo.new(0.32' in eggs
assert 'TweenService:Create(detail, collectInfo' in eggs
assert 'TweenService:Create(detail, respawnInfo' in eggs
assert 'if eggGlow then eggGlow.Enabled = false end' in eggs
assert 'if eggHighlight then eggHighlight.Enabled = false end' in eggs
assert 'if eggGlow then eggGlow.Enabled = true end' in eggs
assert 'if eggHighlight then eggHighlight.Enabled = true end' in eggs
assert 'hatchOverlay.Active = true' in client
# Sprint 4.64 — autonomous displayed companion behavior.
assert 'local wanderRadius = 3.6' in companion_service
assert 'targetPosition = home + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)' in companion_service
assert 'local speed = energy <= 15 and 1.25 or (mood >= 80 and 3.4 or 2.5)' in companion_service
assert 'behavior = "Sleeping"' in companion_service
assert 'local isSleeping = (tonumber(needs.RestingUntil) or 0) > os.time()' in companion_service
assert 'model:SetAttribute("IsSleeping", isSleeping)' in companion_service
assert 'local home = basePivot.Position' in companion_service
assert 'makeShape(folder, "NestToy_"' in companion_service
assert 'targetPosition = toyApproach' in companion_service
assert 'local toyPlayUntil = 0' in companion_service
assert 'toyPlayUntil = now + random:NextNumber(2.8, 4.2)' in companion_service
assert 'behavior = "PlayingWithToy"' in companion_service
assert 'toyPart:SetAttribute("ToyState", "InUse")' in companion_service
assert 'toyPart:SetAttribute("ToyState", "Waiting")' in companion_service
assert 'while model.Parent == folder and folder.Parent do' in companion_service
assert 'behavior = targetIsChase and "ChasingFriend" or (targetIsTreasure and "Searching"' in companion_service
assert 'model:SetAttribute("Behavior", behavior)' in companion_service
assert 'model:SetAttribute("Personality"' in companion_service
assert 'model:PivotTo(CFrame.new(position) * CFrame.Angles(0, facing + yawOffset + reactionYaw + habitYaw, reactionRoll + habitRoll))' in companion_service
assert 'while model.Parent == folder and folder.Parent do' in companion_service
assert 'function DisplayPetService:RefreshPlayer(player)' in display_pet_service
assert 'CompanionService:RefreshDisplayedPets(player, plot' in display_pet_service
assert 'elseif interaction == "ToyPlay" then' in display_pet_service
assert 'elseif interaction == "Sleep" then' in display_pet_service

# Sprint 4.66 — personality, social play and owner reactions.
assert 'local personalityProfiles = {' in companion_service
assert '["Игривый"] = { SocialChance = 0.28' in companion_service
assert '["Спокойный"] = { SocialChance = 0.08' in companion_service
assert 'local personalityProfile = personalityProfiles[personality]' in companion_service
assert 'local partnerSlot = slot % 2 == 1 and slot + 1 or slot - 1' in companion_service
assert 'candidate:GetAttribute("DisplaySlot") == partnerSlot' in companion_service
assert 'partnerModel:GetAttribute("NestHomePosition")' in companion_service
assert 'targetPosition = socialApproach' in companion_service
assert 'targetIsSocial and "SeekingFriend"' in companion_service
assert 'behavior = "Socializing"' in companion_service
assert 'socialRewarded = false' in companion_service
assert 'profile.Nest.CompanionMood[instanceId] = mood' in companion_service
assert 'behavior = "Greeting"' in companion_service
assert 'root.Position - currentPosition).Magnitude <= 7' in companion_service
assert 'petDefinition.FavoriteToy' in companion_service
assert 'model:SetAttribute("FavoriteToy"' in companion_service
assert 'model:SetAttribute("DisplaySlot", slot)' in companion_service
assert 'model:SetAttribute("NestHomePosition", home)' in companion_service
assert '(isSleeping and "Zzz")' in companion_service

# Sprint 4.67 — persistent friendship between displayed companions.
assert 'CompanionBonds = {}' in profile_template
assert 'local function getBondKey(firstId, secondId)' in companion_service
assert 'if first > second then first, second = second, first end' in companion_service
assert 'local function getBondLevel(score)' in companion_service
assert 'if score >= 90 then return "Неразлучные" end' in companion_service
assert 'if score >= 60 then return "Лучшие друзья" end' in companion_service
assert 'if score >= 30 then return "Друзья" end' in companion_service
assert 'if score >= 10 then return "Приятели" end' in companion_service
assert 'model:SetAttribute("CompanionInstanceId", companion.InstanceId or "")' in companion_service
assert 'profile.Nest.CompanionBonds = profile.Nest.CompanionBonds or {}' in companion_service
assert 'profile.Nest.CompanionBonds[bondKey] = bondScore' in companion_service
assert 'if slot < partnerSlot then' in companion_service
assert 'partnerModel:SetAttribute("FriendshipScore", bondScore)' in companion_service
assert 'partnerModel:SetAttribute("FriendshipLevel", bondLevel)' in companion_service
assert 'moodBillboard.Size = UDim2.fromOffset(148, 28)' in companion_service
assert 'string.format("♥♥  Дружба %d%%", bondScore)' in companion_service
assert 'not socialRewarded and partnerModel and not partnerSleeping' in companion_service
assert '(partnerModel:GetPivot().Position - currentPosition).Magnitude <= 10' in companion_service
assert 'socialApproach = home:Lerp(partnerHome, 0.5) + towardPartner.Unit * sideOffset' in companion_service
assert 'local sideOffset = slot < partnerSlot and -1.5 or 1.5' in companion_service

# Sprint 4.68 — personality-driven treasure hunts and owner-only gift caches.
assert 'CompanionGiftReadyAt = 0' in profile_template
assert 'local EconomyService = require(ServerScriptService.Server.Services.EconomyService)' in companion_service
assert 'local treasureSearchOwner = nil' in companion_service
assert 'local nextTreasureAt = math.max(os.time() + 20, profile.Nest.CompanionGiftReadyAt)' in companion_service
assert 'TreasureChance = 0.24' in companion_service
assert 'TreasureChance = 0.04' in companion_service
assert 'local canSearch = not giftCache and not treasureSearchOwner' in companion_service
assert 'targetIsTreasure = true' in companion_service
assert 'behavior = targetIsChase and "ChasingFriend" or (targetIsTreasure and "Searching"' in companion_service
assert 'cache.Name = "CompanionGiftCache"' in companion_service
assert 'prompt.Name = "CollectCompanionGift"' in companion_service
assert 'prompt.ActionText = "Забрать подарок"' in companion_service
assert 'if collector ~= player or not player.Parent or giftCache ~= cache or giftCacheClaimed then return end' in companion_service
assert 'EconomyService:GrantCoins(player, reward, "Подарок питомца")' in companion_service
assert 'profile.Nest.CompanionGiftReadyAt = os.time() + 180' in companion_service
assert 'finder.Name .. " принёс подарок: +" .. reward .. " монет!"' in companion_service
assert 'targetIsTreasure = false' in companion_service
assert 'behavior == "FoundGift" and "Нашёл подарок!"' in companion_service


# Sprint 4.71 — favorite places, autonomous nest exploration and discoveries.
for species_id, favorite_place in (
    ("MeadowFox", "Flowers"),
    ("MossTurtle", "Water"),
    ("SproutDragon", "Trees"),
    ("GlowMoth", "Lanterns"),
    ("SnowOwl", "HighGround"),
    ("CaveGlimmerbat", "Crystals"),
    ("HeartWisp", "Crystals"),
):
    species_start = companion_catalog.index(f"    {species_id} = {{")
    species_end = companion_catalog.find("\n    },", species_start)
    assert species_end > species_start
    assert f'FavoritePlace = "{favorite_place}"' in companion_catalog[species_start:species_end]
assert 'local BUILD_INTERESTS = {' in companion_service
assert 'local DECOR_INTERESTS = {' in companion_service
assert 'local function collectInterestPoints(plotModel, home)' in companion_service
assert 'local function chooseInterestPoint(points, favoritePlace, random, previousId)' in companion_service
assert 'local interestPoints = collectInterestPoints(plot.Model, home)' in companion_service
assert 'if now - interestPointsUpdatedAt >= 5 and plot.Model and plot.Model.Parent then' in companion_service
assert 'local canExplore = #interestPoints > 0 and energy >= 25 and hunger >= 25 and mood >= 30' in companion_service
assert 'local explorationChance = (personality == "Любопытный" or personality == "Любознательный") and 0.34 or 0.2' in companion_service
assert 'targetIsInterest = true' in companion_service
assert 'model:SetAttribute("InterestTargetLabel", point.Label)' in companion_service
assert 'targetIsInterest and "Exploring"' in companion_service
assert 'behavior = "VisitingInterest"' in companion_service
assert 'model:SetAttribute("LastDiscovery", discovery)' in companion_service
assert 'player:SetAttribute("LastNotice", companion.Name .. " заметил кое-что интересное: "' in companion_service


# Sprint 4.72 — paired companion adventures and mutual aid.
adventure_service = Path("src/ServerScriptService/Server/Services/CompanionAdventureService.lua").read_text()
assert '"CompanionAdventureService"' in server
assert 'CompanionAdventureCooldowns = {}' in profile_template
assert 'local function getPairKey(firstId, secondId)' in adventure_service
assert 'local function findCompanionModels(player)' in adventure_service
assert 'local function createAdventureMarker(player, firstModel, secondModel, pairKey, rare)' in adventure_service
assert 'local function tryStartAdventure(player)' in adventure_service
assert 'local PAIR_COOLDOWN = 300' in adventure_service
assert 'local MIN_BOND = 10' in adventure_service
assert 'bond >= MIN_BOND' in adventure_service
assert 'local rareChance = choice.Bond >= 90 and 0.20' in adventure_service
assert 'or choice.Bond >= 60 and 0.16' in adventure_service
assert 'or choice.Bond >= 30 and 0.12' in adventure_service
assert 'local rare = random:NextNumber() <= rareChance' in adventure_service
assert 'prompt.Triggered:Connect(function(collector)' in adventure_service
assert 'if claimed or collector ~= player or not player.Parent then return end' in adventure_service
assert '(root.Position - marker.Position).Magnitude > 13' in adventure_service
assert 'profile.Nest.CompanionAdventureCooldowns[choice.Key] = os.time() + PAIR_COOLDOWN' in adventure_service
assert 'profile.Nest.CompanionBonds[pairKey] = score' in adventure_service
assert 'profile.Nest.CompanionMood[firstId]' in adventure_service
assert 'profile.Nest.CompanionMood[secondId]' in adventure_service
assert 'local beam = Instance.new("Beam")' in adventure_service
assert 'firstAttachment:Destroy()' in adventure_service and 'secondAttachment:Destroy()' in adventure_service
assert 'Debris:AddItem(marker, 90)' in adventure_service


# Cross-system companion mood synchronization: adventure rewards must survive the
# CompanionService follower loop and owner disconnect must always remove markers.
assert 'local savedMood = profile.Nest and profile.Nest.CompanionMood' in companion_service
assert 'mood = math.clamp(math.floor(tonumber(savedMood) or mood), 0, 100)' in companion_service
assert 'for _, child in ipairs(Workspace:GetChildren()) do' in adventure_service
assert 'child:GetAttribute("OwnerUserId") == player.UserId' in adventure_service


# Sprint 4.73 — friendship milestone celebrations.
assert 'local BOND_MILESTONES = {' in companion_service
assert '[10] = { Title = "Первые друзья!"' in companion_service
assert '[30] = { Title = "Крепкая дружба!"' in companion_service
assert '[60] = { Title = "Неразлучная команда!"' in companion_service
assert '[90] = { Title = "Друзья навсегда!"' in companion_service
assert 'local function showBondMilestone(player, firstModel, secondModel, milestone)' in companion_service
assert 'glow.Name = "FriendshipMilestoneGlow"' in companion_service
assert 'banner.Name = "FriendshipMilestoneBanner"' in companion_service
assert 'local milestone = BOND_MILESTONES[bondScore]' in companion_service
assert 'if milestone then' in companion_service


# Sprint 4.73 — friendship milestone celebrations.
assert 'local BOND_MILESTONES = {' in companion_service
assert '[10] = { Title = "Первые друзья!"' in companion_service
assert '[30] = { Title = "Крепкая дружба!"' in companion_service
assert '[60] = { Title = "Неразлучная команда!"' in companion_service
assert '[90] = { Title = "Друзья навсегда!"' in companion_service
assert 'local function showBondMilestone(player, firstModel, secondModel, milestone)' in companion_service
assert 'glow.Name = "FriendshipMilestoneGlow"' in companion_service
assert 'banner.Name = "FriendshipMilestoneBanner"' in companion_service
assert 'local milestone = BOND_MILESTONES[bondScore]' in companion_service
assert 'if milestone then' in companion_service


# Sprint 4.74 — visible shared heart emote during completed-pair social play.
assert 'local socialMomentCooldowns = {}' in companion_service
assert 'local function showSharedHeartMoment(firstModel, secondModel)' in companion_service
assert 'bubble.Name = "SharedFriendshipHeart"' in companion_service
assert 'heart.Text = "♥"' in companion_service
assert 'task.delay(1.6, function()' in companion_service
assert 'if slot < partnerSlot and partnerModel then' in companion_service
assert 'socialMomentCooldowns[momentKey] = now + 18' in companion_service
assert 'showSharedHeartMoment(model, partnerModel)' in companion_service
assert 'local cooldownPrefix = tostring(player.UserId) .. ":"' in companion_service
assert 'if string.sub(key, 1, #cooldownPrefix) == cooldownPrefix then' in companion_service


# Sprint 4.75 — personality and familiarity influence social behavior.
assert 'local partnerPersonality = partnerModel and partnerModel:GetAttribute("Personality") or ""' in companion_service
assert 'local pairBondScore = pairBondKey and profile.Nest and profile.Nest.CompanionBonds' in companion_service
assert 'local isCautious = personality == "Осторожный"' in companion_service
assert 'local isSocialLeader = personality == "Дружелюбный" or personality == "Добродушный"' in companion_service
assert 'model:SetAttribute("FriendshipStyle", friendshipStyle)' in companion_service
assert 'local cautiousCanApproach = not isCautious or pairBondScore >= 10' in companion_service
assert 'or partnerPersonality == "Дружелюбный" or partnerPersonality == "Добродушный"' in companion_service
assert 'or random:NextNumber() < 0.035' in companion_service
assert 'local bondSocialBonus = math.min(pairBondScore / 100, 1) * 0.18' in companion_service
assert 'local outgoingBonus = isSocialLeader and 0.12 or 0' in companion_service
assert 'random:NextNumber() < effectiveSocialChance' in companion_service


# Sprint 4.76 — established friends can trigger a short shared chase.
assert 'local socialChaseCooldowns = {}' in companion_service
assert 'local targetIsChase = false' in companion_service
assert 'if slot < partnerSlot and partnerModel and pairBondScore >= 30' in companion_service
assert 'socialChaseCooldowns[chaseKey] = now + 35' in companion_service
assert 'local chaseUntil = now + 4.5' in companion_service
assert 'model:SetAttribute("CompanionChaseUntil", chaseUntil)' in companion_service
assert 'partnerModel:SetAttribute("CompanionChaseUntil", chaseUntil)' in companion_service
assert 'local partnerPositionForChase = partnerModel and partnerModel:GetPivot().Position' in companion_service
assert 'local chaseRadius = 2.4' in companion_service
assert 'targetIsChase and "ChasingFriend"' in companion_service
assert 'and not isSleeping and not partnerSleeping and mood >= 25 and energy >= 15 then' in companion_service
assert 'for key in pairs(socialChaseCooldowns) do' in companion_service


# Sprint 4.77 — bonded companion can quietly rest beside a sleeping friend.
assert 'local sharedRestCooldowns = {}' in companion_service
assert 'local targetIsRestingTogether = false' in companion_service
assert 'local restingTogetherUntil = 0' in companion_service
assert 'local canRestTogether = partnerModel and partnerSleeping and not isSleeping' in companion_service
assert 'and pairBondScore >= 30 and (isNight or energy <= 35)' in companion_service
assert 'targetIsRestingTogether = true' in companion_service
assert 'restingTogetherUntil = now + random:NextNumber(4.5, 6.5)' in companion_service
assert 'model:SetAttribute("RestingWithFriend", true)' in companion_service
assert 'behavior = "RestingWithFriend"' in companion_service
assert 'model:SetAttribute("RestingWithFriend", nil)' in companion_service
assert 'if targetIsRestingTogether and (not partnerModel or not partnerSleeping) then' in companion_service
assert 'for key in pairs(sharedRestCooldowns) do' in companion_service


# Sprint 4.78 — personality-specific greetings and reunion presentation.
assert 'local pairGreetingLastAt = {}' in companion_service
assert 'local GREETING_STYLES = {' in companion_service
assert '["Дружелюбный"] = { Icon = "♥"' in companion_service
assert '["Игривый"] = { Icon = "✦"' in companion_service
assert '["Осторожный"] = { Icon = "…"' in companion_service
assert 'local function showPersonalityGreeting(firstModel, secondModel, firstPersonality, secondPersonality, reunion)' in companion_service
assert 'bubble.Name = reunion and "FriendshipReunionGreeting" or "PersonalityGreeting"' in companion_service
assert 'local isReunion = lastGreeting > 0 and (now - lastGreeting) >= 120' in companion_service
assert 'showPersonalityGreeting(' in companion_service
assert 'glow.Name = "FriendshipReunionGlow"' in companion_service
assert 'for key in pairs(pairGreetingLastAt) do' in companion_service


# Sprint 4.79 — species-specific friendship moments and persistent discoveries.
assert 'local speciesMomentCooldowns = {}' in companion_service
assert 'local SPECIES_BOND_MOMENTS = {' in companion_service
assert '["Fox|Turtle"] = { Title = "Лесные хранители"' in companion_service
assert '["Dragon|Owl"] = { Title = "Искра мудрости"' in companion_service
assert '["EmberFox|MagmaDragon"] = { Title = "Тёплое пламя"' in companion_service
assert '["AncientStag|RootSprite"] = { Title = "Древний союз"' in companion_service
assert 'model:SetAttribute("CompanionKind", definition.Kind or companion.Id)' in companion_service
assert 'local function getSpeciesMomentKey(firstKind, secondKind)' in companion_service
assert 'local function showSpeciesBondMoment(firstModel, secondModel, moment)' in companion_service
assert 'local speciesMoment = speciesKey and SPECIES_BOND_MOMENTS[speciesKey]' in companion_service
assert 'if speciesMoment and pairBondScore >= 30 then' in companion_service
assert 'and random:NextNumber() < 0.35 then' in companion_service
assert 'profile.Nest.DiscoveredBondMoments = profile.Nest.DiscoveredBondMoments or {}' in companion_service
assert 'profile.Nest.DiscoveredBondMoments[speciesKey] = true' in companion_service
assert 'model:SetAttribute("SpeciesBondMoment", moment.Title)' in companion_service
assert 'model:SetAttribute("SpeciesBondMomentUntil", os.clock() + 3.4)' in companion_service
assert 'for key in pairs(speciesMomentCooldowns) do' in companion_service


# Sprint 4.80 — persistent friendship discovery journal.
bond_journal_service = Path("src/ServerScriptService/Server/Services/BondJournalService.lua").read_text()
profile_template = Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
assert '"BondJournal"' in server
assert '"BondJournalService"' in server
assert 'local bondJournalRemote = waitRemote("BondJournal")' in client
assert 'bondJournalRemote and nestRemote' in client
assert 'local bondJournalButton = Instance.new("TextButton")' in client
assert 'artifactsButton, bondJournalButton, profileButton' in client
assert 'Kind = "heart"' in client and 'kind == "heart"' in client
assert 'local bondJournalPanel = Instance.new("Frame")' in client
assert 'local function invokeBondJournal()' in client
assert 'local function renderBondJournal(data)' in client
assert 'bondJournalButton.Activated:Connect(openBondJournal)' in client
assert 'DiscoveredBondMoments = {},' in profile_template
assert 'local function buildSnapshot(profile)' in bond_journal_service
assert 'profile.Nest.DiscoveredBondMoments' in bond_journal_service
assert 'CompletionPercent = math.floor(discoveredCount / total * 100 + 0.5)' in bond_journal_service
assert 'Title = discovered and definition.Title or "???"' in bond_journal_service
assert 'Hint = discovered and "Секрет уже открыт.' in bond_journal_service


# Sprint 4.81 — visible friendship tiers and tier-based adventure rewards.
adventure_service = Path("src/ServerScriptService/Server/Services/CompanionAdventureService.lua").read_text()
assert 'local friendshipBillboard = Instance.new("BillboardGui")' in companion_service
assert 'friendshipBillboard.Enabled = bondKey ~= nil and bondScore > 0' in companion_service
assert 'friendshipText.Text = string.format("♥ %s  ·  %d/100", bondLevel, bondScore)' in companion_service
assert 'friendshipFill.Size = UDim2.new(bondScore / 100, 0, 1, 0)' in companion_service
assert 'local bondLevel = getBondLevel(score)' in adventure_service
assert 'Bond = bond' in adventure_service
assert 'local rareChance = choice.Bond >= 90 and 0.20' in adventure_service
assert 'or choice.Bond >= 60 and 0.16' in adventure_service
assert 'or choice.Bond >= 30 and 0.12' in adventure_service
assert 'or 0.08' in adventure_service
assert 'firstModel:SetAttribute("FriendshipLevel", bondLevel)' in adventure_service
assert 'secondModel:SetAttribute("FriendshipLevel", bondLevel)' in adventure_service


# Sprint 4.82 — companion gifts, personality odds and memory collection.
companion_service = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
gift_journal = Path("src/ServerScriptService/Server/Services/BondJournalService.lua").read_text()
profile_template = Path("src/ReplicatedStorage/Shared/Config/ProfileTemplate.lua").read_text()
assert 'local BIOME_GIFTS = {' in companion_service
for egg_id in ("MeadowEgg", "EmeraldEgg", "FrostEgg", "EmberEgg", "CrystalEgg", "AncientEgg", "ForgottenCaveEgg", "LineageEgg"):
    assert egg_id + ' = {' in companion_service
assert 'local PERSONALITY_GIFT_BONUS = {' in companion_service
assert 'local function tryGiveCompanionGift(' in companion_service
assert 'local chance = bondScore >= 90 and 0.30' in companion_service
assert 'or bondScore >= 60 and 0.22' in companion_service
assert 'or bondScore >= 30 and 0.14' in companion_service
assert 'or bondScore >= 10 and 0.08' in companion_service
assert 'GIFT_COOLDOWNS[cooldownKey] = now + 90' in companion_service
assert 'profile.Nest.DiscoveredCompanionGifts[giftKey] = true' in companion_service
assert 'profile.Nest.CompanionGiftCount' in companion_service
assert 'receiverModel:SetAttribute("Mood", receiverMood)' in companion_service
assert 'giverModel:SetAttribute("Mood", giverMood)' in companion_service
assert 'showCompanionGift(giverModel, receiverModel, gift, isRare)' in companion_service
assert 'tryGiveCompanionGift(' in companion_service
assert 'DiscoveredCompanionGifts = {},' in profile_template
assert 'CompanionGiftCount = 0,' in profile_template
assert 'local GIFT_COLLECTION = {' in gift_journal
assert 'profile.Nest.DiscoveredCompanionGifts' in gift_journal
assert 'local giftTotal = 0' in gift_journal
assert 'Id = "gift:" .. key' in gift_journal
assert 'local total = #MOMENTS + pairTotal + giftTotal' in gift_journal

assert 'local partnerDefinition = CompanionCatalog[partnerModel:GetAttribute("CompanionId")] or {}' in companion_service
assert 'if random:NextNumber() < 0.5 then' in companion_service
assert 'player, profile, partnerModel, model, partnerDefinition' in companion_service
assert 'local giftKey = tostring(giverDefinition.EggId or "MeadowEgg") .. ":" .. gift.Name' in companion_service
assert 'giftDiscoveries[key] == true' in gift_journal
assert 'Открыто воспоминаний: %d / %d  ·  %d%%' in client

assert 'local RARITY_SPECIAL_GIFT_BONUS = {' in companion_service
assert '["Редкий"] = 0.04' in companion_service
assert '["Эпический"] = 0.07' in companion_service
assert '["Легендарный"] = 0.10' in companion_service
assert '["Мифический"] = 0.14' in companion_service
assert 'rareChance = math.clamp(rareChance + (RARITY_SPECIAL_GIFT_BONUS[giverDefinition.Rarity or ""] or 0), 0.02, 0.35)' in companion_service


# Sprint 4.83 — personality-driven gift reactions and paired pet emotes.
assert 'local GIFT_RECEIVER_REACTIONS = {' in companion_service
assert 'local GIFT_GIVER_REACTIONS = {' in companion_service
assert 'local function setGiftReaction(model, reaction, duration, rare)' in companion_service
assert 'model:SetAttribute("GiftReaction", reaction.Animation)' in companion_service
assert 'model:SetAttribute("GiftReactionUntil", os.clock() + duration)' in companion_service
assert 'receiverReaction = { Animation = "Amazed", Text = "Невероятный подарок!" }' in companion_service
assert 'giverReaction = { Animation = "Proud", Text = "Я нашёл нечто особенное!" }' in companion_service
assert 'setGiftReaction(receiverModel, receiverReaction, duration, isRare)' in companion_service
assert 'setGiftReaction(giverModel, giverReaction, duration * 0.9, isRare)' in companion_service
assert 'local reactionActive = giftReaction ~= nil and now < reactionUntil and not isSleeping' in companion_service
assert 'giftReaction == "Jump" or giftReaction == "Bounce"' in companion_service
assert 'giftReaction == "Spin"' in companion_service
assert 'giftReaction == "Hug"' in companion_service
assert 'giftReaction == "Amazed"' in companion_service
assert 'local hugOffset = Vector3.zero' in companion_service
assert 'hugOffset = towardFriend.Unit * 0.38' in companion_service
assert 'behavior = giftReaction == "Hug" and "HuggingFriend" or "CelebratingGift"' in companion_service
assert 'model:SetAttribute("GiftReaction", nil)' in companion_service


# Sprint 4.84 — autonomous personality habits in quiet nest moments.
assert 'local COMPANION_HABITS = {' in companion_service
for personality, habit_id in (
    ("Любопытный", "SniffAround"),
    ("Любознательный", "Inspect"),
    ("Игривый", "PlayfulHop"),
    ("Энергичный", "Stretch"),
    ("Спокойный", "Groom"),
    ("Осторожный", "LookAround"),
    ("Мечтательный", "Daydream"),
    ("Наблюдательный", "WatchSky"),
    ("Добродушный", "Sway"),
    ("Дружелюбный", "Wave"),
    ("Заботливый", "Care"),
    ("Гордый", "Proud"),
):
    assert f'["{personality}"] = {{ Id = "{habit_id}"' in companion_service
assert 'local activeHabit = nil' in companion_service
assert 'local nextHabitAt = os.clock() + random:NextNumber(8, 16)' in companion_service
assert 'activeHabitUntil = now + random:NextNumber(2.2, 4.0)' in companion_service
assert 'nextHabitAt = now + random:NextNumber(28, 52)' in companion_service
assert 'model:SetAttribute("PersonalHabit", habit.Id)' in companion_service
assert 'model:SetAttribute("PersonalHabitText", habit.Text)' in companion_service
assert 'local habitActive = activeHabit ~= nil and now < activeHabitUntil and isAtTarget and not isSleeping' in companion_service
assert 'behavior = "PersonalHabit"' in companion_service
assert 'model:SetAttribute("PersonalHabit", nil)' in companion_service
assert 'activeHabit = nil' in companion_service
assert 'local habitPhase = now * 2.4 + phase' in companion_service
assert 'local habitBob, habitYaw, habitRoll = 0, 0, 0' in companion_service
assert 'or (habitActive and model:GetAttribute("PersonalHabitText"))' in companion_service


# Sprint 4.85 — pair-specific friendship milestones and persistent shared memories.
assert '[80] = { Title = "Дружба без границ!"' in companion_service
assert '[100] = { Title = "Вместе навеки!"' in companion_service
assert 'local PAIR_BOND_MEMORIES = {' in companion_service
assert '[60] = { Id = "TrustedPact"' in companion_service
assert '[80] = { Id = "UnbreakablePromise"' in companion_service
assert '[100] = { Id = "ForeverTogether"' in companion_service
assert 'local memoryKey = "Pair:" .. bondKey .. ":" .. pairMemory.Id' in companion_service
assert 'profile.Nest.DiscoveredBondMoments[memoryKey] = true' in companion_service
assert 'showSharedHeartMoment(model, partnerModel)' in companion_service
assert 'Новое воспоминание дружбы:' in companion_service
assert 'Новое воспоминание дружбы:' in companion_service
assert 'local PAIR_MEMORIES = {' in gift_journal
assert 'RequiredBond = 60, Id = "TrustedPact"' in gift_journal
assert 'RequiredBond = 80, Id = "UnbreakablePromise"' in gift_journal
assert 'RequiredBond = 100, Id = "ForeverTogether"' in gift_journal
assert 'local companionBonds = type(profile.Nest.CompanionBonds) == "table"' in gift_journal
assert 'local key = "Pair:" .. tostring(bondKey) .. ":" .. memory.Id' in gift_journal
assert 'local total = #MOMENTS + pairTotal + giftTotal' in gift_journal


# Sprint 4.86 — bonded companions comfort friends and explore together.
assert 'local companionCareCooldowns = {}' in companion_service
assert 'local sharedDiscoveryCooldowns = {}' in companion_service
assert 'local targetIsCaring = false' in companion_service
assert 'local careUntil = 0' in companion_service
assert 'partnerMood <= 35 and mood >= 45' in companion_service
assert 'pairBondScore >= 10 and socialApproach' in companion_service
assert 'personality == "Заботливый" and 0.72 or 0.28' in companion_service
assert 'partnerModel:SetAttribute("BeingComfortedUntil", careUntil)' in companion_service
assert 'profile.Nest.CompanionMood[partnerId] = updatedPartnerMood' in companion_service
assert 'profile.Nest.CompanionMood[instanceId] = mood' in companion_service
assert 'beingComforted and "Друг рядом, всё хорошо ♥"' in companion_service
assert 'careUntil > now and "Утешает друга ♥"' in companion_service
assert 'partnerModel:SetAttribute("SharedDiscoveryTargetPosition", point.Position)' in companion_service
assert 'partnerModel:SetAttribute("SharedDiscoveryLeader", instanceId)' in companion_service
assert 'local followingSharedDiscovery = typeof(sharedTarget) == "Vector3"' in companion_service
assert 'if followingSharedDiscovery then' in companion_service
assert 'model:SetAttribute("SharedDiscoveryArrived", true)' in companion_service
assert 'partnerModel:GetAttribute("SharedDiscoveryArrived") == true' in companion_service
assert 'partnerModel:GetPivot().Position - currentPosition).Magnitude <= 6' in companion_service
assert 'model:SetAttribute("LastDiscovery", "Открытие вместе: "' in companion_service
assert 'showSharedHeartMoment(model, partnerModel)' in companion_service
assert 'sharedDiscoveryCooldowns[sharedKey] = now + 90' in companion_service

assert 'if careUntil > 0 and partnerModel' in companion_service
assert 'partnerModel:GetAttribute("BeingComfortedBy") == instanceId' in companion_service
assert 'model:GetAttribute("SharedDiscoveryArrived") ~= true and partnerModel' in companion_service
assert 'partnerModel:SetAttribute("SharedDiscoveryArrived", nil)' in companion_service

assert 'local sharedDiscoveryLeaderUntil = 0' in companion_service
assert 'sharedDiscoveryLeaderUntil = now + 18' in companion_service
assert '(currentPosition - sharedDiscoveryLeaderTarget).Magnitude <= 6' in companion_service
assert 'sharedDiscoveryLeaderUntil = 0' in companion_service


# Sprint 4.87 — bonded companions can play a short server-owned ball-passing game.
assert 'local pairedBallCooldowns = {}' in companion_service
assert 'local function showPairedBallGame(firstModel, secondModel, ownerUserId, pairKey, personality, now)' in companion_service
assert 'ball.Name = "CompanionFriendshipBall"' in companion_service
assert 'ball:SetAttribute("OwnerUserId", ownerUserId)' in companion_service
assert 'ball:SetAttribute("PairKey", pairKey)' in companion_service
assert 'ball.CanCollide = false' in companion_service
assert 'TweenService:Create(' in companion_service
assert 'TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)' in companion_service
assert 'if pairBondScore >= 10 then' in companion_service
assert 'local ballChance = (personality == "Игривый" or personality == "Энергичный"' in companion_service
assert 'pairedBallCooldowns[ballGameKey] = now + 45' in companion_service
assert 'for key in pairs(pairedBallCooldowns) do' in companion_service


# Sprint 4.87 — hide and seek and cooperative toy play.
for token in (
    'local hideSeekCooldowns = {}',
    'local function clearHideSeek(model)',
    'partnerModel:GetAttribute("HideSeekPartner") == instanceId',
    'pet:SetAttribute("HideSeekUntil", now + 12)',
    'hideSeekCooldowns[hideKey] = now + 60',
    'behavior = hideRole == "Hider" and "HidingFromFriend"',
    'local sharedToyCooldowns = {}',
    'partnerModel:GetAttribute("SharedToyPartner") == instanceId',
    'pet:SetAttribute("SharedToyUntil", now + 10)',
    'sharedToyCooldowns[sharedToyKey] = now + 60',
    'behavior = "PlayingSharedToy"',
    'sharedToy:SetAttribute("ToyState", "InUse")',
    'for key in pairs(sharedToyCooldowns) do',
    'for key in pairs(hideSeekCooldowns) do',
):
    assert token in companion_service, token
