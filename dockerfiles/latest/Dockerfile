# syntax=docker/dockerfile:1

FROM php:7.4.22-cli

LABEL org.opencontainers.image.authors="Drsanwujiang <drsanwujiang@gmail.com>" \
    org.opencontainers.image.url="https://github.com/drsanwujiang/dicerobot-docker" \
    org.opencontainers.image.version="3.1.0" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="DiceRobot Docker" \
    org.opencontainers.image.description="DiceRobot Docker image."

ENV container docker
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

ARG DEB_MIRROR
ARG ADOPTIUM_MIRROR_URL
ARG COMPOSER_MIRROR_URL
ARG DICEBOT_UID

# Init
RUN sed -i "s/deb.debian.org/${DEB_MIRROR}/g" /etc/apt/sources.list
RUN sed -i "s|security.debian.org/debian-security|${DEB_MIRROR}/debian-security|g" /etc/apt/sources.list

RUN apt-get update; \
    apt-get install -y wget tzdata ca-certificates fontconfig locales apt-transport-https;

# Java
RUN mkdir -p /etc/apt/keyrings
RUN wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | \
    tee /etc/apt/keyrings/adoptium.asc
RUN echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] ${ADOPTIUM_MIRROR_URL} \
    $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | \
    tee /etc/apt/sources.list.d/adoptium.list
RUN apt-get update && apt-get install -y temurin-11-jdk

# Swoole
RUN apt-get update; \
    apt-get install -y libcurl4-openssl-dev libssl-dev zlib1g-dev curl;

RUN docker-php-ext-install sockets; \
    docker-php-source extract; \
    mkdir /usr/src/php/ext/swoole; \
    wget -qO swoole.tgz https://dl.drsanwujiang.com/dicerobot/swoole/swoole-4.7.1.tgz; \
    tar xfz swoole.tgz --strip-components=1 -C /usr/src/php/ext/swoole; \
    docker-php-ext-configure swoole --enable-http2 --enable-openssl --enable-sockets --enable-swoole-curl --enable-swoole-json; \
    docker-php-ext-install -j$(nproc) swoole; \
    rm -f swoole.tgz; \
    docker-php-source delete

# DiceRobot Environment
RUN apt-get update; \
    apt-get install -y libzip-dev unzip;

RUN docker-php-ext-install zip; \
    wget -qO composer-setup.php https://install.phpcomposer.com/installer; \
    php composer-setup.php; \
    rm -f composer-setup.php; \
    mv -f composer.phar /usr/local/bin/composer;

RUN composer --no-interaction config -g repo.packagist composer ${COMPOSER_MIRROR_URL}
RUN composer --no-interaction config -g cache-dir /tmp

VOLUME ["/dicerobot", "/mirai"]

RUN cp -rv /root/.composer /
RUN chown -R ${DICEBOT_UID} /.composer 

COPY ./init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

# Clean apt
RUN apt-get clean; \
    rm -rf /var/lib/apt/lists/*

EXPOSE 9500
