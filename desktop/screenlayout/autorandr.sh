#!/bin/bash

file=$(mktemp)
autorandr --change > "$file"
if grep -q '(detected)' "$file" ; then
  cat "$file"
else
  echo "NOT DETECTED" ;
  arandr
  file_entry=$(mktemp)
  if zenity --entry --text="Name this configuration. Cancel means no save, empty means 'current'" > "$file_entry" ; then
    entry=$(cat "$file_entry")
    if [ "$entry" == "" ] ; then
      entry="current"
    fi
    autorandr --save "$entry"
    rm "${file_entry}"
  fi
fi

rm "$file"
