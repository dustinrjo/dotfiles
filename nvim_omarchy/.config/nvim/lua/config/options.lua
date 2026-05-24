-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false

-- macOS system clipboard integration
if vim.fn.has("macunix") == 1 then
  vim.opt.clipboard = "unnamedplus"
end
