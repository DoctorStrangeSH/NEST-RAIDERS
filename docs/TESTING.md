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
- [ ] Companion models disappear when their owner leaves.
- [ ] Companion income is server-authoritative and capped.
- [ ] Raid validates range, consent/state, cooldown, and bounded loss.
- [ ] Desktop and mobile controls work.
