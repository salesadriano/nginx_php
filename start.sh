#!/bin/bash

if ! [ -d ${WWWROOT} ]
then
  mkdir -p ${WWWROOT}
fi

chown -R www-data:www-data ${WWWROOT} 
chmod -R 755 ${WWWROOT} 

if ! [ ${WWWROOT} == "/var/www/html" ]
then
  mkdir -p /var/www
  ln -s ${WWWROOT} /var/www/html
fi

if [ -f /projeto/config_cntr/php.ini ] || [ -f /projeto/config_cntr/www.conf ]
then
  cp /projeto/config_cntr/php.ini /etc/php/8.2/fpm/php.ini
  cp /projeto/config_cntr/www.conf /etc/php/8.2/fpm/pool.d/www.conf    
fi

if ! [ -z ${DEBUG} ]
then
  apt update
  apt -y install --allow-unauthenticated php8.2-xdebug 
  printf "xdebug.mode = debug \nxdebug.start_with_request = yes \nxdebug.client_host = host.docker.internal" >> /etc/php/8.2/cli/php.ini  
fi
service php8.2-fpm reload

if [ -f /projeto/config_cntr/nginx.conf ] 
then
  cp /projeto/config_cntr/nginx.conf /etc/nginx/nginx.conf  
fi
sed -i "s|/code;|${WWWROOT};|g" /etc/nginx/conf.d/default.conf

if [ -d /projeto/config_cntr/conf.d ]
then
  cp /projeto/config_cntr/conf.d/* /etc/nginx/conf.d/
fi

if ! [ -z ${MAIL_SERVER} ]
then
  envsubst < /muttrc.template > ~/.mutt/muttrc
fi

