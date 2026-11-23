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

    return #issues == 0, issues
end

return WorldHealthCheck
