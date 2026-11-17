
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- GitHub (or Zscaler) throttles bursts of new SSH connections: after ~20 in quick
-- succession, connects/banner exchanges time out for a couple of minutes. Multiplex
-- every git call from nvim over one shared connection so updates only connect once.
if not vim.env.GIT_SSH_COMMAND then
  vim.env.GIT_SSH_COMMAND = "ssh -o ControlMaster=auto -o ControlPersist=60 -o ControlPath="
    .. vim.fn.stdpath("cache")
    .. "/ssh-%C"
end

require("lazy").setup({ { import = "josean.plugins" }, { import = "josean.plugins.lsp" } }, {
  -- Default on macOS is unlimited. Jobs that start before the shared SSH master
  -- exists each open their own connection, so keep the initial burst small.
  concurrency = 4,
  git = {
    -- Fetch over SSH: corporate Zscaler TLS interception intermittently resets
    -- HTTPS connections to github.com, which surfaces as SSL_ERROR_SYSCALL.
    url_format = "git@github.com:%s.git",
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  }
})
