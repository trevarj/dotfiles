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
        sumneko_lua = {},
      },
      setup = {
        rust_analyzer = function(_, opts)
          local rt = require("rust-tools")
          rt.setup({ server = opts })

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
}
