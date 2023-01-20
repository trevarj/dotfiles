return {
  { "shaunsingh/nord.nvim" },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          hide_gitignored = false,
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        view = "cmdline",
        format = {
          cmdline = {
            icon = ":",
          },
        },
      },
      messages = {
        view = "mini",
        view_warn = "mini",
        view_error = "mini",
      },
      popupmenu = {
        backend = "cmp",
      },
    },
  },
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
