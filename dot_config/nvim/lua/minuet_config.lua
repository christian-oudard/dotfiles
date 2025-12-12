-- ~/.config/nvim/lua/minuet_config.lua (or similar path in your nvim config)

require('minuet').setup {
    virtualtext = {
        auto_trigger_ft = {},
        keymap = {
            accept = '<A-A>',
            accept_line = '<A-a>',
            prev = '<A-[>',
            next = '<A-]>',
            dismiss = '<A-e>',
        },
    },
    provider = 'claude',
    n_completions = 1,
    context_window = 8192,
    provider_options = {
        claude = {
            model = 'claude-sonnet-4-20250514',
            max_tokens = 512,
            stream = true,
        },
    },
}

-- Keymap to toggle Minuet auto-trigger
vim.keymap.set('n', '<leader>tm', function()
    require('minuet.virtualtext').action.toggle_auto_trigger()
end, { desc = 'Toggle Minuet Auto-Trigger' })
