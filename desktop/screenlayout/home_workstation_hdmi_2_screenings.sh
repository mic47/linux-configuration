#!/bin/sh
xrandr \
  --output eDP-1 --mode 3840x2160 --pos 0x0 --rotate normal \
  --output DP-1 --off \
  --output HDMI-1 --off \
  --output DP-2 --off \
  --output HDMI-2 --primary --mode 3840x2160 --pos 3840x0 --rotate normal
#i3-msg "workspace 10, move workspace to output DP-1"
#i3-msg "workspace 9, move workspace to output DP-1"
#i3-msg "workspace 8, move workspace to output DP-1"
#i3-msg "workspace 7, move workspace to output eDP-1"
#i3-msg "workspace 6, move workspace to output DP-1"
#i3-msg "workspace 5, move workspace to output DP-1"
#i3-msg "workspace 4, move workspace to output DP-1"
#i3-msg "workspace 3, move workspace to output eDP-1"
#i3-msg "workspace 2, move workspace to output DP-1"
#i3-msg "workspace 1, move workspace to output DP-1"
