-- LazyVim plugins that I don't want
local osName = io.popen("uname -s"):read("*a")
local freebsdDisable = osName ~= "FreeBSD"
return {
  { "catppuccin", enabled = false },
  { "folke/trouble.nvim", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },
  { "echasnovski/mini.ai", enabled = false },
  { "echasnovski/mini.indentscope", enabled = false },
  { "ggandor/leap.nvim", enabled = false },
  { "ggandor/flit.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = false },
  { "jose-elias-alvarez/null-ls.nvim", cond = freebsdDisable },
  { "williamboman/mason-lspconfig.nvim", cond = freebsdDisable },
  { "williamboman/mason.nvim", cond = freebsdDisable },
}
