#!/bin/bash

path=$1
files=$(ls $path)
for filename in $files
do
   echo ${filename%.*} >> filename.txt
done

filenamelist=$(cat filename.txt | awk '{print $0}')
for name in $filenamelist
do
    cp ${name}.json ${name}Async.json
done

# rm -rf filename.txt RenameScript.sh