#!/bin/bash

#!/usr/bin/env bash

i3status  | while :
do
  read line
  work_today=`~/.local/bin/pomodoro_counter.sh | tr '\n' ' '`
  pomodoro=`pomodoro-client status | sed -e 's/Pomodoro/🍅/'`
  # Documents/WorkLog/2022/02/10.md
  TODO=$(cat $(ls /home/$USER/Documents/WorkNotext.md /home/$USER/Documents/WorkLog/*/*/*.md | sort -r) | grep '[-] \[ \]' | head -n 1)
  TOP_PROCESS=$(
    ps -xa -o %mem=,comm= --sort=-%mem \
    | sed -e 's/^ *//;s/ *$//;s/  */ /;s/WebContent\|WebExtensions\|Web\|Isolated .*\|RDD/firefox/' \
    | awk '{cmd[$2] = cmd[$2]+$1} END{for (x in cmd) {printf("%.1fG %s\n", cmd[x]*32/100, x)}}' \
    | sort -rn \
    | head -n 1
  )
  TOP_CPU_PROCESS=$(
    ps -xa -o %cpu=,comm= --sort=-%cpu \
    | sed -e 's/^ *//;s/ *$//;s/  */ /;s/WebContent\|WebExtensions\|Web\|Isolated .*\|RDD/firefox/' \
    | awk '{cmd[$2] = cmd[$2]+$1} END{for (x in cmd) {printf("%.1f%% %s\n", cmd[x], x)}}'  \
    | sort -rn \
    | head -n 1)
  echo "$TODO | $work_today $pomodoro | $TOP_PROCESS | $TOP_CPU_PROCESS | $line" || exit 1
done
