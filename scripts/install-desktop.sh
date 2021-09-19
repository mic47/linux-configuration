#!/bin/bash

set -ex

# TOOD
# [x] Screenlayout
# [x] .desktop files
# [x] pomodoro configuration
# [x] pomodoro-client
# [x] pomodoro-counter
# [ ] platypus-timetrack -- separate repo currently
# [x] i3configuration
# [x] i3status configuraton
# [x] i3status binaries
# [x] albert
# [x] albert configuration
# [x] albert plugins
# [x] /home/mic/Pictures/i3wm_reference.png
# [x] /home/mic/Pictures/macros/kubernetes_guide.png
# [x] ~/.local/bin/i3status-custom.sh
# [ ] /home/mic/.local/bin/terminalNotes.sh

sudo apt-get install curl wget

curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
curl https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -
echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/home:manuelschneid3r.list

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
  python3-pip \
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

replace_with_symlink() {
  mkdir -p "$(dirname "$2")"
  rm -rf "$2"
  replace_with_symlink "$1" "$2"
}

replace_with_symlink desktop/screenlayout ~/.screenlayout
mkdir -p ~/.config/i3
replace_with_symlink desktop/i3.config ~/.config/i3/config
replace_with_symlink desktop/i3images ~/.config/i3/images
mkdir -p ~/.local/bin
replace_with_symlink desktop/i3status-custom.sh ~/.local/bin/i3status-custom.sh
mkdir -p ~/.config/i3status
replace_with_symlink desktop/i3status.config ~/.config/i3status/config
mkdir -p ~/.local/share/albert/org.albert.extension.python
replace_with_symlink desktop/albert/python_plugins ~/.local/share/albert/org.albert.extension.python/modules
mkdir -p ~/.config/albert
replace_with_symlink desktop/albert/albert.conf ~/.config/albert/albert.conf

mkdir -p ~/.logs
cat desktop/pomodoro.dconf | envsubst | dconf load /org/gnome/pomodoro/
replace_with_symlink desktop/pomodoro-question.sh ~/.local/bin/pomodoro-question.sh
replace_with_symlink desktop/pomodoro-resume.sh ~/.local/bin/pomodoro-resume.sh
replace_with_symlink desktop/pomodoro_counter.sh ~/.local/bin/pomodoro_counter.sh
replace_with_symlink desktop/pomodoro-manual.sh ~/.local/bin/pomodoro-manual.sh
replace_with_symlink desktop/pomodoro-switch.sh ~/.local/bin/pomodoro-switch.sh
mkdir -p github
pushd github
git clone https://github.com/kantord/i3-gnome-pomodoro
reqs=$(mktemp)
cat i3-gnome-pomodoro/requirements.txt | sed -e 's/==.*//' > "$reqs"
sudo pip3 install -r "$reqs"
sed -e 's/env python/python/' -i i3-gnome-pomodoro/pomodoro-client.py
replace_with_symlink "i3-gnome-pomodoro/pomodoro-client.py" ~/.local/bin/pomodoro-client
popd
desktop/desktop_files/install.sh
