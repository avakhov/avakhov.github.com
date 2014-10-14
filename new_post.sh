#!/bin/bash

if [ "$1" == "" ]; then
  echo The script creates a branch, pushes the branch to origin and
  echo prepare markdown file for new post. 
  echo
  echo Usage:
  echo ./new_post.sh the-post-permalink
  exit
fi

ref=`git symbolic-ref HEAD 2> /dev/null`
branch=${ref#refs/heads/}

if [ "$branch" != "master" ]; then
  echo "[ERROR] Create post only from master branch please"
  exit -1
fi

title=$1
filename=_posts/2020-01-01-${1}.markdown
year=`date +%Y`

git checkout -b "$title"
git push origin "$title" -u

cat > $filename <<EOF
---
title: $title
image: /assets/$year/
---
EOF

git add $filename
