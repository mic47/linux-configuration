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
        branch=$(
        hg bookmark 2>/dev/null | grep -e '\*' | sed -e 's/[ *]*/(/;s/ .*/)/' 
        )
    fi
    if [ "$branch" == "" ]; then
        echo ""
    else
        echo $branch \
        | sed -e 's/^(master)$/'`printf "$LIGHT_RED"`'(master)/' \
        | sed -e 's/^/\n'`printf "$LIGHT_GREEN"`'Feature: /' \
        | sed -e 's/$/'`printf "$DEFAULT"`'/'
        #| sed -e 's/$/ '`git status -s |grep -v '??' | wc -l`' file(s) changed/' \
    fi
}

function send_alert {
  result=$([ $? = 0 ] && echo success || echo error)
  full_cmd=$(history | tail -n 1) 
  cmd=$(echo $full_cmd | awk '{print $2;}')

  subject="Command $cmd finished with $result" 
  email=$(cat ~/.email)
  echo "
    $full_cmd
    .
  " | mail -s "$subject" $email
}

