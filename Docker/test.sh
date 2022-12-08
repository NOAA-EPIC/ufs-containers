#!/bin/bash
#set -x

IFS=$'\n'
variants=`grep COMPILE tests/rt.conf | awk -F "|" '{print $2}'`
mkdir build
cd build
declare -i i=1
for line in $variants; do
  echo $i $line
  rm -rf *
  echo cmake $line .. > cmd
  chmod +x cmd
  ./cmd
  make -j 8
  mv ufs_model ../tests/ufs_model_$i
  i=i+1
done

