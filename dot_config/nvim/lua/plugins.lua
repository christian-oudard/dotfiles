return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'chriskempson/base16-vim'
    use 'tpope/vim-commentary'
    use 'tpope/vim-surround'
    use 'SirVer/ultisnips'
    use 'ap/vim-buftabline'
    use '907th/vim-auto-save'
    use 'neovim/nvim-lspconfig'
end)
