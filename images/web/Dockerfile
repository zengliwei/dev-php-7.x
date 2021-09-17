FROM php:7.4-fpm

#
# Install PHP
#
RUN apt-get update \
    && apt-get -y install \
        libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
        libicu-dev \
        libxslt-dev \
        libzip-dev \
    && docker-php-ext-install -j$(nproc) bcmath intl opcache pdo_mysql soap xml xsl zip sockets \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install redis \
    && docker-php-ext-enable redis

#
# Install Composer
#
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 2.1.6
RUN apt-get update \
    && apt-get -y install zip unzip \
    && curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://getcomposer.org/installer \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && composer --ansi --version --no-interaction \
    && rm -f /tmp/installer.php \
    && find /tmp -type d -exec chmod -v 1777 {} +

#
# Install MSMTP for sending email
#
RUN apt-get update \
    && apt-get -y install msmtp
COPY linux/msmtprc /etc/

#
# Install Nginx
#
RUN apt-get update \
    && apt-get -y install nginx
COPY nginx/nginx.conf /etc/nginx/
COPY nginx/sites-enabled/project.conf /etc/nginx/sites-enabled/

#
# Install SSH
#
ARG SSH_PSWD=root
RUN apt-get update \
    && apt-get -y install openssh-server \
    && sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config \
    && sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 30/g' /etc/ssh/sshd_config \
    && sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 1200/g' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/www-data:\/var\/www:\/usr\/sbin\/nologin/www-data:\/var\/www:\/bin\/bash/g' /etc/passwd \
    && echo "root:${SSH_PSWD}" | chpasswd \
    && echo "www-data:${SSH_PSWD}" | chpasswd
COPY linux/.bashrc /root/
COPY linux/.bashrc /var/www/
COPY linux/.profile /var/www/

#
# Install Git
#
RUN apt-get update \
    && apt-get -y install git

#
# Rebuild file structure
#
RUN mv /var/www/html /var/www/current \
    && rm -rf /var/www/current/* \
    && chmod 0775 /var/www/current \
    && chown -R www-data:www-data /var/www
COPY --chown=www-data:www-data nginx/nginx.conf.sample /var/www/current/nginx.conf

#
# Prepare for start
#
COPY docker-bootstrap /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-bootstrap
WORKDIR /var/www
EXPOSE 22 80

CMD ["docker-bootstrap"]