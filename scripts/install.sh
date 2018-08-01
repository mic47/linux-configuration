#!/bin/bash

base=`pwd`

mkdir -p ~/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo source $base/bashrc >> ~/.bashrc
echo source $base/vimrc >> ~/.vimrc
vim +VundleInstall
ln -s $base/pystartup.py ~/.pystartup
ln -s $base/tmux.conf ~/.tmux.conf
ln -s $base/ctags ~/.ctags
ln -s $base/gitignore_global ~/.gitignore_global
ln -s $base/sbt/1.0/plugins/plugins.sbt ~/.sbt/1.0/plugins/plugins.sbt
git config --global core.excludesfile ~/.gitignore_global
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


echo You should also install https://github.com/luben/sctags !!!
