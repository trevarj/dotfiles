return {
  -- add telescope-fzf-native
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
    keys = {
      {
        "<leader>fc",
        function()
          require("telescope.builtin").grep_string()
        end,
        desc = "Search for word under cursor",
      },
      {
        "<leader>fl",
        "<cmd>Telescope resume<cr>",
        desc = "Resume last search",
      },
    },
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

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- they way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
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
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
    },
    opts = {
      view = {
        merge_tool = {
          disable_diagnostics = true,
        },
      },
    },
  },
}
