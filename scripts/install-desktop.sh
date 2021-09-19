#!/bin/bash

set -ex

# TOOD
# [x] Screenlayout
# [ ] .desktop files
# [ ] pomodoro configuration
# [ ] pomodoro-client
# [ ] pomodoro-counter
# [x] i3configuration
# [x] i3status configuraton
# [x] i3status binaries
# [x] albert
# [x] albert configuration
# [x] albert plugins
# [x] /home/mic/Pictures/i3wm_reference.png
# [x] /home/mic/Pictures/macros/kubernetes_guide.png
# [ ] ~/.local/bin/i3status-custom.sh
# [ ] /home/mic/.local/bin/terminalNotes.sh

sudo apt-get install curl wget

curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
curl https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -
echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list
sudo wget -nv https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_20.04/Release.key -O "/etc/apt/trusted.gpg.d/home:manuelschneid3r.asc"

sudo apt update
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
	xss-lock \
  zenity

ln -s "$(pwd)/desktop/screenlayout" ~/.screenlayout
mkdir -p ~/.config/i3
ln -s "$(pwd)/desktop/i3.config" ~/.config/i3/config
ln -s "$(pwd)/desktop/i3images" ~/.config/i3/images
mkdir -p ~/.local/bin
ln -s "$(pwd)/desktop/i3status-custom.sh" ~/.local/bin/i3status-custom.sh
mkdir -p ~/.config/i3status
ln -s "$(pwd)/desktop/i3status.config" ~/.config/i3status/config
rm -r ~/.local/share/albert/org.albert.extension.python/modules
mkdir -p ~/.local/share/albert/org.albert.extension.python
ln -s "$(pwd)/desktop/albert/python_plugins" ~/.local/share/albert/org.albert.extension.python/modules
mkdir -p ~/.config/albert
rm ~/.config/albert/albert.conf
ln -s "$(pwd)/desktop/albert/albert.conf" ~/.config/albert/albert.conf

mkdir ~/.logs
cat desktop/pomodoro.dconf | envsubst | dconf load /org/gnome/pomodoro/
ln -s "$(pwd)/desktop/pomodoro-question.sh" ~/.local/bin/pomodoro-question.sh
ln -s "$(pwd)/desktop/pomodoro-resume.sh" ~/.local/bin/pomodoro-resume.sh
mkdir -p github
pushd github
git clone https://github.com/kantord/i3-gnome-pomodoro
sudo pip install -r i3-gnome-pomodoro/requirements.txt
sed -e 's/env python/python/' -i i3-gnome-pomodoro/pomodoro-client.py
ln -s "$(pwd)/i3-gnome-pomodoro/pomodoro-client.py" ~/.local/bin/pomodoro-client
popd
