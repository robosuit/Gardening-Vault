$ErrorActionPreference = "Stop"

$root = "c:\Users\Anubis\GitHub\Obsidian\Gardening-Vault\Herbalism-Vault"
$plantsDir = Join-Path $root "01_Plants"
$indexDir = Join-Path $root "00_Indexes"

function Parse-Frontmatter {
  param([string]$Content)
  $map = @{}
  $lines = $Content -split "`r?`n"
  if ($lines.Length -lt 3 -or $lines[0].Trim() -ne "---") { return $map }

  $i = 1
  while ($i -lt $lines.Length -and $lines[$i].Trim() -ne "---") {
    $line = $lines[$i]
    if ($line -match "^\s*([^:]+):\s*(.*)\s*$") {
      $key = $matches[1].Trim()
      $val = $matches[2].Trim()
      $map[$key] = $val
    }
    $i++
  }
  return $map
}

function Get-Field {
  param(
    [hashtable]$Map,
    [string[]]$Keys,
    [string]$Default = "Not specified"
  )
  foreach ($k in $Keys) {
    if ($Map.ContainsKey($k) -and -not [string]::IsNullOrWhiteSpace($Map[$k])) {
      return $Map[$k]
    }
  }
  return $Default
}

function Infer-Type {
  param(
    [string]$Name,
    [string]$RawType
  )
  $n = if ($null -eq $Name) { "" } else { $Name.ToLowerInvariant() }
  $t = if ($null -eq $RawType) { "" } else { $RawType.ToLowerInvariant() }

  if ($t -match "succulent" -or $n -match "^aloe$") { return "Succulent" }
  if ($t -match "tree" -or $n -match "^(ginkgo|linden|mimosa|peach|pine|slippery elm|lemon|clove|willow)$") { return "Tree" }
  if ($n -match "^(elderberry|raspberry|rose hips)$") { return "Berry" }
  if ($t -match "shrub" -or $n -match "^(hawthorn|juniper|rose|witch hazel|eleuthero|uva ursi|tea tree|matcha \(tea plant\))$") { return "Shrub" }
  if ($t -match "vine" -or $n -match "^(passionflower|wild yam)$") { return "Vine" }
  if ($t -match "bulb" -or $n -match "^(garlic|onion)$") { return "Bulb" }
  if ($t -match "groundcover|ground-cover" -or $n -match "^(wintergreen|woodruff|plantain)$") { return "Groundcover" }
  if ($t -match "vegetable" -or $n -match "^(capsicum)$") { return "Vegetable" }
  if ($t -match "flower" -or $n -match "^(calendula|marigold|tithonia|poppy)$") { return "Flower" }
  return "Herb"
}

function Infer-LifeCycle {
  param([string]$RawLife)
  $l = if ($null -eq $RawLife) { "" } else { $RawLife.ToLowerInvariant() }
  if ($l -match "biennial") { return "Biennial" }
  if ($l -match "annual") { return "Annual" }
  if ($l -match "tender perennial") { return "Tender Perennial" }
  if ($l -match "perennial") { return "Perennial" }
  return "Perennial"
}

function Split-List {
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text) -or $Text -eq "Not specified") { return @() }
  return ($Text -split ",|\u2022|;" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
}

function Detect-Title {
  param([string]$Content, [string]$FileBase)
  $h1 = ($Content -split "`r?`n" | Where-Object { $_ -match "^\s*#\s+" } | Select-Object -First 1)
  if ($h1) {
    $t = $h1 -replace "^\s*#\s+", ""
    $t = $t -replace "[^\x20-\x7E]", ""
    $t = $t.Trim()
    if (-not [string]::IsNullOrWhiteSpace($t)) { return $t }
  }
  return $FileBase
}

function Build-RelatedLinks {
  param([string]$Tags)
  $links = New-Object System.Collections.Generic.List[string]
  $tagsLc = if ($null -eq $Tags) { "" } else { $Tags.ToLowerInvariant() }

  if ($tagsLc -match "#digestive") { $links.Add("[[Digestive Support]]") }
  if ($tagsLc -match "#nervine|#sleep") { $links.Add("[[Nervine & Calming]]") }
  if ($tagsLc -match "#respiratory") { $links.Add("[[Respiratory Support]]") }
  if ($tagsLc -match "#antimicrobial") { $links.Add("[[Antimicrobial Herbs]]") }
  if ($tagsLc -match "#wound|#circulatory") { $links.Add("[[Wound & Circulation]]") }

  $links.Add("[[Master Plant Index]]")
  $links.Add("[[Medicinal Actions Index]]")
  $links.Add("[[Companion Guilds Index]]")
  $links.Add("[[Color & Energetics Index]]")
  $links.Add("[[Month-by-Month Calendar (Zone 7B)]]")

  return $links | Select-Object -Unique
}

function Normalize-PlantNotes {
  $files = Get-ChildItem $plantsDir -File -Filter "*.md" | Sort-Object Name
  foreach ($file in $files) {
    $content = Get-Content -Raw $file.FullName
    $content = $content -replace "`0", ""
    $meta = Parse-Frontmatter -Content $content
    $title = Detect-Title -Content $content -FileBase $file.BaseName

    $rawType = Get-Field $meta @("Type", "Plant Type")
    $family = Get-Field $meta @("Family")
    $rawLife = Get-Field $meta @("Life Cycle")
    $height = Get-Field $meta @("Height")
    $spread = Get-Field $meta @("Spread")
    $sun = Get-Field $meta @("Sun")
    $soil = Get-Field $meta @("Soil")
    $water = Get-Field $meta @("Water")
    $zone = Get-Field $meta @("Zone")
    $start = Get-Field $meta @("Start Month", "Start Month (Zone 7B)")
    $harvest = Get-Field $meta @("Harvest", "Harvest Time")
    $actions = Get-Field $meta @("Primary Actions")
    $energetics = Get-Field $meta @("Energetics")
    $tags = Get-Field $meta @("Tags") ""
    $type = Infer-Type -Name $title -RawType $rawType
    $life = Infer-LifeCycle -RawLife $rawLife

    $actionList = Split-List $actions
    if ($actionList.Count -eq 0) { $actionList = @("Not specified") }
    $actionBullets = ($actionList | ForEach-Object { "- $_" }) -join "`r`n"

    $links = Build-RelatedLinks -Tags $tags
    $linkBullets = ($links | ForEach-Object { "- $_" }) -join "`r`n"

    $grow = "Prefers $sun conditions, with $soil soil and $water moisture."
    $calendar = "Start: $start`r`nHarvest: $harvest`r`nSee [[Month-by-Month Calendar (Zone 7B)]] for timing details."
    $size = "Height: $height`r`nSpread: $spread"
    $eco = "Supports garden ecology through habitat, pollinator support, and companion diversity based on placement."

    $normalized = @"
---
Type: $type
Family: $family
Life Cycle: $life
Height: $height
Spread: $spread
Sun: $sun
Soil: $soil
Water: $water
Zone: $zone
Start Month: $start
Harvest: $harvest
Primary Actions: $actions
Energetics: $energetics
Tags: $tags
---

# $title

## Growing Conditions
$grow

## Planting Calendar (Zone 7B)
$calendar

## Size and Spacing
$size

## Medicinal Actions
$actionBullets

## Companion Plants
- [[Companion Guilds Index]]
- [[Calendula]]
- [[Yarrow]]
- [[Chamomile]]

## Avoid
- Waterlogged soil
- Poor airflow
- Mismatched water-needs neighbors

## Preparations
- [[Tea Infusion Guide]]
- [[Tincture Guide]]
- [[Salve Guide]]
- [[Syrup Guide]]

## Ecological Role
$eco

## Related Graph Links
$linkBullets
"@

    Set-Content -Path $file.FullName -Value $normalized -Encoding utf8
  }
}

function Collect-PlantData {
  $list = @()
  $files = Get-ChildItem $plantsDir -File -Filter "*.md" | Sort-Object Name
  foreach ($file in $files) {
    $c = Get-Content -Raw $file.FullName
    $m = Parse-Frontmatter -Content $c
    $name = $file.BaseName
    $list += [pscustomobject]@{
      Name = $name
      Type = Get-Field $m @("Type", "Plant Type")
      LifeCycle = Get-Field $m @("Life Cycle")
      Sun = Get-Field $m @("Sun")
      Water = Get-Field $m @("Water")
      Zone = Get-Field $m @("Zone")
      Tags = Get-Field $m @("Tags") ""
      Actions = Get-Field $m @("Primary Actions") ""
    }
  }
  return $list
}

function Add-CollapsibleSection {
  param(
    [System.Collections.Generic.List[string]]$Out,
    [string]$Title,
    [hashtable]$Buckets
  )
  $Out.Add("### $Title")
  $Out.Add("")
  $Out.Add("_Fold this heading in Obsidian to collapse this section._")
  $Out.Add("")
  foreach ($k in ($Buckets.Keys | Sort-Object)) {
    $Out.Add("#### $k")
    foreach ($n in ($Buckets[$k] | Sort-Object -Unique)) {
      $Out.Add("- [[$n]]")
    }
    $Out.Add("")
  }
}

function Canonical-Type {
  param([string]$Value)
  $v = if ($null -eq $Value) { "" } else { $Value.ToLowerInvariant() }
  if ($v -match "berry") { return "Berry" }
  if ($v -match "tree") { return "Tree" }
  if ($v -match "shrub") { return "Shrub" }
  if ($v -match "vine") { return "Vine" }
  if ($v -match "bulb") { return "Bulb" }
  if ($v -match "succulent") { return "Succulent" }
  if ($v -match "groundcover|ground-cover") { return "Groundcover" }
  if ($v -match "vegetable") { return "Vegetable" }
  if ($v -match "flower") { return "Flower" }
  if ($v -match "herb") { return "Herb" }
  return "Herb"
}

function Canonical-LifeCycle {
  param([string]$Value)
  $v = if ($null -eq $Value) { "" } else { $Value.ToLowerInvariant() }
  if ($v -match "biennial") { return "Biennial" }
  if ($v -match "annual") { return "Annual" }
  if ($v -match "tender perennial") { return "Tender Perennial" }
  return "Perennial"
}

function Canonical-Sun {
  param([string]$Value)
  $v = if ($null -eq $Value) { "" } else { $Value.ToLowerInvariant() }
  $hasFull = $v -match "full"
  $hasPart = $v -match "partial|part"
  $hasShade = $v -match "shade"
  if ($hasFull -and $hasPart) { return "Full to Partial Sun" }
  if ($hasPart -and $hasShade -and -not $hasFull) { return "Partial Sun to Shade" }
  if ($hasFull) { return "Full Sun" }
  if ($hasPart) { return "Partial Sun" }
  if ($hasShade) { return "Shade" }
  if ([string]::IsNullOrWhiteSpace($Value) -or $Value -eq "Not specified") { return "Not specified" }
  return $Value
}

function Canonical-Water {
  param([string]$Value)
  $v = if ($null -eq $Value) { "" } else { $Value.ToLowerInvariant() }
  if ($v -match "low|drought") { return "Low" }
  if ($v -match "moist|wet|high") { return "Moist/High" }
  if ($v -match "moderate|regular|consistent") { return "Moderate" }
  if ([string]::IsNullOrWhiteSpace($Value) -or $Value -eq "Not specified") { return "Not specified" }
  return $Value
}

function Build-MasterIndex {
  param([object[]]$Plants)
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add("# Master Plant Index")
  $out.Add("")
  $out.Add("## Alphabetical")
  $out.Add("")
  foreach ($n in ($Plants.Name | Sort-Object)) { $out.Add("- [[$n]]") }
  $out.Add("")
  $out.Add("## Property Views")
  $out.Add("")

  $typeBuckets = @{}
  $lifeBuckets = @{}
  $sunBuckets = @{}
  $waterBuckets = @{}
  $zoneBuckets = @{}
  $container = @()

  foreach ($p in $Plants) {
    foreach ($pair in @(
      @{ Map = $typeBuckets; Key = (Canonical-Type $p.Type) },
      @{ Map = $lifeBuckets; Key = (Canonical-LifeCycle $p.LifeCycle) },
      @{ Map = $sunBuckets; Key = (Canonical-Sun $p.Sun) },
      @{ Map = $waterBuckets; Key = (Canonical-Water $p.Water) },
      @{ Map = $zoneBuckets; Key = $p.Zone }
    )) {
      $k = if ([string]::IsNullOrWhiteSpace($pair.Key)) { "Not specified" } else { $pair.Key }
      if (-not $pair.Map.ContainsKey($k)) { $pair.Map[$k] = @() }
      $pair.Map[$k] += $p.Name
    }
    if (($p.Tags.ToLowerInvariant() -match "#container") -or ($p.Zone.ToLowerInvariant() -match "container")) {
      $container += $p.Name
    }
  }

  Add-CollapsibleSection -Out $out -Title "By Type" -Buckets $typeBuckets
  Add-CollapsibleSection -Out $out -Title "By Life Cycle" -Buckets $lifeBuckets
  Add-CollapsibleSection -Out $out -Title "By Sun" -Buckets $sunBuckets
  Add-CollapsibleSection -Out $out -Title "By Water" -Buckets $waterBuckets
  Add-CollapsibleSection -Out $out -Title "By Zone" -Buckets $zoneBuckets

  $out.Add("### Container / Controlled Climate")
  $out.Add("")
  $out.Add("_Fold this heading in Obsidian to collapse this section._")
  $out.Add("")
  foreach ($n in ($container | Sort-Object -Unique)) { $out.Add("- [[$n]]") }
  $out.Add("")

  $out.Add("## Quick Links")
  $out.Add("")
  $out.Add("- [[Medicinal Actions Index]]")
  $out.Add("- [[Container & Controlled Climate Herbs]]")
  $out.Add("- [[Companion Guilds Index]]")
  $out.Add("- [[Color & Energetics Index]]")
  $out.Add("- [[Month-by-Month Calendar (Zone 7B)]]")
  $out.Add("")
  $out.Add("**Last Updated:** February 16, 2026")

  Set-Content -Path (Join-Path $indexDir "Master Plant Index.md") -Value ($out -join "`r`n") -Encoding utf8
}

function Build-MedicinalIndex {
  param([object[]]$Plants)
  $groups = [ordered]@{
    "Digestive Support" = @()
    "Nervine & Calming" = @()
    "Respiratory Support" = @()
    "Antimicrobial Herbs" = @()
    "Wound & Circulation" = @()
    "Immune and Adaptogen Support" = @()
  }

  foreach ($p in $Plants) {
    $tags = $p.Tags.ToLowerInvariant()
    $actions = $p.Actions.ToLowerInvariant()
    if ($tags -match "#digestive" -or $actions -match "digestive|carminative|bitter") { $groups["Digestive Support"] += $p.Name }
    if ($tags -match "#nervine|#sleep" -or $actions -match "nervine|sedative|calm") { $groups["Nervine & Calming"] += $p.Name }
    if ($tags -match "#respiratory" -or $actions -match "expectorant|respiratory|diaphoretic") { $groups["Respiratory Support"] += $p.Name }
    if ($tags -match "#antimicrobial" -or $actions -match "antimicrobial|antiviral|antibacterial|antifungal") { $groups["Antimicrobial Herbs"] += $p.Name }
    if ($tags -match "#wound|#circulatory" -or $actions -match "vulnerary|wound|circulatory|venotonic") { $groups["Wound & Circulation"] += $p.Name }
    if ($tags -match "#immune|adaptogen" -or $actions -match "immune|adaptogen") { $groups["Immune and Adaptogen Support"] += $p.Name }
  }

  $out = New-Object System.Collections.Generic.List[string]
  $out.Add("# Medicinal Actions Index")
  $out.Add("")
  $out.Add("Organized from plant note metadata and tags.")
  $out.Add("")

  foreach ($k in $groups.Keys) {
    $out.Add("## [[$k]]")
    $out.Add("")
    $names = $groups[$k] | Sort-Object -Unique
    if ($names.Count -eq 0) {
      $out.Add("- None tagged yet.")
    } else {
      foreach ($n in $names) { $out.Add("- [[$n]]") }
    }
    $out.Add("")
  }

  $out.Add("## Quick Navigation")
  $out.Add("")
  $out.Add("- [[Master Plant Index]]")
  $out.Add("- [[Container & Controlled Climate Herbs]]")
  $out.Add("- [[Companion Guilds Index]]")
  $out.Add("- [[Color & Energetics Index]]")
  $out.Add("- [[Month-by-Month Calendar (Zone 7B)]]")
  $out.Add("")
  $out.Add("**Last Updated:** February 16, 2026")

  Set-Content -Path (Join-Path $indexDir "Medicinal Actions Index.md") -Value ($out -join "`r`n") -Encoding utf8
}

function Build-ContainerIndex {
  param([object[]]$Plants)
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add("# Container & Controlled Climate Herbs")
  $out.Add("")
  $out.Add("Herbs that are typically container-grown or need controlled climate support in Zones 6-8.")
  $out.Add("")

  $selected = $Plants | Where-Object {
    $_.Tags.ToLowerInvariant() -match "#container" -or $_.Zone.ToLowerInvariant() -match "container"
  } | Sort-Object Name

  foreach ($p in $selected) {
    $out.Add("- [[$($p.Name)]]")
  }

  $out.Add("")
  $out.Add("## Related")
  $out.Add("")
  $out.Add("- [[Master Plant Index]]")
  $out.Add("- [[Medicinal Actions Index]]")
  $out.Add("- [[Month-by-Month Calendar (Zone 7B)]]")
  $out.Add("")
  $out.Add("**Last Updated:** February 16, 2026")

  Set-Content -Path (Join-Path $indexDir "Container & Controlled Climate Herbs.md") -Value ($out -join "`r`n") -Encoding utf8
}

Normalize-PlantNotes
$plants = Collect-PlantData
Build-MasterIndex -Plants $plants
Build-MedicinalIndex -Plants $plants
Build-ContainerIndex -Plants $plants

Write-Output "Normalized plant notes and regenerated indexes."
