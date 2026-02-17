$ErrorActionPreference = "Stop"

$vaultRoot = "c:\Users\Anubis\GitHub\Obsidian\Gardening-Vault\Vegetable-Vault"
$cropDir = Join-Path $vaultRoot "01_Crops"
$indexDir = Join-Path $vaultRoot "00_Indexes"
$plantingDir = Join-Path $vaultRoot "02_Planting"
$rotationDir = Join-Path $vaultRoot "03_Rotation"

$companionMap = @{
  Asparagus = @(
    "[[Vegetable-Vault/01_Crops/Tomato]]",
    "[[Vegetable-Vault/01_Crops/Parsley]]",
    "[[Herbalism-Vault/01_Plants/Basil]]",
    "[[Herbalism-Vault/01_Plants/Marigold]]"
  )
  Legume = @(
    "[[Vegetable-Vault/01_Crops/Corn Sweet]]",
    "[[Vegetable-Vault/01_Crops/Cucumber]]",
    "[[Vegetable-Vault/01_Crops/Radish]]",
    "[[Herbalism-Vault/01_Plants/Marigold]]"
  )
  Root = @(
    "[[Vegetable-Vault/01_Crops/Onion]]",
    "[[Vegetable-Vault/01_Crops/Lettuce]]",
    "[[Vegetable-Vault/01_Crops/Pea]]",
    "[[Herbalism-Vault/01_Plants/Chives]]"
  )
  Brassica = @(
    "[[Vegetable-Vault/01_Crops/Onion]]",
    "[[Vegetable-Vault/01_Crops/Garlic]]",
    "[[Herbalism-Vault/01_Plants/Dill]]",
    "[[Herbalism-Vault/01_Plants/Chamomile]]"
  )
  Cucurbit = @(
    "[[Vegetable-Vault/01_Crops/Bean Bush]]",
    "[[Vegetable-Vault/01_Crops/Corn Sweet]]",
    "[[Herbalism-Vault/01_Plants/Dill]]",
    "[[Herbalism-Vault/01_Plants/Nasturtium]]"
  )
  Nightshade = @(
    "[[Herbalism-Vault/01_Plants/Basil]]",
    "[[Herbalism-Vault/01_Plants/Marigold]]",
    "[[Vegetable-Vault/01_Crops/Onion]]",
    "[[Vegetable-Vault/01_Crops/Garlic]]"
  )
  Allium = @(
    "[[Vegetable-Vault/01_Crops/Carrot]]",
    "[[Vegetable-Vault/01_Crops/Beet]]",
    "[[Vegetable-Vault/01_Crops/Lettuce]]",
    "[[Herbalism-Vault/01_Plants/Chamomile]]"
  )
  Leafy = @(
    "[[Vegetable-Vault/01_Crops/Carrot]]",
    "[[Vegetable-Vault/01_Crops/Radish]]",
    "[[Vegetable-Vault/01_Crops/Onion]]",
    "[[Herbalism-Vault/01_Plants/Chives]]"
  )
  Corn = @(
    "[[Vegetable-Vault/01_Crops/Bean Pole]]",
    "[[Vegetable-Vault/01_Crops/Pumpkin]]",
    "[[Vegetable-Vault/01_Crops/Winter Squash]]",
    "[[Herbalism-Vault/01_Plants/Marigold]]"
  )
  Potato = @(
    "[[Vegetable-Vault/01_Crops/Bean Bush]]",
    "[[Vegetable-Vault/01_Crops/Cabbage]]",
    "[[Herbalism-Vault/01_Plants/Marigold]]",
    "[[Herbalism-Vault/01_Plants/Horseradish]]"
  )
}

$avoidMap = @{
  Asparagus = @(
    "[[Vegetable-Vault/01_Crops/Onion]]",
    "[[Vegetable-Vault/01_Crops/Garlic]]"
  )
  Legume = @(
    "[[Vegetable-Vault/01_Crops/Onion]]",
    "[[Vegetable-Vault/01_Crops/Garlic]]"
  )
  Root = @(
    "[[Herbalism-Vault/01_Plants/Dill]] (especially with carrots when mature)",
    "Compacted soil and fresh manure"
  )
  Brassica = @(
    "[[Vegetable-Vault/01_Crops/Tomato]]",
    "[[Vegetable-Vault/01_Crops/Bean Pole]]"
  )
  Cucurbit = @(
    "[[Vegetable-Vault/01_Crops/Potato]]",
    "[[Herbalism-Vault/01_Plants/Fennel]]"
  )
  Nightshade = @(
    "[[Herbalism-Vault/01_Plants/Fennel]]",
    "Other disease-prone Solanaceae in the same bed year after year"
  )
  Allium = @(
    "[[Vegetable-Vault/01_Crops/Bean Bush]]",
    "[[Vegetable-Vault/01_Crops/Pea]]"
  )
  Leafy = @(
    "Crowded blocks with poor airflow",
    "Hot, dry, reflected-heat beds"
  )
  Corn = @(
    "[[Vegetable-Vault/01_Crops/Tomato]]",
    "Single-row blocks that prevent pollination"
  )
  Potato = @(
    "[[Vegetable-Vault/01_Crops/Tomato]]",
    "[[Vegetable-Vault/01_Crops/Cucumber]]"
  )
}

$crops = @(
  [pscustomobject]@{Name='Asparagus';File='Asparagus.md';Family='Asparagaceae';Season='Perennial';Feeding='Medium';CompanionGroup='Asparagus';SeedDepth='6-8 in (crowns)';RowSpacing='36-42 in';PlantSpacing='12-18 in';Spring='Mar 1-Apr 15';Fall='';Transplant='Mar 1-Apr 15 (crowns)';Indoor='Use crowns for quickest establishment';Harvest='Apr-Jun (year 3 onward)';TransplantMode='Direct';Rotation='Permanent bed; top-dress with compost yearly';Varieties=@('Jersey Knight: all-male high-yield spears','Mary Washington: classic heirloom with good flavor','Purple Passion: sweeter purple spears');Notes='Do not harvest heavily the first two seasons.'},
  [pscustomobject]@{Name='Bean Bush';File='Bean Bush.md';Family='Fabaceae';Season='Warm';Feeding='Nitrogen Fixer';CompanionGroup='Legume';SeedDepth='1-1.5 in';RowSpacing='24-36 in';PlantSpacing='2-3 in';Spring='Apr 15-Jul 15';Fall='Jul 10-Aug 1';Transplant='Usually direct sow only';Indoor='Direct sow after soil warms';Harvest='Jun-Sep';TransplantMode='Direct';Rotation='Good crop before heavy feeders';Varieties=@('Provider: early and reliable','Contender: heat-tolerant bush type','Dragon Tongue: dual-purpose flat pod');Notes='Inoculate seed when beds are new to legumes.'},
  [pscustomobject]@{Name='Bean Pole';File='Bean Pole.md';Family='Fabaceae';Season='Warm';Feeding='Nitrogen Fixer';CompanionGroup='Legume';SeedDepth='1-1.5 in';RowSpacing='36-42 in';PlantSpacing='4-6 in';Spring='Apr 15-Jun 15';Fall='Jul 10-Aug 1';Transplant='Direct sow at trellis base';Indoor='Direct sow preferred';Harvest='Jul-Oct';TransplantMode='Direct';Rotation='Follow with brassicas or fruiting crops';Varieties=@('Kentucky Wonder: classic pole snap bean','Blue Lake Pole: heavy producer','Fortex: long tender filet bean');Notes='Provide a strong trellis before sowing.'},
  [pscustomobject]@{Name='Bean Lima';File='Bean Lima.md';Family='Fabaceae';Season='Warm';Feeding='Medium';CompanionGroup='Legume';SeedDepth='1-1.5 in';RowSpacing='36-42 in';PlantSpacing='4-6 in';Spring='Apr 25-Jun 1';Fall='';Transplant='Direct sow only in warm soil';Indoor='Direct sow after frost';Harvest='Jul-Sep';TransplantMode='Direct';Rotation='Good bridge crop before leafy greens';Varieties=@('Henderson Bush: compact and early','Fordhook 242: large seeded bush lima','Christmas Lima: speckled heirloom pole type');Notes='Needs consistent warmth for pod set.'},
  [pscustomobject]@{Name='Beet';File='Beet.md';Family='Amaranthaceae';Season='Cool';Feeding='Light';CompanionGroup='Root';SeedDepth='1/2 in';RowSpacing='12-18 in';PlantSpacing='2-3 in';Spring='Mar 15-Apr 15';Fall='Jul 15-Aug 15';Transplant='Direct sow for best roots';Indoor='Direct sow preferred';Harvest='May-Jun and Sep-Nov';TransplantMode='Direct';Rotation='Excellent after heavy feeders';Varieties=@('Detroit Dark Red: standard storage beet','Chioggia: candy-stripe interior','Cylindra: long roots for slicing');Notes='Thin clusters early; each seed ball can sprout multiple plants.'},
  [pscustomobject]@{Name='Broccoli';File='Broccoli.md';Family='Brassicaceae';Season='Cool';Feeding='Heavy';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in seed; set transplants about 3 in deep';RowSpacing='36-42 in';PlantSpacing='18-24 in';Spring='Mar 1-Apr 1';Fall='Jul 1-Jul 31';Transplant='Mar 1-Apr 1 and Jul 1-Jul 31';Indoor='Start 5-7 weeks before transplant dates';Harvest='May-Jun and Oct-Nov';TransplantMode='Transplant';Rotation='Do not follow other brassicas';Varieties=@('Green Magic: heat-tolerant heading type','Belstar: reliable fall performance','De Cicco: side-shoot heirloom');Notes='Use insect netting early against cabbage worms.'},
  [pscustomobject]@{Name='Brussels Sprouts';File='Brussels Sprouts.md';Family='Brassicaceae';Season='Cool';Feeding='Heavy';CompanionGroup='Brassica';SeedDepth='1/2 in seed; set transplants about 3 in deep';RowSpacing='36-42 in';PlantSpacing='18-24 in';Spring='';Fall='Jul 1-Jul 15';Transplant='Jul 1-Jul 15';Indoor='Start 5-7 weeks before transplanting';Harvest='Oct-Dec';TransplantMode='Transplant';Rotation='Keep 3-year gap from other brassicas';Varieties=@('Long Island Improved: heirloom standard','Diablo: uniform hybrid sprouts','Jade Cross: compact early hybrid');Notes='Flavor improves after light frost.'},
  [pscustomobject]@{Name='Cabbage';File='Cabbage.md';Family='Brassicaceae';Season='Cool';Feeding='Heavy';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in seed; set transplants about 3 in deep';RowSpacing='36-42 in';PlantSpacing='12-24 in';Spring='Mar 1-Apr 1';Fall='Jul 15-Aug 15';Transplant='Mar 1-Apr 1 and Jul 15-Aug 15';Indoor='Start 5-7 weeks before transplanting';Harvest='May-Jun and Oct-Dec';TransplantMode='Transplant';Rotation='Follow with legumes or roots';Varieties=@('Early Jersey Wakefield: pointed early cabbage','Golden Acre: compact round heads','Storage No. 4: long keeper');Notes='Keep growth steady to avoid splitting.'},
  [pscustomobject]@{Name='Cantaloupe';File='Cantaloupe.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='60-72 in';PlantSpacing='24-36 in';Spring='Apr 25-Jun 15';Fall='';Transplant='Apr 25-May 20 (optional transplants)';Indoor='Start 2-3 weeks before transplanting';Harvest='Jul-Sep';TransplantMode='Either';Rotation='Do not repeat cucurbits in same bed yearly';Varieties=@('Hales Best: classic netted melon','Athena: strong disease resistance','Sugar Cube: smaller personal-size fruits');Notes='Use black plastic or mulch to warm soil quickly.'},
  [pscustomobject]@{Name='Carrot';File='Carrot.md';Family='Apiaceae';Season='Cool';Feeding='Light';CompanionGroup='Root';SeedDepth='1/4-1/2 in';RowSpacing='12-18 in';PlantSpacing='1-2 in';Spring='Mar 15-Apr 15';Fall='Jul 15-Aug 1';Transplant='Direct sow only';Indoor='Direct sow preferred';Harvest='Jun-Jul and Oct-Dec';TransplantMode='Direct';Rotation='Great cleanup crop after heavy feeders';Varieties=@('Nantes: sweet blunt-tipped roots','Danvers 126: reliable storage type','Scarlet Nantes: smooth roots for fresh eating');Notes='Keep topsoil evenly moist through germination.'},
  [pscustomobject]@{Name='Cauliflower';File='Cauliflower.md';Family='Brassicaceae';Season='Cool';Feeding='Heavy';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in seed; set transplants about 3 in deep';RowSpacing='36-42 in';PlantSpacing='18-24 in';Spring='Mar 1-Apr 1';Fall='Jul 1-Jul 31';Transplant='Mar 1-Apr 1 and Jul 1-Jul 31';Indoor='Start 5-7 weeks before transplanting';Harvest='May-Jun and Oct-Nov';TransplantMode='Transplant';Rotation='Avoid planting after any brassica crop';Varieties=@('Snow Crown: dependable early white heads','Amazing: broad adaptation hybrid','Graffiti: purple curds with mild flavor');Notes='Keep moisture consistent to prevent buttoning.'},
  [pscustomobject]@{Name='Celery';File='Celery.md';Family='Apiaceae';Season='Cool';Feeding='Heavy';CompanionGroup='Leafy';SeedDepth='1/4 in';RowSpacing='24 in';PlantSpacing='6-8 in';Spring='Jan 15-Feb 15 (start transplants)';Fall='Jul 1-Aug 15 (fall crop starts)';Transplant='Mar-Apr and Aug-Sep after hardening';Indoor='Start 8-10 weeks before transplanting';Harvest='Jun-Jul and Oct-Dec';TransplantMode='Transplant';Rotation='Follow with legumes to rebuild fertility';Varieties=@('Tall Utah: common home-garden celery','Tango: vigorous green stalk type','Golden Self-Blanching: easier blanching variety');Notes='Needs consistent moisture and rich soil for crisp stalks.'},
  [pscustomobject]@{Name='Collards';File='Collards.md';Family='Brassicaceae';Season='Cool';Feeding='Medium';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in';RowSpacing='36-42 in';PlantSpacing='18-24 in';Spring='Mar 1-Apr 15';Fall='Jul 1-Aug 15';Transplant='Mar-Apr and Jul-Aug';Indoor='Start 4-6 weeks before transplanting';Harvest='May-Jun and Oct-Jan';TransplantMode='Either';Rotation='Fits after legumes or onions';Varieties=@('Georgia Southern: heat- and cold-tolerant classic','Champion: compact smooth leaves','Top Bunch: upright habit for tight spacing');Notes='Harvest lower leaves first for steady production.'},
  [pscustomobject]@{Name='Corn Sweet';File='Corn Sweet.md';Family='Poaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Corn';SeedDepth='1 in';RowSpacing='30-36 in';PlantSpacing='8-12 in';Spring='Apr 15-Jun 10';Fall='Jul 1-Jul 15';Transplant='Direct sow in blocks';Indoor='Direct sow only';Harvest='Jul-Sep';TransplantMode='Direct';Rotation='Heavy feeder; follow with peas/beans';Varieties=@('Honey Select: triple-sweet bicolor','Silver Queen: old-school white ears','Bodacious: sugary yellow hybrid');Notes='Plant in 4+ row blocks for better pollination.'},
  [pscustomobject]@{Name='Cucumber';File='Cucumber.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='60-72 in';PlantSpacing='12-36 in';Spring='Apr 25-Jun 15';Fall='Jul 1-Jul 15';Transplant='Apr 25-May 20 (optional)';Indoor='Start 2-3 weeks before transplanting';Harvest='Jun-Sep';TransplantMode='Either';Rotation='Avoid repeated cucurbit planting in same bed';Varieties=@('Marketmore 76: slicer with good disease resistance','Boston Pickling: compact pickling type','Diva: smooth burpless fruits');Notes='Trellising improves airflow and straight fruit.'},
  [pscustomobject]@{Name='Eggplant';File='Eggplant.md';Family='Solanaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Nightshade';SeedDepth='1/4 in seed; set transplants about 3 in deep';RowSpacing='24-36 in';PlantSpacing='24-36 in';Spring='May 1-Jun 15';Fall='';Transplant='May 1-Jun 15';Indoor='Start 6-8 weeks before transplanting';Harvest='Jul-Oct';TransplantMode='Transplant';Rotation='Do not follow tomato/pepper/potato';Varieties=@('Black Beauty: classic globe eggplant','Ichiban: slender Asian type','Fairy Tale: small striped fruits');Notes='Wait for warm nights before setting plants out.'},
  [pscustomobject]@{Name='Garlic';File='Garlic.md';Family='Amaryllidaceae';Season='Cool';Feeding='Medium';CompanionGroup='Allium';SeedDepth='1-2 in (cloves)';RowSpacing='6-12 in';PlantSpacing='3-6 in';Spring='';Fall='Sep 15-Nov 15';Transplant='Plant cloves in fall';Indoor='No indoor start needed';Harvest='Jun-Jul';TransplantMode='Direct';Rotation='Good disease-break crop between heavy feeders';Varieties=@('Music: hardy hardneck with large cloves','Inchelium Red: productive softneck keeper','Chesnok Red: flavorful purple-striped hardneck');Notes='Mulch heavily after planting for winter protection.'},
  [pscustomobject]@{Name='Kale';File='Kale.md';Family='Brassicaceae';Season='Cool';Feeding='Medium';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in';RowSpacing='24-36 in';PlantSpacing='8-12 in';Spring='Mar 1-Apr 15';Fall='Jul 15-Aug 15';Transplant='Mar-Apr and Jul-Aug';Indoor='Start 4-6 weeks before transplanting';Harvest='Apr-Jun and Oct-Jan';TransplantMode='Either';Rotation='Useful bridge after legumes';Varieties=@('Lacinato: dark blistered leaves','Red Russian: tender frilly flat leaf','Winterbor: curly cold-hardy type');Notes='Sweeter flavor after frost.'},
  [pscustomobject]@{Name='Kohlrabi';File='Kohlrabi.md';Family='Brassicaceae';Season='Cool';Feeding='Medium';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in seed; transplants about 3 in deep';RowSpacing='24 in';PlantSpacing='6-8 in';Spring='Feb 1-Mar 15';Fall='Aug 15-Sep 30';Transplant='Early spring and late summer';Indoor='Start 4-6 weeks before transplanting';Harvest='Apr-May and Oct-Nov';TransplantMode='Either';Rotation='Short-season brassica for rotation gaps';Varieties=@('Early White Vienna: pale green bulbs','Purple Vienna: purple skin, white flesh','Konan: uniform hybrid bulbs');Notes='Harvest when bulbs are 2-3 inches for tenderness.'},
  [pscustomobject]@{Name='Leek';File='Leek.md';Family='Amaryllidaceae';Season='Cool';Feeding='Medium';CompanionGroup='Allium';SeedDepth='1/4 in seed; set transplants about 3 in deep';RowSpacing='24 in';PlantSpacing='3-4 in';Spring='Jan 15-Feb 15 (start plants)';Fall='Jul 1-Aug 15 (start for fall)';Transplant='Mar-Apr and Aug-Sep';Indoor='Start 8-10 weeks before transplanting';Harvest='Jun-Jul and Oct-Jan';TransplantMode='Transplant';Rotation='Moderate feeder; good before root crops';Varieties=@('King Richard: fast maturing summer leek','American Flag: classic full-size leek','Lancelot: long white shank hybrid');Notes='Hill soil around stems to blanch shanks.'},
  [pscustomobject]@{Name='Lettuce';File='Lettuce.md';Family='Asteraceae';Season='Cool';Feeding='Light';CompanionGroup='Leafy';SeedDepth='1/8 in';RowSpacing='12-18 in';PlantSpacing='6-12 in';Spring='Mar 1-Apr 15';Fall='Aug 1-Aug 31';Transplant='Mar-Apr and Aug-Sep';Indoor='Start 4-6 weeks before transplanting';Harvest='Apr-Jun and Sep-Nov';TransplantMode='Either';Rotation='Excellent quick crop after heavy feeders';Varieties=@('Butterhead: soft loose heads','Romaine: upright crunchy leaves','Looseleaf: cut-and-come-again mix');Notes='Provide afternoon shade for late spring plantings.'},
  [pscustomobject]@{Name='Mustard Greens';File='Mustard Greens.md';Family='Brassicaceae';Season='Cool';Feeding='Light';CompanionGroup='Brassica';SeedDepth='1/4-1/2 in';RowSpacing='12-24 in';PlantSpacing='2-4 in';Spring='Mar 1-Apr 15';Fall='Aug 1-Sep 15';Transplant='Direct sow preferred';Indoor='Direct sow preferred';Harvest='Apr-May and Sep-Nov';TransplantMode='Direct';Rotation='Fast crop that fits between heavy feeders';Varieties=@('Southern Giant Curled: traditional spicy leaves','Red Giant: red-green broad leaves','Mizuna: mild fringed Asian mustard');Notes='Successive sow every 2 weeks for steady harvests.'},
  [pscustomobject]@{Name='Okra';File='Okra.md';Family='Malvaceae';Season='Warm';Feeding='Medium';CompanionGroup='Leafy';SeedDepth='1/2-1 in';RowSpacing='36-42 in';PlantSpacing='12-24 in';Spring='May 15-Jun 15';Fall='';Transplant='Direct sow after heat arrives';Indoor='Optional 3-4 week start in biodegradable pots';Harvest='Jul-Oct';TransplantMode='Either';Rotation='Works after peas/beans in warm beds';Varieties=@('Clemson Spineless: standard green pod','Jambalaya: compact early producer','Burgundy: red decorative pods');Notes='Harvest pods small and often for tenderness.'},
  [pscustomobject]@{Name='Onion';File='Onion.md';Family='Amaryllidaceae';Season='Cool';Feeding='Medium';CompanionGroup='Allium';SeedDepth='1/2 in seed (sets shallow)';RowSpacing='12-24 in';PlantSpacing='2-4 in';Spring='Mar 1-Apr 15 (sets/transplants)';Fall='Sep 15-Nov 15 (overwintering types)';Transplant='Mar-Apr for spring bulbing';Indoor='Start 8-10 weeks before spring transplanting';Harvest='Jun-Aug';TransplantMode='Either';Rotation='Good between brassicas and fruiting crops';Varieties=@('Walla Walla: sweet day-neutral type','Patterson: long storage onion','Red Creole: pungent red storage type');Notes='Use day-length-appropriate cultivars for best bulb size.'},
  [pscustomobject]@{Name='Parsley';File='Parsley.md';Family='Apiaceae';Season='Cool';Feeding='Light';CompanionGroup='Leafy';SeedDepth='1/4-1/2 in';RowSpacing='12-24 in';PlantSpacing='3-6 in';Spring='Mar 15-Apr 15';Fall='Jul 15-Aug 1';Transplant='Mar-Apr and Aug';Indoor='Start 6-8 weeks before transplanting';Harvest='May-Nov';TransplantMode='Either';Rotation='Light feeder useful as bed-edge crop';Varieties=@('Flat-leaf Italian: strong culinary flavor','Curled: decorative dense foliage','Hamburg: grown for edible root and tops');Notes='Soak seed overnight to speed germination.'},
  [pscustomobject]@{Name='Parsnip';File='Parsnip.md';Family='Apiaceae';Season='Cool';Feeding='Light';CompanionGroup='Root';SeedDepth='1/2 in';RowSpacing='18-24 in';PlantSpacing='3-6 in';Spring='Feb 15-Apr 30';Fall='';Transplant='Direct sow only';Indoor='Direct sow fresh seed';Harvest='Oct-Jan';TransplantMode='Direct';Rotation='Follow heavy feeders or corn';Varieties=@('Hollow Crown: traditional long root','Gladiator: uniform hybrid roots','Javelin: smooth tapered roots');Notes='Flavor improves after frost exposure.'},
  [pscustomobject]@{Name='Pea';File='Pea.md';Family='Fabaceae';Season='Cool';Feeding='Nitrogen Fixer';CompanionGroup='Legume';SeedDepth='1-1.5 in';RowSpacing='18-24 in';PlantSpacing='2-3 in';Spring='Mar 1-Apr 15';Fall='Jul 15-Aug 1';Transplant='Direct sow preferred';Indoor='Direct sow in cool soil';Harvest='May-Jun and Oct';TransplantMode='Direct';Rotation='Plant before heavy summer feeders';Varieties=@('Sugar Snap: edible pod snap pea','Green Arrow: shelling pea with long picking window','Little Marvel: compact shelling pea');Notes='Trellis even semi-dwarf types for cleaner harvest.'},
  [pscustomobject]@{Name='Pepper';File='Pepper.md';Family='Solanaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Nightshade';SeedDepth='1/4 in seed; set transplants about 3 in deep';RowSpacing='24-36 in';PlantSpacing='15-18 in';Spring='May 1-Jun 15';Fall='';Transplant='May 1-Jun 15';Indoor='Start 6-8 weeks before transplanting';Harvest='Jul-Oct';TransplantMode='Transplant';Rotation='Do not follow tomato, potato, or eggplant';Varieties=@('California Wonder: blocky sweet bell','Jalapeno: medium-heat hot pepper','Poblano: mild heat roasting pepper');Notes='Use row cover early to speed establishment and block pests.'},
  [pscustomobject]@{Name='Potato';File='Potato.md';Family='Solanaceae';Season='Cool';Feeding='Heavy';CompanionGroup='Potato';SeedDepth='3-4 in';RowSpacing='36-42 in';PlantSpacing='8-12 in';Spring='Mar 15-Apr 15';Fall='';Transplant='Plant seed pieces in spring';Indoor='No indoor start';Harvest='Jun-Jul';TransplantMode='Direct';Rotation='Follow with beans, peas, or leafy crops';Varieties=@('Yukon Gold: yellow all-purpose potato','Kennebec: white storage and frying type','Red Pontiac: red-skinned early-mid type');Notes='Hill soil around stems to prevent green tubers.'},
  [pscustomobject]@{Name='Pumpkin';File='Pumpkin.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='60-96 in';PlantSpacing='24-60 in';Spring='Jun 15-Jul 1';Fall='';Transplant='Direct sow preferred';Indoor='Optional 2-week start in compostable pots';Harvest='Sep-Oct';TransplantMode='Either';Rotation='Keep out of same bed as cucumbers/squash for 2-3 years';Varieties=@('Small Sugar: dense sweet pie flesh','Howden: classic jack-o-lantern type','Jack Be Little: mini ornamental edible');Notes='Match maturity days to desired October harvest date.'},
  [pscustomobject]@{Name='Radish';File='Radish.md';Family='Brassicaceae';Season='Cool';Feeding='Light';CompanionGroup='Root';SeedDepth='1/4-1/2 in';RowSpacing='12-24 in';PlantSpacing='1-2 in';Spring='Mar 1-Apr 15';Fall='Aug 15-Sep 15';Transplant='Direct sow only';Indoor='Direct sow preferred';Harvest='Apr-May and Sep-Oct';TransplantMode='Direct';Rotation='Fast turnover crop for succession gaps';Varieties=@('Cherry Belle: quick spring globe radish','French Breakfast: elongated mild roots','Daikon: long storage and cover-crop root');Notes='Sow in short intervals to prevent glut and pithiness.'},
  [pscustomobject]@{Name='Rutabaga';File='Rutabaga.md';Family='Brassicaceae';Season='Cool';Feeding='Medium';CompanionGroup='Brassica';SeedDepth='1/2 in';RowSpacing='12-18 in';PlantSpacing='6-8 in';Spring='';Fall='Jul 1-Aug 15';Transplant='Direct sow for fall crop';Indoor='Direct sow preferred';Harvest='Oct-Dec';TransplantMode='Direct';Rotation='Good follow-up to legumes';Varieties=@('Laurentian: classic purple-top rutabaga','American Purple Top: hardy storage type','Joan: smooth hybrid roots');Notes='Keep evenly watered during bulb expansion.'},
  [pscustomobject]@{Name='Southern Pea';File='Southern Pea.md';Family='Fabaceae';Season='Warm';Feeding='Nitrogen Fixer';CompanionGroup='Legume';SeedDepth='1-1.5 in';RowSpacing='24-36 in';PlantSpacing='3-4 in';Spring='Apr 15-Jun 15';Fall='';Transplant='Direct sow after frost';Indoor='Direct sow preferred';Harvest='Jul-Sep';TransplantMode='Direct';Rotation='Excellent summer soil-building crop';Varieties=@('California Blackeye No. 5: classic black-eyed pea','Pinkeye Purple Hull: flavorful southern type','Cream 40: tender cream pea');Notes='Tolerates heat better than many beans.'},
  [pscustomobject]@{Name='Spinach';File='Spinach.md';Family='Amaranthaceae';Season='Cool';Feeding='Light';CompanionGroup='Leafy';SeedDepth='1/2 in';RowSpacing='12-18 in';PlantSpacing='2-4 in';Spring='Mar 1-Apr 1';Fall='Aug 15-Sep 15';Transplant='Direct sow preferred';Indoor='Direct sow in cool soil';Harvest='Apr-May and Oct-Nov';TransplantMode='Direct';Rotation='Great after heavy summer crops';Varieties=@('Bloomsdale Long Standing: savoy heirloom','Space: smooth-leaf hybrid','Tyee: disease-resistant savoy');Notes='Provide shade cloth for late spring plantings.'},
  [pscustomobject]@{Name='Squash';File='Squash.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='48-72 in';PlantSpacing='18-36 in';Spring='Apr 25-Jun 15';Fall='Jul 1-Jul 15';Transplant='Apr 25-May 20 (optional)';Indoor='Start 2-3 weeks before transplanting';Harvest='Jun-Sep';TransplantMode='Either';Rotation='Rotate away from cucurbits for 2-3 years';Varieties=@('Yellow Straightneck: classic summer squash','Pattypan: scalloped tender fruits','Cocozelle: striped elongated heirloom');Notes='Harvest young fruits for best texture.'},
  [pscustomobject]@{Name='Sweet Potato';File='Sweet Potato.md';Family='Convolvulaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Root';SeedDepth='6-8 in (slip depth in loose bed)';RowSpacing='36-42 in';PlantSpacing='12-24 in';Spring='May 15-Jun 15';Fall='';Transplant='May 15-Jun 15 (slips)';Indoor='Order or start slips 6-8 weeks before planting';Harvest='Sep-Oct';TransplantMode='Transplant';Rotation='Follow with legumes or leafy greens';Varieties=@('Beauregard: reliable orange storage roots','Covington: sweet high-yield type','Georgia Jet: early maturing heirloom');Notes='Cure roots after harvest for better sweetness and storage.'},
  [pscustomobject]@{Name='Swiss Chard';File='Swiss Chard.md';Family='Amaranthaceae';Season='Cool';Feeding='Medium';CompanionGroup='Leafy';SeedDepth='1/2 in';RowSpacing='18-24 in';PlantSpacing='6-8 in';Spring='Mar 15-Apr 15';Fall='Jul 15-Aug 15';Transplant='Mar-Apr and Jul-Aug (optional)';Indoor='Start 4-5 weeks before transplanting if desired';Harvest='May-Nov';TransplantMode='Either';Rotation='Good after legumes or root crops';Varieties=@('Bright Lights: multicolor stems','Fordhook Giant: broad green leaves','Ruby Red: deep red stems and veins');Notes='Cut outer leaves regularly for long harvest period.'},
  [pscustomobject]@{Name='Tomato';File='Tomato.md';Family='Solanaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Nightshade';SeedDepth='1/4 in seed; set transplants 4-6 in deep';RowSpacing='36-48 in';PlantSpacing='24-36 in';Spring='Apr 25-Jun 15';Fall='Jul 1-Jul 15 (fall crop transplants)';Transplant='Apr 25-Jun 15 and Jul 1-Jul 15';Indoor='Start 5-8 weeks before transplanting';Harvest='Jul-Oct';TransplantMode='Transplant';Rotation='Follow with beans, peas, or leafy greens';Varieties=@('Cherry: small fruits, long harvest','Roma/plum: dense flesh for sauce','Slicer/beefsteak: larger fruits for fresh use');Notes='Determine if you want determinate (compact) or indeterminate (vining) types.'},
  [pscustomobject]@{Name='Turnip';File='Turnip.md';Family='Brassicaceae';Season='Cool';Feeding='Light';CompanionGroup='Brassica';SeedDepth='1/2 in';RowSpacing='12-24 in';PlantSpacing='2-4 in';Spring='Mar 1-Apr 15';Fall='Aug 1-Sep 15';Transplant='Direct sow preferred';Indoor='Direct sow preferred';Harvest='May-Jun and Oct-Nov';TransplantMode='Direct';Rotation='Useful quick crop after summer beds clear';Varieties=@('Purple Top White Globe: standard dual-purpose turnip','Hakurei: tender sweet salad turnip','Seven Top: grown mainly for greens');Notes='Thin early to size roots before heat stress.'},
  [pscustomobject]@{Name='Watermelon';File='Watermelon.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='72-96 in';PlantSpacing='36-48 in';Spring='Apr 25-Jun 15';Fall='';Transplant='Apr 25-May 20 (optional)';Indoor='Start 2-3 weeks before transplanting';Harvest='Jul-Sep';TransplantMode='Either';Rotation='Do not follow cucurbits in same area';Varieties=@('Sugar Baby: small icebox melon','Crimson Sweet: mid-size striped classic','Charleston Gray: large elongated heirloom');Notes='Use row cover early then remove at flowering for pollination.'},
  [pscustomobject]@{Name='Winter Squash';File='Winter Squash.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='60-84 in';PlantSpacing='24-48 in';Spring='May 1-Jun 15';Fall='';Transplant='May 1-May 25 (optional)';Indoor='Start 2-3 weeks before transplanting';Harvest='Sep-Oct';TransplantMode='Either';Rotation='Rotate cucurbits on 3-year cycle';Varieties=@('Waltham Butternut: long-keeping tan fruits','Delicata: quick, sweet striped fruits','Acorn Table Queen: compact vines and small fruits');Notes='Cure fruits 10-14 days after harvest for storage.'},
  [pscustomobject]@{Name='Zucchini';File='Zucchini.md';Family='Cucurbitaceae';Season='Warm';Feeding='Heavy';CompanionGroup='Cucurbit';SeedDepth='1 in';RowSpacing='48-72 in';PlantSpacing='18-24 in';Spring='Apr 25-Jun 15';Fall='Jul 1-Jul 15';Transplant='Apr 25-May 20 (optional)';Indoor='Start 2-3 weeks before transplanting';Harvest='Jun-Sep';TransplantMode='Either';Rotation='Keep away from last-year cucurbit beds';Varieties=@('Black Beauty: dependable dark green classic','Costata Romanesco: ribbed Italian heirloom','Eight Ball: round fruits for stuffing');Notes='Pick fruits at 6-8 inches for peak quality.'}
)

function Get-Defaults([string]$season) {
  switch ($season) {
    'Warm' { return @{LifeCycle='Annual';Sun='Full';Soil='Fertile, well-drained';Water='Moderate, steady moisture';Zone='7B (warm-season annual)'} }
    'Cool' { return @{LifeCycle='Annual/Biennial';Sun='Full to partial';Soil='Fertile, moisture-retentive, well-drained';Water='Moderate';Zone='7B (cool-season crop)'} }
    'Perennial' { return @{LifeCycle='Perennial';Sun='Full';Soil='Well-drained loam with compost';Water='Moderate';Zone='7B'} }
    default { return @{LifeCycle='Annual';Sun='Full';Soil='Well-drained';Water='Moderate';Zone='7B'} }
  }
}

function To-Bullets([string[]]$items) {
  return ($items | ForEach-Object { "- $_" }) -join "`r`n"
}

foreach ($crop in $crops) {
  $d = Get-Defaults $crop.Season
  $companions = if ($companionMap.ContainsKey($crop.CompanionGroup)) { $companionMap[$crop.CompanionGroup] } else { @('[[Herbalism-Vault/01_Plants/Marigold]]') }
  $avoid = if ($avoidMap.ContainsKey($crop.CompanionGroup)) { $avoidMap[$crop.CompanionGroup] } else { @('Overcrowding', 'Poor airflow') }

  $calendarLines = @()
  if ($crop.Spring) { $calendarLines += "- Spring sow/plant window: $($crop.Spring)" }
  if ($crop.Fall) { $calendarLines += "- Fall sow/plant window: $($crop.Fall)" }
  if ($crop.Transplant) { $calendarLines += "- Outdoor transplant window: $($crop.Transplant)" }
  if ($crop.Indoor) { $calendarLines += "- Indoor start lead time: $($crop.Indoor)" }
  $calendarLines += "- Frost baseline used: last spring frost Apr 5-Apr 15; first fall frost Oct 25-Nov 5."

  $transplantBlock = switch ($crop.TransplantMode) {
    'Transplant' {
@"
- Best method: transplant starts/slips/crowns in the window above.
- Harden off starts for 7-10 days before planting outdoors.
- Transplant in late afternoon or on cloudy days to reduce shock.
- Water in thoroughly and mulch after soil has warmed.
"@
    }
    'Either' {
@"
- Direct sow is effective once soil is warm enough.
- Optional transplanting can speed harvest by 1-2 weeks.
- Harden off starts for 7-10 days and avoid root disturbance.
- Water in deeply after planting and keep moisture steady until new growth.
"@
    }
    default {
@"
- Direct sow/planting is the standard method for this crop.
- Prepare a fine seedbed and keep topsoil evenly moist through germination.
- Thin seedlings early to final spacing to reduce disease pressure.
"@
    }
  }

  $tags = ($crop.Name.ToLower() -replace '[^a-z0-9]+','-').Trim('-')
  $note = @"
---
Type: Vegetable
Family: $($crop.Family)
Life Cycle: $($d.LifeCycle)
Height: Varies by cultivar
Spread: Varies by cultivar
Root Depth: Varies by cultivar
Sun: $($d.Sun)
Soil: $($d.Soil)
Water: $($d.Water)
Zone: $($d.Zone)
Start Month: $($crop.Spring)
Harvest: $($crop.Harvest)
Feeding Level: $($crop.Feeding)
Companion Group: $($crop.CompanionGroup)
Tags: $tags, zone-7b, vegetable
---

# $($crop.Name)

## Quick Use Guide
- Seed depth: $($crop.SeedDepth)
- Spacing: rows $($crop.RowSpacing), plants $($crop.PlantSpacing)
- Feeding level: $($crop.Feeding)
- Rotation note: $($crop.Rotation)

## Planting Calendar (Zone 7B)
$($calendarLines -join "`r`n")

## Seed Depth and Spacing
- Seed/planting depth: $($crop.SeedDepth)
- Row spacing: $($crop.RowSpacing)
- In-row spacing: $($crop.PlantSpacing)
- Timing windows verified against Virginia Cooperative Extension (Table 3) and Clemson Extension planting chart.

## Transplanting Time and Procedure
$($transplantBlock.Trim())

## Companion Plants
$(To-Bullets $companions)

## Avoid Planting Near
$(To-Bullets $avoid)

## Varieties
$(To-Bullets $crop.Varieties)

## Crop Notes
$($crop.Notes)

## Verified References
- [Virginia Cooperative Extension - Home Vegetable Gardening in Virginia (Table 3)](https://www.pubs.ext.vt.edu/426/426-331/426-331.html)
- [Clemson Cooperative Extension - Planning a Garden (Table 2)](https://hgic.clemson.edu/factsheet/planning-a-garden/)
- [WVU Extension - Companion Planting in the Garden](https://extension.wvu.edu/lawn-gardening-pests/gardening/garden-management/companion-planting)
- [University of Maryland Extension - Planting Transplants in Your Garden](https://extension.umd.edu/resource/planting-transplants-your-garden/)
"@

  Set-Content -Path (Join-Path $cropDir $crop.File) -Value $note -Encoding utf8
}

$sorted = $crops | Sort-Object Name

function Link-ForCrop($crop) {
  $base = [System.IO.Path]::GetFileNameWithoutExtension($crop.File)
  return "[[Vegetable-Vault/01_Crops/$base]]"
}

$alpha = ($sorted | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"

function Format-SeasonWindow($crop) {
  $parts = @()
  if ($crop.Spring) { $parts += "Spring $($crop.Spring)" }
  if ($crop.Fall) { $parts += "Fall $($crop.Fall)" }
  if ($parts.Count -eq 0) { $parts += "See crop note" }
  return "- $(Link-ForCrop $crop): " + ($parts -join '; ')
}

$cool = (($sorted | Where-Object { $_.Season -eq 'Cool' }) | ForEach-Object { Format-SeasonWindow $_ }) -join "`r`n"
$warm = (($sorted | Where-Object { $_.Season -eq 'Warm' }) | ForEach-Object { Format-SeasonWindow $_ }) -join "`r`n"
$perennial = (($sorted | Where-Object { $_.Season -eq 'Perennial' }) | ForEach-Object { Format-SeasonWindow $_ }) -join "`r`n"

$masterIndex = @"
# Master Crop Index

Comprehensive Zone 7B crop index. Each crop note includes seed depth, sowing windows, transplant timing/procedure, companion notes, and varieties.

## Alphabetical
$alpha

## By Season

### Cool Season
$cool

### Warm Season
$warm

### Perennial Beds
$perennial

## Priority Crops Requested
- [[Vegetable-Vault/01_Crops/Cucumber]]
- [[Vegetable-Vault/01_Crops/Zucchini]]
- [[Vegetable-Vault/01_Crops/Watermelon]]
- [[Vegetable-Vault/01_Crops/Pumpkin]]
- [[Vegetable-Vault/01_Crops/Cantaloupe]]

**Last Updated:** February 17, 2026
"@
Set-Content -Path (Join-Path $indexDir 'Master Crop Index.md') -Value $masterIndex -Encoding utf8

$heavy = $sorted | Where-Object { $_.Feeding -eq 'Heavy' }
$medium = $sorted | Where-Object { $_.Feeding -eq 'Medium' }
$light = $sorted | Where-Object { $_.Feeding -eq 'Light' }
$nfix = $sorted | Where-Object { $_.Feeding -eq 'Nitrogen Fixer' }

$feedDoc = @"
# Feeding Requirements

Use this index for fertility planning and rotation sequencing in Zone 7B.

## Heavy Feeders
$((($heavy | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

## Medium Feeders
$((($medium | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

## Light Feeders
$((($light | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

## Nitrogen Fixers
$((($nfix | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

## Rotation Rule of Thumb
- Sequence beds as heavy -> medium -> light -> nitrogen fixer.
- Avoid planting the same family in the same bed in back-to-back years.
"@
Set-Content -Path (Join-Path $indexDir 'Feeding Requirements.md') -Value $feedDoc -Encoding utf8

$groupDescriptions = @{
  Asparagus = 'Long-term perennial bed companions.'
  Legume = 'Nitrogen-fixing crops that support following feeders.'
  Root = 'Direct-sown root crops and root companions.'
  Brassica = 'Cool-season brassica crops with shared pest profile.'
  Cucurbit = 'Vining and sprawling warm-season crops.'
  Nightshade = 'Tomato/pepper/eggplant-style fruiting crops.'
  Allium = 'Onion-family crops used for pest pressure moderation.'
  Leafy = 'Leaf-harvest crops that like steady moisture and airflow.'
  Corn = 'Block-planted corn and three-sisters partners.'
  Potato = 'Tuber crop grouping for blight-aware rotation planning.'
}

$compLines = @("# Companion Groups", "", "Group crops by companion behavior and rotation category.", "")
foreach ($group in $groupDescriptions.Keys) {
  $members = $sorted | Where-Object { $_.CompanionGroup -eq $group }
  if (-not $members) { continue }
  $compLines += "## $group"
  $compLines += $groupDescriptions[$group]
  $compLines += ""
  $compLines += "### Crops"
  $compLines += (($members | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n")
  $compLines += ""
  $compLines += "### Typical Partners"
  $compLines += (($companionMap[$group] | ForEach-Object { "- $_" }) -join "`r`n")
  $compLines += ""
  $compLines += "### Typical Avoid"
  $compLines += (($avoidMap[$group] | ForEach-Object { "- $_" }) -join "`r`n")
  $compLines += ""
}
Set-Content -Path (Join-Path $indexDir 'Companion Groups.md') -Value ($compLines -join "`r`n") -Encoding utf8

$warmDoc = @"
# Warm Season

Zone 7B warm-season crops (after frost and warm soil).

$warm

## Transplanting Procedure (Warm Crops)
- Harden off starts 7-10 days before planting outside.
- Transplant after danger of frost (typically after Apr 15 in Zone 7B).
- Plant in the evening or on overcast days.
- Water in deeply and mulch once soil has warmed.
"@
Set-Content -Path (Join-Path $plantingDir 'Warm Season.md') -Value $warmDoc -Encoding utf8

$coolDoc = @"
# Cool Season

Zone 7B cool-season crops for spring and fall windows.

$cool

## Transplanting Procedure (Cool Crops)
- Start brassicas and leafy greens indoors before target outdoor windows.
- Harden off 7-10 days before transplanting.
- Use row cover in spring/fall to buffer temperature swings.
- Keep moisture steady to avoid bolting and bitterness.
"@
Set-Content -Path (Join-Path $plantingDir 'Cool Season.md') -Value $coolDoc -Encoding utf8

$heavyDoc = @"
# Heavy Feeders

$((($heavy | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

Avoid following heavy feeders with another heavy feeder in the same bed.
"@
Set-Content -Path (Join-Path $rotationDir 'Heavy Feeders.md') -Value $heavyDoc -Encoding utf8

$lightDoc = @"
# Light Feeders

$((($light | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

Light feeders are good follow-ups after heavy-feeder beds.
"@
Set-Content -Path (Join-Path $rotationDir 'Light Feeders.md') -Value $lightDoc -Encoding utf8

$nfixDoc = @"
# Nitrogen Fixers

$((($nfix | ForEach-Object { "- $(Link-ForCrop $_)" }) -join "`r`n"))

Use these crops in rotation to help rebuild nitrogen.
"@
Set-Content -Path (Join-Path $rotationDir 'Nitrogen Fixers.md') -Value $nfixDoc -Encoding utf8

$sourceDoc = @"
# Source References

Primary references used for the Vegetable-vault refresh:

- Virginia Cooperative Extension - Home Vegetable Gardening in Virginia (Publication 426-331): https://www.pubs.ext.vt.edu/426/426-331/426-331.html
- Clemson Cooperative Extension - Planning a Garden: https://hgic.clemson.edu/factsheet/planning-a-garden/
- WVU Extension - Companion Planting in the Garden: https://extension.wvu.edu/lawn-gardening-pests/gardening/garden-management/companion-planting
- University of Maryland Extension - Planting Transplants in Your Garden: https://extension.umd.edu/resource/planting-transplants-your-garden/

Notes:
- Zone baseline used in vault notes: USDA Zone 7B.
- Frost windows used in notes: last spring frost Apr 5-Apr 15, first fall frost Oct 25-Nov 5.
- Companion planting recommendations are treated as practical field guidance and should be validated by observation in each bed.
"@
Set-Content -Path (Join-Path $indexDir 'Source References.md') -Value $sourceDoc -Encoding utf8

Write-Output ("CROPS_WRITTEN=" + $crops.Count)


