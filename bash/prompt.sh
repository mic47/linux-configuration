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
        commit=$(
        hg log |grep summary | head -n 1  | sed -e 's/^summary:[ \t]*//'
        )
    else
        commit=$(
        git log | head -n 5 | tail -n 1 | sed -e 's/^[ \t]*//'
        )
    fi
    if [ "$commit" == "" ]; then
        echo ""
    else
        echo $commit \
        | sed -e 's/^(master)$/'`printf "$LIGHT_RED"`'(master)/' \
        | sed -e 's/^/\n'`printf "$LIGHT_GREEN"`'Feature: /' \
        | sed -e 's/$/'`printf "$DEFAULT"`'/'
        #| sed -e 's/$/ '`git status -s |grep -v '??' | wc -l`' file(s) changed/' \
    fi
}

declare __last_command

function send_alert {
  result=$([ $? = 0 ] && echo success || echo error)
  full_cmd=$(history | tail -n 1) 
  cmd=$(echo $full_cmd | awk '{print $2;}')

  subject="Command $cmd finished with $result" 
  email=$(cat ~/.email)
  touch /tmp/last_command.$$
  __last_command=$(cat /tmp/last_command.$$)
  if [[ "$cmd" != "vim" && "$__last_command" != "$full_cmd" ]]
  then
    echo "
      $full_cmd 
      .
    " | mail -s "$subject" $email
  fi
  echo -n "$full_cmd" > /tmp/last_command.$$
}

