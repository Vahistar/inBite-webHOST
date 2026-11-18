#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../_lib/console.sh
source "$(cd "$(dirname "$0")/.." && pwd)/_lib/console.sh"

WWW="${COMPOSER_DIR:-/home/container/www}"

command -v composer >/dev/null 2>&1 || { log_warn "composer missing"; exit 0; }
cd "$WWW"

[[ -f composer.json ]] && composer install --no-interaction --prefer-dist --optimize-autoloader || true

if [[ -n "${COMPOSER_MODULES:-}" ]]; then
  info "require: ${COMPOSER_MODULES}"
  # shellcheck disable=SC2086
  composer require ${COMPOSER_MODULES} --no-interaction --working-dir="$WWW" || true
fi

ok "dependencies ready"
