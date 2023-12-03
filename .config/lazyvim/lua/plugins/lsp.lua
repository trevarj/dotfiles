return {
  {
    "mrcjkb/rustaceanvim",
    -- version = "^3", -- Recommended
    ft = { "rust" },
    keys = {},
  },
  {
    "Olical/conjure",
    branch = "develop",
    ft = { "scheme" },
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
      vim.g["conjure#filetype#scheme"] = "conjure.client.scheme.stdio"
      vim.g["conjure#client#scheme#stdio#command"] = "chicken-csi -q"
      vim.g["conjure#client#scheme#stdio#prompt_pattern"] = "\n#;%d> "
      vim.g["conjure#client#scheme#stdio#value_prefix_pattern"] = false
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        guile_ls = {
          mason = false,
          cmd = { "/home/trevor/Workspace/chicken-5.3.0/start_chicken_ls.sh" },
          filetypes = { "scheme" },
          single_file_support = true,
          root_dir = require("lspconfig.util").root_pattern(".git"),
        },
      },
      setup = {
        guile_ls = function(_, opts) end,
      },
    },
  },
}
