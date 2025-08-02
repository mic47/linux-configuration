
-- Task management
vim.cmd([[
function AddTask()
    let cursor_pos = getpos('.')
    let col = col(".")
    normal! ^mq:2^yw'qf]a tp
    call setpos('.', cursor_pos)
    normal! llllll
endfunction
command! AddTask call AddTask()
function AddSection()
    let cursor_pos = getpos('.')
    let col = col(".")
    normal! ^mq:3^yw'q^k$ea sp
    call setpos('.', cursor_pos)
    normal! llllll
endfunction
command! AddSection call AddSection()
function InitTaskFile()
    let uuid = trim(system("uuidgen"))
    call append(0, ["TASK FILE HEADER BEGIN", "0000", "0000", uuid, "TASK FILE HEADER END"])
endfunction
command! InitTaskFile call InitTaskFile()

function StoreTaskFile()
    execute 'silent !python $HOME/Code/Personal/platypus-tasks/parse.py ' . expand('%')
    redraw!
endfunction
command! StoreTaskFile call StoreTaskFile()
autocmd BufWritePost *.tasks call StoreTaskFile()
autocmd BufEnter *.tasks setl filetype=tasks
autocmd BufEnter *.tasks setl foldmethod=syntax
]])

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.tasks",
  callback = function()
    vim.bo.filetype = "tasks"
    -- Optionally, auto-start your language server for this buffer:
    vim.lsp.start {
      name = "mytasks_lsp",
      cmd = { "python3", os.getenv("HOME") .. "/Code/Personal/platypus-tasks/tasks_lsp.py" },  -- Adjust path as needed
      filetypes = {"tasks"},
      root_dir = vim.fn.getcwd(),
      -- add any other custom config here
    }
  end
})
