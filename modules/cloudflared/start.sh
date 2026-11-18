#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../_lib/console.sh
source "$(cd "$(dirname "$0")/.." && pwd)/_lib/console.sh"

if ! [[ "${CLOUDFLARED_STATUS:-0}" =~ ^(true|1)$ ]]; then
  exit 0
fi

if [[ -z "${CLOUDFLARED_TOKEN:-}" ]]; then
  log_err "CLOUDFLARED_TOKEN is empty"
  exit 1
fi

if ! command -v cloudflared >/dev/null 2>&1; then
  log_err "cloudflared binary missing"
  exit 1
fi

info "map host → http://127.0.0.1:${SERVER_PORT:-80}"
nohup cloudflared tunnel --no-autoupdate run --token "${CLOUDFLARED_TOKEN}" \
  >/home/container/logs/cloudflared.log 2>&1 &
echo $! > /home/container/tmp/cloudflared.pid
ok "started (pid $(cat /home/container/tmp/cloudflared.pid))"
