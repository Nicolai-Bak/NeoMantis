-- TODO: Get inspiration from: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
vim.keymap.set('n', '<leader>sw', '<cmd>WhichKey<CR>', {
    desc = '[S]earch [W]hich Key'
})

vim.keymap.set('n', '<leader>L', '<cmd>Lazy<CR>', {
    desc = '[L]azy'
})

vim.keymap.set('n', '<leader>qq', '<cmd>quitall<CR>', {
    desc = 'Quit all'
})

vim.keymap.set('n', '<leader>-', '<cmd>split<CR>', {
    desc = 'Split'
})
vim.keymap.set('n', '<leader>|', '<cmd>vsplit<CR>', {
    desc = 'Vsplit'
})

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- clear search highlight on <Esc> but does not clear search

-- TODO: Come up with good keymapping for this to be a good idea..
-- The m marks the current position, and the backticks (```) are used to jump back to this mark
-- Keymaps requires low timeoutlen to be useful
-- vim.keymap.set('n', 'oo', 'm`o<Esc>``', { desc = 'Insert line below' })
-- vim.keymap.set('n', 'OO', 'm`O<Esc>``', { desc = 'Insert line above' })

-- TODO Make sure comment is correct
-- Ensures that x will not override clipboard
vim.keymap.set('n', 'x', '"_x')

-- Adjust split sizes using alt + hjkl
-- TODO: look at https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
vim.keymap.set('n', '<M-h>', '<c-w>5<', {
    desc = 'Resize'
})
vim.keymap.set('n', '<M-l>', '<c-w>5>', {
    desc = 'Resize'
})
vim.keymap.set('n', '<M-k>', '<C-W>+', {
    desc = 'Resize'
})
vim.keymap.set('n', '<M-j>', '<C-W>-', {
    desc = 'Resize'
})

vim.keymap.set({'i', 'x', 'n', 's'}, '<C-s>', '<cmd>w<cr><esc>', {
    desc = 'Save File'
})
