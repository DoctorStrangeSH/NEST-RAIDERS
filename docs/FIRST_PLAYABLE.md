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


## Building placement editor
- Selecting a building from the catalog opens a translucent footprint preview over the player's own island.
- The preview follows the mouse or touch position, snaps to a 2-stud grid, and shows green for valid locations and red for blocked / out-of-bounds locations.
- Confirm with click / tap; rotate in 15-degree steps with R or the on-screen control; cancel with Escape or the on-screen control.
- Existing buildings can be repositioned with the same preview flow.
- Server-side checks independently validate plot bounds and object overlap before saving.


## Fantasy garden landmarks — Sprint 4.6
- Flower Arch (145 coins): wooden garden arch with flower details.
- Crystal Pond (190 coins): shallow glowing water feature with stone shoreline, lily pad, and bloom.
- Moon Fountain (320 coins): layered stone fountain with a glowing moon crystal and soft point light.
- All three objects use the same persistent build inventory, grid placement, movement, rotation, removal, and server-side footprint validation as the original catalog.


## Social island visits — Sprint 4.7
- Players can open a Russian-language browser of other occupied islands in the current server.
- The list shows display name, level, and current visitor count; it never lists the player's own island.
- Visiting teleports the character to the destination plot while preserving the exact pre-visit CFrame for Return Home.
- A player may inspect another island but existing ownership checks continue to protect purchases and building edits.
- Each island supports up to eight visitors. If its owner leaves, current visitors are returned to their own saved position.
- This is an in-server social feature only; global discovery, likes, favorites, and ranking are future work.


## Island likes and favorites — Sprint 4.8
- The in-server island browser displays received likes and sorts islands by popularity.
- Players can toggle one unique like per island owner; likes are stored in the owner's profile keyed by the visitor's stable UserId.
- Players can save up to 30 other islands to favorites; favorites are stored in their own profile keyed by owner UserId.
- The browser includes an all-islands / favorites-only filter.
- Social actions are server-validated and rate-limited. Browsing the list itself is not throttled.
- Likes and favorites are social recognition only; they grant no currency, XP, pets, or combat advantages.
- Cross-server discovery and global weekly showcases are not part of this milestone.


## Weekly island contests — Sprint 4.9
- Added three weekly island categories: Cozy (Уют), Nature (Природа), and Fantasy (Фэнтези).
- Players can cast one vote per category per UTC week for another occupied island in their current server.
- Votes are stored per voter and category-week; an idempotent per-owner vote ledger is projected into cross-server OrderedDataStore leaderboards. If the leaderboard projection fails, a later list request retries it safely.
- Each category shows the top ten islands and the currently available server nominees.
- Published experience uses persistent DataStores with cached standings and request throttling. Default Studio mode uses an in-memory local fallback and clearly marks its results as temporary.
- Contest votes do not grant gameplay power. Cosmetic winner rewards and cross-server island discovery remain future work.


## Hall of Fame and island trophies — Sprint 4.10
- The first contest list request after a new UTC week attempts to archive the previous week's top three in each category.
- Published servers store a shared 12-week Hall of Fame history; archive writes are idempotent per week.
- Only verified top-three winners may claim their category/week trophy. Claims are saved in the player's profile.
- Claimed trophies are displayed on the player's island and rebuilt when their plot is assigned.
- Local Studio mode uses an in-memory archive; it is temporary and does not represent published cross-server persistence.
- Week closure is lazy (triggered by contest access), not a scheduled background job. A scheduled finalizer is a future live-operations task.


## Global island discovery — Sprint 4.11
- Published servers advertise each occupied island in a shared TTL-backed MemoryStore sorted map. Entries refresh every 30 seconds and expire after 100 seconds.
- The island browser merges current-server plots with cross-server directory entries and deduplicates by owner UserId.
- A cross-server visit validates the current directory record and teleports the player to the exact public server.
- Destination arrival waits for profile, plot, and character readiness, then verifies the target player still owns the expected plot before moving the visitor.
- If the directory is unavailable, the browser retains local results and displays a degraded-status message.
- Studio mode intentionally remains local-only; cross-server behavior requires a published private test experience with MemoryStore and teleport access.


## Player identity and public profiles — Sprint 4.12
- Public profiles are available for players currently present in the same server. Cross-server and offline profile lookup is not implemented yet.
- Profile data is assembled server-side from the target player's loaded profile and exposes display name, username, level, nest level, companion totals, unique species count, collection completion, received island likes, trophy count, achievement states, and available titles.
- The profile does not expose currency, item instance IDs, session tokens, or raw save data.
- Achievements are derived from profile milestones and cannot be granted by the client.
- Cosmetic titles can be equipped only after their achievement is unlocked. The selected title is stored in `Nest.EquippedTitle` and displayed above the character.
- Studio uses ephemeral profile data; persistence of equipped titles must be verified in a published private test.


## Companion growth and genetics — Sprint 4.13
- Newly hatched companions receive a server-rolled genetic trait independent of species and egg rarity: Natural (72%), Verdant (18%), Luminous (8%), or Prismatic (2%). The trait is stored on the companion instance and remains stable through fusion.
- Companions can be trained with coins. Each training grants 75 GrowthXP and costs 30 + current level × 25 coins. Level cap is 10; each next level requires 100 + (current level − 1) × 55 XP, with XP carry-over.
- Growth stages are Hatchling (levels 1–3), Young (4–6), and Adult (7–10). Models scale up at stage boundaries and show genetic aura/spark effects for non-Natural traits.
- Passive income is recalculated from species base income, star rank, level, and the trait's capped bonus (0–8%). Level adds 4% per level above 1; star multipliers remain 1× / 1.75× / 3×.
- Training, XP, level-ups, and income updates are server-authoritative. Existing companions without genetics are reconciled to Natural.
- Fusion preserves the selected target companion's level, XP, and genetic trait while consuming two matching companions of the same species and star rank.


## Species-specific adult abilities — Sprint 4.14
- MeadowFox: TrailFinder grants coins (40 + level × 10 + star rank × 15).
- MossTurtle: RootBlessing adds nest-stored coins (100 + level × 20 + star rank × 25).
- SproutDragon: VerdantSpark grants player XP (35 + level × 5 + star rank × 10).
- Abilities unlock at companion level 7, require the companion to be equipped, and have a persistent 300-second per-companion cooldown.
- The server resolves species ability and reward formula from its catalog and validates ownership, equipped state, unlock level, profile state, and cooldown. The client only displays ability metadata and sends the companion instance ID.


## Adult breeding and genetic inheritance — Sprint 4.15
- Pair two different adult species (level 7+) to produce offspring; parents remain in the collection and receive a 30-minute cooldown.
- Breeding cost: 250 + combined parent star ranks × 100 coins.
- Offspring randomly takes one parent's species. Genetic outcome: 90% inherit one parent's trait, 7% Luminous mutation, 3% Prismatic mutation.
- Offspring starts at level 1 / one star and records both parent species for collection lineage.
- The collection UI uses a two-parent selection flow followed by explicit confirmation. Breeding is server-authoritative and blocked for active/displayed parents or a full collection.
- Distinct hybrid species models remain future work; current offspring uses one parent's existing species model.


## Lineage egg incubation — Sprint 4.16
- Breeding now produces a persistent lineage egg rather than an immediate companion.
- Incubation lasts five minutes. The egg stores the server-selected offspring species, inherited/mutated genetic trait, and parent species IDs.
- The collection displays incubator count, remaining time, offspring preview, and genetic trait. The player hatches the ready egg at their own plot's hatch station.
- The hatch service uses the stored offspring outcome; it does not reroll species or genetics. Standard eggs retain their existing random hatch behavior.


## Starter hybrid species — Sprint 4.17
- MeadowFox + SproutDragon produces EmberFox (Пламенный лис).
- MossTurtle + SproutDragon produces Fernshell (Папоротниковый панцирь).
- MeadowFox + MossTurtle produces BriarGuardian (Терновый страж).
- These three Epic species are breeding-only, excluded from natural egg drops, and shown as such in the collection book until discovered.
- Hybrid follower silhouettes are implemented. EmberFox has the CinderDash adult ability; the other two hybrid ability kits remain future work.


## Genetic mutation appearance — Sprint 4.18
- Verdant companions receive leaf-crystal ornaments and a glowing heart gem.
- Luminous companions receive three cyan lantern orbs with soft point lights.
- Prismatic companions receive three differently colored facets and a prismatic core.
- Inventory cards show genetic rarity and passive-income bonus.


## Personal nest breeding altar — Sprint 4.19
- Each personal nest now has a glowing breeding altar with an owner-only proximity prompt.
- The server only accepts breeding requests when the player is within 18 studs of their own altar.
- Existing breeding validation and confirmation remain in place.


## Breeding ritual reveal — Sprint 4.20
- The two selected companion models appear on opposite altar pads and move toward the core as colored energy beams converge.
- A lineage egg grows from a spark above the altar and receives trait-colored light and particles.
- Hybrid offspring receive a distinct golden shard burst.
- Effects are cosmetic; breeding results and incubation remain server-authoritative.

## Frost Highlands — Sprint 4.21
- Frost Highlands is the third explorable island, reached from Emerald Wilds through a portal gated by level 12 and the completed Emerald Grove trial.
- The island includes a snowfield, pine grove, luminous glacier crystals, three Frost Egg spawn points, three trial rune shrines, and a return portal to Emerald Wilds. A nine-section walkable ice causeway physically connects the island to Emerald Wilds; portals are optional fast travel.
- The Frost Egg uses its own disclosed hatch table: Frost Fox 60%, Snow Owl 30%, Glacier Bear 10%. The same odds are printed on an in-world sign beside the egg grove.
- The three new species have dedicated companion catalog entries and distinct low-poly fox, owl, and bear follower/display models. At companion level 7, Frost Fox finds a coin cache, Snow Owl grants XP, and Glacier Bear stores coins in the nest.
- Activate the Aurora, Glacier, and Winter runes to complete the Heart of Winter trial and receive 180 XP. Rune progress and completion are stored in the player profile.
- Completing the Frost trial satisfies the configured quest requirement for Emberlands; the next zone still requires level 22.
- World egg collection now checks that the player is in the matching unlocked biome; prompts cannot be used remotely from another island.
- CI static checks and world structural health checks cover the Frost island, egg prompts, trial runes, and return portal.
- Studio runtime, persistence, collision, and mobile acceptance are still required; a successful Rojo build is not proof of gameplay.

 
## Emberlands — Sprint 4.22.1
- Third expansion biome prototype after Frost Highlands: volcanic island, lava channels, basalt pillars, and magma core.
- Entry is already gated at level 22 and the completed Heart of Winter trial.
- Heat rises in three invisible server-readable hazard volumes, cools gradually outside them, and drops quickly inside the turquoise cooling sanctuary.
- At 100 heat, the server applies gradual damage and shows a critical warning. Heat resets on character respawn.
- Active Ember companions mitigate heat: Cinder Fox 12%, Magma Whelp 22%, Ash Phoenix 8%. Level-7 active abilities add temporary resistance, full short-duration immunity, or one rescue from critical heat per life.
- Ember Egg hatch odds: Cinder Fox 60%, Magma Whelp 30%, Ash Phoenix 10%. Eggs use the shared collection/hatching flow and biome-specific spawn pool.
- The Russian HUD shows heat percentage, protection, and danger/sanctuary status.
- Visuals are scripted prototypes. Studio playtesting, collision review, and mobile/performance acceptance are not yet complete.

 
## Ashfall world event — Sprint 4.22.2
- Volcanic event runs while players are exploring Emberlands: a 20-second warning, three moving lava surges, then a 75-second reward window.
- Lava surges are server-authoritative and deal damage when they cross a player; the cooling sanctuary remains a safe zone.
- Four glowing ash crystals appear after the event. Each player can collect each node once per event.
- Ash crystals persist in the profile and are shown in the Russian event HUD alongside the countdown and current event phase.
- The event is a scripted gameplay prototype. Studio runtime, multiplayer, balance, and mobile acceptance are still required.


## Heart of Fire trial — Sprint 4.23
- Climb twelve basalt steps to the summit altar in Emberlands.
- Activate three runes: Ember, Cinder, and Inferno. Progress is saved per player.
- Fight the Heart of Fire Guardian. Each successful interaction deals 25 damage; watch for its 1.4-second windup and move more than 23 studs away to dodge its 18-damage counterattack.
- Guardian health persists per player. Defeating it completes ember_trial and awards +250 XP once.
- The existing Crystal Realm gate remains level 35 plus ember_trial.
- The trial has scripted placeholder visuals and prompt-based attacks. Studio playtesting and mobile/performance acceptance remain outstanding.


## Crystal Realm foundation — Sprint 4.24
- Reach level 35 and complete the Heart of Fire trial to unlock Crystal Realm.
- Travel from Emberlands through the Crystal Portal or cross the Crystal Skyway. A return portal leads back to Emberlands.
- Explore the prismatic plateau and mine eight crystal veins. Each vein can be mined once per player every three minutes; each successful mine grants 2–4 Crystal Shards.
- Active Prism Fox and Crystal Fawn companions each add one shard. Aurora Dragon has a 35% chance to add two extra shards.
- Collect the Prismatic Radiance Egg. Hatch odds: Prism Fox 60%, Crystal Fawn 30%, Aurora Dragon 10%.
- Crystal Shards, mining cooldowns and egg/pet progress are saved through the existing profile system.
- Studio playtesting, balance, mobile and performance acceptance remain outstanding.


## Crystal Prism Trial — Sprint 4.25
- Enter Crystal Realm after reaching level 35 and completing the Heart of Fire trial.
- On the trial platform, follow the visible clue and activate the prisms in order: Azure → Rose → Crown. Activating a wrong prism resets only your own sequence; already aligned sequences survive reconnects.
- After aligning all three beams, attack the Prism Guardian. Each strike deals 20 damage. Watch for the 1.55-second warning and move outside the 24-stud radius to dodge its 22-damage pulse.
- Defeating the Guardian grants +500 XP once and completes `crystal_trial`.
- At level 50, the completed trial unlocks the Ancient Heights portal. The current build includes its first landing platform and a return portal; the full biome is not built yet.
- The Russian HUD tracks prism progress, guardian health, and the dodge warning.
- Static CI and Rojo place build pass. Roblox Studio gameplay, multiplayer, persistence, mobile, collision, and performance tests remain required.

## Ancient Heights exploration slice
- Reach level 50 and complete the Crystal Prism Trial to unlock Ancient Heights.
- Travel from the Crystal Realm portal to the Elder Canopy; use the return portal to leave.
- Collect the Ancient Egg from the three active world pickups and hatch it at your own plot.
- Hatch odds: Ancient Stag 55%, Root Sprite 30%, Sky Serpent 15%.
- New species use the existing genetic roll, collection discovery, follower and profile systems.
- This remains a scripted placeholder environment pending curated Creator Store asset review.


## Ancient Heights — Elderwood gathering
- Find one of the six glowing Ancient Roots along the Elder Canopy path.
- Hold E (or use the touch prompt) to collect 1–3 Elderwood.
- Each root has an independent three-minute cooldown for each player.
- Elderwood balance is shown in the Ancient Heights HUD and saved in the player profile.
- Gathering requires the Ancient Heights unlock; client-side UI cannot grant materials.


## Whispering Grove secret
- Beyond the Ancient Heights welcome sign, follow the four glowing stepping stones to a small hidden ledge.
- Activate the Elder Heart altar once to receive 250 coins, 150 XP, and 8 Elderwood.
- The discovery is permanent per player and cannot be farmed by repeating the prompt.


## Elderwood Workshop
- Find the workbench beside the Elder Canopy path in Ancient Heights.
- Craft one Ancient Egg for 10 Elderwood and 300 coins.
- The crafted egg enters the regular egg bag; return to your own nest's hatch station to hatch it.
- Its hatch odds are the same as a wild Ancient Egg: Ancient Stag 55%, Root Sprite 30%, Sky Serpent 15%.


## Ancient Tree Temple
- From the Elder Canopy, cross the stone causeway to the temple side-island.
- Read the clue and activate the three runes in order: Root → River → Dawn.
- A wrong rune resets your own sequence; other players' progress is unaffected.
- Once all three runes are lit, open the treasure chest for a one-time reward of 500 coins, 300 XP, and 20 Elderwood.


## Heartwood Guardian
- First solve Root → River → Dawn and claim the temple treasure.
- Attack the Guardian with E. Each successful hit deals 24 damage.
- Watch for two warnings: the heavy Vine Slam is short-range but deals 30 damage; the wide Root Wave reaches farther but deals 18 damage.
- Move out of the attack radius before the warning ends.
- Victory grants 600 XP and the legendary Heartwood Guardian companion, a boss-exclusive collection discovery.


## Guardian phase two and trophy
- At half health the Guardian enters phase two and unlocks Thorn Burst, a wide attack with a longer warning.
- Watch the core glow and particles to time your dodge.
- Victory also places the permanent “СЕРДЦЕ ДРЕВА” trophy in your personal nest.


## Guardian attack choreography
- Vine Slam: the Guardian raises both arms, then slams them down.
- Root Wave: the Guardian recoils and spreads its arms to release the wave.
- Thorn Burst: in phase two, the Guardian spreads its branches and flares its crown.
- On victory, the heart flashes gold and releases a burst of particles before returning to its calm glow.


## Whispering Grove hidden cache
Explore the stepping stones beyond the Elder Heart altar. Four rune pads conceal a second treasure. Read the sequence from the grove's clue: Moon → Leaf → Dew → Star. An incorrect touch resets your personal sequence. The hidden cache grants Moonpetals, coins and XP once per player.


## Forgotten Heart Cave
A stone bridge leads from Ancient Heights to a hidden cave. Inside, read the clue and awaken three crystals in order: Root → River → Dawn. A wrong activation resets your personal sequence. The treasure chamber awards Starshards, coins and XP once per player.


## Forgotten Cave egg
The Forgotten Heart treasure chest also contains one exclusive egg. Make room in your egg inventory before claiming it, then hatch it at your own nest. The visible odds are 65% Twilight Bat, 25% Crystal Prowler and 10% Heart Wisp.


## Forgotten Heart Guardian boss
After opening the cave chest, the guardian awakens in the arena at the back of the cave. Use the guardian's interaction prompt to attack (30 damage per hit). Its health is personal and saved. At half health it enters phase II and unlocks Shard Rain.
- **Crystal Slam:** leave the blue target circle before it detonates.
- **Echo Pulse:** run beyond the wide ring around the guardian.
- **Shard Rain:** leave all three marked circles.
Victory grants the Mythic **Страж забытого сердца**, 1,200 coins, 5 Starshards and 800 XP once per player.


## Guardian choreography and reward reveal
Watch the Guardian's arms to read each attack: both arms rise before Crystal Slam, spread for Echo Pulse, and lift high for Shard Rain. At phase II the heart turns violet and the arena crystals burst into shards. The crystals regrow after a short pause. Defeating the Guardian triggers a one-time mythic companion reveal.


## Combat feedback
A successful strike makes the Guardian recoil and flash with crystal sparks. A boss hit triggers a brief red screen flash and stronger camera shake; a successful dodge does not. These are local visual cues, while all combat outcomes remain server-authoritative.


## Combat readability
Each boss attack has its own warning color: cyan for Crystal Slam, violet for Echo Pulse and pink for Shard Rain. The health bar eases smoothly to the current value, and successful hits show floating damage numbers.
