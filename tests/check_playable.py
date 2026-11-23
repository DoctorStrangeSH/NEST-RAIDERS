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

print("Playable-first static regression checks passed. Roblox Studio runtime still required.")
