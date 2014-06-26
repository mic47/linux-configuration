#!/bin/bash

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

function alert {
    notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
}

