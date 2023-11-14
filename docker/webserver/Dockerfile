FROM php:8.2-fpm
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y p7zip \
    p7zip-full \
    unace \
    zip \
    unzip \
    xz-utils \
    sharutils \
    uudeview \
    mpack \
    arj \
    ssh \
    cabextract \
    file-roller \
    xdg-utils \
    fonts-liberation \
    libzip-dev zlib1g-dev libicu-dev git libc-client-dev tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure zip\
    && docker-php-ext-install zip \
    && pecl install redis && docker-php-ext-enable redis\
    && docker-php-ext-configure intl && docker-php-ext-install intl
RUN apt-get install -y

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN chown -R www-data:www-data /var/www

WORKDIR /var/www/html

ARG SSH_PRV_KEY

RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan gitlab.conuti.de > /root/.ssh/known_hosts

RUN echo "$SSH_PRV_KEY" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa
CMD ["tail","-f","/etc/hosts"]
