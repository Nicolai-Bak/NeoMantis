vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = 'a' -- enabled for all modes

vim.opt.clipboard = 'unnamedplus' -- syncs clipboard inside neovim with clipboard of OS

vim.opt.breakindent = true -- keeps indentation of broken lines

vim.opt.ignorecase = true -- default not casesensitive
vim.opt.smartcase = true -- but become when capital letters is used

-- FIX: find out if either updatetime or timeoutlen is making todo-comment text really slow to render
vim.opt.updatetime = 250 -- e.g. time for visual changes from lsp

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

vim.opt.signcolumn = 'yes' -- always make room in left margin for signs

vim.opt.splitright = true -- open vsplit to the right
vim.opt.splitbelow = true -- open split below

-- TODO: consider if list and listchars is wanted
-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.inccommand = 'split' -- preview during substitution

vim.opt.cursorline = true -- highlight active cursor line

vim.opt.scrolloff = 5 -- keep this number of lines above or below curser when scrolling

