FROM nginx:1.27.0

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

ADD start.sh /start.sh
ADD config_cntr/* /config/

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
    apt -y install --allow-unauthenticated php8.4 php8.4-fpm php8.4-mysql php8.4-mbstring php-xmlrpc \
                   php8.4-soap php8.4-gd php8.4-xml php8.4-intl php8.4-dev php8.4-curl php8.4-cli php8.4-zip \
                   php-imagick php8.4-pgsql php8.4-gmp php8.4-ldap php8.4-bcmath php8.4-bz2 php8.4-ctype \
                   php8.4-opcache php8.4-phar php8.4-readline unixodbc-dev autoconf \  
                #    temurin-8-jdk\
                   libc-dev pkg-config fontforge cabextract && \
    update-alternatives --set php /usr/bin/php8.4 && \
    update-alternatives --set phar /usr/bin/phar8.4 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar8.4 && \
    update-alternatives --set phpize /usr/bin/phpize8.4 && \
    update-alternatives --set php-config /usr/bin/php-config8.4 && \
   #  update-alternatives --set phpdbg /usr/bin/phpdbg8.4 && \
    wget https://gist.githubusercontent.com/maxwelleite/10774746/raw/ttf-vista-fonts-installer.sh -q -O - | bash && \
    apt upgrade -y && \
    apt-get remove --purge --auto-remove -y  && \
    apt autoremove -y && \
    apt clean && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R www-data:www-data /code &&  \
    chmod 755 /start.sh && \
    mkdir -p ~/.mutt/cache/headers && \
    mkdir /projeto && \
    mkdir ~/.mutt/cache/bodies && \
    touch ~/.mutt/certificates && \
    touch ~/.mutt/muttrc && \
    mkdir ~/Mail && \
    mkdir -m 0700 ~/Mail/INBOX && \
    mkdir -m 0700 ~/Mail/INBOX/{cur,new,tmp} && \
    git config --global core.fileMode false  && \
    git config --global core.autocrlf true

    CMD [ "/start.sh" ]