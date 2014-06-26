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
# ====== Default program settings =====

export SVN_EDITOR=vim
export EDITOR=vim
export PYTHONSTARTUP=~/.pystartup
export BC_LINE_LENGTH=0

# ====== History settings =====

export HISTCONTROL=ignorespace
shopt -s histappend
export HISTSIZE=-1
export HISTFILESIZE=-1
shopt -s checkwinsize
export HISTTIMEFORMAT='%F %T '

export HISTORY_TOKEN=$(random_string 8)

# set a default (must use -e option to include it)
export hcmntextra='date "+%Y%m%d %R"'      # you must be really careful to get the quoting right

# start using it
export PROMPT_COMMAND='hcmnt -eityl ~/.bash_superhistory $LOGNAME@$HOSTNAME '$HISTORY_TOKEN

# ====== Prompt visual hints ==

declare __timer

function pre_command {
       export __timer=$(date +%s)
}

function post_command {
    local __delta=$(($(date +%s) - $__timer))
    #if [[ $__delta > 10 ]]; then
        #alert
    #fi
    export __timer=$(date +%s)
    echo $__delta
}

trap 'pre_command' DEBUG
function proml {
    PS1="\[\033[1;33m\]Last command was executed \$(post_command) second(s) ago\[\033[1;0m\]\$(parse_git_branch)\n$PS1"
}
proml

# ====== Aliases ==============

# X forwarding by default
alias ssh='ssh -XC $*'
alias ssh="ssh -XC"

alias such='git'
alias very='git'
alias wow='git tree'

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

# Compbio aliases
alias bibus='ssh -XC panda.compbio.fmph.uniba.sk bibus'
alias admingrid='clusterssh `for i in cpu02 cpu03 cpu04 cpu05 cpu06 cpu07 ; do echo bifadm@$i.compbio.fmph.uniba.sk; done`'
alias cpu01='ssh -t cpu01 "cd `pwd` && bash"'
# '"echo \"cd `pwd`\"| /bin/bash"'
alias cpu02='ssh -t cpu02 "cd `pwd` && bash"'
alias cpu03='ssh -t cpu03 "cd `pwd` && bash"'
alias cpu04='ssh -t cpu04 "cd `pwd` && bash"'
alias cpu05='ssh -t cpu05 "cd `pwd` && bash"'
alias cpu06='ssh -t cpu06 "cd `pwd` && bash"'
alias cpu07='ssh -t cpu07 "cd `pwd` && bash"'

alias eqstat="qstat -f -u '*' -F memory,threads"

ulimit -u 1000

if [ "`uname -n`" == "compbio" ]; then
	ulimit -m 2097152
fi

alias logtail="pypy bin/logTailer.py output"
