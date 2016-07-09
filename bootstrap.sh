#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PROJECTFOLDER='api-crystal-crm'

# update / upgrade
sudo apt-get install -y language-pack-en-base
sudo locale-gen en_US.UTF-8
sudo LANG=en_US.UTF-8
sudo LC_ALL=en_US.UTF-8
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php-7.0
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install nginx php7.0 php7.0-fpm php7.0-mysql php-xdebug nodejs npm
sudo ln -s /usr/bin/nodejs /usr/bin/node

# create project folder
sudo rm -rf "/var/www/html/${PROJECTFOLDER}"
sudo mkdir -p "/var/www/html/${PROJECTFOLDER}"

# setup hosts file
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /var/www/html/${PROJECTFOLDER}/;
    index index.php index.html index.htm;

    server_name localhost;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

sudo echo 'cgi.fix_pathinfo=0' >> /etc/php/7.0/fpm/php.ini
sudo sed -i 's/www-data/vagrant/g' /etc/nginx/nginx.conf
sudo sed -i 's/www-data/vagrant/g' /etc/php/7.0/fpm/pool.d/www.conf

#setup XDebug
XDEBUG=$(cat <<XDB
[Xdebug]
zend_extension="xdebug.so"
xdebug.remote_enable=1
xdebug.remote_handler=dbgp
; Change 127.0.0.1 to internal IP
xdebug.remote_host=127.0.0.1
xdebug.remote_port=9000
XDB
)
echo "${XDEBUG}" >> /etc/php/7.0/fpm/php.ini

# restart nginx + php7.0-fpm
sudo service nginx restart
sudo service php7.0-fpm restart

# install git
sudo apt-get -y install git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
