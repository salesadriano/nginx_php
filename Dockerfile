FROM nginx:1.25.1

ENV ACCEPT_EULA=Y
ENV WWWROOT=/code
ENV WORKDIR=/code

WORKDIR /code

ADD start.sh /docker-entrypoint.d/40-start.sh
ADD scripts/* /scripts/
ADD config_cntr/php.ini /tmpconfig/php.ini

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
    # curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    # curl -s https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    wget http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources && \
    mv wtf-bookworm.sources /etc/apt/sources.list.d/ && \
    apt -y update && \
    apt -y install --allow-unauthenticated php8.2 php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xmlrpc \
                   php8.2-soap php8.2-gd php8.2-xml php8.2-intl php8.2-dev php8.2-curl php8.2-cli php8.2-zip \
                   php8.2-imagick php8.2-pgsql php8.2-gmp php8.2-ldap php8.2-bcmath php8.2-bz2 php8.2-ctype \
                   php8.2-opcache php8.2-phar php8.2-readline unixodbc-dev autoconf openjdk-8-jdk\
                #    msodbcsql18 mssql-tools adoptopenjdk-8-hotspot \
                   libc-dev pkg-config fontforge cabextract && \
    wget https://gist.githubusercontent.com/maxwelleite/10774746/raw/ttf-vista-fonts-installer.sh -q -O - | bash && \
    apt upgrade -y && \
    apt-get remove --purge --auto-remove -y  && \
    apt autoremove -y && \
    apt clean && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    # printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.2/mods-available/sqlsrv.ini && \
    # printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.2/mods-available/pdo_sqlsrv.ini && \
    # phpenmod -v  sqlsrv pdo_sqlsrv && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R www-data:www-data /code &&  \
    printf "# priority=30\nservice php8.2-fpm start\n" > /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/40-start.sh && \
    mkdir -p ~/.mutt/cache/headers && \
    mkdir /projeto && \
    mkdir ~/.mutt/cache/bodies && \
    touch ~/.mutt/certificates && \
    touch ~/.mutt/muttrc && \
    mkdir ~/Mail && \
    mkdir -m 0700 ~/Mail/INBOX && \
    mkdir -m 0700 ~/Mail/INBOX/{cur,new,tmp} && \
    git config --global core.fileMode false

ADD config_cntr/www.conf /etc/php/8.2/fpm/pool.d/www.conf
ADD config_cntr/php.ini /etc/php/8.2/fpm/php.ini
ADD config_cntr/php.ini /etc/php/8.2/cli/php.ini
ADD config_cntr/drivers/* /usr/lib/php/20220829/
ADD config_cntr/nginx.conf /etc/nginx
ADD config_cntr/default.conf /etc/nginx/conf.d/
ADD config_cntr/muttrc.template /
