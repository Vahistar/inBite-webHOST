#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../_lib/console.sh
source "$(cd "$(dirname "$0")/.." && pwd)/_lib/console.sh"

PHP_VERSION="${PHP_VERSION:-8.4}"
PHP_INI="${PHP_INI:-/home/container/php/php.ini}"
PHP_FPM_CONF="${PHP_FPM_CONF:-/home/container/php/php-fpm.conf}"
NGINX_CONF="${NGINX_CONF:-/home/container/nginx/nginx.conf}"
NGINX_PREFIX="${NGINX_PREFIX:-/home/container}"

mkdir -p \
  "${NGINX_PREFIX}/tmp" \
  "${NGINX_PREFIX}/tmp/client_body" \
  "${NGINX_PREFIX}/tmp/proxy" \
  "${NGINX_PREFIX}/tmp/fastcgi" \
  "${NGINX_PREFIX}/tmp/uwsgi" \
  "${NGINX_PREFIX}/tmp/scgi" \
  "${NGINX_PREFIX}/tmp/fastcgi_cache" \
  "${NGINX_PREFIX}/logs" \
  "${NGINX_PREFIX}/php/sessions"

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
  log_err "php-fpm${PHP_VERSION} not found"
  exit 1
fi

PHP_VER_SHORT=$("$PHP_FPM_BIN" -v 2>/dev/null | head -n1 | awk '{print $2}')
info "PHP-FPM ${PHP_VER_SHORT:-$PHP_VERSION}"
"$PHP_FPM_BIN" -c "$PHP_INI" --fpm-config "$PHP_FPM_CONF" --daemonize
ok "nginx + php-fpm"

SITE_URL="http://${SERVER_IP:-0.0.0.0}:${SERVER_PORT:-80}"

# Egg startup detector looks for this exact marker
echo -e "${GREEN}[OK] All services started${NC}"

# Clean console, then show MOTD from GitHub (no local fallback)
clear_console
curl -fsSL --max-time 5 \
  "https://raw.githubusercontent.com/Vahistar/inBite-motd/refs/heads/main/webhost" \
  2>/dev/null || true
echo -e "${WHITE}#     Website: ${SITE_URL}${NC}"
echo -e "${WHITE}#${NC}"
echo

exec nginx -c "$NGINX_CONF" -p "$NGINX_PREFIX" -e /home/container/logs/nginx-error.log
