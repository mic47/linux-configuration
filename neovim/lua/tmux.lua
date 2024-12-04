-- Tmux integration

-- from https://gist.github.com/mrmrs/5995435
vim.cmd([[
if exists('$TMUX')
  function! TmuxOrSplitSwitch(wincmd, tmuxdir)
    let previous_winnr = win_getid()
    execute a:wincmd
    if previous_winnr == win_getid()
      " The sleep and & gives time to get back to vim so tmux's focus tracking
      " can kick in and send us our ^[[O
      execute "silent !sh -c 'sleep 0.01; tmux " . a:tmuxdir . "' &"
      redraw!
    endif
  endfunction
  let previous_title = substitute(system("tmux display-message -p '#{pane_title}'"), '\n', '', '')
  let &t_ti = "\<Esc>]2;vim\<Esc>\\" . &t_ti
  let &t_te = "\<Esc>]2;". previous_title . "\<Esc>\\" . &t_te
  nnoremap <silent> <C-h> :call TmuxOrSplitSwitch('wincmd h', 'select-pane -L')<cr>
  nnoremap <silent> <C-j> :call TmuxOrSplitSwitch('wincmd j', 'select-pane -D')<cr>
  nnoremap <silent> <C-k> :call TmuxOrSplitSwitch('wincmd k', 'select-pane -U')<cr>
  nnoremap <silent> <C-l> :call TmuxOrSplitSwitch('wincmd l', 'select-pane -R')<cr>
  " Due to the long standing design bug in vim, C-i is same thing as Tab, so
  " it is not a good idea to remap it.
  " nnoremap <silent> <C-i> :call TmuxOrSplitSwitch("execute ':tabnext ' . (tabpagenr() +1)", 'select-window -n')<cr>
  nnoremap <silent> <C-u> :call TmuxOrSplitSwitch("execute ':tabnext ' . (tabpagenr() -1)", 'select-window -p')<cr>
else
  map <C-h> <C-w>h
  map <C-j> <C-w>j
  map <C-k> <C-w>k
  map <C-l> <C-w>l
  "map <C-i> :tabnext<cr>
  map <C-u> :tabprev<cr>
endif 
]])

