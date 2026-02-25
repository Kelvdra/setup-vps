#!/bin/bash
# Script by balxzzy - Full Updated Version

clear
echo "===================================="
echo "         SETUP VPS AUTO"
echo "===================================="
echo

set -e

echo "[1/8] Update dan upgrade sistem..."
apt update -y && apt upgrade -y

echo "[2/8] Install dependensi dasar..."
apt install -y curl git build-essential software-properties-common

echo "[3/8] Install FFmpeg..."
apt install -y ffmpeg

echo "[4/8] Install NVM..."
export NVM_VERSION="v0.39.7"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"

echo
echo "[5/8] Pilih versi Node.js"
echo "Ketik:"
echo "  lts     -> install versi LTS terbaru"
echo "  latest  -> install versi paling baru (25/26)"
echo "  atau isi manual: 18, 20, 22, 24, 25, 26"
echo

while true; do
    read -p "Masukkan versi Node.js: " NODE_VERSION

    if [[ "$NODE_VERSION" == "lts" ]]; then
        nvm install --lts
        nvm use --lts
        nvm alias default 'lts/*'
        break

    elif [[ "$NODE_VERSION" == "latest" ]]; then
        nvm install node
        nvm use node
        nvm alias default node
        break

    elif [[ "$NODE_VERSION" =~ ^(18|20|21|22|23|24|25|26)$ ]]; then
        nvm install $NODE_VERSION
        nvm use $NODE_VERSION
        nvm alias default $NODE_VERSION
        break

    else
        echo "Versi tidak valid."
    fi
done

echo "[6/8] Update npm & aktifkan Corepack (Yarn modern)..."
npm install -g npm@latest

# Aktifkan corepack untuk yarn & pnpm
corepack enable
corepack prepare yarn@stable --activate

echo "[7/8] Install PM2..."
npm install -g pm2

echo "[8/8] Install Nginx..."
apt install -y nginx

# Optional Firewall
if command -v ufw &> /dev/null; then
    echo "Konfigurasi firewall..."
    ufw allow OpenSSH
    ufw allow 'Nginx Full'
    ufw --force enable
fi

echo
echo "===================================="
echo "         SETUP SELESAI"
echo "===================================="
echo " Node.js : $(node -v)"
echo " NPM     : $(npm -v)"
echo " Yarn    : $(yarn -v)"
echo " PM2     : $(pm2 -v)"
echo " FFmpeg  : $(ffmpeg -version | head -n 1)"
echo "===================================="
