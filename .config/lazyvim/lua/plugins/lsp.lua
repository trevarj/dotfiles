return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "simrat39/rust-tools.nvim",
    },
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        rust_analyzer = {},
        lua_ls = {},
      },
      setup = {
        rust_analyzer = function(_, opts)
          local rt = require("rust-tools")
          local rust_tools_opts = vim.tbl_deep_extend("force", opts, {
            root_dir = function(fname)
              local util = require("lspconfig/util")
              return util.find_git_ancestor(fname)
                or util.root_pattern("rust-project.json")(fname)
                or util.root_pattern("Cargo.toml")(fname)
            end,
            tools = {
              hover_actions = {
                auto_focus = false,
              },
              inlay_hints = {
                auto = true,
                show_parameter_hints = true,
              },
            },
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  features = "all",
                  loadOutDirsFromCheck = true,
                  buildScripts = {
                    enable = true,
                  },
                },
                checkOnSave = false,
                check = {
                  command = "clippy",
                  extraArgs = { "--no-deps", "--", "--message-format=json" },
                },
                procMacro = {
                  enable = true,
                },
                lens = {
                  enable = false,
                },
                imports = {
                  prefix = "crate",
                },
              },
            },
          })
          rt.setup({ server = rust_tools_opts })

          require("lazyvim.util").on_attach(function(client, bufnr)
            if client.name == "rust_analyzer" then
              -- Hover actions
              vim.keymap.set(
                "n",
                "<leader>ch",
                rt.hover_actions.hover_actions,
                { desc = "Hover Actions", buffer = bufnr }
              )
              -- Code action groups
              vim.keymap.set(
                "n",
                "<leader>cA",
                rt.code_action_group.code_action_group,
                { desc = "Run Rust Code Actions", buffer = bufnr }
              )
              -- Runnables
              vim.keymap.set("n", "<leader>ce", rt.runnables.runnables, { desc = "Runnables", buffer = bufnr })
              -- Expand macros
              vim.keymap.set(
                "n",
                "<leader>cE",
                rt.expand_macro.expand_macro,
                { desc = "Expand Macro Recursively", buffer = bufnr }
              )
            end
          end)
          return true
        end,
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      -- ensure_installed = {
      --   "stylua",
      --   "shellcheck",
      --   "shfmt",
      --   "rust-analyzer",
      --   "markdownlint",
      -- },
    },
  },
}
