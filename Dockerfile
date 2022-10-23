FROM nginx:1.23.1

VOLUME [ "/code" ]

ENV ACCEPT_EULA=Y
ENV WWWROOT=/code
ENV WORKDIR=/code
ENV PERMISSAO=true

WORKDIR /code

ADD start.sh /docker-entrypoint.d/40-start.sh
ADD scripts/* /scripts/

RUN ln -fs /usr/share/zoneinfo/America/Rio_Branco /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt update && \
    apt -y upgrade && \
    echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen && \
    apt install -y ca-certificates \
                   apt-transport-https \
                   lsb-release \
                   gnupg \
                   ntp \
                   curl \
                   wget \
                   dirmngr \
                   cron \
                   software-properties-common \
                   locales git \
                   openssh-client \
                   rsync \
                   gettext \
                   mariadb-client \
                   mutt \ 
                   sshpass \
                   gcc \
                   g++ \
                   make \
                   unzip && \
    locale-gen && \
    curl -o /etc/apt/trusted.gpg.d/php.gpg -fSL "https://packages.sury.org/php/apt.gpg" && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt -y update && \
    apt -y remove libgcc-8-dev && \
    apt -y install --allow-unauthenticated php5.6 \
                   php5.6-fpm \
                   php5.6-mysql \
                   php5.6-mbstring \
                   php5.6-xmlrpc \
                   php5.6-soap \
                   php5.6-gd \
                   php5.6-xml \
                   php5.6-intl \
                   php5.6-dev \
                   php5.6-curl \
                   php5.6-cli \
                   php5.6-zip \
                   php5.6-imagick \
                   php5.6-pgsql \
                   php5.6-gmp \
                   php5.6-ldap \
                   php5.6-bcmath \
                   php5.6-bz2 \
                   php5.6-ctype \
                   php5.6-opcache \                   
                   php5.6-phar \                   
                   php5.6-readline \
                   gcc \
                   g++ \
                   make \
                   autoconf \
                   libc-dev \
                   pkg-config \
                   git \
                   adoptopenjdk-8-hotspot && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    ntpd -q -g && \
    rm -rf /var/lib/apt/lists/* && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    chown -R www-data:www-data /code &&  \
    printf "# priority=10\nservice ntp start\n" > /docker-entrypoint.d/10-ntpd.sh && \
    chmod 755 /docker-entrypoint.d/10-ntpd.sh && \
    printf "# priority=30\nservice php5.6-fpm start\n" > /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php-fpm.sh && \
    printf "# priority=40\nservice cron start\n" > /docker-entrypoint.d/40-cron.sh && \
    chmod 755 /docker-entrypoint.d/10-ntpd.sh && \    
    chmod 755 /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/40-start.sh && \
    chmod 755 /docker-entrypoint.d/40-cron.sh && \
    mkdir -p ~/.mutt/cache/headers && \
    mkdir /projeto && \
    mkdir ~/.mutt/cache/bodies && \
    touch ~/.mutt/certificates && \
    touch ~/.mutt/muttrc && \
    mkdir ~/Mail && \
    mkdir -m 0700 ~/Mail/INBOX && \
    mkdir -m 0700 ~/Mail/INBOX/{cur,new,tmp}
    
ADD config_cntr/php.ini /etc/php/5.6/fpm/php.ini
ADD config_cntr/www.conf /etc/php/5.6/fpm/pool.d/www.conf
ADD config_cntr/cron.list /
ADD config_cntr/nginx.conf /etc/nginx
ADD config_cntr/default.conf /etc/nginx/conf.d/
ADD config_cntr/muttrc.template /