-- LazyVim plugins that I don't want
local osName = io.popen("uname -s"):read("*a")
local enable = osName ~= "FreeBSD\n"
return {
  { "catppuccin", enabled = false },
  { "echasnovski/mini.ai", enabled = false },
  { "echasnovski/mini.indentscope", enabled = false },
  { "echasnovski/mini.pairs", enabled = false },
  { "folke/noice.nvim", enabled = true },
  { "folke/tokyonight.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "stevearc/dressing.nvim", enabled = true },
  { "williamboman/mason-lspconfig.nvim", enabled = enable },
  { "williamboman/mason.nvim", enabled = enable },
}
