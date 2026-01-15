# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration based on Josean Martinez's setup (https://github.com/josean-dev/dev-environment-files). It uses lazy.nvim as the plugin manager and is configured primarily for web development (TypeScript/JavaScript/React/Svelte), Python, Go, and Lua development.

## Configuration Architecture

### Entry Point & Module Loading
- **init.lua**: Main entry point that loads two core modules:
  - `josean.core`: Base configuration (options, keymaps)
  - `josean.lazy`: Plugin manager setup

### Core Configuration Structure
```
lua/josean/
├── core/
│   ├── init.lua          # Loads options and keymaps
│   ├── options.lua       # Vim options (tabstop, line numbers, etc.)
│   └── keymaps.lua       # Global keybindings
├── lazy.lua              # lazy.nvim setup and plugin imports
└── plugins/              # Individual plugin configurations
    ├── lsp/              # LSP-specific plugins
    │   ├── lspconfig.lua # LSP configurations and keybindings
    │   └── mason.lua     # LSP/formatter/linter installer
    └── *.lua             # Other plugin configs (telescope, nvim-tree, etc.)
```

### Plugin System
- Uses **lazy.nvim** for plugin management
- Each plugin has its own configuration file in `lua/josean/plugins/`
- Plugins are auto-imported from `josean.plugins` and `josean.plugins.lsp`
- Plugin update checking is enabled but silent (no notifications)

## Key Keybindings

**Leader key**: `<Space>`

### Essential Bindings
- `jk` (insert mode): Exit to normal mode
- `<leader>nh`: Clear search highlights
- `<leader>ee`: Toggle file explorer (nvim-tree)
- `<leader>ef`: Toggle file explorer on current file
- `<leader>ff`: Fuzzy find files (Telescope)
- `<leader>fs`: Live grep search (Telescope)
- `<leader>fr`: Recent files (Telescope)
- `<leader>ft`: Find todos (Telescope)

### Window/Split Management
- `<leader>sv`: Split vertically
- `<leader>sh`: Split horizontally
- `<leader>se`: Make splits equal size
- `<leader>sx`: Close current split
- `<leader>st`: Open horizontal terminal

### Tab Management
- `<leader>to`: Open new tab
- `<leader>tx`: Close current tab
- `<leader>tn`: Next tab
- `<leader>tp`: Previous tab

### LSP Keybindings (when LSP is attached)
- `gR`: Show LSP references (Telescope)
- `gD`: Go to declaration
- `gd`: Show definitions (Telescope)
- `gi`: Show implementations (Telescope)
- `gt`: Show type definitions (Telescope)
- `K`: Show documentation/hover
- `<leader>ca`: Code actions
- `<leader>rn`: Smart rename
- `<leader>d`: Show line diagnostics
- `<leader>D`: Show buffer diagnostics
- `[d` / `]d`: Previous/next diagnostic
- `<leader>rs`: Restart LSP
- `<leader>gh`: Inspect Go type (hover)

### Formatting & Linting
- `<leader>mp`: Format file or range (conform.nvim)
- `<leader>l`: Trigger linting manually

## Language Server & Tooling Setup

### LSP Servers (auto-installed via mason.nvim)
- **TypeScript/JavaScript**: ts_ls, eslint
- **Web**: html, cssls, tailwindcss, emmet_ls
- **Frameworks**: svelte
- **GraphQL**: graphql
- **Databases**: prismals
- **Python**: pyright
- **Go**: gopls, templ
- **Lua**: lua_ls

### Formatters (auto-installed)
- **prettier**: JS/TS/React/Svelte/CSS/HTML/JSON/YAML/Markdown/GraphQL
- **stylua**: Lua
- **isort + black**: Python

### Linters (auto-installed)
- **pylint**: Python
- **eslint_d**: JavaScript/TypeScript

### Format-on-Save
- Enabled by default via conform.nvim
- Timeout: 3000ms
- Falls back to LSP formatting if formatter not available

### Go-specific Configuration
- Uses go.nvim plugin
- Auto-runs `goimports` on save for Go files
- Includes gopls LSP integration

## Development Workflow

### Making Configuration Changes
1. Edit files in `lua/josean/core/` for core settings
2. Edit files in `lua/josean/plugins/` for plugin configurations
3. Changes take effect after `:source %` or restart

### Adding New Plugins
1. Create new file in `lua/josean/plugins/` (e.g., `my-plugin.lua`)
2. Return a lazy.nvim plugin spec (table with plugin name and config)
3. Plugin will be auto-loaded on next restart

### Adding New LSP Servers
1. Add server name to `ensure_installed` in `lua/josean/plugins/lsp/mason.lua`
2. Optionally configure server-specific settings in `lua/josean/plugins/lsp/lspconfig.lua`
3. Run `:Mason` to verify installation

### Testing Configuration
- Restart Neovim to reload configuration
- Use `:checkhealth` to diagnose issues
- Use `:Lazy` to manage plugins
- Use `:Mason` to manage LSP servers/formatters/linters
- Use `:LspInfo` to check LSP status
- Use `:LspRestart` to restart LSP servers

## Editor Settings

### Indentation
- Tab width: 2 spaces
- Uses spaces (not tabs)
- Auto-indent enabled

### Display
- Relative line numbers enabled
- Line numbers colored yellow
- Cursor line highlighted
- Sign column always visible (for diagnostics)
- No line wrapping

### Clipboard
- Uses system clipboard (`unnamedplus`)

### Splits
- Vertical splits open to the right
- Horizontal splits open below

## Important Notes

- The configuration disables netrw in favor of nvim-tree
- Format-on-save is aggressive (3s timeout) and enabled globally
- Go files run goimports automatically on save
- LSP diagnostic signs use nerd font icons
- File explorer filters out `.DS_Store` files
