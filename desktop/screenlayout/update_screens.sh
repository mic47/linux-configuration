#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")" || exit

function create_screen_representation {
  sort \
  | tr '\n' ',' \
  | sed -e 's/\s*//;s/,*$//'
}

MONITORS=$(xrandr \
  | grep '\bconnected' \
  | cut -f 1 -d' ' \
  | create_screen_representation
)

LAST_KNOW_CONFIGURATION="last_configuration.txt"

LAST_CONF=$(cat "$LAST_KNOW_CONFIGURATION" | tr -d '\n')

if [ "$LAST_CONF" == "$MONITORS" ] ; then
  echo "Last configuration is same as before, not updating"
  exit 0
fi

echo "$MONITORS" > "$LAST_KNOW_CONFIGURATION"

for i in *sh ; do
  CURRENT=$(cat "$i" \
    | grep '\--output' \
    | sed -e 's/.*--output //' \
    | grep -v 'off' \
    | cut -f 1 -d' ' \
    | create_screen_representation
  )
  if [ "$MONITORS" == "$CURRENT" ] ; then
    ./"$i"
    exit 0
  fi;
done

echo "NO Known configuration detected!"
arandr
exit 1
popd || exit
