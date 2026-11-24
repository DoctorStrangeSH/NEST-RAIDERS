local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactCatalog = require(ReplicatedStorage.Shared.Config.ArtifactCatalog)
local CompanionCatalog = require(ReplicatedStorage.Shared.Config.CompanionCatalog)

local ArtifactBonusService = {}
local MAX_GATHER_BONUS = 0.50
local MAX_RESEARCH_BONUS = 0.50
local MAX_HATCH_BONUS = 0.30
local HATCH_RARITY_RANK = {
    ["Обычный"] = 1,
    ["Необычный"] = 2,
    ["Редкий"] = 3,
    ["Эпический"] = 4,
    ["Легендарный"] = 5,
    ["Мифический"] = 6,
}

function ArtifactBonusService:GetGatherBonus(profile)
    if type(profile) ~= "table" then return 0 end
    local artifacts = type(profile.Artifacts) == "table" and profile.Artifacts or {}
    local equippedArtifacts = type(profile.EquippedArtifacts) == "table" and profile.EquippedArtifacts or {}
    local artifactsById = {}
    for _, artifact in ipairs(artifacts) do
        if type(artifact) == "table" and type(artifact.InstanceId) == "string" then
            artifactsById[artifact.InstanceId] = artifact
        end
    end

    local totalBonus = 0
    for _, instanceId in ipairs(equippedArtifacts) do
        local artifact = type(instanceId) == "string" and artifactsById[instanceId] or nil
        local definition = artifact and ArtifactCatalog[artifact.Id]
        if definition then
            local level = math.clamp(math.floor(tonumber(artifact.Level) or 1), 1, 6)
            local scaledBonus = (tonumber(definition.GatherBonus) or 0) * (1 + (level - 1) * 0.25)
            totalBonus += math.clamp(scaledBonus, 0, MAX_GATHER_BONUS)
        end
    end

    return math.clamp(totalBonus, 0, MAX_GATHER_BONUS)
end

function ArtifactBonusService:GetResearchBonus(profile)
    if type(profile) ~= "table" then return 0 end
    local artifacts = type(profile.Artifacts) == "table" and profile.Artifacts or {}
    local equippedArtifacts = type(profile.EquippedArtifacts) == "table" and profile.EquippedArtifacts or {}
    local artifactsById = {}
    for _, artifact in ipairs(artifacts) do
        if type(artifact) == "table" and type(artifact.InstanceId) == "string" then
            artifactsById[artifact.InstanceId] = artifact
        end
    end

    local totalBonus = 0
    for _, instanceId in ipairs(equippedArtifacts) do
        local artifact = type(instanceId) == "string" and artifactsById[instanceId] or nil
        local definition = artifact and ArtifactCatalog[artifact.Id]
        if definition then
            local level = math.clamp(math.floor(tonumber(artifact.Level) or 1), 1, 6)
            local scaledBonus = (tonumber(definition.ResearchBonus) or 0) * (1 + (level - 1) * 0.25)
            totalBonus += math.clamp(scaledBonus, 0, MAX_RESEARCH_BONUS)
        end
    end

    return math.clamp(totalBonus, 0, MAX_RESEARCH_BONUS)
end

-- Hunter artifacts increase only the relative weight of the highest rarity tier
-- available in the selected natural egg. Breeding outcomes are not routed here.
function ArtifactBonusService:GetHatchBonus(profile)
    if type(profile) ~= "table" then return 0 end
    local artifacts = type(profile.Artifacts) == "table" and profile.Artifacts or {}
    local equippedArtifacts = type(profile.EquippedArtifacts) == "table" and profile.EquippedArtifacts or {}
    local artifactsById = {}
    for _, artifact in ipairs(artifacts) do
        if type(artifact) == "table" and type(artifact.InstanceId) == "string" then
            artifactsById[artifact.InstanceId] = artifact
        end
    end

    local totalBonus = 0
    for _, instanceId in ipairs(equippedArtifacts) do
        local artifact = type(instanceId) == "string" and artifactsById[instanceId] or nil
        local definition = artifact and ArtifactCatalog[artifact.Id]
        if definition then
            local level = math.clamp(math.floor(tonumber(artifact.Level) or 1), 1, 6)
            local scaledBonus = (tonumber(definition.HatchBonus) or 0) * (1 + (level - 1) * 0.25)
            totalBonus += math.clamp(scaledBonus, 0, MAX_HATCH_BONUS)
        end
    end

    return math.clamp(totalBonus, 0, MAX_HATCH_BONUS)
end

-- Returns one species' actual normalized chance and its unmodified base chance.
-- Shop and collection-book odds use this same calculation as the hatch selector.
function ArtifactBonusService:GetHatchSpeciesChance(profile, speciesWeights, speciesId)
    if type(speciesWeights) ~= "table" or type(speciesId) ~= "string" then return 0, 0 end

    local highestRank = 0
    local baseTotal, adjustedTotal = 0, 0
    local requestedBaseWeight, requestedAdjustedWeight = 0, 0
    local bonus = self:GetHatchBonus(profile)
    for candidateId, weight in pairs(speciesWeights) do
        local definition = CompanionCatalog[candidateId]
        local safeWeight = tonumber(weight) or 0
        local rank = definition and HATCH_RARITY_RANK[definition.Rarity] or nil
        if definition and rank and safeWeight > 0 then
            highestRank = math.max(highestRank, rank)
            baseTotal += safeWeight
            if candidateId == speciesId then requestedBaseWeight = safeWeight end
        end
    end
    if baseTotal <= 0 or requestedBaseWeight <= 0 then return 0, 0 end

    for candidateId, weight in pairs(speciesWeights) do
        local definition = CompanionCatalog[candidateId]
        local safeWeight = tonumber(weight) or 0
        local rank = definition and HATCH_RARITY_RANK[definition.Rarity] or nil
        if definition and rank and safeWeight > 0 then
            local adjustedWeight = safeWeight
            if rank == highestRank then adjustedWeight *= (1 + bonus) end
            adjustedTotal += adjustedWeight
            if candidateId == speciesId then requestedAdjustedWeight = adjustedWeight end
        end
    end
    if adjustedTotal <= 0 then return 0, 0 end

    return requestedAdjustedWeight / adjustedTotal, requestedBaseWeight / baseTotal, bonus
end

-- Returns the selected species plus the base and boosted chance of the egg's
-- highest rarity tier. Sorted IDs keep seeded simulations reproducible.
function ArtifactBonusService:ChooseHatchSpecies(profile, speciesWeights, rollValue)
    if type(speciesWeights) ~= "table" then return nil, 0, 0, 0, false end

    local entries = {}
    local highestRank = 0
    for speciesId, weight in pairs(speciesWeights) do
        local definition = CompanionCatalog[speciesId]
        local safeWeight = tonumber(weight) or 0
        local rank = definition and HATCH_RARITY_RANK[definition.Rarity] or nil
        if definition and rank and safeWeight > 0 then
            table.insert(entries, { Id = speciesId, Weight = safeWeight, Rank = rank })
            highestRank = math.max(highestRank, rank)
        end
    end
    if #entries == 0 then return nil, 0, 0, 0, false end
    table.sort(entries, function(a, b) return a.Id < b.Id end)

    local bonus = self:GetHatchBonus(profile)
    local baseTotal, adjustedTotal = 0, 0
    local baseTopWeight, adjustedTopWeight = 0, 0
    for _, entry in ipairs(entries) do
        baseTotal += entry.Weight
        local adjustedWeight = entry.Weight
        if entry.Rank == highestRank then
            baseTopWeight += entry.Weight
            adjustedWeight *= (1 + bonus)
            adjustedTopWeight += adjustedWeight
        end
        entry.AdjustedWeight = adjustedWeight
        adjustedTotal += adjustedWeight
    end
    if baseTotal <= 0 or adjustedTotal <= 0 then return nil, bonus, 0, 0, false end

    local baseChance = baseTopWeight / baseTotal
    local adjustedChance = adjustedTopWeight / adjustedTotal
    local roll = type(rollValue) == "number"
        and math.clamp(rollValue, 0, 0.999999999) or math.random()
    local target = roll * adjustedTotal
    local cursor = 0
    for _, entry in ipairs(entries) do
        cursor += entry.AdjustedWeight
        if target < cursor then
            return entry.Id, bonus, baseChance, adjustedChance, entry.Rank == highestRank
        end
    end
    local last = entries[#entries]
    return last.Id, bonus, baseChance, adjustedChance, last.Rank == highestRank
end

-- Applies a server-side expected-yield bonus without changing node cooldowns.
-- Fractional yield is rolled once per successful harvest, so every collection
-- receives a fair long-run bonus while preserving integer material counts.
function ArtifactBonusService:ApplyGatherBonus(profile, baseAmount, rollValue)
    local safeBase = math.max(0, math.floor(tonumber(baseAmount) or 0))
    if safeBase == 0 then return 0, 0, 0 end

    local bonus = self:GetGatherBonus(profile)
    local expectedExtra = safeBase * bonus
    local extra = math.floor(expectedExtra)
    local fraction = expectedExtra - extra
    local roll = type(rollValue) == "number" and math.clamp(rollValue, 0, 0.999999999) or math.random()
    if fraction > 0 and roll < fraction then
        extra += 1
    end

    return safeBase + extra, bonus, extra
end

-- Applies an expected XP bonus without changing the base reward or level rules.
-- Fractional bonus XP is rolled once per successful XP award.
function ArtifactBonusService:ApplyResearchBonus(profile, baseAmount, rollValue)
    local safeBase = math.max(0, math.floor(tonumber(baseAmount) or 0))
    if safeBase == 0 then return 0, 0, 0 end

    local bonus = self:GetResearchBonus(profile)
    local expectedExtra = safeBase * bonus
    local extra = math.floor(expectedExtra)
    local fraction = expectedExtra - extra
    if fraction > 0 then
        local roll = type(rollValue) == "number" and math.clamp(rollValue, 0, 0.999999999) or math.random()
        if roll < fraction then
            extra += 1
        end
    end

    return safeBase + extra, bonus, extra
end

return ArtifactBonusService
