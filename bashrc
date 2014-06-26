# ====== Utility functions

function git_diff() {
  git diff --no-ext-diff -w "$@" | vim -R -
}

colors() {
    local fgc bgc vals seq0

    printf "Color escapes are %s\n" '\e[${value};...;${value}m'
    printf "Values 30..37 are \e[33mforeground colors\e[m\n"
    printf "Values 40..47 are \e[43mbackground colors\e[m\n"
    printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

    # foreground colors
    for fgc in {30..37}; do
        # background colors
        for bgc in {40..47}; do
            fgc=${fgc#37} # white
            bgc=${bgc#40} # black

            vals="${fgc:+$fgc;}${bgc}"
            vals=${vals%%;}

            seq0="${vals:+\e[${vals}m}"
            printf "  %-9s" "${seq0:-(default)}"
            printf " ${seq0}TEXT\e[m"
            printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
        done
        echo; echo
    done
}

random_string()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}
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

# TODO: custom history

# From http://stackoverflow.com/questions/945288/saving-current-directory-to-bash-history
hcmnt() {

# adds comments to bash history entries (or logs them)

# by Dennis Williamson - 2009-06-05 - updated 2009-06-19
# http://stackoverflow.com/questions/945288/saving-current-directory-to-bash-history
# (thanks to Lajos Nagy for the idea)

# the comments can include the directory
# that was current when the command was issued
# plus optionally, the date or other information

# set the bash variable PROMPT_COMMAND to the name
# of this function and include these options:

    # -e - add the output of an extra command contained in the hcmntextra variable
    # -i - add ip address of terminal that you are logged in *from*
    #      if you're using screen, the screen number is shown
    #      if you're directly logged in, the tty number or X display number is shown
    # -l - log the entry rather than replacing it in the history
    # -n - don't add the directory
    # -t - add the from and to directories for cd commands
    # -y - add the terminal device (tty)
    # text or a variable

# Example result for PROMPT_COMMAND='hcmnt -et $LOGNAME'
#     when hcmntextra='date "+%Y%m%d %R"'
# cd /usr/bin ### mike 20090605 14:34 /home/mike -> /usr/bin

# Example for PROMPT_COMMAND='hcmnt'
# cd /usr/bin ### /home/mike

# Example for detailed logging:
#     when hcmntextra='date "+%Y%m%d %R"'
#     and PROMPT_COMMAND='hcmnt -eityl ~/.hcmnt.log $LOGNAME@$HOSTNAME'
#     $ tail -1 ~/.hcmnt.log
#     cd /var/log ### dave@hammerhead /dev/pts/3 192.168.1.1 20090617 16:12 /etc -> /var/log


# INSTALLATION: source this file in your .bashrc

    # will not work if HISTTIMEFORMAT is used - use hcmntextra instead
    export HISTTIMEFORMAT=

    # HISTTIMEFORMAT still works in a subshell, however, since it gets unset automatically:

    #   $ htf="%Y-%m-%d %R "    # save it for re-use
    #   $ (HISTTIMEFORMAT=$htf; history 20)|grep 11:25

    local script=$FUNCNAME

    local hcmnt=
    local cwd=
    local extra=
    local text=
    local logfile=

    local options=":eil:nty"
    local option=
    OPTIND=1
    local usage="Usage: $script [-e] [-i] [-l logfile] [-n|-t] [-y] [text]"

    local newline=$'\n' # used in workaround for bash history newline bug
    local histline=     # used in workaround for bash history newline bug

    local ExtraOpt=
    local LogOpt=
    local NoneOpt=
    local ToOpt=
    local tty=
    local ip=

    # *** process options to set flags ***

    while getopts $options option
    do
        case $option in
            e ) ExtraOpt=1;;        # include hcmntextra
            i ) ip="$(who --ips -m)" # include the terminal's ip address
                ip=($ip)
                ip="${ip[4]}"
                if [[ -z $ip ]]
                then
                    ip=$(tty)
                fi;;
            l ) LogOpt=1            # log the entry
                logfile=$OPTARG;;
            n ) if [[ $ToOpt ]]
                then
                    echo "$script: can't include both -n and -t."
                    echo $usage
                    return 1
                else
                    NoneOpt=1       # don't include path
                fi;;
            t ) if [[ $NoneOpt ]]
                then
                    echo "$script: can't include both -n and -t."
                    echo $usage
                    return 1
                else
                    ToOpt=1         # cd shows "from -> to"
                fi;;
            y ) tty=$(tty);;
            : ) echo "$script: missing filename: -$OPTARG."
                echo $usage
                return 1;;
            * ) echo "$script: invalid option: -$OPTARG."
                echo $usage
                return 1;;
        esac
    done

    text=($@)                       # arguments after the options are saved to add to the comment
    text="${text[*]:$OPTIND - 1:${#text[*]}}"

    # *** process the history entry ***

    hcmnt=$(history 1)              # grab the most recent command

    # save history line number for workaround for bash history newline bug
    histline="${hcmnt%  *}"

    hcmnt="${hcmnt# *[0-9]*  }"     # strip off the history line number

    if [[ -z $NoneOpt ]]            # are we adding the directory?
    then
        if [[ ${hcmnt%% *} == "cd" ]]    # if it's a cd command, we want the old directory
        then                             #   so the comment matches other commands "where *were* you when this was done?"
            if [[ $ToOpt ]]
            then
                cwd="$OLDPWD -> $PWD"    # show "from -> to" for cd
            else
                cwd=$OLDPWD              # just show "from"
            fi
        else
            cwd=$PWD                     # it's not a cd, so just show where we are
        fi
    fi

    if [[ $ExtraOpt && $hcmntextra ]]    # do we want a little something extra?
    then
        extra=$(eval "$hcmntextra")
    fi

    # strip off the old ### comment if there was one so they don't accumulate
    # then build the string (if text or extra aren't empty, add them plus a space)
    hcmnt="${hcmnt% ### *} ### ${text:+$text }${tty:+$tty }${ip:+$ip }${extra:+$extra }$cwd"

    if [[ $LogOpt ]]
    then
        # save the entry in a logfile
        echo "$hcmnt" >> $logfile || echo "$script: file error." ; return 1
    else

        # workaround for bash history newline bug
        if [[ $hcmnt != ${hcmnt/$newline/} ]] # if there a newline in the command
        then
            history -d $histline # then delete the current command so it's not duplicated
        fi

        # replace the history entry
        history -s "$hcmnt"
    fi

} # END FUNCTION hcmnt

# set a default (must use -e option to include it)
export hcmntextra='date "+%Y%m%d %R"'      # you must be really careful to get the quoting right

# start using it
export PROMPT_COMMAND='hcmnt'

# ====== Prompt visual hints ==
function parse_git_branch {
    local LIGHT_RED="\033[1;31m"
    local LIGHT_GREEN="\033[1;32m"
    local DEFAULT="\033[0m"
    branch=$(
        git branch --no-color 2> /dev/null \
        | sed -e '/^[^*]/d' \
              -e 's/* \(.*\)/(\1)/' 
    )
    if [ "$branch" == "" ]; then
        echo ""
    else
        echo $branch \
        | sed -e 's/^(master)$/'`printf "$LIGHT_RED"`'(master)/' \
        | sed -e 's/$/ '`git status -s |grep -v '??' | wc -l`' file(s) changed/' \
        | sed -e 's/^/\n'`printf "$LIGHT_GREEN"`'branch: /' \
        | sed -e 's/$/'`printf "$DEFAULT"`'/'
    fi
}

declare __timer

function pre_command {
       export __timer=$(date +%s)
}

function alert {
    notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
}

function post_command {
    __delta=$(($(date +%s) - $__timer))
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
