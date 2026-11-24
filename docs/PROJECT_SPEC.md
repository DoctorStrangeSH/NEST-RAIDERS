# NEST RAIDERS — Product & Technical Specification

**Version:** 0.1.0 · **Status:** Approved direction / implementation in progress

## 1. Product vision
NEST RAIDERS is a bright, social Roblox open-world collection/adventure game. Players explore a connected archipelago, discover and secure eggs, hatch companions, grow a personal nest, earn resources, complete quests, and participate in fair, readable raids.

The game takes inspiration from the broad collection/stealing genre loop, but must have its own world, names, visual identity, progression, economy, UX, content, and code. Do not copy another game's maps, UI, assets, text, branding, or proprietary implementation.

## 2. Locked decisions
| Decision | Value |
|---|---|
| Working title | NEST RAIDERS |
| Art direction | Bright, colorful, polished, readable 3D |
| World | Connected island archipelago; seamless traversal, no mandatory portals |
| PvP | Balanced; protect new players and avoid irreversible loss |
| Scope | Ambitious, delivered through small playable milestones |
| Progression | Biomes unlock through level + quests/trials; visible early, accessible later |
| Primary platform | Roblox; mobile-first, also desktop/tablet |

## 3. Core player fantasy and loop
1. Explore a lively island and spot an egg, event, resource, or quest.
2. Reach it using traversal and lightweight challenges.
3. Secure/carry the egg to the player's nest.
4. Hatch it using a clear, satisfying reveal.
5. Place the companion; it follows and provides a defined benefit such as passive coins.
6. Reinvest in nest upgrades, tools, cosmetics, and exploration.
7. Unlock the next biome through meaningful objectives.
8. Visit social hubs, trade safely, and opt into raids.

The first playable release must implement one complete loop, not a collection of disconnected systems.

## 4. World and progression
The archipelago is one navigable world. Streaming may load/unload distant geometry, but players should not be sent through mandatory portals between biomes. Natural geography, bridges, lifts, caves, currents, and environmental challenges create the route.

Provisional progression bands (tune from playtests):
- Starter Island — immediately available; Common/Uncommon eggs.
- Emerald Wilds — level 5 + introductory exploration quest.
- Frost Highlands — level 12 + traversal trial.
- Emberlands — level 22 + heat-resistance / quest milestone.
- Crystal Realm — level 35 + puzzle or collection trial.
- Ancient Heights — level 50 + multi-step quest.
- Void Frontier — level 75 + endgame challenge.

These are starting hypotheses, not final balance. A level alone must not unlock every late-game reward. Server validates access on every meaningful interaction. Closed areas may be visible from safe viewpoints, but locked content cannot be collected or farmed early. Trading must not bypass all progression gates: late-game companions may be displayed/traded under controlled rules, but zone-specific quests and rewards remain account-bound.

## 5. Systems and requirements

### 5.1 Player profile and saving
- Server owns all authoritative state.
- Persist schema version, coins, XP/level, unlocked zones, inventory, nest upgrades, companions, quests, settings.
- Use DataStoreService with UpdateAsync, retry/backoff, session protection, and safe shutdown handling.
- Never overwrite a valid profile with defaults after a load failure.
- Validate and clamp every persisted value; migrate old schema versions.
- Autosave at a measured interval and on PlayerRemoving/BindToClose.
- DataStore failures must fail closed for purchases and trades.

### 5.2 Eggs and inventory
- Eggs have stable IDs, rarity, source zone, hatch table, and optional modifiers.
- Server validates proximity, zone unlock, ownership, capacity, and cooldown before granting.
- Inventory changes are atomic and idempotent; client never chooses reward or rarity.
- Hatch result is generated on server from configured weighted tables.
- Show odds clearly wherever randomized paid or earned egg outcomes are offered.

### 5.3 Companions
- Companion definitions are data-driven: ID, display name, rarity, income, movement profile, cosmetic model key.
- Server calculates income and progression; client handles presentation only.
- Follow behavior must be lightweight and capped; avoid one expensive physics assembly per pet.
- Duplicate companions have a useful, non-punitive sink (collection progress, merge, or exchange).

### 5.4 Economy
- One primary soft currency at first.
- Define sources and sinks before adding premium currency.
- Track earning/spending telemetry and tune inflation.
- No paid random reward without clear odds and policy review.
- No direct purchase of competitive power that invalidates progression or PvP fairness.

### 5.5 Nest / player plot
- Each player receives a server-assigned plot.
- Plot ownership and all placement operations are server-validated.
- Upgrades expand capacity and cosmetic options.
- Players can buy cosmetic decorations into a persistent inventory, place them into unlocked slots on their own plot, and remove them back into inventory.
- Decoration purchase and placement are server-authoritative: validate profile readiness, plot ownership, proximity, catalog IDs, currency, inventory, slot unlocks, and occupancy.
- Nest level 1 exposes two decoration slots; each upgrade adds one, up to six at level 5.
- Placed decorations can be moved on a server-validated 2-stud grid within plot bounds and rotated in 15-degree increments; transform data is persisted.
- Cosmetics must not affect pet stats, passive income, raid outcomes, or progression power.
- Protect offline players from destructive loss; raids should have bounded stakes and recovery.

### 5.6 Raids and PvP
- Balanced PvP means clear consent/telegraphing, counterplay, cooldowns, and capped losses.
- Newcomer protection and progression-based matchmaking.
- Never allow raids to delete a player's entire collection or paid items.
- Server validates target, range, line of sight, cooldown, raid state, and reward.
- Log suspicious raid/economy events; rate-limit remotes.

### 5.7 Quests and onboarding
- Short tutorial teaches movement, egg discovery, returning to nest, hatching, and first upgrade.
- Quests provide alternate progression paths and direct players to world landmarks.
- Avoid hard dead-ends; explain why a zone is locked and show the next actionable goal.

### 5.8 UI and accessibility
- Bright, high-contrast, uncluttered UI; large touch targets.
- Core actions available on mobile without precision clicking.
- Inventory, companion collection, quest tracker, currency, zone lock requirements, and settings.
- Support reduced motion and readable text sizes where practical.
- Never communicate rarity through color alone.

### 5.9 Monetization
- Monetization is not a launch blocker for the first prototype.
- Prioritize cosmetics, nest themes, emotes, convenience with strict caps, and optional private servers.
- Avoid pay-to-win, manipulative countdowns, confusing currencies, and paid random rewards until Roblox policy and regional legal requirements are reviewed.
- All purchases must be server-confirmed and grant exactly once; receipt processing must be idempotent.

## 6. Art and asset pipeline
- Target style: bright, friendly, saturated but controlled palette; strong silhouettes; readable landmarks; polished lighting; consistent scale.
- Creator Store / Toolbox assets may be used only after checking creator, permissions, license/usage terms, dependencies, performance, and embedded scripts.
- Prefer models with no scripts. Inspect every descendant before use; remove unnecessary scripts and external dependencies.
- Do not assume “free” means unrestricted commercial use. Keep an asset register with source URL, creator, license/permission evidence, import date, and modifications.
- Avoid mixing realistic assets with low-poly/cartoon assets. Establish a small style guide and test assets together in the same scene.
- All game-specific gameplay scripts remain in this repository; imported models are presentation assets, not trusted code.

## 7. Technical architecture
- Engine: Roblox Studio.
- Language: Luau.
- Project sync: Rojo.
- Server-authoritative architecture with shared configuration modules and thin clients.
- Data-driven content definitions in ReplicatedStorage/Shared/Config.
- Server services in ServerScriptService/Services.
- Client controllers in StarterPlayer/StarterPlayerScripts/Controllers.
- Remotes live in a single, explicitly managed folder; validate payload types, size, rate, ownership, range, and state.
- Use CollectionService tags and Attributes for world interaction points.
- Use StreamingEnabled for large world geometry; keep critical gameplay state server-side.
- Avoid requiring untrusted Toolbox scripts or runtime code downloaded from external sources.

### Suggested service boundaries
- PlayerDataService — profile lifecycle and persistence.
- ProgressionService — XP, level, quest and zone unlock rules.
- InventoryService — eggs and companion ownership.
- EggService — world pickups and hatching.
- EconomyService — validated currency transactions.
- NestService — plot assignment and upgrades.
- CompanionService — companion state and income.
- RaidService — PvP state, validation, cooldowns, bounded outcomes.
- Remotes/Network — typed remote registration and rate limiting.

## 8. Security and exploit resistance
- Treat every client request as untrusted.
- Never accept client-supplied currency, rarity, rewards, level, inventory deltas, target ownership, or purchase success.
- Validate distance server-side using server-observed character positions.
- Rate-limit every remote and reject malformed/oversized payloads.
- Use transaction IDs / idempotency for grants and purchases.
- Avoid trusting client-created instances for progression or rewards.
- Log anomalies without exposing sensitive player data.

## 9. Performance and quality targets
- Design for low-end mobile devices first.
- Stream distant world geometry and keep active physics/AI bounded.
- Use pooled effects, low-frequency server updates, and client-side cosmetic interpolation.
- Profile memory, script time, physics, and network traffic in Studio with realistic player counts.
- Test touch controls, low graphics quality, respawn, reconnect, server shutdown, and DataStore failure paths.

## 10. Analytics and success measures
Instrument onboarding completion, first egg found, first hatch, first nest upgrade, first return session, session length, zone progression, raid participation, trade completion, and purchase conversion. Do not optimize only for time spent; monitor frustration, reports, quit points, and fairness.

## 11. Definition of Done
A feature is done only when:
- Server validation exists for all state-changing actions.
- Error and reconnect paths are handled.
- Desktop and mobile controls are tested.
- No unexpected output/errors in Studio.
- Data migrations and save behavior are tested when applicable.
- Documentation and ROADMAP are updated.
- Acceptance checklist is recorded.


## Weekly island showcase
- The social layer includes weekly island voting in three non-power categories: Cozy, Nature, and Fantasy.
- Each player may vote once per category per UTC week; self-votes and unavailable targets are rejected server-side.
- Published servers share top-ten category standings through OrderedDataStore, backed by an idempotent per-owner vote ledger. Local Studio mode uses an explicitly temporary in-memory fallback; leaderboard reads are cached and throttled.
- Voting is for social recognition only. Winner cosmetics, global island discovery, moderation review, and anti-alt heuristics are later release work.


## Hall of Fame and cosmetic contest rewards
- Archive the previous UTC week's top three per category when the contest is accessed in the new week.
- Retain the latest 12 completed weeks in a shared published DataStore.
- Claims must be verified against the archived winner list on the server; each category/week can be claimed once per player.
- Store claimed trophy records in the player's persistent profile and render the trophies on their personal island.
- Trophy visuals are cosmetic only and grant no progression, economy, companion, or PvP advantages.
- Studio fallback history is local and temporary. Automatic scheduled finalization is not part of this sprint.


## Global island discovery and visits
- Published servers publish active island owner records to a shared TTL-backed MemoryStore sorted map.
- Directory records include UserId, display name, level, plot ID, JobId, PlaceId, visitor count, capacity, likes, and update timestamp.
- Browsing merges local plots and global records, deduplicating by stable UserId.
- Cross-server visits must validate the directory record server-side and teleport to the exact public server.
- Destination arrival must verify that the requested owner still owns the requested plot before moving the visitor.
- Directory unavailability degrades gracefully to local listings; Studio remains local-only.
- Directory entries are ephemeral and refresh periodically; they are not a persistent player profile or ranking database.


## Player identity, public profiles, achievements, and titles
- Public profiles are served for online players in the same game server. Offline and cross-server lookup is a future extension.
- Public fields: display name, username, level, nest level, companion count, unique species, collection completion, received island likes, contest trophy count, achievement states, available titles, and equipped title.
- Private profile fields such as currency, raw inventory entries, item instance IDs, session tokens, and raw save data must not be exposed.
- Achievements are derived from server-authoritative profile state: first companion, 10 companions, five unique species, nest level 3, first contest trophy, 10 received likes, and level 10.
- Titles are cosmetic, may be equipped only after unlocking, persist in `Nest.EquippedTitle`, and render above the character.
- Client requests cannot grant achievements or equip locked titles.


## Companion growth, training, and genetics
- A newly hatched companion receives one server-generated genetic trait independent of species rarity. Weights: Natural 72%, Verdant 18%, Luminous 8%, Prismatic 2%. Traits are stored per companion instance and stable through fusion.
- Companion level cap: 10. Training grants 75 GrowthXP and costs 30 + current level × 25 coins. Next-level XP requirement: 100 + (current level − 1) × 55; XP carries over.
- Growth stages: Hatchling (1–3), Young (4–6), Adult (7–10). Stages are visible in inventory and reflected by model scale. Non-Natural traits add distinct visual aura/spark effects.
- Passive income = species base income × star multiplier × level multiplier × genetic multiplier, floored to integer. Star multipliers are 1 / 1.75 / 3; level multiplier is 1 + 0.04 × (level − 1); genetic bonus is capped at 8%.
- All training validation, coin deduction, XP progression, level-up, and income calculation are server-authoritative.
- Legacy companions without a genetic trait default to Natural during profile normalization.
- Fusion consumes two matching companions of the same species and star rank, preserving the selected target's level, XP, and genetic trait.


## Species-specific adult companion abilities
- Each starter species has one unique catalog-defined active ability, unlocked at companion level 7 (Adult stage).
- Abilities can only be triggered for a companion currently equipped in the player's active team. The server resolves the ability from the owned companion's species catalog; clients cannot select a reward or amount.
- MeadowFox — TrailFinder: grants coins using the server economy service. Reward formula: 40 + level × 10 + star rank × 15.
- MossTurtle — RootBlessing: adds coins to the player's nest storage. Reward formula: 100 + level × 20 + star rank × 25; storage cap is 2,000,000,000.
- SproutDragon — VerdantSpark: grants player progression XP. Reward formula: 35 + level × 5 + star rank × 10.
- Each ability has a 300-second per-companion cooldown persisted in AbilityReadyAt. Cooldown validation and reward calculation are server-authoritative.
- The inventory snapshot exposes only ability display metadata, unlock state, and remaining cooldown. It does not accept ability definitions or reward amounts from the client.


## Adult breeding and genetic inheritance
- Breeding requires two distinct owned companions of different species, each at level 7 or higher. Both parents must be unequipped and not displayed in the nest. Parents are not consumed.
- Breeding costs 250 + (parent A star rank + parent B star rank) × 100 coins. Each parent receives an independent 1,800-second cooldown. The server checks ownership, level, species, equipped/displayed state, cooldown, currency, and collection capacity before changing profile data.
- Offspring species is randomly selected from either parent's species. Offspring starts at level 1, one star, and zero GrowthXP.
- Genetic inheritance: 90% chance to inherit one parent's existing trait (each parent equally likely); 7% chance of Luminous mutation; 3% chance of Prismatic mutation. Trait values are selected from server-defined constants, never from client payloads.
- Offspring records Origin = Breeding and both parent species IDs. Collection snapshots resolve parent species names for lineage display.
- Collection capacity is 100 companions. Breeding must fail without charging currency or setting cooldowns when the collection is full.
- UI requires selecting parent A, selecting parent B, then explicitly confirming breeding before spending coins.
- This is the first breeding loop; true hybrid species and distinct cross-species models are future work. The child retains one parent's existing species model.


## Lineage egg incubation
- Successful breeding creates a persistent egg record in the player's existing EggInventory. No companion is created immediately.
- The egg stores a server-selected offspring species, genetic trait, both parent species IDs, origin = Breeding, and IncubatesUntil = creation time + 300 seconds.
- The inventory snapshot exposes egg origin, remaining incubation seconds, offspring species name, genetic trait name, and parent names. The client cannot modify stored egg outcomes.
- Before the deadline, hatch requests leave the egg untouched and return a remaining-time notice. At or after the deadline, the player's owned plot hatch station consumes the egg and creates exactly one companion using its stored species, genetics, and lineage.
- Normal world/shop eggs keep the existing random hatch flow.
- The collection UI shows an incubator summary with lineage egg count, next egg countdown, species preview, and genetic trait.
- Breeding checks both companion and egg inventory capacity before charging currency or setting parent cooldowns.


## Starter hybrid species
- The first three cross-species pairs produce deterministic breeding-only hybrids, independent of parent selection order:
  - MeadowFox + SproutDragon → EmberFox (Пламенный лис), Epic, base income 13.
  - MossTurtle + SproutDragon → Fernshell (Папоротниковый панцирь), Epic, base income 14.
  - MeadowFox + MossTurtle → BriarGuardian (Терновый страж), Epic, base income 12.
- Hybrid catalog entries have Weight = 0 and are excluded from the natural egg hatch pool. They can only be obtained through their corresponding breeding pair.
- Lineage eggs store the hybrid species ID and parent species IDs. Incubation/hatching continues to use the stored offspring result.
- Collection book entries flag HybridOnly and display "Только через разведение" while undiscovered.
- Companion follower models have dedicated hybrid silhouettes and color palettes; they do not fall back to the starter fox model.
- EmberFox has the CinderDash adult ability, unlocked at level 7, requiring an equipped companion, with server-side reward formula 60 + level × 12 + star rank × 20 and the catalog cooldown.
- Fernshell and BriarGuardian currently have no active ability; their ability kits are future balancing work.


## Genetic mutation appearance — Sprint 4.18
- Natural: no additional genetic ornaments.
- Verdant: green aura, three leaf/crystal growths along the upper silhouette, and a neon heart gem.
- Luminous: cyan aura and three neon lantern orbs, each with a soft PointLight.
- Prismatic: violet aura, three differently colored neon facets, and a prismatic core.
- Genetic ornaments are built into the same companion model used for followers and nest displays, so the trait appearance is consistent across contexts.
- Inventory cards show trait name, rarity, rounded passive-income bonus percentage, growth XP, and passive income.
- Existing profile compatibility: missing or malformed genetic traits normalize to Natural.


## Personal nest breeding altar — Sprint 4.19
- Every personal plot builds a dedicated BreedingStation next to its hatch station. The altar uses a wooden base, neon ring, translucent purple core, and soft PointLight.
- A ProximityPrompt displays "Разведение" / "Алтарь потомства". Only the plot owner receives the prompt guidance notice.
- The server validates the player's assigned plot and character root position; the Breed inventory action is rejected unless the player is within 18 studs of their own BreedingStation.
- Proximity is an additional gate, not a replacement for existing checks: both parents must be owned, adult, distinct species, unequipped, undisplayed, off cooldown, and fit within collection/egg capacity. Costs and parent cooldowns are applied only after validation.


## Breeding ritual reveal — Sprint 4.20
- A successful server-side Breed action triggers a short altar sequence after the lineage egg is inserted into the profile.
- Temporary preview copies of the two exact selected companion models appear on opposite altar pads. Their species silhouettes and genetic ornaments are preserved; they converge toward the altar core through species-colored Beam instances.
- The egg appears as a small spark, grows into a visible egg, and receives a trait-colored PointLight and particle burst.
- Genetic trait colors: Natural warm gold, Verdant green, Luminous cyan, Prismatic violet.
- The egg stores IsHybrid based on the selected offspring catalog entry. Hybrid eggs receive four additional golden shards and a stronger reveal burst.
- Ritual effects are temporary, automatically cleaned up, and never run for rejected breeding requests.
- The animation is cosmetic only: offspring species, genetic trait, parent lineage, currency cost, parent cooldown, and five-minute incubation remain server-authoritative and unchanged.

 
## Implemented biome slice — Frost Highlands (Sprint 4.21)
The first Frost Highlands vertical slice is integrated in the prototype:
- Entry is server-gated by level 12 and the account-bound `emerald_trial` completion.
- The island contains a snowfield, pine grove, glacier crystals, three Frost Egg pickups, three trial runes, and a return portal to Emerald Wilds. A walkable nine-section ice causeway connects it physically to Emerald Wilds; portals are optional fast travel.
- Frost Egg odds are 60% Frost Fox, 30% Snow Owl, and 10% Glacier Bear; the shared BiomeCatalog is the hatch source of truth and the odds are disclosed on an in-world sign.
- Frost Fox, Snow Owl, and Glacier Bear each unlock a distinct server-validated active ability at companion level 7 (coin cache, XP reward, and nest coin storage respectively).
- Frost trial progress (Aurora, Glacier, Winter) is persistent; completing all three grants +180 XP once and satisfies the configured Emberlands quest prerequisite. Emberlands still requires level 22.
- Egg collection is rejected unless the player's server-owned current biome matches the egg's unlocked biome.
- These are scripted placeholder visuals. Studio runtime, persistence, collision, mobile, and performance acceptance remain mandatory before this slice is considered release-ready.

 
## Emberlands — Heat gameplay slice (Sprint 4.22.1)
- Emberlands is gated by the existing progression configuration: level 22 and the completed `frost_trial` quest.
- The volcanic blockout contains a central magma core, basalt pillars, lava channels, three server-readable heat volumes, and a cooling sanctuary.
- The server-owned HeatService replicates each player's heat value and danger/sanctuary state. Heat rises only inside configured volumes, cools outside them, and cools faster inside the sanctuary. At critical heat, the server applies gradual damage.
- Active Cinder Fox, Magma Whelp, and Ash Phoenix companions provide passive heat reduction. Their level-7 active abilities provide temporary heat resistance, a stronger temporary heat ward, and a one-time per-life rescue from critical heat respectively.
- Ember Egg odds are 60% Cinder Fox, 30% Magma Whelp, and 10% Ash Phoenix. The egg uses the existing biome-owned hatch table and random spawn pool.
- The client HUD displays server-replicated temperature, danger warnings, sanctuary state, and protection.
- Structural CI checks cover the Ember island, heat/cooling volumes, egg prompts, and portals. Roblox Studio runtime, multiplayer, balance, and mobile acceptance remain outstanding.

 
## Ashfall world event — Sprint 4.22.2
- When players are in Emberlands, the server schedules a volcanic event. The first warning begins after a short arrival grace period; later events follow the configured interval.
- A 20-second warning precedes three moving lava surges. The server checks player positions and applies damage with a per-player cooldown; the cooling sanctuary is explicitly outside the surge damage boundary.
- After the surges, four ash-crystal nodes appear for 75 seconds. Each player may claim each node once per event. Ash crystals are stored in the persistent profile material inventory and replicated to the client HUD.
- The Russian HUD displays the warning countdown, active eruption, aftermath timer, and saved ash-crystal balance.
- Static CI checks cover event wiring and safety conditions. Studio runtime, multiplayer claims, reward persistence, balance, and mobile acceptance remain outstanding.


## Heart of Fire trial — Sprint 4.23
- The Emberlands summit now contains a raised basalt altar, a twelve-step approach, three rune pedestals, and the Heart of Fire Guardian.
- Players activate the Ember, Cinder, and Inferno runes. Rune progress is stored per player. All three runes unlock the guardian encounter for that player.
- Guardian health is tracked per player and saved in QuestProgress.EmberTrialBossHealth. Each valid strike removes 25 health. The guardian telegraphs a counterattack for 1.4 seconds; a player who leaves its 23-stud attack radius avoids the 18-damage hit.
- Defeating the guardian completes ember_trial and grants +250 XP once. The existing progression configuration already gates Crystal Realm behind level 35 and ember_trial.
- The Russian HUD shows rune progress, guardian health, and the dodge warning. Static CI and world-health checks cover the arena structure and service wiring.
- This is a scripted combat prototype. Roblox Studio collision, combat feel, multiplayer, persistence, balance, and mobile acceptance are still required.


## Crystal Realm foundation — Sprint 4.24
- Crystal Realm is gated by the existing level 35 + ember_trial requirement. It is reachable from Emberlands through a portal and a physical crystal skyway, with a return portal.
- The island contains a floating prismatic plateau, luminous crystal spires, aurora gardens, eight mineable crystal veins and Crystal Egg spawn points.
- Each player can mine each vein once per three-minute cooldown. A successful mine awards 2–4 Crystal Shards. Shards and node cooldowns are stored in the player profile.
- Active Prism Fox companions add one shard, Crystal Fawns add one shard, and active Aurora Dragons have a 35% chance to add two extra shards.
- The Prismatic Radiance Egg hatches Prism Fox (60%), Crystal Fawn (30%), or Aurora Dragon (10%). The existing egg collection, respawn and hatch systems are reused.
- The Russian HUD shows the saved Crystal Shard balance. Static CI and world-health checks cover the biome structure and service wiring.
- Studio runtime, balance, multiplayer, mobile and performance acceptance remain outstanding.


## Crystal Prism Trial — Sprint 4.25
- The Crystal Realm trial contains three reflectors and a visible clue for the Azure → Rose → Crown activation sequence.
- Each player's sequence is stored in `QuestProgress.CrystalTrialPrisms`. Activating the wrong prism clears only that player's sequence. Completing all three unlocks the Prism Guardian.
- The Prism Guardian has 160 saved health per player. Valid interactions deal 20 damage. It telegraphs a 22-damage area pulse for 1.55 seconds; moving outside its 24-stud radius avoids the hit.
- Defeating the guardian completes `crystal_trial` and awards +500 XP once. The existing progression configuration gates Ancient Heights behind level 50 and `crystal_trial`.
- The first Ancient Heights landing platform and a return portal are present; this is a destination slice, not the completed biome.
- The Russian trial HUD shows puzzle progress, guardian health, and the dodge warning. CI and world-health checks cover puzzle props, prompts, guardian, and destination portals.
- Roblox Studio runtime, multiplayer, balance, collision, mobile, and performance acceptance remain outstanding.

## Ancient Heights — Sprint 4.26
- Access requires level 50 and completion of the Crystal Prism Trial (crystal_trial).
- The first playable slice is the Elder Canopy: a central stone path, eight old trees, six rune pillars, and Ancient Egg pickups.
- Ancient Egg hatch weights are 55% Ancient Stag, 30% Root Sprite, and 15% Sky Serpent.
- Egg collection, respawn, hatch validation, inventory capacity, discovery tracking, and genetic rolls reuse the existing server-authoritative egg pipeline.
- Ancient species have distinct follower silhouettes. Their active ability kits are intentionally not advertised until their server-authoritative implementations are added.


## Ancient Heights gathering — Sprint 4.27
- Six glowing Elderwood root nodes are distributed along the Elder Canopy path.
- Harvesting is available only while the player is in Ancient Heights and has the required level/trial unlock.
- Each player has an independent three-minute cooldown for every node.
- A successful harvest grants 1–3 Elderwood, persisted in Materials.Elderwood.
- The Ancient Heights HUD displays the saved balance; client UI never grants resources.
- Elderwood is a progression material; its crafting/unlock sink is intentionally deferred until the first gathering playtest.


## Whispering Grove secret — Sprint 4.27
- A short sequence of floating stepping stones leads from the Elder Canopy to a hidden outer ledge.
- The ledge contains four rune pillars and the Elder Heart altar.
- The altar can be claimed once per player, guarded by server-side biome, progression, character, distance, profile, and duplicate-claim validation.
- First discovery grants 250 coins, 150 XP, and 8 Elderwood; completion is saved in CompletedQuests.ancient_grove_secret.
- The secret is a one-time exploration reward, not a repeatable currency farm.


## Elderwood workshop — Sprint 4.28
- The Ancient Heights Elderwood Workshop is a physical workbench in the Elder Canopy, with an in-world recipe sign.
- Craft one Ancient Egg for 10 Elderwood and 300 coins.
- The server validates Ancient Heights presence, zone unlock, living character, prompt distance, loaded profile, egg bag capacity (20), available resources, and the shared BiomeCatalog recipe.
- The recipe is charged only after all checks pass.
- Crafted eggs enter the normal saved egg inventory as AncientEgg / AncientHeights / Crafting and hatch through the player's own nest station.
- The existing BiomeCatalog remains the single source of truth for Ancient Egg species weights (55/30/15); crafting does not reroll or modify odds.


## Ancient Tree Temple — Sprint 4.29
- A side-island temple in Ancient Heights is connected by a solid stone causeway.
- The temple contains a three-rune puzzle. The required order is Root → River → Dawn; activating a wrong rune resets only that player's sequence.
- Rune progress is saved in `QuestProgress.AncientTempleRunes` and is independent for each player.
- After solving the puzzle, each player can claim the temple chest once. The one-time reward is 500 coins, 300 XP, and 20 Elderwood.
- The objective HUD displays progress and completion while the player is in Ancient Heights.
- A dedicated boss encounter and boss-exclusive companion are reserved for the next sprint.


## Heartwood Guardian — Sprint 4.30
- The Guardian is the Ancient Tree Temple boss and is available only after the player's own Root → River → Dawn puzzle and treasure claim.
- Boss health is stored per player in `QuestProgress.AncientTempleBossHealth` (240 HP); one player's damage does not affect another player's encounter.
- The boss alternates two telegraphed attacks: Vine Slam (30 damage, 15-stud radius, 1.8-second warning) and Root Wave (18 damage, 26-stud radius, 1.25-second warning). Moving outside the active attack radius before impact avoids damage.
- A one-time victory grants 600 XP and the legendary Heartwood Guardian companion. The companion is never included in natural egg pools and is labeled as boss-exclusive in the collection book. Boss-exclusive companions cannot be used as breeding parents, so this reward remains exclusive to the boss encounter.
- The reward is added to the collection and automatically activated only when an active companion slot is available.


## Heartwood Guardian — Sprint 4.31
- At 120 HP (50% of maximum), the Guardian enters phase two for that player. The phase is saved implicitly through that player's boss health and is independent of other players.
- Phase two adds Thorn Burst: 22 damage, 32-stud radius and a 2-second warning. Vine Slam and Root Wave remain in the attack rotation.
- The local client plays a core pulse, color shift, light burst and particle telegraph for the active player's attack. These visuals must not overwrite another player's phase or health.
- Defeating the Guardian grants a permanent trophy entry in `Nest.IslandTrophies.AncientTempleGuardian`. The trophy is displayed in the player's nest with the label “СЕРДЦЕ ДРЕВА”.


## Heartwood Guardian — Sprint 4.32
- Vine Slam uses a raised-arm windup followed by a downward strike.
- Root Wave uses a body recoil, raised head and spread arms.
- Thorn Burst spreads both arms and branches and flares the crown.
- All animated body parts return to their authored idle CFrames after the attack. A newer attack cancels stale tweens before starting its own choreography.
- The physical Guardian model is shared and its choreography is cosmetic only. Player health, attack windups, phase, damage and rewards remain per-player and server-authoritative.
- The heart core and PointLight telegraph remain local to each client so one player's phase does not recolor another player's encounter.
- On personal victory, the winning client plays a gold particle burst and heart-core reveal. The reward companion is still granted by the server.


## Whispering Grove hidden cache — Sprint 4.33
- Four runes are interactable on the hidden grove platform. Their required order is Moon → Leaf → Dew → Star.
- Each player's sequence is saved in `QuestProgress.GroveCacheRunes`. A wrong rune resets only that player's sequence.
- The cache is locked until the four runes are activated in order. The server validates biome, zone access, living character and interaction distance.
- A successful first claim sets `CompletedQuests.whispering_grove_cache` and grants 5 Moonpetals, 400 coins and 200 XP. Repeated claims grant nothing.
- Moonpetals are stored in `Materials.Moonpetal` and mirrored to the `Moonpetal` player attribute for UI and crafting integrations.
- The Ancient Heights HUD displays the player's personal cache-rune progress.


## Forgotten Heart Cave — Sprint 4.34
- A side-dungeon island is connected to Ancient Heights by a stone bridge. The cave contains a floor, rock walls, ceiling, stalactites, three crystals and a treasure chamber.
- The crystal sequence is Root → River → Dawn. Each player's sequence is stored in `QuestProgress.ForgottenCaveCrystals`; a wrong crystal resets only that player's sequence.
- The treasure chest stays locked until all three crystals are activated in order. The server validates the player's biome, zone access, living character and distance to the interaction target.
- A first successful claim sets `CompletedQuests.forgotten_cave_cache` and awards 3 Starshards, 600 coins and 300 XP. Repeated claims grant nothing.
- Starshards are stored in `Materials.Starshard` and mirrored to the `Starshard` player attribute.
- The Ancient Heights quest HUD displays the player's cave progress and completed-cache state.


## Forgotten Heart companions — Sprint 4.35
- The cave treasure chest grants one `ForgottenCaveEgg` per player, in addition to 3 Starshards, 600 coins and 300 XP.
- The egg is stored in the existing egg inventory and hatched through the normal nest hatch station. Claiming requires a free egg slot.
- Species odds are fixed and visible in the cave: Cave Glimmerbat 65%, Crystal Prowler 25%, Heart Wisp 10%.
- Cave Glimmerbat is Rare, Crystal Prowler is Epic, and Heart Wisp is Legendary. Each has a distinct follower silhouette, personality, preferred food/toy, income and ability metadata.
- All three species are registered in CompanionCatalog and BiomeCatalog, so the existing hatch, discovery and Collection Book pipelines handle them without a separate hatch implementation.


## Forgotten Heart Guardian — Sprint 4.36
- The cave guardian becomes attackable after the player has completed the Root → River → Dawn puzzle and claimed the Forgotten Cave treasure chest.
- Each player's encounter health is stored in `QuestProgress.ForgottenHeartBossHealth` (360 HP). The encounter and completion flag are personal and persist across sessions.
- The player attacks by using the guardian's proximity prompt. Each successful strike deals 30 damage, with a 0.8-second per-player hit cooldown.
- At 180 HP the boss enters phase II. Phase I uses Crystal Slam and Echo Pulse; phase II also unlocks Shard Rain.
- Attacks are server-authoritative and telegraphed with ground markers. Targeted markers are shown only to the player whose encounter is being attacked. Players avoid damage by leaving the marked area before the windup ends.
- A successful first defeat grants the Mythic boss-exclusive companion `ForgottenHeartGuardian`, 1,200 coins, 5 Starshards and 800 XP. Repeated interactions grant no duplicate reward.
- The reward companion is permanently recorded in the Collection Book under Пещера забытого сердца and has its own follower silhouette.


## Forgotten Heart Guardian choreography — Sprint 4.37
- Boss attack animations are client-local and keyed to the player's replicated windup attributes: Crystal Slam raises and slams both arms, Echo Pulse spreads the arms, and Shard Rain raises both arms to summon falling shards.
- The second phase has a one-time awakening flourish: the core turns violet, the guardian spreads its arms and arena crystals shatter.
- Eight crystal clusters decorate the arena. Shard Rain and phase awakening break the clusters for the local player; flying shard debris is cosmetic and clusters regrow after eight seconds.
- Victory plays a collapse animation while the golden heart remains visible.
- The server raises ForgottenHeartBossRewardReveal only on a fresh victory. The client uses this transient signal to show the mythic companion reveal card. Returning players who already defeated the boss do not see the acquisition scene again.
- All choreography, debris and crystal breakage are client-local; the server remains authoritative for damage, health, completion and rewards.


## Forgotten Heart combat feedback — Sprint 4.38
- The server increments `ForgottenHeartBossHitPulse` after each accepted player hit and `ForgottenHeartBossDamagePulse` when a boss attack damages the player.
- The client uses these signals for a guardian recoil reaction (body compression, head recoil, core flash and crystal sparks), a subtle hit camera shake, and a stronger red-screen/camera response when the player takes damage.
- These effects are cosmetic and local to the challenged player. Boss health, damage, cooldowns, attack resolution and rewards remain server-authoritative.
- Sound effects are intentionally not assigned placeholder asset IDs. Curated/licensed Roblox audio assets must be selected and verified before sound is marked complete.


## Forgotten Heart combat readability — Sprint 4.39
- Crystal Slam warning zones use cyan, Echo Pulse uses violet, and Shard Rain uses pink. The warnings remain local to the challenged player.
- The boss health bar animates to the latest server-replicated health value and changes accent color at phase II.
- Successful player hits display a short floating damage number calculated from the replicated health delta. This is display-only; the server remains authoritative for hit validation and damage.\n\n## Unified material inventory — Sprint 4.40
- Provide a single read-only inventory panel for Elderwood, Moonpetal, Starshard, Crystal Shards, and Ash Crystals.
- Display live values from server-replicated player attributes; never accept client-side resource edits.
- PlayerDataService publishes saved balances for Elderwood, Moonpetal, and Starshard when a profile loads, alongside the existing Ash Crystal and Crystal Shard attributes.
- The panel is reachable from the main navigation, uses the shared modal coordinator, and must fit narrow mobile viewports.
- Existing biome-specific HUDs remain contextual; this panel is the cross-biome overview.\n

## Ancient Egg advanced recipe — Sprint 4.41
- The Ancient Heights workshop crafts one Ancient Egg for 10 Elderwood, 5 Moonpetals, 3 Starshards and 300 coins.
- All four balances are validated server-side before any ingredient is deducted.
- Insufficient ingredients reject the craft without partial spending and report the exact missing resource.
- On success, all ingredients are deducted together, the egg is added to the normal egg inventory, and updated resource/coin attributes are replicated.
- Egg species odds remain the existing AncientEgg BiomeCatalog weights (55/30/15).

## Artifact collection — Sprint 4.42
- Artifacts are persistent instances in `profile.Artifacts`; equipped instance IDs are stored separately in `profile.EquippedArtifacts`.
- Maximum equipped artifacts: 2. The server validates ownership and slot capacity for every equip action.
- The Ancient Heights workshop crafts one random artifact for 4 Moonpetals, 2 Starshards, 2 Crystal Shards, 1 Ash Crystal and 250 coins.
- Initial Sprint 4.42 craft weights (before Researcher and Hunter families): Root Sigil 42% (+3% passive income), Moon Pendant 21% (+6%), Star Prism 7% (+10%), Root Harvester 12% (+5% gathering), Moon Forager 6% (+10% gathering), Star Prospector 2% (+15% gathering). These historical weights were later rebalanced as new artifact families were introduced; see Sprint 4.46 for the current 100-point catalog.
- Bonuses stack additively and are capped at +20% to passive income from active companions.
- The UI displays owned artifacts, rarity, effect and equipment state. All crafting, ownership and equipment changes are server-authoritative.

## Artifact upgrade levels — Sprint 4.43
- Each artifact instance stores an integer `Level` from 1 to 6.
- Tier labels: I Обычный, II Улучшенный, III Редкий, IV Эпический, V Легендарный, VI Мифический.
- Three unique artifacts of the same catalog ID and level merge into one new instance at the next level.
- Equipped artifacts cannot be consumed by a merge. Server validation rejects malformed, duplicate, unowned, mixed-type, mixed-level and max-level inputs.
- Passive-income bonus is base catalog bonus × `(1 + 0.25 × (Level - 1))`; the sum of equipped bonuses remains capped at +20%.
- The artifact UI offers merge actions only for groups of at least three unequipped copies.

- The merge UI displays a confirmation overlay with the resulting next tier before any artifact is consumed.

## Gatherer artifact family — Sprint 4.44
- Three new artifacts affect resource yield: Root Harvester (+5%), Moon Forager (+10%), Star Prospector (+15%).
- Gatherer bonuses scale by 25% per artifact upgrade level, like passive-income bonuses. The combined gathering bonus from equipped artifacts is capped at +50%.
- The server-only ArtifactBonusService calculates bonuses from owned artifact instances referenced by EquippedArtifacts. Client input cannot choose a bonus or resource amount.
- Bonuses are applied to the successful base yield of Elderwood roots in Ancient Heights and crystal veins in Crystal Realm, after existing companion mining bonuses.
- Fractional expected bonus yield is rolled once per successful node harvest. It does not bypass or shorten the existing per-node cooldown.
- After adding Hunters in Sprint 4.46, current weights total 100: income artifacts use 36/18/6 (60%), Gatherer artifacts use 12/6/2 (20%), Researcher artifacts use 6/3/1 (10%), and Hunter artifacts use 6/3/1 (10%). Each family retains a 6:3:1 relative rarity ratio.

### Studio QA fixture — Gatherer artifacts
- The artifact collection exposes a temporary QA action only when the client is running in Roblox Studio.
- The server independently enforces `RunService:IsStudio()`, fills each of the three Gatherer types to three level-I instances, and enforces the 40-item collection limit.
- This fixture is for local gameplay verification only; it is unavailable in published servers and does not alter crafting odds or normal player progression. QA instances are tagged `DevOnly`, excluded from persistent save snapshots (including equipped IDs), and cannot be merged with normal crafted instances.


## Researcher artifact family — Sprint 4.45
- Three Researcher artifacts increase player XP rewards: Field Journal (+5%), Moon Atlas (+10%), Star Compass (+15%).
- Research bonuses scale by 25% per artifact upgrade level; the combined equipped Researcher bonus is capped at +50%.
- All positive XP awards pass through the server-authoritative `ProgressionService:AddXP` entry point. It applies the equipped Researcher bonus after validating the profile and base reward; clients cannot select an XP amount or bonus.
- Fractional expected bonus XP is rolled once per XP award. A zero or invalid base reward awards no XP and does not trigger a bonus roll.
- Trial, secret, boss, and companion-ability notices display the actual XP awarded, the actual extra XP, and the expected Researcher percentage when equipped (including a zero-extra roll); they never display the unmodified base reward as if it were the final amount.
- The artifact snapshot exposes each Researcher bonus and the combined equipped XP bonus. The collection UI displays the scaled effect and equipped XP total.
- Current craft odds reserve 10% for Researchers (6/3/1) and 10% for Hunters (6/3/1), alongside 60% income (36/18/6) and 20% gathering (12/6/2).
- Roblox Studio exposes a temporary Researcher fixture and a deterministic 1000-award simulation. Both are server-guarded, use an isolated random stream, and the simulation never changes profile XP or player level.


## Hunter artifact family — Sprint 4.46
- Three Hunter artifacts improve the chance of hatching a companion from the highest rarity tier present in the selected natural egg: Hunter Trophy (+5%), Moon Tracker (+10%), Hunter Crown (+15%).
- The percentage is a relative multiplier on the weights of the egg's highest available rarity tier, not a percentage-point guarantee. All lower rarity weights remain unchanged and the complete table is renormalized.
- The server derives rarity rank from CompanionCatalog and selects from the original biome egg SpeciesWeights. It does not add species, alter base tables, or change genetic-trait odds.
- Hunter bonuses apply only to natural world/shop eggs. Breeding eggs retain their inherited offspring and trait without any Hunter reroll.
- Hunter bonuses scale by 25% per artifact upgrade level; the combined equipped Hunter bonus is capped at +30%. The two existing equipment slots remain unchanged.
- Successful natural hatch notices display the actual highest-tier chance before and after the equipped Hunter modifier.
- Egg Shop and Collection Book calculate each species' current normalized chance from the same server-side helper used by hatching. When a Hunter changes a species chance, the UI also shows its unmodified base chance.
- Shared world egg signs are static reference points and must be labeled as base odds without Hunter artifacts; player-specific live odds belong in the shop and Collection Book.
- Craft weights are rebalanced to income 36/18/6 (60%), Gatherer 12/6/2 (20%), Researcher 6/3/1 (10%), Hunter 6/3/1 (10%); all weights total 100.
- Roblox Studio exposes a server-guarded Hunter fixture and a deterministic 7,000-hatch simulation (1,000 per natural egg table). The simulation uses the production selection formula and does not consume eggs, grant companions, change XP, or mutate profile inventory.
- The inventory snapshot and collection summary expose all four combined equipped effects: passive income (capped at +20%), gathering (capped at +50%), XP (capped at +50%), and Hunter hatch weighting (capped at +30%).


## Raid consent and matchmaking — Sprint 4.47
- Raid participation is opt-in and session-only. Players separately enable attacker readiness or open their own nest to voluntary challenges; each window lasts ten minutes.
- Both roles require a loaded profile, an assigned personal plot, level 5 or higher, and completion of a fifteen-minute newcomer protection period after joining the current server.
- The matchmaking board lists only online players in the same server who have explicitly opened defense and remain eligible. Players visiting another island cannot participate.
- A challenge expires after 45 seconds and requires an explicit accept or decline from the defender. Each attacker has a 30-second challenge cooldown.
- Acceptance creates a server-owned READY match record for up to two minutes. Either participant may cancel it; disconnects and expiry clear the record for both players.
- This foundation does not move characters, start combat, or modify coins, eggs, companions, artifacts, or profile data. Those actions require a later, separately validated raid encounter.

- Roblox Studio exposes a temporary **ТЕСТ: ОТКРЫТЬ ДОСТУП К РЕЙДАМ** control. It bypasses the level/time gates only in the current Studio session; it does not edit the profile, saved level, or published-server rules. A separate reset action restores newcomer protection.

 
## Bounded raid arena — Sprint 4.48
- A raid arena is created only after an eligible defender explicitly accepts an invitation. Each match receives its own isolated arena instance.
- The attacker wins by reducing the Nest Core from 100 integrity to zero. The defender wins if the 150-second timer expires first.
- The attacker can strike the core for 20 integrity every 2.2 seconds; the defender can restore 10 integrity every 8 seconds. Both actions require a living character within 16 studs of the core and are validated on the server.
- The round does not allow player-versus-player damage, theft, or changes to nest ownership, eggs, companions, artifacts or materials.
- Both players' original character pivots are stored before teleporting. Normal completion, voluntary exit, death and disconnect clean up the arena and restore the remaining participant; a respawning participant is returned to the saved position.
- A win grants 150 coins and 100 XP; the other participant receives 50 coins. Each player's reward is independently throttled by a persistent ten-minute cooldown in QuestProgress.RaidRewardCooldownUntil.
- A voluntary early exit, death or disconnect cancels the match without rewards. A timed-out match is a defender win.
- The arena HUD exposes role, core integrity, remaining time, one role-specific action, and a no-reward forfeit control.
