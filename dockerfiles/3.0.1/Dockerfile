# syntax=docker/dockerfile:1.3-labs

FROM php:7.4.22-cli

LABEL org.opencontainers.image.authors="Drsanwujiang <drsanwujiang@gmail.com>" \
    org.opencontainers.image.url="https://github.com/drsanwujiang/dicerobot-docker" \
    org.opencontainers.image.version="3.0.1" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.title="DiceRobot Docker" \
    org.opencontainers.image.description="DiceRobot Docker image."

ENV container docker
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Init
RUN echo 'deb http://mirrors.aliyun.com/debian/ buster main non-free contrib\n\
deb http://mirrors.aliyun.com/debian-security buster/updates main\n\
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib\n\
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib'\
> /etc/apt/sources.list <<EOF

RUN apt-get update; \
    apt-get install -y wget

# Java
ENV JAVA_VERSION jdk-11.0.11+9

RUN apt-get update; \
    apt-get install -y tzdata ca-certificates fontconfig locales; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO /tmp/openjdk.tar.gz https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jre_x64_linux_hotspot_11.0.11_9.tar.gz; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz

ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

# Systemd
RUN apt-get update; \
    apt-get install -y systemd systemd-sysv; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

# Swoole
RUN apt-get update; \
    apt-get install -y libcurl4-openssl-dev libssl-dev zlib1g-dev curl; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install sockets; \
    docker-php-source extract; \
    mkdir /usr/src/php/ext/swoole; \
    wget -qO swoole.tgz https://dl.drsanwujiang.com/dicerobot/swoole/swoole-4.7.0.tgz; \
    tar xfz swoole.tgz --strip-components=1 -C /usr/src/php/ext/swoole; \
    docker-php-ext-configure swoole --enable-http2 --enable-openssl --enable-sockets --enable-swoole-curl --enable-swoole-json; \
    docker-php-ext-install -j$(nproc) swoole; \
    rm -f swoole.tgz; \
    docker-php-source delete

# DiceRobot Environment
RUN apt-get update; \
    apt-get install -y libzip-dev unzip; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install zip; \
    wget -qO composer-setup.php https://install.phpcomposer.com/installer; \
    php composer-setup.php; \
    rm -f composer-setup.php; \
    mv -f composer.phar /usr/bin/composer; \
    composer --no-interaction config -g repo.packagist composer https://mirrors.aliyun.com/composer/

VOLUME ["/root/dicerobot", "/root/mirai"]

WORKDIR /root

COPY ./dockerfiles/3.0.1/*.sh /root/

EXPOSE 9500

STOPSIGNAL SIGRTMIN+3

ENTRYPOINT ["/lib/systemd/systemd"]
