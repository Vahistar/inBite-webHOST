#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

mkdir -p /home/container/tmp /home/container/logs /home/container/tmp/fastcgi_cache
find /home/container/tmp -mindepth 1 -mtime +1 -delete 2>/dev/null || true
find /home/container/logs -type f -name "*.log" -mtime +14 -delete 2>/dev/null || true
mkdir -p /home/container/tmp/fastcgi_cache
echo -e "${GREEN}[LogCleaner] Done.${NC}"
