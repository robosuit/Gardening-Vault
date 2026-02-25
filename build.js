const fs = require('fs-extra');
const path = require('path');
const glob = require('glob');
const matter = require('gray-matter');
const MarkdownIt = require('markdown-it');

const md = new MarkdownIt({html:true});
const repoRoot = __dirname;
const outDir = path.join(repoRoot, 'web', 'data');
fs.ensureDirSync(outDir);

// Vault directories to scan (top-level folders). Adjust if you want others included.
const vaultDirs = [
  'Fruit-Berry-Vault',
  'Herbalism-Vault',
  'Vegetable-Vault',
  'Wildflower-Vault',
  'Master-Indexes',
  'Templates'
];

function collectMarkdownFiles() {
  const files = [];
  vaultDirs.forEach(dir => {
    const pattern = `${dir.replace(/\\/g, '/')}/**/*.md`;
    const matches = glob.sync(pattern, { cwd: repoRoot, nodir: true });
    console.log(`Found ${matches.length} markdown files in ${dir}`);
    matches.forEach(m => files.push(m));
  });
  return files;
}

function normalizeRelative(p) {
  return p.split(path.sep).join('/');
}

function build() {
  const files = collectMarkdownFiles();
  const items = files.map(file => {
    const abs = path.join(repoRoot, file);
    const rel = normalizeRelative(path.relative(repoRoot, abs));
    const vault = rel.split('/')[0] || '';
    const raw = fs.readFileSync(abs, 'utf8');
    const parsed = matter(raw);
    const html = md.render(parsed.content || '');
    const title = parsed.data && parsed.data.title ? parsed.data.title : path.basename(file, '.md');
    return {
      id: rel,
      vault,
      path: rel,
      title,
      frontmatter: parsed.data || {},
      html,
      raw: parsed.content || ''
    };
  });

  const outPath = path.join(outDir, 'plants.json');
  fs.writeFileSync(outPath, JSON.stringify(items, null, 2), 'utf8');
  console.log(`Wrote ${items.length} items to ${outPath}`);
}

build();
