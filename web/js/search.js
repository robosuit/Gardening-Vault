let DATA = [];
let currentFilter = 'all';

function esc(s) {
  return (s || '').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

async function load() {
  try {
    // Get the base path for GitHub Pages subdirectory
    const basePath = window.location.pathname.includes('/Gardening-Vault/') ? '/Gardening-Vault' : '';
    const res = await fetch(basePath + '/data/plants.json');
    
    if (!res.ok) throw new Error('Failed to load data: ' + res.status);
    
    DATA = await res.json();
    document.getElementById('total-count').textContent = DATA.length;
    renderList(filterData('all'));
  } catch (err) {
    const resultsDiv = document.getElementById('results');
    resultsDiv.innerHTML = `
      <div class="no-results">
        <h3>❌ Error Loading Data</h3>
        <p>${esc(err.message)}</p>
        <p>Make sure to run: <code>npm run build-data</code></p>
      </div>
    `;
    console.error('Data load error:', err);
  }
}

function excerptHtml(html) {
  if (!html) return '';
  // Extract first paragraph
  const match = html.match(/<p>(.*?)<\/p>/);
  if (match) return match[1].slice(0, 200);
  // Fallback: strip HTML tags and take first 200 chars
  const text = html.replace(/<[^>]*>/g, '');
  return text.slice(0, 200);
}

function getVaultEmoji(vault) {
  const emojis = {
    'Herbalism-Vault': '🌿',
    'Vegetable-Vault': '🥬',
    'Fruit-Berry-Vault': '🍓',
    'Wildflower-Vault': '🌼',
    'Master-Indexes': '📋',
    'Quick Start Guides': '📖'
  };
  return emojis[vault] || '🌱';
}

function filterData(filter) {
  if (filter === 'all') return DATA;
  return DATA.filter(item => item.vault === filter);
}

function renderList(items) {
  const out = document.getElementById('results');
  
  if (!items || items.length === 0) {
    out.innerHTML = `
      <div class="no-results">
        <h3>🔍 No plants found</h3>
        <p>Try adjusting your search or filter.</p>
      </div>
    `;
    return;
  }
  
  out.innerHTML = items.map(it => {
    const emoji = getVaultEmoji(it.vault);
    const excerpt = excerptHtml(it.html);
    return `
      <article class="item">
        <span class="vault">${emoji} ${esc(it.vault.replace('-Vault', '').replace(/-/g, ' '))}</span>
        <h2>${esc(it.title)}</h2>
        <div class="excerpt">${excerpt}</div>
      </article>
    `;
  }).join('\n');
}

function doSearch(q) {
  const ql = (q || '').toLowerCase();
  let filtered = filterData(currentFilter);
  
  if (ql) {
    filtered = filtered.filter(it => {
      const title = (it.title || '').toLowerCase();
      const content = (it.raw || '').toLowerCase();
      const tags = it.frontmatter && Object.values(it.frontmatter).join(' ').toLowerCase();
      
      return title.includes(ql) || content.includes(ql) || (tags && tags.includes(ql));
    });
  }
  
  renderList(filtered);
}

document.addEventListener('DOMContentLoaded', () => {
  load();
  
  // Search input
  const q = document.getElementById('q');
  q.addEventListener('input', e => doSearch(e.target.value));
  
  // Filter buttons
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      e.target.classList.add('active');
      currentFilter = e.target.dataset.filter;
      q.value = ''; // Clear search when filtering
      doSearch('');
    });
  });
});
