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
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4 
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

require("lazy").setup({

  -- File explorer
    { "nvim-tree/nvim-tree.lua" },

  -- Git
    { "tpope/vim-fugitive" },

  -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Status line
    { "nvim-lualine/lualine.nvim" },

    -- Syntax highlighting
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    {
	    "mikavilpas/yazi.nvim",
	    dependencies = {
		    "nvim-lua/plenary.nvim",
	    },
    }

})



local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)


local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<C-v>"] = false, -- disable default
				["<C-x>"] = false, -- disable default
				
				["<C-x>"] = actions.select_vertical,
				["<C-b>"] = actions.select_horizontal,
			},
			n = {
				["<C-v>"] = false, -- disable default
				["<C-x>"] = false, -- disable default

				["<C-x>"] = actions.select_vertical,
				["<C-b>"] = actions.select_horizontal,
			},
		},
	},
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

vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

vim.keymap.set("n", "<C-Left>", "<C-w>h")
vim.keymap.set("n", "<C-Down>", "<C-w>j")
vim.keymap.set("n", "<C-Up>", "<C-w>k")
vim.keymap.set("n", "<C-Right>", "<C-w>l")





