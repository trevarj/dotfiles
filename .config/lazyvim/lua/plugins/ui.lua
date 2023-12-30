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
          keywords = { fg = colors.aurora.orange, bold = true },
          functions = { bold = true },
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
          hl.GitSignsCurrentLineBlame = { fg = c.polar_night.light }
          hl.MatchParen = { fg = c.aurora.yellow, bg = c.frost.artic_ocean }
          -- hl.NonText = { fg = c.polar_night.light }
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
      window = {
        width = 30,
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
    -- dependencies = { "nvim-lua/lsp-status.nvim" },
    dependencies = { "gbprod/nord.nvim" },
    event = "VeryLazy",
    opts = function(_, opts)
      local colors = require("nord.colors").palette
      local nord = require("lualine.themes.nord")
      nord.normal.a.fg = colors.snow_storm.brighter
      nord.normal.a.bg = colors.polar_night.light
      nord.insert.a.bg = colors.aurora.red
      opts.options.theme = nord
      opts.sections.lualine_y = {
        { "progress", separator = "", padding = { left = 1, right = 1 } },
        { "location", padding = { left = 0, right = 1 } },
      }

      opts.sections.lualine_c = {}
      table.insert(opts.sections.lualine_c, {
        "filename",
        path = 1,
        shorting_target = 80,
      })
      table.remove(opts.sections.lualine_z)
      -- table.insert(opts.sections.lualine_z, "require('lsp-status').status()")
      table.insert(opts.sections.lualine_z, {
        "filetype",
        icon_only = true,
        color = {
          bg = colors.polar_night.brightest,
        },
      })
    end,
  },
  -- {
  --   "nvim-lua/lsp-status.nvim",
  --   config = function(_, _)
  --     require("lsp-status").config({
  --       status_symbol = "",
  --     })
  --   end,
  -- },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = false,
        show_buffer_close_icons = false,
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
    .                  .-.    .  _   *     _   .                  
           *          /   \     ((       _/ \       *    .        
         _    .   .--'\/\_ \     `      /    \  *    ___          
     *  / \_    _/ ^      \/\'__        /\/\  /\  __/   \ *       
       /    \  /    .'   _/  /  \  *' /    \/  \/ .`'\_/\   .     
  .   /\/\  /\/ :' __  ^/  ^/    `--./.'  ^  `-.\ _    _:\ _      
     /    \/  \  _/  \-' __/.' ^ _   \_   .'\   _/ \ .  __/ \     
   /\  .-   `. \/     \ / -.   _/ \ -. `_/   \ /    `._/  ^  \    
  /  `-.__ ^   / .-'.--'    . /    `--./ .-'  `-.  `-. `.  -  `.  
@/        `.  / /      `-.   /  .-'   / .   .'   \    \  \  .-  \%
@&8jgs@@%% @)&@&(88&@.-_=_-=_-=_-=_-=_.8@% &@&&8(8%@%8)(8@%8 8%@)%
@88:::&(&8&&8:::::%&`.~-_~~-~~_~-~_~-~~=.'@(&%::::%@8&8)::&#@8::::
::::::::8%@@%:::::@%&8:`.=~~-.~~-.~~=..~'8::::::::&@8:::::&8::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 ]]
      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
