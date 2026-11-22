# First Playable — Studio Test Flow

## Included in this slice
- Generated Starter Island blockout with spawn, path, trees, distant island silhouettes, three Meadow Egg pickups, and a hatch station.
- Server-side egg collection with distance and capacity checks.
- Server-side weighted hatch roll from the shared companion catalog.
- Companion passive coin income.
- Six server-assigned personal nest plots with owner signs and owner-only hatch validation.
- Placeholder fox, turtle, and dragon companion models follow the player (up to three visible).
- Server-authoritative egg shop: buy Meadow Eggs for 50 coins, with server-side balance and bag-capacity checks.
- Shop UI shows the exact 55% / 30% / 15% hatch probabilities.
- Shared companion catalog drives hatch weights, shop odds, names, rarity, and income.
- Collection book tracks discovered species, duplicates, and collection completion.
- Server-authoritative companion inventory with equip / unequip and a three-pet active limit.
- Russian, touch-friendly collection panel with rarity, level, and passive income details.
- Only equipped companions follow the player and generate passive income.
- Minimal HUD for coins, eggs, companions, level, personal plot, and notices.
- Initial profile persistence and biome progression foundation.

## Required Studio setup
1. Install Roblox Studio.
2. Install Rojo and the Rojo Studio plugin.
3. Clone this repository and check out branch feature/first-playable-loop.
4. From the repository root, run `rojo serve`.
5. In Studio, create/open a test place and connect the Rojo plugin.
6. Confirm mapped services appear in Explorer, then press Play.
7. Default Studio mode uses an in-memory profile, so the gameplay loop can be tested immediately without publishing. Progress resets when the Studio session ends. For persistence/session-lock tests, publish a separate private test experience, set GameConfig.UseStudioDataStore = true, and enable Studio Access to API Services. Never point development tests at the production experience.

## Player test
1. Spawn on Starter Island.
2. Walk to a glowing Meadow Egg and press E / tap the prompt.
3. Confirm HUD egg count increments.
4. Find your assigned plot (shown in the HUD) and use its Hatch Egg prompt.
5. Confirm one egg is consumed and one companion is added.
6. Confirm the hatched companion appears and follows your character.
7. Open «Магазин яиц», buy a Meadow Egg for 50 coins, and verify both balance and egg count update.
8. Confirm the shop displays 55% / 30% / 15% hatch odds.
9. Open «Книга коллекционера» and confirm undiscovered species are hidden and completion counts unique species.
10. Open «Мои питомцы», equip and unequip companions, and confirm no more than three can be active.
11. Confirm only equipped companions follow you and generate passive income.
12. Wait for passive income; confirm Coins increases.
13. Rejoin the private test place and confirm data persists.

## Known limitations
- World geometry is a temporary scripted blockout, not final art.
- Synty Nature Pack is catalogued as a candidate but must be imported and inspected manually in Studio.
- Plots are currently six fixed slots per server; dynamic plot expansion and polished nest customization are not implemented.
- Companion visuals are temporary scripted blockout models, not final imported character assets. Only the first three companions are shown following a player.
- Carrying animation, egg carrying inventory, trading, and PvP raids are not implemented.
- Starter companion odds are prototype values; the shop currently discloses them, but a dedicated hatch reveal screen is still required before release.
- DataStore behavior has not been runtime-verified in Studio.
- DataStore session locking is implemented in code but still requires runtime verification in a private published test experience. Default Studio testing uses ephemeral profiles and does not save progress.
