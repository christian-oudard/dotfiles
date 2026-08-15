local on_attach = function(client, bufnr)
  -- Complete object members with omnifunc and Ctrl-Space.
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { buffer = bufnr, silent = true })

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


-- Configure all LSPs, but only enable each once a buffer of its filetype is
-- opened *and* its binary is on PATH. This lets rust-analyzer come from a
-- per-project `nix develop` shell or rustup without erroring elsewhere.
local servers = {
    pyright       = { filetypes = {'python'},     cmd = 'pyright-langserver',
                      config = { on_attach = on_attach } },
    ruff          = { filetypes = {'python'},     cmd = 'ruff',
                      config = { on_attach = on_attach } },
    ts_ls         = { filetypes = {'javascript','javascriptreact','typescript','typescriptreact'},
                      cmd = 'typescript-language-server',
                      config = { on_attach = on_attach } },
    rust_analyzer = { filetypes = {'rust'},       cmd = 'rust-analyzer',
                      config = { on_attach = on_attach } },
    nil_ls        = { filetypes = {'nix'},        cmd = 'nil',
                      config = {
                          on_attach = on_attach,
                          settings = { ['nil'] = { formatting = { command = { 'nixfmt' } } } },
                      } },
}

for name, spec in pairs(servers) do
    vim.lsp.config(name, spec.config)
    vim.api.nvim_create_autocmd('FileType', {
        pattern = spec.filetypes,
        callback = function()
            if vim.fn.executable(spec.cmd) == 1 then
                vim.lsp.enable(name)
            end
        end,
    })
end

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
})

require('lean').setup{}
