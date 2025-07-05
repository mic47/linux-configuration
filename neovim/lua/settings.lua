vim.cmd('set grepprg=crep')
vim.cmd('set grepformat=%f:%l:%m')
--
-- General settings
vim.g.t_co = 256
vim.g.background = "dark"
vim.cmd('highlight TypeHint ctermfg=darkgray')
vim.cmd('highlight NormalFloat ctermbg=black ')
vim.cmd('highlight PMenu ctermfg=white ctermbg=black guibg=black')

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.expandtab = true
vim.g.shiftwidth = 2
vim.g.softtabstop = 2
vim.g.tabstop = 2
vim.g.smarttab = true
vim.g.autoindent = true
vim.g.cindent = true
vim.g.cursorline = true
vim.g.incsearch = true
vim.g.ignoresearch = true
vim.g.smartcase = true
vim.g.hlsearch = true

vim.g.grep = "crep"

vim.cmd("set backupcopy=yes")
