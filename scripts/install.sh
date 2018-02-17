#!/bin/bash

base=`pwd`

echo source $base/bashrc >> ~/.bashrc
echo source $base/vimrc >> ~/.vimrc
vim +VundleInstall
ln -s $base/pystartup.py ~/.pystartup
ln -s $base/tmux.conf ~/.tmux.conf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
