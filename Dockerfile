FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="BiteHost WebHost" \
      org.opencontainers.image.description="Nginx + PHP-FPM for Pterodactyl/Pelican" \
      org.opencontainers.image.source="https://github.com/Vahistar/BiteHost-WebHost" \
      org.opencontainers.image.licenses="MIT"

ARG PHP_VERSION=8.4
ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSION=${PHP_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg2 lsb-release apt-transport-https \
        git unzip tini cron certbot python3-certbot-nginx \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/mainline/debian bookworm nginx" \
        > /etc/apt/sources.list.d/nginx.list \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ bookworm main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nginx \
    && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-readline \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-exif \
        php${PHP_VERSION}-gmp \
        php${PHP_VERSION}-imagick \
    && ARCH=$(uname -m) \
    && if [ "$ARCH" = "x86_64" ]; then CF_ARCH=amd64; elif [ "$ARCH" = "aarch64" ]; then CF_ARCH=arm64; else echo "Unsupported arch: $ARCH"; exit 1; fi \
    && wget -q -O /tmp/cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}.deb" \
    && dpkg -i /tmp/cloudflared.deb \
    && rm -f /tmp/cloudflared.deb \
    && apt-get install -y --no-install-recommends python3-certbot-dns-cloudflare || true \
    && curl -fsSL -o /usr/local/bin/composer https://getcomposer.org/download/latest-stable/composer.phar \
    && chmod +x /usr/local/bin/composer \
    && curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && printf '%s\n' 'session.upload_progress.enabled = 0' \
        > /etc/php/${PHP_VERSION}/fpm/conf.d/99-php2shell.ini \
    && printf '%s\n' 'session.upload_progress.enabled = 0' \
        > /etc/php/${PHP_VERSION}/cli/conf.d/99-php2shell.ini \
    && rm -rf /var/lib/apt/lists/*

COPY scripts/check-php2shell.sh /usr/local/bin/check-php2shell.sh
RUN chmod +x /usr/local/bin/check-php2shell.sh \
    && /usr/local/bin/check-php2shell.sh "${PHP_VERSION}"

RUN useradd -m -d /home/container -s /bin/bash container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
USER root
RUN chmod +x /entrypoint.sh
USER container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
