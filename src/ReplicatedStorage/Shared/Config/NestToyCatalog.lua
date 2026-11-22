local NestToyCatalog = {
    MeadowBall = {
        Id = "MeadowBall",
        Name = "Прыгучий мяч",
        Description = "Для весёлых игр и активных питомцев.",
        Cost = 25,
        PlayMoodBonus = 15,
        EnergyCost = 10,
        Color = Color3.fromRGB(255, 132, 92),
        Shape = Enum.PartType.Ball,
    },
    CozyPlush = {
        Id = "CozyPlush",
        Name = "Мягкая игрушка",
        Description = "Уютная компания для спокойных питомцев.",
        Cost = 40,
        PlayMoodBonus = 10,
        EnergyCost = 5,
        Color = Color3.fromRGB(170, 133, 220),
        Shape = Enum.PartType.Block,
    },
    WindSpinner = {
        Id = "WindSpinner",
        Name = "Вертушка",
        Description = "Лёгкая игрушка для любопытных созданий.",
        Cost = 35,
        PlayMoodBonus = 5,
        EnergyCost = 0,
        Color = Color3.fromRGB(105, 205, 190),
        Shape = Enum.PartType.Cylinder,
    },
}

return NestToyCatalog
