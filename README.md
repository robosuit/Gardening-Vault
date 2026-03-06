This `web/` folder is the static website root for Gardening Vault.

Workflow:
- Edit markdown notes in vault folders (`Herbalism-Vault/`, `Vegetable-Vault/`, `Fruit-Berry-Vault/`, `Wildflower-Vault/`, etc.)
- Run `npm ci` once
- Run `npm run build-data` after note changes to regenerate `web/data/plants.json`
- Test locally with `npm start`
- Push to `main` and GitHub Actions will publish `web/` to GitHub Pages

Website behavior:
- Left panel: vault/category filtering
- Center rail: quick modes (`All`, `Plants`, `Indexes`, `Guides`) and card/list view toggles
- Right panel: sort controls, search, type filter, and actions
- Results area: selectable notes with full markdown preview modal
- Built-in help modal explains usage for new users
