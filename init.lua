-- 1. Global System Settings
vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Editor Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4 
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.termguicolors = true
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.clipboard = "unnamedplus"
--
-- Global Clipboard Configuration (OSC 52)
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = function() require('vim.ui.clipboard.osc52').paste('+') end,
    ['*'] = function() require('vim.ui.clipboard.osc52').paste('*') end,
  },
}

-- 2. Plugin Declarations & Configurations via Lazy
require("lazy").setup({
    -- File explorer
    { "nvim-tree/nvim-tree.lua" },
    
    -- Git
    { "tpope/vim-fugitive" },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local actions = require("telescope.actions")
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-d>"] = actions.delete_buffer + actions.move_to_top, 
                            ["<C-x>"] = actions.select_vertical,
                            ["<C-b>"] = actions.select_horizontal,
                        },
                        n = {
                            ["d"] = actions.delete_buffer,
                            ["<C-x>"] = actions.select_vertical,
                            ["<C-b>"] = actions.select_horizontal,
                        },
                    },
                },
            })
        end
    },

    -- Status line
    { "nvim-lualine/lualine.nvim" },

    -- Visual Theme Setup
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        lazy = false,
        priority = 1000,
        config = function()
            require('github-theme').setup({
                options = {
                    compile_path = vim.fn.stdpath('cache') .. '/github-theme',
                    transparent = true,
                    hide_end_of_buffer = true,
                    hide_nc_statusline = true,
                    styles = { 
                        comments = 'NONE',
                        functions = 'NONE',
                        keywords = 'bold',
                        variables = 'NONE',
                        conditionals = 'bold',
                        constants = 'NONE',
                        numbers = 'NONE',
                        operators = 'NONE',
                        strings = 'NONE',
                        types = 'bold',
                    },
                }
            })
            -- Unfied colorscheme call (Only load the exact one you want!)
            vim.cmd('colorscheme github_dark_dimmed')
        end,
    },   

    -- AI Codex 
    {
        'kkrampis/codex.nvim',
        lazy = true,
        cmd = { 'Codex', 'CodexToggle' },
        keys = {
            { '<leader>cg', function() require('codex').toggle() end, desc = 'Toggle Codex popup', mode = { 'n', 't' } },
        },
        opts = {
            keymaps = {
                toggle = nil,
                quit = '<C-q>',
            },
            border      = 'rounded',
            width       = 0.8,
            height      = 0.8,
            model       = nil,
            autoinstall = true,
            panel       = false,
            use_buffer  = false,
        },
    },
    
    -- Claude Code 
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        keys = {
            { '<leader>cc', "<cmd>ClaudeCodeFocus<cr>", desc = 'Toggle claudio popup', mode = { 'n', 'x' } },
        },
        config = function()
            local my_snacks_opts = {
                position = "float",
                width = 0.9,
                height = 0.9,
                border = "rounded",
                backdrop = 10,
                keys = {
                    term_normal = false, 
                    claude_hide = { "<leader>cc", function() Snacks.terminal.toggle() end, mode = "t", desc = "Hide" },
                    safe_escape = { "<Esc>", "<c-\\><c-n>", mode = "t", desc = "Enter Normal mode" },
                }
            }

            local active_term = nil
            local custom_snacks_provider = {}
            custom_snacks_provider.setup = function(config) end
            custom_snacks_provider.open = function(cmd_string, env_table, _, _)
                local opts = vim.deepcopy(my_snacks_opts)
                opts.env = env_table
                active_term = Snacks.terminal(cmd_string, opts)
            end
            custom_snacks_provider.close = function()
                if active_term then active_term:close() end
            end
            custom_snacks_provider.simple_toggle = function(cmd_string, env_table, _)
                local opts = vim.deepcopy(my_snacks_opts)
                opts.env = env_table
                active_term = Snacks.terminal.toggle(cmd_string, opts)
            end
            custom_snacks_provider.focus_toggle = function(cmd_string, env_table, _)
                local opts = vim.deepcopy(my_snacks_opts)
                opts.env = env_table
                active_term = Snacks.terminal.toggle(cmd_string, opts)
            end
            custom_snacks_provider.get_active_bufnr = function()
                if active_term and active_term.buf and vim.api.nvim_buf_is_valid(active_term.buf) then
                    return active_term.buf
                end
                return nil
            end
            custom_snacks_provider.is_available = function()
                return pcall(require, "snacks")
            end

            require("claudecode").setup({
                port_range = { min = 10000, max = 65535 },
                auto_start = false,
                log_level = "info",
                start_insert = false,
                auto_insert = false,
                focus_after_send = false,
                track_selection = true,
                visual_demotion_delay_ms = 50,
                terminal = {
                    provider = custom_snacks_provider, 
                    auto_close = false,
                },
            })
        end, 
    },

    -- Debugger (DAP)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()
            require("dap-python").setup("python3") 

            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end

            -- Debugger Keymaps
            vim.keymap.set('n', '<F5>', function() dap.continue() end)
            vim.keymap.set('n', '<F6>', function() dap.step_over() end)
            vim.keymap.set('n', '<F7>', function() dap.step_into() end)
            vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
            vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
        end
    }, 

    -- Surrounding text manipulations
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy", 
        config = true
    }, 

    -- Syntax Highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- Modern Neovim Treesitter Initialization (v1.0.0+)
            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            
            -- Enable Treesitter highlighting globally for all files
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local bufnr = args.buf
                    -- Add any languages you want to exclude here
                    local ft = vim.bo[bufnr].filetype
                    if ft ~= "tmux" then
                        pcall(vim.treesitter.start, bufnr)
                    end
                end,
            })
        end
    },

    -- Indentation Guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = { char = "·" },
            scope = { enabled = true, show_start = false, show_end = false },
        },
    }, 
    
    -- Core LSP Configuration (Universal 0.11+ Safe Approach)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "lua_ls" }
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Global LSP Keybindings Attach Hook
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local bufnr = args.buf
                    local builtin = require('telescope.builtin')
                    local opts = { noremap = true, silent = true, buffer = bufnr }

                    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
                    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
                    vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, opts)
                    vim.keymap.set('n', '<leader>D', builtin.diagnostics, opts)
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                end,
            })

            -- Filetype Autocommand to start servers directly via core engine
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "python",
                callback = function()
                    vim.lsp.start({
                        name = "pyright",
                        cmd = { "pyright-langserver", "--stdio" },
                        capabilities = capabilities,
                        settings = {
                            python = {
                                analysis = {
                                    autoSearchPaths = true,
                                    useLibraryCodeForTypes = true,
                                    diagnosticMode = "workspace",
                                },
                            },
                        },
                    })
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "lua",
                callback = function()
                    vim.lsp.start({
                        name = "lua_ls",
                        cmd = { "lua-language-server" },
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = { globals = { 'vim' } },
                                workspace = { checkThirdParty = false },
                            },
                        },
                    })
                end,
            })
        end,
    },

    -- Completion Engine (CMP)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                snippet = {
                    expand = function(args) require("luasnip").lsp_expand(args.body) end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end
    },

    -- Yazi File Manager Integration
    {
        "mikavilpas/yazi.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        init = function ()
            vim.g.loaded_netrwPlugin = 1
        end, 
        keys = {
            { "<leader>y", "<cmd>Yazi<CR>", desc = "Open Yazi file manager" }
        },
        opts = {
            open_for_directories = true,
            use_ya_for_directories = true,
            close_on_open = true,
            keymaps = {
                open_file_in_vertical_split = "<C-x>",
                open_file_in_horizontal_split = "<C-b>",
            },
            ui = { width = 0.85, height = 0.85, border = "rounded" },
        }
    }
})

-- 3. Global Diagnostics Options
vim.diagnostic.config({
    virtual_text = false,   -- disable inline text
    signs = false,          -- disable gutter signs
    underline = false,      -- disable underlines
    update_in_insert = false,
    severity_sort = false,
})

-- 4. Standalone Custom Keymaps & Utilities

-- Global Telescope Callers
local ts_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", ts_builtin.find_files)
vim.keymap.set("n", "<leader>fg", ts_builtin.live_grep)
vim.keymap.set("n", "<leader>fb", ts_builtin.buffers)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.bo.commentstring = "# %s"
    end,
})

-- DAP Quick Exit Command
vim.keymap.set('n', '<leader>dq', function()
    require("dap").terminate()
    require("dapui").close()
    vim.cmd("silent! bd! [dap-repl]") 
end, { desc = "Exit Debugger and close REPL" })

-- DAP UI Toggle Mappings
vim.keymap.set('n', '<leader>du', function() require("dapui").toggle() end, { desc = "Toggle DAP UI View" })

-- Terminal, Window resize and selections adjustments
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("n", ">", "<C-w>>")
vim.keymap.set("n", "<", "<C-w><")
vim.keymap.set("n", "+", "<C-w>+")
vim.keymap.set("n", "-", "<C-w>-")

vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window Navigation Core binds
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-Left>", "<C-w>h")
vim.keymap.set("n", "<C-Down>", "<C-w>j")
vim.keymap.set("n", "<C-Up>", "<C-w>k")
vim.keymap.set("n", "<C-Right>", "<C-w>l")

-- WSL/Windows Interoperability Image Utility Command
vim.api.nvim_create_user_command('ViewImage', function(opts)
    local result_file = opts.args
    if vim.fn.filereadable(result_file) == 1 then
        vim.fn.jobstart({ "powershell.exe", "-Command", "Start-Process " .. result_file }, { detach = true })
    else
        print("Error: File '" .. result_file .. "' not found.")
    end
end, { nargs = 1, complete = "file" })
