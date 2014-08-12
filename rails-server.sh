#! /bin/bash

sudo useradd -M -r www-data

#Postgresql
sudo yum -y install postgres*

#SqlLite
sudo yum -y install sqlite-devel

#Rails
curl -sSL https://get.rvm.io | bash -s stable --rails --autolibs=enabled
source /usr/local/rvm/scripts/rvm
gem install bundler

#nginx
sudo yum -y install nginx

