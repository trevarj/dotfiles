-- LazyVim plugins that I don't want
local osName = io.popen("uname -s"):read("*a")
local enable = osName ~= "FreeBSD\n"
return {
  { "catppuccin", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },
  { "echasnovski/mini.ai", enabled = false },
  { "echasnovski/mini.indentscope", enabled = false },
  { "echasnovski/mini.pairs", enabled = false },
  { "williamboman/mason-lspconfig.nvim", enabled = enable },
  { "williamboman/mason.nvim", enabled = enable },
}
