#!/usr/bin/env bash
set -euo pipefail

sed -i 's/\r$//' "$0" 2>/dev/null || true
find modules -type f -name "*.sh" -exec sed -i 's/\r$//' {} + 2>/dev/null || true

# shellcheck source=modules/_lib/console.sh
source "$(cd "$(dirname "$0")" && pwd)/modules/_lib/console.sh"

trap 'log_err "Error on line $LINENO"' ERR
shopt -s nullglob

module_label() {
  case "$1" in
    logcleaner)  echo "Log Cleaner" ;;
    cloudflared) echo "Cloudflared" ;;
    certbot)     echo "Certbot" ;;
    composer)    echo "Composer" ;;
    cron)        echo "Cron" ;;
    git)         echo "Git" ;;
    nginx)       echo "Nginx" ;;
    *)           echo "${1^}" ;;
  esac
}

is_enabled() { [[ "${1:-}" =~ ^(true|1)$ ]]; }

clear_console
log_info "Starting inBite webHOST..."

PHP_VERSION="${PHP_VERSION:-8.4}"
if command -v "php${PHP_VERSION}" >/dev/null 2>&1; then
  UP=$(php${PHP_VERSION} -d "display_errors=0" -r 'echo ini_get("session.upload_progress.enabled") ? "1" : "0";' 2>/dev/null || echo "?")
  if [[ "$UP" == "1" ]]; then
    log_warn "session.upload_progress is ON (should be Off)"
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
  log_step "PHP extensions"
  rm -rf "$PHP_CONF_ACTIVE"
  mkdir -p "$PHP_CONF_ACTIVE"
  linked=0
  disabled=0
  for ini in "$PHP_CONF_SOURCE"/fpm/conf.d/*.ini "$PHP_CONF_SOURCE"/cli/conf.d/*.ini; do
    [[ -e "$ini" ]] || continue
    name=$(basename "$ini")
    [[ -e "$PHP_CONF_ACTIVE/$name" ]] && continue
    ext="${name#*-}"; ext="${ext%.ini}"; ext="${ext,,}"
    if [[ " ${disabled_list} " == *" ${ext} "* ]]; then
      info "disabled: ${ext}"
      disabled=$((disabled + 1))
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
    msg="${linked} active"
    (( disabled > 0 )) && msg+=", ${disabled} disabled"
    ok "$msg"
  else
    rm -rf "$PHP_CONF_ACTIVE"
  fi
fi

if is_enabled "${CLOUDFLARED_STATUS:-0}" && is_enabled "${CERTBOT_STATUS:-0}"; then
  if [[ -z "${CERTBOT_DNS_CLOUDFLARE_TOKEN:-}" ]]; then
    log_warn "Tunnel + Certbot HTTP-01 may conflict on the same hostname"
  fi
fi

if is_enabled "${LOGCLEANER_STATUS:-1}" && [[ -x modules/logcleaner/start.sh ]]; then
  log_step "$(module_label logcleaner)"
  modules/logcleaner/start.sh
fi

if is_enabled "${GIT_STATUS:-0}" && [[ -x modules/git/start.sh ]]; then
  log_step "$(module_label git)"
  modules/git/start.sh
fi

for module_dir in modules/*/; do
  module_name=$(basename "$module_dir")
  [[ "$module_name" =~ ^(_lib|logcleaner|git|nginx|wordpress)$ ]] && continue
  start_script="${module_dir}start.sh"
  status_var="${module_name^^}_STATUS"
  status="${!status_var:-false}"
  is_enabled "$status" || continue
  if [[ -x "$start_script" ]]; then
    log_step "$(module_label "$module_name")"
    "$start_script"
  fi
done

if is_enabled "${NGINX_STATUS:-1}" && [[ -x modules/nginx/start.sh ]]; then
  log_step "$(module_label nginx)"
  exec modules/nginx/start.sh
fi

echo
log_ok "Done (nginx skipped)."
echo
