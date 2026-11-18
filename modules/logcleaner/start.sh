#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../_lib/console.sh
source "$(cd "$(dirname "$0")/.." && pwd)/_lib/console.sh"

mkdir -p /home/container/tmp /home/container/logs /home/container/tmp/fastcgi_cache
find /home/container/tmp -mindepth 1 -mtime +1 -delete 2>/dev/null || true
find /home/container/logs -type f -name "*.log" -mtime +14 -delete 2>/dev/null || true
mkdir -p /home/container/tmp/fastcgi_cache
ok "cleaned tmp & old logs"
