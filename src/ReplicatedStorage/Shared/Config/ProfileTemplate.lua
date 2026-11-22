local ProfileTemplate = {
    SchemaVersion = 1,
    Coins = 100,
    XP = 0,
    Level = 1,
    UnlockedZones = {
        StarterIsland = true,
    },
    CompletedQuests = {},
    EggInventory = {},
    Companions = {},
    ActiveCompanions = {},
    Nest = {
        Level = 1,
        PlotId = nil,
        DisplayedCompanions = {},
        StoredCoins = 0,
        CompanionMood = {},
        CompanionNeeds = {},
        CompanionToys = {},
        DecorInventory = {},
        PlacedDecor = {},
        BuildInventory = {},
        PlacedBuildings = {},
        NextBuildingId = 0,
        IslandLikesByUserId = {},
        FavoriteIslandUserIds = {},
        IslandTrophies = {},
        EquippedTitle = "",
    },
    Settings = {
        MusicEnabled = true,
        EffectsEnabled = true,
        ReducedMotion = false,
    },
}

return ProfileTemplate
