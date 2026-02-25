let DATA = [];

function esc(s){ return (s||'').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

async function load() {
  try {
    const res = await fetch('data/plants.json');
    DATA = await res.json();
    renderList(DATA);
  } catch (err) {
    document.getElementById('results').innerText = 'Failed to load data. Run `npm run build-data` first.';
    console.error(err);
  }
}

function excerptHtml(html) {
  if (!html) return '';
  const idx = html.indexOf('</p>');
  if (idx !== -1) return html.slice(0, idx+4);
  return html.slice(0, 200);
}

function renderList(items) {
  const out = document.getElementById('results');
  if (!items || items.length === 0) { out.innerHTML = '<p>No results.</p>'; return; }
  out.innerHTML = items.map(it => `
    <article class="item">
      <h2>${esc(it.title)}</h2>
      <small class="vault">${esc(it.vault)}</small>
      <div class="excerpt">${excerptHtml(it.html)}</div>
      <a class="open-link" href="/START HERE.md">Open in Obsidian</a>
    </article>
  `).join('\n');
}

function doSearch(q){
  const ql = (q||'').toLowerCase();
  if (!ql) return renderList(DATA);
  const filtered = DATA.filter(it => {
    if ((it.title||'').toLowerCase().includes(ql)) return true;
    if ((it.frontmatter && Object.values(it.frontmatter).join(' ')).toLowerCase().includes(ql)) return true;
    if ((it.raw||'').toLowerCase().includes(ql)) return true;
    return false;
  });
  renderList(filtered);
}

document.addEventListener('DOMContentLoaded', ()=>{
  load();
  const q = document.getElementById('q');
  q.addEventListener('input', e => doSearch(e.target.value));
});
