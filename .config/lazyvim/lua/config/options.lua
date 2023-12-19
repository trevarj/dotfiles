-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Rustacean
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {},
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      vim.lsp.inlay_hint.enable(bufnr)
      -- you can also put keymaps in here
    end,
    settings = {
      -- rust-analyzer language server configuration
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          runBuildScripts = true,
        },
        -- Add clippy lints for Rust.
        checkOnSave = {
          allFeatures = false,
          command = "clippy",
          extraArgs = { "--no-deps" },
        },
        procMacro = {
          enable = true,
          ignored = {
            ["async-trait"] = { "async_trait" },
            ["napi-derive"] = { "napi" },
            ["async-recursion"] = { "async_recursion" },
          },
        },
      },
    },
  },
  -- DAP configuration
  dap = {},
}

vim.opt.guicursor = "n-v-c:block,i:blinkon1"
-- tildes and diff view deletions
vim.opt.fillchars = "eob: ,diff:╱"

vim.opt.conceallevel = 0
vim.opt.cmdheight = 0
vim.opt.formatexpr = "" -- reset formatexpr for gq to work
vim.o.timeoutlen = 1000
vim.diagnostic.config({
  float = { border = "rounded" },
})
-- vim.lsp.set_log_level("debug")
