-- Toggleable inline git blame.
--
-- LazyVim ships gitsigns but never enables `current_line_blame`, and maps
-- <leader>gb directly to the Snacks commit picker. This turns <leader>gb into a
-- blame submenu so the persistent overlay can live at <leader>gbv.
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true, -- on at startup; toggled with <leader>gbv
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol",
      delay = 300, -- gitsigns default of 1000ms feels laggy
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "  <author>, <author_time:%R> • <summary>",
  },
  init = function()
    -- Snacks and LazyVim's own keymaps are both in place by VeryLazy.
    LazyVim.on_very_lazy(function()
      -- <leader>gb is a direct mapping in LazyVim; drop it so the submenu
      -- opens immediately instead of stalling for 'timeoutlen'. Scheduled
      -- because LazyVim's own keymaps also land on VeryLazy, after this.
      vim.schedule(function()
        pcall(vim.keymap.del, "n", "<leader>gb")
      end)

      vim.keymap.set("n", "<leader>gbl", function()
        Snacks.picker.git_log_line()
      end, { desc = "Git Blame Line" })

      vim.keymap.set("n", "<leader>gbb", function()
        require("gitsigns").blame_line({ full = true })
      end, { desc = "Blame Line (popup)" })

      Snacks.toggle({
        name = "Inline Git Blame",
        get = function()
          return require("gitsigns.config").config.current_line_blame
        end,
        set = function(state)
          require("gitsigns").toggle_current_line_blame(state)
        end,
      }):map("<leader>gbv")

      require("which-key").add({ { "<leader>gb", group = "blame" } })
    end)
  end,
}
