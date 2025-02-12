return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'morhetz/gruvbox'
    use 'tpope/vim-commentary'
    use 'tpope/vim-surround'
    use 'tpope/vim-fugitive'
    use 'SirVer/ultisnips'
    use 'ap/vim-buftabline'
    use '907th/vim-auto-save'
    use 'neovim/nvim-lspconfig'
    use 'Vimjas/vim-python-pep8-indent'
    use 'github/copilot.vim'
    use {
           "folke/trouble.nvim",
           requires = "kyazdani42/nvim-web-devicons",
           config = function() require("trouble").setup {} end
    }
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
end)
