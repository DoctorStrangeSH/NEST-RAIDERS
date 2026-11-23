local ArtifactCatalog = {
    RootSigil = {
        Id = "RootSigil", Name = "Печать древнего корня", Rarity = "Обычный",
        Description = "Усиливает пассивный доход активных питомцев на 3%.",
        IncomeBonus = 0.03, Weight = 48,
    },
    MoonPendant = {
        Id = "MoonPendant", Name = "Лунный кулон", Rarity = "Редкий",
        Description = "Усиливает пассивный доход активных питомцев на 6%.",
        IncomeBonus = 0.06, Weight = 24,
    },
    StarPrism = {
        Id = "StarPrism", Name = "Звёздная призма", Rarity = "Эпический",
        Description = "Усиливает пассивный доход активных питомцев на 10%.",
        IncomeBonus = 0.10, Weight = 8,
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
}
return ArtifactCatalog
