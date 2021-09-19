#!/bin/bash

install_custom_deb_package_from_github() {
  repo=$1
  directory=$2
  git clone "$repo" "$directory"
  pushd "$directory" || exit 1
  git pull
  make install-local
  popd || exit 1
}

base=`pwd`

mkdir -p ~/.vim/bundle
mkdir -p ~/.local/bin
g++ -W -Wall -O3 superhistoryparse.cpp -o ~/.local/bin/superhistory_parser
ln -s $base/crep.py ~/.local/bin/crep
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
cp fzf.patch ~/.fzf/
pushd ~/.fzf
git apply fzf.patch
rm fzf.patch
popd
sudo apt update
sudo apt install python3-dev python3-pip python3-setuptools urlview
sudo pip3 install thefuck

npm install eslint
npm install prettier eslint-plugin-prettier
npm install eslint-config-prettier

mkdir -p "github"
install_custom_deb_package_from_github git@github.com:mic47/git-tools.git github/git-tools

echo Go to ~/vim/bundle/YouCompleteMe and install it you want probably all, maybe not go.
echo You should also install https://github.com/luben/sctags !!!
echo You should also install http://ensime.github.io/editors/vim/install/ !!!
