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
    use 'mileszs/ack.vim'
    use 'github/copilot.vim'
    use 'junegunn/fzf.vim'
    use {
           "folke/trouble.nvim",
           requires = "kyazdani42/nvim-web-devicons",
           config = function() require("trouble").setup {} end
    }
end)
