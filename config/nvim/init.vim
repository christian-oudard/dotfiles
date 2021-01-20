if has('nvim')
    let s:editor_root=expand("~/.config/nvim")
else
    let s:editor_root=expand("~/.vim")
endif

" Point to Python interpreter. This only works if the system has the
" python package "neovim" installed.
let g:python_host_prog='/usr/local/bin/python'

" vim-plug
call plug#begin(s:editor_root . '/plugged')
Plug 'hynek/vim-python-pep8-indent'
Plug 'derekwyatt/vim-scala'
Plug 'saltstack/salt-vim'
Plug 'chriskempson/base16-vim'  " color scheme
Plug 'tpope/vim-fugitive'  " git
Plug 'tpope/vim-commentary'  " commenting and uncommenting
Plug 'tpope/vim-surround'
Plug 'SirVer/ultisnips'  " snippets
Plug 'w0rp/ale'  " syntax checker
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'mileszs/ack.vim'  " ag searching
Plug 'bronson/vim-trailing-whitespace'  " delete trailing whitespace
Plug 'ap/vim-buftabline'  " tabs for each buffer
Plug '907th/vim-auto-save'
Plug 'hail2u/vim-css3-syntax'
Plug 'leafgarland/typescript-vim'
Plug 'nikvdp/ejs-syntax'
Plug 'cespare/vim-toml'
Plug 'tomlion/vim-solidity'
Plug 'udalov/kotlin-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

" Visual settings

set lazyredraw
set termguicolors
let base16colorspace=256
syntax on
filetype plugin indent on

" Colors

set background=dark
colorscheme base16-woodland
" set background=light
" colorscheme base16-solarized-light

" Set background to none so transparent terminal works.
" call g:Base16hi("Normal", "", "none", "", "")
" Search terms.
call g:Base16hi("Search", "none", g:base16_gui01, "", "")
call g:Base16hi("IncSearch", "none", g:base16_gui01, "", "")
" Special whitespace characters.
call g:Base16hi("NonText", g:base16_gui01, "none", "", "", "bold")
call g:Base16hi("SpecialKey", g:base16_gui01, "none", "", "", "bold")
call g:Base16hi("ExtraWhitespace", g:base16_gui01, "none", "", "", "bold")
" Don't bold statements.
call g:Base16hi("Statement", "", "none", "", "", "none")

" Behavior settings
set fileformat=unix
set fileformats=unix,dos
set scrolloff=2 " Set a margin of lines when scrolling.
set backspace=indent,eol,start
set backupdir=./.backup,.,/tmp

" Always-on sign column for error indicators
augroup error_column
    autocmd!
    autocmd BufWinEnter * sign define fakesign
    autocmd BufWinEnter * exe "sign place 1337 line=1 name=fakesign buffer=" . bufnr('%')
augroup END

" vim-auto-save
let g:auto_save = 1

set nohidden
set nobackup
set noswapfile
set nowritebackup
set noautoread
set autowrite
set autowriteall

" persistent undo
set undofile
set undodir=~/.vim/undo

" search
set ignorecase
set smartcase
set whichwrap+=<,>,h,l,[,]
set hidden
set hlsearch
" indentation
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab
set list
set linebreak
set showbreak=↪
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set wrap
set textwidth=110


augroup indentation
    autocmd!
    autocmd FileType python setlocal softtabstop=4 shiftwidth=4
    autocmd FileType ruby setlocal softtabstop=2 shiftwidth=2
    autocmd FileType haskell setlocal softtabstop=2 shiftwidth=2
    autocmd FileType cabal setlocal softtabstop=2 shiftwidth=2
    autocmd FileType go setlocal noexpandtab tabstop=2 softtabstop=2 shiftwidth=2
    autocmd FileType yaml setlocal softtabstop=2 shiftwidth=2
    autocmd FileType html setlocal softtabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.ejs set filetype=html
    autocmd FileType javascript setlocal softtabstop=2 shiftwidth=2
    autocmd FileType typescript setlocal softtabstop=2 shiftwidth=2
    autocmd FileType css setlocal softtabstop=2 shiftwidth=2
    autocmd FileType markdown setlocal softtabstop=4 shiftwidth=4 textwidth=90 formatoptions-=t
augroup END


" Status line
set laststatus=2
set statusline=%f       "relative filename
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%=      "left/right separator
set statusline+=%l/%L   "cursor line/total lines

" Wildcards
set wildignore=*.o,*.obj,*~,*.pyc
set wildignore+=.env
set wildignore+=.env[0-9]+
set wildignore+=.env-pypy
set wildignore+=.git,.gitkeep
set wildignore+=.tmp
set wildignore+=.coverage
set wildignore+=*DS_Store*
set wildignore+=.sass-cache/
set wildignore+=__pycache__/
set wildignore+=.webassets-cache/
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=.tox/**
set wildignore+=.idea/**
set wildignore+=.vagrant/**
set wildignore+=.coverage/**
set wildignore+=*.egg,*.egg-info
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/Library/**,*/.rbenv/**
set wildignore+=*/.nx/**,*.app

" Keyboard
let mapleader = ","

" Unmap unused, frequently accidental, or conflicting commands.
nnoremap <C-z> <Nop>
nnoremap Q <Nop>
nnoremap s <Nop>
nnoremap S <Nop>
try
    unmap <Leader>fc
    unmap <Leader>fef
    unmap <C-f>
catch
endtry
" Use easier key combinations to exit insert mode.
inoremap qj <esc>
inoremap vw <esc>
inoremap <del> <esc>
nnoremap <del> <esc>
" use d, h, t, n to move left, up, down, and right
noremap d h
noremap D H
noremap h j
noremap H J
noremap gh gj
noremap t k
noremap T K
noremap gt gk
noremap n l
noremap N L
" Reassign the keys we overwrote.
noremap k d
noremap K D
noremap l t
noremap L T
noremap j n
noremap J N
" Use dvorak directions for Netrw (:Explore) buffers too.
augroup netrw_map
    autocmd!
    autocmd filetype netrw call NetrwMap()
augroup END
function! NetrwMap()
    noremap <buffer> d h
    noremap <buffer> D H
    noremap <buffer> h j
    noremap <buffer> H J
    noremap <buffer> gh gj
    noremap <buffer> t k
    noremap <buffer> T K
    noremap <buffer> gt gk
    noremap <buffer> n l
    noremap <buffer> N L
    noremap <buffer> k d
    noremap <buffer> K D
    noremap <buffer> j n
    noremap <buffer> J N
endfunction
" intuitive Y
noremap Y y$
" Press semicolon for command prompt.
nnoremap ; :
" Redo copy and paste mappings.
vnoremap <C-X> "+x
vnoremap <C-C> "+y
map <C-V> "+gP
cmap <C-V> <C-R>+
" Use CTRL-Q to do what CTRL-V used to do
noremap <C-Q> <C-V>

" Toggle search highlighting.
nnoremap <Leader>hs :set hlsearch!<CR>

" Change surround mappings for dvorak.
let g:surround_no_mappings = 1
nmap ks <Plug>Dsurround
nmap cs <Plug>Csurround
nmap s <Plug>Ysurround
nmap ss <Plug>Yssurround
xmap s  <Plug>VSurround
xmap gs <Plug>VgSurround

" Full text search with ack.vim.
noremap <Leader>f :Ack ''<Left>
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Quick buffer switching with buftabline.
noremap <Leader>n :bnext<CR>
noremap <Leader>p :bprevious<CR>
noremap <Leader>d :bdelete<CR>
noremap <Leader>, <C-^>
nmap <Leader>1 <Plug>BufTabLine.Go(1)
nmap <Leader>2 <Plug>BufTabLine.Go(2)
nmap <Leader>3 <Plug>BufTabLine.Go(3)
nmap <Leader>4 <Plug>BufTabLine.Go(4)
nmap <Leader>5 <Plug>BufTabLine.Go(5)
nmap <Leader>6 <Plug>BufTabLine.Go(6)
nmap <Leader>7 <Plug>BufTabLine.Go(7)
nmap <Leader>8 <Plug>BufTabLine.Go(8)
nmap <Leader>9 <Plug>BufTabLine.Go(9)
nmap <Leader>0 <Plug>BufTabLine.Go(10)

noremap <Leader>r :source ~/.config/nvim/init.vim<CR>

" File finding with fzf.
nmap <C-P> :FZF<CR>
set rtp+=~/.fzf

" ALE Asynchronous Lint Engine
let g:ale_linters = {
\   'python': ['flake8'],
\   'haskell': ['hdevtools', 'hlint'],
\   'javascript': ['eslint'],
\}

" YouCompleteMe
let g:ycm_key_list_select_completion = ['<Down>']
let g:ycm_key_list_previous_completion = ['<Up>']

" vim-hdevtools
let g:hdevtools_stack = 1
let g:hdevtools_options = '-g-fdefer-type-errors'
augroup hdevtools
    autocmd!
    autocmd FileType haskell nnoremap <buffer> <Leader>t :HdevtoolsType<CR>
    autocmd FileType haskell nnoremap <buffer> <silent> <Leader>i :HdevtoolsInfo<CR>
    autocmd FileType haskell nnoremap <buffer> <silent> <Leader>c :HdevtoolsClear<CR>
augroup END

" haskell-vim
let g:haskell_indent_disable = 1

" vim-css3-syntax
augroup VimCSS3Syntax
  autocmd!
  autocmd FileType css setlocal iskeyword+=-
augroup END

" CoC
let b:coc_suggest_disable = 1
