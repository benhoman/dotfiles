-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

opt.autowrite = false
opt.clipboard = "unnamed"
opt.incsearch = true
opt.scrolloff = 8
opt.colorcolumn = "80,90,100"
opt.ruler = true

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"

vim.g.lazyvim_picker = "fzf" -- or "telescope"
