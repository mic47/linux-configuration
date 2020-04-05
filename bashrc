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

declare __timer
declare __timer2

function pre_command {
       export __timer2=$__timer
       export __timer=$(date +%s)
}

function post_command {
    local __wuut=$__timer2
    local __delta=$(($(date +%s) - $__wuut))
    local alert=''
    if [[ $__delta -ge 60 ]]; then
        alert=$'\a';
        $(send_alert)
    fi
    echo $__delta$alert
}

function future_command {
    head -n 1 ~/.future
}

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

__sizeup_build_query () {
  local bool="and"
  local query=""
  for t in $@; do
    query="$query -$bool -iname \"*.$t\""
    bool="or"
  done
  echo -n "$query"
}

__sizeup_humanize () {
  local size=$1
  if [ $size -ge 1073741824 ]; then
    printf '%6.2f%s' $(echo "scale=2;$size/1073741824"| bc) G
  elif [ $size -ge 1048576 ]; then
    printf '%6.2f%s' $(echo "scale=2;$size/1048576"| bc) M
  elif [ $size -ge 1024 ]; then
    printf '%6.2f%s' $(echo "scale=2;$size/1024"| bc) K
  else
    printf '%6.2f%s' ${size} b
  fi
}

sizeup () {
  local helpstring="Show file sizes for all files with totals\n-r\treverse sort\n-[0-3]\tlimit depth (default 4 levels, 0=unlimited)\nAdditional arguments limit by file extension\n\nUsage: sizeup [-r[0123]] ext [,ext]"
  local totalb=0
  local size output reverse OPT
  local depth="-maxdepth 4"
  OPTIND=1
  while getopts "hr0123" opt; do
    case $opt in
      r) reverse="-r " ;;
      0) depth="" ;;
      1) depth="-maxdepth 1" ;;
      2) depth="-maxdepth 2" ;;
      3) depth="-maxdepth 3" ;;
      h) echo -e $helpstring; return;;
      \?) echo "Invalid option: -$OPTARG" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local cmd="find . -type f ${depth}$(__sizeup_build_query $@)"
  local counter=0
  while read -r file; do
    counter=$(( $counter+1 ))
    size=$(stat -f '%z' "$file")
    totalb=$(( $totalb+$size ))
    >&2 echo -ne $'\E[K\e[1;32m'"${counter}:"$'\e[1;31m'" $file "$'\e[0m'"("$'\e[1;31m'$size$'\e[0m'")"$'\r'
    # >&2 echo -n "$(__sizeup_humanize $totalb): $file ($size)"
    # >&2 echo -n $'\r'
    output="${output}${file#*/}*$size*$(__sizeup_humanize $size)\n"
  done < <(eval $cmd)
  >&2 echo -ne $'\r\E[K\e[0m'
  echo -e "$output"| sort -t '*' ${reverse}-nk 2 | cut -d '*' -f 1,3 | column -s '*' -t
  echo $'\e[1;33;40m'"Total: "$'\e[1;32;40m'"$(__sizeup_humanize $totalb)"$'\e[1;33;40m'" in $counter files"$'\e[0m'
}

function next_command {
    eval `future_command`
    cat ~/.future | tac | head -n -1 | tac > /tmp/.future
    cp /tmp/.future ~/.future
}

alias vimall='nvim `hg status --rev .^ -a -m -n`'
alias vimgall='nvim `git diff --relative -r $(git merge-base HEAD master) | grep "+++ b" | sed -e "s/+++ b.//"`'

alias cp='cp --backup=numbered'
alias ln='ln --backup=numbered'
alias mv='mv -f --backup=numbered'
alias turbo_mode="ps -x -o %mem,pid,command=CMD |grep --color=always 'Google Chrome Helper' | sed -e 's/^ *//;s/  */ /g' | sort -n | tail -n 10  | cut -f 2 -d ' ' | xargs -n 1 kill"

function getip {
  getent hosts "$1" | sed -e "s/ .*//" 
}

fn_which_vim() {
  vim $(which $*)
}

fn_which_cat() {
  cat $(which $*)
}

alias which_vim=fn_which_vim
alias which_cat=fn_which_cat

alias go_home_hg_you_are_drunk='hg reset -C && hg revert --all && hg clean --all && hg purge && hg up --clean .'


trap 'pre_command' DEBUG

alias pcat='pandoc -t markdown $1'
alias occurences='sort | uniq -c | sort -n'
alias jq_less='jq . --color-output | less -R'

alias display_internal_lowres_external_highres='xrandr --output eDP-1 --scale 2x2 && xrandr --output HDMI-2 --panning 3840x2160+3840+0'
export PATH=~/.local/bin:$PATH
