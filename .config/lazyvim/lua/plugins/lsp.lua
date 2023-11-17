return {
  {
    "mrcjkb/rustaceanvim",
    -- version = "^3", -- Recommended
    ft = { "rust" },
    keys = {},
  },
  {
    "Olical/conjure",
    ft = { "scheme", "lisp", "fennel" },
    dependencies = {
      {
        "PaterJason/cmp-conjure",
        config = function()
          local cmp = require("cmp")
          local config = cmp.get_config()
          table.insert(config.sources, {
            name = "buffer",
            option = {
              sources = {
                { name = "conjure" },
              },
            },
          })
          cmp.setup(config)
        end,
      },
    },
    config = function(_, _)
      require("conjure.main").main()
      require("conjure.mapping")["on-filetype"]()
    end,
    init = function()
      -- Set configuration options here
      -- vim.g["conjure#debug"] = true
      vim.g["conjure#filetype#scheme"] = "conjure.client.guile.socket"
      vim.g["conjure#client#guile#socket#pipename"] = ".guile-repl.socket"
    end,
  },
}
