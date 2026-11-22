# NEST RAIDERS — Creator Store Asset Catalog

This is a shortlist, not an automatic import. Insert assets manually through Roblox Studio Toolbox, inspect the imported hierarchy, and record the exact imported version before using it in a published place.

## Approved candidates

Roblox's official Creator Store announcement for the Synty partnership states that the released Synty packs are completely free to use in anything you create on Roblox. The matching Creator Store listings currently show Get Model. Still inspect each imported model and record the actual version used.

| Asset | Creator | Asset ID | Intended use | Status |
|---|---|---:|---|---|
| [Synty Nature Pack](https://create.roblox.com/store/asset/6933438443/Synty-Nature-Pack) | Roblox | 6933438443 | Starter Island foliage, trees, bushes, rocks, flowers, outdoor props | Candidate — import and inspect |
| [Synty City Pack](https://create.roblox.com/store/asset/6933556508/Synty-City-Pack) | Roblox | 6933556508 | Ancient Village buildings, market props, lamps, furniture | Candidate — import and inspect |
| [Synty Dungeon Pack: Cave & Castle Interiors](https://create.roblox.com/store/asset/6934021345/Synty-Dungeon-Pack-Cave-Castle-Interiors) | Roblox | 6934021345 | Hidden caves, dungeon rooms, ancient ruins interiors | Candidate — import and inspect |

Sources: [Roblox Creator Store Synty Nature Pack](https://create.roblox.com/marketplace/asset/6933438443/Synty-Nature-Pack) · [Roblox DevForum official Synty pack announcement](https://devforum.roblox.com/t/free-synty-asset-packs-released-in-the-marketplace/1283755/).

The Nature Pack listing reports about 200 MeshParts and 108,816 triangles. Do not place the entire pack indiscriminately: select a small consistent subset, reuse approved assets, and profile mobile performance.

## Not approved yet
Any other Creator Store model remains unapproved until its current price, creator, usage terms, dependencies, and scripts are inspected. "Free" or "Get Model" is not sufficient evidence by itself unless the applicable permission is clear.

## Import procedure
1. Open Roblox Studio and the NEST RAIDERS place.
2. Open Toolbox → Creator Store and search for the exact asset title or ID above.
3. Insert into a separate staging folder, never directly into the live map.
4. Inspect every descendant and remove unexpected Script, LocalScript, and ModuleScript instances.
5. Check for external package links, remote calls, hidden parts, excessive particle emitters, and unexpected sounds.
6. Check scale, pivot, collision, texture resolution, mesh count, and mobile performance.
7. Move only the approved subset into the production map.
8. Record the actual imported asset version and any modifications here.

## Visual consistency lock
Bright, friendly stylized low-poly / chunky forms; saturated but controlled colors; soft readable lighting; consistent tree scale; clear paths and silhouettes. Do not mix realistic assets, classic blocky props, and high-detail PBR packs in the same visible area.
