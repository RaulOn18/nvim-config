# Ponytail Debt Ledger

Auto-generated list of `ponytail:` comment markers in this repo. Each row is a
deliberate shortcut: the comment names the ceiling (what the shortcut can't
handle) and the upgrade path (what triggers fixing it). A row without an
upgrade trigger gets a `no-trigger` tag — rot risk.

Regenerate by invoking the `ponytail-debt` skill.

---

## Ledger

**No ponytail: debt. Clean ledger.** The lone stale `ponytail:` marker (autocmds.lua:3) was a deletion log, not a live deferral — converted to a plain `NOTE:` comment.

---

## Recently Paid Debts (this session)

The following 12 markers were paid in this session. The `ponytail:` comments
were removed; the code changes are listed for the record.

| # | File | Change |
|---|------|--------|
| 1 | `lua/mappings.lua:7` | Deleted 7-line `gD` fallback. Trust NvChad to bind `gD`. |
| 2 | `lua/configs/lspconfig.lua:6` | Deleted 14-line `silent_on` loop. Re-enables ESLint Windows / vtsls 5.9.x error noise. |
| 3 | `lua/configs/conform.lua:21` | Restored 3 formatters (`dart_format`, `gofumpt`, `goimports`). |
| 4 | `lua/chadrc.lua:13` | Restored 5 `@lsp.type.*.kotlin` hl_override entries. |
| 5 | `lua/configs/on_attach.lua:5` | Removed `kotlin_lsp` from `SEM_TOK_OFF` (3 servers now). Comment removed. |
| 6 | `lua/plugins/kotlin.lua:3` | Spec changed `ft = { "kotlin" }` → `event = "VeryLazy"`; added `keys` field with `<leader>rG/B/R` (moved from mappings.lua). |
| 7 | `lua/plugins/ide.lua:27` | Removed stale comment; `rG/B/R` now actually live in `plugins/kotlin.lua` keys. |
| 8 | `lua/mappings.lua:39-43` | Deleted rG/B/R block (moved to kotlin.lua). |
| 9 | `lua/plugins/flutter.lua:1` | Restored 14-item `commands` picker, `is_flutter_project()` guard (used in FileType autocmd), `codeActionProvider = { codeActionKinds = {} }` dance (in dartls on_attach). |
| 10 | `lua/options.lua:54` | Replaced 3-line `vim.fn.has "clipboard"` one-liner with 13-line OS+executable probe (pbcopy / xclip / xsel / powershell). |
| 11 | `lua/plugins/debug.lua:2` | Replaced 2-path codelldb fallback with 8-path search. |
| 12 | `lua/utils/c.lua:2` | Added `compile_commands_dir()` (hand-rolled regex per original) and `cd_shell()` (Windows `cd /d`). `build_dir` now consults compile_commands.json first. |
| 13 | `lua/plugins/sql.lua:13` | Removed stale marker — the upstream's own README still recommends `init = function() vim.g.db_ui_use_nerd_fonts = 1 end`; the plugin has no `setup({…})`. The code was canonical, not a workaround. |

**Line count:** 1300 → 1338 (+38 lines; restores that the audit had removed).

## Resolved Blocker Note (debt #13)

The original debt for `sql.lua:13` claimed the upstream "still uses `vim.g`" and an `opts` migration would break DBUI. Verified by reading upstream docs: that is correct. The plugin's `init` function setting `vim.g.db_ui_*` is the recommended pattern. There is no `setup({…})` function to migrate to. The `ponytail:` marker was removed because the current code matches what upstream itself documents. Re-add a `ponytail:` marker only if/when `vim-dadbod-ui` adds a `setup({opts})` function and `vim.g` becomes a fallback.
