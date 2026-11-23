"""Static regression checks for the playable Roblox Studio package.

These checks catch known UI boot and placement mistakes; they do not replace Studio Play tests.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

client = Path("src/StarterPlayer/StarterPlayerScripts/ClientBootstrap.client.lua").read_text()
server = Path("src/ServerScriptService/Server/Bootstrap.server.lua").read_text()
watchdog = Path("src/StarterPlayer/StarterPlayerScripts/BootRecovery.client.lua").read_text()
world = Path("src/ServerScriptService/Server/World/WorldBuilder.lua").read_text()
plots = Path("src/ServerScriptService/Server/Services/PlotService.lua").read_text()
eggs = Path("src/ServerScriptService/Server/Services/EggService.lua").read_text()
companions = Path("src/ServerScriptService/Server/Services/CompanionService.lua").read_text()
inventory = Path("src/ServerScriptService/Server/Services/InventoryService.lua").read_text()
assert 'if payload.Action ~= "Get" then' in inventory, "Read-only inventory snapshots must bypass cooldown"
assert 'REQUEST_COOLDOWN' in inventory, "Mutation cooldown must remain active"
assert 'GetAttributeChangedSignal("CompanionCount"):Connect(function()' in client
assert 'if inventoryPanel.Visible then' in client and 'if bookPanel.Visible then' in client
assert 'refreshingCompanionWindows = false' in client

assert 'local function bindPlayer(player)' in companions, "Companion service must bind early joiners"
assert 'Players.PlayerAdded:Connect(bindPlayer)' in companions
assert 'player.CharacterAdded:Connect(function()' in companions
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
print("Playable-first static regression checks passed. Roblox Studio runtime still required.")
