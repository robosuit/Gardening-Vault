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

function inferType(frontmatter, vaultDir, section) {
  const fmType = frontmatter.Type || frontmatter.type || frontmatter.Category || frontmatter.category;
  if (fmType) return String(fmType);

  const sectionLc = section.toLowerCase();
  if (sectionLc.includes('index')) return 'Index';
  if (sectionLc.includes('guide')) return 'Guide';

  const config = vaultConfig.find((entry) => entry.dir === vaultDir);
  return config ? config.type : 'Note';
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
    const type = inferType(frontmatter, vault, section);
    const tags = parseTags(frontmatter.Tags || frontmatter.tags);
    const html = md.render(content);

    const vaultMeta = vaultConfig.find((entry) => entry.dir === vault);

    return {
      id: rel,
      order: index + 1,
      vault,
      vaultLabel: vaultMeta ? vaultMeta.label : vault,
      section,
      type,
      path: rel,
      title,
      excerpt: excerptFromContent(content),
      tags,
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
