#!/bin/bash

PROFILE=${1:-notes}

if [[ $(ps uax |grep vim | grep 'servername TerminalNotes') ]] ; then
  /usr/bin/vim --servername TerminalNotes --remote-send '<ESC><C-c><ESC>' ;
  /usr/bin/vim --servername TerminalNotes --remote-send '<ESC><C-c><ESC><CR>:wa<CR>' ;
  /usr/bin/vim --servername TerminalNotes --remote-send '<ESC><C-c><ESC><CR>:qa<CR>' ;
else
  gnome-terminal --hide-menubar --profile="$PROFILE" --title='Terminal Notes' --class='GnomeTerminalNotes' &
fi

