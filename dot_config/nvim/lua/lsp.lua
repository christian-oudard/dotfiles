local on_attach = function(client, bufnr)
  -- Complete object members with omnifunc and Ctrl-Space.
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-Space>', '<C-x><C-o>', {noremap = true, silent = true})

  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, bufopts)
end


vim.lsp.config('pyright', {
    on_attach = on_attach,
})
vim.lsp.enable('pyright')

vim.lsp.config('rust_analyzer', {
    on_attach = on_attach,
})
vim.lsp.enable('rust_analyzer')

vim.lsp.config('ruff', {
    on_attach = on_attach,
})
vim.lsp.enable('ruff')

vim.lsp.config('ts_ls', {
    on_attach = on_attach,
})
vim.lsp.enable('ts_ls')

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})
