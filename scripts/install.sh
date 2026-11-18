#!/bin/bash
set -euo pipefail

cd /mnt/server || exit 1

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq git curl ca-certificates unzip xz-utils wget >/dev/null 2>&1 \
  || { echo "[ERROR] Failed to install packages"; exit 1; }

REPO_URL="${EGG_REPO_URL:-https://github.com/Vahistar/BiteHost-WebHost}"
BRANCH_REF="${EGG_REPO_BRANCH:-main}"

echo "[SETUP] Cloning ${REPO_URL} (${BRANCH_REF})..."
rm -rf /mnt/server/gtemp
git clone --depth 1 --branch "${BRANCH_REF}" "${REPO_URL}" /mnt/server/gtemp \
  || { echo "[ERROR] Failed to clone egg repository"; exit 1; }

cp -a /mnt/server/gtemp/nginx /mnt/server/
cp -a /mnt/server/gtemp/php /mnt/server/
cp -a /mnt/server/gtemp/modules /mnt/server/
cp -a /mnt/server/gtemp/www /mnt/server/
cp /mnt/server/gtemp/start-modules.sh /mnt/server/
cp /mnt/server/gtemp/LICENSE /mnt/server/ 2>/dev/null || true
chmod +x /mnt/server/start-modules.sh
find /mnt/server/modules -type f -name "*.sh" -exec chmod +x {} \;
rm -rf /mnt/server/gtemp

mkdir -p /mnt/server/tmp /mnt/server/logs /mnt/server/php/sessions /mnt/server/tmp/fastcgi_cache

is_true() { [[ "${1:-}" == "1" || "${1:-}" == "true" || "${1:-}" == "TRUE" ]]; }

WP=0; NL=0
is_true "${WORDPRESS:-0}" && WP=1
is_true "${NAMELESSMC:-0}" && NL=1

if [[ "$WP" -eq 1 && "$NL" -eq 1 ]]; then
  echo "[ERROR] Enable only one of WORDPRESS or NAMELESSMC, not both."
  exit 1
fi

if [[ "$WP" -eq 1 ]]; then
  echo "[SETUP] Installing WordPress..."
  rm -rf /mnt/server/www/*
  cd /mnt/server/www
  curl -fL -o latest.tar.gz https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz
  mv wordpress/* .
  rm -rf wordpress latest.tar.gz
  cp /mnt/server/nginx/conf.d/wordpress.conf.example /mnt/server/nginx/conf.d/default.conf
  if [[ ! -f /mnt/server/crontab ]]; then
    cat > /mnt/server/crontab <<'EOF'
*/5 * * * * cd /home/container/www && php -f wp-cron.php >/dev/null 2>&1
EOF
  fi
  echo "[DONE] WordPress installed. Visit http://ip:port/wp-admin"
  exit 0
fi

if [[ "$NL" -eq 1 ]]; then
  echo "[SETUP] Installing NamelessMC..."
  rm -rf /mnt/server/www/*
  cd /mnt/server/www
  curl -fL "https://github.com/NamelessMC/Nameless/releases/latest/download/nameless-deps-dist.tar.xz" \
    | tar -xJ -C /mnt/server/www
  cp /mnt/server/nginx/conf.d/namelessmc.conf.example /mnt/server/nginx/conf.d/default.conf
  echo "[DONE] NamelessMC installed."
  exit 0
fi

if is_true "${USER_UPLOAD:-0}"; then
  echo "[SETUP] USER_UPLOAD enabled."
  exit 0
fi

GIT_ADDRESS="${GIT_ADDRESS:-}"
if [[ -z "$GIT_ADDRESS" ]]; then
  echo "[SETUP] Default landing page ready."
  exit 0
fi

if [[ "${GIT_ADDRESS}" != *.git ]]; then
  GIT_ADDRESS="${GIT_ADDRESS}.git"
fi

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
fi

rm -rf /mnt/server/www/*
mkdir -p /mnt/server/www
cd /mnt/server/www

BRANCH="${GIT_BRANCH:-${BRANCH:-}}"
echo "[Git] Cloning ${GIT_ADDRESS}..."
if [[ -n "$BRANCH" ]]; then
  git clone --depth 1 --single-branch --branch "$BRANCH" "$GIT_ADDRESS" .
else
  git clone --depth 1 "$GIT_ADDRESS" .
fi

ORIGIN=$(git config --get remote.origin.url || true)
if [[ -n "$ORIGIN" ]]; then
  CLEAN=$(echo "$ORIGIN" | sed -E 's|https://[^@]+@|https://|')
  git remote set-url origin "$CLEAN"
fi

[[ -n "$ASKPASS" && -f "$ASKPASS" ]] && rm -f "$ASKPASS"
unset GIT_ASKPASS GIT_ASKPASS_USER GIT_ASKPASS_PASS || true

echo "[DONE] Installation complete."
