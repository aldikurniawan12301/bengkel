# Panduan Operasional & Deployment Server BengkelPintar

Dokumen ini memuat panduan lengkap menjalankan server API di lingkungan lokal (laptop demo) serta prosedur pemindahan dan operasional di VPS (produksi) sesuai `docs/PRD.md` bagian 8.6.

---

## 1. Lingkungan Lokal (Laptop Demo)

Pada tahap demo/skripsi, server API dan PostgreSQL berjalan di laptop dengan mode jaringan lokal (Wi-Fi / hotspot):

### Persyaratan
- Python 3.11+ (dengan virtual environment)
- PostgreSQL 15+ (lokal)
- Berkas model machine learning: `rf_model.pkl` dan `model_meta.json`

### Langkah Menjalankan
1. **Masuk ke direktori server dan aktifkan virtualenv:**
   ```powershell
   cd bengkelpintar_api
   .venv\Scripts\activate
   ```
2. **Siapkan berkas `.env`:**
   Salin `.env.example` ke `.env` lalu sesuaikan kredensial:
   ```ini
   DATABASE_URL=postgresql+psycopg://bengkel_app:password@localhost:5432/bengkelpintar
   JWT_SECRET=rahasia-jwt-lokal-minimal-32-karakter
   API_KEY=bengkelpintar_api_key_lokal
   MODEL_DIR=../bengkelpintar_backend/models
   ```
3. **Inisialisasi tabel dan data awal (seeding):**
   ```powershell
   python seed.py
   ```
4. **Jalankan server API:**
   ```powershell
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```
   > **Penting:** Parameter `--host 0.0.0.0` wajib agar aplikasi Flutter di HP yang terhubung ke Wi-Fi/hotspot yang sama dapat mengakses server lewat IP laptop (contoh: `http://192.168.1.10:8000`).

5. **Firewall:**
   Pastikan Windows Defender Firewall mengizinkan koneksi masuk (*inbound*) pada port TCP **8000**. Port PostgreSQL (**5432**) **tidak boleh dibuka** ke jaringan luar.

---

## 2. Prosedur Backup dan Restore Database

Skrip backup dan restore tersedia di folder `scripts/`:

### A. Backup Database
- **Menggunakan Python (Lintas Platform):**
  ```bash
  python scripts/backup.py
  ```
  Opsi tambahan:
  - `--output path/ke/file.sql`: Tentukan nama/lokasi berkas cadangan secara spesifik.
  - `--dir path/folder`: Tentukan folder tujuan (default: `bengkelpintar_api/backups/`).
  - `--url <DATABASE_URL>`: Timpa URL database.

- **Menggunakan PowerShell (Windows):**
  ```powershell
  .\scripts\backup.ps1
  ```

- **Menggunakan Bash (Linux/VPS):**
  ```bash
  ./scripts/backup.sh
  ```

### B. Restore (Pemulihan) Database
- **Menggunakan Python:**
  ```bash
  python scripts/restore.py backups/bengkelpintar_20261115_120000.sql
  ```
  Opsi tambahan:
  - `--dbname <nama_db>`: Pulihkan ke nama database berbeda (misal database uji atau database baru).
  - `-y` atau `--yes`: Lewati pertanyaan konfirmasi (cocok untuk skrip otomatis).

- **Menggunakan PowerShell (Windows):**
  ```powershell
  .\scripts\restore.ps1 backups\bengkelpintar_20261115_120000.sql
  ```

- **Menggunakan Bash (Linux/VPS):**
  ```bash
  ./scripts/restore.sh backups/bengkelpintar_20261115_120000.sql
  ```

---

## 3. Panduan Migrasi ke VPS (Produksi)

Ketika beralih ke server sungguhan (VPS), ikuti langkah-langkah berikut:

### 3.1 Spesifikasi dan Persiapan Server
- **Sistem Operasi:** Ubuntu 22.04 / 24.04 LTS (atau Debian 12).
- **Spesifikasi:** 1–2 vCPU, RAM 2GB+, SSD 20GB+.
- **Domain:** A record menunjuk ke IP publik VPS (contoh: `api.bengkelpintar.com`).

### 3.2 Keamanan Jaringan dan Firewall
Gunakan `ufw` untuk menutup port yang tidak perlu:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP (Let's Encrypt)
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```
> **Catatan Keamanan:** Port PostgreSQL (5432) **hanya boleh terikat ke localhost (127.0.0.1)** dan dilarang dibuka ke internet.

### 3.3 Instalasi Dependensi Sistem
```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip postgresql postgresql-contrib nginx certbot python3-certbot-nginx git
```

### 3.4 Konfigurasi PostgreSQL Produksi
```bash
sudo -u postgres psql
```
Di dalam prompt PostgreSQL:
```sql
CREATE DATABASE bengkelpintar;
CREATE USER bengkel_app WITH ENCRYPTED PASSWORD 'GantiDenganPasswordSangatKuatDanPanjang';
GRANT ALL PRIVILEGES ON DATABASE bengkelpintar TO bengkel_app;
\c bengkelpintar
GRANT ALL ON SCHEMA public TO bengkel_app;
\q
```

### 3.5 Deployment Kode Aplikasi
1. Clone repositori ke direktori server (misal `/opt/bengkelpintar`):
   ```bash
   sudo mkdir -p /opt/bengkelpintar
   sudo chown -R $USER:$USER /opt/bengkelpintar
   git clone <URL_REPO> /opt/bengkelpintar
   cd /opt/bengkelpintar/bengkelpintar_api
   ```
2. Buat virtual environment dan pasang dependensi:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install --upgrade pip
   pip install -r requirements.txt
   ```
3. Salin artefak model ML (`rf_model.pkl` dan `model_meta.json`) ke folder yang ditentukan (misal `/opt/bengkelpintar/bengkelpintar_backend/models/`).
4. Siapkan berkas `.env` produksi:
   ```ini
   DATABASE_URL=postgresql+psycopg://bengkel_app:PasswordKuatTadi@127.0.0.1:5432/bengkelpintar
   JWT_SECRET=HasilkanKunciAcak64KarakterDenganOpensslRandHex32
   API_KEY=KunciApiKeyKhususAplikasiMobileProduksi
   MODEL_DIR=/opt/bengkelpintar/bengkelpintar_backend/models
   ```
5. Inisialisasi skema awal dan data master:
   ```bash
   python seed.py
   ```
   Atau pulihkan cadangan dari laptop demo:
   ```bash
   python scripts/restore.py /path/ke/backup_dari_laptop.sql -y
   ```

### 3.6 Konfigurasi Systemd Service
Buat unit service `/etc/systemd/system/bengkelpintar.service`:
```ini
[Unit]
Description=BengkelPintar FastAPI Service
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/bengkelpintar/bengkelpintar_api
EnvironmentFile=/opt/bengkelpintar/bengkelpintar_api/.env
ExecStart=/opt/bengkelpintar/bengkelpintar_api/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000 --workers 2
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Aktifkan dan nyalakan service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable bengkelpintar
sudo systemctl start bengkelpintar
sudo systemctl status bengkelpintar
```

### 3.7 Konfigurasi Nginx dan SSL (HTTPS Wajib)
Buat konfigurasi virtual host `/etc/nginx/sites-available/bengkelpintar`:
```nginx
server {
    server_name api.bengkelpintar.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeout koneksi
        proxy_connect_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

Aktifkan situs dan pasang sertifikat SSL:
```bash
sudo ln -s /etc/nginx/sites-available/bengkelpintar /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d api.bengkelpintar.com
```

### 3.8 Cadangan Terjadwal (Cron Job VPS)
Tambahkan entri crontab untuk mencadangkan database otomatis setiap pukul 02:00 malam:
```bash
crontab -e
```
Isi baris:
```cron
0 2 * * * /opt/bengkelpintar/bengkelpintar_api/scripts/backup.sh --dir /var/backups/bengkelpintar >> /var/log/bengkelpintar_backup.log 2>&1
```

---

## 4. Build Aplikasi Flutter untuk Produksi

Setelah server VPS aktif dengan HTTPS, build aplikasi Flutter dengan mengarahkan `API_BASE_URL` ke domain produksi:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.bengkelpintar.com
```

Pengguna mobile tidak perlu mengisi IP atau konfigurasi manual apa pun saat memakai aplikasi rilis.
