-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })

vim.keymap.set("n", "<leader>bc", "<cmd>%bd|e#|bd#<cr><cr>", { desc = "Close all buffers except current" })

-- Move to tmux window using the <ctrl> hjkl keys
local ss = require("smart-splits")
vim.keymap.set("n", "<C-h>", ss.move_cursor_left, { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", ss.move_cursor_down, { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", ss.move_cursor_up, { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", ss.move_cursor_right, { desc = "Go to right window" })
