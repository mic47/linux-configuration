#!/bin/bash

#!/usr/bin/env bash

i3status  | while :
do
  read line
  work_today=`~/.local/bin/pomodoro_counter.sh | tr '\n' ' '`
  pomodoro=`/usr/bin/python3 ~/install/i3-gnome-pomodoro/pomodoro-client.py status | sed -e 's/Pomodoro/🍅/'`
  TODO=`cat "/home/$USER/Dropbox/Wiki/markor/01_TODO.md" | grep '[-] \[ \]' | head -n 1`
  TOP_PROCESS=$(ps -xa -o %mem=,comm= --sort=-%mem | sed -e 's/^ *//;s/ *$//;s/  */ /;s/WebContent\|WebExtensions\|Web/firefox/' | awk '{cmd[$2] = cmd[$2]+$1} END{for (x in cmd) {printf("%.1fG %s\n", cmd[x]*32/100, x)}}'  | sort -rn | head -n 1)
  TOP_CPU_PROCESS=$(ps -xa -o %cpu=,comm= --sort=-%cpu | sed -e 's/^ *//;s/ *$//;s/  */ /;s/WebContent\|WebExtensions\|Web/firefox/' | awk '{cmd[$2] = cmd[$2]+$1} END{for (x in cmd) {printf("%.1f%% %s\n", cmd[x], x)}}'  | sort -rn | head -n 1)
  echo "$TODO | $work_today $pomodoro | $TOP_PROCESS | $TOP_CPU_PROCESS | $line" || exit 1
done
