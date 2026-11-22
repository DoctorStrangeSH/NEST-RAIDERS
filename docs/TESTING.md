# Testing Checklist

## Studio setup
- [ ] Open the Rojo-synced place in Roblox Studio.
- [ ] Enable API Services only in a separate test experience when testing DataStores.
- [ ] Never test persistence against the live production experience.
- [ ] Use Start Server with at least two clients for multiplayer checks.

## Profile safety
- [ ] New profile receives expected defaults.
- [ ] Existing profile loads without resetting values.
- [ ] Simulated DataStore failure does not overwrite save with defaults.
- [ ] PlayerRemoving and server shutdown save safely.
- [ ] Rejoining restores progression and inventory.

## Progression
- [ ] New player starts with Starter Island only.
- [ ] Client cannot unlock a zone by changing local attributes.
- [ ] Insufficient level and missing quest both deny access.
- [ ] Completing requirements unlocks the expected zone.

## Gameplay
- [ ] Egg pickup validates distance, zone, cooldown, and capacity.
- [ ] Hatch rewards are rolled on server and consume exactly one egg.
- [ ] Each player receives a unique nest plot; two players never share ownership.
- [ ] A player can hatch only at their own plot; another player's hatch prompt is rejected.
- [ ] A player's saved PlotId is reused when available after reconnect.
- [ ] When all six plots are occupied, the next player receives a clear server-full message.
- [ ] Newly hatched companions appear and follow their owner.
- [ ] At most three companion models are rendered per player.
- [ ] Egg shop displays the current balance, egg capacity, price, and hatch odds.
- [ ] Buying a Meadow Egg deducts exactly 50 coins and adds exactly one egg.
- [ ] Purchase is rejected with insufficient coins, full egg inventory, unknown egg ID, or unmet level requirement.
- [ ] Client cannot set a custom price or grant itself eggs through the shop remote.
- [ ] Shop odds match the server-side hatch weights (55% / 30% / 15%).
- [ ] Collection book lists every catalog species and hides undiscovered species names.
- [ ] Discovery progress counts unique species, not total pet duplicates.
- [ ] Collection book duplicate counts match the owned companion inventory.
- [ ] Collection book is read-only; client cannot grant discoveries or edit odds.
- [ ] Shop hatch odds and server hatch weights both come from the shared catalog.
- [ ] Companion inventory lists every owned pet with rarity, level, and income.
- [ ] Nest upgrade panel displays current level, next cost, and unlocked display pedestals.
- [ ] Nest upgrade deducts exactly 250 / 750 / 2000 / 5000 coins for levels 2–5.
- [ ] Nest upgrade rejects insufficient funds, unassigned plots, and upgrades above level 5.
- [ ] Nest upgrade visuals update without duplicating old decorations.
- [ ] Nest level and display pedestal count restore after reconnect.
- [ ] Player cannot upgrade another player's nest through the remote.
- [ ] Player can equip and unequip owned companions; non-owned IDs are rejected.
- [ ] Equipping a fourth companion is rejected; unequipping frees a slot.
- [ ] Only equipped companions follow the player and generate passive income.
- [ ] Legacy companion saves without instance IDs are migrated without losing pets.
- [ ] Fusion is available only when the player owns three pets of the same species and star rank.
- [ ] Fusion consumes exactly two duplicates and upgrades the selected pet by one star.
- [ ] Fusion rejects a non-owned pet, fewer than three matching pets, and pets already at three stars.
- [ ] Active slots are preserved correctly when an equipped duplicate is consumed by fusion.
- [ ] Fused pet income is recalculated from the catalog base income and the new star multiplier.
- [ ] Star rank is saved and restored after reconnect.
- [ ] Two-star and three-star pets show the correct evolution aura and star visuals.
- [ ] Companion models disappear when their owner leaves.
- [ ] Companion income is server-authoritative and capped.
- [ ] Raid validates range, consent/state, cooldown, and bounded loss.
- [ ] Desktop and mobile controls work.
