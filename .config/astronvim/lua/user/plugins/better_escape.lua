return {
  mapping = { "jj", "ww" }, -- a table with mappings to use
  timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
  clear_empty_lines = false, -- clear line after escaping if there is only whitespace
  keys = function()
    -- moves cursor ahead one if not at beginning of line
    return vim.api.nvim_win_get_cursor(0)[2] > 1 and "<esc>l" or "<esc>"
  end,
}
