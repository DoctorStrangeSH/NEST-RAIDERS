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
        { Id = "StarterIsland", DisplayName = "Стартовый остров", RequiredLevel = 1, RequiredQuest = nil },
        { Id = "EmeraldWilds", DisplayName = "Изумрудный лес", RequiredLevel = 5, RequiredQuest = nil },
        { Id = "FrostHighlands", DisplayName = "Ледяные нагорья", RequiredLevel = 12, RequiredQuest = "emerald_trial" },
        { Id = "Emberlands", DisplayName = "Пепельные земли", RequiredLevel = 22, RequiredQuest = "frost_trial" },
        { Id = "CrystalRealm", DisplayName = "Хрустальное королевство", RequiredLevel = 35, RequiredQuest = "ember_trial" },
        { Id = "AncientHeights", DisplayName = "Древние высоты", RequiredLevel = 50, RequiredQuest = "crystal_trial" },
        { Id = "VoidFrontier", DisplayName = "Граница пустоты", RequiredLevel = 75, RequiredQuest = "ancient_temple_boss" },
    },
}

-- One complete in-game day lasts 24 real minutes. Server Lighting replicates the clock to all clients.
GameConfig.WorldCycle = {
    Enabled = true,
    SecondsPerGameHour = 60,
    StartClockTime = 14,
    DayStartsAt = 6,
    NightStartsAt = 19,
}

-- Weather changes on the Starter Island every few real minutes.
GameConfig.Weather = {
    Enabled = true,
    MinDurationSeconds = 120,
    MaxDurationSeconds = 210,
    -- Weights are relative; clear weather remains the most common.
    Types = {
        { Id = "Clear", Label = "Ясно", Weight = 48 },
        { Id = "Rain", Label = "Дождь", Weight = 27 },
        { Id = "Fog", Label = "Туман", Weight = 15 },
        { Id = "Storm", Label = "Гроза", Weight = 10 },
    },
}

GameConfig.Economy = {
    StartingCoins = 100,
    MaxCoins = 2_000_000_000,
    PassiveIncomeIntervalSeconds = 10,
}

return GameConfig
