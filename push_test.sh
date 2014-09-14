#!/bin/bash
bundle exec jekyll build
rsync --exclude=.git -av --del _site/ ../vakhov-test

pushd ../vakhov-test
  git add -A
  git commit -m"Testing at `date`"
  git push
popd
