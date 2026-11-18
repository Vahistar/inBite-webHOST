#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-/home/container/crontab}"

match_field() {
  local field="$1" value="$2"
  [[ "$field" == "*" ]] && return 0
  if [[ "$field" =~ ^\*/([0-9]+)$ ]]; then
    local step="${BASH_REMATCH[1]}"
    (( value % step == 0 )) && return 0
    return 1
  fi
  [[ "$field" == "$value" ]]
}

while true; do
  min=$(date +%-M 2>/dev/null || date +%M | sed 's/^0//')
  hour=$(date +%-H 2>/dev/null || date +%H | sed 's/^0//')
  dom=$(date +%-d 2>/dev/null || date +%d | sed 's/^0//')
  mon=$(date +%-m 2>/dev/null || date +%m | sed 's/^0//')
  dow=$(date +%w)

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    # shellcheck disable=SC2086
    set -- $line
    [[ $# -lt 6 ]] && continue
    fmin=$1; fhour=$2; fdom=$3; fmon=$4; fdow=$5
    shift 5
    cmd="$*"
    match_field "$fmin" "$min" || continue
    match_field "$fhour" "$hour" || continue
    match_field "$fdom" "$dom" || continue
    match_field "$fmon" "$mon" || continue
    match_field "$fdow" "$dow" || continue
    bash -c "$cmd" || true
  done < "$FILE"

  sleep 60
done
