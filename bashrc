#!/bin/bash

# Found in http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SOURCE_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"


source $SOURCE_DIR/bash/utils.sh
source $SOURCE_DIR/bash/history.sh
source $SOURCE_DIR/bash/prompt.sh
source $SOURCE_DIR/bash/fzf.sh
# ====== Default program settings =====

export SVN_EDITOR=vim
export EDITOR=vim
export PYTHONSTARTUP=~/.pystartup
export BC_LINE_LENGTH=0

# ====== History settings =====

export HISTCONTROL=ignorespace
shopt -s histappend
export HISTSIZE=99999999
export HISTFILESIZE=99999999
shopt -s checkwinsize
export HISTTIMEFORMAT='%F %T '

export HISTORY_TOKEN=$(random_string 8)

# set a default (must use -e option to include it)
export hcmntextra='date "+%Y-%m-%d %R"'      # you must be really careful to get the quoting right

# start using it
export PROMPT_COMMAND='hcmnt -eityl ~/.bash_superhistory $LOGNAME@$HOSTNAME '$HISTORY_TOKEN

# Make FZF to use new history
export FZF_CTRL_R_OPTS='--tac'
export FZF_CTRL_R_COMMAND='__superhistory_for_fzf__'

# ====== Prompt visual hints ==

function proml {
  PS1="\[\033[1;33m\][\$(date)] Last command took \$(post_command) second(s)\[\033[1;0m\]\$(parse_git_branch)\n\$(future_command)\n$PS1"
}
proml

# ====== Aliases ==============

# X forwarding by default
alias ssh='ssh -XC $*'
alias ssh="ssh -XC"

alias astyle='astyle -t --indent-classes --pad-oper --pad-paren-out'
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias vless='vim -u /usr/share/vim/vim72/macros/less.vim'

alias kill_zombies='sudo kill -HUP $(ps -A -ostat,ppid | grep -e "[zZ]"| awk "{ print \$2 }")'
set -o vi

alias tsh="python $SOURCE_DIR/bin/tsh.py"

alias vimall='nvim `hg status --rev .^ -a -m -n`'
alias vimgall='nvim `git diff --relative -r $(git merge-base HEAD master) | grep "+++ b" | sed -e "s/+++ b.//"`'

alias cp='cp --backup=numbered'
alias ln='ln --backup=numbered'
alias mv='mv -f --backup=numbered'
alias turbo_mode="ps -x -o %mem,pid,command=CMD |grep --color=always 'Google Chrome Helper' | sed -e 's/^ *//;s/  */ /g' | sort -n | tail -n 10  | cut -f 2 -d ' ' | xargs -n 1 kill"

function getip {
  getent hosts "$1" | sed -e "s/ .*//" 
}

which_vim() {
  vim $(which $*)
}

which_cat() {
  cat $(which $*)
}

alias go_home_hg_you_are_drunk='hg reset -C && hg revert --all && hg clean --all && hg purge && hg up --clean .'


trap 'pre_command' DEBUG

alias pcat='pandoc -t markdown $1'
alias occurences='sort | uniq -c | sort -n'
alias jq_less='jq . --color-output | less -R'

alias display_internal_lowres_external_highres='xrandr --output eDP-1 --scale 2x2 && xrandr --output HDMI-2 --panning 3840x2160+3840+0'
export PATH=~/.local/bin:$PATH
