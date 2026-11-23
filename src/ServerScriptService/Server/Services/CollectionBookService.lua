local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)
local BiomeCatalog = require(ReplicatedStorage.Shared.Config.BiomeCatalog)

local CollectionBookService = {}
local function buildSnapshot(profile)
    local ownedCounts = {}
    for _, companion in ipairs(profile.Companions) do
        if type(companion.Id) == "string" then
            ownedCounts[companion.Id] = (ownedCounts[companion.Id] or 0) + 1
        end
    end

    -- Backfill discoveries from still-owned companions for profiles created
    -- before DiscoveredSpecies existed; past consumed species cannot be inferred.
    profile.DiscoveredSpecies = type(profile.DiscoveredSpecies) == "table"
        and profile.DiscoveredSpecies or {}
    for speciesId, count in pairs(ownedCounts) do
        if count > 0 and CompanionCatalog[speciesId] then
            profile.DiscoveredSpecies[speciesId] = true
        end
    end

    profile.DiscoveredBiomes = type(profile.DiscoveredBiomes) == "table" and profile.DiscoveredBiomes or {}
    local entries = {}
    local discovered = 0
    local total = 0
    for _, definition in pairs(CompanionCatalog) do
        total += 1
        local count = ownedCounts[definition.Id] or 0
        local isDiscovered = profile.DiscoveredSpecies[definition.Id] == true
        if isDiscovered then discovered += 1 end
        local eggId = definition.EggId
        local biomeName = definition.BossExclusive and (definition.AcquisitionBiome or "Храм Древнего древа") or "Зелёный луг"
        local eggName = definition.BossExclusive and "Награда за босса" or "Яйцо луга"
        local biomeChance = 0
        if not definition.BossExclusive then
            eggId = eggId or "MeadowEgg"
            for _, biome in pairs(BiomeCatalog) do
                for _, egg in pairs(biome.Eggs or {}) do
                    if egg.Id == eggId then
                        biomeName = biome.Name or biomeName
                        eggName = egg.Name or eggName
                        local totalWeight = 0
                        for _, weight in pairs(egg.SpeciesWeights or {}) do
                            if type(weight) == "number" and weight > 0 then totalWeight += weight end
                        end
                        local speciesWeight = tonumber(egg.SpeciesWeights and egg.SpeciesWeights[definition.Id]) or 0
                        biomeChance = totalWeight > 0 and math.floor(speciesWeight / totalWeight * 100 + 0.5) or 0
                        break
                    end
                end
            end
        end
        table.insert(entries, {
            Id = definition.Id,
            Name = definition.Name,
            Rarity = definition.Rarity,
            Description = definition.Description,
            Income = definition.Income,
            HatchChance = biomeChance,
            EggName = eggName,
            BiomeName = biomeName,
            DiscoveredBiome = profile.DiscoveredBiomes[definition.Id],
            HybridOnly = definition.Hybrid == true,
            BossExclusive = definition.BossExclusive == true,
            AcquisitionLabel = definition.AcquisitionLabel,
            OwnedCount = count,
            Discovered = isDiscovered,
        })
    end
    table.sort(entries, function(a, b)
        if a.HatchChance == b.HatchChance then return a.Name < b.Name end
        return a.HatchChance > b.HatchChance
    end)

    return {
        Entries = entries,
        Discovered = discovered,
        Total = total,
        CompletionPercent = total > 0 and math.floor(discovered / total * 100 + 0.5) or 0,
    }
end

function CollectionBookService:HandleRequest(player, payload)
    if type(payload) ~= "table" or payload.Action ~= "Get" then
        return { Ok = false, Message = "Некорректный запрос." }
    end

    -- Collection lookup is read-only and should never be rate-limited.

    local profile = PlayerDataService:GetProfile(player)
    if not profile or not player:GetAttribute("ProfileLoaded") then
        return { Ok = false, Message = "Профиль ещё загружается." }
    end

    return { Ok = true, Data = buildSnapshot(profile) }
end

function CollectionBookService:Init()
    local remotes = ReplicatedStorage:FindFirstChild("NestRaidersRemotes")
    if not remotes then
        remotes = Instance.new("Folder")
        remotes.Name = "NestRaidersRemotes"
        remotes.Parent = ReplicatedStorage
    end

    local remote = remotes:FindFirstChild("CollectionBook")
    if not remote then
        remote = Instance.new("RemoteFunction")
        remote.Name = "CollectionBook"
        remote.Parent = remotes
    end
    remote.OnServerInvoke = function(player, payload)
        return self:HandleRequest(player, payload)
    end

end

return CollectionBookService
