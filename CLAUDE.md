# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Neovim configuration based on [Josean Martinez's setup](https://github.com/josean-dev/dev-environment-files). Uses lazy.nvim as the plugin manager. Configured for web development (TypeScript/JavaScript/React/Svelte), Python, Go, and Lua.

The `dev-environment-files/` directory is a copy of the upstream reference repo — do not modify it. All active configuration lives at the repo root.

## Architecture

**Entry point**: `init.lua` loads two modules:
- `josean.core` (via `lua/josean/core/init.lua`) — loads `options.lua` and `keymaps.lua`
- `josean.lazy` (via `lua/josean/lazy.lua`) — bootstraps lazy.nvim plugin manager

**Plugin system**: lazy.nvim auto-imports from two directories:
- `lua/josean/plugins/*.lua` — general plugin configs
- `lua/josean/plugins/lsp/*.lua` — LSP-specific configs (`lspconfig.lua`, `mason.lua`)

Each plugin file returns a lazy.nvim spec table. To add a plugin, create a new `.lua` file in `lua/josean/plugins/` returning its spec. `lua/josean/plugins/init.lua` is special — it returns a flat list of simple plugin specs (no config). lazy.nvim silently checks for plugin updates and change detection notifications are both disabled in `lazy.lua`.

**LSP pipeline**: mason.nvim installs servers/tools → mason-lspconfig bridges to lspconfig → lspconfig configures servers with cmp-nvim-lsp capabilities. LSP keybindings are set up via `LspAttach` autocmd in `lspconfig.lua`. A wildcard `vim.lsp.config("*")` applies shared capabilities (including gopls `showDocument` support) to all servers.

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
- **Commented-out LSP configs**: Several server-specific configs in `lspconfig.lua` are commented out (svelte, graphql, emmet_ls, eslint, lua_ls). These were previously active and can be uncommented if custom per-server settings are needed again.

## LSP Servers (auto-installed via mason)

ts_ls, eslint, html, cssls, tailwindcss, svelte, lua_ls, graphql, emmet_ls, prismals, pyright, gopls, templ

## Formatters (auto-installed via mason)

prettier (JS/TS/React/Svelte/CSS/HTML/JSON/YAML/Markdown/GraphQL/Liquid), stylua (Lua), isort + black (Python)

## Theme

tokyonight "night" style with default palette. Custom color overrides (dark blue background, yellow comments) exist in `colorscheme.lua` but are currently commented out. Copilot suggestions are purple (`#a855f7`). Transparency togglable via `transparent` variable in `colorscheme.lua`.

## Editor Settings

- 2-space indentation (spaces, not tabs)
- Relative line numbers, yellow line number color
- System clipboard (`unnamedplus`)
- Splits open right/below
- No line wrapping
- Case-insensitive search with smart case

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
| `<leader>se` | normal | Search emoji (Telescope, markdown files) |
| `<C-Space>` | insert (cmp) | Trigger completion manually |
| `<C-k>`/`<C-j>` | insert (cmp) | Navigate completion items |
| `<CR>` | insert (cmp) | Confirm completion (no auto-select) |
