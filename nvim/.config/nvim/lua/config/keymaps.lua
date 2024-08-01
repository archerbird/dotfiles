-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap
map("n", "S-j", "ddkP==", opts) -- move line up
map("n", "S-k", "ddp==", opts) -- move line down
map("v", "S-j", ":m >+2<CR>gv", opts) -- move selection up
map("v", "S-k", ":m <-2<CR>gv", opts) -- move selection down
