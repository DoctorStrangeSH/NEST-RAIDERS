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
- [ ] Place a non-equipped owned pet on each unlocked display pedestal; its model appears on the correct pedestal.
- [ ] Reject placing a non-owned pet, an active pet, a duplicate display assignment, or a locked slot.
- [ ] Remove a displayed pet; it returns to the available list and its model disappears.
- [ ] Displayed pets are excluded from active-team equip and fusion until removed.
- [ ] Displayed-pet income accumulates separately every 10 seconds and does not enter the wallet automatically.
- [ ] Collect displayed income; wallet increases by the exact amount and stored income resets.
- [ ] Wallet-cap overflow remains stored instead of being discarded.
- [ ] Display assignments and stored income persist after reconnect.
- [ ] Displayed pets idle with a gentle bob and turn without drifting away from their pedestal.
- [ ] Each displayed pet shows its saved mood above the model.
- [ ] Petting increases mood by 15, capped at 100; playing increases mood by 25, capped at 100.
- [ ] Mood interactions reject non-displayed pets, unknown interaction names, and requests during the per-pet cooldown.
- [ ] Mood values persist after reconnect and the mood bubble refreshes after interaction.
- [ ] Mood interactions do not grant coins or modify companion rarity, level, or income.
- [ ] Hunger, energy, and mood decay at their documented rates while time passes, including elapsed offline time.
- [ ] Feed costs exactly 10 coins, restores 35 hunger (capped at 100), and grants 5 mood; insufficient funds are rejected.
- [ ] Feeding is rejected when hunger is already at least 95 and never creates negative currency.
- [ ] Sleep starts a 60-second rest; energy recovers while resting and does not exceed 100.
- [ ] A second sleep request while already resting is rejected; a pet at 95+ energy cannot start resting.
- [ ] Playing consumes 10 energy and is rejected when energy is below 10.
- [ ] Pet needs persist across reconnect; a completed rest period does not continue regenerating energy after its end.
- [ ] Opening the nest care panel refreshes the pet model bubble and displayed need values.
- [ ] Meadow Fox displays the Curious personality and Sweet Berries as its favorite food.
- [ ] Moss Turtle displays the Calm personality and Young Leaves as its favorite food.
- [ ] Sprout Dragon displays the Playful personality and Glowfruit as its favorite food.
- [ ] Petting grants the catalog-defined personality bonus; playing grants its own catalog-defined bonus.
- [ ] A favorite treat costs exactly 15 coins, restores 35 hunger, and grants 15 mood.
- [ ] Treating a pet displays its actual favorite food from the shared catalog; the client cannot choose or spoof another species food.
- [ ] Treating is rejected for insufficient coins, near-full hunger, non-displayed pets, or requests during the interaction cooldown.
- [ ] Personality bonuses never exceed 100 mood and never modify rarity, stars, or passive income.
- [ ] Nest toy catalog exposes Meadow Ball (25), Cozy Plush (40), and Wind Spinner (35) with matching display labels.
- [ ] Buying a toy deducts exactly its catalog price and equips it only to the selected displayed companion.
- [ ] Insufficient coins, invalid toy IDs, non-displayed pets, and interaction cooldown requests are rejected server-side.
- [ ] Equipping a replacement toy charges the new toy price and updates the displayed prop / nest panel.
- [ ] ToyPlay is rejected when the pet has no toy equipped or lacks the energy required by that toy.
- [ ] ToyPlay grants the catalog mood bonus plus 10 mood for the species favorite toy, capped at 100.
- [ ] ToyPlay consumes the exact energy cost from the toy catalog; Wind Spinner costs no energy.
- [ ] Equipped toy choice persists after reconnect and is restored on the pet model.
- [ ] Toy purchases and play do not modify rarity, stars, passive income, or other players’ profiles.
- [ ] Nest decoration shop is available only after profile load and while near the player-owned plot.
- [ ] Catalog exposes Flower Pot (30), Warm Lantern (55), Meadow Crystal (75), and Mushroom Seat (90).
- [ ] Buying a decoration deducts exactly its catalog price and increments only the buyer inventory.
- [ ] Unknown decoration IDs, insufficient coins, and inventory count above 20 are rejected.
- [ ] A player can place only an owned decoration into an unlocked, empty slot on their own plot.
- [ ] A player cannot place into another player’s plot, an occupied slot, or a slot above the nest-level limit.
- [ ] Removing a placed decoration returns exactly one item to inventory and clears the model.
- [ ] Move placed decorations with directional controls; positions snap to a 2-stud grid.
- [ ] Rotate placed decorations in 15-degree steps and verify the model orientation updates.
- [ ] Use the placement preview to move a decoration to several island locations; the preview should snap to the 2-stud grid.
- [ ] Confirm a placement with mouse click and touch tap; only the owner's PlotGrass surface should be accepted.
- [ ] Rotate with R on desktop and the rotate button on touch; verify the final saved rotation.
- [ ] Cancel with Escape and the mobile cancel button; the decoration must remain at its previous position.
- [ ] Verify movement and rotation persist after reconnect.
- [ ] Reject coordinates outside the nest bounds, malformed / non-finite transforms, and attempts to move locked or empty slots.
- [ ] Nest level 1 exposes two decoration slots; each upgrade unlocks one more, up to six at level 5.
- [ ] Inventory and placed decorations persist after reconnect and restore on the assigned plot.
- [ ] Releasing a plot removes the previous owner’s rendered decorations and displayed pets before reassignment.
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


## Island building system
- [ ] Open the island building panel after profile load and verify the five catalog entries and prices.
- [ ] Buy Stone Path (12), Clover Bush (28), Apple Tree (85), Wooden Fence (22), and Cozy Cottage (260); verify exact coin deductions and inventory counts.
- [ ] Place each owned object; verify the expected low-poly model appears only on the player's own island.
- [ ] Attempt placement on an occupied footprint and confirm the server rejects it.
- [ ] Move and rotate placed objects; verify 2-stud grid snapping, 15-degree rotation, and plot bounds.
- [ ] Remove an object and verify it returns to inventory without losing ownership.
- [ ] Verify the 100-object cap and per-type inventory cap.
- [ ] Rejoin and verify the inventory and complete island layout persist.
- [ ] Leave the server and verify the released plot has no previous owner's rendered buildings.


## Building placement preview — Sprint 4.5
- [ ] Buy a building, select Place, and verify the editor hides while the island remains visible.
- [ ] Move the pointer across the island and verify the translucent footprint follows and snaps to the 2-stud grid.
- [ ] Verify valid empty areas show green and occupied / out-of-bounds areas show red.
- [ ] Confirm with desktop click and mobile tap; verify the correct building appears at the preview location.
- [ ] Rotate with R and the on-screen rotate control; verify the saved orientation.
- [ ] Cancel with Escape and the on-screen cancel control; verify no inventory or placement data changes.
- [ ] Select an existing building's Move / Drag control and reposition it; verify it does not collide with itself or other objects.
- [ ] Attempt to place a large cottage partly outside the plot and verify server rejection.
- [ ] Verify the editor returns to the construction catalog after confirmation and cancellation.


## Fantasy garden landmarks — Sprint 4.6
- [ ] Verify Flower Arch appears with two posts, top beam, flower details, and fits within its 4-stud footprint.
- [ ] Verify Crystal Pond renders a horizontal water surface, inner glow, shoreline stones, lily pad, and flower.
- [ ] Verify Moon Fountain renders horizontal basins, central pedestal, crystal, and a soft PointLight.
- [ ] Buy each new object and confirm exact prices: Flower Arch 145, Crystal Pond 190, Moon Fountain 320.
- [ ] Place, move, rotate, remove, and rejoin with each new object; verify inventory and layout persistence.
- [ ] Confirm each landmark respects overlap checks and full-footprint island bounds.
- [ ] Test a plot release and verify all three new landmark models are cleared before reassignment.


## Social island visits — Sprint 4.7
- [ ] Run a two-player Studio server and open the island browser from both clients.
- [ ] Verify each player sees the other occupied island with the correct display name and level; own island is not listed.
- [ ] Visit another player's island and verify the visitor appears at the destination without changing ownership.
- [ ] Verify visitors can inspect decorations, buildings, and displayed companions but cannot buy, move, or remove the owner's objects.
- [ ] Use Return Home and verify the player returns to their exact pre-visit position.
- [ ] Visit a second island while already visiting; verify the original return position is preserved.
- [ ] Verify an island refuses a ninth visitor and shows a clear message.
- [ ] Have an island owner leave while visitors are present; verify guests are returned safely.
- [ ] Have a visitor leave while visiting; verify visitor count decreases.
- [ ] Attempt malformed plot IDs, self-visits, unavailable plot IDs, and rapid repeated requests; verify server rejection.
- [ ] Verify visits do not modify player profile data or grant currency / rewards.


## Island likes and favorites — Sprint 4.8
- [ ] Use two Studio clients; open the island browser and verify each island shows its current like count.
- [ ] Like another player's island; verify the owner sees the count increase and the viewer sees the active like state.
- [ ] Toggle the same like off; verify count decreases and repeated requests cannot create duplicate likes.
- [ ] Attempt to like your own island and an offline / invalid UserId; verify rejection.
- [ ] Add an island to favorites; close and reopen the panel and verify the saved state remains.
- [ ] Rejoin using a published private test experience and verify favorite IDs and received likes persist across sessions.
- [ ] Remove an island from favorites and verify it disappears from the favorites-only filter.
- [ ] Save 30 favorites and verify the 31st is rejected with a clear message.
- [ ] Verify the browser sorts by likes descending, then visitors, then owner name.
- [ ] Verify opening / refreshing the list is not blocked by the action cooldown; rapid like / favorite toggles are throttled.
- [ ] Verify likes do not grant coins, XP, pets, or combat power.
- [ ] Verify profile reconciliation adds social fields to existing saves without wiping existing nest data.


## Weekly island contests — Sprint 4.9
- [ ] In Studio local fallback, run a two-player server and verify all three categories appear: Cozy, Nature, Fantasy.
- [ ] Verify each category shows its own standings and the currently occupied islands on this server as nominees.
- [ ] Vote for another player in Cozy; verify the vote is accepted and the category locks for that voter.
- [ ] Attempt a second Cozy vote for a different island; verify the server rejects it.
- [ ] Verify the same player can still vote once in Nature and once in Fantasy.
- [ ] Attempt to vote for yourself, an offline player, an invalid UserId, and an unknown category; verify rejection.
- [ ] Verify a player leaving after the list loads causes a clear rejection rather than a phantom vote.
- [ ] In a published private test experience with API access enabled, vote from two different servers and verify both votes appear in the same category leaderboard.
- [ ] Verify the leaderboard sorts by vote count descending and shows display names for offline winners.
- [ ] Verify weekly datastore names change at the UTC week boundary and a new week's vote allowance starts.
- [ ] Simulate vote DataStore failure; verify no vote is claimed as saved when the vote record cannot be written.
- [ ] Simulate score projection failure after vote-record save; verify the vote remains locked and the next List request retries the idempotent score projection.
- [ ] Verify leaderboard reads are cached and List requests are throttled to protect DataStore budgets.
- [ ] Verify contest votes grant no coins, XP, pets, items, or PvP power.
- [ ] Verify the Studio fallback clearly indicates that results are local and ephemeral.


## Hall of Fame and island trophies — Sprint 4.10
- [ ] In Studio, use a test harness / temporary prior-week scores and verify the Hall of Fame shows the previous week's top three in all categories.
- [ ] Verify finalization is idempotent: opening the contest repeatedly does not duplicate a weekly archive.
- [ ] In a published private test experience, verify the first contest list request after the UTC week changes archives the previous week's top three from OrderedDataStore.
- [ ] Verify the Hall of Fame history is shared between separate servers and retains at most the latest 12 completed weeks.
- [ ] Verify a player outside the top three cannot claim a trophy by changing the client payload.
- [ ] Verify first-, second-, and third-place winners can each claim only their own category/week award.
- [ ] Verify a claimed award persists after leaving and rejoining, and duplicate claim requests are rejected.
- [ ] Verify a successful claim creates a visible trophy on the winner's own island and that it is restored on next join.
- [ ] Verify visitors can see trophies but cannot move, remove, or claim another player's trophies.
- [ ] Verify plot release removes trophy instances before the plot is assigned to another player.
- [ ] Verify no trophy grants coins, XP, pets, income, or PvP power.
- [ ] Verify history read / archive write failures show a safe error and do not create unverified claims.


## Global island discovery and cross-server visits — Sprint 4.11
- [ ] In a published private test experience, start two public server instances and join with at least one island owner in each.
- [ ] Verify active island owners publish to the shared MemoryStore directory and appear in both servers' global island browsers.
- [ ] Verify the same owner is listed only once when both local and directory data contain the same UserId.
- [ ] Verify directory entries include owner display name, level, plot ID, server ID, place ID, visitor count, capacity, and likes.
- [ ] Select an island in another server and verify the visitor is teleported to the exact listed server.
- [ ] Verify destination arrival waits for profile, plot, and character readiness before attempting the visit.
- [ ] Verify the destination server checks the target UserId still owns the supplied plot before moving the visitor.
- [ ] Verify a departed / stale target fails safely and leaves the visitor at their own nest.
- [ ] Verify full islands, self-visits, malformed user IDs, malformed server IDs, and mismatched directory records are rejected.
- [ ] Verify visitor counts update on the destination server and the return-home flow still works after cross-server travel.
- [ ] Verify owner departure returns all visitors and the directory entry is removed or expires.
- [ ] Verify MemoryStore read / write failures fall back to the current-server list with a clear status message.
- [ ] Verify Studio mode explicitly indicates that global browsing is unavailable and retains local island browsing.
- [ ] Verify likes, favorites, profile data, and currency are unchanged by cross-server travel.


## Player identity, public profiles, achievements, and titles — Sprint 4.12
- [ ] In a two-player Studio server, open the other local player's island profile and verify display name, username, level, nest level, companion count, unique species, collection percent, received likes, and trophy count.
- [ ] Verify the profile never exposes coins, inventory instance IDs, session tokens, private save fields, or other players' like voter IDs.
- [ ] Verify achievement unlock states are derived from server profile data: first companion, 10 companions, five unique species, nest level 3, one contest trophy, 10 received likes, and level 10.
- [ ] Verify achievements cannot be unlocked by sending modified client payloads; the profile remote accepts only Get and EquipTitle actions.
- [ ] Verify only unlocked titles can be equipped and an arbitrary / unknown title ID is rejected.
- [ ] Verify equipped title persists after leaving and rejoining in a published private test experience.
- [ ] Verify the title appears above the owner's character and refreshes after respawn or title change.
- [ ] Verify title can be removed and no title is shown above the avatar when unequipped.
- [ ] Verify a profile request for an offline player or player on another server fails safely with a clear message.
- [ ] Verify profile request cooldown and repeated title selection do not break the panel.
- [ ] Verify the own-profile button, local island profile button, close button, and mobile scrolling layout.
- [ ] Verify public profile data refreshes after earning a companion, leveling, receiving likes, or claiming a trophy.


## Companion growth, training, and genetics — Sprint 4.13
- [ ] Hatch companions repeatedly and verify the genetic trait is rolled server-side independently of species rarity.
- [ ] Verify disclosed genetic weights: Natural 72%, Verdant 18%, Luminous 8%, Prismatic 2%.
- [ ] Verify existing saves without GeneticTrait safely receive the Natural trait when normalized.
- [ ] Verify inventory shows each companion's level, growth XP, next-level requirement, growth stage, genetic trait, star rank, and income.
- [ ] Verify training costs are calculated server-side as 30 + (current level × 25), and each training grants 75 growth XP.
- [ ] Verify insufficient coins, unknown InstanceId, malformed payloads, and level-10 training are rejected without changing profile data.
- [ ] Verify XP carries over between levels and stage boundaries are correct: Hatchling levels 1–3, Young 4–6, Adult 7–10.
- [ ] Verify stage scale and genetic visual effects appear on active followers and displayed nest pets after training.
- [ ] Verify passive income recalculates from species base income, star rank, level, and capped genetic bonus.
- [ ] Verify fusion preserves the selected target's level, XP, and genetic trait while increasing its star rank; consumed companions are removed once.
- [ ] Verify training does not duplicate income, companions, or active slots under rapid repeated requests.
- [ ] Verify desktop and mobile inventory cards fit, scroll, and keep Train / Merge / Equip actions reachable.
- [ ] Verify old profiles migrate without data loss and their companion income is recalculated safely.


## Species-specific companion abilities — Sprint 4.14
- [ ] Verify each species exposes only its catalog-defined ability: MeadowFox / TrailFinder, MossTurtle / RootBlessing, SproutDragon / VerdantSpark.
- [ ] Verify ability controls remain locked below level 7 and are unavailable to non-equipped companions.
- [ ] Verify the adult ability becomes usable at level 7 and displays its current ready / cooldown state.
- [ ] Verify TrailFinder grants the configured coin reward through the server economy service and respects the global currency cap.
- [ ] Verify RootBlessing adds the configured amount to Nest.StoredCoins without exceeding the nest storage cap; collected nest coins remain collectible.
- [ ] Verify VerdantSpark grants the configured player XP through ProgressionService and updates level / zone unlock attributes.
- [ ] Verify each ability sets a per-companion 300-second cooldown and a repeated request cannot duplicate its reward.
- [ ] Verify cooldown persists after respawn and profile reload in a published private test experience.
- [ ] Verify unknown ability IDs, altered client payloads, unowned pets, inactive pets, locked pets, and cooldown bypass attempts are rejected.
- [ ] Verify the inventory UI fits on mobile and desktop, and locked / ready / cooldown labels remain readable.
- [ ] Verify abilities do not grant rewards when the player profile is not loaded.


## Adult breeding and genetic inheritance — Sprint 4.15
- [ ] Verify breeding requires two different owned species and both parents are level 7 or higher.
- [ ] Verify equipped parents and pets displayed in the nest cannot be selected; no parent is consumed by successful breeding.
- [ ] Verify breeding cost is 250 + (parent A stars + parent B stars) × 100 coins and insufficient funds leave both parents unchanged.
- [ ] Verify each parent receives its own 1,800-second cooldown and cooldown survives profile reload.
- [ ] Verify inherited genetics: 90% chance to inherit one parent's trait (50/50 parent selection), 7% Luminous mutation, 3% Prismatic mutation.
- [ ] Verify offspring species is selected from one of the two parent species and offspring starts at level 1, one star, and 0 GrowthXP.
- [ ] Verify offspring origin and both parent species are stored and displayed in collection lineage.
- [ ] Verify collection capacity of 100 companions blocks breeding without charging coins or setting cooldowns.
- [ ] Verify client cannot breed with unowned IDs, the same parent twice, wrong species, under-level parents, cooldown bypass, or altered cost/trait/species values.
- [ ] Verify rapid repeated requests cannot create duplicate offspring or charge twice; request throttling and cooldowns are effective.
- [ ] Verify all profile state persists after leave/rejoin in a published private test experience.
- [ ] Verify two-step parent selection and explicit confirmation work on desktop and mobile; cancellation / selecting the first parent again resets selection.
- [ ] Verify the new offspring appears once in collection, can be equipped/trained, and retains its inherited trait after save/reload.


## Lineage egg incubation — Sprint 4.16
- [ ] Verify successful breeding creates one persistent LineageEgg in EggInventory, not an immediate companion.
- [ ] Verify the egg stores server-selected offspring species, inherited/mutated genetic trait, and both parent species IDs.
- [ ] Verify the egg cannot hatch before IncubatesUntil and the player receives a remaining minutes/seconds notice.
- [ ] Verify the egg becomes hatchable at or after its five-minute incubation deadline.
- [ ] Verify hatching a lineage egg creates exactly one companion with the stored species, genetics, and lineage; it must not reroll any of these values.
- [ ] Verify normal world/shop eggs retain their existing random species and genetic trait behavior.
- [ ] Verify an invalid lineage egg with unknown species or missing genetic data is not consumed.
- [ ] Verify egg inventory capacity and collection capacity are checked before breeding costs or parent cooldowns are applied.
- [ ] Verify the incubator summary shows lineage egg count, countdown, offspring species preview, and genetic trait.
- [ ] Verify egg and parent cooldown state persists after leave/rejoin in a published private test experience.
- [ ] Verify rapid hatch requests cannot consume one egg twice or duplicate a companion.
- [ ] Verify the hatch station still validates plot ownership and player proximity for lineage eggs.
- [ ] Verify desktop and mobile collection layout remains readable with the incubator summary.


## Starter hybrid species — Sprint 4.17
- [ ] Verify MeadowFox + SproutDragon always produces EmberFox, regardless of parent selection order.
- [ ] Verify MossTurtle + SproutDragon always produces Fernshell, regardless of parent selection order.
- [ ] Verify MeadowFox + MossTurtle always produces BriarGuardian, regardless of parent selection order.
- [ ] Verify each hybrid egg stores the hybrid species ID and the original parent species IDs before incubation.
- [ ] Verify ready hybrid eggs hatch into the stored hybrid species and preserve the inherited/mutated genetic trait.
- [ ] Verify all hybrid definitions have Weight = 0 and are excluded from the natural egg hatch pool.
- [ ] Verify hybrid species appear in the collection book with HybridOnly=true and are labelled "Только через разведение" until discovered.
- [ ] Verify discovered hybrids show rarity, owned count, and passive income.
- [ ] Verify EmberFox's CinderDash unlocks at level 7, requires an equipped pet, grants the server-calculated coin reward, and obeys the five-minute cooldown.
- [ ] Verify Fernshell and BriarGuardian render distinct follower silhouettes rather than falling back to the MeadowFox model.
- [ ] Verify unknown pair combinations never grant an unrelated hybrid and still follow the documented non-hybrid fallback.
- [ ] Verify existing saved profiles load with the expanded catalog and no loss of existing companions.
- [ ] Verify breeding, hatching, follower rendering, and collection UI on desktop and mobile in Roblox Studio.
