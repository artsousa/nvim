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

vim.keymap.set('n', '*', '*N', { noremap = true, silent = true })

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

vim.opt.clipboard = "unnamedplus"

require("lazy").setup({
    -- File explorer
    { "nvim-tree/nvim-tree.lua" },
    
    -- Git
    { "tpope/vim-fugitive" },

    {
    	"numToStr/Comment.nvim",
	    config = true,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Status line
    { "nvim-lualine/lualine.nvim" },

    -- Visual 
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('github-theme').setup({
		options = {
                    compile_path = vim.fn.stdpath('cache') .. '/github-theme',
                    transparent = true,
                    hide_end_of_buffer = true,
                    hide_nc_statusline = true,
                    styles = { 
                        -- `:help attr-list`
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

            vim.cmd('colorscheme github_dark')
        end,
    },  

    -- codex 
    {
        'kkrampis/codex.nvim',
        lazy = true,
        cmd = { 'Codex', 'CodexToggle' }, -- Optional: Load only on command execution
        keys = {
            {
                '<leader>cg', -- Change this to your preferred keybinding
                function() require('codex').toggle() end,
                desc = 'Toggle Codex popup or side-panel',
                mode = { 'n', 't' }
            },
        },
        opts = {
            keymaps = {
                toggle = nil, -- Keybind to toggle Codex window (Disabled by default, watch out for conflicts)
                quit = '<C-q>', -- Keybind to close the Codex window (default: Ctrl + q)
            },         -- Disable internal default keymap (<leader>cc -> :CodexToggle)
            border      = 'rounded',  -- Options: 'single', 'double', or 'rounded'
            width       = 0.8,        -- Width of the floating window (0.0 to 1.0)
            height      = 0.8,        -- Height of the floating window (0.0 to 1.0)
            model       = nil,        -- Optional: pass a string to use a specific model (e.g., 'o3-mini')
            autoinstall = true,       -- Automatically install the Codex CLI if not found
            panel       = false,      -- Open Codex in a side-panel (vertical split) instead of floating window
            use_buffer  = false,      -- Capture Codex stdout into a normal buffer instead of a terminal buffer
        },
    },
    
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        
        -- Keys block stays outside so Lazy knows when to load the plugin
        keys = {
            {
                '<leader>cc', "<cmd>ClaudeCodeFocus<cr>", desc = 'Toggle claudio popup', mode = { 'n', 'x' }
            },
            quit = '<C-q>',
        },

        -- Use config() instead of opts for complex setups
        config = function()
            -- 1. Extract the options
            local my_snacks_opts = {
                position = "float",
                width = 0.9,
                height = 0.9,
                border = "rounded",
                backdrop = 10,
                keys = {
                    term_normal = false, 
                    claude_hide = {
                        "<leader>cc", function() Snacks.terminal.toggle() end, mode = "t", desc = "Hide",
                    },
                    safe_escape = { "<Esc>", "<c-\\><c-n>", mode = "t", desc = "Enter Normal mode" },
                }
            }

            -- 2. THE FIX: Store the active terminal state OUTSIDE the provider table
            local active_term = nil

            -- 3. Create a pure provider table with ONLY functions, no data state
            local custom_snacks_provider = {}

            custom_snacks_provider.setup = function(config) end

            custom_snacks_provider.open = function(cmd_string, env_table, effective_config, focus)
                local opts = vim.deepcopy(my_snacks_opts)
                opts.env = env_table
                -- Save to our hidden external variable
                active_term = Snacks.terminal(cmd_string, opts)
            end

            custom_snacks_provider.close = function()
                if active_term then 
                    active_term:close() 
                end
            end

            custom_snacks_provider.simple_toggle = function(cmd_string, env_table, effective_config)
                local opts = vim.deepcopy(my_snacks_opts)
                opts.env = env_table
                active_term = Snacks.terminal.toggle(cmd_string, opts)
            end

            custom_snacks_provider.focus_toggle = function(cmd_string, env_table, effective_config)
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
                local ok, _ = pcall(require, "snacks")
                return ok
            end

            -- 4. Call the plugin setup
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

    -- debugger
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

            -- Configuração para Python
            -- O caminho deve apontar para o python onde o debugpy está instalado
            require("dap-python").setup("python3") 

            -- Abrir/Fechar UI automaticamente
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            -- dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            -- dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            -- Atalhos de Teclado
            vim.keymap.set('n', '<F5>', function() dap.continue() end)
            vim.keymap.set('n', '<F6>', function() dap.step_over() end)
            vim.keymap.set('n', '<F7>', function() dap.step_into() end)
            vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
            vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
            
        end
    }, 


    -- nvim-surround 
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event="VeryLazy", 
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    }, 

    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy=true,
        config = function()
            require("nvim-treesitter.configs").setup{
                ensure_installed = { "python" },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true,
                }
            }
        end
    },
    
    -- indentation guide -- 
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {
            indent = {
              char = "·", -- Aqui você define o caractere (pode ser "┆", "│", "·")
            },
            scope = {
              enabled = true, -- Destaca a indentação do bloco onde o cursor está
              show_start = false,
              show_end = false,
            },
        },
    }, 


    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            
            -- 1. Setup Mason to manage external server binaries
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "lua_ls" }
            })

            -- 2. Configure Pyright using the new 0.11+ Core API
            vim.lsp.config('pyright', {
                filetypes = { "python" },
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

            -- 3. Configure Lua LS (since you have it in ensure_installed)
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        diagnostics = { globals = { 'vim' } },
                        workspace = { checkThirdParty = false },
                    },
                },
            })

            -- 4. Global Keybindings (The modern way via Autocmd)
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local bufnr = args.buf
                    local builtin = require('telescope.builtin')
                    local opts = { noremap = true, silent = true, buffer = bufnr }

                    -- Telescope-specific Mappings
                    vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
                    vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
                    vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, opts)
                    vim.keymap.set('n', '<leader>D', builtin.diagnostics, opts)
                    
                    -- Standard LSP Mappings
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                end,
            })
        end,
    },

    {
	    "hrsh7th/nvim-cmp",
	    dependencies = {
		    -- LSP source
		    "hrsh7th/cmp-nvim-lsp",

		    -- Buffer + path
		    "hrsh7th/cmp-buffer",
		    "hrsh7th/cmp-path",

		    -- Snippets (optional but recommended)
		    "L3MON4D3/LuaSnip",
		    "saadparwaiz1/cmp_luasnip",
	    }
    },


    {
	    "mikavilpas/yazi.nvim",
	    dependencies = {
		    "nvim-lua/plenary.nvim",
	    }
    }

})


vim.keymap.set('n', '<leader>dq', function()
    require("dap").terminate()
    require("dapui").close()
    vim.cmd("silent! bd! [dap-repl]") 
end, { desc = "Sair do Debugger e fechar REPL" })

vim.api.nvim_create_user_command('ViewImage', function(opts)
    -- opts.args contém a string que você digitou após o comando
    local result_file = opts.args

    -- Verifica se o arquivo existe antes de tentar chamar o Windows
    if vim.fn.filereadable(result_file) == 1 then
        -- No WSL, o powershell.exe consegue abrir arquivos se o caminho for relativo
        -- ou se usarmos wslpath para converter para o formato C:\...
        vim.fn.jobstart({ "powershell.exe", "-Command", "Start-Process " .. result_file }, { detach = true })
    else
        print("Erro: Arquivo '" .. result_file .. "' não encontrado.")
    end
end, { 
    nargs = 1, -- Obriga a passar exatamente 1 argumento
    complete = "file" -- Ativa o auto-complete de arquivos (TAB) ao digitar o comando
})

-- Apenas fechar/abrir a UI (sem matar o processo)
vim.keymap.set('n', '<leader>du', function() 
    require("dapui").toggle() 
end, { desc = "Alternar Interface DAP" })


vim.cmd('colorscheme github_dark_dimmed')
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = true
	end,
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local function start_lsp(name, config)
    vim.lsp.start(vim.tbl_deep_extend("force", {
        name = name,
        capabilities = capabilities,
    }, config or {}))
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		start_lsp("pyright", vim.lsp.config.pyright or {
			cmd = { "pyright-langserver", "--stdio" },
		})
	end,
})

vim.diagnostic.config({
	virtual_text = false,   -- disable inline text
	signs = false,          -- disable gutter signs
	underline = false,      -- disable underlines
	update_in_insert = false,
	severity_sort = false,
})


local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)


vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function() vim.treesitter.start() end,
})

local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-v>"] = false, -- disable default
				["<C-x>"] = false, -- disable default
		        ["<C-d>"] = actions.delete_buffer + actions.move_to_top, 

				["<C-x>"] = actions.select_vertical,
				["<C-b>"] = actions.select_horizontal,
			},
			n = {
				["<C-v>"] = false, -- disable default
				["<C-x>"] = false, -- disable default
                ["d"] = actions.delete_buffer,

				["<C-x>"] = actions.select_vertical,
				["<C-b>"] = actions.select_horizontal,
			},
		},
	},
})

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
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

require("yazi").setup({
	open_for_directories = true,
	use_ya_for_directories = true,
	close_on_open = true,
    keymaps = {
		--telescope behavior
        open_file_in_vertical_split = "<C-x>",
		open_file_in_horizontal_split = "<C-b>",
	},
    ui = {
		width = 0.85,
		height = 0.85,
		border = "rounded",
	},
})


vim.keymap.set(
	"n",
	"<leader>y",
	"<cmd>Yazi<CR>",
	{ desc = "Open Yazi file manager" }
)

-- terminal exit mode --
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- resize window -- 
vim.keymap.set("n", ">", "<C-w>>")
vim.keymap.set("n", "<", "<C-w><")

-- select and indent mode -- 
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- unselect  
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- window navigation -- 
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-Left>", "<C-w>h")
vim.keymap.set("n", "<C-Down>", "<C-w>j")
vim.keymap.set("n", "<C-Up>", "<C-w>k")
vim.keymap.set("n", "<C-Right>", "<C-w>l")



