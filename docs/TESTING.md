# Testing Checklist

## Studio setup
- [ ] Open the downloaded `NEST-RAIDERS.rbxlx` or Rojo-synced place in Roblox Studio.
- [ ] Press **Play** to start the server. The archipelago is built at runtime by `WorldBuilder`; an empty Workspace in Edit mode is expected.
- [ ] Wait for the boot sequence, then confirm `Workspace/NestRaidersWorld` appears in Explorer.
- [ ] In Explorer, inspect `ReplicatedStorage/NestRaidersRemotes`: `WorldHealth` should become `READY`; there should be no `WorldError` or `ServiceError_*` attributes.
- [ ] Open **View → Output** and capture any `[NEST RAIDERS]` errors if the world or HUD does not load.
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


## Genetic mutation appearance — Sprint 4.18
- [ ] Verify Natural companions receive no mutation ornaments or genetic aura.
- [ ] Verify Verdant companions render three green crystal leaves and a glowing heart gem, in addition to the green aura.
- [ ] Verify Luminous companions render three cyan lantern orbs with PointLight instances and the cyan aura.
- [ ] Verify Prismatic companions render three differently colored neon facets and a prismatic core, in addition to the prismatic aura.
- [ ] Verify mutation ornaments appear consistently on equipped followers and nest display companions.
- [ ] Verify growth scaling does not detach or leave mutation ornaments behind.
- [ ] Verify inventory cards display trait name, trait rarity, rounded passive income bonus percentage, growth XP, and income.
- [ ] Verify old saved companions with missing genetic data normalize to Natural without errors.
- [ ] Verify hybrid species can render every supported genetic mutation without losing their base species silhouette.
- [ ] Verify visual density and readability on desktop and mobile; ornaments must not block ProximityPrompts or interaction hitboxes.


## Personal nest breeding altar — Sprint 4.19
- [ ] Verify every personal plot builds a dedicated BreedingStation beside its hatch station.
- [ ] Verify the altar has a visible neon ring, soft purple PointLight, and a ProximityPrompt labelled "Разведение" / "Алтарь потомства".
- [ ] Verify the owning player receives guidance when activating their own altar.
- [ ] Verify a non-owner activating another player's altar receives an ownership notice.
- [ ] Verify breeding from anywhere outside the owner's 18-stud station radius is rejected before coins/cooldowns/egg inventory change.
- [ ] Verify breeding inside the owner's station radius still enforces adult level, different species, ownership, equipped/displayed restrictions, cooldown, currency, and capacity.
- [ ] Verify a player cannot use another player's altar to bypass personal plot ownership.
- [ ] Verify station placement does not overlap the hatch station, nest bowl, owner sign, or display pedestals.
- [ ] Verify the station and prompt are usable on desktop and mobile touch controls.
- [ ] Verify prompt activation and remote invocation spam do not duplicate lineage eggs or charge coins more than once.


## Breeding ritual reveal — Sprint 4.20
- [ ] Verify a successful Breed action creates exactly one lineage egg and triggers one ritual sequence.
- [ ] Verify two parent-energy echoes use distinct species colors and converge toward the altar core.
- [ ] Verify energy beams converge on the core and disappear when the egg reveal begins.
- [ ] Verify the lineage egg grows from a small spark to a visible egg above the altar.
- [ ] Verify Natural, Verdant, Luminous, and Prismatic traits use their corresponding reveal colors.
- [ ] Verify Luminous and Prismatic particles remain readable without overwhelming the scene.
- [ ] Verify hybrid offspring store IsHybrid=true and trigger four golden reveal shards with a stronger light/particle burst.
- [ ] Verify non-hybrid offspring store IsHybrid=false and do not display the golden hybrid burst.
- [ ] Verify effects clean themselves up within nine seconds and do not accumulate after repeated breeding.
- [ ] Verify the animation runs only after server validation and successful egg insertion; rejected requests do not spawn effects or charge currency.
- [ ] Verify the ritual does not block the inventory response or delay the five-minute incubation timer.
- [ ] Verify two players breeding simultaneously see effects only at their own personal altars.
- [ ] Verify the altar ritual is readable on mobile and does not obstruct nearby prompts.


## Actual parent models in breeding ritual — Sprint 4.20 follow-up
- [ ] Verify the ritual displays the exact two selected companion species, including hybrid silhouettes and genetic mutation ornaments.
- [ ] Verify parent models appear on opposite altar pads, facing the ritual core.
- [ ] Verify both models smoothly move toward the core while species-colored beams transfer energy.
- [ ] Verify the parent preview models are temporary copies and do not duplicate, mutate, equip, or remove the player's saved companions.
- [ ] Verify preview models and their lights are removed after the energy transfer and all temporary effects are cleaned up.
- [ ] Verify simultaneous rituals by different players do not mix parent previews or effects.

## Ancient Heights — Studio acceptance
- [ ] Confirm a player below level 50 cannot enter even after completing the prism trial.
- [ ] Confirm a level-50 player without crystal_trial cannot enter.
- [ ] Confirm an eligible player can travel from Crystal Realm and return safely.
- [ ] Confirm only three Ancient Egg pickups are active and each has a working collect prompt.
- [ ] Collect one Ancient Egg; verify it enters inventory, disappears, and respawns after the normal timer at a free spawn slot.
- [ ] Verify hatching uses the Ancient Egg table (55% / 30% / 15%) and grants the matching Ancient species.
- [ ] Verify the three follower silhouettes, genetic ornaments, collection discoveries, and profile updates.
- [ ] Test two players independently; one player's egg collection must not grant or remove another player's inventory item.
- [ ] Check landing, path, trees, rune pillars, egg stands, collision, and camera readability on desktop and mobile emulation.


## Ancient Heights Elderwood gathering — Studio acceptance
- [ ] Confirm all six glowing root nodes appear along the Elder Canopy path with working prompts.
- [ ] Confirm harvesting works only inside Ancient Heights for an eligible player.
- [ ] Confirm an ineligible player or a player outside interaction distance receives no reward.
- [ ] Confirm each harvest grants 1–3 Elderwood and updates the Ancient Heights HUD immediately.
- [ ] Confirm the same player cannot harvest the same node again during its three-minute cooldown.
- [ ] Confirm a different player can harvest that node independently.
- [ ] Rejoin and confirm Elderwood balance and node cooldowns persist.
- [ ] Confirm the panel is hidden outside Ancient Heights and readable on mobile emulation.


## Whispering Grove secret discovery — Studio acceptance
- [ ] Follow the four stepping stones from the Ancient Canopy to the hidden ledge; verify the route is traversable without unintended gaps.
- [ ] Verify the altar prompt appears only within interaction distance.
- [ ] Activate the altar as an eligible player; verify exactly +250 coins, +150 XP, and +8 Elderwood.
- [ ] Rejoin and activate again; verify the reward cannot be claimed twice.
- [ ] Verify a player outside Ancient Heights, outside prompt range, or without the level/trial unlock receives no reward.
- [ ] Test two players claiming independently; one player's claim must not consume the other's reward.
- [ ] Verify platform, stepping stones, pillars, altar, and sign collision/camera readability on desktop and mobile.


## Elderwood workshop — Studio acceptance
- [ ] Travel to Ancient Heights and locate the Elderwood Workshop beside the Elder Canopy path.
- [ ] Confirm the recipe sign clearly shows 10 Elderwood + 300 coins.
- [ ] Craft with sufficient materials; verify exactly 10 Elderwood and 300 coins are deducted and EggCount increases by one.
- [ ] Confirm the crafted egg appears in the normal inventory and can be hatched at the player's own nest.
- [ ] Confirm the hatch uses the Ancient Egg catalog and 55/30/15 species weights.
- [ ] With fewer than 10 Elderwood or fewer than 300 coins, verify crafting is rejected and no balance changes.
- [ ] With 20 eggs in the bag, verify crafting is rejected and no resources are consumed.
- [ ] Verify players outside Ancient Heights, without the zone unlock, dead, or outside prompt range cannot craft.
- [ ] Rejoin and verify the crafted egg and remaining resources persist in a private published test.
- [ ] In a two-player session, verify each player's resources and crafted eggs remain independent.


## Ancient Tree Temple — Studio acceptance
- [ ] Travel from the Elder Canopy across the stone causeway; verify the bridge and temple floor are walkable and have no gaps.
- [ ] Confirm the temple roof, pillars, signs, runes, and chest do not block the player's route or prompts.
- [ ] Follow the clue and activate Root → River → Dawn; verify the HUD advances 0/3 to 3/3.
- [ ] Activate River first or use another wrong rune; verify only that player's progress resets.
- [ ] Open the chest after solving; verify exactly +500 coins, +300 XP, and +20 Elderwood.
- [ ] Try to open the chest before solving and after claiming; verify no early or duplicate reward.
- [ ] In a two-player session, verify one player's rune progress and chest claim do not complete or reward the other player.
- [ ] Rejoin a private published test and verify rune progress and the one-time chest reward persist.
- [ ] Verify HUD at 375px, 768px, and desktop widths; ensure the temple objective panel does not overlap the Elderwood balance.


## Heartwood Guardian boss — Studio acceptance
- [ ] Complete the temple rune puzzle and claim the treasure chest before attempting the boss.
- [ ] Confirm the boss rejects interaction before the player's own temple puzzle and chest claim.
- [ ] Confirm each hit removes 24 boss HP and the health bar starts at 240.
- [ ] Verify Vine Slam warning lasts 1.8 seconds, deals 30 damage within 15 studs, and can be dodged by moving farther away.
- [ ] Verify Root Wave warning lasts 1.25 seconds, deals 18 damage within 26 studs, and can be dodged by leaving the radius.
- [ ] Verify attacks alternate and the player can continue attacking after each cooldown.
- [ ] In a two-player session, verify each player's boss HP, windup, victory and rewards are independent.
- [ ] Rejoin a private published test and verify boss HP and victory state persist.
- [ ] Defeat the boss and confirm exactly one Heartwood Guardian is added, 600 XP is granted, and no duplicate reward is possible.
- [ ] Confirm the new companion appears in the collection book as boss-exclusive and follows the player if an active slot is available.
- [ ] Verify boss HUD warnings and health bar at 375px, 768px and desktop widths.


## Heartwood Guardian phase two & trophy — Studio acceptance
- [ ] Deal damage until the Guardian reaches exactly 120 HP; verify phase two and its HUD appear immediately.
- [ ] Verify Thorn Burst only appears in phase two, warns for 2 seconds, deals 22 damage within 32 studs, and can be dodged.
- [ ] Confirm Vine Slam and Root Wave remain available in phase two.
- [ ] Verify the core pulse, phase color, light burst and particles play on warning and reset afterward.
- [ ] In a two-player session, put one player in phase two and keep the other in phase one; verify their HUD and local boss visuals do not cross-contaminate.
- [ ] Defeat the boss and verify the “СЕРДЦЕ ДРЕВА” trophy appears in the player's nest.
- [ ] Rejoin and verify the trophy remains displayed and no duplicate trophy is created.


## Heartwood Guardian animation & victory — Studio acceptance
- [ ] Trigger Vine Slam and confirm both arms rise, strike down, and return to the exact idle pose.
- [ ] Trigger Root Wave and confirm the body recoils, head lifts, arms spread, then all parts return.
- [ ] Trigger Thorn Burst in phase two and confirm arms, branches and crown flare before resetting.
- [ ] Trigger attacks quickly from two players and confirm no limb remains stuck or drifts from its original position.
- [ ] Confirm the local core pulse remains independent from shared body animation and each player's HUD / phase stays private.
- [ ] Defeat the Guardian and confirm only the winning player sees the gold victory reveal, then receives the unique follower and nest trophy.
- [ ] Rejoin and verify the follower, trophy and completed state persist without replaying the victory effect on spawn.


## Whispering Grove hidden cache — Studio acceptance
- [ ] Find the four rune pads on the hidden platform and activate Moon → Leaf → Dew → Star.
- [ ] Activate a wrong rune midway; confirm only your own progress resets to 0/4.
- [ ] Rejoin after two correct runes; confirm the HUD restores 2/4 and the next expected rune remains Dew.
- [ ] Try the cache before solving the puzzle; confirm it remains locked and grants no rewards.
- [ ] Complete the puzzle and open the cache; confirm exactly +5 Moonpetals, +400 coins and +200 XP.
- [ ] Reopen the cache and confirm no duplicate rewards are granted.
- [ ] In a two-player session, progress one player's rune sequence and verify the other player's HUD and saved sequence remain unchanged.
- [ ] Rejoin and confirm the cache remains claimed and Moonpetal balance persists.


## Forgotten Heart Cave — Studio acceptance
- [ ] Reach the cave from Ancient Heights and cross the bridge without falling or snagging on the rails.
- [ ] Enter the cave; confirm the floor, walls and ceiling allow comfortable player movement and camera clearance.
- [ ] Read the entrance clue and activate Root → River → Dawn.
- [ ] Activate a wrong crystal midway; confirm only your personal progress resets to 0/3.
- [ ] Rejoin after one or two correct crystals; confirm the HUD restores the saved sequence.
- [ ] Try the chest before completing the puzzle; confirm it remains locked and grants no rewards.
- [ ] Complete the puzzle and open the chest; confirm exactly +3 Starshards, +600 coins and +300 XP.
- [ ] Reopen the chest and confirm no duplicate reward is granted.
- [ ] In a two-player session, progress one player's cave sequence and verify the other player's progress and reward state remain independent.
- [ ] Rejoin after claiming the chest and verify completion and Starshard balance persist.


## Forgotten Cave egg & companions — Studio acceptance
- [ ] Complete the cave puzzle and claim the chest with an available egg inventory slot.
- [ ] Confirm exactly one Forgotten Cave Egg is added and the existing cave rewards are still granted.
- [ ] Fill the egg inventory and verify the chest does not mark itself claimed or consume rewards until space is available.
- [ ] Hatch the egg at the player's own nest station.
- [ ] Verify hatch outcomes match the displayed 65% / 25% / 10% table over a large sample.
- [ ] Confirm Cave Glimmerbat has bat wings/ears, Crystal Prowler has crystal crest/tail, and Heart Wisp has its halo/core glow.
- [ ] Confirm all three appear in the Collection Book with the correct rarity, cave source, odds and discovery state.
- [ ] Rejoin after claiming/hatching and verify the egg, pet and collection discovery persist.


## Forgotten Heart Guardian boss — Studio acceptance
- [ ] Claim the Forgotten Cave chest and verify the boss HUD unlocks without requiring a rejoin.
- [ ] Approach the guardian and confirm the prompt is available only within interaction range.
- [ ] Strike the boss and verify health decreases by exactly 30, with no rapid prompt double-hits.
- [ ] Verify phase II begins at or below 180 HP and Shard Rain becomes available.
- [ ] Dodge Crystal Slam by leaving its target circle before the warning ends.
- [ ] Dodge Echo Pulse by moving outside the wide ring.
- [ ] Dodge Shard Rain by leaving all three marked zones.
- [ ] In a two-player Studio session, confirm one player's boss health, attack markers, completion and rewards do not affect the other player.
- [ ] Defeat the boss and verify one Mythic Forgotten Heart Guardian companion, 1,200 coins, 5 Starshards and 800 XP are granted.
- [ ] Confirm the reward companion has the crystal golem follower model and appears in the Collection Book with the cave source.
- [ ] Rejoin and confirm boss completion, companion ownership and reward balances persist; no duplicate reward is granted.


## Forgotten Heart Guardian choreography — Studio acceptance
- [ ] Trigger Crystal Slam and confirm both arms rise and slam in sync with the warning.
- [ ] Trigger Echo Pulse and confirm the arms spread while the wide warning ring is visible.
- [ ] Trigger Shard Rain and confirm raised arms, crystal breakage and flying shard fragments.
- [ ] Reach phase II and verify the purple awakening flare and arena crystal break sequence play once.
- [ ] Confirm crystal clusters regrow after eight seconds and are not left invisible or undersized.
- [ ] Defeat the boss and verify the collapse animation and golden core remain visible.
- [ ] Confirm the mythic companion reveal card appears once, fits 375px-wide mobile screens and closes with its button.
- [ ] Rejoin after defeating the boss and confirm the reward reveal does not replay.
- [ ] In a two-player Studio session, confirm one player's animations and crystal breakage are not visible to the other player.


## Forgotten Heart combat feedback — Studio acceptance
- [ ] Strike the boss and confirm its body compresses, head recoils, core flashes and crystal sparks appear.
- [ ] Confirm the hit camera shake is subtle and does not interfere with aiming or movement.
- [ ] Stand inside a boss warning zone and verify the damage flash and stronger camera shake play on a hit.
- [ ] Dodge an attack and verify no damage flash is shown.
- [ ] Test on a 375px-wide mobile viewport and confirm the flash does not block ProximityPrompt controls.
- [ ] In a two-player Studio session, confirm combat feedback is local to the player whose encounter generated it.
- [ ] Verify effects stop cleanly after leaving the cave, dying, respawning or defeating the boss.
- [ ] Add and test curated audio only after approved sound assets and usage rights are confirmed.


## Forgotten Heart combat readability — Studio acceptance
- [ ] Confirm Crystal Slam warning zones are cyan, Echo Pulse zones violet and Shard Rain zones pink.
- [ ] Check that all three warning colors remain visible against the cave floor and crystal lighting.
- [ ] Hit the boss and verify a floating damage number matches the actual health reduction.
- [ ] Verify no damage number appears when the player dodges or the health value does not change.
- [ ] Confirm the health bar animates smoothly and changes to the phase-II accent at 180 HP.
- [ ] Check damage number placement on desktop and 375px-wide mobile screens; ensure it does not cover the interaction prompt.\n\n## Unified material inventory — Sprint 4.40
- [ ] Open «Мои материалы» from the main menu on desktop and mobile.
- [ ] Verify Elderwood, Moonpetal, Starshard, Crystal Shards, and Ash Crystals display the saved profile values.
- [ ] Verify profile load publishes Elderwood, Moonpetal, and Starshard even when the player has never visited their source biome this session.
- [ ] Gather Elderwood, open the Whispering Grove cache, claim the Forgotten Cave treasure/boss reward, mine Crystal Shards, and claim Ash Crystals; verify the panel refreshes immediately.
- [ ] Verify the panel is mutually exclusive with other modal windows and closes with its own close control and «ЗАКРЫТЬ ВСЁ».
- [ ] Verify layout at 375px mobile width and desktop.
- [ ] In a private published test place, rejoin and confirm all five balances persist.\n

## Sprint 4.41 — Advanced Ancient Egg recipe
- [ ] Collect 10 Elderwood, 5 Moonpetals, 3 Starshards and 300 coins; craft one Ancient Egg.
- [ ] Verify each ingredient and the coin balance decrease by exactly the recipe amount.
- [ ] Repeat with each ingredient individually missing; verify the notice names the missing material and no other balance changes.
- [ ] Fill the egg bag; verify crafting is rejected without spending anything.
- [ ] Trigger from outside prompt range and from a different biome; verify no spending.
- [ ] Spam the prompt; verify one egg and one ingredient deduction only.
- [ ] Hatch the crafted Ancient Egg at the normal nest station and verify the 55/30/15 catalog odds remain unchanged.
- [ ] Rejoin a private published test and verify egg and remaining resources persist.

## Sprint 4.42 — Artifact system acceptance
- [ ] Open the artifact panel with an empty collection; verify the empty state and craft requirements.
- [ ] Attempt crafting outside Ancient Heights, away from the workshop, and with each required material missing; verify rejection and no partial spending.
- [ ] Craft repeatedly; verify only catalog artifacts are awarded and rarities match 60/30/10 odds over a sufficiently large sample.
- [ ] Equip two artifacts, attempt a third, and verify the third is rejected without changing equipment.
- [ ] Unequip one artifact and equip another; verify slot count and saved state.
- [ ] Compare passive income with no artifacts and with each artifact combination; verify additive bonuses and the 20% cap.
- [ ] Rejoin and verify collection, equipment and passive-income bonus persist.
- [ ] Verify artifact panel, long artifact names and buttons fit 375px mobile and desktop.

## Sprint 4.43 — Artifact upgrades acceptance
- [ ] Craft or otherwise obtain three copies of one artifact type at level I; merge and verify one level-II instance replaces exactly three inputs.
- [ ] Repeat through levels III–VI and verify level labels and scaled bonuses.
- [ ] Attempt to merge mixed artifact types and mixed levels; verify rejection and no inventory changes.
- [ ] Attempt duplicate IDs, unowned IDs, fewer/more than three IDs, and equipped items; verify rejection and no inventory changes.
- [ ] Attempt to merge a level-VI artifact; verify maximum-level rejection.
- [ ] Rejoin after a successful merge; verify artifact ID, instance ID, level and equipment state persist.
- [ ] Equip upgraded artifacts and compare passive-income payouts; verify the combined +20% cap.
- [ ] Verify the UI only offers unequipped merge groups and remains usable at 375px width.

- [ ] Click **ОБЪЕДИНИТЬ ×3**, verify the confirmation shows the resulting next tier, then cancel and verify nothing changes.
- [ ] Confirm the merge and verify the three source instances are replaced by one upgraded instance.

## Sprint 4.44 — Gatherer artifacts acceptance
- [ ] Craft artifacts repeatedly and verify the three Gatherer entries are obtainable; expected family weight is 20% (12/6/2 out of 100).
- [ ] Equip a Gatherer artifact and harvest an Elderwood root; verify server notice shows the gathering bonus and resource total increases according to the bonus roll.
- [ ] Equip a Gatherer artifact and mine a Crystal Realm vein; verify the bonus applies after existing active-companion bonuses.
- [ ] Compare a sufficiently large sample of harvests with no Gatherer artifact and with +5%, +10%, and +15% bonuses; verify average extra yield trends toward the displayed rate.
- [ ] Upgrade a Gatherer artifact and verify its bonus scales by 25% per level.
- [ ] Equip two Gatherer artifacts and verify combined bonus is capped at +50%.
- [ ] Unequip the artifacts and verify gathering returns to the unmodified yield.
- [ ] Verify node cooldowns remain 180 seconds and are not bypassed by artifact bonuses.
- [ ] Verify wrong biome, locked progression, dead character, out-of-range and missing-profile attempts award no resources.
- [ ] Rejoin and verify artifact levels, equipment and displayed bonus persist.
- [ ] Check artifact collection text and effect labels at 375px mobile width.

## Sprint 4.44 — Studio quick-test fixture
- In Roblox Studio only, open **АРТЕФАКТЫ** and use **ТЕСТ: ВЫДАТЬ ×3 СОБИРАТЕЛЕЙ**.
- The server fills each Gatherer type to three level-I copies, allowing equip, harvest, merge and confirmation testing without grinding the rare craft odds.
- The server rejects this action outside Studio and refuses to exceed the 40-item collection cap. QA instances are tagged as temporary, excluded from saved DataStore snapshots, and cannot be merged with normal crafted instances.
- [ ] Verify the test button is visible in Studio Play and absent from a published server.
- [ ] Use the fixture to equip each Gatherer, harvest Elderwood and Crystal nodes, merge three copies, and verify the next tier.
- [ ] Verify the fixture cannot be invoked in a published server and leaves the inventory unchanged when capacity is insufficient.

- QA fixtures are counted independently from normal crafted artifacts. The collection labels temporary QA items with `ТЕСТ` and keeps their merge groups separate from normal artifacts.

## Sprint 4.44 — Transparent resource bonus notices
- [ ] With Gatherer equipped, harvest Elderwood and Crystal nodes repeatedly; each notice must show the total material yield and the number of extra materials attributed to the artifact (including zero).
- [ ] Compare displayed extra materials against actual server-side inventory changes; verify no phantom rewards.
- [ ] With no Gatherer equipped, notices should not display a Gatherer bonus.
- [ ] Verify the displayed percentage is the expected long-run bonus, not a guaranteed bonus on every attempt.

## Sprint 4.44 — Studio-only sampling tool
- Open **АРТЕФАКТЫ** in Studio Play, equip a Gatherer and select **ТЕСТ: 1000 СБОРОВ БЕЗ НАЧИСЛЕНИЯ** at the top of the collection list.
- The test uses the actual server `ArtifactBonusService:ApplyGatherBonus` formula on 1000 sample yields (1, 2, 3). It compares the observed extra-material rate against the expected equipped Gatherer rate.
- No resource balances or node cooldowns are modified. The request is blocked in published servers.
- [ ] With nothing equipped, confirm 0 extra drops and 0% expected yield.
- [ ] Equip a +5% / +10% / +15% Gatherer and confirm the simulated observed rate is near the expected rate.
- [ ] Unequip the Gatherer and rerun to confirm the bonus disappears.
- [ ] Ensure simulated samples never award real materials or bypass node cooldowns.
- The 1000-sample Studio simulation uses its own seeded `Random` generator and passes rolls into the production bonus function. It does not consume the game's shared `math.random()` sequence, so QA sampling cannot perturb unrelated drops or gameplay randomness.
- Static regression also verifies the Studio guard runs before sampling and the simulation handler contains no resource-balance or node-cooldown writes.


## Sprint 4.45 — Researcher artifacts acceptance
- [ ] Craft artifacts repeatedly and verify Researcher entries appear with a combined 10% family chance; verify all catalog weights total 100.
- [ ] Equip Field Journal, Moon Atlas, and Star Compass separately; verify positive XP awards trend toward +5%, +10%, and +15%.
- [ ] Verify XP from trials, secrets, and companion abilities all passes through the same Researcher bonus path.
- [ ] Unequip Researcher artifacts and verify XP returns to the unmodified base reward.
- [ ] Upgrade a Researcher artifact and verify its bonus scales by 25% per level.
- [ ] Equip two upgraded Researchers and verify combined XP bonus is capped at +50%.
- [ ] Verify invalid profiles, zero/negative XP, and rejected reward paths do not award bonus XP.
- [ ] Verify trial, secret, boss, and companion-ability notices show actual XP, actual extra XP, and the expected Researcher percentage, including when a fractional roll grants zero extra XP.
- [ ] Rejoin and verify artifact levels, equipment and displayed XP bonus persist.
- [ ] Check artifact names, effect text, summary and Studio-only controls at 375px mobile width.

## Sprint 4.45 — Studio Researcher QA
- In Roblox Studio only, open **АРТЕФАКТЫ** and use **ТЕСТ: ВЫДАТЬ ×3 ИССЛЕДОВАТЕЛЕЙ**.
- Equip each Researcher and use **ТЕСТ: 1000 НАГРАД XP БЕЗ НАЧИСЛЕНИЯ** to sample the production formula.
- [ ] Verify the fixture adds three level-I copies of each Researcher type, respects the 40-item collection cap, and tags each item as temporary.
- [ ] Merge three matching QA copies and verify the next tier; verify QA copies cannot merge with normal crafted artifacts.
- [ ] Confirm the simulation output is near the expected equipped bonus for no artifact and each Researcher tier.
- [ ] Verify simulation does not change profile XP, player level, saved resources, or shared gameplay RNG.
- [ ] Verify both QA actions are rejected by the server outside Roblox Studio.


## Sprint 4.46 — Hunter artifacts acceptance
- [ ] Verify Hunter Trophy (+5%), Moon Tracker (+10%), and Hunter Crown (+15%) appear in crafting with family odds 6/3/1 (10% total).
- [ ] Verify all artifact weights total 100: income 60%, Gatherer 20%, Researcher 10%, Hunter 10%.
- [ ] Equip each Hunter separately and verify the highest-rarity tier chance increases for all seven natural biome egg tables.
- [ ] Verify the displayed base and adjusted probabilities match the server's normalized weighted table.
- [ ] Verify lower rarity species weights are unchanged and all species remain in their original biome egg.
- [ ] Verify two equipped Hunter artifacts stack additively and the combined relative-weight modifier never exceeds +30%.
- [ ] Upgrade Hunter artifacts through levels I–VI and verify the 25% per-level scaling and cap.
- [ ] Verify unequipping removes the Hunter modifier immediately and rejoining preserves equipment and levels.
- [ ] Hatch a breeding egg with Hunters equipped and verify offspring species and inherited genetic trait are unchanged.
- [ ] Verify Hunter artifacts never alter genetic-trait odds.
- [ ] Verify hatch notices show the highest-tier probability before and after the Hunter modifier only for natural eggs.
- [ ] Verify Egg Shop and Collection Book show each species' live normalized chance and its base chance when Hunter artifacts change it, for both discovered and undiscovered companions.
- [ ] Verify shared world egg signs explicitly identify their displayed percentages as base odds without Hunter artifacts.
- [ ] Verify collection UI at 320×480, 375×667, and desktop sizes; confirm the panel stays within the viewport and the summary remains readable.
- [ ] Verify all three Studio fixture buttons and all three simulations appear inside the scrollable list, can be reached by scrolling, and do not overlap the craft button or combined-bonus summary.
- [ ] Verify Hunter descriptions, individual effects and combined Hunter bonus remain readable without overlap.
- [ ] Verify the collection summary shows all four combined equipped effects (income, gathering, XP, Hunter) and matches the equipped artifacts.
- [ ] Verify the UI regression test checks the exact current Gatherer effect label and the Studio fixture scroll-layout contract.

## Sprint 4.46 — Studio Hunter QA
- In Roblox Studio only, open **АРТЕФАКТЫ** and use **ТЕСТ: ВЫДАТЬ ×3 ОХОТНИКОВ**.
- Equip Hunter artifacts and run **ТЕСТ: 7000 ВЫЛУПЛЕНИЙ БЕЗ НАГРАД**.
- [ ] Confirm the simulation samples 1,000 outcomes from each of the seven natural egg tables and reports both observed and formula probabilities.
- [ ] Confirm simulation leaves egg inventory, companion collection, XP, genetic traits, and saved profile data unchanged.
- [ ] Verify test artifacts remain tagged temporary, are not persisted, and cannot merge with normal crafted copies.
- [ ] Verify both Hunter QA actions are rejected by the server outside Roblox Studio.


## Sprint 4.47 — Raid consent and matchmaking
- [ ] With a new profile, open **РЕЙДЫ НА ГНЁЗДА** and verify both opt-in controls are blocked by newcomer protection.
- [ ] In Studio Play, use **ТЕСТ: ОТКРЫТЬ ДОСТУП К РЕЙДАМ** to bypass level/time gates for matchmaking tests; verify the saved profile level and profile data remain unchanged. Click the same control again to restore the protection state.
- [ ] Set a test profile to level 4; verify raid participation remains locked. At level 5, verify the 15-minute join protection still applies.
- [ ] After protection expires, enable **ГОТОВ К РЕЙДУ** and verify it expires after ten minutes or can be disabled manually.
- [ ] Enable **ОТКРЫТЬ ГНЕЗДО** on a second player; verify the first player sees that nest only after enabling attack readiness.
- [ ] Verify a closed nest, protected player, self-target, visitor, player without a plot, and already matched player cannot be challenged.
- [ ] Send a challenge; verify it appears only for the defender and expires after 45 seconds.
- [ ] Accept, decline, cancel, and let a challenge expire; verify both clients receive the correct state.
- [ ] Accept a challenge; verify both players see the same opponent, role and READY state, then cancel it from either side.
- [ ] Disconnect either participant during an invitation and during READY state; verify the other participant is released.
- [ ] Confirm the matchmaking system never changes coins, eggs, companions, artifacts, materials or saved profile data.
- [ ] Verify the board, buttons, incoming invitation and target list at 320×480, 375×667, tablet and desktop sizes.

 
## Sprint 4.48 — Bounded raid arena acceptance
- [ ] In a two-client Studio session, open a defender's nest, enable attacker readiness, send a challenge and explicitly accept it; verify both players are moved to the same isolated arena.
- [ ] Verify each arena has a stable floor, enclosing walls, two separated spawn points, a visible core pedestal and a readable floating health label.
- [ ] As attacker, approach the core and strike it; verify exactly 20 integrity is removed and the action is rejected beyond 16 studs.
- [ ] Spam the attack action; verify the server enforces the 2.2-second cooldown and cannot reduce integrity below zero.
- [ ] As defender, approach the core and reinforce it; verify exactly 10 integrity is restored up to 100 and the action is rejected beyond 16 studs.
- [ ] Spam reinforcement; verify the server enforces the 8-second cooldown and a full core cannot be overfilled.
- [ ] Verify the attacker wins at zero integrity and the defender wins when the 150-second timer expires.
- [ ] Verify the attacker receives 150 coins and 100 XP, while the defender receives 50 coins; confirm XP uses the normal Researcher artifact path.
- [ ] Complete another match inside the ten-minute reward cooldown; verify neither participant receives duplicate rewards.
- [ ] Forfeit, reset/die, and disconnect during an active round; verify the arena is destroyed, no reward is granted, and the remaining player returns to their saved position.
- [ ] Rejoin after a rewarded match and verify the persistent reward cooldown remains active.
- [ ] Confirm no coins, eggs, companions, artifacts, materials, nest decorations or building inventory are stolen or otherwise changed by the opponent.
- [ ] Verify the arena HUD, role-specific action and forfeit control at 320×480, 375×667, tablet and desktop sizes.

 
## Sprint 4.49 — Raid duel combat acceptance
- [ ] In a two-client Studio session, start a raid and verify both players receive the correct temporary sword and shield visuals.
- [ ] Verify the sword and shield are positioned correctly on R15 and R6 characters and do not interfere with movement or core interaction.
- [ ] As either role, approach within 12 studs and strike; verify the opponent loses exactly 24 raid combat health.
- [ ] Attempt a strike from beyond 12 studs; verify the server rejects it without changing either combat health value.
- [ ] Spam strike requests; verify the server enforces the 1.15-second cooldown independently for each player.
- [ ] Raise guard and strike inside the 0.9-second window; verify the incoming strike is negated and the attacker receives 18 counter-damage.
- [ ] Strike after the guard window expires; verify the strike deals 24 damage normally.
- [ ] Spam guard; verify the 3.2-second cooldown and the HUD's remaining cooldown state.
- [ ] Verify five unblocked strikes can defeat a player; verify a successful parry can change the duel outcome and the correct role receives victory rewards.
- [ ] Verify duel health is separate from Humanoid health: normal character health is unchanged by strikes and parries.
- [ ] Verify both duel health values update on both clients and clear when the match ends.
- [ ] Verify temporary RaidCombatGear, hit flashes and guard visuals are removed on core victory, duel victory, timer victory, forfeit, death and disconnect.
- [ ] Verify duel victory still uses the existing 150-coin / 100-XP winner and 50-coin participant rewards, including the persistent ten-minute cooldown.
- [ ] Verify core attacks, defender reinforcement, round timer and return-position recovery still work after adding duel combat.
- [ ] Verify the combat HUD and touch targets at 320×480, 375×667, tablet and desktop sizes.

 
## Sprint 4.50 — Persistent nest defenses acceptance
- [ ] Open **СТРОИТЬ ОСТРОВ** and verify the catalog labels Stone Bastion, Watchtower and Thorn Trap as **ОБОРОНА**.
- [ ] Purchase each defense and verify coins decrease by the catalog cost and the defense count increases without exceeding 12.
- [ ] Attempt to buy a seventh bastion, fourth watchtower, seventh trap, and any thirteenth total defense; verify server rejection and no coin/profile changes.
- [ ] Place each structure on the personal island; verify distinct wall/tower/trap models render at the selected position.
- [ ] Move and rotate each structure, then remove it; verify inventory returns exactly one item and placement data remains correct after reopening the panel.
- [ ] Join a two-client Studio session, create an opt-in raid and accept it; verify the defender's placed structures are materialized on the arena's defender half.
- [ ] Verify an island with no placed defenses produces an empty defense state and does not create default free structures.
- [ ] As attacker, walk into a bastion; verify it physically blocks the route and does not block the defender spawn or Nest Core.
- [ ] Attack a bastion within 12 studs; verify 35 structure health is removed, the 1.15-second cooldown is enforced, and the barrier disappears only at zero health.
- [ ] As defender, repair a damaged but standing bastion within 12 studs; verify +30 health, an eight-second cooldown and the health label update.
- [ ] Attempt to repair a destroyed structure; verify it cannot be restored in the same raid.
- [ ] Verify a watchtower fires only at the attacker inside 38 studs, deals 8 raid-health damage on a projectile hit, and stops after destruction or match cleanup.
- [ ] Verify a thorn trap triggers only for the attacker, deals 12 raid-health damage, and cannot trigger again for six seconds.
- [ ] Verify defender characters, visitors and unrelated players do not trigger traps or receive turret damage.
- [ ] Attempt attacker repair, defender structure damage, out-of-range requests and rapid remote spam; verify all are rejected server-side.
- [ ] Finish a raid after damaging, repairing and destroying defenses; reopen the defender's island build panel and verify original saved placements and inventory are unchanged.
- [ ] Start a second raid; verify every owned defense returns at full health and the previous arena state is not reused.
- [ ] Verify defense count, role controls and construction catalogue at 320×480, 375×667, tablet and desktop sizes.

 
## Sprint 4.51 — Battle companion acceptance
- [ ] In a two-client Studio session, equip up to three active companions on both accounts and start an accepted raid.
- [ ] Verify each participant sees their own active companions beside them in the arena; companions must follow their owner and never block movement, the core or defenses.
- [ ] Verify nameplates show companion names and role labels; the selected primary battle companion has a distinct highlight.
- [ ] Verify primary selection uses the first active companion with a `RaidAbility` in active-slot order, not collection order. Reorder active companions and start a new raid to verify the selected ability changes.
- [ ] Verify an active roster without any raid-role companion shows the empty pet state and hides the ability button.
- [ ] Verify raid abilities unlock at player level 5; attempt malformed action payloads, use outside an active match and use after death; all must be rejected.
- [ ] As a Hunter, use the ability with the opponent inside range; verify a visible projectile, correct damage, cooldown and normal duel victory/reward handling.
- [ ] As a Hunter, attempt to use the ability beyond range or excessive vertical separation; verify rejection and that cooldown is not consumed.
- [ ] As a Healer, take duel/turret/trap damage and use the ability; verify the exact configured healing, maximum 100 health and rejection at full health.
- [ ] Verify Healer never changes Roblox Humanoid health and cannot revive a dead character.
- [ ] As a Guardian, activate the shield and receive a normal duel strike; verify shield capacity is consumed before combat health.
- [ ] Verify Guardian shields also absorb parry counter-damage, Watchtower hits and Thorn Trap hits.
- [ ] Verify shield duration expiry, full depletion, cooldown display and rejection of a second shield while one is active.
- [ ] Spam pet ability requests; verify the server enforces per-match cooldowns even if the client button is manipulated.
- [ ] Verify one primary pet ability per participant and no effect from companions that are not in the active roster.
- [ ] End raids by core victory, duel victory, timer, forfeit, death and disconnect; verify all raid companions, nameplates, highlights and projectiles are removed.
- [ ] Reopen the collection and verify companion ownership, active slots, levels, moods and needs remain unchanged.
- [ ] Verify pet HUD controls at 320×480, 375×667, tablet and desktop.

 
## Sprint 4.52 — Battle companion mastery acceptance
- [ ] Verify Ash Phoenix is Hunter, Snow Owl is Healer and Glacier Bear is Guardian in the collection and raid arena.
- [ ] Verify Cinder Fox and Frost Fox do not show the misplaced raid roles; their ordinary species abilities remain unchanged.
- [ ] Create or train copies of one Hunter, one Healer and one Guardian to growth levels 1, 5 and 10.
- [ ] Verify Hunter effective damage is base, base +2 and base +4 at levels 1, 5 and 10 respectively.
- [ ] Verify Healer effective power is base, base +2 and base +4 at levels 1, 5 and 10 respectively.
- [ ] Verify Guardian shield capacity is base, base +2 and base +6 at levels 1, 5 and 10 respectively.
- [ ] Verify Hunter damage never exceeds 30, Healer power never exceeds 35 and Guardian shield never exceeds 40.
- [ ] Verify a Healer with only 3 missing health restores exactly 3, even when its scaled power is higher.
- [ ] Verify player level 4 is denied and level 5 is allowed, independently of the companion's growth level.
- [ ] Verify Guardian shield duration and ability cooldown remain species-defined and do not shorten as the pet grows.
- [ ] Verify the HUD displays the primary companion's actual level and effective power label on both clients.
- [ ] Verify each raid companion nameplate shows the same growth level as the collection.
- [ ] Reorder active companions and verify the selected primary pet's level and power change to match the first active role companion.
- [ ] Train a companion before a raid, rejoin, and verify its saved growth level still controls combat power.
- [ ] Verify the scaling does not change normal pet income, stars, genetic traits, breeding readiness or collection ownership.
- [ ] Verify the raid HUD at 320×480, 375×667, tablet and desktop.

 
## Sprint 4.53 — Raid companion team synergy acceptance
- [ ] Start a two-client Studio raid with Guardian + Healer active. Verify the HUD shows **Живой бастион**, Guardian/Healer ability power is +15%, and incoming raid combat damage is reduced by 12%.
- [ ] With Guardian + Healer, verify reduction applies to normal melee strikes, parry counter-damage, Watchtower hits and Thorn Trap hits before any Guardian pet shield absorbs the remaining damage.
- [ ] Start a raid with Hunter + Guardian active. Verify **Штурмовой строй**, Hunter ability power +15% and normal melee strike damage +10%.
- [ ] Verify Hunter + Guardian increases both Hunter ability power and Guardian shield capacity by 15%, and does not change parry counter-damage.
- [ ] Start a raid with Hunter + Healer active. Verify **Согласованный натиск**, Hunter ability power +15% and Healer restoration power +15%.
- [ ] Verify Healer still restores only missing raid combat health and cannot exceed 100.
- [ ] Start a raid with Hunter + Healer + Guardian active. Verify **Триада** replaces all pair synergies and applies +10% ability power, 8% damage reduction and +5% normal melee strike damage exactly once.
- [ ] Verify a roster with two Hunters and one Guardian counts as two distinct roles and activates only Hunter + Guardian.
- [ ] Verify three companions with the same role show no synergy; adding a second distinct role activates only its matching pair.
- [ ] Verify a single role, an empty active roster or companions without raid abilities show the no-synergy HUD state and preserve Sprint 4.52 values.
- [ ] Verify the server derives composition from the saved active roster; forged client attributes or request payload fields cannot grant or change synergy.
- [ ] Verify Hunter, Healer and Guardian ability power still respects caps 30, 35 and 40 after synergy.
- [ ] Verify synergy cannot shorten pet cooldowns, extend Guardian shield duration, change player-level unlock requirements or increase raid rewards.
- [ ] Verify the synergy name and effect description are visible on both clients and update correctly when each participant has a different roster.
- [ ] Finish by core victory, duel victory, timer, forfeit, death and disconnect; verify synergy attributes clear and no synergy data appears in the saved profile.
- [ ] Verify the synergy line and 286-pixel raid HUD at 320×480, 375×667, tablet and desktop.

 
## Sprint 4.54 — Companion synergy visual acceptance
- [ ] Start a Guardian + Healer raid and verify Guardian companions use the Bastion cyan/blue aura while Healers use mint green.
- [ ] Start a Hunter + Guardian raid and verify warm orange Hunter and blue Guardian auras.
- [ ] Start a Hunter + Healer raid and verify warm orange Hunter and green Healer auras.
- [ ] Start a full Hunter + Healer + Guardian raid and verify orange, violet and cyan role colors for Triad.
- [ ] Verify the aura is subtle at rest and does not hide the existing primary-pet highlight, pet silhouette or nameplate.
- [ ] Verify the server-issued activation pulse lights every companion in the roster once when the raid starts.
- [ ] Verify each participant sees one animated activation toast with the correct synergy title and description; no repeated toast on ordinary HUD updates.
- [ ] Verify the attack team pulses on a validated opponent strike, core hit and defense hit.
- [ ] Verify a successful Hunter projectile, Healer restoration and Guardian shield activation each cue the active companion team.
- [ ] Verify a successful parry cues the defender's team, not the attacking team.
- [ ] Verify Bastion/Triad defensive cues appear only when incoming damage was actually reduced; no cue for no-synergy teams.
- [ ] Spam strike requests within existing server cooldowns and confirm no duplicate effects, persistent emitters, or growing Highlight/PointLight counts.
- [ ] Verify effects are cleaned up after their short tween duration and after victory, defeat, forfeit, death, timeout and disconnect.
- [ ] Verify no-synergy rosters show no aura, no activation toast and no coordinated synergy cues.
- [ ] Verify both clients see the same world companion effects while each client only sees its own synergy activation toast.
- [ ] Verify HUD toast, companion aura and cues at 320×480, 375×667, tablet and desktop.
- [ ] Run a two-client Studio match with three companions per side and check frame rate, readability and Output for runtime errors.

 
## Sprint 4.55 — Companion combat motion acceptance
- [ ] Enter a raid with one Hunter and verify a short wind-up, forward lunge toward the opponent and return to the follower slot after a validated strike.
- [ ] Enter a raid with one Guardian and verify a shorter advance on attack and a lowered protective brace on a defensive cue.
- [ ] Enter a raid with one Healer and verify a supportive hover on ability use and a rising pose on defense.
- [ ] Verify Hunter pet ability uses a target-directed dive, Guardian shield uses a defensive brace, and Healer restoration uses a rising hover.
- [ ] Verify three active companions begin activation motion with a subtle stagger rather than an identical simultaneous bounce.
- [ ] Verify all companions animate even when the participant has no synergy; no-synergy teams must not receive synergy-only aura/highlight effects.
- [ ] Verify attacker and defender Hunter motions point toward the actual opponent, not a fixed world direction.
- [ ] Verify the normal follower formation resumes after every motion and when the cue expires.
- [ ] Turn and move the player during a cue; verify no persistent offset, snapping or jitter after the action.
- [ ] Verify motion remains readable with three companions and does not overlap the player character or obscure the raid controls.
- [ ] Verify repeated combat requests respect existing server cooldowns and do not create additional motion loops.
- [ ] Verify companion motion stops cleanly on match end, forfeit, death, timeout and disconnect.
- [ ] Run a two-client Studio test and confirm both clients see the same model motion.
- [ ] Check server Output and frame rate during a full match with three companions per participant.

 
## Sprint 4.56 — Responsive UI foundation acceptance
- [ ] Test the initial boot card at 320×480 and verify the card and full error/loading text remain inside the viewport.
- [ ] Test the feature menu at 320×480 and 375×667; verify all 14 actions remain reachable by scrolling.
- [ ] Verify each menu button has a visible two-letter native badge and no blank image placeholder.
- [ ] Verify menu labels begin after the badge, truncate at the end and remain readable without overlapping.
- [ ] Test the same menu at tablet, 1366×768 and 1920×1080; verify desktop sizing and full labels return.
- [ ] Change the Studio emulator resolution while running; verify the global UIScale and navigation geometry update.
- [ ] Replace Workspace.CurrentCamera during a test; verify scale and navigation listeners rebind to the new camera.
- [ ] Verify camera changes do not create duplicate resize connections or repeated UI scaling.
- [ ] Verify all modal panels still open/close correctly and the raid panel is registered only once in modal exclusivity.
- [ ] Verify close-all and Escape behavior remain unchanged.
- [ ] Check Windows, Android and iOS font rendering for every native navigation badge.
- [ ] Continue with individual modal constraints and gameplay HUD safe-area checks in the next UI sprint.

 
## Sprint 4.57 — Main navigation visual acceptance
- [ ] Open the feature menu at 320×480, 375×667, tablet, 1366×768 and 1920×1080.
- [ ] Confirm the navigation header and all three section labels are visible in the correct order.
- [ ] Confirm all 14 vector icons are drawn correctly, distinct from one another and not clipped by their 28×28 badge.
- [ ] Confirm icons render without external asset loading, blank rectangles or unsupported glyphs.
- [ ] Check that long Russian button labels truncate at the end and never overlap the icon.
- [ ] Check button gradients, accent strokes, rounded corners and consistent vertical spacing.
- [ ] Hover every action on desktop and confirm a subtle highlight; test touch taps on mobile without relying on hover.
- [ ] Confirm the hamburger transforms into a close mark while the menu is open and resets after closing.
- [ ] Activate all 14 feature actions; confirm the existing feature handler still runs and the menu closes afterward.
- [ ] Scroll through the complete menu on phone portrait and landscape; verify the last three actions remain reachable.
- [ ] Capture a Studio screenshot and tune any visual issues before starting the companion inventory panel.

 
## Sprint 4.58 — Companion inventory acceptance
- [ ] Check inventory panel at 320×480, 375×667, tablet, 1366×768 and 1920×1080.
- [ ] Confirm the title, accent divider, team summary, genetics line and incubator card do not overlap.
- [ ] Confirm active count and total owned companion count match the server response.
- [ ] Confirm every rarity receives a distinct accent and star count is displayed correctly.
- [ ] Check turtle, winged/dragon, bird, deer and default/fox portrait silhouettes for clipping and visual consistency.
- [ ] Confirm XP progress fill matches GrowthXP / GrowthXPToNext and handles max-level pets.
- [ ] Confirm team action text clearly communicates equip/unequip state and updates after server response.
- [ ] Confirm merge remains a two-step confirmation and still consumes the correct companions.
- [ ] Confirm training disables at max level and refreshes cost/state after the server response.
- [ ] Confirm ability availability/cooldown and breeding selection/confirmation remain functional.
- [ ] Confirm cards expand for optional ability/breeding rows and no buttons overlap at narrow widths.
- [ ] Confirm empty state is visible only when no companions are owned.
- [ ] Test all inventory actions with mouse and touch, including scroll gestures.
- [ ] Inspect long companion names, genetic trait names and parent names for truncation or wrapping issues.

 
## Sprint 4.59 — Egg shop and hatch acceptance
- [ ] Confirm six natural biome eggs appear in progression order and the Forgotten Cave egg is not sold in the regular shop.
- [ ] Confirm each card displays the correct egg name, biome, rarity, price and three possible companions.
- [ ] Compare displayed probabilities against the biome species weights and equipped hatch artifacts.
- [ ] Verify level-locked cards, quest-locked cards, insufficient coins and full 20/20 egg capacity have distinct messages and disabled purchase buttons.
- [ ] Attempt direct RemoteFunction purchases for locked eggs and verify the server rejects them without changing coins or inventory.
- [ ] Buy each available egg and confirm coins, EggCount, inventory record EggId and BiomeId update exactly once.
- [ ] Confirm the correct biome egg name appears on world ProximityPrompts.
- [ ] Collect each world egg and confirm its welded band, runes, crown gem, glow and Highlight travel with it and respawn together.
- [ ] Hatch a shop egg from each biome and verify OriginBiome, species table and discovery are correct.
- [ ] Hatch a world egg and a breeding egg; confirm the correct egg is consumed and the companion is added once.
- [ ] Trigger the hatch prompt repeatedly and verify the server serializes hatch requests.
- [ ] Verify the reveal event is sent only after the server commits the companion and counters.
- [ ] Verify egg shake, crack lines, pet reveal, rarity border, trait and income details.
- [ ] Skip the animation and confirm the already-saved result is shown; close the reveal and confirm the pet remains in inventory.
- [ ] Rejoin and confirm purchased/hatch results persist.
- [ ] Test shop and reveal on 320×480, 375×667, tablet, 1366×768 and 1920×1080.
- [ ] Capture Studio screenshots of shop cards and the hatch reveal at phone and desktop sizes.

## Sprint 4.60 — Collection Book UX
1. Open the Collection Book and search by a known species name, rarity, biome name and acquisition label.
2. Test filters: All, Discovered, Not discovered. Confirm counts/results change correctly and clearing the search restores results.
3. Verify hidden species remain hidden as undiscovered; search must not reveal undiscovered names.
4. Verify discovered entries still show owned count, income, discovery biome and normalized hatch odds; boss-only and breeding-only entries retain their acquisition labels.
5. Test long names and detail text at 320×480, 375px, tablet and desktop. Confirm list scroll, panel close and menu/modal exclusivity.
6. Hatch a new species while the book is open. Confirm the book refreshes once and the new discovery appears without reopening.
7. Confirm no client-side action changes collection data or hatch odds; server response remains authoritative.

Static CI checks are not a substitute for these Roblox Studio runtime checks.

## Sprint 4.61 — Unified Nest Management Overview
1. Open My Nest from navigation. Confirm the overview shows current nest level, coins, owned companion count and displayed-pet income per 10 seconds.
2. Compare the income value with Display Pets and the next two actual 10-second payout ticks; an empty display must show zero.
3. Use each shortcut: Display Pets, Decorations, Construction and Upgrade Nest. Confirm the overview closes before the destination panel opens and all destination actions still work.
4. Attempt an upgrade with insufficient coins, then with enough coins. Confirm server rejection/success messaging, coin balance and level refresh. Verify max-level state disables both upgrade controls.
5. Hatch a companion while the overview is open. Confirm owned count updates. Change coin balance and confirm the summary updates without reopening.
6. Test 320×480, 375×667, tablet, 1366×768 and 1920×1080. Confirm stat cards, two-column shortcut grid, upgrade button and close button do not overlap or clip.
7. Test mouse and touch activation; confirm no duplicate upgrade request can be submitted while the action is in progress.

Static CI checks do not replace Roblox Studio runtime and economy tests.

## Sprint 4.62 — Living Nest Environment
1. Start a fresh server and inspect all six plots. Confirm each has four corner trees, flower beds and the stepping-stone approach.
2. Walk around each plot and across the decorative pieces. Confirm props do not block characters, prompts or camera selection.
3. Open construction and place items at the outermost valid grid cells. Confirm landscaping stays outside the build grid and does not cause false placement collisions.
4. Upgrade a nest through levels 1–5. Confirm level 2 lantern posts emit warm light, level 3 crystals glow, level 4 banner appears and level 5 crown appears.
5. Leave and rejoin. Confirm the environment is rebuilt and the correct upgrade tier is restored from the saved nest level.
6. Run two or more players together. Confirm each plot's landscaping and upgrade tier remain independent and no props appear on another player's plot.
7. Inspect at low and high graphics quality and from ground/elevated camera angles. Check for floating pieces, clipping, excessive bloom or unwanted visual noise.

Static source assertions cover the decoration definitions and non-collidable settings; they do not replace Studio movement, placement, multiplayer or persistence testing.

## Sprint 4.63 — Island Identity Styles
1. Open Nest Decorations. Confirm the style section lists Meadow, Arcane, Ancient Temple and Royal Garden with clear selected/locked states.
2. At nest level 1, confirm only Meadow can be selected. Upgrade to level 2 and confirm Arcane unlocks; level 3 unlocks Ancient; level 5 unlocks Royal.
3. Select each available style. Confirm grass, trees, flowers and path colors change, and each theme adds its own signature world details.
4. Attempt SetStyle requests with an unknown ID and with a locked style from a test client. Confirm the server rejects both and the active theme remains unchanged.
5. Leave and rejoin after selecting a non-default style. Confirm the same style is restored on the assigned plot.
6. Verify theme details do not block character movement, pet displays, contest trophies, construction placement or custom decoration placement.
7. Test the selector and scrolling at 320×480, 375×667, tablet, 1366×768 and 1920×1080.

Static source checks validate the catalogue, persistence field, server-side unlock gate and UI wiring. Runtime and exploit validation must be completed in Roblox Studio.

## Sprint 4.64 — Living Island Companions
1. Display one pet in a nest slot. Confirm it walks around a small area near its own display point, turns toward its destination, pauses, and idles naturally.
2. Display four pets. Confirm each remains in its own area and does not wander across the plot or into another pet's area.
3. Raise a pet's mood above 80 and confirm its behavior becomes more playful and its movement becomes quicker. Lower its energy below 15 and confirm movement slows.
4. Put a pet to sleep. Confirm it stops wandering and remains in a resting pose until the sleep timer expires.
5. Remove or replace a displayed pet while it is moving. Confirm the old model and its movement loop stop cleanly.
6. Use the existing Feed, Pet, Play, EquipToy and ToyPlay actions while pets are moving. Confirm server responses and displayed needs stay consistent.
7. Test with multiple players and monitor server performance, movement replication, plot boundaries, building placement and decoration placement.

Static regression checks validate bounded movement, state-driven behavior and existing interaction wiring. Roblox Studio runtime and multiplayer performance checks are still required.

## Sprint 4.65 — Autonomous Toy Play
1. Equip Meadow Ball, Cozy Plush and Wind Spinner on separate displayed pets. Confirm each toy appears on the ground beside its pet, not attached to its body.
2. Wait for a pet to choose its toy. Confirm it walks to the toy, pauses, performs a playful bob/turn, and the toy bounces or rocks. Confirm the Wind Spinner keeps rotating.
3. After a short play session, confirm the pet resumes wandering and may choose the toy again later.
4. Set mood low or energy below the toy's energy requirement. Confirm the pet does not start a new toy session. Put it to sleep and confirm toy play stops.
5. Re-equip a different toy and confirm the previous toy is removed and only one new toy remains.
6. Remove the pet while it is moving or playing. Confirm both pet and toy are removed with no orphaned parts.
7. Test up to four displayed pets and multiple players. Check movement boundaries, server performance, character movement, building placement and decoration placement.

Static checks validate the toy state machine and cleanup ownership. Roblox Studio runtime, multiplayer and visual checks remain required.

## Sprint 4.66 — Personalities & Social Life
1. Display two companions in slots 1 and 2. Wait for one to seek its partner; confirm the second joins and both face each other during a short social interaction.
2. Repeat with slots 3 and 4. Confirm pairs remain inside their plot and do not interfere with other displays.
3. Complete a social session and confirm both companions gain a small amount of mood. Remove one companion or put it to sleep mid-session and confirm no reward is granted for the interrupted session.
4. Compare playful/energetic personalities with calm/cautious personalities. Confirm activity frequency, pauses and movement speed differ without any personality becoming stuck.
5. Equip each pet's favorite toy and a non-favorite toy in separate tests. Confirm favorite toys are chosen more frequently, while all equipped toys remain usable.
6. Stand near an idle pet. Confirm it faces the owner, shows a greeting emotion and returns to normal idle behavior after the owner walks away.
7. Test all four slots, multiple players, re-equipping toys, removing pets and rejoining. Check for stuck SeekingFriend states, orphaned toys, duplicate mood rewards and server performance issues.

Static regression checks cover personality profiles, social pairing, mood rewards and greeting triggers. Roblox Studio runtime, multiplayer and persistence checks remain required.

## Sprint 4.67 — Companion Friendship
1. Display two companions in slots 1 and 2 and complete several social interactions. Confirm the friendship score increases once per completed interaction, not twice.
2. Verify the relationship title advances at 10, 30, 60 and 90 points: Приятели, Друзья, Лучшие друзья and Неразлучные.
3. Start a social interaction, then remove the partner or put it to sleep before the timer ends. Confirm no friendship or mood reward is granted for that interrupted session.
4. Repeat with slots 3 and 4. Swap displayed pets and verify friendship remains tied to the same two companion instance IDs rather than slot numbers.
5. Use two players in the same server. Confirm each player's pair scores remain private and never affect the other player's companions.
6. In a published private test experience, complete interactions, leave and rejoin. Confirm friendship score and title are restored from the profile.
7. Confirm old profiles without CompanionBonds load normally and receive an empty table through reconciliation.

Static checks cover deterministic pair keys, threshold titles, single-award ownership and interruption guards. Roblox Studio runtime, multiplayer isolation and DataStore persistence remain required.

## Sprint 4.68 — Autonomous Pet Discoveries
1. Display a Curious or Exploratory companion and observe idle/wandering behavior until it searches a nearby point. Confirm the pet shows the Russian searching state and creates a visible cache.
2. Repeat with a Calm or Cautious companion over a longer session. Confirm its search tendency is lower, not higher, than the curious pet's.
3. Approach the cache as the owner and collect it. Confirm the reward notification, coin balance and mood update.
4. Trigger the prompt repeatedly or from two nearby clients. Confirm only one reward is granted and only the owner can collect it.
5. Confirm reward scales with companion level and stars, and the next search cannot occur until the three-minute cooldown expires.
6. Refresh the displayed-pet lineup or rejoin after claiming. Confirm the cooldown persists and no duplicate cache/reward appears.
7. Test two players in one server; each player must have an independent cache, reward and cooldown.
8. Put a searching pet to sleep before it reaches its target. Confirm its search is cancelled and no cache/reward is generated.
9. Confirm old profiles without CompanionGiftReadyAt load normally through profile reconciliation.

Static checks cover migration, personality search chances, owner-only prompt validation, one-time rewards and cooldown. Roblox Studio visual, timing, multiplayer and persistence tests remain required.


## Sprint 4.69 — Living Island: Day/Night and Companion Routines
1. Start a fresh Studio server and confirm the world begins at 14:00 and the clock advances continuously.
2. Observe the world phase attributes on `Workspace.NestRaidersWorld`; confirm `WorldTimePhase` changes from Day to Night at 19:00 and back to Day at 06:00.
3. Start a second client in the same server. Confirm both clients see the same lighting and phase changes.
4. Display GlowMoth, SnowOwl, CaveGlimmerbat and HeartWisp. Confirm their glow is visible at night and fades during daylight.
5. Compare a nocturnal pet across daytime/nighttime: it should move more briskly and have a higher treasure-search tendency during its preferred hours.
6. Compare MeadowFox, MossTurtle and SproutDragon across day/night: they should be more active during daylight and calmer at night.
7. Manually put a pet to sleep, play with a toy and complete a social interaction during both phases. Confirm the schedule never cancels the explicit sleep state or breaks existing interactions.
8. Collect a companion gift, then observe a full phase transition. Confirm the persistent three-minute reward cooldown remains authoritative.
9. Rebuild the world in a controlled test and confirm the old clock loop stops instead of competing with the new one.
10. Run a full 24-minute cycle with multiple players and monitor server Output for errors and unnecessary per-frame work.

Static checks verify cycle settings, phase replication, activity traits and behavior modifiers. Roblox Studio runtime, lighting, multiplayer and performance tests remain required.


## Sprint 4.70 — Dynamic Weather and Pet Reactions
1. Start a Studio server and wait for the initial weather state. Confirm the HUD shows time, day/night and a Russian weather label.
2. Observe at least two full weather changes. Confirm transitions blend over several seconds and all clients receive the same weather.
3. During Rain and Storm, inspect the nine rain emitter areas around the island. Confirm precipitation covers the playable island, falls downward and does not hide prompts or building placement.
4. During Fog, inspect the island from close and distant camera zoom. Confirm important paths, eggs, prompts and UI remain readable.
5. During Storm, observe at least one lightning flash. Confirm it is brief and the normal weather brightness returns immediately afterward.
6. Display MossTurtle during rain and confirm its rain-positive behavior feedback; display GlowMoth, SnowOwl, CaveGlimmerbat and HeartWisp during a storm and confirm they seek and remain near shelter.
7. Confirm non-nocturnal pets slow down and reduce roaming in poor weather; confirm treasure searches become less likely during storms.
8. Test sleep, hunger, toys, friendship, treasure cache claiming and nest building during all four weather states. Weather must not cancel or duplicate these actions.
9. Test a narrow mobile viewport and a low graphics setting. Confirm the weather strip remains readable and particles do not cause severe frame drops.
10. Rebuild the world during a weather state in a controlled test. Confirm old weather loops and effects are removed with the previous world.
11. Run multiple weather rotations with two or more clients and inspect server Output for errors or accumulated effects.

Static checks verify weather configuration, environmental objects, state attributes, species reactions and HUD subscriptions. Roblox Studio visual, multiplayer, low-end performance and gameplay tests remain required.


## Sprint 4.71 — Favorite Places and Autonomous Nest Exploration
1. Start a Studio server and display companions in each unlocked nest slot. Confirm pets remain within their own plot and choose nearby garden landmarks.
2. Observe MeadowFox and SproutDragon over several minutes. Confirm they prefer flower beds and trees respectively, while still occasionally visiting other nearby points.
3. Place a CrystalPond or MoonFountain and a WarmLantern or MeadowCrystal. Confirm MossTurtle prefers water features, GlowMoth prefers lanterns, and CaveGlimmerbat/HeartWisp prefer crystals when those destinations are in range.
4. Place an AppleTree, FlowerArch, CozyCottage and Watchtower. Confirm each object is recognized as a destination of the expected category.
5. Watch the overhead pet label while moving and while visiting a point. Confirm labels fit and do not obscure nearby pets or prompts.
6. Observe rare discovery notices. Confirm they are occasional, identify the pet and landmark, and do not grant unintended coins or items.
7. Let energy and hunger fall, trigger sleep and storm shelter, and confirm urgent needs take priority over exploration.
8. Use toys, socialize paired pets, collect a treasure cache and build/remove decorations during the same session. Confirm exploration does not cancel or duplicate existing actions.
9. Remove and replace a decoration, then refresh the displayed pets. Confirm old destinations are not retained and newly placed landmarks can be selected.
10. Test all four display slots on every plot position, including the two rear slots. Confirm target points remain on the plot and pets do not clip through the plot edge or nest station.
11. Run with two players and compare notices, pets and destination attributes. Each player must only receive discoveries from their own companions.

Static regression checks cover species preferences, destination collection, weighted selection, exploration states and owner notices. Visual, multiplayer, placement and behavior-priority checks remain required in Roblox Studio.


## Sprint 4.72 — Paired companion adventures
- [ ] Equip at least two companions and verify an eligible pair can start an adventure only while both are awake, sufficiently happy, and nearby.
- [ ] Confirm the paired secret appears near the two companions with a visible connecting beam and readable Russian label.
- [ ] Confirm the rare golden-secret variant is visually distinct and sends the correct owner notification.
- [ ] Claim the secret as the owner; verify both companions receive mood, the lower-mood companion receives the larger assistance bonus, and pair friendship increases.
- [ ] Attempt to claim another player's marker and verify rejection.
- [ ] Attempt to claim outside prompt range and verify no profile changes.
- [ ] Verify per-pair cooldown prevents immediate repeat events and persists after reconnect.
- [ ] Verify claim, timeout, respawn, and disconnect clean up the marker, beam, and attachments.
- [ ] After claiming, watch both pets for at least 10 seconds; rewarded mood must remain visible and must not snap back on the next follower update.
- [ ] Test with two players in the same server; ensure events and rewards remain isolated by owner.
- [ ] Test prompt readability and interaction on desktop and mobile.


## Sprint 4.73 — Friendship milestone celebrations
- [ ] Raise a display pair from 9 to 10 friendship; verify both pets glow and the banner says "Первые друзья!".
- [ ] Repeat for 30, 60 and 90; verify each milestone has its own color and title.
- [ ] Continue social sessions between milestones; verify no milestone banner or owner notification appears.
- [ ] Verify glow and banner clean up after approximately 2.4 seconds, including if a pet is removed during the effect.
- [ ] Verify milestone score/title remains after rejoin and no celebration replays just for loading the profile.
- [ ] Test both display pairs and two players in one server; verify visual effects and notices stay owner/pair scoped.
- [ ] Check banner readability on desktop and mobile at minimum and maximum camera zoom.


## Sprint 4.74 — Shared friendship emotes
- [ ] Display two awake companions with enough mood to socialize; wait for a shared social session and verify a heart appears above both pets at the same time.
- [ ] Verify each heart disappears after approximately 1.6 seconds.
- [ ] Keep the pair together through several social sessions; verify the emote does not repeat inside the 18-second pair cooldown.
- [ ] Verify the emote does not grant extra mood, friendship, coins or XP beyond the existing social-session reward.
- [ ] Test display pairs 1–2 and 3–4, four pets, two players, pet removal during the effect and mobile camera readability.


## Sprint 4.75 — Personality-aware relationships
- [ ] Test Осторожный + Осторожный at bond 0–9; verify approaches are rare but possible at zero bond, so the pair can gradually earn its first bond points without becoming permanently isolated.
- [ ] Test Осторожный + Дружелюбный and Осторожный + Добродушный at bond 0; verify the outgoing pet can initiate and the cautious pet can accept.
- [ ] Raise a cautious pair to 10 bond; verify social approaches become possible without a personality change.
- [ ] Compare Дружелюбный / Добродушный against Спокойный / Мудрый; verify outgoing pets initiate more often over a comparable observation window.
- [ ] Verify increasing bond raises social chance gradually but does not create constant movement or interrupt sleep, shelter, hunger, or energy rules.
- [ ] Verify FriendshipStyle is correct on both display pairs and remains correct after respawn/rejoin.
- [ ] Confirm no additional mood, bond, currency or XP is granted by the new personality modifiers.


## Sprint 4.76 — Friendship chase games
- [ ] With pair bond below 30, complete several social sessions; verify the new chase does not start.
- [ ] With pair bond 30+, complete social sessions; verify an occasional chase begins for both pets at the same time.
- [ ] Verify both companions move around the partner target for approximately 4.5 seconds and publish ChasingFriend while moving.
- [ ] Verify both pets return to normal wandering/social routines when the shared window ends.
- [ ] Put either pet to sleep, remove it from display, or lower its mood/energy below the guard during a chase; verify the behavior stops safely.
- [ ] Verify the same pair cannot trigger another chase inside the 35-second cooldown, and another pair/player has an independent cooldown.
- [ ] Test display pairs 1–2 and 3–4, multiple players, low-end graphics and mobile camera readability.
- [ ] Confirm chase behavior grants no extra mood, bond, currency or XP.


## Sprint 4.77 — Resting beside a friend
- [ ] With bond below 30, put one companion to sleep; verify its partner does not trigger shared rest.
- [ ] With bond 30+, put one companion to sleep at night; verify the awake partner may approach and settle beside it.
- [ ] Repeat during daytime with awake companion energy at 35 or below; verify eligibility.
- [ ] Verify the awake pet stops about 1.8 studs to the side, does not overlap or move the sleeping pet, and holds the calm state for approximately 4.5–6.5 seconds.
- [ ] Verify Behavior and RestingWithFriend attribute appear during the rest and clear afterwards.
- [ ] Wake the sleeping pet during the interaction; verify the shared-rest state ends safely.
- [ ] Let the resting pet fall asleep; verify its own sleep state takes priority and the shared-rest marker clears.
- [ ] Verify the same pair respects its 55-second cooldown, while another pair/player has an independent cooldown.
- [ ] Test both display pairs, multiplayer, low-end graphics and mobile camera readability; confirm no needs or rewards are changed.


## Sprint 4.78 — Personality greetings and reunion moments
- [ ] Trigger a social session with each supported personality; verify the matching icon, color and phrase appears above the correct companion.
- [ ] Pair two different personalities; verify each pet displays its own greeting style at the same time.
- [ ] Verify ordinary greeting bubbles disappear after approximately 2.1 seconds.
- [ ] Trigger another greeting for the same pair within 120 seconds; verify no reunion glow/banner appears.
- [ ] Wait at least 120 seconds after the previous greeting; trigger a new social session and verify both pets receive the reunion greeting and warm glow.
- [ ] Verify reunion visuals clean up after approximately 3.2 seconds and the existing 18-second spam cooldown remains effective.
- [ ] Test both display pairs, all personality styles, pet removal during an effect, two players, and mobile camera readability.
- [ ] Confirm greetings do not grant extra bond, mood, needs, currency or XP.


## Sprint 4.79 — Species-specific friendship discoveries
- [ ] Raise Fox + Turtle bond to 30+; trigger social sessions until Лесные хранители appears.
- [ ] Repeat with Dragon + Owl, EmberFox + MagmaDragon, and AncientStag + RootSprite; verify the correct unique title/icon/color.
- [ ] Reverse each pair's display order; verify the same species interaction is selected.
- [ ] Verify the moment only has a chance to occur at 30+ bond and never occurs for an unsupported species combination.
- [ ] Verify both models receive SpeciesBondMoment / SpeciesBondMomentUntil and that attributes, bubbles and highlights clear after approximately 3.4 seconds.
- [ ] Verify first-time discovery notification appears once and profile.Nest.DiscoveredBondMoments survives leaving/rejoining.
- [ ] Trigger repeated sessions inside 180 seconds; verify no repeated species moment for the same owner/pair/species. Verify a different pair has an independent cooldown.
- [ ] Test both display pairs, multiple players, pet removal during the effect and mobile readability.
- [ ] Confirm species moments grant no additional bond, mood, needs, currency or XP.


## Sprint 4.80 — Friendship discovery journal
- [ ] Open Дневник дружбы with no discoveries; verify 0/4 and 0% progress.
- [ ] Verify all four locked entries show ??? and broad hints only; exact species combinations and titles remain hidden.
- [ ] Discover one species moment, close/reopen the journal, and verify 1/4 and 25% with its correct title/icon/rarity.
- [ ] Discover all four moments and verify 4/4 and 100%.
- [ ] Leave and rejoin; verify discovered entries remain unlocked.
- [ ] Open the journal before profile load completes; verify a friendly error notice and no client error.
- [ ] Verify the close button works, cards scroll, the journal navigation icon is present, and the panel fits phone, tablet and desktop viewports.
- [ ] Open the collector's book then the friendship journal; verify the journal takes focus without overlapping the previous panel.
- [ ] Confirm the client cannot submit or alter discovery IDs; only server-side companion events write the saved discovery table.


## Sprint 4.81 — Visible friendship tiers
- [ ] Pair two active companions and complete a social interaction; verify both show the correct tier, score and progress bar.
- [ ] Verify badge is absent before the first friendship point and appears after the first successful interaction.
- [ ] Check thresholds at 9/10, 29/30, 59/60 and 89/90 points; confirm label, color and progress width.
- [ ] Claim a paired adventure; verify both models update without requiring a re-equip or respawn.
- [ ] Verify the saved relationship score survives leave/rejoin and the badge reconstructs from saved profile data.
- [ ] Verify tiers affect only rare paired-adventure variant odds (8/12/16/20%); base spawn cadence and five-minute pair cooldown remain unchanged.
- [ ] Test with one, two and three active pets on narrow phone, tablet and desktop viewports; confirm overhead labels do not obscure names or needs.


## Sprint 4.82 — Companion gifts
- [ ] Start a shared social session with two active pets; verify a gift can be initiated by either pet over repeated sessions.
- [ ] Verify each of the eight origin egg pools selects only its own biome gift set.
- [ ] Compare personality types; confirm caring/friendly personalities receive their configured chance modifier and independent/proud personalities their reduction.
- [ ] Check friendship chance bands at 9/10, 29/30, 59/60 and 89/90; confirm final chance stays within 2–40%.
- [ ] Confirm special gift base odds follow friendship tiers (4%, 9%, 14%, 20%), then rarity adds 2%, 4%, 7%, 10% or 14% and final chance never exceeds 35%; no currency, XP, materials or combat power are created.
- [ ] Verify receiver mood increases by 5 and giver mood by 2, both capped at 100 and retained by the companion simulation.
- [ ] Verify the same pair cannot trigger another gift within 90 seconds; another pair remains eligible.
- [ ] Verify first-time discoveries persist after leave/rejoin and only discovered gift titles/icons are revealed in the friendship journal.
- [ ] Verify gift cards/glows clean up after 2.8 seconds and do not accumulate in the world.
- [ ] Check the 52-entry friendship journal scrolls smoothly and remains usable on phone, tablet and desktop.


## Sprint 4.82 — Companion gifts
- [ ] Start a shared social session with two active pets; verify a gift can be initiated by either pet over repeated sessions.
- [ ] Verify each of the eight origin egg pools selects only its own biome gift set.
- [ ] Compare personality types; confirm caring/friendly personalities receive their configured chance modifier and independent/proud personalities their reduction.
- [ ] Check friendship chance bands at 9/10, 29/30, 59/60 and 89/90; confirm final chance stays within 2–40%.
- [ ] Confirm special gift roll follows the tier values (4%, 9%, 14%, 20%) and does not create currency, XP, materials or combat power.
- [ ] Verify receiver mood increases by 5 and giver mood by 2, both capped at 100 and retained by the companion simulation.
- [ ] Verify the same pair cannot trigger another gift within 90 seconds; another pair remains eligible.
- [ ] Verify first-time discoveries persist after leave/rejoin and only discovered gift titles/icons are revealed in the friendship journal.
- [ ] Verify gift cards/glows clean up after 2.8 seconds and do not accumulate in the world.
- [ ] Check the 52-entry friendship journal scrolls smoothly and remains usable on phone, tablet and desktop.


## Sprint 4.83 — Emotional gift reactions
- [ ] Trigger ordinary gifts for each personality and verify receiver reaction matches the personality map.
- [ ] Verify giver reacts independently and does not display the receiver's reaction by mistake.
- [ ] Trigger a special gift and verify Amazed receiver + Proud giver reactions, longer duration and gold presentation.
- [ ] Verify Jump/Bounce, Spin, Hug, Shy, Sway/Dream, Proud and Amazed movements are visible without abrupt snapping.
- [ ] During Hug, verify both pets move slightly toward each other, face one another and do not clip through their bodies.
- [ ] Verify overhead reaction phrases fit without covering the friendship badge or gift card for too long.
- [ ] Verify reaction attributes clear after 2.8 seconds (ordinary) / 3.6 seconds (special), and movement returns to normal.
- [ ] Verify a sleeping pet does not perform active movement; reaction resumes/clears safely after the timer.
- [ ] Test with three active pets to ensure one pair's gift reaction does not animate the unrelated third pet.
- [ ] Check readability and movement on phone, tablet and desktop camera distances.


## Sprint 4.84 — Autonomous personality habits
- [ ] Observe all 12 supported personalities and verify their intended idle habit appears.
- [ ] Verify habits last 2.2–4.0 seconds and repeat no more often than the 28–52 second cooldown permits.
- [ ] Verify habits require sufficient mood, energy and hunger; exhausted or hungry pets should prioritize needs.
- [ ] Verify habits do not interrupt sleep, shared rest, social play, chasing, toy use, exploration, treasure searches or gift reactions.
- [ ] Trigger sleep during a habit and verify the habit state clears immediately.
- [ ] Verify overhead Russian captions fit on screen and do not collide with friendship/gift billboards.
- [ ] Verify the third displayed pet can perform its own habit independently of the paired pets.
- [ ] Check movement readability and performance on phone, tablet and desktop.


## Sprint 4.85 — Special friendship memories
- [ ] Raise one pair from 59 to 60 bond and verify Trusted Pact unlocks once with a shared celebration.
- [ ] Raise the same pair from 79 to 80 and verify Unbreakable Promise unlocks once.
- [ ] Raise the same pair from 99 to 100 and verify Friends Forever unlocks once.
- [ ] Verify existing 10, 30 and 90 milestones still trigger as before.
- [ ] Create a second pair and verify its pair-specific memory keys are independent of the first pair.
- [ ] Verify the journal lists three locked entries per bonded pair, with correct threshold hints and hidden titles.
- [ ] Verify discovered pair memories reveal their title/icon and increase the completion count exactly once.
- [ ] Leave/rejoin and verify all unlocked memories persist and are not re-announced.
- [ ] Check banners/glows do not overlap gift/reaction billboards excessively on phone, tablet and desktop.


## Sprint 4.86 — Cooperative companion life
- [ ] Set one bonded pet's mood to 35 or lower while its awake partner has mood >= 45, energy >= 20 and hunger >= 20; verify the partner may approach and comfort it.
- [ ] Verify Caring personality initiates more often than other personalities over repeated controlled trials.
- [ ] Verify receiver gains 6 mood (9 for Caring initiator) and initiator gains 2 only after reaching the friend and completing the interaction.
- [ ] Verify the receiver shows “Друг рядом, всё хорошо ♥” and the initiator shows “Утешает друга ♥” during the interaction.
- [ ] Verify sleep, low energy, hunger, or a missing partner cancels/blocks comfort safely.
- [ ] With a pair at 20+ bond, trigger cooperative exploration and verify the invited pet follows the exact same interest point.
- [ ] Verify the discovery completes whether the leader or invited pet arrives first, but only once, and only when both are within 6 studs.
- [ ] Verify both pets receive +3 mood and the player receives one shared-discovery notice.
- [ ] Verify invitations expire after 18 seconds and do not grant rewards if one pet never arrives.
- [ ] Verify 75-second comfort and 90-second discovery cooldowns prevent spam during the session.
- [ ] Test with three active pets; unrelated third pet must not join or receive rewards.
- [ ] Check captions, movement, billboards and performance on phone, tablet and desktop.


## Sprint 4.87 — Shared ball play
- [ ] Build a pair with at least 10 saved friendship points and observe repeated social sessions; verify ball play can occur but does not trigger every time.
- [ ] Verify Playful/Energetic pairs trigger more often than other personality combinations over controlled repeated trials.
- [ ] Verify the ball appears between the correct two companions, passes alternately five times, displays "ПАС!" and cleans up within 4.5 seconds.
- [ ] Verify the ball has no collision/touch/query behavior and cannot block players, pets, prompts or building placement.
- [ ] Remove either pet during the animation; verify the ball is destroyed without errors.
- [ ] Put either pet to sleep or make it unavailable before social play; verify no ball game starts.
- [ ] Verify the 45-second cooldown is isolated by owner and pair, and is cleared when the owner leaves.
- [ ] Test visibility and label readability at desktop, tablet and mobile camera distances.


## Sprint 4.87 — Hide and seek and cooperative toys
- [ ] With a 20+ bond pair, observe hide and seek near a tree, flower bed or shelter. Confirm randomized roles, seeker delay, arrival and one completion notice.
- [ ] Verify no eligible landmark means no hide-and-seek session; timeout clears both roles.
- [ ] Equip a toy on either display slot and verify both pets approach opposite sides of the same toy, with visible play captions and animation.
- [ ] Verify both games cancel when a pet sleeps, is removed, has low needs or seeks storm shelter.
- [ ] Verify separate 60-second cooldowns, no additional currency/XP and no simultaneous ball game.
- [ ] Verify normal pet behavior and toy state resume after expiry; test multiple owners and mobile readability.


## Sprint 4.87 — Shared treasure hunt
- [ ] Observe a 30+ friendship pair searching a nearby landmark and reaching separate positions.
- [ ] Confirm discovery requires both pets to arrive and produces exactly one notice and golden visual, removed after three seconds.
- [ ] Remove one pet, lower its needs, start sleep or change weather to storm during the event; verify cancellation without discovery.
- [ ] Check 10-second timeout and 90-second cooldown, no additional currency or items, and no overlap with ball, toy or hide-and-seek.
- [ ] Check multiple owners, display refresh, mobile readability and performance.


## Sprint 4.88 — Void Frontier destination foundation
- [ ] At level 74, or without `ancient_temple_boss`, attempt the Ancient Heights portal; confirm Void Frontier travel is denied.
- [ ] In a disposable test profile, set level 75 and complete `ancient_temple_boss`; confirm the Void Frontier portal accepts travel.
- [ ] Walk the full 18-segment causeway in both directions; check gaps, collision, edge safety and respawn.
- [ ] Confirm VoidFrontier is the current biome after arrival and AncientHeights after return.
- [ ] Test two players with different unlock states; one player's unlock must not affect the other.
- [ ] Check beacon/pillar visibility and bridge performance on desktop, tablet and mobile.


## Sprint 4.89 — Void Trial
- [ ] Activate Rift, Echo, Star in order; verify progress reaches 3/3 and the altar accepts the claim.
- [ ] Activate a wrong rune mid-sequence; verify progress resets to 0/3.
- [ ] Claim the altar twice; verify coins, XP and Starshards are granted only once.
- [ ] Leave and rejoin after activating one or two runes; verify the sequence is retained.
- [ ] Test two players independently; one player's runes must not change the other's progress.
- [ ] Try interacting from another biome, while dead, and outside prompt range; verify no progress or rewards.


## Sprint 4.90 — Star Eater boss
- [ ] Complete Void Trial, enter the arena and confirm the boss becomes attackable; without the trial it must reject interaction.
- [ ] Reduce health through 540 → 351 → 162 and confirm phases I, II and III activate at the intended thresholds.
- [ ] Verify Rift Slam, Void Pulse, Starfall and Collapse show the correct danger markers and damage only players who remain in marked zones.
- [ ] Dodge every pattern successfully; verify no damage after leaving the warning zones before impact.
- [ ] Leave and rejoin mid-fight; verify boss health persists for that player.
- [ ] Defeat the boss twice; verify exactly one Star Eater companion, 1,800 coins, 1,200 XP and 12 Starshards are awarded.
- [ ] Test two players with different health/completion states; their boss progress and warning markers must remain isolated.
- [ ] Verify HUD, attack text and arena readability on desktop, tablet and mobile.


## Sprint 4.91 — Void Frontier ecosystem
- [ ] Collect each of the three active Void eggs; verify the hatch inventory stores `VoidEgg` and `VoidFrontier`.
- [ ] Hatch a large controlled sample and confirm the weighted pool uses Riftling 60%, Echo Wisp 30%, Nebula Drake 10%.
- [ ] Fill egg inventory and verify world egg collection is rejected without consuming the world egg.
- [ ] Harvest all six Starshard nodes; verify 1–3 base shards, artifact bonus behavior and the active Star Eater 30% extra-shard chance.
- [ ] Re-harvest a node immediately; verify the remaining cooldown is shown and no extra shards are granted.
- [ ] Leave and rejoin; verify node cooldowns and Starshard totals persist.
- [ ] Test two players on the same node; each player's cooldown and reward must be independent.
- [ ] Verify egg and node placement is clear of the rune puzzle, return portal and boss arena on desktop/tablet/mobile.


## Sprint 4.92 — Void Forge crafting
- [ ] Reach Void Frontier and use the physical forge prompt; confirm the artifact panel opens and shows all three recipes.
- [ ] Craft Void Harvester, Rift Compass and Nebula Charm separately; verify each recipe creates the correct deterministic artifact.
- [ ] Verify exact resource and coin deductions for all three recipes.
- [ ] Attempt each recipe with one missing material and with insufficient coins; verify no resource is deducted.
- [ ] Attempt crafting from another biome, while locked, and while standing away from the forge; verify rejection.
- [ ] Fill the artifact collection to 40; verify crafting is rejected without spending resources.
- [ ] Rejoin and confirm all crafted items remain in the collection.
- [ ] Equip and unequip each item; verify the corresponding gather, research and hatch bonus is reflected by the existing bonus services.
- [ ] Verify existing Ancient Heights random artifact crafting and artifact merging still work.
- [ ] Check forge prompt, recipe controls and scrolling on desktop, tablet and mobile.


## Sprint 4.93 — Voidwalker equipment
- [ ] Open the Void Forge prompt; verify the equipment panel opens and all four recipes appear only in Void Frontier.
- [ ] Craft Riftblade, Voidplate, Starhelm and Nebula Cloak; verify exact resource/coin costs and one-copy-per-item restriction.
- [ ] Attempt crafting with missing materials, insufficient coins, wrong biome and excessive distance; verify no resources are deducted.
- [ ] Equip each item; verify the correct slot, character visual and stat attributes update.
- [ ] Equip a second item in the same slot if test data is injected; verify it replaces the previous item without duplicating visuals.
- [ ] Unequip each slot; verify the model disappears and stats return to the expected baseline.
- [ ] Equip all four pieces; verify the Voidwalker set bonus appears and adds +10% damage, +10% defense and +20 max health.
- [ ] Reset the character; verify visuals, attributes, MaxHealth and WalkSpeed restore from the saved loadout.
- [ ] Attack Void, Ancient Temple and Forgotten Heart bosses; verify gear damage increases boss damage and gear defense reduces incoming attacks.
- [ ] Test raid combat with two players; verify each player's damage/defense stats are applied only to the correct player.
- [ ] Rejoin a published private test server; verify gear collection and equipped slots persist.
- [ ] Check the gear panel, cards, buttons and scrolling on desktop, tablet and mobile.
