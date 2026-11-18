#!/bin/bash
set -euo pipefail

cd /home/container

# Expand Pterodactyl {{VAR}} placeholders in STARTUP
MODIFIED_STARTUP=$(echo "${STARTUP:-./start-modules.sh}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

# Quiet prompt — start-modules.sh clears the console next
eval "${MODIFIED_STARTUP}"
