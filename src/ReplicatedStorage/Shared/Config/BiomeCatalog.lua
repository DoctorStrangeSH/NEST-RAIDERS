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
