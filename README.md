# NEST RAIDERS

A bright, seamless Roblox island-adventure about discovering eggs, hatching companions, building a nest, and raiding rival nests.

> Project status: pre-alpha. The repository is built with Rojo and Luau. Roblox Studio is required to run and visually test the experience.

## Development

1. Install Roblox Studio.
2. Install [Rojo](https://rojo.space/) and the Roblox Studio Rojo plugin.
3. Run `rojo serve` from the repository root.
4. Connect the Rojo plugin in Studio and sync the `NEST RAIDERS` project.
5. Press Play to test.

See [`docs/PROJECT_SPEC.md`](docs/PROJECT_SPEC.md) for the product specification and [`ROADMAP.md`](ROADMAP.md) for milestones.

## Asset policy

Use Creator Store assets only after checking creator, permissions, dependencies, scripts, and license/usage terms. Prefer assets with clear reuse permissions. Never import unknown free models containing executable scripts into production. All core gameplay logic remains in this repository.


## Personal nest customization — latest addition
- Added a persistent decoration inventory and four cosmetic items: Flower Pot (30), Warm Lantern (55), Meadow Crystal (75), and Mushroom Seat (90).
- Buy decorations, place them into unlocked slots on the player's own nest, and remove them back into inventory.
- Nest level 1 exposes two decoration slots; upgrades unlock up to six.
- The server validates plot ownership, player proximity, currency, inventory, catalog IDs, slot limits, and occupancy.
- Current visuals are scripted placeholders; replace them with reviewed Creator Store assets after in-Studio art and license checks.

## Additional acceptance tests
- [ ] Buy each decoration and verify exact currency deduction and inventory count.
- [ ] Place only owned decorations in free unlocked slots on the player's own plot.
- [ ] Reject invalid IDs, insufficient coins, occupied slots, locked slots, and requests made too far from the plot.
- [ ] Remove a placed item and verify it returns to inventory.
- [ ] Verify decorations and inventory persist after reconnect.
- [ ] Verify a plot release clears the previous owner's rendered decorations.


## Nest decoration positioning — latest addition
- Decorations retain their unlocked plot slot, but can be repositioned within the nest on a 2-stud grid.
- Directional controls nudge the selected decoration; the rotate control turns it in 15-degree increments.
- Position and rotation are stored in the player profile and restored when the plot is assigned.
- The server rejects out-of-bounds, malformed, and non-finite transforms.


## Island decoration editor — latest addition
- Select an existing decoration and enter placement mode.
- A local translucent preview snaps to the owned island's grass surface on a 2-stud grid.
- Confirm with mouse click or touch tap; rotate with R on desktop or the on-screen rotate control on mobile.
- Cancel with Escape or the on-screen cancel control. The editor panel is hidden during placement so the island remains visible.
- The client only raycasts against the current player's own plot surface; the server still validates ownership, slot, proximity, and transform bounds.


## First island construction system
- Added a server-authoritative catalog for five buildable objects: Stone Path (12), Clover Bush (28), Apple Tree (85), Wooden Fence (22), and Cozy Cottage (260).
- Players purchase objects into a persistent build inventory, place them on a 2-stud island grid, move and rotate them, and remove them back into inventory.
- The server enforces coin costs, inventory ownership, plot proximity, grid bounds, object-footprint overlap, per-type limits, and a 100-object island cap.
- Built models are reconstructed from saved profile data when the plot is assigned and cleared when the plot is released.
- Current models are lightweight scripted prototypes; reviewed Creator Store assets and drag-preview placement remain future polish tasks.


## Building placement editor — latest addition
- Building placement now uses a translucent footprint preview rather than selecting an arbitrary free coordinate.
- The preview follows the cursor / touch point over the player's own island, snaps to the 2-stud grid, and uses green / red feedback for valid / blocked positions.
- Place new buildings or reposition existing ones, rotate in 15-degree increments, confirm with click / tap, or cancel without changing saved data.
- The server validates the complete footprint against island bounds and occupied building footprints.
- The construction catalog returns after placement or cancellation.


## Fantasy garden building additions — Sprint 4.6
The construction catalog now also includes:
- Flower Arch — 145 coins; a wooden arch decorated with flowers.
- Crystal Pond — 190 coins; a shallow luminous pond with a stone shoreline and lily detail.
- Moon Fountain — 320 coins; a layered fountain with a softly glowing crystal.
These landmarks share the existing server-authoritative purchase, inventory, placement, move, rotate, remove, and persistence systems.


## Social island visits — Sprint 4.7
NEST RAIDERS now includes an in-server island browser. Players can see other occupied islands, visit a player's nest, inspect their pets and builds, and return to their exact previous position. Each island allows up to eight guests; guests are returned home if the island owner leaves. Existing server ownership checks prevent visitors from editing another player's island. Global discovery, favorites, and likes are not included yet.


## Island popularity — Sprint 4.8
The social island browser now supports persistent likes and favorites. Likes are unique per visitor and stored on the island owner's profile; favorites are stored on the visitor's profile (up to 30 islands). The browser sorts current-server islands by received likes and supports a favorites-only filter. These features are cosmetic / social and do not grant gameplay power. Cross-server discovery and weekly showcases remain future work.


## Weekly island contests — Sprint 4.9
Players can vote once per category each week in three island showcases: Cozy, Nature, and Fantasy. The top-ten leaderboards use ordered DataStores and are shared across published servers. Players choose nominees from occupied islands in their current server. Local Studio testing uses temporary in-memory standings; published persistence requires DataStore access. Votes are social recognition only and do not grant gameplay power.


## Hall of Fame
The previous week's top-three island contest results are archived when the contest is first accessed in the new week. Winners can claim one cosmetic trophy per category/week; claims are server-verified and saved to their profile. Claimed trophies are displayed on the owner's island. Published history is shared across servers and retains the latest 12 completed weeks. Local Studio results remain temporary.


## Global island discovery
In published servers, active islands are advertised through a TTL-backed MemoryStore directory. Players can browse islands across public servers and teleport to the exact server hosting the selected owner. The destination verifies the owner and plot before moving the visitor. Studio intentionally uses local-only browsing; cross-server acceptance testing requires a published private test experience.


## Player identity
Players can open their own profile or inspect an island owner's public profile while both are in the same server. Profiles show progression, collection milestones, received island likes, contest trophies, and server-derived achievements. Unlocked cosmetic titles can be equipped and appear above the character. Cross-server and offline profile lookup remains planned work.


## Companion growth
Companions gain growth XP through paid training and progress through Hatchling, Young, and Adult stages. Every hatch also rolls an independent genetic variant (Natural, Verdant, Luminous, or Prismatic) with disclosed odds. Genetics add cosmetic effects and a small capped passive-income bonus. Training and all progression calculations are validated server-side.


## Adult companion abilities
At level 7, equipped companions unlock a unique active ability: MeadowFox finds coin stashes, MossTurtle stores a nest blessing, and SproutDragon grants player XP. Each ability has a persistent per-companion five-minute cooldown and is validated on the server.


## Adult breeding and genetics
Two different adult species can breed without being consumed. Offspring inherit one parent's species and usually one parent's genetic trait, with a small chance of Luminous or Prismatic mutation. Both parents receive a 30-minute cooldown, and lineage is recorded in the collection.


## Lineage egg incubator
Breeding creates a lineage egg that incubates for five minutes. Its species, genetic outcome, and parent lineage are fixed by the server at creation. Once ready, hatch it at your own nest station; the resulting companion preserves that stored inheritance.


## Breeding-only hybrid species
Three starter cross-species pairs now produce unique hybrids: EmberFox, Fernshell, and BriarGuardian. They have dedicated follower silhouettes, appear in the collection book as breeding-only discoveries, and cannot hatch from ordinary eggs.


## Genetic mutation appearances
Verdant, Luminous, and Prismatic companions have distinct physical ornaments in addition to their aura: leaf crystals, glowing lantern orbs, and multi-color facets. The collection UI displays each trait's rarity and passive-income bonus.


## Personal breeding altar
Each player's nest includes a dedicated glowing breeding altar. Breeding requests are server-validated and only accepted near the altar in the player's own plot.


## Breeding ritual
Successful breeding triggers a temporary altar animation: the two selected companion models converge through species-colored energy beams into a trait-colored lineage egg. Hybrid offspring receive a distinct golden reveal burst. The visual sequence does not alter server-authoritative breeding outcomes or incubation.

 
## Frost Highlands — Sprint 4.21
- Third explorable biome with snowfields, pine trees, glacier crystals, Frost Egg spawns, a return portal, and a walkable ice causeway to Emerald Wilds.
- Frost Portal is gated by level 12 and the completed Emerald Grove trial.
- Frost Egg hatch odds are disclosed in-world: Frost Fox 60%, Snow Owl 30%, Glacier Bear 10%.
- Three persistent runes complete the Heart of Winter trial for +180 XP and satisfy the Emberlands quest gate.
- Frost Fox, Snow Owl, and Glacier Bear each unlock a unique server-validated active ability at companion level 7.
- World egg pickup is restricted to the player's current unlocked biome.
- All visuals are scripted prototypes pending Roblox Studio art and gameplay acceptance.

 
### Emberlands — Sprint 4.22.1
- Volcanic island prototype with server-driven heat zones and a cooling sanctuary.
- Heat increases near magma, cools outside danger areas, and causes gradual server-side damage at critical temperature.
- Active Ember companions provide heat resistance and unique adult abilities.
- Ember Egg hatch odds: Cinder Fox 60%, Magma Whelp 30%, Ash Phoenix 10%.
- Access requires level 22 and completion of the Frost Highlands trial.
- Roblox Studio runtime and multiplayer acceptance are still required.


### Ancient Heights gathering
- Six glowing Elderwood root nodes with server-validated collection.
- 1–3 Elderwood per harvest, per-player three-minute node cooldowns, and profile persistence.
- A biome-specific HUD panel displays the saved Elderwood balance.
- Studio acceptance cases are tracked in [docs/TESTING.md](docs/TESTING.md).


### Whispering Grove secret
- A hidden stepping-stone route leads to a small shrine beyond the Elder Canopy.
- The Elder Heart altar grants a one-time, profile-saved reward of 250 coins, 150 XP, and 8 Elderwood.
- Server-side validation prevents repeat claims and out-of-zone reward requests.


### Elderwood Workshop
- Craft an Ancient Egg in the Ancient Heights workbench for 10 Elderwood and 300 coins.
- Crafted eggs use the existing Ancient Heights hatch pool and normal personal nest hatch flow.
- Server checks zone access, character distance, loaded profile, resources and egg capacity before charging.


### Ancient Tree Temple
- Cross the stone causeway in Ancient Heights to reach the temple.
- Solve the Root → River → Dawn rune sequence and open the treasure chest.
- Each player earns the 500-coin, 300-XP, 20-Elderwood reward once; puzzle progress is saved per player.


### Heartwood Guardian
- Complete the temple puzzle and treasure claim, then defeat the Guardian in a per-player boss encounter.
- Dodge alternating Vine Slam and Root Wave attacks.
- Victory grants 600 XP and the legendary boss-exclusive Heartwood Guardian companion.


### Guardian phase two and trophy
- At half health the Guardian unlocks Thorn Burst, a wide, telegraphed attack.
- Defeating the boss also awards the permanent “СЕРДЦЕ ДРЕВА” trophy, displayed in the player's personal nest.


### Guardian animations
The Heartwood Guardian now has distinct Vine Slam, Root Wave and Thorn Burst attack choreography, plus a gold particle reveal for the player who defeats it. The shared model animation is cosmetic; combat progress remains isolated per player.


### Whispering Grove secret
A second optional secret is hidden beyond the Elder Heart altar. Activate four runes in order (Moon → Leaf → Dew → Star) to unlock a personal cache with Moonpetals, coins and XP.
