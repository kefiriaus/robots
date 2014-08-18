#! /bin/bash

SCRIPT_DIR=`pwd`
CENTOS="/etc/centos-release"
DEBIAN="/etc/debian_version" 
OS=""

#Checking rights
ID=`whoami`
if [[ "$ID" != "root" ]]; then
	echo "You are not root user!!!
	"
	exit 1
fi

#Checking if your OS is Debian or CentOS
if [[ -f "$CENTOS" ]]; then
	TMP=`cat $CENTOS | sed -n '/centos/Ip' | sed -n '/6\.5/Ip'`
	if [[ "$TMP" != "" ]]; then
		OS="centos"
	fi
fi

if [[ "$OS" == "" ]]; then
	echo "Your OS doesn't support this script!"
else
	echo "Your OS is $OS version $TMP
	"
	
	if [[ "$OS" == "centos" ]]; then
		#getting server parameters
		HOST=""
		GIT=""
		USER=""
		while [[ "$HOST" == "" ]]; do
			echo "Enter your host name without www, like yandex.ru:"
			read HOST
		done
		while [[ "$GIT" == "" ]]; do
			echo "Enter your github repo:"
			read GIT
		done
                while [[ "$USER" == "" ]]; do
                        echo "Enter deploy user:"
                        read USER
                done
		
		if [[ "$HOST" != "" ]] && [[ "$GIT" != "" ]] && [[ "$USER" != "" ]]; then
			if [[ `id www-data | sed -n '/No such user/Ip'` != "" ]]; then
				sudo useradd -M -r www-data
			fi
			if [[ `id $USER | sed -n '/No such user/Ip'` != "" ]]; then
				sudo useradd "$USER"
				sudo usermod -a -G www-data "$USER"
				sudo passwd "$USER"
			fi

			#Postgresql
			sudo yum -y install postgres*

			#SqlLite
			sudo yum -y install sqlite-devel

			#Rails
			if [[ `rails -v | sed -n '/4/Ip'` == "" ]]; then
				curl -sSL https://get.rvm.io | bash -s stable --rails --autolibs=enabled
				source /usr/local/rvm/scripts/rvm
				gem install bundler
			fi

			#nginx
			if [[ ! -d '/etc/nginx' ]]; then
				sudo yum -y install nginx
			fi

			sudo yum -y install nodejs

			if [[ ! -f "/etc/nginx/conf.d/$HOST.conf" ]]; then
				sudo cat "nginx.conf" | sed -e "s/#{server_name}#/$HOST/g" > "/etc/nginx/conf.d/$HOST.conf"
			fi

			if [[ ! -d "/var/www" ]]; then
				sudo mkdir "/var/www"
			fi

			if [[ ! -d "/var/www/$HOST" ]]; then
				sudo mkdir "/var/www/$HOST"
			fi
                        if [[ ! -d "/var/www/$HOST/shared" ]]; then
                                sudo mkdir "/var/www/$HOST/shared"
                        fi
                        if [[ ! -d "/var/www/$HOST/shard/pids" ]]; then
                                sudo mkdir "/var/www/$HOST/shared/pids"
                        fi
			if [[ ! -d "/var/www/$HOST/shared/config" ]]; then
                                sudo mkdir "/var/www/$HOST/shared/config"
			fi
			
			if [[ ! -d "/var/www/$HOST/current" ]]; then
				cd "/var/www/$HOST"
				rails new current
				cd "/var/www/$HOST/current"

				echo "gem 'unicorn'" >> Gemfile
				bundle install
				sudo cat "$SCRIPT_DIR/unicorn.rb" | sed -e "s/#{server_name}#/$HOST/g" > "config/unicorn.rb"

				echo "gem 'capistrano', group: :development" >> Gemfile
				echo "gem 'rvm-capistrano', group: :development" >> Gemfile
				bundle install
				bundle exec capify .
				sudo cat "$SCRIPT_DIR/deploy.rb" | sed -e "s/#{server_name}#/$HOST/g" | sed -e "s/#{deploy_user}#/$USER/g" | sed -e "s/#{github_repo}#/$GIT/g" > "config/deploy.rb"
			fi
			
			sudo chown -R www-data:www-data "/var/www/$HOST"
		fi
	fi


fi
