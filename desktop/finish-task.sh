#!/bin/bash

grep \
  -n \
  --with-filename '\(^ *- *\[ \]\|^ *\[ \]\)' \
  $(
    ls \
      /home/$USER/Documents/WorkNotext.md \
      /home/$USER/Documents/WorkLog/*/*/*.md \
      | sort -r \
    ; \
    ls \
      /home/$USER/Dropbox/Wiki/log/*/*/*.md \
      | sort -r \
  ) \
  | sed -e 's/^/\n/' \
  | sed -e 's/^\([^:]*\):\([^:]*\):\(.*\)$/\3:\1:\2/' \
  | zenity --list --checklist --column=a --column=b --text 'Mark Tasks as Done' --separator '\n'  --width 500 --height 500 \
  | sed -e 's/^\(.*\):\([^:]*\):\([^:]*\)$/\3:\2/' \
  | sed -e 's/^/sed -i -e "/;s/:/s\/[[] []]\/[x]\/" "/;s/$/"/' \
  | bash

