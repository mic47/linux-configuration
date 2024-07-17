#!/bin/bash

source ~/.fzf.bash

function preview_bat {
  file="$1"
  c=${2:-100000}
  language=$(echo "$file" | sed -e 's/^.*[.]\([^.]*\)/\1/')
  head -c "$c" "$file" \
  | bat \
    --color always \
    --language "$language"
}

export -f preview_bat


function fcommit {
  git log \
    --oneline \
    --decorate \
    --color=always \
  | fzf \
    --multi \
    --no-sort \
    --nth=2..-1 \
    --ansi \
    --preview-window=left:70%:wrap \
    --preview 'git show {+1} | bat --color always --language diff' \
  | cut -f 1 -d ' '
}

function fpackagejson {
  #| fzf-tmux  -- -d : -n 1 \
  cat package.json  \
    | jq '.scripts | to_entries[] | ("yarn " +  .key + ":" + .value) ' -r \
    | grep -v /// > /tmp/lala ; cat /tmp/lala \
    | tac \
    | fzf \
      --multi \
      -d : \
      --no-sort \
      --nth=1 \
      --with-nth=1 \
      --ansi \
      --preview-window=right:30%:wrap \
      --preview 'echo {2..-1}' \
    | cut -d: -f 2
}
export -f fcommit

function fbranch {
  git branch \
  | sed -e 's/^..//' \
  | fzf \
    --preview-window=left:70%:wrap \
    --preview='git log --decorate --oneline $(git merge-base {} master)..{} --color=always ; git diff --color=always $(git merge-base {} master)..{} '
}

export -f fbranch

__fzf_select_from_tmux_pane ()
{
  builtin typeset READLINE_LINE_NEW="$(
    command tmux capture-pane -Jp -S -100  \
    | grep -v 'Last command took' \
    | grep -v '^Feature:' \
    | grep -v "^$USER@" \
    | command sed 's/\s/\n/g' \
    | grep -v '^\s*$' \
    | grep '^.......' \
    | env fzf -m --tac --height 30%
  )"

  #  | sort \
  #  | uniq \
  if
    [[ -n $READLINE_LINE_NEW ]]
  then
    builtin bind '"\er": redraw-current-line'
    builtin bind '"\e^": magic-space'
    READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${READLINE_LINE_NEW}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
    READLINE_POINT=$(( READLINE_POINT + ${#READLINE_LINE_NEW} ))
  else
    builtin bind '"\er":'
    builtin bind '"\e^":'
  fi
}

export -f __fzf_select_from_tmux_pane

export FZF_CTRL_T_OPTS='--preview="if [ -d {} ] ; then ls -la --color=always {} ; else preview_bat {} 100000 ; fi" --preview-window=right:70%:wrap'

bind -m emacs-standard -x '"\C-y": fcommit'
bind -m vi-command -x '"\C-y": fcommit'
bind -m vi-insert -x '"\C-y": fcommit'
bind -m emacs-standard -x '"\C-b": fbranch'
bind -m vi-command -x '"\C-b": fbranch'
bind -m vi-insert -x '"\C-b": fbranch'
bind -m emacs-standard -x '"\C-f": __fzf_select_from_tmux_pane'
bind -m vi-command -x '"\C-f": __fzf_select_from_tmux_pane'
bind -m vi-insert -x '"\C-f": __fzf_select_from_tmux_pane'
bind -m emacs-standard -x '"\C-g": fpackagejson'
bind -m vi-command -x '"\C-g": fpackagejson'
bind -m vi-insert -x '"\C-g": fpackagejson'

fzgrep() {
  grep --color=always $* \
    | fzf \
      --ansi \
      --preview='bat --color=always $(echo {} | sed -e "s/:.*//" )' \
      --preview-window=bottom
}
export -f fzgrep

select_worktree_fzf() {
  sed -e 's/[ \t][ \6]*/:/g' \
    | cut -d/ -f 4- \
    | fzf \
      -d : \
      --ansi \
      --preview 'cd $HOME/{1}; git log -n 1 --color=always ; echo; git -c color.ui=always status' \
    | cut -d: -f 1
}

export -f select_worktree_fzf

select_worktree() {
  DIRECTORY_RELATIVE_TO_HOME=$(
    for directory in "$@" ; do
      cd "$directory" || exit
      git worktree list
    done | select_worktree_fzf
  )
  if [ -n "$DIRECTORY_RELATIVE_TO_HOME" ] ; then 
    cd "$HOME/$DIRECTORY_RELATIVE_TO_HOME" || exit;
    SESSION_NAME=$(echo "$DIRECTORY_RELATIVE_TO_HOME" | tr '/' '\n' | tac | tr '\n' '/' )
    if [ -z "$TMUX" ] ; then
      echo "NO TMUX"
      tmux new-session -A -t "$SESSION_NAME"
    else 
      echo "YES TMUX"
      tmux has-session -t "$SESSION_NAME" || tmux new -d -t "$SESSION_NAME"
      tmux switch -t "$SESSION_NAME"
    fi
  fi 
}

export -f select_worktree
