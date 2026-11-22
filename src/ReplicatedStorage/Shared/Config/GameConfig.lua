local GameConfig = {}

GameConfig.DataStoreName = "NestRaiders_PlayerData_v1"
GameConfig.DataSchemaVersion = 1
GameConfig.AutosaveIntervalSeconds = 60
-- Keep false for instant local Studio testing without publishing or API access.
-- Set true only in a private published test experience with Studio API access enabled.
GameConfig.UseStudioDataStore = false

GameConfig.Progression = {
    MaxLevel = 100,
    BaseXPToNextLevel = 100,
    XPScalePerLevel = 1.18,
    Zones = {
        { Id = "StarterIsland", DisplayName = "Starter Island", RequiredLevel = 1, RequiredQuest = nil },
        { Id = "EmeraldWilds", DisplayName = "Emerald Wilds", RequiredLevel = 5, RequiredQuest = "starter_explorer" },
        { Id = "FrostHighlands", DisplayName = "Frost Highlands", RequiredLevel = 12, RequiredQuest = "emerald_trial" },
        { Id = "Emberlands", DisplayName = "Emberlands", RequiredLevel = 22, RequiredQuest = "frost_trial" },
        { Id = "CrystalRealm", DisplayName = "Crystal Realm", RequiredLevel = 35, RequiredQuest = "ember_trial" },
        { Id = "AncientHeights", DisplayName = "Ancient Heights", RequiredLevel = 50, RequiredQuest = "crystal_trial" },
        { Id = "VoidFrontier", DisplayName = "Void Frontier", RequiredLevel = 75, RequiredQuest = "ancient_trial" },
    },
}

GameConfig.Economy = {
    StartingCoins = 100,
    MaxCoins = 2_000_000_000,
    PassiveIncomeIntervalSeconds = 10,
}

return GameConfig
