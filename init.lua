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

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- clear search highlight on <Esc> but does not clear search

-- TODO: Come up with good keymapping for this to be a good idea..
-- The m marks the current position, and the backticks (```) are used to jump back to this mark
-- Keymaps requires low timeoutlen to be useful
-- vim.keymap.set('n', 'oo', 'm`o<Esc>``', { desc = 'Insert line below' })
-- vim.keymap.set('n', 'OO', 'm`O<Esc>``', { desc = 'Insert line above' })

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme('tokyonight-storm')
    end,
  },
  { 'christoomey/vim-tmux-navigator', event = 'VimEnter' },
  'tpope/vim-sleuth', -- Better indentation automatically
  { 'lewis6991/gitsigns.nvim', opts = {} },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()
    end,
  },
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Lower right hand corner updated from LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- LUA LSP with comp, annotations, and signatures for Neovim apis used in config, runtime and plugins
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
              end,
            })
          end
        end,
      })
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = {
        lua_ls = {},
        stylua = {}, --lua formatting
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})

      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- Making sure to overriding setting from ensure_installed list
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    opts = {},
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          ['<C-y>'] = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete({}),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      })
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = {
      notify_on_error = false,
      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        -- TODO: Add keybinding for trouble
        opts = {
          use_diagnostic_signs = true,
        },
      },
    },
    opts = {},
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre', 'User' },
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    },
    config = function(_, opts)
      require('nvim-treesitter.install').prefer_git = true
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}, {
  defaults = {
    -- TODO: Be clever enough to set lazy = false. Requires more knowledge on event and when to load
    lazy = false,
    version = false,
  },
})
