return {
  {
    "nvim-lualine/lualine.nvim",
    -- dependencies = { "nvim-lua/lsp-status.nvim" },
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections.lualine_y = {
        { "progress", separator = "", padding = { left = 1, right = 1 } },
        { "location", padding = { left = 0, right = 1 } },
      }
      table.remove(opts.sections.lualine_z)
      -- table.insert(opts.sections.lualine_z, "require('lsp-status').status()")
    end,
  },
}
