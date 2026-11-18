#!/usr/bin/env bash
# Shared console helpers for inBite webHOST
# info = white · success = green · warn = yellow · error = red

WHITE='\033[1;37m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

PREFIX='[webHOST]'

clear_console() {
  printf '\033c' 2>/dev/null || clear 2>/dev/null || true
}

log_info()  { echo -e "${WHITE}${PREFIX}${NC} ${WHITE}$1${NC}"; }
log_ok()    { echo -e "${GREEN}${PREFIX}${NC} ${GREEN}$1${NC}"; }
log_warn()  { echo -e "${YELLOW}${PREFIX}${NC} ${YELLOW}$1${NC}"; }
log_err()   { echo -e "${RED}${PREFIX}${NC} ${RED}$1${NC}"; }
log_step()  { echo -e "${WHITE}→ $1${NC}"; }

ok()   { echo -e "  ${GREEN}ok${NC} ${WHITE}· $1${NC}"; }
info() { echo -e "  ${WHITE}$1${NC}"; }
warn() { echo -e "  ${YELLOW}$1${NC}"; }
err()  { echo -e "  ${RED}$1${NC}"; }
