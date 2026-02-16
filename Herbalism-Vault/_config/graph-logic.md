# 🧠 Graph Structure Logic

This document explains how the vault is designed to create meaningful connections in Obsidian's graph view.

## Link Architecture

### Primary Hubs (Index Files)

Each index file serves as a central hub connecting to multiple plants:

- **Master Plant Index** → All 30+ plants
- **Medicinal Actions Index** → 6 medicinal categories
- **Month-by-Month Calendar** → 5 monthly files
- **Color & Energetics Index** → Color organization
- **Companion Guilds Index** → 4 guild groups

### Secondary Connections (Category Pages)

Medicinal action pages link back to plants:

**Digestive Support**
- Connects to: Anise, Fennel, Caraway, Dill, Peppermint, etc.
- Creates a network of herbs with shared function

**Nervine & Calming**
- Connects to: Lavender, Lemon Balm, Catnip, Chamomile, etc.
- Shows complementary nervine herbs

**Respiratory Support**
- Connects to: Hyssop, Horehound, Thyme, Oregano, Sage, Echinacea

**Antimicrobial Herbs**
- Connects to: Oregano, Thyme, Rosemary, Echinacea, etc.

**Wound & Circulation**
- Connects to: Lavender, Yarrow, Echinacea, Ginger, Hawthorn

### Tertiary Connections (Companion Guilds)

Companion guilds create synergy clusters:

**Pollinator Guild**
- Borage, Bergamot, Echinacea, Lavender, Yarrow
- All attract beneficial insects

**Mediterranean Dry Guild**
- Thyme, Oregano, Rosemary, Sage, Marjoram
- Share similar growing conditions

**Digestive Guild**
- Anise, Fennel, Caraway, Dill, Cilantro
- All support digestion, similar aromatic family

**Mint Containment Guild**
- Peppermint, Lemon Mint, Lemon Balm, Catnip, Mountain Mint
- Mints that need controlled growth

## Link Patterns

### Bidirectional Links

Each plant file links TO:
```
[[Master Plant Index]]
[[Digestive Support]]  (if applicable)
[[Mediterranean Bed]]  (if in garden design)
[[March]]  (if planted in March)
[[Lavender|Companion Plants]]
```

And each of those files links BACK to the plant.

### Graph Clusters This Creates

**By Function:**
```
Digestive cluster:
- Anise ↔ Fennel ↔ Caraway ↔ Dill ↔ Peppermint
- All link to: Digestive Support (hub)
- Color: See by tags #digestive
```

**By Season:**
```
April cluster:
- Anise, Borage, Dill, Fennel
- All link to: April.md (month file)
- All can be successively sown together
```

**By Garden Design:**
```
Mediterranean Bed cluster:
- Thyme, Oregano, Rosemary, Sage
- All link to: Mediterranean Bed.md
- All share low-water needs
```

**By Color:**
```
Purple cluster:
- Lavender, Bergamot, Hyssop, Echinacea
- All link to: Color & Energetics Index
- Visual theme linking
```

## Graph View Navigation

### What You'll See

**Open graph view:**
1. Master Plant Index is the center hub
2. 30+ plants radiate outward
3. Medicinal action pages form secondary hubs
4. Monthly files create seasonal branches
5. Color tags create visual clusters

### How to Explore

1. **Click Master Plant Index** → See all plants relative to primary index
2. **Filter by tag: #digestive** → See digestive herb network
3. **Click April.md** → See all spring-planted herbs
4. **Click Mediterranean Bed** → See garden design cluster
5. **Click Lavender** → See all connections (actions, months, companions, colors)

## Design Benefits

✅ **Multi-dimensional navigation** - Reach same plant from multiple angles
✅ **Thematic clustering** - Plants naturally group by function/season
✅ **Visual learning** - Graph view reveals connections instantly
✅ **Cross-referencing** - Extract information through linked paths
✅ **Planning tool** - See garden design, planting schedule, medicinal uses in one view

## Tag-Based Filtering

The tagging system (see `_config/tagging-system.md`) creates invisible graph clusters:

- Filter `#digestive` → All digestive herbs visible
- Filter `#low-water` → All drought tolerant plants visible
- Filter `#spring` → All spring activities visible
- Filter `#warming #digestive` → Warming digestive herbs only

## Obsidian Plugins That Enhance This

**Recommended:**
- **Dataview** - Create dynamic plant tables
- **Graph Analysis** - Quantify cluster strength
- **Smart Typography** - Better markdown rendering
- **Tag Wrangler** - Manage tags visually

---

**The goal:** A living herbal intelligence map where each plant is a node in a larger knowledge network.

