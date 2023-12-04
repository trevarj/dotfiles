return {
  -- { "shaunsingh/nord.nvim" },
  {
    "gbprod/nord.nvim",
    opts = {
      errors = { mode = "fg" },
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = false },
        keywords = { bold = true },
        functions = {},
        variables = {},
        -- To customize lualine/bufferline
        bufferline = {
          current = {},
          modified = { italic = true },
        },
      },
      -- colorblind mode
      -- see https://github.com/EdenEast/nightfox.nvim#colorblind
      -- simulation mode has not been implemented yet.
      colorblind = {
        enable = true,
        preserve_background = true,
        severity = {
          protan = 0.4,
          deutan = 1.0,
          tritan = 0.0,
        },
      },
    },
  },
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
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },
  {
    "folke/noice.nvim",
    enabled = true,
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
        enabled = false,
      },
      notify = {
        view = "mini",
      },
      presets = {
        lsp_doc_border = true,
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-lua/lsp-status.nvim" },
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections.lualine_y = {
        { "progress", separator = "", padding = { left = 1, right = 1 } },
        { "location", padding = { left = 0, right = 1 } },
      }
      table.remove(opts.sections.lualine_z)
      table.insert(opts.sections.lualine_z, "require('lsp-status').status()")
    end,
  },
  {
    "nvim-lua/lsp-status.nvim",
    config = function(_, _)
      require("lsp-status").config({
        status_symbol = "",
      })
    end,
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
████████╗██████╗ ███████╗██╗   ██╗  ██╗███╗   ███╗
╚══██╔══╝██╔══██╗██╔════╝██║   ██║  ██║████╗ ████║
   ██║   ██████╔╝█████╗  ██║   ██║  ██║██╔████╔██║
   ██║   ██╔══██╗██╔══╝  ╚██╗ ██╔╝  ██║██║╚██╔╝██║
   ██║   ██║  ██║███████╗ ╚████╔╝██╗██║██║ ╚═╝ ██║
   ╚═╝   ╚═╝  ╚═╝╚══════╝  ╚═══╝ ╚═╝╚═╝╚═╝     ╚═╝
]]
      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
