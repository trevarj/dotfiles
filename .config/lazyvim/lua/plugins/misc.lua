return {
  {
    "gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
        virt_text_priority = 100,
        delay = 1000,
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    keys = {
      -- Move to tmux window using the <ctrl> hjkl keys
      { "<C-h>", "<cmd>SmartCursorMoveLeft<cr>", { desc = "Go to left window" } },
      { "<C-j>", "<cmd>SmartCursorMoveDown<cr>", { desc = "Go to lower window" } },
      { "<C-k>", "<cmd>SmartCursorMoveUp<cr>", { desc = "Go to upper window" } },
      { "<C-l>", "<cmd>SmartCursorMoveRight<cr>", { desc = "Go to right window" } },
    },
  },
  {
    "max397574/better-escape.nvim",
    lazy = false,
    opts = {
      mapping = { "ww" },
      timeout = vim.o.timeoutlen,
      keys = function()
        return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
      end,
    },
  },
}
