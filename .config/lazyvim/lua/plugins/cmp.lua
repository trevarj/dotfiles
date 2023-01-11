return {
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
