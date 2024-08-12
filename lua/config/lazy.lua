require('config.options')
require('config.keymaps')
require('config.autocmds')

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system(
        {'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', -- latest stable release
         lazypath})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({{
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
        style = 'storm'
    },
    init = function()
        vim.cmd.colorscheme('tokyonight')
    end
}, {
    'christoomey/vim-tmux-navigator',
    event = 'VimEnter'
}, 'tpope/vim-sleuth', -- Better indentation automatically
{
    'lewis6991/gitsigns.nvim',
    opts = {}
}, { -- Fizzy finder
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
            desc = '[S]earch [K]eymaps'
        })
    end
}, {
    'numToStr/Comment.nvim',
    opts = {}
}, {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
        spec = {{
            '<leader>s',
            group = '[S]earch'
        }, {
            '<leader>q',
            group = '[Q]uit'
        }}
    }
}, {
    'lervag/vimtex',
    ft = 'tex'
}, {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    build = ':Copilot auth',
    opts = {
        suggestion = {
            enabled = false
        },
        panel = {
            enabled = false
        },
        filetypes = {
            markdown = true,
            help = true
        }
    }
}, { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = {'BufReadPost', 'BufNewFile', 'BufWritePre'},
    dependencies = { -- Automatically install LSPs and related tools to stdpath for Neovim
    {
        'williamboman/mason.nvim',
        config = true
    }, 'williamboman/mason-lspconfig.nvim', 'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Lower right hand corner updated from LSP
    {
        'j-hui/fidget.nvim',
        opts = {}
    }, -- LUA LSP with comp, annotations, and signatures for Neovim apis used in config, runtime and plugins
    {
        'folke/neodev.nvim',
        opts = {}
    }},
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('lsp-attach', {
                clear = true
            }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', {
                        clear = false
                    })
                    vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight
                    })

                    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references
                    })

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('lsp-detach', {
                            clear = true
                        }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({
                                group = 'lsp-highlight',
                                buffer = event2.buf
                            })
                        end
                    })
                end
            end
        })
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        local servers = {
            lua_ls = {},
            stylua = {}, -- lua formatting
            tflint = {},
            terraformls = {}
        }

        require('mason').setup()

        local ensure_installed = vim.tbl_keys(servers or {})

        require('mason-tool-installer').setup({
            ensure_installed = ensure_installed
        })

        require('mason-lspconfig').setup({
            handlers = {function(server_name)
                local server = servers[server_name] or {}
                -- Making sure to overriding setting from ensure_installed list
                server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                require('lspconfig')[server_name].setup(server)
            end}
        })
    end
}, { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    opts = {},
    dependencies = {'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path', {
        'zbirenbaum/copilot-cmp',
        dependencies = 'copilot.lua',
        opts = {},
        config = function(_, opts)
            local copilot_cmp = require('copilot_cmp')
            copilot_cmp.setup(opts)
            -- attach cmp source whenever copilot attaches
            -- fixes lazy-loading issues with the copilot cmp source
            -- LazyVim.lsp.on_attach(function(client)
            --     copilot_cmp._on_insert_enter({})
            -- end, "copilot")
        end
    }},
    config = function()
        local cmp = require('cmp')
        cmp.setup({
            completion = {
                completeopt = 'menu,menuone,noinsert'
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-p>'] = cmp.mapping.select_prev_item(),

                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),

                ['<C-y>'] = cmp.mapping.confirm({
                    select = true
                }),
                ['<C-Space>'] = cmp.mapping.complete({})
            }),
            sources = {{
                name = 'copilot',
                group_index = 1,
                priority = 100
            }, {
                name = 'nvim_lsp'
            }, {
                name = 'luasnip'
            }, {
                name = 'path'
            }}
        })
    end
}, {
    'stevearc/conform.nvim',
    opts = {
        notify_on_error = false,
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_fallback = true
        },
        formatters_by_ft = {
            lua = {'stylua'}
        }
    }
}, {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = {'nvim-lua/plenary.nvim', {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        -- TODO: Add keybinding for trouble
        opts = {
            use_diagnostic_signs = true
        }
    }},
    opts = {}
}, { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = {'BufReadPost', 'BufNewFile', 'BufWritePre', 'User'},
    build = ':TSUpdate',
    opts = {
        ensure_installed = {'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc'},
        -- Autoinstall languages that are not installed
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false
        },
        indent = {
            enable = true
        }
    },
    config = function(_, opts)
        require('nvim-treesitter.install').prefer_git = true
        require('nvim-treesitter.configs').setup(opts)
    end
}}, {
    defaults = {
        -- TODO: Be clever enough to set lazy = false. Requires more knowledge on event and when to load
        -- lazy = false,
        version = false
    },
    checker = { -- checks for plugin updates automatically
        enabled = true
    },
    install = {
        colorscheme = {'tokyonight-storm'}
    },
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {"gzip", -- "matchit",
            -- "matchparen",
            -- "netrwPlugin",
            "tarPlugin", "tohtml", "tutor", "zipPlugin"}
        }
    }

})
