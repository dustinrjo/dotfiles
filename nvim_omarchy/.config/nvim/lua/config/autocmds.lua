-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Soft-wrap markdown at word boundaries. LazyVim already sets wrap+spell for
-- markdown; linebreak keeps long prose readable without markdownlint's 80-col rule.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.linebreak = true
    vim.opt_local.textwidth = 0
  end,
})
