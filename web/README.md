This `web/` folder is the generated website root for Gardening Vault.

Workflow:
- Edit markdown files in your Obsidian vaults (e.g. `Herbalism-Vault/01_Plants/`)
- Run `npm ci` once, then `npm run build-data` to regenerate `web/data/plants.json`
- Serve locally with `npm start` or push to GitHub and the Action will publish `/web` to Pages.
