#!/bin/bash

yum -y install wget curl

wget http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm
rpm -ivh epel-release-7-0.2.noarch.rpm

yum -y install nodejs npm --enablerepo=epel
yum -y install postgres*
yum -y install sqlite-devel
yum -y install nginx
yum -y install python-devel
yum -y install ncurses-devel

# Install ruby on rails
curl -sSL https://get.rvm.io | bash -s stable --rails --autolibs=enabled
ruby --version
source /usr/local/rvm/scripts/rvm
gem install bundler

# Install vim
cd /usr/local/src
wget ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
tar -xjf vim-7.4.tar.bz2
cd vim-7.4
./configure --enable-multibyte --with-tlib=ncurses --enable-pythoninterp --enable-rubyinterp --with-features=huge
make && make install
export PATH=/usr/local/bin:$PATH

# Install vim plugins
cd /usr/local/src
sh -c "`curl -fsSL https://raw.github.com/skwp/dotfiles/master/install.sh`"
