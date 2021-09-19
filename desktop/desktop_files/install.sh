#!/bin/bash

export CONFIG_HOME=$(pwd)

for i in desktop/desktop_files/*desktop ; do
  cat "$i" | envsubst > ~/.local/share/applications/"$(basename "$i")"
done
