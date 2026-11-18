#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
NC='\033[0m'
WWW="${COMPOSER_DIR:-/home/container/www}"

command -v composer >/dev/null 2>&1 || { echo -e "${YELLOW}[Composer] missing.${NC}"; exit 0; }
cd "$WWW"

[[ -f composer.json ]] && composer install --no-interaction --prefer-dist --optimize-autoloader || true

if [[ -n "${COMPOSER_MODULES:-}" ]]; then
  echo -e "${WHITE}[Composer] ${COMPOSER_MODULES}${NC}"
  # shellcheck disable=SC2086
  composer require ${COMPOSER_MODULES} --no-interaction --working-dir="$WWW" || true
fi

echo -e "${GREEN}[Composer] Done.${NC}"
