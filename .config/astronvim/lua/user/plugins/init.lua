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
}
