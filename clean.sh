#!/bin/bash
#

echo -n "Current work directory: $(pwd), "
read -n 1 -rep 'right? (y/n)' con
[ "$con"x != yx ] && echo "Break" && exit 1

rm -rf ./files/assets/forum-*
rm -rf ./files/assets/admin-*
rm -rf ./files/assets/rev-manifest.json
rm -rf ./files/storage/cache/*
rm -rf ./files/storage/formatter/*
rm -rf ./files/storage/less/*
rm -rf ./files/storage/logs/*
rm -rf ./files/storage/tmp/*
rm -rf ./files/storage/views/*

if [ "$1"x == allx ];then
  rm -rf ./conf/flarum/*
  rm -rf ./files/logs/*
fi
