#!/bin/bash
#

a=$(cat txt)
for n in ${a[*]};do
  na=$(echo $n | cut -c 8-)
  eval "mv $n $na"
done
