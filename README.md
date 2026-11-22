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
