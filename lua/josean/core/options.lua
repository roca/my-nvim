vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true

vim.api.nvim_set_hl(0, 'LineNr', { fg = 'yellow' })

-- tabs & indentations
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true --expand tab to spaces
opt.autoindent = true -- copy indent from current line when staring new one

opt.wrap = false

-- search settings
opt.ignorecase = true  -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorsscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorscheme that canm be light or dark wiil be made dark
opt.signcolumn = "yes" -- show sign column so that test doesn't shift

opt.backspace = "indent,eol,start" -- allow backspce on indent, end of line or insert mode start position

--clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true --split vertical window to the right
opt.splitbelow = true --split horizontal window to the bottom 
