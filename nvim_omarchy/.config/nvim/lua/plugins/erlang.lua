return {
	-- Treesitter parser for Erlang
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "erlang" })
		end,
	},
	-- Erlang LSP via Mason
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				erlangls = {},
			},
		},
	},
	-- Ensure erlang_ls is installed via Mason
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "erlang-ls" })
		end,
	},
}
