#!/bin/bash

# TOOD
# [x] Screenlayout
# [ ] .desktop files
# [ ] pomodoro configuration
# [ ] pomodoro-client
# [ ] pomodoro-counter
# [x] i3configuration
# [x] i3status configuraton
# [x] i3status binaries
# [ ] albert
# [ ] albert configuration
# [ ] albert plugins
# [ ] /home/mic/Pictures/i3wm_reference.png
# [ ] /home/mic/Pictures/macros/kubernetes_guide.png
# [ ] ~/.local/bin/i3status-custom.sh
# [ ] /home/mic/.local/bin/terminalNotes.sh

sudo apt-get install \
	albert \
	arandr \
	autorandr \
	dconf-editor \
  dunst \
	feh \
	flameshot \
	gnome-shell-pomodoro \
  gnome-settings-daemon \
  gnome-power-manager \
  gnome-screensaver \
  gnome-screenshot \
	gparted \
	i3 \
	i3blocks \
	i3status \
	inotify-tools \
	lm-sensors \
  parallel \
	pavucontrol \
	pulseaudio-equalizer \
  pulseaudio-utils \
	spotify-client \
	xautolock \
	xbindkeys \
	xbuilder \
	xclip \
	xcompmgr \
	xdg-desktop-portal-gtk \
	xdotool \
	xkbset \
	xss-lock

ln -s "$(pwd)/desktop/screenlayout" ~/.screenlayout
mkdir -p ~/.config/i3
ln -s "$(pwd)/desktop/i3.config" ~/.config/i3/config
ln -s "$(pwd)/desktop/i3status-custom.sh" ~/.local/bin/i3status-custom.sh
mkdir -p ~/.config/i3status
ln -s "$(pwd)/desktop/i3status.config" ~/.config/i3status/config
