-- ~/.config/nvim/lua/minuet_config.lua (or similar path in your nvim config)

require('minuet').setup {
    virtualtext = {
        auto_trigger_ft = { 'python', 'lua', 'rust', 'javascript', 'typescript', 'sh', 'go', 'c', 'cpp' },
        keymap = {
            accept = '<A-A>',
            accept_line = '<A-a>',
            prev = '<A-[>',
            next = '<A-]>',
            dismiss = '<A-e>',
        },
    },
    provider = 'openai_fim_compatible',
    -- Number of completions to request. For local models, 1 is often sufficient
    -- to save resources and provide quick responses.
    n_completions = 1,
    -- Context window size. Adjust this based on your GPU VRAM and model capabilities.
    -- Larger values allow the model to see more of your code.
    context_window = 4096,
    provider_options = {
        openai_fim_compatible = {
            -- The endpoint for your vLLM server.
            -- Ensure this matches the port your vLLM instance is running on.
            end_point = 'http://localhost:11434/v1/completions',
            -- vLLM does not typically require an API key; 'TERM' is a common placeholder.
            api_key = 'TERM',
            -- A descriptive name for this provider.
            name = 'VLLM',
            -- The exact model name as specified when starting your vLLM server.
            model = 'Qwen/Qwen2.5-Coder-3B-Instruct-AWQ',
            -- Enable streaming for real-time completion display.
            stream = true,
            -- Optional parameters to fine-tune model behavior.
            optional = {
                -- Stop sequences for the model. These tokens will stop the completion.
                -- '<|endoftext|>' is common for many code models.
                stop = { '<|endoftext|>' },
                -- Maximum number of new tokens to generate. Adjust as needed for
                -- desired completion length.
                max_tokens = 64,
            },
            -- Custom template for Fill-In-the-Middle (FIM) prompting.
            -- This ensures the model receives the context in the correct format
            -- using Qwen's specific FIM tokens.
            template = {
                prompt = function(context_before_cursor, context_after_cursor)
                    return '<|fim_prefix|>'
                        .. context_before_cursor
                        .. '<|fim_suffix|>'
                        .. context_after_cursor
                        .. '<|fim_middle|>'
                end,
                -- Set to false to disable Minuet's default suffix handling,
                -- as we are manually constructing the entire FIM prompt.
                suffix = false,
            },
        },
    },
}
