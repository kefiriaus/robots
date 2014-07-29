echo "========================"
echo "Installing Ruby On Rails"
echo "========================"

RUBY_VERSION=`ruby --version | sed -n '/ruby 2\.1\.2/Ip'`

if [[ "$RUBY_VERSION" == "" ]];then

#Step 1: Install Required Packages
sudo yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel
sudo yum -y install libyaml-devel libffi-devel openssl-devel make
sudo yum -y install bzip2 autoconf automake libtool bison iconv-devel

#Step 2: Install RVM
curl -L get.rvm.io | bash -s stable

#Step 3: Setup RVM Environment
source /etc/profile.d/rvm.sh

#Step 4: Install Ruby
rvm install 2.1.2

#Step 5: Setup Default Ruby Version
rvm use 2.1.2 --default

#Step 6: Check Current Ruby Version.
ruby --version

fi

ln -s /usr/local/bin/gem /usr/bin/gem
ln -s /usr/local/rvm/bin/rvm /usr/bin/rvm

gem install rails
#gem install passenger
#passenger-install-apache2-module
