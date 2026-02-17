# VS Code Auto-Adjust Prompt

Use this prompt in VS Code Copilot/Chat to re-run the same normalization:

```
Project root: Gardening-Vault

Run this script and then summarize results:
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/update_vault_metadata.ps1

After running:
1) Confirm counts of files in Herbalism-Vault/01_Plants, Vegetable-Vault/01_Crops, and Wildflower-Vault/01_Plants.
2) Verify every herb and vegetable file has these frontmatter fields:
   Start Method
   Days to Germination
   Bloom Days
   Bloom Speed Tier
   Pollinator Value
   Nectar Level
   Pollen Level
   Indoor Bloom Viable
3) Report bloom tier distribution and high-pollinator totals.
4) Regenerate index files only if counts or metadata drift.
```
