#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

if ! [[ "${CLOUDFLARED_STATUS:-0}" =~ ^(true|1)$ ]]; then
  exit 0
fi

if [[ -z "${CLOUDFLARED_TOKEN:-}" ]]; then
  echo -e "${RED}[Cloudflared] CLOUDFLARED_TOKEN is empty.${NC}"
  exit 1
fi

if ! command -v cloudflared >/dev/null 2>&1; then
  echo -e "${RED}[Cloudflared] binary missing.${NC}"
  exit 1
fi

echo -e "${YELLOW}[Cloudflared] Map hostname to http://127.0.0.1:${SERVER_PORT:-80}${NC}"
nohup cloudflared tunnel --no-autoupdate run --token "${CLOUDFLARED_TOKEN}" \
  >/home/container/logs/cloudflared.log 2>&1 &
echo $! > /home/container/tmp/cloudflared.pid
echo -e "${GREEN}[Cloudflared] Started (pid $(cat /home/container/tmp/cloudflared.pid)).${NC}"
