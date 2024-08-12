-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight on yank',
    group = vim.api.nvim_create_augroup('highlight-yank', {
        clear = true
    }),
    callback = function()
        vim.highlight.on_yank()
    end
})

-- numbertoggle
vim.api.nvim_create_augroup('numbertoggle', {
    clear = true
})

vim.api.nvim_create_autocmd({'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter'}, {
    group = 'numbertoggle',
    callback = function()
        if vim.o.nu and vim.fn.mode() ~= 'i' then
            vim.o.rnu = true
        end
    end
})

vim.api.nvim_create_autocmd({'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave'}, {
    group = 'numbertoggle',
    callback = function()
        if vim.o.nu then
            vim.o.rnu = false
        end
    end
})
-- end numbertoggle
