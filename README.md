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
