const state = {
  data: [],
  filtered: [],
  vaultCategory: 'all',
  quick: 'all',
  life: 'all',
  view: 'cards',
  query: '',
  sort: 'relevance'
};

const PLANT_VAULTS = new Set([
  'Herbalism-Vault',
  'Vegetable-Vault',
  'Fruit-Berry-Vault',
  'Wildflower-Vault'
]);

const CATEGORY_ORDER = ['all', 'Herbs', 'Vegetables', 'Fruits', 'Berries', 'Wildflowers'];

const els = {
  vaultNav: document.getElementById('vaultNav'),
  searchInput: document.getElementById('searchInput'),
  sortSelect: document.getElementById('sortSelect'),
  resetBtn: document.getElementById('resetBtn'),
  results: document.getElementById('results'),
  resultsSummary: document.getElementById('resultsSummary'),
  openHelpBtn: document.getElementById('openHelpBtn'),
  noteDialog: document.getElementById('noteDialog'),
  dialogTitle: document.getElementById('dialogTitle'),
  dialogMeta: document.getElementById('dialogMeta'),
  dialogBody: document.getElementById('dialogBody'),
  closeNoteDialog: document.getElementById('closeNoteDialog'),
  helpDialog: document.getElementById('helpDialog'),
  closeHelpDialog: document.getElementById('closeHelpDialog')
};

function esc(text) {
  const value = String(text || '');
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function getBasePath() {
  const { hostname, pathname } = window.location;
  if (!hostname.endsWith('github.io')) return '';
  const firstSegment = pathname.split('/').filter(Boolean)[0] || '';
  return firstSegment ? `/${firstSegment}` : '';
}

function getLifeCycle(item) {
  const fm = item.frontmatter || {};
  return String(
    fm['Life Cycle'] ||
    fm.lifeCycle ||
    fm.LifeCycle ||
    ''
  ).toLowerCase();
}

function isBerry(item) {
  const text = [
    item.title,
    item.path,
    (item.tags || []).join(' '),
    item.raw
  ].join(' ').toLowerCase();

  return /(berry|blueberry|blackberry|raspberry|strawberry|elderberry|cranberry|goji)/.test(text);
}

function categoryOf(item) {
  if (item.vault === 'Herbalism-Vault') return 'Herbs';
  if (item.vault === 'Vegetable-Vault') return 'Vegetables';
  if (item.vault === 'Wildflower-Vault') return 'Wildflowers';
  if (item.vault === 'Fruit-Berry-Vault') return isBerry(item) ? 'Berries' : 'Fruits';
  return 'Other';
}

function isPlantType(item) {
  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();
  return ['herb', 'vegetable', 'fruit', 'flower', 'wildflower'].some((token) => type.includes(token)) ||
    section.includes('plants') ||
    section.includes('crops');
}

function isIndex(item) {
  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();
  return type.includes('index') || section.includes('index') || item.vault === 'Master-Indexes';
}

function isGuide(item) {
  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();
  return type.includes('guide') ||
    section.includes('guide') ||
    section.includes('apothecary') ||
    section.includes('preparations') ||
    section.includes('planting') ||
    item.vault === 'Quick Start Guides' ||
    item.vault === 'Templates';
}

function matchesLifeCycle(item) {
  if (state.life === 'all') return true;
  const life = getLifeCycle(item);
  if (!life) return false;
  if (state.life === 'annual') return life.includes('annual');
  if (state.life === 'perennial') return life.includes('perennial');
  return true;
}

function baseScope() {
  if (state.quick === 'indexes') {
    return state.data.filter((item) => isIndex(item));
  }

  if (state.quick === 'guides') {
    return state.data.filter((item) => isGuide(item));
  }

  if (state.quick === 'plants') {
    return state.data.filter((item) => PLANT_VAULTS.has(item.vault) && isPlantType(item));
  }

  return state.data.filter((item) => PLANT_VAULTS.has(item.vault));
}

function searchScore(item, query) {
  if (!query) return 0;

  const q = query.toLowerCase();
  const title = String(item.title || '').toLowerCase();
  const category = categoryOf(item).toLowerCase();
  const tags = (item.tags || []).join(' ').toLowerCase();
  const excerpt = String(item.excerpt || '').toLowerCase();
  const raw = String(item.raw || '').toLowerCase();
  const path = String(item.path || '').toLowerCase();

  let score = 0;

  if (title === q) score += 600;
  if (title.startsWith(q)) score += 320;
  if (title.includes(q)) score += 220;
  if (category.includes(q)) score += 120;
  if (tags.includes(q)) score += 100;
  if (excerpt.includes(q)) score += 55;
  if (raw.includes(q)) score += 25;
  if (path.includes(q)) score += 15;

  return score;
}

function bySort(a, b) {
  if (state.query && state.sort === 'relevance') {
    return b._score - a._score || a.title.localeCompare(b.title);
  }
  if (state.sort === 'title-asc') return a.title.localeCompare(b.title);
  if (state.sort === 'title-desc') return b.title.localeCompare(a.title);
  if (state.sort === 'category-asc') return categoryOf(a).localeCompare(categoryOf(b)) || a.title.localeCompare(b.title);
  return a.title.localeCompare(b.title);
}

function currentScopeWithQuery() {
  const query = state.query.trim().toLowerCase();
  let items = baseScope().filter((item) => matchesLifeCycle(item));

  if (state.vaultCategory !== 'all') {
    items = items.filter((item) => categoryOf(item) === state.vaultCategory);
  }

  if (!query) {
    return items.map((item) => ({ ...item, _score: 0 }));
  }

  const scored = items
    .map((item) => ({ ...item, _score: searchScore(item, query) }))
    .filter((item) => item._score > 0);

  return scored;
}

function applyFilters() {
  state.filtered = currentScopeWithQuery().sort(bySort);
}

function renderVaultNav() {
  const scoped = baseScope().filter((item) => matchesLifeCycle(item));
  const query = state.query.trim().toLowerCase();
  const queryScoped = query
    ? scoped.filter((item) => searchScore(item, query) > 0)
    : scoped;

  const counts = new Map();
  queryScoped.forEach((item) => {
    const cat = categoryOf(item);
    if (cat === 'Other') return;
    counts.set(cat, (counts.get(cat) || 0) + 1);
  });

  const rows = [
    `<button type="button" class="vault-btn ${state.vaultCategory === 'all' ? 'active' : ''}" data-vault-category="all">All (${queryScoped.length})</button>`
  ];

  CATEGORY_ORDER.filter((item) => item !== 'all').forEach((category) => {
    const count = counts.get(category) || 0;
    rows.push(
      `<button type="button" class="vault-btn ${state.vaultCategory === category ? 'active' : ''}" data-vault-category="${esc(category)}">${esc(category)} (${count})</button>`
    );
  });

  els.vaultNav.innerHTML = rows.join('');
}

function renderResults() {
  const isListView = state.view === 'list';
  els.results.className = isListView ? 'results-list' : 'results-grid';

  if (!state.filtered.length) {
    els.results.innerHTML = `
      <div class="empty">
        <h3>No matching notes</h3>
        <p>Try a shorter search phrase or reset filters.</p>
      </div>
    `;
    return;
  }

  els.results.innerHTML = state.filtered.map((item) => {
    return `
      <button type="button" class="result-card" data-id="${esc(item.id)}" role="listitem">
        <div class="result-title">${esc(item.title)}</div>
        <div class="result-meta">
          <span class="chip">${esc(categoryOf(item))}</span>
          <span class="chip">${esc(item.type || 'Note')}</span>
        </div>
        <div class="result-excerpt">${esc(item.excerpt || '')}</div>
        <div class="result-path">${esc(item.path)}</div>
      </button>
    `;
  }).join('');
}

function updateSummary() {
  const cycleLabel = state.life === 'all' ? 'all life cycles' : state.life;
  const quickLabel = state.quick;
  els.resultsSummary.textContent = `Showing ${state.filtered.length} results (${quickLabel}, ${cycleLabel}). Click any result to open directly.`;
}

function applyAndRender() {
  applyFilters();
  renderVaultNav();
  renderResults();
  updateSummary();
}

function markdownMetaChips(item) {
  const parts = [
    categoryOf(item),
    item.type || null,
    getLifeCycle(item) ? `Life Cycle: ${getLifeCycle(item)}` : null,
    item.startMonth ? `Start: ${item.startMonth}` : null,
    item.harvest ? `Harvest: ${item.harvest}` : null
  ].filter(Boolean);

  return parts.map((part) => `<span class="chip">${esc(part)}</span>`).join('');
}

function openNote(item) {
  if (!item) return;
  els.dialogTitle.textContent = item.title;
  els.dialogMeta.innerHTML = markdownMetaChips(item);
  els.dialogBody.innerHTML = item.html || '<p>No content.</p>';
  els.noteDialog.showModal();
}

function resetFilters() {
  state.vaultCategory = 'all';
  state.quick = 'all';
  state.life = 'all';
  state.view = 'cards';
  state.query = '';
  state.sort = 'relevance';

  els.searchInput.value = '';
  els.sortSelect.value = 'relevance';

  document.querySelectorAll('[data-quick]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.quick === 'all');
  });

  document.querySelectorAll('[data-view]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.view === 'cards');
  });

  document.querySelectorAll('[data-life]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.life === 'all');
  });

  applyAndRender();
}

async function loadData() {
  const basePath = getBasePath();
  try {
    const response = await fetch(`${basePath}/data/plants.json`);
    if (!response.ok) throw new Error(`Could not load data (${response.status})`);
    state.data = await response.json();
    applyAndRender();
  } catch (error) {
    els.results.innerHTML = `
      <div class="empty">
        <h3>Data load failed</h3>
        <p>${esc(error.message)}</p>
      </div>
    `;
    console.error(error);
  }
}

function wireEvents() {
  els.vaultNav.addEventListener('click', (event) => {
    const button = event.target.closest('[data-vault-category]');
    if (!button) return;
    state.vaultCategory = button.dataset.vaultCategory;
    applyAndRender();
  });

  els.searchInput.addEventListener('input', (event) => {
    state.query = event.target.value;
    applyAndRender();
  });

  els.sortSelect.addEventListener('change', (event) => {
    state.sort = event.target.value;
    applyAndRender();
  });

  document.querySelectorAll('[data-quick]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.quick = btn.dataset.quick;
      document.querySelectorAll('[data-quick]').forEach((x) => x.classList.toggle('active', x === btn));
      applyAndRender();
    });
  });

  document.querySelectorAll('[data-view]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.view = btn.dataset.view;
      document.querySelectorAll('[data-view]').forEach((x) => x.classList.toggle('active', x === btn));
      renderResults();
    });
  });

  document.querySelectorAll('[data-life]').forEach((btn) => {
    btn.addEventListener('click', () => {
      state.life = btn.dataset.life;
      document.querySelectorAll('[data-life]').forEach((x) => x.classList.toggle('active', x === btn));
      applyAndRender();
    });
  });

  els.results.addEventListener('click', (event) => {
    const card = event.target.closest('.result-card');
    if (!card) return;
    const item = state.filtered.find((entry) => entry.id === card.dataset.id);
    openNote(item);
  });

  els.resetBtn.addEventListener('click', resetFilters);
  els.openHelpBtn.addEventListener('click', () => els.helpDialog.showModal());
  els.closeNoteDialog.addEventListener('click', () => els.noteDialog.close());
  els.closeHelpDialog.addEventListener('click', () => els.helpDialog.close());
}

document.addEventListener('DOMContentLoaded', () => {
  wireEvents();
  loadData();
});
