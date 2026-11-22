# NEST RAIDERS — Creator Store Asset Catalog

This is a shortlist, not an automatic import. Insert assets manually through Roblox Studio Toolbox, inspect the imported hierarchy, and record the exact imported version before using it in a published place.

## Approved candidate

| Asset | Creator | Asset ID | Cost / permission evidence | Intended use | Status |
|---|---|---:|---|---|---|
| [Synty Nature Pack](https://create.roblox.com/store/asset/6933438443/Synty-Nature-Pack) | Roblox | 6933438443 | Creator Store listing says "Get Model" and describes Synty assets as officially licensed for use in any Roblox game | Starter Island foliage, trees, bushes, rocks, flowers, outdoor props | Candidate — import and inspect in Studio |

The listing describes approximately 200 MeshParts and 108,816 triangles. Do not place the entire pack indiscriminately: select a small consistent subset, use shared assets across distant areas, and profile mobile performance.

## Not approved yet
Any other Creator Store model remains unapproved until its current price, creator, usage terms, dependencies, and scripts are inspected. "Free" or "Get Model" is not by itself sufficient evidence of commercial-use permission.

## Import procedure
1. Open Roblox Studio and the NEST RAIDERS place.
2. Open Toolbox → Creator Store and search for the exact asset title or ID above.
3. Insert into a separate staging folder, never directly into the live map.
4. Inspect every descendant and remove unexpected Script, LocalScript, and ModuleScript instances.
5. Check for external package links, remote calls, hidden parts, excessive particle emitters, and unexpected sounds.
6. Confirm collision, scale, pivot, textures, mesh count, and mobile rendering.
7. Move only the approved subset into the production map.
8. Record the actual imported asset version and any modifications here.

## Visual consistency lock
Bright stylized low-poly / chunky forms; saturated but controlled colors; soft readable lighting; consistent tree scale; clear paths and silhouettes. Do not mix realistic foliage, classic blocky props, and high-detail PBR packs in the same visible area.
