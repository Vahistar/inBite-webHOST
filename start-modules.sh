#!/usr/bin/env bash
set -euo pipefail

sed -i 's/\r$//' "$0" 2>/dev/null || true
find modules -type f -name "*.sh" -exec sed -i 's/\r$//' {} + 2>/dev/null || true

trap 'echo -e "\033[0;31m[Orchestrator] Error on line $LINENO\033[0m"' ERR
shopt -s nullglob

BLUE='\033[0;34m'
BOLD_BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
NC='\033[0m'

header() {
  echo -e "\n${BLUE}───────────────────────────────────────────────${NC}"
  echo -e "${BOLD_BLUE}[Orchestrator] $1${NC}"
}

is_enabled() { [[ "${1:-}" =~ ^(true|1)$ ]]; }

echo -e "\n${BOLD_BLUE}[Orchestrator] Starting...${NC}"

PHP_VERSION="${PHP_VERSION:-8.4}"
if command -v "php${PHP_VERSION}" >/dev/null 2>&1; then
  UP=$(php${PHP_VERSION} -d "display_errors=0" -r 'echo ini_get("session.upload_progress.enabled") ? "1" : "0";' 2>/dev/null || echo "?")
  if [[ "$UP" == "1" ]]; then
    echo -e "${YELLOW}[Security] session.upload_progress is ON (should be Off).${NC}"
  fi
fi

PHP_DISABLED_EXTENSIONS="${PHP_DISABLED_EXTENSIONS:-}"
PHP_CONF_SOURCE="${PHP_CONF_SOURCE:-/etc/php/${PHP_VERSION}}"
PHP_CONF_USER="${PWD}/php/conf.d"
PHP_CONF_ACTIVE="${PWD}/php/conf.d-active"
disabled_list="${PHP_DISABLED_EXTENSIONS//,/ }"
disabled_list="${disabled_list,,}"
user_inis=("$PHP_CONF_USER"/*.ini)

if [[ -n "${disabled_list// /}" || ${#user_inis[@]} -gt 0 ]]; then
  header "Configuring PHP extensions"
  rm -rf "$PHP_CONF_ACTIVE"
  mkdir -p "$PHP_CONF_ACTIVE"
  linked=0
  for ini in "$PHP_CONF_SOURCE"/fpm/conf.d/*.ini "$PHP_CONF_SOURCE"/cli/conf.d/*.ini; do
    [[ -e "$ini" ]] || continue
    name=$(basename "$ini")
    [[ -e "$PHP_CONF_ACTIVE/$name" ]] && continue
    ext="${name#*-}"; ext="${ext%.ini}"; ext="${ext,,}"
    if [[ " ${disabled_list} " == *" ${ext} "* ]]; then
      echo -e "${WHITE}[PHP] Disabled: ${ext}${NC}"
      continue
    fi
    ln -s "$ini" "$PHP_CONF_ACTIVE/$name"
    linked=$((linked + 1))
  done
  for ini in "${user_inis[@]}"; do
    [[ -e "$ini" ]] || continue
    rm -f "$PHP_CONF_ACTIVE/$(basename "$ini")"
    cp "$ini" "$PHP_CONF_ACTIVE/"
  done
  if (( linked > 0 )); then
    export PHP_INI_SCAN_DIR="$PHP_CONF_ACTIVE"
  else
    rm -rf "$PHP_CONF_ACTIVE"
  fi
fi

if is_enabled "${CLOUDFLARED_STATUS:-0}" && is_enabled "${CERTBOT_STATUS:-0}"; then
  if [[ -z "${CERTBOT_DNS_CLOUDFLARE_TOKEN:-}" ]]; then
    echo -e "${YELLOW}[Domains] Tunnel + Certbot HTTP-01 may conflict on the same hostname.${NC}"
  fi
fi

if is_enabled "${LOGCLEANER_STATUS:-1}" && [[ -x modules/logcleaner/start.sh ]]; then
  header "logcleaner"
  modules/logcleaner/start.sh
fi

if is_enabled "${GIT_STATUS:-0}" && [[ -x modules/git/start.sh ]]; then
  header "git"
  modules/git/start.sh
fi

for module_dir in modules/*/; do
  module_name=$(basename "$module_dir")
  [[ "$module_name" =~ ^(logcleaner|git|nginx|wordpress)$ ]] && continue
  start_script="${module_dir}start.sh"
  status_var="${module_name^^}_STATUS"
  status="${!status_var:-false}"
  is_enabled "$status" || continue
  if [[ -x "$start_script" ]]; then
    header "$module_name"
    "$start_script"
  fi
done

if is_enabled "${NGINX_STATUS:-1}" && [[ -x modules/nginx/start.sh ]]; then
  header "nginx"
  exec modules/nginx/start.sh
fi

echo -e "\n${GREEN}[Orchestrator] Done (nginx skipped).${NC}\n"
