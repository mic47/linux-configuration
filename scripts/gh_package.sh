#!/bin/bash

repo=$1
directory=$2

git clone "$repo" "$directory"
pushd "$directory" || exit 1
git pull
make install-local
popd || exit 1
