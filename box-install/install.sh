#!/bin/bash
HOST=root@b.vakhov.me

ssh $HOST mkdir -p /root/.ssh
scp box-install/id_rsa* $HOST:/root/.ssh
ssh $HOST 'echo StrictHostKeyChecking=no > /root/.ssh/config'
ssh $HOST 'test -d /root/blog || git clone git@github.com:avakhov/blog /root/blog'
ssh $HOST git config --global user.email "vakhov@gmail.com"
ssh $HOST git config --global user.name "Alex Vakhov"
ssh $HOST git config --global push.default matching

# ruby-ruby-ruby - https://gist.github.com/scmx/9489499
# ssh $HOST << EOF
#   apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev nodejs
#   pushd /tmp
#     wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz
#     tar -xvzf ruby-2.1.2.tar.gz
#     pushd ruby-2.1.2/
#       ./configure --prefix=/usr/local
#       make
#       make install
#     popd
#   popd
#
#   gem install bundler
# EOF
