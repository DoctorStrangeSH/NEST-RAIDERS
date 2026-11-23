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
    CrystalRealm = {
        Id = "CrystalRealm",
        Name = "Хрустальное королевство",
        DefaultEggId = "CrystalEgg",
        Eggs = {
            CrystalEgg = {
                Id = "CrystalEgg",
                Name = "Яйцо призматического сияния",
                Rarity = "Легендарное",
                SpeciesWeights = {
                    PrismFox = 60,
                    CrystalDeer = 30,
                    AuroraDragon = 10,
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
    ForgottenCave = {
        Id = "ForgottenCave",
        Name = "Пещера забытого сердца",
        DefaultEggId = "ForgottenCaveEgg",
        Eggs = {
            ForgottenCaveEgg = {
                Id = "ForgottenCaveEgg",
                Name = "Яйцо забытого сердца",
                Rarity = "Легендарное",
                SpeciesWeights = {
                    CaveGlimmerbat = 65,
                    CrystalProwler = 25,
                    HeartWisp = 10,
                },
            },
        },
    },
    AncientHeights = {
        Id = "AncientHeights",
        Name = "Древние высоты",
        DefaultEggId = "AncientEgg",
        Eggs = {
            AncientEgg = {
                Id = "AncientEgg",
                Name = "Яйцо древнего древа",
                Rarity = "Мифическое",
                SpeciesWeights = {
                    AncientStag = 55,
                    RootSprite = 30,
                    SkySerpent = 15,
                },
            },
        },
    },
}
return BiomeCatalog
