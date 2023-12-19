return {
  {
    "gbprod/nord.nvim",
    dev = false,
    opts = function(_, _)
      local colors = require("nord.colors").palette
      return {
        transparent = false, -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        diff = { mode = "fg" }, -- enables/disables colorful backgrounds when used in diff mode. values : [bg|fg]
        borders = true, -- Enable the border between verticaly split windows visible
        errors = { mode = "fg" }, -- Display mode for errors and diagnostics
        -- values : [bg|fg|none]
        search = { theme = "vim" }, -- theme for highlighting search results
        -- values : [vim|vscode]
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = false },
          keywords = { bold = true },
          functions = { fg = colors.aurora.orange, bold = true },
          variables = {},

          -- To customize lualine/bufferline
          bufferline = {
            current = {},
            modified = { italic = false },
          },
        },
        -- colorblind mode
        -- see https://github.com/EdenEast/nightfox.nvim#colorblind
        -- simulation mode has not been implemented yet.
        colorblind = {
          enable = true,
          preserve_background = true,
          severity = {
            protan = 0.2,
            deutan = 0.9,
            tritan = 0.4,
          },
        },

        --- You can override specific highlights to use other groups or a hex color
        --- function will be called with all highlights and the colorScheme table
        on_highlights = function(hl, c)
          hl.LspInlayHint = { fg = c.frost.artic_ocean }
        end,
      }
    end,
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
