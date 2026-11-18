#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
WHITE='\033[0;37m'
NC='\033[0m'

GIT_DIR="${GIT_DIR:-/home/container/www}"

if ! [[ "${GIT_STATUS:-false}" =~ ^(true|1)$ ]]; then
  exit 0
fi

command -v git >/dev/null 2>&1 || { echo -e "${YELLOW}[Git] git not installed.${NC}"; exit 0; }
[[ -d "$GIT_DIR/.git" ]] || { echo -e "${YELLOW}[Git] No repo in $GIT_DIR.${NC}"; exit 0; }

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

echo -e "${WHITE}[Git] Pulling...${NC}"
if git pull --ff-only; then
  echo -e "${GREEN}[Git] Updated.${NC}"
else
  echo -e "${RED}[Git] Pull failed.${NC}"
fi

[[ -n "$ASKPASS" && -f "$ASKPASS" ]] && rm -f "$ASKPASS"
unset GIT_ASKPASS GIT_ASKPASS_USER GIT_ASKPASS_PASS || true
