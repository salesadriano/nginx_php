
# Imagem Docker para Servidor NGINX com PHP 8.1 com integração com repositório git, cliente de e-mail e java

## GIT
Configurações para repositório GIT, quando configurado realiza pull do projeto e posiciona no Document Root do NGINX (Compatível apenas com HTTP Authentication)

``${GIT_PATH}`` - URL do do repositório; \
``${GIT_USERNAME}`` - Usuário para autenticação; \
``${GIT_PASSWORD}`` - Senha do Usuário.

## e-mail
Configurações para cliente de e-mail baseado em mutt

``${MAIL_SERVER}`` - URL do Servidor de e-mail a ser usado; \
``${MAIL_USER}`` - Usuário para autenticação no servidor de e-mail; \
``${MAIL_DOMAIN}`` - Domínio do serviço de e-mail; \
``${MAIL_NAME}`` - Nome do usuário para envio do e-mail; \
``${MAIL_SMTP_PORT}`` - Porta do serviço de e-mail; \
``${MAIL_PASSWORD}`` - Senha do usuário para autenticação no servidor de e-mail. \

## Document Root

``${WWWROOT}`` - Caminho do diretório que será usado como Document Root pelo NGINX. 
## diretório de Trabalho

``${WORKDIR}`` - diretório principal do projeto. 

## Debug
``${DEBUG}`` - Quando definido com true habilita o x-debug no PHP. 

## Paths
``/projeto`` - Quando configurado o repositório do GIT o pull do projeto é feito neste path e em seguida é sincronizado com o ``${WORKDIR}``; \
``/projeto/config_cntr/php.ini`` - Quando presente no projeto substitui o arquivo no Sistema Operacional (SO) e reinicia o serviço do PHP; \
``/projeto/config_cntr/www.conf`` - Quando presente no projeto substitui o arquivo no SO e reinicia o serviço do PHP; \
``/projeto/config_cntr/nginx.conf`` - Quando presente no projeto substitui o arquivo no SO e reinicia o serviço do NGINX; \
``/projeto/config_cntr/default.conf`` - Quando presente no projeto substitui o arquivo no SO e reinicia o serviço do NGINX; \
``/docker-entrypoint.d`` - Todas as scripts adicionados e este path serão executadas na inicialização do pod.


## Drivers
Bibliotecas ativas no PHP
- mysql 
- mbstring
- xmlrpc
- soap
- gd
- xml
- intl
- dev
- curl
- cli
- zip
- imagick
- pgsql
- gmp
- ldap
- bcmath
- bz2
- ctype
- opcache
- phar
- readline 

## Java
openjdk version "1.8.0_292" \
OpenJDK Runtime Environment (AdoptOpenJDK)(build 1.8.0_292-b10) \
OpenJDK 64-Bit Server VM (AdoptOpenJDK)(build 25.292-b10, mixed mode) 

## Tools
Ferramentas disponíveis na Image
- MariaDB Client
- MSSql Tools
- Git
- SSH Client
- Rsync
- CRON Service
- Unzip
- NTP Service

## Exemplo de uso

``docker run --name [pod] --rm -it -e DEBUG=true -e WWWROOT=/code -e GIT_PATH=https://gitlab.com/nginx_php.git -e GIT_USERNAME=user -e GIT_PASSWORD=password -p 80:80 -d [imagePath]``
