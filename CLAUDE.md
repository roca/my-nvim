# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration based on [Josean Martinez's setup](https://github.com/josean-dev/dev-environment-files). Uses lazy.nvim as the plugin manager. Configured for web development (TypeScript/JavaScript/React/Svelte), Python, Go, and Lua.

**Requires Neovim 0.11+** — the LSP setup uses the native `vim.lsp.config()` / `vim.lsp.enable()` API, which does not exist in 0.10 or earlier.

The `dev-environment-files/` directory is a copy of the upstream reference repo — do not modify it. All active configuration lives at the repo root. Both `dev-environment-files/` and `pack/` are gitignored, so they will appear in the working tree but never in diffs.

`.github/workflows/` contains Claude Code GitHub Actions (`claude.yml`, `claude-code-review.yml`) — these automate PR review for this repo and are unrelated to the Neovim config itself.

## Architecture

**Entry point**: `init.lua` loads two modules:
- `josean.core` (via `lua/josean/core/init.lua`) — loads `options.lua` and `keymaps.lua`
- `josean.lazy` (via `lua/josean/lazy.lua`) — bootstraps lazy.nvim plugin manager

**Plugin system**: lazy.nvim auto-imports from two directories:
- `lua/josean/plugins/*.lua` — general plugin configs
- `lua/josean/plugins/lsp/*.lua` — LSP-specific configs (`lspconfig.lua`, `mason.lua`)

Each plugin file returns a lazy.nvim spec table. To add a plugin, create a new `.lua` file in `lua/josean/plugins/` returning its spec. `lua/josean/plugins/init.lua` is special — it returns a flat list of simple plugin specs (no config). In `lazy.lua`, the update checker is enabled but silent (`notify = false`), as is change detection — pending update counts surface in the lualine statusline rather than as popups.

**LSP pipeline**: mason.nvim installs servers/tools → mason-lspconfig (v2, `main` branch) auto-enables each installed server via `vim.lsp.enable()` → a single wildcard `vim.lsp.config("*")` applies shared cmp-nvim-lsp capabilities (plus gopls `showDocument` support) to every server. LSP keybindings are set up via an `LspAttach` autocmd in `lspconfig.lua`.

Critically, there are **no per-server `setup()` calls** — enabling is automatic from mason-lspconfig's `ensure_installed` list. To add a server, add it to `ensure_installed` in `mason.lua` and nothing else. Only add a `vim.lsp.config("<server>", {...})` block in `lspconfig.lua` if that server needs settings beyond the shared defaults.

**Formatting pipeline**: conform.nvim handles format-on-save (3s timeout, LSP fallback) and manual formatting via `<leader>mp` (1s timeout). Go files are formatted separately by go.nvim (`goimports` on save), not conform.nvim — Go is intentionally absent from conform's `formatters_by_ft`.

**Linting pipeline**: nvim-lint runs on `BufEnter`, `BufWritePost`, `InsertLeave`. Currently only `pylint` is active (eslint_d is installed by mason but not configured as a linter — the eslint LSP server handles JS/TS linting instead). The linting module has commented-out logic for conditionally removing eslint_d when no config file is found — this can be re-enabled if eslint_d is added back as a linter.

**Completion pipeline**: nvim-cmp sources (in priority order): LSP, LuaSnip snippets, buffer text, file paths. Uses `<C-j>`/`<C-k>` to navigate, `<CR>` to confirm (no auto-select), `<C-Space>` to trigger manually. LuaSnip loads VSCode-style snippets from friendly-snippets.

**Commenting**: Comment.nvim with ts-context-commentstring for correct comment syntax in embedded languages (JSX/TSX/Svelte/HTML).

## Key Design Decisions

- **Leader key**: `<Space>`
- **Insert mode exit**: `jk` instead of `<Esc>`
- **Copilot accept**: `<Shift-Tab>` (not default Tab, to avoid conflicts with nvim-cmp). Copilot's built-in `accept` is disabled; acceptance is handled via a custom keymap that falls back to normal `<S-Tab>` when no suggestion is visible
- **netrw disabled** in favor of nvim-tree (width: 50, wider than default)
- **auto-session**: auto-restore is disabled; manual restore with `<leader>wr`, save with `<leader>ws`
- **tmux integration**: vim-tmux-navigator for seamless split navigation between nvim and tmux
- **Format-on-save**: enabled globally, aggressive 3s timeout
- **Go files**: auto-run `goimports` on save via go.nvim (separate from conform.nvim pipeline)
- **Commented-out LSP configs**: Several server-specific configs in `lspconfig.lua` are commented out (svelte, graphql, emmet_ls, eslint, lua_ls). These were previously active and can be uncommented if custom per-server settings are needed again. They are safe to leave commented because mason-lspconfig auto-enables the servers regardless.
- **Plugins are fetched over SSH**, not HTTPS: `lazy.lua` sets `git.url_format = "git@github.com:%s.git"` because Zscaler TLS interception on this machine intermittently resets HTTPS connections to github.com (`LibreSSL SSL_connect: SSL_ERROR_SYSCALL`). **This makes a working GitHub SSH key a hard prerequisite** — on a fresh machine without one, no plugin will install. Drop the `git` block to fall back to HTTPS. Note that lazy.nvim's bootstrap clone at the top of `lazy.lua` still uses HTTPS deliberately, so lazy itself can install before any key exists. If you ever change `url_format`, also rewrite the existing plugin remotes (`git -C <dir> remote set-url origin ...`) — on an origin/url mismatch lazy **deletes and re-clones** the plugin rather than fixing the remote, which would re-trigger every `build` step.
- **treesitter is pinned to `branch = "master"`** and set `lazy = false`. Do not "upgrade" it to the `main` branch — that is a breaking rewrite with a different config API that would invalidate `treesitter.lua` entirely.
- **`<leader>se` is double-bound** (a known conflict): `core/keymaps.lua` maps it to "make splits equal size", then `emoji.lua` (which sets `lazy = false`, so it loads at startup after core) overwrites it with the emoji picker. The emoji picker wins; the split-resize binding is effectively dead. Use `<C-w>=` directly for split resizing, or rebind one of the two if this matters.

## LSP Servers (auto-installed via mason)

ts_ls, eslint, html, cssls, tailwindcss, svelte, lua_ls, graphql, emmet_ls, prismals, pyright, gopls, templ

## Formatters (auto-installed via mason)

prettier (JS/TS/React/Svelte/CSS/HTML/JSON/YAML/Markdown/GraphQL/Liquid), stylua (Lua), isort + black (Python)

## Theme

tokyonight "night" style with **active** custom overrides in `colorscheme.lua`:

- `on_colors` replaces the whole palette with a custom dark-blue scheme (bg `#011628`, bg_dark `#011423`) and forces comments to pure yellow (`#ffff00`)
- `on_highlights` paints brackets/parens pink (`@punctuation.bracket` → `#ff69b4`)
- Transparency is togglable via the `transparent` local at the top of the file (currently `false`); it gates sidebar/float/statusline backgrounds

Colors set outside tokyonight: line numbers are yellow (`LineNr` in `core/options.lua`), Copilot inline suggestions are purple (`#a855f7` in `copilot.lua`), and lualine has its own hardcoded theme table (`lualine.lua`) that does not derive from tokyonight. Changing the colorscheme will not update lualine or those overrides.

## Editor Settings

- 2-space indentation (spaces, not tabs) — but see the stylua caveat below
- Relative line numbers, yellow line number color
- System clipboard (`unnamedplus`)
- Splits open right/below
- No line wrapping
- Case-insensitive search with smart case

**stylua caveat**: there is no `.stylua.toml`, so stylua runs with its defaults (**tabs**, width 4) — which contradicts the 2-space editor setting. Because conform formats Lua on save, any config file opened and saved in Neovim gets converted to tabs. The repo is consequently split: roughly half the plugin files use tabs (those saved since stylua became active) and half use 2 spaces (those not yet touched). When editing, match the file you are in rather than normalizing it, otherwise the diff balloons to the whole file. Add a `.stylua.toml` if consistent indentation is wanted.

## Testing Configuration Changes

- Restart Neovim or `:source %` to reload
- `:checkhealth` to diagnose issues
- `:Lazy` to manage plugins, `:Lazy sync` to update `lazy-lock.json`
- `:Mason` to manage LSP servers/formatters/linters
- `:LspInfo` / `:LspRestart` for LSP status
- After editing a plugin file, the simplest verification is restarting Neovim and checking `:Lazy` for errors

## Notable Keybindings

Most keybindings are discoverable via which-key (press `<leader>` and wait). Key non-obvious bindings:

| Binding | Mode | Action |
|---------|------|--------|
| `jk` | insert | Exit insert mode |
| `<S-Tab>` | insert | Accept Copilot suggestion |
| `<C-k>`/`<C-j>` | Telescope | Navigate results up/down |
| `<C-q>` | Telescope | Send selection to quickfix (Trouble) |
| `<C-t>` | Telescope | Open in Trouble |
| `<leader>l` | normal | Trigger linting manually |
| `<leader>mp` | normal/visual | Format file or range |
| `<leader>gh` | normal | Inspect Go type (hover) |
| `<leader>wr` | normal | Restore session |
| `<leader>ws` | normal | Save session |
| `<leader>st` | normal | Open horizontal terminal split |
| `<leader>cd` | normal | Copy current working directory to clipboard |
| `<leader>se` | normal | Search emoji (Telescope) — shadows "make splits equal size", see conflict note above |
| `<C-Space>` | insert (cmp) | Trigger completion manually |
| `<C-k>`/`<C-j>` | insert (cmp) | Navigate completion items |
| `<CR>` | insert (cmp) | Confirm completion (no auto-select) |
| `<C-space>` | normal/visual | Treesitter incremental selection (same key as cmp, but different mode, so no conflict); `<BS>` shrinks |
