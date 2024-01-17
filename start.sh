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

if [ -f /projeto/config_cntr/php.ini ] 
then
  cp /projeto/config_cntr/php.ini /config/
fi
if [ -f /projeto/config_cntr/www.conf ] 
then  
  cp /projeto/config_cntr/www.conf /config/    
fi
if [ -f /projeto/config_cntr/nginx.conf ] 
then
  cp /projeto/config_cntr/nginx.conf /config/  
fi
if [ -f /projeto/config_cntr/default.conf ] 
then
  cp /projeto/config_cntr/default.conf /config/  
fi

export COMMENT="#"

if [ ${DEBUG} == true ]
then
  apt update
  apt -y install --allow-unauthenticated php8.2-xdebug 
  export COMMENT=""
fi

if [ ${GIT_EMAIL} != "" ]  &&  [ ${GIT_USERNAME} != "" ] 
then
  git config --global user.email ${GIT_EMAIL} 
  git config --global user.name ${GIT_USERNAME}
fi

if ! [ -z ${MAIL_SERVER} ]
then
  envsubst < /muttrc.template > ~/.mutt/muttrc
fi
envsubst < /config/www.conf  > /etc/php/8.2/fpm/pool.d/www.conf
envsubst < /config/php.ini  > /etc/php/8.2/fpm/php.ini
envsubst < /config/php.ini  > /etc/php/8.2/cli/php.ini
cp /config/nginx.conf /etc/nginx/nginx.conf
envsubst < /config/default.conf  > /etc/nginx/conf.d/000-default.conf
service php8.2-fpm reload
