#!/bin/bash

for i in *\.*; do
    if [[ -d $i ]]; then
        echo scp -r $i:$1 $i/$i; 
    fi
done


