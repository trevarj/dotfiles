-- LazyVim plugins that I don't want
local osName = io.popen("uname -s"):read("*a")
local enable = osName ~= "FreeBSD\n"
return {
  { "catppuccin", enabled = false },
  { "folke/trouble.nvim", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },
  { "echasnovski/mini.ai", enabled = true },
  { "echasnovski/mini.indentscope", enabled = true },
  { "williamboman/mason-lspconfig.nvim", enabled = enable },
  { "williamboman/mason.nvim", enabled = enable },
}
