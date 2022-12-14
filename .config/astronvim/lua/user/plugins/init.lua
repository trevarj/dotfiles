return {
  ["sindrets/diffview.nvim"] = {
    opt = true,
    setup = function()
      table.insert(astronvim.git_plugins, "diffview.nvim")
    end,
    config = function()
      require("user.plugins.diffview")
    end,
  },
  ["lvimuser/lsp-inlayhints.nvim"] = {
    module = "lsp-inlayhints",
    config = function()
      require("user.plugins.lsp-inlayhints")
    end,
  },
  ["hrsh7th/cmp-nvim-lsp-signature-help"] = {
    after = "nvim-cmp",
    config = function()
      astronvim.add_user_cmp_source("nvim_lsp_signature_help")
    end,
  },
  ["echasnovski/mini.map"] = {
    config = function()
      require("user.plugins.minimap")
    end,
  },
}
