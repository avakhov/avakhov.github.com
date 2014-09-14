#!/bin/bash

echo "baseurl: /vakhov-test" >> _config.yml
bundle exec jekyll build
cp _config.yml _config.yml.tmp
sed '$ d' _config.yml.tmp > _config.yml
rm -f _config.yml.tmp

rsync --exclude=.git -av --del _site/ ../vakhov-test

pushd ../vakhov-test
  git add -A
  git commit -m"Testing at `date`"
  git push
popd
