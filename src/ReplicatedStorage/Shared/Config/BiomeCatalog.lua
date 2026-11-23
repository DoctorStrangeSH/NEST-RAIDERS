-- Biome-owned egg tables keep species odds explicit and easy to balance.
-- Future biomes can add their own egg definitions without changing hatch logic.
local BiomeCatalog = {
    Meadow = {
        Id = "Meadow",
        Name = "Зелёный луг",
        DefaultEggId = "MeadowEgg",
        Eggs = {
            MeadowEgg = {
                Id = "MeadowEgg",
                Name = "Яйцо луга",
                Rarity = "Обычное",
                SpeciesWeights = {
                    MeadowFox = 55,
                    MossTurtle = 30,
                    SproutDragon = 15,
                },
            },
        },
    },
    FrostHighlands = {
        Id = "FrostHighlands",
        Name = "Ледяные нагорья",
        DefaultEggId = "FrostEgg",
        Eggs = {
            FrostEgg = {
                Id = "FrostEgg",
                Name = "Яйцо вечной зимы",
                Rarity = "Редкое",
                SpeciesWeights = {
                    FrostFox = 60,
                    SnowOwl = 30,
                    GlacierBear = 10,
                },
            },
        },
    },
    Emberlands = {
        Id = "Emberlands",
        Name = "Пепельные земли",
        DefaultEggId = "EmberEgg",
        Eggs = {
            EmberEgg = {
                Id = "EmberEgg",
                Name = "Яйцо пепельного пламени",
                Rarity = "Эпическое",
                SpeciesWeights = {
                    CinderFox = 60,
                    MagmaWhelp = 30,
                    AshPhoenix = 10,
                },
            },
        },
    },
    EmeraldWilds = {
        Id = "EmeraldWilds",
        Name = "Изумрудный лес",
        DefaultEggId = "EmeraldEgg",
        Eggs = {
            EmeraldEgg = {
                Id = "EmeraldEgg",
                Name = "Яйцо древней рощи",
                Rarity = "Необычное",
                SpeciesWeights = {
                    EmeraldFox = 50,
                    GlowMoth = 32,
                    AncientSprout = 18,
                },
            },
        },
    },
}
return BiomeCatalog
