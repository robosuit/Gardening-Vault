$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$herbDir = Join-Path $projectRoot "Herbalism-Vault\01_Plants"
$herbIndexDir = Join-Path $projectRoot "Herbalism-Vault\00_Indexes"
$vegDir = Join-Path $projectRoot "Vegetable-Vault\01_Crops"
$vegIndexDir = Join-Path $projectRoot "Vegetable-Vault\00_Indexes"
$wildRoot = Join-Path $projectRoot "Wildflower-Vault"
$wildDir = Join-Path $wildRoot "01_Plants"
$wildIndexDir = Join-Path $wildRoot "00_Indexes"
$wildMixDir = Join-Path $wildRoot "02_Mixes"
$wildConfigDir = Join-Path $wildRoot "_config"
$quickGuideDir = Join-Path $projectRoot "Quick Start Guides"
$masterIndexDir = Join-Path $projectRoot "Master-Indexes"

function Get-DocParts {
  param([string]$Raw)
  $m = [regex]::Match($Raw, "(?s)^---\r?\n(.*?)\r?\n---\r?\n?(.*)$")
  if (-not $m.Success) {
    return @{
      Front = [ordered]@{}
      Body = $Raw
    }
  }
  $front = [ordered]@{}
  foreach ($line in ($m.Groups[1].Value -split "\r?\n")) {
    if ($line -match "^\s*([^:]+):\s*(.*)$") {
      $front[$matches[1].Trim()] = $matches[2].Trim()
    }
  }
  return @{
    Front = $front
    Body = $m.Groups[2].Value
  }
}

function Write-Doc {
  param(
    [string]$Path,
    [hashtable]$Front,
    [string]$Body,
    [string[]]$Order
  )
  $lines = @("---")
  $seen = @{}
  foreach ($k in $Order) {
    if ($Front.Contains($k)) {
      $lines += "${k}: $($Front[$k])"
      $seen[$k] = $true
    }
  }
  foreach ($k in $Front.Keys) {
    if (-not $seen.ContainsKey($k)) {
      $lines += "${k}: $($Front[$k])"
    }
  }
  $lines += "---"
  $content = ($lines -join "`r`n") + "`r`n`r`n" + $Body.TrimStart("`r", "`n")
  Set-Content -Path $Path -Value $content -Encoding utf8
}

function Get-LowDays {
  param([string]$Range)
  $m = [regex]::Match($Range, "(\d+)")
  if ($m.Success) { return [int]$m.Groups[1].Value }
  return 999
}

function Get-HighDays {
  param([string]$Range)
  $m = [regex]::Matches($Range, "(\d+)")
  if ($m.Count -eq 0) { return 999 }
  if ($m.Count -eq 1) { return [int]$m[0].Groups[1].Value }
  return [int]$m[$m.Count - 1].Groups[1].Value
}

function Get-Tier {
  param([string]$Range)
  $n = Get-LowDays $Range
  if ($n -le 45) { return "Elite" }
  if ($n -le 60) { return "Fast" }
  if ($n -le 90) { return "Moderate" }
  return "Slow"
}

function Add-Tag {
  param(
    [string]$TagLine,
    [string]$Tag,
    [switch]$HashStyle
  )
  $tagToAdd = if ($HashStyle) { "#$Tag" } else { $Tag }
  if ([string]::IsNullOrWhiteSpace($TagLine)) { return $tagToAdd }

  $isHash = $TagLine -match "#"
  $tokens = if ($isHash) {
    $TagLine -split "\s+" | Where-Object { $_.Trim() -ne "" }
  } else {
    $TagLine -split "\s*,\s*" | Where-Object { $_.Trim() -ne "" }
  }

  if ($tokens -contains $tagToAdd) { return $TagLine }
  if ($isHash) {
    return ($tokens + $tagToAdd) -join " "
  }
  return ($tokens + $tagToAdd) -join ", "
}

function Ensure-Section {
  param(
    [string]$Body,
    [string]$Header,
    [string[]]$Lines
  )
  if ($Body -match "(?m)^##\s+$([regex]::Escape($Header))\s*$") {
    return $Body
  }
  $block = "## $Header`r`n" + (($Lines | ForEach-Object { "- $_" }) -join "`r`n")
  if ([string]::IsNullOrWhiteSpace($Body)) { return $block + "`r`n" }
  return $Body.TrimEnd() + "`r`n`r`n" + $block + "`r`n"
}

$herbOverrides = @{
  "Calendula" = @{ Germ = "5-10 days"; Bloom = "35-50 days"; Poll = "High"; Nectar = "Moderate"; Pollen = "High"; Indoor = "Yes"; Start = "Start indoors 4-6 weeks before transplant or direct sow in trays." }
  "Chamomile" = @{ Germ = "7-14 days"; Bloom = "45-60 days"; Poll = "High"; Nectar = "Moderate"; Pollen = "High"; Indoor = "Yes"; Start = "Surface sow indoors 5-7 weeks before bloom target." }
  "Cilantro" = @{ Germ = "7-10 days"; Bloom = "40-55 days"; Poll = "High"; Nectar = "Moderate"; Pollen = "High"; Indoor = "Yes"; Start = "Direct sow or start in deep cells; allow bolting for flowers." }
  "Nasturtium" = @{ Germ = "7-10 days"; Bloom = "35-50 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Yes"; Start = "Direct sow or start in larger cells to reduce transplant shock." }
  "Dill" = @{ Germ = "7-14 days"; Bloom = "45-60 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Yes"; Start = "Direct sow preferred; can be started indoors in deep trays." }
  "Borage" = @{ Germ = "7-14 days"; Bloom = "45-60 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Yes"; Start = "Direct sow preferred; start in deep cells if transplanting." }
  "Marigold" = @{ Germ = "5-10 days"; Bloom = "50-60 days"; Poll = "High"; Nectar = "Moderate"; Pollen = "Moderate"; Indoor = "Yes"; Start = "Start indoors 4-6 weeks before bloom target." }
  "Tithonia" = @{ Germ = "7-14 days"; Bloom = "75-95 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Limited"; Start = "Start indoors 4-6 weeks before planting; needs strong light and warmth." }
  "Thyme" = @{ Germ = "10-21 days"; Bloom = "70-100 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Limited"; Start = "Start indoors 8-10 weeks before transplanting." }
  "Rosemary" = @{ Germ = "14-28 days"; Bloom = "120-240 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "No"; Start = "Usually propagated by cuttings; seed is slow and variable." }
  "Lavender" = @{ Germ = "14-30 days"; Bloom = "120-180 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "No"; Start = "Cold stratify seed before indoor sowing; long establishment." }
  "Dandelion" = @{ Germ = "7-14 days"; Bloom = "55-75 days"; Poll = "High"; Nectar = "Moderate"; Pollen = "High"; Indoor = "Limited"; Start = "Direct sow or indoor tray sowing for quick leaf and flower cycles." }
  "Yarrow" = @{ Germ = "10-20 days"; Bloom = "80-120 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Limited"; Start = "Start indoors 8-10 weeks before transplanting." }
  "White Yarrow" = @{ Germ = "10-20 days"; Bloom = "80-120 days"; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Limited"; Start = "Start indoors 8-10 weeks before transplanting." }
}

$herbPollHigh = @(
  "Basil","Bergamot","Borage","Calendula","Catnip","Chamomile","Chives","Cilantro","Dill","Echinacea","Fennel",
  "Hyssop","Italian Basil","Lavender","Lemon Balm","Lemon Mint","Marigold","Monarda","Mountain Mint","Nasturtium",
  "Oregano","Purple Basil","Rosemary","Sage","Summer Savory","Thai Basil","Thyme","Tithonia","White Yarrow","Yarrow"
)

$herbSlowNo = @(
  "Black Cohosh","Eleuthero","Ginkgo","Ginseng","Goldenseal","Hawthorn","Horse Chestnut","Juniper","Linden","Mimosa",
  "Peach","Pine","Slippery Elm","Tea Tree","Uva Ursi","Willow","Witch Hazel","Woodruff"
)

$herbOrder = @(
  "Type","Category","Family","Life Cycle","Height","Spread","Root Depth","Sun","Soil","Water","Zone","Start Method",
  "Start Month","Days to Germination","Bloom Days","Bloom Speed Tier","Harvest","Primary Actions","Energetics",
  "Pollinator Value","Nectar Level","Pollen Level","Indoor Bloom Viable","Feeding Level","Companion Group","Tags"
)

$herbCount = 0
foreach ($file in Get-ChildItem $herbDir -File) {
  $parts = Get-DocParts (Get-Content -Raw $file.FullName)
  $fm = $parts.Front
  $body = $parts.Body
  $name = $file.BaseName

  if (-not $fm.Contains("Type")) { $fm["Type"] = "Herb" }
  $fm["Category"] = "Herb"
  if (-not $fm.Contains("Root Depth")) { $fm["Root Depth"] = "Varies by species" }

  $life = if ($fm.Contains("Life Cycle")) { $fm["Life Cycle"] } else { "" }
  $germ = "7-21 days"
  $bloom = "60-90 days"
  $start = "Start indoors 6-8 weeks before target planting; direct sow species that dislike transplanting."
  $poll = "Moderate"
  $nectar = "Moderate"
  $pollen = "Moderate"
  $indoor = "Limited"

  if ($life -match "Biennial") { $bloom = "90-180 days"; $indoor = "No" }
  if ($life -match "Perennial|shrub|tree|Tender perennial|tropical") { $bloom = "90-365+ days"; $germ = "10-30 days"; $indoor = "No" }
  if ($herbPollHigh -contains $name) { $poll = "High"; $nectar = "High"; $pollen = "Moderate" }
  if ($herbSlowNo -contains $name) { $bloom = "120-365+ days"; $indoor = "No"; $poll = "Low"; $nectar = "Low"; $pollen = "Low" }

  if ($herbOverrides.ContainsKey($name)) {
    $o = $herbOverrides[$name]
    $germ = $o.Germ
    $bloom = $o.Bloom
    $poll = $o.Poll
    $nectar = $o.Nectar
    $pollen = $o.Pollen
    $indoor = $o.Indoor
    $start = $o.Start
  }

  $fm["Start Method"] = $start
  $fm["Days to Germination"] = $germ
  $fm["Bloom Days"] = $bloom
  $fm["Bloom Speed Tier"] = Get-Tier $bloom
  $fm["Pollinator Value"] = $poll
  $fm["Nectar Level"] = $nectar
  $fm["Pollen Level"] = $pollen
  $fm["Indoor Bloom Viable"] = $indoor
  if (-not $fm.Contains("Feeding Level")) { $fm["Feeding Level"] = "Low-Moderate" }
  if (-not $fm.Contains("Companion Group")) { $fm["Companion Group"] = "Herb Guild" }

  $tags = if ($fm.Contains("Tags")) { $fm["Tags"] } else { "" }
  $tags = Add-Tag -TagLine $tags -Tag ("bloom-" + $fm["Bloom Speed Tier"].ToLower()) -HashStyle
  $tags = Add-Tag -TagLine $tags -Tag ("pollinator-" + $fm["Pollinator Value"].ToLower()) -HashStyle
  $fm["Tags"] = $tags

  $body = Ensure-Section -Body $body -Header "Seed Starting and Bloom Timing" -Lines @(
    "Start method: $($fm["Start Method"])",
    "Days to germination: $($fm["Days to Germination"])",
    "Bloom from seed: $($fm["Bloom Days"])",
    "Bloom speed tier: $($fm["Bloom Speed Tier"])",
    "Indoor bloom viability: $($fm["Indoor Bloom Viable"])"
  )

  Write-Doc -Path $file.FullName -Front $fm -Body $body -Order $herbOrder
  $herbCount++
}

function New-HerbNote {
  param(
    [string]$Name,
    [string]$Family,
    [string]$LifeCycle,
    [string]$Sun,
    [string]$Zone,
    [string]$StartMethod,
    [string]$Germ,
    [string]$Bloom,
    [string]$Pollinator
  )
  $path = Join-Path $herbDir ($Name + ".md")
  if (Test-Path $path) { return }
  $tier = Get-Tier $Bloom
  $pollLower = $Pollinator.ToLower()
  $body = @"
# $Name

## Growing Conditions
Prefers $Sun with well-drained soil and steady moisture.

## Planting Calendar (Zone 7B)
Start: Spring under lights or protected greenhouse conditions.
See [[Month-by-Month Calendar (Zone 7B)]] for timing details.

## Seed Starting and Bloom Timing
- Start method: $StartMethod
- Days to germination: $Germ
- Bloom from seed: $Bloom
- Bloom speed tier: $tier
- Indoor bloom viability: Limited

## Companion Plants
- [[Companion Guilds Index]]
- [[Calendula]]
- [[Yarrow]]

## Related Graph Links
- [[Master Plant Index]]
- [[Companion Guilds Index]]
- [[Month-by-Month Calendar (Zone 7B)]]
"@
  $fm = [ordered]@{
    "Type" = "Herb"
    "Category" = "Herb"
    "Family" = $Family
    "Life Cycle" = $LifeCycle
    "Height" = "Varies by cultivar"
    "Spread" = "Varies by cultivar"
    "Root Depth" = "Varies by species"
    "Sun" = $Sun
    "Soil" = "Well-drained, moderate fertility"
    "Water" = "Moderate"
    "Zone" = $Zone
    "Start Method" = $StartMethod
    "Start Month" = "Late winter to spring (greenhouse)"
    "Days to Germination" = $Germ
    "Bloom Days" = $Bloom
    "Bloom Speed Tier" = $tier
    "Harvest" = "Seasonal by use"
    "Primary Actions" = "Culinary and ecological support"
    "Energetics" = "Context dependent"
    "Pollinator Value" = $Pollinator
    "Nectar Level" = if ($Pollinator -eq "High") { "High" } else { "Moderate" }
    "Pollen Level" = if ($Pollinator -eq "High") { "Moderate" } else { "Moderate" }
    "Indoor Bloom Viable" = "Limited"
    "Feeding Level" = "Low-Moderate"
    "Companion Group" = "Herb Guild"
    "Tags" = "#herb #bloom-$($tier.ToLower()) #pollinator-$pollLower"
  }
  Write-Doc -Path $path -Front $fm -Body $body -Order $herbOrder
}

New-HerbNote -Name "Creeping Thyme" -Family "Lamiaceae" -LifeCycle "Perennial" -Sun "Full sun" -Zone "4-9" -StartMethod "Start indoors 8-10 weeks before transplanting." -Germ "10-21 days" -Bloom "70-100 days" -Pollinator "High"
New-HerbNote -Name "Allium (Ornamental)" -Family "Amaryllidaceae" -LifeCycle "Perennial bulb" -Sun "Full sun" -Zone "4-8" -StartMethod "Best from bulbs/sets; seed is slow and long-cycle." -Germ "14-28 days" -Bloom "120-240 days" -Pollinator "High"

$vegOverrides = @{
  "Daikon Radish" = @{ Germ = "3-7 days"; Bloom = "40-55 days"; Start = "Direct sow or indoor tray sowing for rapid bolting."; Poll = "Moderate"; Nectar = "Moderate"; Pollen = "Moderate"; Indoor = "Yes"; Feed = "Light"; Group = "Root" }
  "Red Beet" = @{ Germ = "5-10 days"; Bloom = "50-70 days"; Start = "Direct sow or cell trays; transplant when small."; Poll = "Moderate"; Nectar = "Low"; Pollen = "Moderate"; Indoor = "Yes"; Feed = "Light"; Group = "Root" }
  "Luffa" = @{ Germ = "7-14 days"; Bloom = "55-75 days"; Start = "Start indoors 4-6 weeks before transplanting."; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Limited"; Feed = "Heavy"; Group = "Cucurbit" }
  "Gourd" = @{ Germ = "7-10 days"; Bloom = "50-70 days"; Start = "Start indoors 3-4 weeks before transplanting or direct sow warm soil."; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "Limited"; Feed = "Heavy"; Group = "Cucurbit" }
  "Sunchoke" = @{ Germ = "10-21 days"; Bloom = "120-160 days"; Start = "Plant tubers directly; seed is uncommon for home systems."; Poll = "High"; Nectar = "High"; Pollen = "Moderate"; Indoor = "No"; Feed = "Medium"; Group = "Root" }
  "Sugarcane" = @{ Germ = "14-30 days"; Bloom = "300+ days"; Start = "Plant cane cuttings in warm controlled environment."; Poll = "Low"; Nectar = "Low"; Pollen = "Low"; Indoor = "No"; Feed = "Heavy"; Group = "Grass" }
}
$vegPollHigh = @("Cucumber","Squash","Zucchini","Pumpkin","Watermelon","Cantaloupe","Gourd","Luffa","Sunchoke")

function New-VegetableNote {
  param(
    [string]$Name,
    [string]$Family,
    [string]$StartMonth,
    [string]$Harvest,
    [string]$SeedDepth,
    [string]$RowSpacing,
    [string]$PlantSpacing,
    [string]$Varieties,
    [string]$Notes
  )
  $path = Join-Path $vegDir ($Name + ".md")
  if (Test-Path $path) { return }
  $o = $vegOverrides[$Name]
  $tier = Get-Tier $o.Bloom
  $body = @"
# $Name

## Quick Use Guide
- Seed depth: $SeedDepth
- Spacing: rows $RowSpacing, plants $PlantSpacing
- Feeding level: $($o.Feed)
- Companion group: $($o.Group)

## Planting Calendar (Zone 7B)
- Start window: $StartMonth
- Indoor start method: $($o.Start)
- Harvest window: $Harvest

## Seed Starting and Bloom Timing
- Days to germination: $($o.Germ)
- Bloom from seed: $($o.Bloom)
- Bloom speed tier: $tier
- Indoor bloom viability: $($o.Indoor)

## Companion Plants
- [[Herbalism-Vault/01_Plants/Marigold]]
- [[Herbalism-Vault/01_Plants/Nasturtium]]
- [[Master-Indexes/Companion Matrix]]

## Varieties
$Varieties

## Crop Notes
$Notes
"@
  $tags = ($Name.ToLower() -replace "[^a-z0-9]+", "-").Trim("-")
  $fm = [ordered]@{
    "Type" = "Vegetable"
    "Category" = "Vegetable"
    "Family" = $Family
    "Life Cycle" = "Annual"
    "Height" = "Varies by cultivar"
    "Spread" = "Varies by cultivar"
    "Root Depth" = "Varies by cultivar"
    "Sun" = "Full sun"
    "Soil" = "Fertile, well-drained"
    "Water" = "Moderate"
    "Zone" = "7B"
    "Start Method" = $o.Start
    "Start Month" = $StartMonth
    "Days to Germination" = $o.Germ
    "Bloom Days" = $o.Bloom
    "Bloom Speed Tier" = $tier
    "Harvest" = $Harvest
    "Pollinator Value" = $o.Poll
    "Nectar Level" = $o.Nectar
    "Pollen Level" = $o.Pollen
    "Indoor Bloom Viable" = $o.Indoor
    "Feeding Level" = $o.Feed
    "Companion Group" = $o.Group
    "Tags" = "$tags, zone-7b, vegetable, bloom-$($tier.ToLower()), pollinator-$($o.Poll.ToLower())"
  }
  Write-Doc -Path $path -Front $fm -Body $body -Order @(
    "Type","Category","Family","Life Cycle","Height","Spread","Root Depth","Sun","Soil","Water","Zone","Start Method",
    "Start Month","Days to Germination","Bloom Days","Bloom Speed Tier","Harvest","Pollinator Value","Nectar Level",
    "Pollen Level","Indoor Bloom Viable","Feeding Level","Companion Group","Tags"
  )
}

$varLuffa = @"
- Smooth Luffa: long, straight sponge gourds
- Angled Luffa: ridged fruit, often earlier
"@
New-VegetableNote -Name "Luffa" -Family "Cucurbitaceae" -StartMonth "Apr-May (indoors start in Mar-Apr)" -Harvest "Aug-Oct" -SeedDepth "1 in" -RowSpacing "60-72 in" -PlantSpacing "18-24 in" -Varieties $varLuffa -Notes "Use trellising for straight fruit and clean sponge quality."

$varGourd = @"
- Birdhouse Gourd: hard shell for crafts
- Dipper Gourd: long-neck utility shapes
- Speckled Swan Gourd: ornamental curved neck fruits
"@
New-VegetableNote -Name "Gourd" -Family "Cucurbitaceae" -StartMonth "Apr-Jun" -Harvest "Sep-Oct" -SeedDepth "1 in" -RowSpacing "72-96 in" -PlantSpacing "24-36 in" -Varieties $varGourd -Notes "Give long vines full sun and strong support structures."

$varDaikon = @"
- Miyashige: classic white long-root type
- Minowase: large long storage type
- KN Bravo: smooth roots with strong uniformity
"@
New-VegetableNote -Name "Daikon Radish" -Family "Brassicaceae" -StartMonth "Mar-Apr and Aug-Sep" -Harvest "Apr-May and Oct-Nov" -SeedDepth "1/2 in" -RowSpacing "12-18 in" -PlantSpacing "3-4 in" -Varieties $varDaikon -Notes "Great for compaction relief and bio-drilling when roots are left to decompose."

$varRedBeet = @"
- Detroit Dark Red: classic table beet
- Red Ace: uniform sweet roots
- Bull's Blood: deep red roots and leaves
"@
New-VegetableNote -Name "Red Beet" -Family "Amaranthaceae" -StartMonth "Mar-Apr and Jul-Aug" -Harvest "May-Jun and Sep-Nov" -SeedDepth "1/2 in" -RowSpacing "12-18 in" -PlantSpacing "2-3 in" -Varieties $varRedBeet -Notes "Useful for root production and for managed bolting to support early pollinators."

$varSunchoke = @"
- Fuseau: smooth, elongated tubers
- Stampede: productive, uniform stand
- Red Fuseau: red-skinned elongated tubers
"@
New-VegetableNote -Name "Sunchoke" -Family "Asteraceae" -StartMonth "Mar-Apr (tubers)" -Harvest "Oct-Dec" -SeedDepth "4-6 in (tubers)" -RowSpacing "36-42 in" -PlantSpacing "12-18 in" -Varieties $varSunchoke -Notes "Also called Jerusalem artichoke; tall late-season pollinator support flowers."

$varSugarcane = @"
- Green Ribbon: home-garden chewing cane
- Purple Ribbon: purple cane skin selection
- Red Cane: high-brix chewing type
"@
New-VegetableNote -Name "Sugarcane" -Family "Poaceae" -StartMonth "Mar-May (protected warmth)" -Harvest "Late fall through winter in warm systems" -SeedDepth "2-4 in (setts)" -RowSpacing "48-60 in" -PlantSpacing "18-24 in" -Varieties $varSugarcane -Notes "In Zone 7B this is best managed in greenhouse/high tunnel or as a warm-season container experiment."

$vegOrder = @(
  "Type","Category","Family","Life Cycle","Height","Spread","Root Depth","Sun","Soil","Water","Zone","Start Method",
  "Start Month","Days to Germination","Bloom Days","Bloom Speed Tier","Harvest","Pollinator Value","Nectar Level",
  "Pollen Level","Indoor Bloom Viable","Feeding Level","Companion Group","Tags"
)

$vegCount = 0
foreach ($file in Get-ChildItem $vegDir -File) {
  $parts = Get-DocParts (Get-Content -Raw $file.FullName)
  $fm = $parts.Front
  $body = $parts.Body
  $name = $file.BaseName

  $fm["Category"] = "Vegetable"
  if (-not $fm.Contains("Start Method")) {
    $fm["Start Method"] = "See planting calendar and crop notes for direct sow vs transplant guidance."
  }
  if (-not $fm.Contains("Days to Germination")) {
    $fm["Days to Germination"] = "5-14 days"
  }
  if (-not $fm.Contains("Bloom Days")) {
    $fm["Bloom Days"] = "50-90 days"
  }
  if (-not $fm.Contains("Pollinator Value")) { $fm["Pollinator Value"] = "Moderate" }
  if (-not $fm.Contains("Nectar Level")) { $fm["Nectar Level"] = "Moderate" }
  if (-not $fm.Contains("Pollen Level")) { $fm["Pollen Level"] = "Moderate" }
  if (-not $fm.Contains("Indoor Bloom Viable")) { $fm["Indoor Bloom Viable"] = "Limited" }

  if ($vegOverrides.ContainsKey($name)) {
    $o = $vegOverrides[$name]
    $fm["Start Method"] = $o.Start
    $fm["Days to Germination"] = $o.Germ
    $fm["Bloom Days"] = $o.Bloom
    $fm["Pollinator Value"] = $o.Poll
    $fm["Nectar Level"] = $o.Nectar
    $fm["Pollen Level"] = $o.Pollen
    $fm["Indoor Bloom Viable"] = $o.Indoor
    if (-not $fm.Contains("Feeding Level")) { $fm["Feeding Level"] = $o.Feed }
    if (-not $fm.Contains("Companion Group")) { $fm["Companion Group"] = $o.Group }
  }
  elseif ($vegPollHigh -contains $name) {
    $fm["Pollinator Value"] = "High"
    $fm["Nectar Level"] = "High"
    $fm["Pollen Level"] = "Moderate"
  }

  $fm["Bloom Speed Tier"] = Get-Tier $fm["Bloom Days"]
  $tags = if ($fm.Contains("Tags")) { $fm["Tags"] } else { "" }
  $tags = Add-Tag -TagLine $tags -Tag ("bloom-" + $fm["Bloom Speed Tier"].ToLower())
  $tags = Add-Tag -TagLine $tags -Tag ("pollinator-" + $fm["Pollinator Value"].ToLower())
  $fm["Tags"] = $tags

  $body = Ensure-Section -Body $body -Header "Bloom Timing and Pollinator Notes" -Lines @(
    "Start method: $($fm["Start Method"])",
    "Days to germination: $($fm["Days to Germination"])",
    "Bloom from seed: $($fm["Bloom Days"])",
    "Pollinator value: $($fm["Pollinator Value"])"
  )

  Write-Doc -Path $file.FullName -Front $fm -Body $body -Order $vegOrder
  $vegCount++
}

$allVegFiles = Get-ChildItem $vegDir -File | Sort-Object BaseName
$vegRows = @()
foreach ($f in $allVegFiles) {
  $p = Get-DocParts (Get-Content -Raw $f.FullName)
  $fm = $p.Front
  $vegRows += [pscustomobject]@{
    Name = $f.BaseName
    Link = "[[Vegetable-Vault/01_Crops/$($f.BaseName)]]"
    Tier = if ($fm.Contains("Bloom Speed Tier")) { $fm["Bloom Speed Tier"] } else { "Unknown" }
    Poll = if ($fm.Contains("Pollinator Value")) { $fm["Pollinator Value"] } else { "Unknown" }
    Feed = if ($fm.Contains("Feeding Level")) { $fm["Feeding Level"] } else { "Unknown" }
    Bloom = if ($fm.Contains("Bloom Days")) { $fm["Bloom Days"] } else { "Unknown" }
    Group = if ($fm.Contains("Companion Group")) { $fm["Companion Group"] } else { "General" }
  }
}

$masterCrop = @()
$masterCrop += "# Master Crop Index"
$masterCrop += ""
$masterCrop += "Expanded crop list for Zone 7B with seed-start and bloom-speed metadata."
$masterCrop += ""
$masterCrop += "## Alphabetical"
$masterCrop += (($vegRows | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
$masterCrop += ""
$masterCrop += "## Fast Bloom (<=60 days)"
$masterCrop += (($vegRows | Where-Object { (Get-HighDays $_.Bloom) -le 60 } | ForEach-Object { "- $($_.Link) - $($_.Bloom)" }) -join "`r`n")
$masterCrop += ""
$masterCrop += "## High Pollinator Value"
$masterCrop += (($vegRows | Where-Object { $_.Poll -eq "High" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
$masterCrop += ""
$masterCrop += "**Last Updated:** February 17, 2026"
Set-Content -Path (Join-Path $vegIndexDir "Master Crop Index.md") -Value ($masterCrop -join "`r`n") -Encoding utf8

$feedDoc = @()
$feedDoc += "# Feeding Requirements"
$feedDoc += ""
$feedDoc += "## Heavy Feeders"
$feedDoc += (($vegRows | Where-Object { $_.Feed -eq "Heavy" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
$feedDoc += ""
$feedDoc += "## Medium Feeders"
$feedDoc += (($vegRows | Where-Object { $_.Feed -eq "Medium" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
$feedDoc += ""
$feedDoc += "## Light Feeders"
$feedDoc += (($vegRows | Where-Object { $_.Feed -eq "Light" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
$feedDoc += ""
$feedDoc += "## Nitrogen Fixers"
$feedDoc += (($vegRows | Where-Object { $_.Feed -eq "Nitrogen Fixer" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
Set-Content -Path (Join-Path $vegIndexDir "Feeding Requirements.md") -Value ($feedDoc -join "`r`n") -Encoding utf8

$companionDoc = @()
$companionDoc += "# Companion Groups"
$companionDoc += ""
$companionDoc += "Group crops by companion behavior and rotation category."
$companionDoc += ""
foreach ($g in ($vegRows.Group | Sort-Object -Unique)) {
  $companionDoc += "## $g"
  $companionDoc += (($vegRows | Where-Object { $_.Group -eq $g } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
  $companionDoc += ""
}
Set-Content -Path (Join-Path $vegIndexDir "Companion Groups.md") -Value ($companionDoc -join "`r`n") -Encoding utf8

$rotationDir = Join-Path $projectRoot "Vegetable-Vault\03_Rotation"
$heavyLinks = ($vegRows | Where-Object { $_.Feed -eq "Heavy" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n"
$lightLinks = ($vegRows | Where-Object { $_.Feed -eq "Light" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n"
$nFixLinks = ($vegRows | Where-Object { $_.Feed -eq "Nitrogen Fixer" } | ForEach-Object { "- $($_.Link)" }) -join "`r`n"

Set-Content -Path (Join-Path $rotationDir "Heavy Feeders.md") -Value ("# Heavy Feeders`r`n`r`n" + $heavyLinks + "`r`n`r`nAvoid following heavy feeders with another heavy feeder in the same bed.") -Encoding utf8
Set-Content -Path (Join-Path $rotationDir "Light Feeders.md") -Value ("# Light Feeders`r`n`r`n" + $lightLinks + "`r`n`r`nLight feeders are good follow-ups after heavy-feeder beds.") -Encoding utf8
Set-Content -Path (Join-Path $rotationDir "Nitrogen Fixers.md") -Value ("# Nitrogen Fixers`r`n`r`n" + $nFixLinks + "`r`n`r`nUse these crops in rotation to help rebuild nitrogen.") -Encoding utf8

New-Item -ItemType Directory -Force -Path $wildRoot, $wildDir, $wildIndexDir, $wildMixDir, $wildConfigDir | Out-Null

$wildflowers = @(
  @{ Name="Alyssum"; Family="Brassicaceae"; Life="Annual"; Sun="Full to part sun"; Zone="2-11"; Start="Surface sow indoors 4-6 weeks early or direct sow."; StartMonth="Feb-May"; Germ="5-10 days"; Bloom="35-50 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="Yes"; Notes="One of the fastest reliable nectar flowers for greenhouse starts." },
  @{ Name="Milkweed"; Family="Apocynaceae"; Life="Perennial"; Sun="Full sun"; Zone="3-9"; Start="Cold stratify seed 30 days before sowing."; StartMonth="Jan-Apr"; Germ="10-21 days"; Bloom="90-140 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="Limited"; Notes="Critical monarch support plant; first-year bloom varies by species." },
  @{ Name="Lupine"; Family="Fabaceae"; Life="Perennial"; Sun="Full to part sun"; Zone="4-8"; Start="Scarify and soak seed before sowing."; StartMonth="Feb-Apr"; Germ="10-20 days"; Bloom="70-120 days"; Poll="High"; Nectar="Moderate"; Pollen="High"; Indoor="Limited"; Notes="Nitrogen-fixing pollinator spike flowers." },
  @{ Name="Sunflower"; Family="Asteraceae"; Life="Annual"; Sun="Full sun"; Zone="2-11"; Start="Direct sow or start in deep cells."; StartMonth="Mar-Jun"; Germ="7-10 days"; Bloom="55-75 days"; Poll="High"; Nectar="Moderate"; Pollen="High"; Indoor="Yes"; Notes="Use branching or dwarf types for fast greenhouse bloom cycles." },
  @{ Name="Tithonia"; Family="Asteraceae"; Life="Annual"; Sun="Full sun"; Zone="2-11"; Start="Start indoors 4-6 weeks before outplanting."; StartMonth="Mar-May"; Germ="7-14 days"; Bloom="75-95 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="Limited"; Notes="Strong late spring to summer nectar producer." },
  @{ Name="Sedum"; Family="Crassulaceae"; Life="Perennial"; Sun="Full sun"; Zone="3-9"; Start="Best from cuttings/division; seed is slow."; StartMonth="Spring"; Germ="14-30 days"; Bloom="120-240 days"; Poll="High"; Nectar="High"; Pollen="Low"; Indoor="No"; Notes="Excellent late-season nectar when mature." },
  @{ Name="Phlox (Annual)"; Family="Polemoniaceae"; Life="Annual"; Sun="Full to part sun"; Zone="2-11"; Start="Start indoors 4-6 weeks early or direct sow."; StartMonth="Feb-May"; Germ="7-14 days"; Bloom="50-65 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Yes"; Notes="Good filler flower for early mix color and moderate pollinator support." },
  @{ Name="California Poppy"; Family="Papaveraceae"; Life="Annual"; Sun="Full sun"; Zone="6-10"; Start="Direct sow preferred, does not like transplanting."; StartMonth="Mar-May"; Germ="7-14 days"; Bloom="50-65 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Limited"; Notes="Cool-season fast color in bright beds." },
  @{ Name="Cosmos"; Family="Asteraceae"; Life="Annual"; Sun="Full sun"; Zone="2-11"; Start="Direct sow or start indoors 3-4 weeks early."; StartMonth="Mar-Jun"; Germ="7-10 days"; Bloom="50-70 days"; Poll="High"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Yes"; Notes="Long flowering window with repeated cutting." },
  @{ Name="Coreopsis"; Family="Asteraceae"; Life="Annual/Perennial by species"; Sun="Full sun"; Zone="4-9"; Start="Start indoors 6-8 weeks early."; StartMonth="Feb-May"; Germ="10-21 days"; Bloom="55-80 days"; Poll="High"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Limited"; Notes="Plains and lanceleaf types are dependable pollinator flowers." },
  @{ Name="New England Aster"; Family="Asteraceae"; Life="Perennial"; Sun="Full sun"; Zone="4-8"; Start="Start indoors or winter sow; slower first year."; StartMonth="Feb-Apr"; Germ="10-21 days"; Bloom="110-160 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="No"; Notes="Critical late-season nectar for bees and butterflies." },
  @{ Name="Purple Coneflower"; Family="Asteraceae"; Life="Perennial"; Sun="Full sun"; Zone="3-9"; Start="Cold stratify for best germination."; StartMonth="Jan-Apr"; Germ="10-21 days"; Bloom="100-140 days"; Poll="High"; Nectar="Moderate"; Pollen="High"; Indoor="Limited"; Notes="Long-lived pollinator and seed-head bird plant." },
  @{ Name="Baby Blue Eyes"; Family="Boraginaceae"; Life="Annual"; Sun="Full to part sun"; Zone="3-10"; Start="Direct sow in cool conditions."; StartMonth="Feb-Apr"; Germ="7-14 days"; Bloom="55-70 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Yes"; Notes="Good in cool-season blends." },
  @{ Name="Corn Poppy"; Family="Papaveraceae"; Life="Annual"; Sun="Full sun"; Zone="3-10"; Start="Direct sow preferred."; StartMonth="Mar-May"; Germ="7-14 days"; Bloom="60-75 days"; Poll="Moderate"; Nectar="Low"; Pollen="Moderate"; Indoor="Limited"; Notes="Quick annual color, useful in broad pollinator strips." },
  @{ Name="Evening Primrose"; Family="Onagraceae"; Life="Biennial/Perennial"; Sun="Full sun"; Zone="4-9"; Start="Direct sow or start indoors with cool stratification."; StartMonth="Feb-May"; Germ="7-20 days"; Bloom="80-120 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="Limited"; Notes="Dusk and evening pollinator support." },
  @{ Name="Crimson Clover"; Family="Fabaceae"; Life="Annual"; Sun="Full sun"; Zone="3-9"; Start="Direct sow in trays or beds."; StartMonth="Feb-Apr and Aug-Sep"; Germ="5-10 days"; Bloom="60-85 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="Yes"; Notes="Pollinator support and nitrogen fixation." },
  @{ Name="Phacelia"; Family="Boraginaceae"; Life="Annual"; Sun="Full sun"; Zone="3-10"; Start="Direct sow preferred."; StartMonth="Mar-May"; Germ="7-14 days"; Bloom="50-70 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="Yes"; Notes="One of the strongest bee forage annuals." },
  @{ Name="Gaillardia"; Family="Asteraceae"; Life="Perennial/Annual"; Sun="Full sun"; Zone="3-10"; Start="Start indoors 6-8 weeks early."; StartMonth="Feb-May"; Germ="7-20 days"; Bloom="65-90 days"; Poll="High"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Limited"; Notes="Also called blanketflower; drought tolerant once established." },
  @{ Name="Gayfeather"; Family="Asteraceae"; Life="Perennial"; Sun="Full sun"; Zone="3-9"; Start="Seed requires patience; corms bloom faster."; StartMonth="Feb-Apr"; Germ="14-28 days"; Bloom="110-160 days"; Poll="High"; Nectar="High"; Pollen="Moderate"; Indoor="No"; Notes="Excellent butterfly and bee magnet in summer." },
  @{ Name="Candytuft"; Family="Brassicaceae"; Life="Annual"; Sun="Full sun"; Zone="3-9"; Start="Direct sow or start indoors 4 weeks early."; StartMonth="Mar-May"; Germ="10-15 days"; Bloom="55-70 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Yes"; Notes="Compact filler in mixed pollinator containers." },
  @{ Name="Bachelor Button"; Family="Asteraceae"; Life="Annual"; Sun="Full sun"; Zone="2-11"; Start="Direct sow cool soil or start indoors 4 weeks early."; StartMonth="Mar-May"; Germ="7-14 days"; Bloom="60-75 days"; Poll="High"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Yes"; Notes="Also called cornflower; supports early beneficials." },
  @{ Name="Rocket Larkspur"; Family="Ranunculaceae"; Life="Annual"; Sun="Full to part sun"; Zone="2-10"; Start="Direct sow in cool soil; dislikes transplanting."; StartMonth="Mar-Apr and Sep-Oct"; Germ="14-21 days"; Bloom="80-110 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Low"; Indoor="Limited"; Notes="Useful height and color but slower bloom from seed." },
  @{ Name="Siberian Wallflower"; Family="Brassicaceae"; Life="Perennial"; Sun="Full sun"; Zone="3-8"; Start="Start indoors 6-8 weeks early."; StartMonth="Feb-Apr"; Germ="7-14 days"; Bloom="70-110 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Limited"; Notes="Cool-season color bridge into spring." },
  @{ Name="Black Eyed Susan"; Family="Asteraceae"; Life="Perennial/Annual"; Sun="Full sun"; Zone="3-9"; Start="Start indoors 6-8 weeks early."; StartMonth="Feb-May"; Germ="7-21 days"; Bloom="80-110 days"; Poll="High"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Limited"; Notes="Long flowering summer support flower." },
  @{ Name="African Daisy"; Family="Asteraceae"; Life="Tender perennial/annual"; Sun="Full sun"; Zone="9-11 annual elsewhere"; Start="Start indoors 6-8 weeks early."; StartMonth="Feb-May"; Germ="10-20 days"; Bloom="60-85 days"; Poll="Moderate"; Nectar="Moderate"; Pollen="Moderate"; Indoor="Yes"; Notes="Strong color and moderate pollinator utility." }
)

$wildOrder = @(
  "Type","Category","Family","Life Cycle","Height","Spread","Root Depth","Sun","Soil","Water","Zone","Start Method",
  "Start Month","Days to Germination","Bloom Days","Bloom Speed Tier","Harvest","Pollinator Value","Nectar Level",
  "Pollen Level","Indoor Bloom Viable","Feeding Level","Companion Group","Tags"
)

foreach ($wf in $wildflowers) {
  $path = Join-Path $wildDir ($wf.Name + ".md")
  $tier = Get-Tier $wf.Bloom
  $tags = "#wildflower #bloom-$($tier.ToLower()) #pollinator-$($wf.Poll.ToLower())"
  $fm = [ordered]@{
    "Type" = "Flower"
    "Category" = "Wildflower"
    "Family" = $wf.Family
    "Life Cycle" = $wf.Life
    "Height" = "Varies by cultivar"
    "Spread" = "Varies by cultivar"
    "Root Depth" = "Varies by species"
    "Sun" = $wf.Sun
    "Soil" = "Well-drained, moderate fertility"
    "Water" = "Moderate"
    "Zone" = $wf.Zone
    "Start Method" = $wf.Start
    "Start Month" = $wf.StartMonth
    "Days to Germination" = $wf.Germ
    "Bloom Days" = $wf.Bloom
    "Bloom Speed Tier" = $tier
    "Harvest" = "Flowering season"
    "Pollinator Value" = $wf.Poll
    "Nectar Level" = $wf.Nectar
    "Pollen Level" = $wf.Pollen
    "Indoor Bloom Viable" = $wf.Indoor
    "Feeding Level" = "Low"
    "Companion Group" = "Pollinator Support"
    "Tags" = $tags
  }
  $body = @"
# $($wf.Name)

## Seed Starting
- Method: $($wf.Start)
- Start window: $($wf.StartMonth)
- Days to germination: $($wf.Germ)

## Bloom Timing
- Bloom from seed: $($wf.Bloom)
- Bloom speed tier: $tier
- Indoor bloom viability: $($wf.Indoor)

## Pollinator Notes
- Pollinator value: $($wf.Poll)
- Nectar level: $($wf.Nectar)
- Pollen level: $($wf.Pollen)
- Strategy: $($wf.Notes)

## Companion Use
- Pair with herbs and vegetables needing pollinator pressure.
- Link into [[Master-Indexes/Pollinator Network]] and [[Master-Indexes/Companion Matrix]].
- For early greenhouse pollinator support, combine with [[Wildflower-Vault/01_Plants/Alyssum]].

## Related Links
- [[Wildflower-Vault/00_Indexes/Master Wildflower Index]]
- [[Wildflower-Vault/00_Indexes/Bloom Speed Index]]
- [[Wildflower-Vault/00_Indexes/Pollinator Value Index]]
"@
  Write-Doc -Path $path -Front $fm -Body $body -Order $wildOrder
}

$wildRows = @()
foreach ($f in Get-ChildItem $wildDir -File | Sort-Object BaseName) {
  $parts = Get-DocParts (Get-Content -Raw $f.FullName)
  $fm = $parts.Front
  $wildRows += [pscustomobject]@{
    Name = $f.BaseName
    Link = "[[Wildflower-Vault/01_Plants/$($f.BaseName)]]"
    Tier = $fm["Bloom Speed Tier"]
    Poll = $fm["Pollinator Value"]
    Bloom = $fm["Bloom Days"]
  }
}

$wildMaster = @()
$wildMaster += "# Master Wildflower Index"
$wildMaster += ""
$wildMaster += "## Alphabetical"
$wildMaster += (($wildRows | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
$wildMaster += ""
$wildMaster += "## Fast Bloom Selections"
$wildMaster += (($wildRows | Where-Object { $_.Tier -in @("Elite","Fast") } | ForEach-Object { "- $($_.Link) - $($_.Bloom)" }) -join "`r`n")
Set-Content -Path (Join-Path $wildIndexDir "Master Wildflower Index.md") -Value ($wildMaster -join "`r`n") -Encoding utf8

$wildSpeed = @()
$wildSpeed += "# Bloom Speed Index"
$wildSpeed += ""
foreach ($tier in @("Elite","Fast","Moderate","Slow")) {
  $wildSpeed += "## $tier"
  $wildSpeed += (($wildRows | Where-Object { $_.Tier -eq $tier } | ForEach-Object { "- $($_.Link) - $($_.Bloom)" }) -join "`r`n")
  $wildSpeed += ""
}
Set-Content -Path (Join-Path $wildIndexDir "Bloom Speed Index.md") -Value ($wildSpeed -join "`r`n") -Encoding utf8

$wildPoll = @()
$wildPoll += "# Pollinator Value Index"
$wildPoll += ""
foreach ($poll in @("High","Moderate","Low")) {
  $wildPoll += "## $poll"
  $wildPoll += (($wildRows | Where-Object { $_.Poll -eq $poll } | ForEach-Object { "- $($_.Link)" }) -join "`r`n")
  $wildPoll += ""
}
Set-Content -Path (Join-Path $wildIndexDir "Pollinator Value Index.md") -Value ($wildPoll -join "`r`n") -Encoding utf8

$beesMix = @"
# Bees Mix

Designed for rapid bee forage and long bloom overlap.

- [[Wildflower-Vault/01_Plants/Alyssum]]
- [[Wildflower-Vault/01_Plants/Phacelia]]
- [[Wildflower-Vault/01_Plants/Sunflower]]
- [[Wildflower-Vault/01_Plants/Cosmos]]
- [[Wildflower-Vault/01_Plants/Coreopsis]]
- [[Wildflower-Vault/01_Plants/New England Aster]]
"@
Set-Content -Path (Join-Path $wildMixDir "Bees Mix.md") -Value $beesMix -Encoding utf8

$butterflyMix = @"
# Butterfly Mix

Focused on host and nectar plants for butterflies.

- [[Wildflower-Vault/01_Plants/Milkweed]]
- [[Wildflower-Vault/01_Plants/Lupine]]
- [[Wildflower-Vault/01_Plants/Gaillardia]]
- [[Wildflower-Vault/01_Plants/Purple Coneflower]]
- [[Wildflower-Vault/01_Plants/Black Eyed Susan]]
- [[Wildflower-Vault/01_Plants/New England Aster]]
"@
Set-Content -Path (Join-Path $wildMixDir "Butterfly Mix.md") -Value $butterflyMix -Encoding utf8

$fastMix = @"
# Fast Bloom Mix

Targets earliest practical flowers from seed in controlled environments.

- [[Wildflower-Vault/01_Plants/Alyssum]] (35-50 days)
- [[Wildflower-Vault/01_Plants/Phlox (Annual)]] (50-65 days)
- [[Wildflower-Vault/01_Plants/Cosmos]] (50-70 days)
- [[Wildflower-Vault/01_Plants/California Poppy]] (50-65 days)
- [[Wildflower-Vault/01_Plants/Bachelor Button]] (60-75 days)
"@
Set-Content -Path (Join-Path $wildMixDir "Fast Bloom Mix.md") -Value $fastMix -Encoding utf8

$wildTags = @'
# Wildflower Tagging System

## Bloom Speed Tags
- `#bloom-elite`
- `#bloom-fast`
- `#bloom-moderate`
- `#bloom-slow`

## Pollinator Tags
- `#pollinator-high`
- `#pollinator-moderate`
- `#pollinator-low`

## Core Type Tag
- `#wildflower`
'@
Set-Content -Path (Join-Path $wildConfigDir "tagging-system.md") -Value $wildTags -Encoding utf8

$fastHerbRows = @()
foreach ($f in Get-ChildItem $herbDir -File | Sort-Object BaseName) {
  $parts = Get-DocParts (Get-Content -Raw $f.FullName)
  $fm = $parts.Front
  if ($fm["Pollinator Value"] -eq "High" -and $fm["Indoor Bloom Viable"] -in @("Yes","Limited")) {
    $n = Get-LowDays $fm["Bloom Days"]
    if ($n -le 60) {
      $fastHerbRows += [pscustomobject]@{
        Name = $f.BaseName
        Link = "[[$($f.BaseName)]]"
        Bloom = $fm["Bloom Days"]
        Tier = $fm["Bloom Speed Tier"]
        Indoor = $fm["Indoor Bloom Viable"]
      }
    }
  }
}
$fastHerbRows = $fastHerbRows | Sort-Object { Get-LowDays $_.Bloom }, Name

$fastHerbDoc = @()
$fastHerbDoc += "# Fast Bloom Pollinator Herbs (Greenhouse)"
$fastHerbDoc += ""
$fastHerbDoc += "Target: seed-to-bloom herbs for rapid pollinator support under controlled indoor/greenhouse conditions."
$fastHerbDoc += ""
$fastHerbDoc += "## Best Candidates"
$fastHerbDoc += (($fastHerbRows | ForEach-Object { "- $($_.Link): $($_.Bloom) (tier: $($_.Tier); indoor: $($_.Indoor))" }) -join "`r`n")
$fastHerbDoc += ""
$fastHerbDoc += "## 40-50 Day Priority List"
$fastHerbDoc += "- [[Calendula]] (35-50 days)"
$fastHerbDoc += "- [[Nasturtium]] (35-50 days)"
$fastHerbDoc += "- [[Cilantro]] (40-55 days, usable in the 40-50 window when bolting is encouraged)"
$fastHerbDoc += ""
$fastHerbDoc += "## March Bloom Planning"
$fastHerbDoc += "- For March flowers, sow 40-60 day herbs in late January through early February under 14-16h light and stable warmth."
$fastHerbDoc += "- Highest-priority fast options in this vault: [[Calendula]], [[Cilantro]], [[Chamomile]], [[Dill]], [[Borage]], [[Nasturtium]]."
Set-Content -Path (Join-Path $herbIndexDir "Fast Bloom Pollinator Herbs.md") -Value ($fastHerbDoc -join "`r`n") -Encoding utf8

$sourceDoc = @"
# Source References - Seed Start and Bloom Timing

Primary references used for seed-start and bloom-speed normalization:

- Virginia Cooperative Extension: https://www.pubs.ext.vt.edu/426/426-331/426-331.html
- Clemson Cooperative Extension: https://hgic.clemson.edu/factsheet/planning-a-garden/
- Johnny's Selected Seeds (grower library): https://www.johnnyseeds.com/growers-library/
- Benary technical guides: https://www.benary.com/
- University of Maryland Extension transplant guidance: https://extension.umd.edu/resource/planting-transplants-your-garden/

Notes:
- Bloom days are practical ranges and vary by cultivar, light intensity, nutrition, and temperature.
- Indoor greenhouse assumptions: 14-16h light, warm root zone, consistent fertility, and minimal transplant shock.
"@
Set-Content -Path (Join-Path $masterIndexDir "Source References - Seed and Bloom Data.md") -Value $sourceDoc -Encoding utf8

$promptDoc = @'
# VS Code Auto-Adjust Prompt

Use this prompt in VS Code Copilot/Chat to re-run the same normalization:

```
Project root: Gardening-Vault

Run this script and then summarize results:
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update_vault_metadata.ps1

After running:
1) Confirm counts of files in Herbalism-Vault/01_Plants, Vegetable-Vault/01_Crops, and Wildflower-Vault/01_Plants.
2) Verify every herb and vegetable file has these frontmatter fields:
   Start Method
   Days to Germination
   Bloom Days
   Bloom Speed Tier
   Pollinator Value
   Nectar Level
   Pollen Level
   Indoor Bloom Viable
3) Report bloom tier distribution and high-pollinator totals.
4) Regenerate index files only if counts or metadata drift.
```
'@
Set-Content -Path (Join-Path $quickGuideDir "VS Code Auto-Adjust Prompt.md") -Value $promptDoc -Encoding utf8

$herbTierCounts = @{}
foreach ($f in Get-ChildItem $herbDir -File) {
  $tier = (Get-DocParts (Get-Content -Raw $f.FullName)).Front["Bloom Speed Tier"]
  if (-not $herbTierCounts.ContainsKey($tier)) { $herbTierCounts[$tier] = 0 }
  $herbTierCounts[$tier]++
}

$wildTierCounts = @{}
foreach ($f in Get-ChildItem $wildDir -File) {
  $tier = (Get-DocParts (Get-Content -Raw $f.FullName)).Front["Bloom Speed Tier"]
  if (-not $wildTierCounts.ContainsKey($tier)) { $wildTierCounts[$tier] = 0 }
  $wildTierCounts[$tier]++
}

Write-Output "HERBS_UPDATED=$herbCount"
Write-Output "VEGETABLES_UPDATED=$vegCount"
Write-Output ("WILDFLOWERS_TOTAL=" + (Get-ChildItem $wildDir -File).Count)
Write-Output ("HERB_TIERS=" + (($herbTierCounts.Keys | Sort-Object | ForEach-Object { "${_}:$($herbTierCounts[$_])" }) -join ","))
Write-Output ("WILD_TIERS=" + (($wildTierCounts.Keys | Sort-Object | ForEach-Object { "${_}:$($wildTierCounts[$_])" }) -join ","))
