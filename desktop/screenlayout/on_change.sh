#!/bin/bash
script_dir=$(realpath "$(dirname $0)")

udevadm monitor | while read -r line ; do
  echo "[$(date)] $line"
  sleep 3
  #./update_screens.sh
  bash "$script_dir"/autorandr.sh
done
