local ArtifactCatalog = {
    RootSigil = {
        Id = "RootSigil", Name = "Печать древнего корня", Rarity = "Обычный",
        Description = "Усиливает пассивный доход активных питомцев на 3%.",
        IncomeBonus = 0.03, Weight = 36,
    },
    MoonPendant = {
        Id = "MoonPendant", Name = "Лунный кулон", Rarity = "Редкий",
        Description = "Усиливает пассивный доход активных питомцев на 6%.",
        IncomeBonus = 0.06, Weight = 18,
    },
    StarPrism = {
        Id = "StarPrism", Name = "Звёздная призма", Rarity = "Эпический",
        Description = "Усиливает пассивный доход активных питомцев на 10%.",
        IncomeBonus = 0.10, Weight = 6,
    },
    RootHarvester = {
        Id = "RootHarvester", Name = "Серп древних корней", Rarity = "Обычный",
        Description = "Даёт шанс получить больше материалов при сборе ресурсов.",
        GatherBonus = 0.05, Weight = 12,
    },
    MoonForager = {
        Id = "MoonForager", Name = "Лунный собиратель", Rarity = "Редкий",
        Description = "Увеличивает дополнительную добычу ресурсов при сборе.",
        GatherBonus = 0.10, Weight = 6,
    },
    StarProspector = {
        Id = "StarProspector", Name = "Звёздный геодезист", Rarity = "Эпический",
        Description = "Сильно повышает шанс получить дополнительные материалы.",
        GatherBonus = 0.15, Weight = 2,
    },
    FieldJournal = {
        Id = "FieldJournal", Name = "Полевой дневник", Rarity = "Обычный",
        Description = "Увеличивает получаемый опыт игрока на 5%.",
        ResearchBonus = 0.05, Weight = 6,
    },
    MoonAtlas = {
        Id = "MoonAtlas", Name = "Лунный атлас", Rarity = "Редкий",
        Description = "Увеличивает получаемый опыт игрока на 10%.",
        ResearchBonus = 0.10, Weight = 3,
    },
    StarCompass = {
        Id = "StarCompass", Name = "Звёздный компас", Rarity = "Эпический",
        Description = "Увеличивает получаемый опыт игрока на 15%.",
        ResearchBonus = 0.15, Weight = 1,
    },
    HunterTrophy = {
        Id = "HunterTrophy", Name = "Охотничий трофей", Rarity = "Обычный",
        Description = "Увеличивает шанс вылупить питомца высшей редкости из яйца.",
        HatchBonus = 0.05, Weight = 6,
    },
    MoonTracker = {
        Id = "MoonTracker", Name = "Лунный следопыт", Rarity = "Редкий",
        Description = "Увеличивает шанс вылупить питомца высшей редкости из яйца.",
        HatchBonus = 0.10, Weight = 3,
    },
    HunterCrown = {
        Id = "HunterCrown", Name = "Корона охотника", Rarity = "Эпический",
        Description = "Значительно увеличивает шанс вылупить питомца высшей редкости из яйца.",
        HatchBonus = 0.15, Weight = 1,
    },
}
return ArtifactCatalog
