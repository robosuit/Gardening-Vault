$ErrorActionPreference = "Stop"

$root = "c:\Users\Anubis\GitHub\Obsidian\Gardening-Vault\Herbalism-Vault"
$dir = Join-Path $root "01_Plants"

function Make-Note(
  [string]$File,
  [string]$Name,
  [string]$Type,
  [string]$Family,
  [string]$LifeCycle,
  [string]$Sun,
  [string]$Zone,
  [string]$Actions,
  [string]$Tags,
  [string]$Growing
) {
  $path = Join-Path $dir $File
  if (Test-Path $path) { return }

  $md = @"
---
Type: $Type
Family: $Family
Life Cycle: $LifeCycle
Height: Varies by cultivar/site
Spread: Varies by cultivar/site
Sun: $Sun
Soil: Well-drained, organic matter as needed
Water: Moderate unless noted
Zone: $Zone
Start Month: Spring (Zone 7B)
Harvest: Seasonal by plant part
Primary Actions: $Actions
Energetics: Context dependent
Tags: $Tags
---

# $Name

## Growing Conditions
$Growing

## Planting Calendar (Zone 7B)
Start in spring after frost risk unless this species is typically fall-planted. For tender species, use containers and move indoors before first frost.

## Size and Spacing
Follow cultivar-specific spacing; most herbs perform best with airflow and no overcrowding.

## Medicinal Actions
- $Actions
- See 02_Apothecary notes for formula context and contraindications.

## Companion Plants
- [[Calendula]]
- [[Yarrow]]
- [[Chamomile]]

## Avoid
- Waterlogged soil
- Poor airflow

## Preparations
- Tea or decoction (plant-part dependent)
- Tincture
- Infused oil/salve (primarily for topical herbs)

## Ecological Role
Supports biodiversity through nectar, habitat, and/or soil function depending on species.
"@

  Set-Content -Path $path -Value $md -Encoding utf8
}

$rows = @(
  "Anise.md|Anise|Herb|Apiaceae|Annual|Full sun|6-8|Carminative, Expectorant|#digestive #respiratory #annual #warming|Direct sow preferred; dislikes root disturbance.",
  "Bergamot.md|Bergamot|Herb|Lamiaceae|Perennial|Full-partial sun|4-9|Antimicrobial, Nervine, Diaphoretic|#respiratory #immune #perennial #pollinators|Keep airflow high to reduce mildew.",
  "Caraway.md|Caraway|Herb|Apiaceae|Biennial|Full sun|4-8|Carminative, Antispasmodic|#digestive #warming|Biennial; harvest seed in second year.",
  "Chamomile.md|Chamomile|Herb|Asteraceae|Annual/short-lived perennial|Full-partial sun|3-9|Nervine, Digestive, Anti-inflammatory|#nervine #digestive #cooling|Surface sow and harvest flowers often.",
  "Cilantro.md|Cilantro|Herb|Apiaceae|Annual|Full-partial sun|2-11|Digestive, Carminative|#digestive #cooling #annual|Cool-season performer; bolts in heat.",
  "Dill.md|Dill|Herb|Apiaceae|Annual|Full sun|2-11|Carminative, Antispasmodic|#digestive #annual|Direct sow for best root development.",
  "Thai Basil.md|Thai Basil|Herb|Lamiaceae|Annual|Full sun|6-8 (annual)|Digestive, Aromatic|#digestive #annual #warming|Warm-season basil; transplant after true heat arrives.",
  "Italian Basil.md|Italian Basil|Herb|Lamiaceae|Annual|Full sun|6-8 (annual)|Digestive, Aromatic|#digestive #annual #warming|Pinch frequently to delay flowering.",
  "Purple Basil.md|Purple Basil|Herb|Lamiaceae|Annual|Full sun|6-8 (annual)|Digestive, Antioxidant|#digestive #annual #purple|Needs sun for strong leaf color.",
  "Summer Savory.md|Summer Savory|Herb|Lamiaceae|Annual|Full sun|5-10|Carminative, Antimicrobial|#digestive #antimicrobial #annual|Prefers lean soil and regular tip pinching.",
  "Catnip.md|Catnip|Herb|Lamiaceae|Perennial|Full-partial sun|3-9|Nervine, Antispasmodic|#nervine #perennial #cooling|Cut back after bloom for regrowth.",
  "Chives.md|Chives|Herb|Amaryllidaceae|Perennial|Full-partial sun|3-9|Digestive, Circulatory support|#digestive #perennial|Divide clumps every few years.",
  "Dandelion.md|Dandelion|Herb|Asteraceae|Perennial|Full-partial sun|3-10|Bitter tonic, Liver support|#digestive #detox #perennial|Deep taproot and strong self-seeding.",
  "Echinacea.md|Echinacea|Herb|Asteraceae|Perennial|Full sun|3-9|Immune modulating, Lymphatic|#immune #antimicrobial #perennial|Best root harvest from year 2+.",
  "Fennel.md|Fennel|Herb|Apiaceae|Perennial/annual grown|Full sun|6-9|Carminative, Expectorant|#digestive #respiratory #warming|Isolate from close Apiaceae relatives if seed purity matters.",
  "Horehound.md|Horehound|Herb|Lamiaceae|Perennial|Full sun|3-9|Expectorant, Bitter tonic|#respiratory #digestive #perennial|Thrives in drier low-fertility soils.",
  "Hyssop.md|Hyssop|Herb|Lamiaceae|Perennial|Full sun|4-9|Expectorant, Antimicrobial|#respiratory #antimicrobial #perennial|Mediterranean-style drainage is ideal.",
  "Lemon Balm.md|Lemon Balm|Herb|Lamiaceae|Perennial|Full-partial sun|4-9|Nervine, Antiviral|#nervine #immune #perennial|Can spread; cut before seed set if needed.",
  "Lovage.md|Lovage|Herb|Apiaceae|Perennial|Full-partial sun|4-8|Digestive, Diuretic|#digestive #perennial|Give permanent deep-soil location.",
  "Marjoram.md|Marjoram|Herb|Lamiaceae|Tender perennial|Full sun|6-9|Digestive, Nervine|#digestive #nervine #warming|Needs drainage and protection in colder winters.",
  "Mountain Mint.md|Mountain Mint|Herb|Lamiaceae|Perennial|Full-partial sun|4-8|Digestive, Diaphoretic|#digestive #respiratory #perennial #pollinators|Native pollinator powerhouse.",
  "Lemon Mint.md|Lemon Mint|Herb|Lamiaceae|Perennial|Full-partial sun|4-9|Nervine, Digestive|#nervine #digestive #perennial|Often grouped with monarda types.",
  "Rosemary.md|Rosemary|Herb|Lamiaceae|Perennial shrub|Full sun|7-10 (protect in 6-7)|Circulatory, Cognitive, Antimicrobial|#circulatory #antimicrobial #perennial #warming|Needs sharp drainage and winter protection in cold spots.",
  "Sage.md|Sage|Herb|Lamiaceae|Perennial|Full sun|4-8|Antimicrobial, Astringent, Digestive|#antimicrobial #digestive #perennial|Keep soil on the dry side.",
  "Thyme.md|Thyme|Herb|Lamiaceae|Perennial|Full sun|5-9|Antimicrobial, Expectorant|#respiratory #antimicrobial #perennial|Avoid overwatering.",
  "Oregano.md|Oregano|Herb|Lamiaceae|Perennial|Full sun|5-10|Antimicrobial, Digestive|#antimicrobial #digestive #perennial|Cut back after bloom to refresh growth.",
  "White Yarrow.md|White Yarrow|Herb|Asteraceae|Perennial|Full sun|3-9|Diaphoretic, Wound support|#wound #circulatory #perennial #white|Drought tolerant once established.",
  "Calendula.md|Calendula|Herb|Asteraceae|Annual|Full sun|2-11|Vulnerary, Lymphatic, Anti-inflammatory|#wound #immune #annual #yellow|Deadhead to keep flowers coming.",
  "Comfrey.md|Comfrey|Herb|Boraginaceae|Perennial|Full-partial sun|3-9|Vulnerary, Tissue support|#wound #perennial|Place permanently; roots resprout.",
  "Elderberry.md|Elderberry|Shrub|Adoxaceae|Perennial|Full-partial sun|3-8|Antiviral, Immune support|#immune #respiratory #perennial|Plant two for stronger berry set.",
  "Feverfew.md|Feverfew|Herb|Asteraceae|Perennial|Full-partial sun|5-9|Migraine support, Anti-inflammatory|#nervine #perennial|Short-lived; may self-seed.",
  "Garlic.md|Garlic|Medicinal bulb|Amaryllidaceae|Annual|Full sun|3-8|Antimicrobial, Immune, Circulatory|#antimicrobial #immune #annual|Plant in fall for best bulbs.",
  "Mullein.md|Mullein|Herb|Scrophulariaceae|Biennial|Full sun|3-9|Demulcent expectorant|#respiratory #biennial|Rosette first year, flower spike second year.",
  "St. John's Wort.md|St. John's Wort|Herb|Hypericaceae|Perennial|Full sun|5-9|Nervine, Mood support, Vulnerary|#nervine #wound #perennial|Review drug-interaction profile before use.",
  "Valerian.md|Valerian|Herb|Caprifoliaceae|Perennial|Full-partial sun|4-9|Sedative nervine, Antispasmodic|#nervine #sleep #perennial|Harvest mature roots in fall.",
  "Marshmallow.md|Marshmallow|Herb|Malvaceae|Perennial|Full-partial sun|3-8|Demulcent, Anti-inflammatory|#digestive #respiratory #moistening #perennial|Prefers consistent moisture.",
  "Hawthorn.md|Hawthorn|Shrub/tree|Rosaceae|Perennial|Full-partial sun|4-8|Cardiovascular tonic|#circulatory #perennial|Long-lived woody medicine.",
  "Yarrow.md|Yarrow|Herb|Asteraceae|Perennial|Full sun|3-9|Diaphoretic, Vulnerary, Circulatory|#wound #circulatory #perennial|Excellent in dry sunny beds.",
  "Aloe.md|Aloe|Succulent|Asphodelaceae|Perennial (container)|Full sun to bright indirect|10-12 (container in 6-8)|Vulnerary, Skin soothing|#wound #cooling #container|Grow in containers and bring indoors before frost.",
  "Arnica.md|Arnica|Herb|Asteraceae|Perennial|Full-partial sun|4-8|Topical anti-inflammatory, Vulnerary|#wound #cooling #perennial|Best used for external preparations.",
  "Ashwagandha.md|Ashwagandha|Herb|Solanaceae|Annual in 6-8|Full sun|8-11 (annual in 6-7)|Adaptogen, Nervine|#nervine #hormonal #warming #annual|Treat as warm-season annual in colder zones.",
  "Astragalus.md|Astragalus|Herb|Fabaceae|Perennial|Full sun|5-9|Adaptogen, Immune tonic|#immune #perennial|Harvest roots from mature plants (year 3+).",
  "Black Cohosh.md|Black Cohosh|Herb|Ranunculaceae|Perennial|Partial shade|3-8|Hormonal support, Antispasmodic|#hormonal #perennial #partial-shade|Woodland species; prefers moisture and shade.",
  "Blue Vervain.md|Blue Vervain|Herb|Verbenaceae|Perennial|Full-partial sun|3-8|Nervine, Bitter tonic|#nervine #digestive #perennial|Performs best in moist soils.",
  "Burdock.md|Burdock|Herb|Asteraceae|Biennial|Full-partial sun|2-10|Alterative, Liver support|#detox #digestive #biennial|Harvest first-year roots for best texture and potency.",
  "Poppy.md|Poppy|Herb|Papaveraceae|Annual|Full sun|3-9|Soothing, Mild nervine|#nervine #annual|Direct sow only; choose legal ornamental/culinary species.",
  "Capsicum.md|Capsicum|Herb/vegetable|Solanaceae|Annual|Full sun|6-8 (annual)|Circulatory stimulant, Topical analgesic|#circulatory #warming #annual|Start indoors early and transplant into heat.",
  "Cardamom.md|Cardamom|Herb (container)|Zingiberaceae|Perennial tropical|Partial shade|10-12 (container in 6-8)|Carminative, Warming digestive|#digestive #warming #container|Container-only in zones 6-8.",
  "Clove.md|Clove|Tree (container)|Myrtaceae|Perennial tropical|Full-partial sun|10-12 (container/greenhouse in 6-8)|Analgesic, Antimicrobial|#antimicrobial #warming #container|Requires greenhouse-style warmth in cold climates.",
  "Eleuthero.md|Eleuthero|Shrub|Araliaceae|Perennial|Partial shade|3-8|Adaptogen, Stamina tonic|#immune #perennial #partial-shade|Slow woody adaptogen for cooler climates.",
  "Eucalyptus.md|Eucalyptus|Tree/herb|Myrtaceae|Perennial (often annual-grown in cold zones)|Full sun|8-11 (annual/container in 6-7)|Expectorant, Antimicrobial|#respiratory #antimicrobial #container|Use hardy species or grow as annual/cut foliage plant.",
  "Geranium.md|Geranium|Herb (tender)|Geraniaceae|Tender perennial|Full-partial sun|9-11 (container/annual in 6-8)|Astringent, Mild antimicrobial|#wound #container|Overwinter indoors in cold zones.",
  "Ginger.md|Ginger|Rhizome herb|Zingiberaceae|Tender perennial|Partial shade|8-11 (annual/container in 6-7)|Digestive stimulant, Anti-nausea|#digestive #warming #container|Pre-sprout indoors for longer season.",
  "Ginkgo.md|Ginkgo|Tree|Ginkgoaceae|Perennial tree|Full sun|3-9|Circulatory, Cognitive support|#circulatory #perennial|Long-term tree crop; medicinal leaf from mature trees.",
  "Ginseng.md|Ginseng|Woodland herb|Araliaceae|Perennial|Shade|3-8|Adaptogen, Energy tonic|#nervine #immune #perennial #partial-shade|Needs true woodland conditions and patience.",
  "Goldenseal.md|Goldenseal|Woodland herb|Ranunculaceae|Perennial|Partial-full shade|3-8|Antimicrobial, Bitter tonic|#antimicrobial #perennial #partial-shade|Prioritize cultivated sources over wild harvest.",
  "Gotu Kola.md|Gotu Kola|Herb|Apiaceae|Perennial warm-zone/annual cold-zone|Partial shade|7-11 (container annual in 6)|Nervine, Tissue support|#nervine #wound #container|Needs constant moisture and warmth.",
  "Hibiscus.md|Hibiscus|Herb/shrub|Malvaceae|Annual or perennial by species|Full sun|5-11 (species dependent)|Cooling, Cardiovascular support|#circulatory #cooling|Roselle is annual-friendly in zones 6-8.",
  "Holy Basil.md|Holy Basil|Herb|Lamiaceae|Annual in 6-8|Full sun|10-11 (annual in 6-8)|Adaptogen, Nervine, Respiratory|#nervine #immune #annual|Warm-season basil; harvest before frost.",
  "Horse Chestnut.md|Horse Chestnut|Tree|Sapindaceae|Perennial tree|Full-partial sun|3-8|Venotonic, Anti-inflammatory|#circulatory #perennial|Large tree; medicinal use requires proper processing.",
  "Horseradish.md|Horseradish|Root herb|Brassicaceae|Perennial|Full-partial sun|3-8|Expectorant, Antimicrobial|#respiratory #antimicrobial #perennial|Vigorous spreader; site with containment in mind.",
  "Juniper.md|Juniper|Shrub/tree|Cupressaceae|Perennial|Full sun|2-9|Urinary support, Digestive aromatic|#digestive #detox #perennial|Requires sharp drainage and sun.",
  "Lady's Mantle.md|Lady's Mantle|Herb|Rosaceae|Perennial|Partial-full sun|3-8|Astringent, Women's tonic|#hormonal #wound #perennial|Likes cooler roots and moderate moisture.",
  "Licorice.md|Licorice|Herb|Fabaceae|Perennial|Full sun|7-10 (6 with protection)|Demulcent, Expectorant|#digestive #respiratory #perennial|Borderline in zone 6; protect roots heavily.",
  "Linden.md|Linden|Tree|Malvaceae|Perennial tree|Full-partial sun|3-8|Nervine, Diaphoretic|#nervine #respiratory #perennial|Fragrant summer blossoms for tea.",
  "Matcha (Tea Plant).md|Matcha (Tea Plant)|Shrub|Theaceae|Perennial|Partial shade|7-9 (protected in 6)|Stimulant, Antioxidant|#nervine #perennial #partial-shade|Needs acidic soil and winter shelter in colder areas.",
  "Milk Thistle.md|Milk Thistle|Herb|Asteraceae|Biennial/annual|Full sun|5-9|Hepatic support, Bitter tonic|#digestive #detox|Can self-seed aggressively; manage heads.",
  "Mimosa.md|Mimosa|Tree|Fabaceae|Perennial tree|Full sun|6-9|Nervine, Mood support|#nervine #perennial|Check local invasive guidance before planting.",
  "Monarda.md|Monarda|Herb|Lamiaceae|Perennial|Full-partial sun|4-9|Antimicrobial, Diaphoretic, Nervine|#respiratory #immune #perennial|Same core group as bergamot.",
  "Motherwort.md|Motherwort|Herb|Lamiaceae|Perennial|Full-partial sun|4-8|Nervine, Cardiotonic|#nervine #circulatory #hormonal #perennial|Self-seeds readily; deadhead if needed.",
  "Nasturtium.md|Nasturtium|Herb|Tropaeolaceae|Annual|Full-partial sun|2-11|Antimicrobial, Expectorant|#antimicrobial #respiratory #annual|Prefers leaner soil for better flowering.",
  "Oats.md|Oats|Herb/grain|Poaceae|Annual|Full sun|3-10|Nervine trophorestorative, Nutritive|#nervine #annual #moistening|Grow for milky oat tops and oatstraw.",
  "Onion.md|Onion|Medicinal bulb|Amaryllidaceae|Biennial grown annual|Full sun|5-10|Antimicrobial, Expectorant|#antimicrobial #annual|Plant early spring sets or starts.",
  "Parsley.md|Parsley|Herb|Apiaceae|Biennial grown annual|Full-partial sun|4-9|Nutritive, Diuretic, Digestive|#digestive #annual|Slow germination; soak seed pre-sow.",
  "Passionflower.md|Passionflower|Vine herb|Passifloraceae|Perennial vine|Full-partial sun|5-9|Nervine, Antispasmodic|#nervine #sleep #perennial|Needs trellis and winter mulch at cold edge.",
  "Peach.md|Peach|Tree|Rosaceae|Perennial tree|Full sun|5-8|Nutritive fruit, Respiratory leaf traditions|#digestive #perennial|Use disease-resistant cultivars and prune annually.",
  "Pennyroyal.md|Pennyroyal|Herb|Lamiaceae|Perennial|Full-partial sun|6-9|Digestive aromatic, Insect-repellent|#digestive #perennial|Use caution with internal dosing; avoid in pregnancy.",
  "Pine.md|Pine|Tree|Pinaceae|Perennial tree|Full sun|3-8 (species dependent)|Respiratory, Antimicrobial|#respiratory #antimicrobial #perennial|Choose species suited to local soils and space.",
  "Plantain.md|Plantain|Herb|Plantaginaceae|Perennial|Full-partial sun|3-9|Vulnerary, Demulcent|#wound #digestive #perennial|Excellent first-aid herb for topical use.",
  "Raspberry.md|Raspberry|Shrub|Rosaceae|Perennial canes|Full-partial sun|3-9|Astringent, Nutritive|#hormonal #digestive #perennial|Prune by cane type for productivity.",
  "Rhodiola.md|Rhodiola|Herb|Crassulaceae|Perennial|Full sun|2-7 (marginal in 8)|Adaptogen, Cognitive support|#nervine #perennial|Best in cooler zone 6-7 climates.",
  "Rose.md|Rose|Shrub|Rosaceae|Perennial|Full sun|4-9|Astringent, Nervine|#nervine #wound #perennial|Choose disease-resistant varieties for low-input care.",
  "Rose Hips.md|Rose Hips|Shrub fruit|Rosaceae|Perennial|Full sun|4-9|Nutritive, Immune support|#immune #digestive #perennial|Allow selected flowers to set hips for fall harvest.",
  "Self-Heal.md|Self-Heal|Herb|Lamiaceae|Perennial|Full-partial sun|4-9|Vulnerary, Immune support|#wound #immune #perennial|Useful low-growing meadow/edge medicine.",
  "Shatavari.md|Shatavari|Herb|Asparagaceae|Perennial warm-zone/annual cold-zone|Partial-full sun|8-11 (container/annual in 6-7)|Demulcent, Reproductive tonic|#hormonal #moistening #container|Best as container crop in colder zones.",
  "Skullcap.md|Skullcap|Herb|Lamiaceae|Perennial|Full-partial sun|3-8|Nervine, Antispasmodic|#nervine #perennial|Prefers steady moisture and cooler roots.",
  "Slippery Elm.md|Slippery Elm|Tree|Ulmaceae|Perennial tree|Full-partial sun|3-9|Demulcent, GI/respiratory soothing|#digestive #respiratory #perennial|Use ethically sourced cultivated bark.",
  "Stinging Nettle.md|Stinging Nettle|Herb|Urticaceae|Perennial|Full-partial sun|3-10|Nutritive, Anti-inflammatory|#immune #detox #perennial|Harvest with gloves; strong spring mineral herb.",
  "Tea Tree.md|Tea Tree|Shrub (container)|Myrtaceae|Perennial tropical|Full sun|9-11 (container in 6-8)|Topical antimicrobial|#antimicrobial #container|Overwinter indoors; external use focus.",
  "Turmeric.md|Turmeric|Rhizome herb|Zingiberaceae|Tender perennial|Partial shade|8-11 (annual/container in 6-7)|Anti-inflammatory, Digestive|#digestive #warming #container|Start indoors early like ginger.",
  "Uva Ursi.md|Uva Ursi|Shrub|Ericaceae|Perennial evergreen|Full-partial sun|2-7 (not ideal in most 8)|Urinary support, Astringent|#detox #perennial|Best in cooler acidic sites with sharp drainage.",
  "Willow.md|Willow|Tree/shrub|Salicaceae|Perennial|Full sun|4-9|Analgesic, Anti-inflammatory|#wound #circulatory #perennial|Prefers moisture and grows quickly from cuttings.",
  "Wintergreen.md|Wintergreen|Groundcover herb|Ericaceae|Perennial|Partial shade|3-7 (marginal in 8)|Topical analgesic, Aromatic|#wound #cooling #perennial|Needs acidic woodland conditions.",
  "Witch Hazel.md|Witch Hazel|Shrub/tree|Hamamelidaceae|Perennial|Full-partial sun|3-8|Astringent, Anti-inflammatory|#wound #circulatory #perennial|Native shrub/tree with strong topical use tradition.",
  "Woodruff.md|Woodruff|Groundcover herb|Rubiaceae|Perennial|Shade-partial sun|4-8|Nervine, Mild antispasmodic|#nervine #perennial #ground-cover|Spreads well in moist shade.",
  "Flaxseed.md|Flaxseed|Herb/crop|Linaceae|Annual|Full sun|2-9|Demulcent, Nutritive|#digestive #moistening #annual|Direct sow in cool spring weather.",
  "Wild Yam.md|Wild Yam|Vine herb|Dioscoreaceae|Perennial|Partial shade|4-8|Antispasmodic, Hormonal support traditions|#hormonal #digestive #perennial|Woodland-edge vine needing support.",
  "Lemon.md|Lemon|Tree (container)|Rutaceae|Perennial citrus|Full sun|9-11 (container in 6-8)|Digestive, Immune nutritive|#digestive #immune #container|Grow dwarf citrus in pots and overwinter indoors.",
  "Marigold.md|Marigold|Herb/flower|Asteraceae|Annual|Full sun|2-11|Mild anti-inflammatory, Topical support|#wound #annual #yellow|Companion-friendly annual with long bloom period.",
  "Tithonia.md|Tithonia|Herb/flower|Asteraceae|Annual|Full sun|2-11|Pollinator support, Mild traditional use|#annual #pollinators|Heat-loving annual for biomass and pollinator support."
)

foreach ($row in $rows) {
  $p = $row -split "\|"
  Make-Note $p[0] $p[1] $p[2] $p[3] $p[4] $p[5] $p[6] $p[7] $p[8] $p[9]
}

Write-Output "Generated initial herb note set."

