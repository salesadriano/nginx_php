#!/bin/bash

if ! [ -d ${WWWROOT} ]
then
  mkdir -p ${WWWROOT}
fi

if ! [ -z ${GIT_USERNAME} ] && ! [ -z ${GIT_PASSWORD} ] && ! [ -z ${GIT_PATH} ]
then
  cd /projeto
  git config --global pull.ff only && \
  git config --global init.defaultBranch master && \
  git config --global core.fileMode false && \
  git init && \
  git remote add master https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_PATH}
  git pull master master  
  rsync -aruvhcpt --progress /projeto/* ${WWWROOT}/
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
  cp /projeto/config_cntr/php.ini /etc/php/8.1/fpm/php.ini
  cp /projeto/config_cntr/www.conf /etc/php/8.1/fpm/pool.d/www.conf    
fi

if [ ${DEBUG}  == "true" ]
then
  apt update
  apt -y install --allow-unauthenticated php8.1-xdebug
  sed -i "s|##||g" /etc/php/8.1/fpm/php.ini
fi
service php8.1-fpm reload

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

