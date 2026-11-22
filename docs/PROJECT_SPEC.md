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
