# First Playable — Studio Test Flow

## Included in this slice
- Generated Starter Island blockout with spawn, path, trees, distant island silhouettes, three Meadow Egg pickups, and a hatch station.
- Server-side egg collection with distance and capacity checks.
- Server-side weighted hatch roll from a starter companion table.
- Companion passive coin income.
- Minimal HUD for coins, eggs, companions, level, and notices.
- Initial profile persistence and biome progression foundation.

## Required Studio setup
1. Install Roblox Studio.
2. Install Rojo and the Rojo Studio plugin.
3. Clone this repository and check out branch feature/first-playable-loop.
4. From the repository root, run `rojo serve`.
5. In Studio, create/open a test place and connect the Rojo plugin.
6. Confirm mapped services appear in Explorer, then press Play.
7. For DataStore tests, publish a separate private test experience and enable Studio Access to API Services. Never point development tests at the production experience.

## Player test
1. Spawn on Starter Island.
2. Walk to a glowing Meadow Egg and press E / tap the prompt.
3. Confirm HUD egg count increments.
4. Return to the wooden nest and use Hatch Egg.
5. Confirm one egg is consumed and one companion is added.
6. Wait for passive income; confirm Coins increases.
7. Rejoin the private test place and confirm data persists.

## Known limitations
- World geometry is a temporary scripted blockout, not final art.
- Synty Nature Pack is catalogued as a candidate but must be imported and inspected manually in Studio.
- Egg collection and hatching are currently a shared starter-island test loop; per-player plots, carrying animation, egg inventory UI, companion models/following, and PvP raids are not implemented.
- Starter companion odds are prototype values and must be disclosed in hatch UI before release.
- DataStore behavior has not been runtime-verified in Studio.
- Profile session locking is not implemented yet; do not treat this as a production-ready save system.
