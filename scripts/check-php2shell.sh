#!/bin/bash
set -euo pipefail

PHP_MAJOR_MINOR="${1:-}"
if [[ -z "$PHP_MAJOR_MINOR" ]]; then
  echo "Usage: $0 <major.minor>"
  exit 2
fi

BIN="php${PHP_MAJOR_MINOR}"
if ! command -v "$BIN" >/dev/null 2>&1; then
  BIN=php
fi

FULL=$("$BIN" -r 'echo PHP_VERSION;' 2>/dev/null || true)
if [[ -z "$FULL" ]]; then
  echo "[check] ERROR: could not read PHP_VERSION"
  exit 1
fi

VER=$(echo "$FULL" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
MAJOR=$(echo "$VER" | cut -d. -f1)
MINOR=$(echo "$VER" | cut -d. -f2)
PATCH=$(echo "$VER" | cut -d. -f3)

min_ok() {
  local need_major=$1 need_minor=$2 need_patch=$3
  if (( MAJOR > need_major )); then return 0; fi
  if (( MAJOR < need_major )); then return 1; fi
  if (( MINOR > need_minor )); then return 0; fi
  if (( MINOR < need_minor )); then return 1; fi
  (( PATCH >= need_patch ))
}

case "${MAJOR}.${MINOR}" in
  8.2) min_ok 8 2 35 || { echo "[check] FAIL: need >= 8.2.35, got $FULL"; exit 1; } ;;
  8.3) min_ok 8 3 36 || { echo "[check] FAIL: need >= 8.3.36, got $FULL"; exit 1; } ;;
  8.4) min_ok 8 4 27 || { echo "[check] FAIL: need >= 8.4.27, got $FULL"; exit 1; } ;;
  8.5) min_ok 8 5 12 || { echo "[check] FAIL: need >= 8.5.12, got $FULL"; exit 1; } ;;
  *)
    echo "[check] FAIL: unsupported branch ${MAJOR}.${MINOR} ($FULL)"
    exit 1
    ;;
esac

UP=$("$BIN" -d display_errors=0 -r 'echo ini_get("session.upload_progress.enabled") ? "1" : "0";')
if [[ "$UP" == "1" ]]; then
  echo "[check] FAIL: session.upload_progress.enabled must be Off"
  exit 1
fi

echo "[check] OK: PHP $FULL, upload_progress Off"
