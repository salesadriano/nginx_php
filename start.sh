#!/bin/bash

if ! [ -z ${GIT_USERNAME} ] && ! [ -z ${GIT_PASSWORD} ] && ! [ -z ${GIT_PATH} ]
then
  cd /projeto
  git config --global pull.ff only && \
  git config --global init.defaultBranch master && \
  git config --global core.fileMode false && \
  git init && \
  git remote add master https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_PATH}
  git pull master master  
  rsync -aruvhcpt --progress /projeto/* ${WORKDIR}/
fi

if [ PERMISSAO eq "true" ]
  chown -R www-data:www-data ${WORKDIR} &
  chmod -R 775 ${WORKDIR} &
fi

if [ -d /scripts_init ];
then
  for f in /scripts_init/*; 
    do $f; 
  done
fi

if [ -d /projeto/scripts_init ];
then
  for f in /projeto/scripts_init/*; 
    do $f; 
  done
fi

if [ -f /projeto/config_cntr/php.ini ] || [ -f /projeto/config_cntr/www.conf ]
then
  cp /projeto/config_cntr/php.ini /etc/php/8.0/fpm/php.ini
  cp /projeto/config_cntr/www.conf /etc/php/8.0/fpm/pool.d/www.conf    
fi

if ! [ -z ${DEBUG} ]
then
  apt update
  apt -y install --allow-unauthenticated php-xdebug
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

service nginx reload

if ! [ -z ${MAIL_SERVER} ]
then
  envsubst < /muttrc.template > ~/.mutt/muttrc
fi

