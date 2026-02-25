const fs = require('fs-extra');
const path = require('path');
const glob = require('glob');
const matter = require('gray-matter');
const MarkdownIt = require('markdown-it');

const md = new MarkdownIt({ html: true });
const repoRoot = __dirname;
const outDir = path.join(repoRoot, 'web', 'data');
fs.ensureDirSync(outDir);

const vaultConfig = [
  { dir: 'Fruit-Berry-Vault', label: 'Fruits & Berries', type: 'Fruit' },
  { dir: 'Herbalism-Vault', label: 'Herbalism', type: 'Herb' },
  { dir: 'Vegetable-Vault', label: 'Vegetables', type: 'Vegetable' },
  { dir: 'Wildflower-Vault', label: 'Wildflowers', type: 'Flower' },
  { dir: 'Master-Indexes', label: 'Master Indexes', type: 'Index' },
  { dir: 'Quick Start Guides', label: 'Quick Guides', type: 'Guide' },
  { dir: 'Templates', label: 'Templates', type: 'Template' }
];

const MONTHS = [
  'january',
  'february',
  'march',
  'april',
  'may',
  'june',
  'july',
  'august',
  'september',
  'october',
  'november',
  'december'
];

const MONTH_TEMPERATURES = {
  january: ['cool'],
  february: ['cool'],
  march: ['cool'],
  april: ['warm'],
  may: ['warm'],
  june: ['warm'],
  july: ['warm'],
  august: ['warm'],
  september: ['warm'],
  october: ['warm', 'cool'],
  november: ['cool'],
  december: ['cool']
};

function normalizeRelative(filePath) {
  return filePath.split(path.sep).join('/');
}

function sectionFromPath(relPath) {
  const parts = relPath.split('/');
  const raw = parts[1] || '';
  return raw
    .replace(/^\d+[_-]?/, '')
    .replace(/_/g, ' ')
    .trim() || 'General';
}

function firstHeading(markdown) {
  const match = (markdown || '').match(/^#\s+(.+)$/m);
  return match ? match[1].trim() : '';
}

function toPlainText(markdown) {
  if (!markdown) return '';

  return markdown
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/`[^`]*`/g, ' ')
    .replace(/!\[[^\]]*\]\([^)]*\)/g, ' ')
    .replace(/\[[^\]]*\]\([^)]*\)/g, ' ')
    .replace(/\[\[[^\]]*\]\]/g, ' ')
    .replace(/^#+\s+/gm, '')
    .replace(/[>*_~\-]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function excerptFromContent(markdown, length = 180) {
  const plain = toPlainText(markdown);
  if (plain.length <= length) return plain;
  return `${plain.slice(0, length).trimEnd()}...`;
}

function parseTags(rawTags) {
  if (!rawTags) return [];

  if (Array.isArray(rawTags)) {
    return rawTags
      .map(String)
      .map((tag) => tag.replace(/^#/, '').trim())
      .filter(Boolean);
  }

  return String(rawTags)
    .split(/[\s,]+/)
    .map((tag) => tag.replace(/^#/, '').trim())
    .filter(Boolean);
}

function uniqueLower(values) {
  return [...new Set(values.map((value) => String(value || '').trim().toLowerCase()).filter(Boolean))];
}

function safeDecode(input) {
  try {
    return decodeURIComponent(input);
  } catch {
    return input;
  }
}

function extractMonths(text) {
  const lower = String(text || '').toLowerCase();
  return MONTHS.filter((month) => new RegExp(`\\b${month}\\b`).test(lower));
}

function inferType(frontmatter, vaultDir, section) {
  const fmType = frontmatter.Type || frontmatter.type || frontmatter.Category || frontmatter.category;
  if (fmType) return String(fmType);

  const sectionLc = section.toLowerCase();
  if (sectionLc.includes('index')) return 'Index';
  if (sectionLc.includes('guide')) return 'Guide';

  const config = vaultConfig.find((entry) => entry.dir === vaultDir);
  return config ? config.type : 'Note';
}

function classifyNote({ rel, vault, section, title, frontmatter, baseTags }) {
  const pathLc = safeDecode(rel.toLowerCase());
  const titleLc = title.toLowerCase();
  const sectionLc = section.toLowerCase();
  const addTags = [...baseTags];
  const months = [];
  const temperatures = [];

  let type = inferType(frontmatter, vault, section);
  let category = 'Plant';

  const addTag = (...values) => {
    values.forEach((value) => {
      if (value) addTags.push(value);
    });
  };

  const addTemperature = (...values) => {
    values.forEach((value) => {
      if (value) temperatures.push(value);
    });
  };

  if (pathLc.includes('/00_indexes/') || vault === 'Master-Indexes') {
    type = 'Index';
    category = 'Index';
    addTag('index', 'reference');
  }

  if (vault === 'Templates' || pathLc.includes('/templates/')) {
    type = 'Template';
    category = 'Template';
    addTag('template');
  }

  if (vault === 'Quick Start Guides') {
    type = 'Guide';
    category = 'Guide';
    addTag('guide');
  }

  if (pathLc.includes('/02_apothecary/') || pathLc.includes('/03_preparations/')) {
    type = 'Guide';
    category = 'Guide';
    addTag('guide', 'herbal-medicine');
  }

  if (pathLc.includes('/04_garden_design/')) {
    type = 'Design';
    category = 'Design';
    addTag('design', 'structure', 'architecture', 'layout');
  }

  if (pathLc.includes('/05_months/')) {
    type = 'Guide';
    category = 'Guide';
    addTag('month', 'guide', 'planting');

    const monthHits = extractMonths(`${titleLc} ${pathLc}`);
    monthHits.forEach((month) => {
      months.push(month);
      addTag(month);
      addTemperature(...(MONTH_TEMPERATURES[month] || []));
      addTag(...(MONTH_TEMPERATURES[month] || []));
    });
  }

  if (pathLc.includes('/02_planting/')) {
    type = 'Guide';
    category = 'Guide';
    addTag('guide', 'planting');

    if (titleLc.includes('warm') || pathLc.includes('warm')) {
      addTemperature('warm');
      addTag('warm');
    }
    if (titleLc.includes('cool') || pathLc.includes('cool')) {
      addTemperature('cool');
      addTag('cool');
    }
  }

  if (/(design|structure|architecture|layout)/.test(`${titleLc} ${sectionLc} ${pathLc}`)) {
    addTag('design', 'structure', 'architecture');
  }
  if (/(map)/.test(`${titleLc} ${pathLc}`)) addTag('map');
  if (/(matrix)/.test(`${titleLc} ${pathLc}`)) addTag('matrix');
  if (/(network)/.test(`${titleLc} ${pathLc}`)) addTag('network');

  if (titleLc.includes('tincture')) addTag('tincture');
  if (titleLc.includes('salve')) addTag('salve');
  if (titleLc.includes('ointment')) addTag('ointment');
  if (titleLc.includes('syrup')) addTag('syrup');
  if (titleLc.includes('infusion') || titleLc.includes('tea')) addTag('tea');

  const frontmatterMonthText = `${frontmatter['Start Month'] || ''} ${frontmatter.Harvest || ''}`;
  extractMonths(frontmatterMonthText).forEach((month) => {
    months.push(month);
    addTag(month);
  });

  const tags = uniqueLower(addTags).filter((tag) => {
    if (category === 'Guide' && (pathLc.includes('/02_apothecary/') || pathLc.includes('/03_preparations/'))) {
      return tag !== 'herb' && tag !== 'herbs';
    }
    return true;
  });

  return {
    type,
    category,
    tags,
    months: uniqueLower(months),
    temperatures: uniqueLower(temperatures)
  };
}

function collectMarkdownFiles() {
  const files = [];

  vaultConfig.forEach((vault) => {
    const pattern = `${vault.dir.replace(/\\/g, '/')}/**/*.md`;
    const matches = glob.sync(pattern, { cwd: repoRoot, nodir: true });
    console.log(`Found ${matches.length} markdown files in ${vault.dir}`);
    matches.forEach((match) => files.push(match));
  });

  return files.sort((a, b) => a.localeCompare(b));
}

function build() {
  const files = collectMarkdownFiles();

  const items = files.map((file, index) => {
    const abs = path.join(repoRoot, file);
    const rel = normalizeRelative(path.relative(repoRoot, abs));
    const vault = rel.split('/')[0] || '';
    const rawSource = fs.readFileSync(abs, 'utf8');

    const parsed = matter(rawSource);
    const content = parsed.content || '';
    const heading = firstHeading(content);
    const fallbackTitle = path.basename(file, '.md');
    const frontmatter = parsed.data || {};

    const title = String(frontmatter.title || heading || fallbackTitle).trim();
    const section = sectionFromPath(rel);
    const initialTags = parseTags(frontmatter.Tags || frontmatter.tags);
    const classification = classifyNote({
      rel,
      vault,
      section,
      title,
      frontmatter,
      baseTags: initialTags
    });
    const html = md.render(content);

    const vaultMeta = vaultConfig.find((entry) => entry.dir === vault);

    return {
      id: rel,
      order: index + 1,
      vault,
      vaultLabel: vaultMeta ? vaultMeta.label : vault,
      section,
      type: classification.type,
      category: classification.category,
      path: rel,
      title,
      excerpt: excerptFromContent(content),
      tags: classification.tags,
      months: classification.months,
      temperatures: classification.temperatures,
      zone: frontmatter.Zone || frontmatter.zone || null,
      sun: frontmatter.Sun || frontmatter.sun || null,
      water: frontmatter.Water || frontmatter.water || null,
      harvest: frontmatter.Harvest || frontmatter.harvest || null,
      startMonth: frontmatter['Start Month'] || frontmatter.startMonth || null,
      pollinatorValue: frontmatter['Pollinator Value'] || null,
      feedingLevel: frontmatter['Feeding Level'] || null,
      frontmatter,
      html,
      raw: content
    };
  });

  const outPath = path.join(outDir, 'plants.json');
  fs.writeFileSync(outPath, JSON.stringify(items, null, 2), 'utf8');
  console.log(`Wrote ${items.length} items to ${outPath}`);
}

build();
