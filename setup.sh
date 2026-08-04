#!/bin/bash
# Updated setup script by Copilot (for Kelvdra/setup-vps)
# Improvements:
# - safer bash flags (set -euo pipefail)
# - check for root
# - non-interactive default to LTS when no input provided or when run with NODE_VERSION env/arg
# - retry logic for apt when dpkg/apt lock present
# - install and enable ufw if missing and configure common rules
# - more robust NVM loading
# - graceful final status output with existence checks

set -euo pipefail
IFS=$'\n\t'

LOGPREFIX="[setup-vps]"

# Simple logger
log() { echo "$LOGPREFIX $*"; }
err() { echo "$LOGPREFIX ERROR: $*" >&2; }

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
  err "Script harus dijalankan sebagai root. Jalankan 'sudo bash setup.sh'"
  exit 1
fi

# Wait for apt/dpkg locks to be released (simple retry)
wait_for_apt() {
  local retries=30
  local count=0
  while (fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/dpkg/lock >/dev/null 2>&1); do
    if (( count >= retries )); then
      err "Timeout menunggu apt/dpkg lock"
      return 1
    fi
    log "Menunggu apt lock... (try $((count+1))/$retries)"
    sleep 2
    count=$((count+1))
  done
}

# Noninteractive frontend for apt
export DEBIAN_FRONTEND=noninteractive

log "[1/8] Update dan upgrade sistem..."
wait_for_apt
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y || true
apt-get autoremove -y || true

log "[2/8] Install dependensi dasar..."
apt-get install -y --no-install-recommends curl git ca-certificates gnupg lsb-release software-properties-common build-essential

log "[3/8] Install FFmpeg..."
apt-get install -y --no-install-recommends ffmpeg

log "[4/8] Install/konfigurasi NVM (Node Version Manager)..."
NVM_VERSION="v0.39.7"
# Install nvm if not already installed
if [[ ! -d "$HOME/.nvm" && ! -f "/root/.nvm/nvm.sh" ]]; then
  log "Mengunduh dan memasang nvm $NVM_VERSION"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash || true
else
  log "NVM sudah terpasang (melewati pemasangan)"
fi

# Load nvm in this shell (try a few common locations)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"
elif [[ -s "/root/.nvm/nvm.sh" ]]; then
  # shellcheck source=/dev/null
  source "/root/.nvm/nvm.sh"
else
  log "Peringatan: nvm tidak ditemukan setelah pemasangan. Pastikan shell login memuat nvm." 
fi

# Determine Node version to install.
# Priority: CLI arg $1 -> environment NODE_VERSION -> interactive input -> default "lts"
NODE_VERSION_CLI="${1:-}" || true
NODE_VERSION_ENV="${NODE_VERSION:-}" || true
NODE_VERSION_TO_USE=""

if [[ -n "$NODE_VERSION_CLI" ]]; then
  NODE_VERSION_TO_USE="$NODE_VERSION_CLI"
elif [[ -n "$NODE_VERSION_ENV" ]]; then
  NODE_VERSION_TO_USE="$NODE_VERSION_ENV"
else
  # If running non-interactive (no tty), default to lts
  if [[ ! -t 0 ]]; then
    NODE_VERSION_TO_USE="lts"
  else
    echo
    echo "[5/8] Pilih versi Node.js (kosong -> lts):"
    echo "  lts     -> install versi LTS terbaru"
    echo "  latest  -> install versi paling baru (current)"
    echo "  atau isi manual: 18, 20, 22, 24, 25, 26"
    echo
    read -r -p "Masukkan versi Node.js: " NODE_VERSION_INPUT || true
    NODE_VERSION_TO_USE="${NODE_VERSION_INPUT:-lts}"
  fi
fi

log "Memasang Node.js: $NODE_VERSION_TO_USE"
if [[ "$NODE_VERSION_TO_USE" == "lts" ]]; then
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
elif [[ "$NODE_VERSION_TO_USE" == "latest" || "$NODE_VERSION_TO_USE" == "node" ]]; then
  nvm install node
  nvm use node
  nvm alias default node
else
  # allow numeric major versions like 18,20,22,... or full versions
  nvm install "$NODE_VERSION_TO_USE"
  nvm use "$NODE_VERSION_TO_USE"
  nvm alias default "$NODE_VERSION_TO_USE"
fi

log "[6/8] Update npm & aktifkan Corepack (jika tersedia)..."
# upgrade npm if available
if command -v npm >/dev/null 2>&1; then
  npm install -g npm@latest || true
fi

# enable corepack if node/npm include it
if command -v corepack >/dev/null 2>&1; then
  corepack enable || true
  corepack prepare yarn@stable --activate || true
fi

log "[7/8] Install PM2 (global)..."
npm install -g pm2 || true

log "[8/8] Install Nginx dan UFW..."
apt-get install -y --no-install-recommends nginx || true

# Install ufw if not present and open common ports
if ! command -v ufw >/dev/null 2>&1; then
  log "Menginstal ufw (firewall)"
  apt-get install -y --no-install-recommends ufw || true
fi

if command -v ufw >/dev/null 2>&1; then
  log "Konfigurasi ufw: izinkan OpenSSH dan Nginx Full"
  ufw allow OpenSSH || true
  ufw allow 'Nginx Full' || true
  # Enable silently
  echo "y" | ufw enable >/dev/null 2>&1 || true
fi

# Optional: enable and start services
if command -v systemctl >/dev/null 2>&1; then
  systemctl enable --now nginx || true
fi

log "\n===================================="
log "         SETUP SELESAI"
log "===================================="
# Print versions if commands exist
if command -v node >/dev/null 2>&1; then
  log " Node.js : $(node -v)"
fi
if command -v npm >/dev/null 2>&1; then
  log " NPM     : $(npm -v)"
fi
if command -v yarn >/dev/null 2>&1; then
  log " Yarn    : $(yarn -v)"
fi
if command -v pm2 >/dev/null 2>&1; then
  log " PM2     : $(pm2 -v)"
fi
if command -v ffmpeg >/dev/null 2>&1; then
  log " FFmpeg  : $(ffmpeg -version | head -n 1)"
fi
log "===================================="

exit 0
