# NEST RAIDERS — Roadmap

Status legend: [x] done · [ ] not done · [~] in progress

## Release principles
- Ship a genuinely playable vertical slice before expanding content.
- Server-authoritative economy, inventory, hatching, stealing, and progression.
- Mobile-first controls and performance budgets from the first prototype.
- No pay-to-win advantages; monetization must be transparent and fair.
- Every milestone ends with a Studio test checklist and a tagged build.

## Milestone 0 — Project foundation
- [x] Create repository and product direction.
- [x] Lock bright art direction, connected island world, balanced PvP, ambitious scope.
- [x] Add Rojo project mapping and Luau folder structure.
- [x] Add shared configuration, profile template, and server bootstrap.
- [x] Add initial DataStore profile lifecycle and zone progression rules.
- [x] Add project specification, asset pipeline, asset catalog, and Studio test checklist.
- [ ] Add automated static checks / CI.
- [ ] Validate Rojo build and Luau scripts in Roblox Studio.

## Milestone 1 — First playable loop
- [x] Generate a temporary Starter Island blockout with spawn, eggs, and hatch station.
- [x] Collect eggs with server-side distance and capacity checks.
- [x] Hatch an egg with a server-side weighted companion roll.
- [x] Companion passive income prototype.
- [x] Minimal HUD for coins, eggs, companions, and level.
- [ ] Per-player nest plots and ownership.
- [ ] Carry animation and world egg inventory UI.
- [ ] Companion models and follow behavior.
- [ ] Buy a basic egg and see inventory update.
- [ ] Save and restore progress after reconnect in Studio.
- [ ] Replace blockout environment with curated Creator Store assets.
- [ ] Full desktop and mobile playtest.

## Milestone 2 — Open-world progression
- [ ] Seamless connected biomes with no mandatory world portals.
- [~] Level and quest requirements defined in shared configuration; gameplay gates not yet implemented.
- [ ] Server-side zone checks for egg collection and interactions.
- [ ] Starter Island, Emerald Wilds, Frost Highlands, Emberlands, Crystal Realm, Ancient Heights, Void Frontier.
- [ ] World landmarks, secrets, caves, traversal routes, and discovery rewards.

## Milestone 3 — Nest, companions, and economy
- [ ] Nest expansion and decoration.
- [ ] Companion rarity, traits, passive income, and collection book.
- [ ] Egg hatch tables with disclosed probabilities.
- [ ] Trading with confirmation, cooldowns, and scam-resistant UI.
- [ ] Economy sinks and telemetry-driven balancing.

## Milestone 4 — Raiding and PvP
- [ ] Opt-in / clearly signposted raid windows and protected newcomer period.
- [ ] Balanced raid tools, defenses, cooldowns, and recovery.
- [ ] Anti-grief safeguards and server-side validation.
- [ ] Matchmaking / server population tuning.
- [ ] Abuse reporting and moderation hooks.

## Milestone 5 — Live operations and launch readiness
- [ ] Daily and weekly quests.
- [ ] Rotating events and limited-time cosmetics (not exclusive power).
- [ ] Tutorial, onboarding analytics, retention and funnel instrumentation.
- [ ] Device/performance testing, exploit review, accessibility pass.
- [ ] Store page, thumbnails, trailer, localization, launch checklist.

## Release gates
A milestone is not complete until its acceptance tests pass in Roblox Studio on desktop and mobile emulation. Monetization and public launch are blocked until saving, server authority, exploit resistance, and moderation basics are verified.

## Current implementation note
The current code is a foundation, not yet a playable game. DataStore persistence and progression logic have not been runtime-tested in Studio. The first playable loop and Creator Store asset integration remain upcoming work.
