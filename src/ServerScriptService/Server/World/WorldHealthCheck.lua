-- Read-only structural diagnostics of the first playable loop.
-- No game rewards, spawning or DataStore writes: a failing check cannot corrupt gameplay.
local Workspace = game:GetService("Workspace")

local WorldHealthCheck = {}

function WorldHealthCheck:Check()
    local issues = {}
    local function fail(message)
        table.insert(issues, message)
    end
    local world = Workspace:FindFirstChild("NestRaidersWorld")
    local island = world and world:FindFirstChild("StarterIsland")
    if not island then
        fail("Стартовый остров отсутствует")
        return false, issues
    end

    local spawn = island:FindFirstChild("StarterSpawn")
    if not spawn or not spawn:IsA("SpawnLocation") then
        fail("Нет стартовой точки появления")
    end

    local eggs = island:FindFirstChild("EggSpawnPoints")
    if not eggs then
        fail("Нет папки точек сбора яиц")
    else
        local count = 0
        for _, egg in ipairs(eggs:GetChildren()) do
            if egg:IsA("BasePart") and egg:GetAttribute("WorldEgg") then
                count += 1
                local prompt = egg:FindFirstChild("CollectEggPrompt")
                if not prompt or not prompt:IsA("ProximityPrompt") then
                    fail("Нет взаимодействия со сбором: " .. egg.Name)
                end
            end
        end
        if count < 3 then
            fail("Доступно точек яиц: " .. count .. " из 3")
        end
    end

    local plots = island:FindFirstChild("PlayerPlots")
    if not plots then
        fail("Папка PlayerPlots не создана службой PlotService")
    else
        local count = 0
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then
                count += 1
                local station = plot:FindFirstChild("HatchStation")
                local prompt = station and station:FindFirstChild("HatchPrompt")
                if not station or not station:IsA("BasePart")
                    or not prompt or not prompt:IsA("ProximityPrompt") then
                    fail("Нет вылупления на участке: " .. plot.Name)
                end
                if not plot:FindFirstChild("PlotGrass") then
                    fail("Нет поверхности строительства: " .. plot.Name)
                end
            end
        end
        if count < 6 then
            fail(string.format("Создано участков: %d из 6 (PlotService: %s)", count, tostring(plots:GetAttribute("CreatedCount") or "нет отчёта")))
        end
    end

    local causeway = world and world:FindFirstChild("GlacierCauseway")
    local causewayCount = 0
    for _, segment in ipairs(causeway and causeway:GetChildren() or {}) do
        if segment:IsA("BasePart") and segment.Name:match("^IceBridgeSegment_") then
            causewayCount += 1
        end
    end
    if causewayCount < 9 then
        fail(string.format("Ледяной мост: %d из 9 секций", causewayCount))
    end

    local frost = world and world:FindFirstChild("FrostHighlands")
    if not frost then
        fail("Ледяные нагорья не созданы")
    else
        local frostEggs = frost:FindFirstChild("EggSpawnPoints")
        local frostEggCount = 0
        for _, egg in ipairs(frostEggs and frostEggs:GetChildren() or {}) do
            if egg:IsA("BasePart") and egg:GetAttribute("WorldEgg")
                and egg:GetAttribute("BiomeId") == "FrostHighlands"
                and egg:FindFirstChild("CollectEggPrompt") then
                frostEggCount += 1
            end
        end
        if frostEggCount < 3 then
            fail(string.format("Яйца Ледяных нагорий: %d из 3", frostEggCount))
        end
        local frostRunes = frost:FindFirstChild("FrostTrialRunes")
        local runeCount = 0
        for _, descendant in ipairs(frostRunes and frostRunes:GetDescendants() or {}) do
            if descendant:IsA("ProximityPrompt") and descendant.Name == "FrostRunePrompt" then
                runeCount += 1
            end
        end
        if runeCount < 3 then
            fail(string.format("Руны Ледяных нагорий: %d из 3", runeCount))
        end
        if not frost:FindFirstChild("FrostReturnPortal") then
            fail("Нет обратного портала из Ледяных нагорий")
        end
        if not frost:FindFirstChild("FrostEggOddsSign") then
            fail("Нет таблички с вероятностями яйца вечной зимы")
        end
        local emerald = world:FindFirstChild("EmeraldWilds")
        if not emerald or not emerald:FindFirstChild("FrostPortal") then
            fail("Нет входного портала в Ледяные нагорья из Изумрудного леса")
        end
    end


    local ember = world and world:FindFirstChild("Emberlands")
    if not ember then
        fail("Пепельные земли не созданы")
    else
        local heatZones = ember:FindFirstChild("HeatZones")
        local heatCount = 0
        for _, zone in ipairs(heatZones and heatZones:GetChildren() or {}) do
            if zone:IsA("BasePart") and (tonumber(zone:GetAttribute("HeatPerSecond")) or 0) > 0 then
                heatCount += 1
            end
        end
        if heatCount < 3 then fail("В Пепельных землях должно быть не менее трёх зон жара") end
        local sanctuary = ember:FindFirstChild("CoolingSanctuary")
        local cooling = sanctuary and sanctuary:FindFirstChild("CoolingZone")
        if not cooling or (tonumber(cooling:GetAttribute("CoolingPerSecond")) or 0) <= 0 then
            fail("Не создана рабочая зона охлаждения")
        end
        local emberCauseway = world:FindFirstChild("EmberCauseway")
        local bridgeCount = 0
        for _, segment in ipairs(emberCauseway and emberCauseway:GetChildren() or {}) do
            if segment:IsA("BasePart") and segment.Name:match("^EmberBridgeSegment_") then bridgeCount += 1 end
        end
        if bridgeCount < 9 then fail(string.format("Базальтовый мост: %d из 9 секций", bridgeCount)) end
        if not ember:FindFirstChild("EmberEggOddsSign") then fail("Нет таблички с вероятностями Яйца пепельного пламени") end
        local emberEggs = ember:FindFirstChild("EggSpawnPoints")
        local eggCount = 0
        for _, egg in ipairs(emberEggs and emberEggs:GetChildren() or {}) do
            if egg:IsA("BasePart") and egg:GetAttribute("WorldEgg")
                and egg:GetAttribute("BiomeId") == "Emberlands"
                and egg:FindFirstChild("CollectEggPrompt") then eggCount += 1 end
        end
        if eggCount < 3 then fail("Яйца Пепельных земель: " .. eggCount .. " из 3") end
        if not ember:FindFirstChild("EmberReturnPortal") then fail("Нет обратного портала из Пепельных земель") end
        local frost = world:FindFirstChild("FrostHighlands")
        if not frost or not frost:FindFirstChild("EmberPortal") then fail("Нет портала из Ледяных нагорий в Пепельные земли") end
        local trial = ember:FindFirstChild("HeartOfFireTrial")
        if not trial then
            fail("Не создана арена Испытания Огненного сердца")
        else
            local arena = trial:FindFirstChild("HeartOfFireArena")
            if not arena or not arena:IsA("BasePart") then
                fail("Нет платформы арены Огненного сердца")
            end
            local runes = trial:FindFirstChild("TrialRunes")
            local runeCount = 0
            for _, descendant in ipairs(runes and runes:GetDescendants() or {}) do
                if descendant:IsA("ProximityPrompt") and descendant.Name == "EmberTrialRunePrompt" then
                    runeCount += 1
                end
            end
            if runeCount < 3 then fail(string.format("Руны Огненного сердца: %d из 3", runeCount)) end
            local guardian = trial:FindFirstChild("HeartOfFireGuardian")
            local core = guardian and guardian:FindFirstChild("GuardianFlameCore")
            local bossPrompt = core and core:FindFirstChild("EmberTrialBossPrompt")
            if not bossPrompt or not bossPrompt:IsA("ProximityPrompt") then
                fail("Нет взаимодействия с Огненным стражем")
            end
            local approach = trial:FindFirstChild("TrialApproach")
            local stepCount = 0
            for _, step in ipairs(approach and approach:GetChildren() or {}) do
                if step:IsA("BasePart") and step.Name:match("^BasaltTrialStep_") then stepCount += 1 end
            end
            if stepCount < 12 then fail(string.format("Подъём к алтарю: %d из 12 ступеней", stepCount)) end
        end
    end


    local crystal = world and world:FindFirstChild("CrystalRealm")
    if not crystal then
        fail("Хрустальное королевство не создано")
    else
        if not crystal:FindFirstChild("PrismaticPlateau") then fail("Нет плато Хрустального королевства") end
        if not crystal:FindFirstChild("CrystalReturnPortal") then fail("Нет обратного портала из Хрустального королевства") end
        local crystalVeins = crystal:FindFirstChild("CrystalVeins")
        local veinCount = 0
        for _, node in ipairs(crystalVeins and crystalVeins:GetChildren() or {}) do
            if node:IsA("BasePart") and type(node:GetAttribute("CrystalNodeId")) == "string"
                and node:FindFirstChild("MineCrystalPrompt") then veinCount += 1 end
        end
        if veinCount < 6 then fail(string.format("Кристальные жилы: %d из 6", veinCount)) end
        local crystalEggs = crystal:FindFirstChild("EggSpawnPoints")
        local crystalEggCount = 0
        for _, egg in ipairs(crystalEggs and crystalEggs:GetChildren() or {}) do
            if egg:IsA("BasePart") and egg:GetAttribute("WorldEgg")
                and egg:GetAttribute("BiomeId") == "CrystalRealm"
                and egg:FindFirstChild("CollectEggPrompt") then crystalEggCount += 1 end
        end
        if crystalEggCount < 3 then fail("Яйца Хрустального королевства: " .. crystalEggCount .. " из 3") end
        if not crystal:FindFirstChild("CrystalEggOddsSign") then fail("Нет таблицы вероятностей кристального яйца") end
        if not world:FindFirstChild("CrystalSkyway") then fail("Нет небесного моста к Хрустальному королевству") end
        if not ember or not ember:FindFirstChild("CrystalPortal") then fail("Нет входного портала из Пепельных земель в Хрустальное королевство") end
    end


    local prismTrial = crystal and crystal:FindFirstChild("PrismTrial")
    if not prismTrial then
        fail("Нет арены Испытания призмы")
    else
        if not prismTrial:FindFirstChild("PrismTrialPlatform") then fail("Нет платформы Испытания призмы") end
        local prismCount = 0
        for _, descendant in ipairs(prismTrial:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") and descendant.Name == "CrystalPrismPrompt" then
                prismCount += 1
            end
        end
        if prismCount < 3 then fail(string.format("Призмы испытания: %d из 3", prismCount)) end
        if not prismTrial:FindFirstChild("PrismLightBeam_1") or not prismTrial:FindFirstChild("PrismLightBeam_2") then
            fail("Нет световых лучей призматического механизма")
        end
        local guardian = prismTrial:FindFirstChild("PrismGuardian")
        local core = guardian and guardian:FindFirstChild("GuardianPrismCore")
        local bossPrompt = core and core:FindFirstChild("CrystalTrialBossPrompt")
        if not bossPrompt or not bossPrompt:IsA("ProximityPrompt") then fail("Нет взаимодействия с Хранителем призмы") end
        if not prismTrial:FindFirstChild("CrystalTrialSign") then fail("Нет подсказки к последовательности призм") end
    end
    local ancient = world and world:FindFirstChild("AncientHeights")
    if not ancient or not ancient:FindFirstChild("AncientLanding") then fail("Нет стартовой площадки Древних высот") end
    if not ancient or not ancient:FindFirstChild("AncientReturnPortal") then fail("Нет обратного портала с Древних высот") end
    if not crystal or not crystal:FindFirstChild("AncientHeightsPortal") then fail("Нет портала к Древним высотам") end
    if ancient then
        local ancientEggs = ancient:FindFirstChild("EggSpawnPoints")
        local ancientEggCount = 0
        for _, egg in ipairs(ancientEggs and ancientEggs:GetChildren() or {}) do
            if egg:IsA("BasePart") and egg:GetAttribute("WorldEgg")
                and egg:GetAttribute("BiomeId") == "AncientHeights"
                and egg:GetAttribute("EggId") == "AncientEgg"
                and egg:FindFirstChild("CollectEggPrompt") then
                ancientEggCount += 1
            end
        end
        if ancientEggCount < 3 then fail(string.format("Яйца Древних высот: %d из 3", ancientEggCount)) end
        if not ancient:FindFirstChild("ElderCanopy") then fail("Нет рощи Древних высот") end
        if not ancient:FindFirstChild("AncientEggOddsSign") then fail("Нет таблицы вероятностей древнего яйца") end
        local elderwoodNodes = ancient:FindFirstChild("ElderwoodNodes")
        local elderwoodCount = 0
        for _, node in ipairs(elderwoodNodes and elderwoodNodes:GetChildren() or {}) do
            if node:IsA("BasePart") and type(node:GetAttribute("ElderwoodNodeId")) == "string"
                and node:FindFirstChild("HarvestElderwoodPrompt") then
                elderwoodCount += 1
            end
        end
        if elderwoodCount < 6 then fail(string.format("Древние корни: %d из 6", elderwoodCount)) end
    end

    return #issues == 0, issues
end

return WorldHealthCheck
