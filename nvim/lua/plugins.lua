-- Plugin configuration (plugins installed via home-manager)

-- Trouble (diagnostics list)
require('trouble').setup {}

-- Bufferline (buffer tabs at top)
require('bufferline').setup{
  options = {
    show_buffer_close_icons = false,
    modified_icon = '',
  }
}
