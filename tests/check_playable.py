"""Static regression checks for the playable Roblox Studio package.

These checks catch known UI boot and placement mistakes; they do not replace Studio Play tests.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

client = Path("src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua").read_text()
assert 'player.CameraMinZoomDistance = 7' in client
assert 'player.CameraMaxZoomDistance = 24' in client
assert 'ResponsiveHudScale' in client and 'camera:GetPropertyChangedSignal("ViewportSize")' in client
assert 'МЕНЮ' in client and '☰  МЕНЮ' not in client
assert '🪙' not in client, "Avoid unsupported currency emoji glyphs in UI"

server = Path("src/ServerScriptService/Server/Bootstrap.server.lua").read_text()
watchdog = Path("src/StarterPlayer/StarterPlayerScripts/BootRecovery.client.lua").read_text()
world = Path("src/ServerScriptService/Server/World/WorldBuilder.lua").read_text()
plots = Path("src/ServerScriptService/Server/Services/PlotService.lua").read_text()
build_service = Path("src/ServerScriptService/Server/Services/NestBuildService.lua").read_text()
assert 'local folder = island:FindFirstChild("PlayerPlots")' in plots
assert 'local ok, model, station, ownerLabel = pcall(buildPlot, folder, definition)' in plots
assert 'folder:SetAttribute("CreatedCount", created)' in plots
assert 'folder:SetAttribute("ExpectedCount", #PLOT_DEFINITIONS)' in plots
assert 'return self._initialized, created' in plots
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
assert 'chooseCompanion(egg.Id or "MeadowEgg")' in eggs
assert 'BiomeId = egg:GetAttribute("BiomeId") or "Meadow"' in eggs
assert 'OriginBiome = egg.BiomeId or "Meadow"' in eggs



companions = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
inventory = Path("src/ServerScriptService/Server/Services/InventoryService.lua").read_text()
book = Path("src/ServerScriptService/Server/Services/CollectionBookService.lua").read_text()
assert 'profile.DiscoveredBiomes[companion.Id] = companion.OriginBiome or "Meadow"' in eggs
assert 'local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)' in book
assert 'BiomeName = biomeName' in book and 'DiscoveredBiome = profile.DiscoveredBiomes[definition.Id]' in book
assert 'speciesWeight / totalWeight * 100' in book
assert 'entry.DiscoveredBiome' in client and 'entry.EggName' in client

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
assert 'ELDERWOOD_COST = 10' in ancient_crafting and 'COIN_COST = 300' in ancient_crafting
assert 'EGG_CAPACITY = 20' in ancient_crafting and 'profile.EggInventory' in ancient_crafting
assert 'ProgressionService:CanEnterZone(player, "AncientHeights")' in ancient_crafting
assert 'CraftAncientEggPrompt' in ancient_crafting and 'MaxActivationDistance + 2' in ancient_crafting
assert 'REQUEST_COOLDOWN_SECONDS = 1.5' in ancient_crafting and 'LAST_REQUEST_AT' in ancient_crafting
assert 'Id = EGG_ID' in ancient_crafting and 'BiomeId = "AncientHeights"' in ancient_crafting
assert 'profile.Materials.Elderwood = elderwood - ELDERWOOD_COST' in ancient_crafting
assert 'profile.Coins = coins - COIN_COST' in ancient_crafting
assert 'EggCount' in ancient_crafting and 'Elderwood' in ancient_crafting and 'Coins' in ancient_crafting
assert 'ElderwoodWorkshop' in world and 'AncientEggCraftingStation' in world
assert 'CraftAncientEggPrompt' in world and 'РЕЦЕПТ ДРЕВНОГО ЯЙЦА' in world
assert 'Нет мастерской создания древних яиц' in world_health


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
assert 'Корень → Река → Рассвет' in world
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
assert 'local function chooseCompanion(eggId)' in Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()

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

print("Playable-first static regression checks passed. Roblox Studio runtime still required.")
