local GearCatalog = {
    Riftblade = {
        Id = "Riftblade", Name = "Клинок разлома", Slot = "Weapon", SetId = "Voidwalker",
        Rarity = "Эпический", Description = "Клинок, выкованный из края пространственной трещины.",
        DamageBonus = 0.22, DefenseBonus = 0, MaxHealthBonus = 0, WalkSpeedBonus = 0,
        Color = Color3.fromRGB(177, 129, 255), Visual = "Sword",
        Cost = { Starshard = 20, CrystalShard = 8, Coins = 1200 },
    },
    Voidplate = {
        Id = "Voidplate", Name = "Доспех пустоты", Slot = "Armor", SetId = "Voidwalker",
        Rarity = "Легендарный", Description = "Панцирь из закалённого звёздного базальта.",
        DamageBonus = 0, DefenseBonus = 0.18, MaxHealthBonus = 20, WalkSpeedBonus = 0,
        Color = Color3.fromRGB(83, 91, 137), Visual = "Armor",
        Cost = { Starshard = 28, AshCrystal = 8, Coins = 1600 },
    },
    Starhelm = {
        Id = "Starhelm", Name = "Шлем звёздного дозора", Slot = "Helmet", SetId = "Voidwalker",
        Rarity = "Эпический", Description = "Лёгкий шлем с сердцевиной, удерживающей звёздный свет.",
        DamageBonus = 0, DefenseBonus = 0.05, MaxHealthBonus = 30, WalkSpeedBonus = 0,
        Color = Color3.fromRGB(255, 215, 147), Visual = "Helmet",
        Cost = { Starshard = 16, Moonpetal = 8, Coins = 900 },
    },
    NebulaCloak = {
        Id = "NebulaCloak", Name = "Плащ туманности", Slot = "Accessory", SetId = "Voidwalker",
        Rarity = "Легендарный", Description = "Плащ, сотканный из лёгкой ткани и пыли туманностей.",
        DamageBonus = 0, DefenseBonus = 0.05, MaxHealthBonus = 0, WalkSpeedBonus = 2,
        Color = Color3.fromRGB(177, 117, 204), Visual = "Cloak",
        Cost = { Starshard = 24, Elderwood = 10, Coins = 1400 },
    },
}
return GearCatalog
