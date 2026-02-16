# 🏷️ Tag Architecture

This document defines the tagging system used throughout the vault for graph filtering and organization.

## Medicinal Tags

Use these tags to categorize herbs by their primary medicinal actions:

- `#digestive` - Supports digestion, relieves gas/bloating
- `#nervine` - Calms, relaxes, supports nervous system
- `#respiratory` - Supports lung function, expectorant
- `#antimicrobial` - Antibacterial, antiviral, antifungal
- `#wound` - Wound healing, tissue repair
- `#immune` - Strengthens immune response
- `#circulatory` - Supports blood flow and circulation
- `#hormonal` - Supports endocrine balance
- `#detox` - Supports body's natural cleansing

## Growth Tags

Use these tags to organize plants by growing characteristics:

- `#annual` - Completes lifecycle in one year
- `#perennial` - Returns year after year
- `#sun` - Requires full sun (6+ hours)
- `#partial-shade` - Tolerates some shade
- `#low-water` - Drought tolerant
- `#moist-soil` - Prefers consistent moisture
- `#container` - Works well in pots
- `#ground-cover` - Good as border plant

## Color Tags

Use these tags to organize by flower/leaf color:

- `#purple` - Purple flowers or foliage
- `#yellow` - Yellow flowers or foliage
- `#white` - White flowers or foliage
- `#pink` - Pink or rose flowers
- `#green` - Green foliage dominant
- `#red` - Red flowers or foliage

## Energetic Tags

Based on Traditional Chinese Medicine & Herbalism:

- `#warming` - Increases body warmth, circulation
- `#cooling` - Reduces heat, inflammation
- `#drying` - Reduces moisture, fluids
- `#moistening` - Adds hydration

## Season Tags

For planting & harvest organization:

- `#spring` - Spring activities
- `#summer` - Summer activities
- `#fall` - Fall/autumn activities
- `#winter` - Winter activities (year-round care)

## Life Cycle Tags

- `#seed-start` - Can be started indoors
- `#direct-sow` - Direct seed into ground
- `#transplant` - Plant as seedling
- `#self-seeding` - Reseeds itself

## Example Plant Tag Usage

A plant file might have:
```
Tags: #digestive #perennial #sun #low-water #cooling #purple #spring
```

This allows filtering for:
- All digestive herbs
- All perennials
- All low-water plants
- All cooling herbs
- All purple flowers
- All spring planting

---

## How to Search by Tag in Obsidian

1. Click "Open local graph" (bottom left)
2. Use filter: `tag:#digestive`
3. See all connected herbs in that medicinal action cluster

---

**Pro Tip:** Combining tags reveals powerful connections:
- `#digestive #warming` = warming digestive herbs
- `#nervine #cooling` = cooling nervine herbs
- `#low-water #sun` = herbs for dry, sunny spots
