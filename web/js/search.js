const state = {
  data: [],
  filtered: [],
  selectedId: null,
  vault: 'all',
  quick: 'all',
  view: 'cards',
  query: '',
  type: 'all',
  sort: 'title-asc'
};

const VAULT_ORDER = [
  'Herbalism-Vault',
  'Vegetable-Vault',
  'Fruit-Berry-Vault',
  'Wildflower-Vault',
  'Master-Indexes',
  'Quick Start Guides',
  'Templates'
];

const els = {
  vaultNav: document.getElementById('vaultNav'),
  sortSelect: document.getElementById('sortSelect'),
  typeSelect: document.getElementById('typeSelect'),
  searchInput: document.getElementById('searchInput'),
  results: document.getElementById('results'),
  resultsSummary: document.getElementById('resultsSummary'),
  statusBox: document.getElementById('statusBox'),
  openSelectedBtn: document.getElementById('openSelectedBtn'),
  copyPathBtn: document.getElementById('copyPathBtn'),
  sourceBtn: document.getElementById('sourceBtn'),
  downloadBtn: document.getElementById('downloadBtn'),
  resetBtn: document.getElementById('resetBtn'),
  helpRailBtn: document.getElementById('helpRailBtn'),
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

function vaultLabel(vault) {
  const match = state.data.find((item) => item.vault === vault);
  if (match && match.vaultLabel) return match.vaultLabel;
  return vault.replace('-Vault', '').replace(/-/g, ' ');
}

function getSelectedItem() {
  if (!state.selectedId) return null;
  return state.data.find((item) => item.id === state.selectedId) || null;
}

function quickMatch(item, quick) {
  if (quick === 'all') return true;

  const type = String(item.type || '').toLowerCase();
  const section = String(item.section || '').toLowerCase();
  const vault = String(item.vault || '').toLowerCase();

  if (quick === 'plants') {
    return ['herb', 'vegetable', 'fruit', 'flower', 'wildflower'].some((token) => type.includes(token));
  }

  if (quick === 'indexes') {
    return type.includes('index') || section.includes('index') || vault.includes('master-index');
  }

  if (quick === 'guides') {
    return type.includes('guide') ||
      section.includes('guide') ||
      section.includes('preparation') ||
      section.includes('planting') ||
      vault.includes('quick start guides');
  }

  return true;
}

function sortItems(items) {
  const sorted = [...items];

  sorted.sort((a, b) => {
    if (state.sort === 'title-asc') return a.title.localeCompare(b.title);
    if (state.sort === 'title-desc') return b.title.localeCompare(a.title);
    if (state.sort === 'vault-asc') return a.vault.localeCompare(b.vault) || a.title.localeCompare(b.title);
    if (state.sort === 'type-asc') return String(a.type).localeCompare(String(b.type)) || a.title.localeCompare(b.title);
    if (state.sort === 'section-asc') return String(a.section).localeCompare(String(b.section)) || a.title.localeCompare(b.title);
    return 0;
  });

  return sorted;
}

function applyFilters() {
  const query = state.query.trim().toLowerCase();

  const filtered = state.data.filter((item) => {
    if (state.vault !== 'all' && item.vault !== state.vault) return false;
    if (state.type !== 'all' && String(item.type) !== state.type) return false;
    if (!quickMatch(item, state.quick)) return false;
    if (!query) return true;

    const haystack = [
      item.title,
      item.type,
      item.section,
      item.excerpt,
      item.raw,
      item.path,
      item.tags.join(' '),
      Object.values(item.frontmatter || {}).join(' ')
    ].join(' ').toLowerCase();

    return haystack.includes(query);
  });

  state.filtered = sortItems(filtered);

  if (!state.filtered.some((item) => item.id === state.selectedId)) {
    state.selectedId = state.filtered[0] ? state.filtered[0].id : null;
  }
}

function renderVaultNav() {
  const counts = new Map();
  state.data.forEach((item) => counts.set(item.vault, (counts.get(item.vault) || 0) + 1));

  const orderedVaults = [...counts.keys()].sort((a, b) => {
    const aPos = VAULT_ORDER.indexOf(a);
    const bPos = VAULT_ORDER.indexOf(b);

    if (aPos === -1 && bPos === -1) return a.localeCompare(b);
    if (aPos === -1) return 1;
    if (bPos === -1) return -1;
    return aPos - bPos;
  });

  const rows = [
    `<button type="button" class="menu-item ${state.vault === 'all' ? 'active' : ''}" data-vault="all">All Documents (${state.data.length})</button>`
  ];

  orderedVaults.forEach((vault) => {
    const count = counts.get(vault) || 0;
    rows.push(
      `<button type="button" class="menu-item ${state.vault === vault ? 'active' : ''}" data-vault="${esc(vault)}">${esc(vaultLabel(vault))} (${count})</button>`
    );
  });

  els.vaultNav.innerHTML = rows.join('');
}

function renderTypeOptions() {
  const types = [...new Set(state.data.map((item) => String(item.type || '').trim()).filter(Boolean))]
    .sort((a, b) => a.localeCompare(b));

  els.typeSelect.innerHTML = [
    '<option value="all">All Types</option>',
    ...types.map((type) => `<option value="${esc(type)}">${esc(type)}</option>`)
  ].join('');

  els.typeSelect.value = state.type;
}

function renderResults() {
  const isListView = state.view === 'list';
  els.results.className = isListView ? 'results-list' : 'results-grid';

  if (!state.filtered.length) {
    els.results.innerHTML = `
      <div class="empty">
        <h3>No matching notes</h3>
        <p>Adjust vault, search, type, quick filters, or sorting.</p>
      </div>
    `;
    return;
  }

  els.results.innerHTML = state.filtered.map((item, index) => {
    const selected = item.id === state.selectedId ? 'selected' : '';
    const excerpt = esc(item.excerpt || 'No excerpt available.');
    const meta = [item.vaultLabel || vaultLabel(item.vault), item.type, item.section].filter(Boolean);

    return `
      <button type="button" class="result-card ${selected}" data-id="${esc(item.id)}" style="--i:${index};" role="listitem">
        <div class="result-title">${esc(item.title)}</div>
        <div class="result-meta">${meta.map((tag) => `<span class="chip">${esc(tag)}</span>`).join('')}</div>
        <div class="result-excerpt">${excerpt}</div>
        <div class="result-path">${esc(item.path)}</div>
      </button>
    `;
  }).join('');
}

function updateSummary() {
  const scope = state.vault === 'all' ? 'all vaults' : vaultLabel(state.vault);
  els.resultsSummary.textContent = `Showing ${state.filtered.length} of ${state.data.length} notes in ${scope}.`;

  const selected = getSelectedItem();
  if (!selected) {
    els.statusBox.textContent = 'No note selected. Click any result to choose one.';
    return;
  }

  els.statusBox.textContent = `Selected: ${selected.title} (${selected.vaultLabel || vaultLabel(selected.vault)})`;
}

function applyAndRender() {
  applyFilters();
  renderVaultNav();
  renderResults();
  updateSummary();
}

function markdownMetaChips(item) {
  const parts = [
    item.vaultLabel || vaultLabel(item.vault),
    item.type,
    item.section,
    item.zone ? `Zone ${item.zone}` : null,
    item.startMonth ? `Start: ${item.startMonth}` : null,
    item.harvest ? `Harvest: ${item.harvest}` : null
  ].filter(Boolean);

  return parts.map((part) => `<span class="chip">${esc(part)}</span>`).join('');
}

function openNote(item) {
  if (!item) return;

  els.dialogTitle.textContent = item.title;
  els.dialogMeta.innerHTML = markdownMetaChips(item) + `<span class="chip">${esc(item.path)}</span>`;
  els.dialogBody.innerHTML = item.html || '<p>No content.</p>';
  els.noteDialog.showModal();
}

function repoLinkFor(item) {
  const { hostname, pathname } = window.location;

  if (hostname.endsWith('github.io')) {
    const owner = hostname.split('.')[0];
    const repo = pathname.split('/').filter(Boolean)[0] || 'Gardening-Vault';
    return `https://github.com/${owner}/${repo}/blob/main/${encodeURI(item.path)}`;
  }

  return `https://github.com/robosuit/Gardening-Vault/blob/main/${encodeURI(item.path)}`;
}

async function copySelectedPath() {
  const selected = getSelectedItem();
  if (!selected) return;

  try {
    await navigator.clipboard.writeText(selected.path);
    els.statusBox.textContent = `Copied path: ${selected.path}`;
  } catch (error) {
    els.statusBox.textContent = 'Clipboard copy failed in this browser context.';
    console.error(error);
  }
}

function downloadFilteredData() {
  const payload = JSON.stringify(state.filtered, null, 2);
  const blob = new Blob([payload], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = 'gardening-vault-filtered.json';
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function setView(view) {
  state.view = view;
  document.querySelectorAll('[data-view]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.view === view);
  });
  renderResults();
}

function setQuick(quick) {
  state.quick = quick;
  document.querySelectorAll('[data-quick]').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.quick === quick);
  });
  applyAndRender();
}

function resetFilters() {
  state.vault = 'all';
  state.quick = 'all';
  state.query = '';
  state.type = 'all';
  state.sort = 'title-asc';

  els.searchInput.value = '';
  els.sortSelect.value = 'title-asc';
  els.typeSelect.value = 'all';

  setQuick('all');
}

async function loadData() {
  const basePath = getBasePath();

  try {
    const response = await fetch(`${basePath}/data/plants.json`);
    if (!response.ok) throw new Error(`Could not load data (${response.status})`);

    state.data = await response.json();
    renderTypeOptions();
    applyAndRender();
  } catch (error) {
    els.results.innerHTML = `
      <div class="empty">
        <h3>Data load failed</h3>
        <p>${esc(error.message)}</p>
      </div>
    `;
    els.statusBox.textContent = 'Build the JSON with npm run build-data and reload.';
    console.error(error);
  }
}

function wireEvents() {
  els.vaultNav.addEventListener('click', (event) => {
    const button = event.target.closest('[data-vault]');
    if (!button) return;
    state.vault = button.dataset.vault;
    applyAndRender();
  });

  els.results.addEventListener('click', (event) => {
    const card = event.target.closest('.result-card');
    if (!card) return;
    state.selectedId = card.dataset.id;
    renderResults();
    updateSummary();
  });

  els.results.addEventListener('dblclick', (event) => {
    const card = event.target.closest('.result-card');
    if (!card) return;
    const item = state.data.find((entry) => entry.id === card.dataset.id);
    openNote(item);
  });

  els.searchInput.addEventListener('input', (event) => {
    state.query = event.target.value;
    applyAndRender();
  });

  els.sortSelect.addEventListener('change', (event) => {
    state.sort = event.target.value;
    applyAndRender();
  });

  els.typeSelect.addEventListener('change', (event) => {
    state.type = event.target.value;
    applyAndRender();
  });

  document.querySelectorAll('[data-quick]').forEach((btn) => {
    btn.addEventListener('click', () => setQuick(btn.dataset.quick));
  });

  document.querySelectorAll('[data-view]').forEach((btn) => {
    btn.addEventListener('click', () => setView(btn.dataset.view));
  });

  els.openSelectedBtn.addEventListener('click', () => openNote(getSelectedItem()));
  els.copyPathBtn.addEventListener('click', () => copySelectedPath());

  els.sourceBtn.addEventListener('click', () => {
    const selected = getSelectedItem();
    if (!selected) return;
    window.open(repoLinkFor(selected), '_blank', 'noopener');
  });

  els.downloadBtn.addEventListener('click', downloadFilteredData);
  els.resetBtn.addEventListener('click', resetFilters);

  els.openHelpBtn.addEventListener('click', () => els.helpDialog.showModal());
  els.helpRailBtn.addEventListener('click', () => els.helpDialog.showModal());

  els.closeNoteDialog.addEventListener('click', () => els.noteDialog.close());
  els.closeHelpDialog.addEventListener('click', () => els.helpDialog.close());
}

document.addEventListener('DOMContentLoaded', () => {
  wireEvents();
  loadData();
});
