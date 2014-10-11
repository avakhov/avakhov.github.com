#!/bin/bash

last=`ls -1 _posts/2020-01-01* | head -1`
now=`date "+%Y-%m-%d"`
publish=${last//2020-01-01/$now}
mv $last $publish
git add -A
git commit -m"Blogging at `date`"
