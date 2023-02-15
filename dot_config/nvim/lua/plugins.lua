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
end)
