#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD_BLUE='\033[1;34m'
WHITE='\033[0;37m'
NC='\033[0m'

header() {
  echo -e "${BLUE}───────────────────────────────────────────────${NC}"
  echo -e "${BOLD_BLUE}$1${NC}"
}

PHP_VERSION="${PHP_VERSION:-8.4}"
PHP_INI="${PHP_INI:-/home/container/php/php.ini}"
PHP_FPM_CONF="${PHP_FPM_CONF:-/home/container/php/php-fpm.conf}"
NGINX_CONF="${NGINX_CONF:-/home/container/nginx/nginx.conf}"
NGINX_PREFIX="${NGINX_PREFIX:-/home/container}"

mkdir -p "${NGINX_PREFIX}/tmp" "${NGINX_PREFIX}/logs" "${NGINX_PREFIX}/php/sessions" "${NGINX_PREFIX}/tmp/fastcgi_cache"

if [[ "${TRUST_PROXY:-1}" =~ ^(true|1)$ ]]; then
  if ! grep -q "snippets/proxy-headers.conf" "${NGINX_PREFIX}/nginx/conf.d/default.conf" 2>/dev/null; then
    if grep -q "server_name" "${NGINX_PREFIX}/nginx/conf.d/default.conf"; then
      sed -i '/server_name/a\    include /home/container/nginx/snippets/proxy-headers.conf;' \
        "${NGINX_PREFIX}/nginx/conf.d/default.conf" || true
    fi
  fi
fi

if command -v "php-fpm${PHP_VERSION}" >/dev/null 2>&1; then
  PHP_FPM_BIN="php-fpm${PHP_VERSION}"
elif command -v php-fpm >/dev/null 2>&1; then
  PHP_FPM_BIN=php-fpm
else
  echo -e "${RED}[Nginx] ERROR: php-fpm${PHP_VERSION} not found.${NC}"
  exit 1
fi

header "[Startup] Starting PHP-FPM"
echo -e "${WHITE}[Startup] ${PHP_FPM_BIN} ($("$PHP_FPM_BIN" -v 2>/dev/null | head -n1))${NC}"
"$PHP_FPM_BIN" -c "$PHP_INI" --fpm-config "$PHP_FPM_CONF" --daemonize

echo -e "${GREEN}[SUCCESS] Web server is running. All services started successfully.${NC}"

curl -fsSL --max-time 5 \
  "https://raw.githubusercontent.com/Vahistar/inBite-motd/refs/heads/main/webhost" \
  2>/dev/null || true
echo "#"
echo "#     Website: http://${SERVER_IP:-0.0.0.0}:${SERVER_PORT:-80}"
echo "#"

exec nginx -c "$NGINX_CONF" -p "$NGINX_PREFIX" -e /home/container/logs/nginx-error.log
