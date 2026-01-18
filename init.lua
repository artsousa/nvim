vim.g.mapleader = " "

-- Bootstrap lazy.nvim
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
             -- ...
        })

            vim.cmd('colorscheme github_dark')
        end,
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
        end,
    },

    {
	    "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },

        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
              ensure_installed = { "pyright", "lua_ls" } -- Servidores para Python e Lua
            })

            local lspconfig = require("lspconfig")
            -- Configura o Pyright (essencial para seus scripts de ML)
            lspconfig.pyright.setup({})
          end,
        }
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
	    },
    },


    {
	    "mikavilpas/yazi.nvim",
	    dependencies = {
		    "nvim-lua/plenary.nvim",
	    },
    },

})

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
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.lsp.start({
			name = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
			capabilities = capabilities,
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


-- window navigation -- 
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-Left>", "<C-w>h")
vim.keymap.set("n", "<C-Down>", "<C-w>j")
vim.keymap.set("n", "<C-Up>", "<C-w>k")
vim.keymap.set("n", "<C-Right>", "<C-w>l")




