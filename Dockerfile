FROM nginx:1.25.3

ENV WWWROOT=/var/www/html
ENV WORKDIR=/code
ENV PHP_EXEC_TIMEOUT=3600
ENV PHP_MEMORY=8192
ENV PHP_POST_MAX=8192
ENV PHP_FILE_MAX=8192
ENV PHP_UPLOAD_MAX=8192
ENV NGINX_BODY_MAX=8192
ENV PHP_REPORTING=E_ERROR
ENV PHP_ERROS=Off
ENV DEBUG=false
ENV COMMENT=#
ENV document_root="\$document_root"
ENV uri="\$uri"
ENV query_string="\$query_string"
ENV fastcgi_script_name="\$fastcgi_script_name"
ENV GIT_EMAIL=""
ENV GIT_USERNAME=""

WORKDIR /code

ADD start.sh /docker-entrypoint.d/40-start.sh
ADD config_cntr/* /config

#TODO Compilar com php 8.3
RUN ln -fs /usr/share/zoneinfo/America/Rio_Branco /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt update && \
    apt -y upgrade && \
    echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen && \
    apt install -y ca-certificates apt-transport-https lsb-release gnupg ntp curl \
                   wget dirmngr software-properties-common locales git openssh-client \
                   rsync gettext mariadb-client mutt sshpass gcc g++ make unzip && \
    locale-gen && \
    curl -o /etc/apt/trusted.gpg.d/php.gpg -fSL "https://packages.sury.org/php/apt.gpg" && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    wget http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources && \
    mkdir -p /etc/apt/keyrings && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
    wget http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    mv wtf-bookworm.sources /etc/apt/sources.list.d/ && \
    apt -y update && \
    apt -y install --allow-unauthenticated php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xmlrpc \
                   php8.2-soap php8.2-gd php8.2-xml php8.2-intl php8.2-dev php8.2-curl php8.2-cli php8.2-zip \
                   php8.2-imagick php8.2-pgsql php8.2-gmp php8.2-ldap php8.2-bcmath php8.2-bz2 php8.2-ctype \
                   php8.2-opcache php8.2-phar php8.2-readline unixodbc-dev autoconf temurin-8-jdk\
                   libc-dev pkg-config fontforge cabextract && \
    wget https://gist.githubusercontent.com/maxwelleite/10774746/raw/ttf-vista-fonts-installer.sh -q -O - | bash && \
    apt upgrade -y && \
    apt-get remove --purge --auto-remove -y  && \
    apt autoremove -y && \
    apt clean && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R www-data:www-data /code &&  \
    printf "# priority=30\nservice php8.2-fpm start\n" > /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/40-start.sh && \
    mkdir -p ~/.mutt/cache/headers && \
    mkdir /projeto && \
    mkdir /config && \
    mkdir ~/.mutt/cache/bodies && \
    touch ~/.mutt/certificates && \
    touch ~/.mutt/muttrc && \
    mkdir ~/Mail && \
    mkdir -m 0700 ~/Mail/INBOX && \
    mkdir -m 0700 ~/Mail/INBOX/{cur,new,tmp} && \
    git config --global core.fileMode false  && \
    git config --global core.autocrlf true


