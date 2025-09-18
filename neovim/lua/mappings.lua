
-- custom settings
vim.cmd('map <silent> <C-G> <Plug>(code_browse_browser)')
vim.cmd('map <silent> <Leader>g <Plug>(code_browse_browser)')
vim.cmd('map <silent> <C-F> <Plug>(code_browse_grep)')

vim.cmd('map <silent> <C-P> :call fzf#vim#gitfiles(\'.\')<CR>')

vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gg', vim.diagnostic.open_float, nil, { focusable = false })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', 'gx', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'gy', vim.lsp.buf.format, opts)
vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', 'ge', vim.lsp.buf.rename, opts)
vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'go', vim.lsp.buf.document_symbol, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', 'gu', vim.diagnostic.setqflist, opts)
vim.keymap.set('n', 'gc', vim.lsp.buf.incoming_calls, opts)
vim.keymap.set('n', 'gp', vim.lsp.buf.typehierarchy, opts)

vim.keymap.set("n", "<C-e>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
