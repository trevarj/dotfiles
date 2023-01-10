return {
  {
    "nvim-lualine/lualine.nvim",
    -- dependencies = { "nvim-lua/lsp-status.nvim" },
    event = "VeryLazy",
    opts = function(_, opts)
      table.remove(opts.sections.lualine_z)
      -- table.insert(opts.sections.lualine_z, "require('lsp-status').status()")
    end,
  },
}
