lua require('plugins')
lua require('lsp')

" Color scheme, gruvbox with italics and transparent background.
set termguicolors
let g:gruvbox_italic = 1
autocmd VimEnter * ++nested colorscheme gruvbox
autocmd VimEnter * highlight Normal ctermbg=none guibg=none

" Dim minuet virtual text
autocmd ColorScheme * highlight! link MinuetVirtualText GruvboxBg3

" Syntax highlighting adjustments
highlight Search ctermfg=18 ctermbg=17
highlight IncSearch ctermfg=18 ctermbg=16
highlight TabLineSel ctermfg=3 ctermbg=18
highlight clear Error
highlight Error cterm=underline ctermfg=01 ctermbg=18


" Enable Italics
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

" Behavior settings
set fileformat=unix
set fileformats=unix,dos
set scrolloff=2 " Set a margin of lines when scrolling.
set backspace=indent,eol,start
set backupdir=./.backup,.,/tmp
set signcolumn=yes " Always-on sign column for error indicators
set mouse= " Disable mouse
set comments=://,b:#,:%,n:>,fb:-,fb:•

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
set undodir=~/.config/nvim/undo

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
set linebreak
set showbreak=↪
set listchars=tab:→\ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨
set list
set wrap
set textwidth=120

augroup indentation
    autocmd!
    autocmd FileType python setlocal softtabstop=4 shiftwidth=4
    autocmd FileType lua setlocal softtabstop=2 shiftwidth=2
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
    autocmd FileType javascriptreact setlocal softtabstop=2 shiftwidth=2
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

" Use dvorak directions for Netrw (:Explore) and Quickfix buffers too.
augroup netrw_map
    autocmd!
    autocmd FileType netrw call NetrwMap()
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

augroup quickfix_map
  autocmd!
  " autocmd FileType qf nunmap <buffer> h
  autocmd FileType qf nnoremap <buffer> h j
  " autocmd FileType qf nunmap <buffer> t
  autocmd FileType qf nnoremap <buffer> t k
augroup END


" intuitive Y
noremap Y y$
" Press semicolon for command prompt.
nnoremap ; :
" Redo copy and paste mappings.
vnoremap <C-X> "+x
vnoremap <C-C> "+y
map <C-V> "+gP
cmap <C-V> <C-R>+
" Use gv to do what CTRL-V used to do (blockwise-visual)
noremap gv <C-V>

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

" Toggle paste mode
function! TogglePaste()
    if(&paste == 0)
        set paste
        echo "Paste Mode Enabled"
    else
        set nopaste
        echo "Paste Mode Disabled"
    endif
endfunction
map <leader>v :call TogglePaste()<cr>

" Quick buffer switching.
noremap <Leader>n :bnext<CR>
noremap <Leader>p :bprevious<CR>
noremap <Leader>d :bdelete<CR>
noremap <Leader>, <C-^>
nnoremap <Leader>1 :BufferLineGoToBuffer 1<CR>
nnoremap <Leader>2 :BufferLineGoToBuffer 2<CR>
nnoremap <Leader>3 :BufferLineGoToBuffer 3<CR>
nnoremap <Leader>4 :BufferLineGoToBuffer 4<CR>
nnoremap <Leader>5 :BufferLineGoToBuffer 5<CR>
nnoremap <Leader>6 :BufferLineGoToBuffer 6<CR>
nnoremap <Leader>7 :BufferLineGoToBuffer 7<CR>
nnoremap <Leader>8 :BufferLineGoToBuffer 8<CR>
nnoremap <Leader>9 :BufferLineGoToBuffer 9<CR>
nnoremap <Leader>0 :BufferLineGoToBuffer 10<CR>

" vim-css3-syntax
augroup VimCSS3Syntax
  autocmd!
  autocmd FileType css setlocal iskeyword+=-
augroup END

" rust.vim
let g:rustfmt_autosave = 0

" GitHub Copilot. Require manual :Copilot enable
" autocmd VimEnter * Copilot disable
let g:copilot_filetypes = {
    \ '*': v:false,
    \ 'python': v:true,
    \ 'rust': v:true,
    \ 'javascript': v:true,
    \ 'sh': v:true,
    \ 'sql': v:true,
    \ }

" trouble.nvim
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>

" Telescope
lua vim.api.nvim_set_keymap('n', '<leader>f', "<cmd>lua require('telescope.builtin').live_grep()<CR>", { noremap = true, silent = true })
lua vim.api.nvim_set_keymap('n', '<C-p>',    "<cmd>lua require('telescope.builtin').find_files()<CR>", { noremap = true, silent = true })
