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

const state = {
  data: [],
  filtered: [],
  quick: 'all',
  view: 'cards',
  life: 'all',
  temperature: 'all',
  month: 'all',
  query: '',
  sort: 'relevance',
  vaultCategory: 'all'
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
  monthSelect: document.getElementById('monthSelect'),
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

  const segments = pathname.split('/').filter(Boolean);
  if (!segments.length) return '';

  // Support both deployment layouts:
  // 1) /Gardening-Vault/ (GitHub Actions artifact publishes web as site root)
  // 2) /Gardening-Vault/web/ (Pages "deploy from branch" on repository root)
  if (segments.length >= 2 && segments[1] === 'web') {
    return `/${segments[0]}/web`;
  }

  return `/${segments[0]}`;
}

function getLifeCycle(item) {
  const fm = item.frontmatter || {};
  return String(
    fm['Life Cycle'] ||
    fm.LifeCycle ||
    fm.lifeCycle ||
    ''
  ).toLowerCase();
}

function getTagSet(item) {
  const tags = Array.isArray(item.tags) ? item.tags : [];
  return new Set(tags.map((tag) => String(tag).toLowerCase()));
}

function getTemperatures(item) {
  if (Array.isArray(item.temperatures) && item.temperatures.length) {
    return item.temperatures.map((value) => String(value).toLowerCase());
  }

  const tags = getTagSet(item);
  const values = [];
  if (tags.has('cool')) values.push('cool');
  if (tags.has('warm')) values.push('warm');
  return values;
}

function getMonths(item) {
  if (Array.isArray(item.months) && item.months.length) {
    return item.months.map((value) => String(value).toLowerCase());
  }

  const tags = getTagSet(item);
  return MONTHS.filter((month) => tags.has(month));
}

function isBerry(item) {
  const text = [
    item.title,
    item.path,
    item.raw,
    Array.isArray(item.tags) ? item.tags.join(' ') : ''
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

function isIndex(item) {
  if (String(item.category || '').toLowerCase() === 'index') return true;

  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();
  const vault = String(item.vault || '').toLowerCase();
  return type.includes('index') || section.includes('index') || vault.includes('master-index');
}

function isGuide(item) {
  const category = String(item.category || '').toLowerCase();
  if (category === 'guide' || category === 'design') return true;

  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();
  const vault = String(item.vault || '').toLowerCase();

  return type.includes('guide') ||
    section.includes('guide') ||
    section.includes('preparation') ||
    section.includes('planting') ||
    vault.includes('quick start guides') ||
    vault.includes('templates');
}

function isPlantLike(item) {
  if (String(item.category || '').toLowerCase() === 'plant') return true;

  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();

  return ['herb', 'vegetable', 'fruit', 'flower', 'wildflower'].some((token) => type.includes(token)) ||
    section.includes('plants') ||
    section.includes('crops');
}

function matchesQuick(item) {
  if (state.quick === 'indexes') return isIndex(item);
  if (state.quick === 'guides') return isGuide(item);
  if (state.quick === 'plants') return PLANT_VAULTS.has(item.vault) && isPlantLike(item);
  return PLANT_VAULTS.has(item.vault);
}

function matchesLife(item) {
  if (state.life === 'all') return true;
  if (!PLANT_VAULTS.has(item.vault)) return false;

  const life = getLifeCycle(item);
  if (!life) return false;

  if (state.life === 'annual') return life.includes('annual');
  if (state.life === 'perennial') return life.includes('perennial');
  return true;
}

function matchesTemperature(item) {
  if (state.temperature === 'all') return true;
  return getTemperatures(item).includes(state.temperature);
}

function matchesMonth(item) {
  if (state.month === 'all') return true;
  return getMonths(item).includes(state.month);
}

function matchesVaultCategory(item) {
  if (state.vaultCategory === 'all') return true;
  if (state.quick === 'indexes' || state.quick === 'guides') return true;
  return categoryOf(item) === state.vaultCategory;
}

function scoreItem(item, query) {
  if (!query) return 0;

  const q = query.toLowerCase();
  const title = String(item.title || '').toLowerCase();
  const category = categoryOf(item).toLowerCase();
  const itemCategory = String(item.category || '').toLowerCase();
  const type = String(item.type || '').toLowerCase();
  const excerpt = String(item.excerpt || '').toLowerCase();
  const path = String(item.path || '').toLowerCase();
  const tags = (Array.isArray(item.tags) ? item.tags : []).join(' ').toLowerCase();
  const raw = String(item.raw || '').toLowerCase();

  let score = 0;
  if (title === q) score += 900;
  if (title.startsWith(q)) score += 420;
  if (title.includes(q)) score += 250;
  if (tags.includes(q)) score += 150;
  if (category.includes(q)) score += 120;
  if (itemCategory.includes(q)) score += 120;
  if (type.includes(q)) score += 80;
  if (excerpt.includes(q)) score += 60;
  if (path.includes(q)) score += 40;
  if (raw.includes(q)) score += 20;

  return score;
}

function sortResults(items) {
  const sorted = [...items];

  if (state.sort === 'relevance' && state.query.trim()) {
    sorted.sort((a, b) => b._score - a._score || a.title.localeCompare(b.title));
    return sorted;
  }

  if (state.sort === 'title-asc' || state.sort === 'relevance') {
    sorted.sort((a, b) => a.title.localeCompare(b.title));
    return sorted;
  }

  if (state.sort === 'title-desc') {
    sorted.sort((a, b) => b.title.localeCompare(a.title));
    return sorted;
  }

  if (state.sort === 'category-asc') {
    sorted.sort((a, b) => categoryOf(a).localeCompare(categoryOf(b)) || a.title.localeCompare(b.title));
    return sorted;
  }

  return sorted;
}

function baseScope() {
  return state.data.filter((item) => matchesQuick(item) && matchesLife(item) && matchesTemperature(item) && matchesMonth(item));
}

function applyFilters() {
  const query = state.query.trim().toLowerCase();
  let items = baseScope().filter((item) => matchesVaultCategory(item));

  if (query) {
    items = items
      .map((item) => ({ ...item, _score: scoreItem(item, query) }))
      .filter((item) => item._score > 0);
  } else {
    items = items.map((item) => ({ ...item, _score: 0 }));
  }

  state.filtered = sortResults(items);
}

function renderVaultNav() {
  const query = state.query.trim().toLowerCase();
  const items = baseScope().filter((item) => !query || scoreItem(item, query) > 0);
  const counts = new Map();

  items.forEach((item) => {
    const cat = categoryOf(item);
    if (cat === 'Other') return;
    counts.set(cat, (counts.get(cat) || 0) + 1);
  });

  const rows = [];
  const allCount = items.filter((item) => categoryOf(item) !== 'Other').length;
  rows.push(
    `<button type="button" class="vault-btn ${state.vaultCategory === 'all' ? 'active' : ''}" data-vault-category="all">All (${allCount})</button>`
  );

  CATEGORY_ORDER.filter((value) => value !== 'all').forEach((category) => {
    const count = counts.get(category) || 0;
    rows.push(
      `<button type="button" class="vault-btn ${state.vaultCategory === category ? 'active' : ''}" data-vault-category="${esc(category)}">${esc(category)} (${count})</button>`
    );
  });

  els.vaultNav.innerHTML = rows.join('');
}

function renderResults() {
  const listView = state.view === 'list';
  els.results.className = listView ? 'results-list' : 'results-grid';

  if (!state.filtered.length) {
    els.results.innerHTML = `
      <div class="empty">
        <h3>No matching notes</h3>
        <p>Try another search phrase or reset filters.</p>
      </div>
    `;
    return;
  }

  els.results.innerHTML = state.filtered.map((item) => {
    const typeChip = String(item.category || item.type || 'Note');

    return `
      <button type="button" class="result-card" data-id="${esc(item.id)}" role="listitem">
        <div class="result-title">${esc(item.title)}</div>
        <div class="result-meta">
          <span class="chip">${esc(categoryOf(item))}</span>
          <span class="chip">${esc(typeChip)}</span>
        </div>
        <div class="result-excerpt">${esc(item.excerpt || '')}</div>
        <div class="result-path">${esc(item.path)}</div>
      </button>
    `;
  }).join('');
}

function updateSummary() {
  const lifeText = state.life === 'all' ? 'all cycles' : state.life;
  const tempText = state.temperature === 'all' ? 'all temps' : state.temperature;
  const monthText = state.month === 'all' ? 'all months' : state.month;
  const quickText = state.quick;

  els.resultsSummary.textContent = `Showing ${state.filtered.length} results (${quickText}, ${lifeText}, ${tempText}, ${monthText}). Click any result to open.`;
}

function applyAndRender() {
  applyFilters();
  renderVaultNav();
  renderResults();
  updateSummary();
}

function markdownMetaChips(item) {
  const chips = [
    categoryOf(item),
    item.category || item.type || null,
    getLifeCycle(item) ? `Life Cycle: ${getLifeCycle(item)}` : null,
    getTemperatures(item).length ? `Temp: ${getTemperatures(item).join('/')}` : null,
    getMonths(item).length ? `Months: ${getMonths(item).join(', ')}` : null
  ].filter(Boolean);

  return chips.map((value) => `<span class="chip">${esc(value)}</span>`).join('');
}

function openNote(item) {
  if (!item) return;

  els.dialogTitle.textContent = item.title;
  els.dialogMeta.innerHTML = markdownMetaChips(item);
  els.dialogBody.innerHTML = item.html || '<p>No content.</p>';
  els.noteDialog.showModal();
}

function setQuick(quick) {
  state.quick = quick;
  if (quick === 'indexes' || quick === 'guides') {
    state.vaultCategory = 'all';
  }

  document.querySelectorAll('[data-quick]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.quick === quick);
  });
}

function setView(view) {
  state.view = view;
  document.querySelectorAll('[data-view]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.view === view);
  });
}

function setLife(life) {
  state.life = life;
  document.querySelectorAll('[data-life]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.life === life);
  });
}

function setTemperature(temperature) {
  state.temperature = temperature;
  document.querySelectorAll('[data-temp]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.temp === temperature);
  });
}

function attachOutsideDismiss(dialog) {
  dialog.addEventListener('click', (event) => {
    if (event.target === dialog) {
      dialog.close();
    }
  });
}

function resetFilters() {
  state.query = '';
  state.quick = 'all';
  state.view = 'cards';
  state.life = 'all';
  state.temperature = 'all';
  state.month = 'all';
  state.sort = 'relevance';
  state.vaultCategory = 'all';

  els.searchInput.value = '';
  els.monthSelect.value = 'all';
  els.sortSelect.value = 'relevance';
  setQuick('all');
  setView('cards');
  setLife('all');
  setTemperature('all');
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

  els.monthSelect.addEventListener('change', (event) => {
    state.month = event.target.value;
    applyAndRender();
  });

  els.sortSelect.addEventListener('change', (event) => {
    state.sort = event.target.value;
    applyAndRender();
  });

  document.querySelectorAll('[data-quick]').forEach((btn) => {
    btn.addEventListener('click', () => {
      setQuick(btn.dataset.quick);
      applyAndRender();
    });
  });

  document.querySelectorAll('[data-view]').forEach((btn) => {
    btn.addEventListener('click', () => {
      setView(btn.dataset.view);
      renderResults();
    });
  });

  document.querySelectorAll('[data-life]').forEach((btn) => {
    btn.addEventListener('click', () => {
      setLife(btn.dataset.life);
      applyAndRender();
    });
  });

  document.querySelectorAll('[data-temp]').forEach((btn) => {
    btn.addEventListener('click', () => {
      setTemperature(btn.dataset.temp);
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

  attachOutsideDismiss(els.noteDialog);
  attachOutsideDismiss(els.helpDialog);
}

document.addEventListener('DOMContentLoaded', () => {
  wireEvents();
  loadData();
});
