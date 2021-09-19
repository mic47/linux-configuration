#!/bin/bash

sudo apt-get install \
	agrep \
	astyle \
	atop \
	bat \
	bsdgames \
	cloc \
	colordiff \
	convert \
	curl \
	devilspie \
	exuberant-ctags \
	git \
	git-extras \
	iotop \
	jnettop \
	jq \
	links \
	lsp-plugins \
	lynx \
	make \
	neovim \
	nmap \
	parallel \
	pv \
	sloccount \
	slop \
	sox \
	thefuck \
	tidy \
	tmux \
	traceroute \
	visidata \
	visualvm \
	websocat \
	wireshark \
	yad \
	yamllint

./scripts/gh_package.sh git@github.com:mic47/git-tools.git github/git-tools
