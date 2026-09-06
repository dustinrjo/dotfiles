-- Keep LazyVim's markdown extra (render-markdown, marksman, preview) but drop
-- markdownlint's style nags. Write in source; read via render-markdown.
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = {}
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- Don't let markdownlint-cli2 rewrite wrapping/blank-lines on :Format.
      -- Explicit format still has prettier if you want it.
      opts.formatters_by_ft.markdown = { "prettier" }
      opts.formatters_by_ft["markdown.mdx"] = { "prettier" }
      return opts
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    opts = {
      -- Rendered in normal/command; raw source while inserting.
      render_modes = { "n", "c", "t" },
      anti_conceal = { enabled = true },
      heading = {
        sign = false,
        -- LazyVim's extra sets icons = {} which leaves headings looking like source.
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      checkbox = { enabled = true },
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },
    },
  },
}
