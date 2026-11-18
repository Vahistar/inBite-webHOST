#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../_lib/console.sh
source "$(cd "$(dirname "$0")/.." && pwd)/_lib/console.sh"

CRON_FILE="${CRON_CONFIG_FILE:-/home/container/crontab}"

if ! [[ "${CRON_STATUS:-0}" =~ ^(true|1)$ ]]; then
  exit 0
fi

if [[ ! -f "$CRON_FILE" ]]; then
  printf '%s\n' '# */5 * * * * cd /home/container/www && php -f wp-cron.php >/dev/null 2>&1' > "$CRON_FILE"
  warn "created ${CRON_FILE}"
fi

chmod +x /home/container/modules/cron/cron-engine.sh
nohup bash /home/container/modules/cron/cron-engine.sh "$CRON_FILE" \
  >/home/container/logs/cron.log 2>&1 &
echo $! > /home/container/tmp/cron.pid
ok "started (pid $(cat /home/container/tmp/cron.pid))"
