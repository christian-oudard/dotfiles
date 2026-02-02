-- Plugin setup
require('lsp')
require('nvim-web-devicons').setup{}
require('trouble').setup{}
require('telescope').setup{}

-- Colorscheme: gruvbox with italics and transparent background
vim.opt.termguicolors = true
require('gruvbox').setup {
  italic = {
    strings = false,
    emphasis = true,
    comments = true,
    operators = false,
  },
  transparent_mode = true,
}
vim.cmd('colorscheme gruvbox')

-- Bufferline
require('bufferline').setup {
  options = {
    show_buffer_close_icons = false,
    modified_icon = '',
  },
}

-- Dim minuet virtual text
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'MinuetVirtualText', { link = 'GruvboxBg3' })
  end,
})

-- Syntax highlighting adjustments
vim.api.nvim_set_hl(0, 'Search', { ctermfg = 18, ctermbg = 17 })
vim.api.nvim_set_hl(0, 'IncSearch', { ctermfg = 18, ctermbg = 16 })
vim.api.nvim_set_hl(0, 'TabLineSel', { ctermfg = 3, ctermbg = 18 })
vim.api.nvim_set_hl(0, 'Error', { underline = true, ctermfg = 1, ctermbg = 18 })

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

-- Behavior
vim.opt.fileformat = 'unix'
vim.opt.fileformats = { 'unix', 'dos' }
vim.opt.scrolloff = 2
vim.opt.backspace = { 'indent', 'eol', 'start' }
vim.opt.backupdir = './.backup,.,/tmp'
vim.opt.signcolumn = 'yes'
vim.opt.mouse = ''
vim.opt.comments = '://,b:#,:%,n:>,fb:-,fb:•'

-- vim-auto-save
vim.g.auto_save = 1

-- File handling
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.autoread = false
vim.opt.autowrite = true
vim.opt.autowriteall = true

-- Persistent undo
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.whichwrap:append('<,>,h,l,[,]')
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = 'screen'

-- Performance
vim.opt.updatetime = 250
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Indentation
vim.opt.tabstop = 8
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.linebreak = true
vim.opt.showbreak = '↪'
vim.opt.listchars = { tab = '→ ', nbsp = '␣', trail = '•', extends = '⟩', precedes = '⟨' }
vim.opt.list = true
vim.opt.wrap = true
vim.opt.textwidth = 120

-- Tab line (bufferline)
vim.opt.showtabline = 2

-- Status line
vim.opt.laststatus = 2
vim.opt.statusline = '%f%h%m%r%=%l/%L'

-- Wildcards
vim.opt.wildignore = {
  '*.o', '*.obj', '*~', '*.pyc',
  '.env', '.env[0-9]+', '.env-pypy',
  '.git', '.gitkeep',
  '.tmp', '.coverage',
  '*DS_Store*', '.sass-cache/',
  '__pycache__/', '.webassets-cache/',
  'vendor/rails/**', 'vendor/cache/**',
  '*.gem', 'log/**', 'tmp/**',
  '.tox/**', '.idea/**', '.vagrant/**', '.coverage/**',
  '*.egg', '*.egg-info',
  '*.png', '*.jpg', '*.gif',
  '*.so', '*.swp', '*.zip', '*/.Trash/**', '*.pdf', '*.dmg', '*/Library/**', '*/.rbenv/**',
  '*/.nx/**', '*.app',
}

--------------------------------------------------------------------------------
-- Autocommands
--------------------------------------------------------------------------------

-- Filetype-specific indentation
local indentation_group = vim.api.nvim_create_augroup('indentation', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = indentation_group,
  pattern = 'python',
  callback = function()
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = indentation_group,
  pattern = { 'lua', 'ruby', 'haskell', 'cabal', 'yaml', 'json', 'html', 'javascript', 'typescript', 'css', 'javascriptreact' },
  callback = function()
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = indentation_group,
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = indentation_group,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.textwidth = 90
    vim.opt_local.formatoptions:remove('t')
  end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  group = indentation_group,
  pattern = '*.ejs',
  callback = function()
    vim.opt_local.filetype = 'html'
  end,
})

-- Netrw dvorak mappings
local function netrw_map()
  local opts = { buffer = true }
  vim.keymap.set('', 'd', 'h', opts)
  vim.keymap.set('', 'D', 'H', opts)
  vim.keymap.set('', 'h', 'j', opts)
  vim.keymap.set('', 'H', 'J', opts)
  vim.keymap.set('', 'gh', 'gj', opts)
  vim.keymap.set('', 't', 'k', opts)
  vim.keymap.set('', 'T', 'K', opts)
  vim.keymap.set('', 'gt', 'gk', opts)
  vim.keymap.set('', 'n', 'l', opts)
  vim.keymap.set('', 'N', 'L', opts)
  vim.keymap.set('', 'k', 'd', opts)
  vim.keymap.set('', 'K', 'D', opts)
  vim.keymap.set('', 'j', 'n', opts)
  vim.keymap.set('', 'J', 'N', opts)
end

vim.api.nvim_create_augroup('netrw_map', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'netrw_map',
  pattern = 'netrw',
  callback = netrw_map,
})

-- Quickfix dvorak mappings
vim.api.nvim_create_augroup('quickfix_map', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'quickfix_map',
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'h', 'j', { buffer = true })
    vim.keymap.set('n', 't', 'k', { buffer = true })
  end,
})

-- vim-css3-syntax
vim.api.nvim_create_augroup('VimCSS3Syntax', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'VimCSS3Syntax',
  pattern = 'css',
  callback = function()
    vim.opt_local.iskeyword:append('-')
  end,
})

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

vim.g.mapleader = ','

-- Unmap unused, frequently accidental, or conflicting commands
vim.keymap.set('n', '<C-z>', '<Nop>')
vim.keymap.set('n', 'Q', '<Nop>')
vim.keymap.set('n', 's', '<Nop>')
vim.keymap.set('n', 'S', '<Nop>')
pcall(vim.keymap.del, 'n', '<Leader>fc')
pcall(vim.keymap.del, 'n', '<Leader>fef')
pcall(vim.keymap.del, 'n', '<C-f>')

-- Easier exit from insert mode
vim.keymap.set('i', 'qj', '<Esc>')
vim.keymap.set('i', 'vw', '<Esc>')
vim.keymap.set('i', '<Del>', '<Esc>')
vim.keymap.set('n', '<Del>', '<Esc>')

-- Dvorak navigation: d, h, t, n for left, down, up, right
vim.keymap.set('', 'd', 'h')
vim.keymap.set('', 'D', 'H')
vim.keymap.set('', 'h', 'j')
vim.keymap.set('', 'H', 'J')
vim.keymap.set('', 'gh', 'gj')
vim.keymap.set('', 't', 'k')
vim.keymap.set('', 'T', 'K')
vim.keymap.set('', 'gt', 'gk')
vim.keymap.set('', 'n', 'l')
vim.keymap.set('', 'N', 'L')

-- Reassign overwritten keys
vim.keymap.set('', 'k', 'd')
vim.keymap.set('', 'K', 'D')
vim.keymap.set('', 'l', 't')
vim.keymap.set('', 'L', 'T')
vim.keymap.set('', 'j', 'n')
vim.keymap.set('', 'J', 'N')

-- Intuitive Y
vim.keymap.set('', 'Y', 'y$')

-- Semicolon for command prompt
vim.keymap.set('n', ';', ':')

-- Copy and paste
vim.keymap.set('v', '<C-X>', '"+x')
vim.keymap.set('v', '<C-C>', '"+y')
vim.keymap.set('', '<C-V>', '"+gP')
vim.keymap.set('c', '<C-V>', '<C-R>+')
vim.keymap.set('', 'gv', '<C-V>')

-- Toggle search highlighting
vim.keymap.set('n', '<Leader>hs', ':set hlsearch!<CR>')

-- vim-surround dvorak mappings
vim.g.surround_no_mappings = 1
vim.keymap.set('n', 'ks', '<Plug>Dsurround')
vim.keymap.set('n', 'cs', '<Plug>Csurround')
vim.keymap.set('n', 's', '<Plug>Ysurround')
vim.keymap.set('n', 'ss', '<Plug>Yssurround')
vim.keymap.set('x', 's', '<Plug>VSurround')
vim.keymap.set('x', 'gs', '<Plug>VgSurround')

-- Buffer switching
vim.keymap.set('', '<Leader>n', ':bnext<CR>')
vim.keymap.set('', '<Leader>p', ':bprevious<CR>')
vim.keymap.set('', '<Leader>d', ':bdelete<CR>')
vim.keymap.set('', '<Leader>,', '<C-^>')

for i = 1, 9 do
  vim.keymap.set('n', '<Leader>' .. i, ':BufferLineGoToBuffer ' .. i .. '<CR>')
end
vim.keymap.set('n', '<Leader>0', ':BufferLineGoToBuffer 10<CR>')

-- trouble.nvim
vim.keymap.set('n', '<Leader>xx', '<cmd>Trouble diagnostics toggle<CR>')
vim.keymap.set('n', '<Leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>')

-- Diagnostic navigation
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Inlay hints toggle (Neovim 0.10+)
vim.keymap.set('n', '<Leader>ih', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

-- Telescope
vim.keymap.set('n', '<Leader>f', function() require('telescope.builtin').live_grep() end, { noremap = true, silent = true })
vim.keymap.set('n', '<C-p>', function() require('telescope.builtin').find_files() end, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>fb', function() require('telescope.builtin').buffers() end, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>fh', function() require('telescope.builtin').help_tags() end, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>fr', function() require('telescope.builtin').oldfiles() end, { noremap = true, silent = true })

--------------------------------------------------------------------------------
-- Plugin variables
--------------------------------------------------------------------------------

-- rust.vim
vim.g.rustfmt_autosave = 0

-- GitHub Copilot
vim.g.copilot_filetypes = {
  ['*'] = false,
  python = true,
  rust = true,
  javascript = true,
  sh = true,
  sql = true,
}
