-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- macOS system clipboard integration (no-op on Linux, where remote_clipboard
-- above already installs a provider when it is needed)
if vim.fn.has("macunix") == 1 then
  vim.opt.clipboard = "unnamedplus"
end
