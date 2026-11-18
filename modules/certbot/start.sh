#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

if ! [[ "${CERTBOT_STATUS:-0}" =~ ^(true|1)$ ]]; then
  exit 0
fi

DOMAIN="${CERTBOT_DOMAIN:-}"
EMAIL="${CERTBOT_EMAIL:-}"
WEBROOT="${CERTBOT_WEBROOT_PATH:-/home/container/www}"
CONFIG_DIR="${CERTBOT_CONFIG_DIR:-/home/container/certbot}"

if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
  echo -e "${RED}[Certbot] CERTBOT_DOMAIN and CERTBOT_EMAIL required.${NC}"
  exit 1
fi

command -v certbot >/dev/null 2>&1 || { echo -e "${RED}[Certbot] missing.${NC}"; exit 1; }

mkdir -p "$CONFIG_DIR" "$WEBROOT"

STAGING_ARGS=()
[[ "${CERTBOT_STAGING:-0}" =~ ^(true|1)$ ]] && STAGING_ARGS+=(--staging)
FORCE_ARGS=()
[[ "${CERTBOT_FORCE_RENEWAL:-0}" =~ ^(true|1)$ ]] && FORCE_ARGS+=(--force-renewal)

if [[ -n "${CERTBOT_DNS_CLOUDFLARE_TOKEN:-}" ]]; then
  CF_INI=$(mktemp)
  printf 'dns_cloudflare_api_token = %s\n' "$CERTBOT_DNS_CLOUDFLARE_TOKEN" > "$CF_INI"
  chmod 600 "$CF_INI"
  if ! certbot certonly \
      --config-dir "$CONFIG_DIR" --work-dir "$CONFIG_DIR/work" --logs-dir /home/container/logs \
      --agree-tos --non-interactive -m "$EMAIL" \
      --dns-cloudflare --dns-cloudflare-credentials "$CF_INI" \
      -d "$DOMAIN" "${STAGING_ARGS[@]}" "${FORCE_ARGS[@]}"; then
    echo -e "${YELLOW}[Certbot] DNS-01 failed, trying webroot...${NC}"
    certbot certonly \
      --config-dir "$CONFIG_DIR" --work-dir "$CONFIG_DIR/work" --logs-dir /home/container/logs \
      --agree-tos --non-interactive -m "$EMAIL" \
      --webroot -w "$WEBROOT" -d "$DOMAIN" "${STAGING_ARGS[@]}" "${FORCE_ARGS[@]}" \
      || { rm -f "$CF_INI"; echo -e "${RED}[Certbot] Failed.${NC}"; exit 1; }
  fi
  rm -f "$CF_INI"
else
  certbot certonly \
    --config-dir "$CONFIG_DIR" --work-dir "$CONFIG_DIR/work" --logs-dir /home/container/logs \
    --agree-tos --non-interactive -m "$EMAIL" \
    --webroot -w "$WEBROOT" -d "$DOMAIN" "${STAGING_ARGS[@]}" "${FORCE_ARGS[@]}" \
    || { echo -e "${RED}[Certbot] Failed.${NC}"; exit 1; }
fi

echo -e "${GREEN}[Certbot] Certs in ${CONFIG_DIR}/live/${DOMAIN}/${NC}"
echo -e "${YELLOW}[Certbot] Enable nginx/conf.d/default-ssl.conf.example if needed.${NC}"
