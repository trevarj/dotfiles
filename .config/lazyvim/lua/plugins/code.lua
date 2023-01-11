return {
  -- add telescope-fzf-native
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
    -- apply the config and additionally load fzf-native
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      opts.defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,

        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = { ["q"] = actions.close },
        },
      }
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rust",
        "toml",
        "haskell",
        "diff",
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      local compare = cmp.config.compare
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" }, { name = "crates" } }))
      opts.sorting = {

        priority_weight = 2,
        comparators = {
          compare.exact,
          compare.order,
          -- compare.offset,
          -- compare.scopes,
          -- compare.score,
          compare.recently_used,
          compare.locality,
          -- compare.kind,
          compare.sort_text,
          -- compare.length,
        },
      }
    end,
  },
  {
    "saecki/crates.nvim",
    dependencies = "hrsh7th/nvim-cmp",
    ft = "Cargo.toml",
    init = function()
      require("crates").setup()
    end,
  },
}
