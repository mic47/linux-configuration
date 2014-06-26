#!/bin/bash

for i in *\.*; do
    if [[ -d $i ]]; then
        scp -r $i:$1 $i/$1; 
    fi
done


