local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactCatalog = require(ReplicatedStorage.Shared.Config.ArtifactCatalog)

local ArtifactBonusService = {}
local MAX_GATHER_BONUS = 0.50
local MAX_RESEARCH_BONUS = 0.50

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
