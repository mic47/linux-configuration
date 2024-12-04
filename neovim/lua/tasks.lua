
-- Task management
vim.cmd([[
function AddTask()
    let cursor_pos = getpos('.')
    let col = col(".")
    normal! ^mq:2
    call setpos('.', cursor_pos)
    normal! llllll
endfunction
command! AddTask call AddTask()
function AddSection()
    let cursor_pos = getpos('.')
    let col = col(".")
    normal! ^mq:3
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