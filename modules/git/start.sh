#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=../_lib/console.sh
source "$(cd "$(dirname "$0")/.." && pwd)/_lib/console.sh"

GIT_DIR="${GIT_DIR:-/home/container/www}"

if ! [[ "${GIT_STATUS:-false}" =~ ^(true|1)$ ]]; then
  exit 0
fi

command -v git >/dev/null 2>&1 || { log_warn "git not installed"; exit 0; }
[[ -d "$GIT_DIR/.git" ]] || { log_warn "No repo in $GIT_DIR"; exit 0; }

cd "$GIT_DIR"

ASKPASS=""
if [[ -n "${USERNAME:-}" && -n "${ACCESS_TOKEN:-}" ]]; then
  ASKPASS=$(mktemp)
  cat > "$ASKPASS" <<'EOF'
#!/bin/bash
case "$1" in
  *Username*) echo "$GIT_ASKPASS_USER" ;;
  *Password*) echo "$GIT_ASKPASS_PASS" ;;
esac
EOF
  chmod 700 "$ASKPASS"
  export GIT_ASKPASS_USER="$USERNAME"
  export GIT_ASKPASS_PASS="$ACCESS_TOKEN"
  export GIT_ASKPASS="$ASKPASS"
  export GIT_TERMINAL_PROMPT=0
  CURRENT_URL=$(git config --get remote.origin.url || true)
  if [[ -n "$CURRENT_URL" ]]; then
    CLEAN=$(echo "$CURRENT_URL" | sed -E 's|https://[^@]+@|https://|')
    git remote set-url origin "$CLEAN"
  fi
fi

info "pulling..."
if git pull --ff-only; then
  ok "updated"
else
  err "git pull failed"
fi

[[ -n "$ASKPASS" && -f "$ASKPASS" ]] && rm -f "$ASKPASS"
unset GIT_ASKPASS GIT_ASKPASS_USER GIT_ASKPASS_PASS || true
