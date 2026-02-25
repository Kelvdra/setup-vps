# 🚀 VPS Auto Setup Script

Script otomatis untuk setup VPS Ubuntu/Debian dengan:

- ✅ Node.js (hingga versi 26 / latest / LTS)
- ✅ NVM (Node Version Manager)
- ✅ NPM (latest)
- ✅ Yarn (via Corepack)
- ✅ PM2 (Process Manager)
- ✅ Nginx
- ✅ FFmpeg
- ✅ Firewall (UFW auto-config)

Cocok untuk deployment backend, bot, API server, atau web app production.

---

## 📦 Fitur

- Install Node.js versi:
  - `lts`
  - `latest`
  - atau manual: `18, 20, 22, 24, 25, 26`
- Auto set default Node version
- Install Yarn modern (Corepack)
- Install PM2 global
- Install & aktifkan Nginx
- Install FFmpeg
- Basic firewall setup (OpenSSH + Nginx)
- Stop otomatis jika ada error (`set -e`)

---

## 🖥️ Support OS

- Ubuntu 20.04+
- Ubuntu 22.04+
- Ubuntu 24.04+
- Debian 11+

---

## ⚙️ Cara Install

### 1️⃣ Clone Repository

~~~bash
git clone https://github.com/USERNAME/REPO.git
cd REPO
~~~

### 2️⃣ Berikan Permission

~~~bash
chmod +x setup.sh
~~~

### 3️⃣ Jalankan Script

~~~bash
sudo bash setup.sh
~~~

---

## 🔢 Pilihan Versi Node.js

Saat dijalankan, kamu akan diminta memilih versi:

~~~text
lts      → Install versi LTS terbaru
latest   → Install versi paling baru (misal 25/26)
18–26    → Install versi spesifik
~~~

---

## 📦 Yang Akan Terinstall

| Package   | Keterangan |
|------------|------------|
| Node.js | Runtime JavaScript |
| NPM | Package Manager |
| Yarn | Package Manager modern |
| PM2 | Process Manager production |
| Nginx | Web Server |
| FFmpeg | Media processing |
| UFW | Basic firewall config |

---

## 🔥 Cek Versi Setelah Install

~~~bash
node -v
npm -v
yarn -v
pm2 -v
ffmpeg -version
~~~

---

## 🛡 Firewall Rules

Script otomatis membuka:

- OpenSSH
- Nginx Full (HTTP + HTTPS)

Jika UFW tersedia, firewall akan otomatis diaktifkan.

---

## 🧠 Kenapa Pakai Corepack untuk Yarn?

Node.js modern (>=16) sudah include Corepack.

~~~bash
corepack enable
corepack prepare yarn@stable --activate
~~~

Lebih stabil dibanding `npm install -g yarn`.

---

## 📌 Notes

- Jalankan sebagai `root` atau pakai `sudo`
- Direkomendasikan minimal RAM 1GB
- Script akan berhenti jika terjadi error
- Aman untuk fresh VPS

---

## 📜 License

Free to use & modify.
