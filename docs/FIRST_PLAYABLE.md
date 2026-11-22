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
- Fuse three matching pets into a two-star or three-star companion; fusion is server-validated and consumes two duplicates.
- Higher star ranks increase passive income and add visible aura / star effects.
- Place owned companions on unlocked personal nest pedestals; displayed pets are separate from the active follower team.
- Displayed pets accumulate a separate income balance every 10 seconds, which the player collects manually from the nest UI.
- Displayed pets animate with a gentle idle bob / turn and show a mood bubble.
- Players can pet or play with displayed pets to raise saved mood (with server-side cooldowns).
- Displayed pets have persistent hunger and energy needs; both decay gradually and elapsed time is applied when the player returns.
- Starter species have distinct personalities and favorite foods: the Meadow Fox is Curious and likes Sweet Berries, the Moss Turtle is Calm and likes Young Leaves, and the Sprout Dragon is Playful and likes Glowfruit.
- Personality gives species-specific mood bonuses for petting or playing; the nest care panel shows each pet personality and favorite food.
- A favorite treat costs 15 coins, restores 35 hunger, and grants 15 mood; the server selects the correct favorite food from the companion catalog.
- The nest toy shop offers a Meadow Ball (25 coins), Cozy Plush (40 coins), and Wind Spinner (35 coins). Each displayed pet can equip one toy; replacing it purchases the new toy at full price.
- The nest decoration shop offers a Flower Pot (30), Warm Lantern (55), Meadow Crystal (75), and Mushroom Seat (90). Buy decorations into inventory, place them in an unlocked empty slot, and remove them to return them to inventory.
- Nest level 1 has two decoration slots; each nest upgrade unlocks one additional slot, up to six at level 5. Decoration changes are saved with the player profile.
- Placed decorations can be nudged around the nest on a 2-stud grid and rotated in 15-degree steps using touch-friendly controls; server checks keep them inside the plot.
- The decoration editor provides a local surface preview, click / tap-to-place confirmation, desktop R rotation, mobile rotate / cancel buttons, and hides the shop while the player chooses a point on their island.
- Playing with an equipped toy increases mood by its catalog bonus plus 10 when it is the pet’s favorite toy; energy cost is determined by the toy (the Wind Spinner costs no energy).
- Toy models are temporary scripted props; curated Creator Store toy assets are a later visual pass.
- Feed a pet for 10 coins to restore 35 hunger and 5 mood; tired pets can rest for 60 seconds to recover energy.
- Playing consumes 10 energy; exhausted pets refuse play. Needs are currently personal-care flavor and do not change income.
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
11. Obtain three identical pets, fuse them, and confirm two duplicates are consumed and the selected pet gains a star rank.
12. Confirm higher star ranks show an aura and increase income.
13. Confirm only equipped companions follow you and generate passive income.
14. Wait for passive income; confirm Coins increases.
15. Open «Улучшить гнездо», buy available upgrades, and verify decorations and display pedestals unlock.
16. Open «Питомцы на витринах», place an available companion on an unlocked pedestal, and verify its model appears in the nest.
17. Wait 10 seconds and collect the displayed-pet income; verify the wallet and stored balance update.
18. Pet and play with a displayed companion; confirm mood increases and play consumes energy.
19. Feed the pet for 10 coins and confirm hunger / mood update; try feeding with insufficient coins.
20. Give the pet its favorite treat for 15 coins; verify the food name, hunger and mood response.
21. Compare petting / play mood gains for the three starter personalities.
22. Equip each toy type on a displayed pet; confirm its coin cost, model prop, and nest panel label.
23. Play with the equipped toy; verify mood and energy changes, including the favorite-toy bonus.
24. Put a tired pet to sleep and confirm energy recovers over 60 seconds.
25. Open the decoration shop while standing near your own nest.
26. Buy a Flower Pot and a Warm Lantern; verify coin deductions and inventory counts.
27. Place each decoration in a free slot and verify the correct models appear in your plot.
28. Remove one decoration and verify it returns to inventory; try placing into an occupied or locked slot.
29. Upgrade the nest and confirm one additional decoration slot unlocks.
30. Remove the displayed pet and confirm it returns to the available list.
31. Rejoin the private test place and confirm nest level, display assignments, pet mood, needs, equipped toys, decoration inventory, placed decorations, and uncollected income persist.

## Known limitations
- World geometry is a temporary scripted blockout, not final art.
- Synty Nature Pack is catalogued as a candidate but must be imported and inspected manually in Studio.
- Plots are currently six fixed slots per server; dynamic plot expansion and polished nest customization are not implemented.
- Companion visuals are temporary scripted blockout models, not final imported character assets. Only the first three companions are shown following a player; displayed pets are rendered separately on personal nest pedestals.
- Carrying animation, egg carrying inventory, trading, and PvP raids are not implemented.
- Starter companion odds are prototype values; the shop currently discloses them, but a dedicated hatch reveal screen is still required before release.
- DataStore behavior has not been runtime-verified in Studio.
- DataStore session locking is implemented in code but still requires runtime verification in a private published test experience. Default Studio testing uses ephemeral profiles and does not save progress.


## Island building catalog
- The Russian island construction panel contains five object types: Stone Path (12), Clover Bush (28), Apple Tree (85), Wooden Fence (22), and Cozy Cottage (260).
- Buy objects into a persistent building inventory, place them on a 2-stud grid, move and rotate them, or remove them back to inventory.
- The server validates profile readiness, plot ownership, proximity, catalog IDs, currency, inventory, plot bounds, object overlap, and the 100-object island cap.
- Buildings are saved in the player nest profile and rebuilt when the player's plot is assigned. Rendered models are cleared when the plot is released.
