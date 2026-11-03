# PRD: BengkelPintar

**Pengembangan Sistem Klasifikasi Kerusakan pada Motor Menggunakan Metode Random Forest Berbasis Flutter**

| | |
|---|---|
| **Nama aplikasi** | BengkelPintar |
| **Jenis dokumen** | Product Requirements Document (PRD) |
| **Tujuan proyek** | Skripsi / Tugas Akhir |
| **Platform** | Mobile (Flutter, Android) |
| **Versi dokumen** | 1.1 (draft) |
| **Tanggal** | 27 Oktober 2026 |

**Dokumen terkait:** `HALAMAN.md` (34 halaman) dan `DESIGN.md` (panduan UI/UX) di folder `docs/`, serta `AGENTS.md` (aturan kerja agent) dan `TASKS.md` (tugas frontend dan backend) di root proyek.

---

## 1. Latar Belakang

Diagnosis kerusakan sepeda motor di bengkel umumnya bergantung pada pengalaman mekanik. Hasilnya bisa berbeda antar mekanik, dan proses dari diagnosis sampai transaksi (memilih sparepart, menghitung biaya, membuat nota) sering dilakukan terpisah dan manual.

BengkelPintar menggabungkan dua hal dalam satu aplikasi mobile:

1. **Diagnosis kerusakan** berbasis gejala menggunakan algoritma **Random Forest**.
2. **Sistem POS (Point of Sale)** sederhana untuk mengelola produk, jasa, stok, dan transaksi bengkel.

Hasil diagnosis terhubung langsung ke POS, sehingga komponen dan jasa yang relevan bisa langsung menjadi draft transaksi.

## 2. Tujuan

### 2.1 Tujuan Produk
- Membantu mekanik mengklasifikasikan kerusakan motor dari gejala yang dipilih.
- Menampilkan hasil diagnosis lengkap: kerusakan utama, tingkat keyakinan, kemungkinan lain, urgensi, solusi, komponen terkait, perkiraan biaya, dan perkiraan waktu.
- Menghubungkan hasil diagnosis dengan transaksi POS agar alur kerja bengkel lebih cepat dan tercatat rapi.

### 2.2 Tujuan Skripsi
- Membangun dan mengevaluasi model Random Forest untuk klasifikasi kerusakan motor (akurasi, precision, recall, F1-score, confusion matrix).
- Mengimplementasikan model tersebut dalam sistem client-server yang dapat dipakai di perangkat mobile.

### 2.3 Indikator Keberhasilan
| Indikator | Target |
|---|---|
| Model Random Forest dapat dilatih dan dievaluasi | Laporan evaluasi tersedia (akurasi dan confusion matrix) |
| Alur utama berjalan end-to-end | Login, diagnosis, pilih komponen, draft transaksi, finalisasi, nota |
| Aplikasi dipakai di 2 HP berbeda | Admin dan mekanik melihat data yang sama |
| Hasil diagnosis lengkap | Seluruh field pada bagian 6 tampil |

> Target akurasi model ditentukan setelah dataset terkumpul.

## 3. Ruang Lingkup

### 3.1 Dalam Lingkup
- Autentikasi dan pembagian peran (admin dan mekanik).
- Diagnosis kerusakan dari checklist gejala.
- Riwayat diagnosis.
- POS dasar: katalog produk dan jasa, stok, transaksi, nota, laporan sederhana.
- Pengelolaan data gejala dan kerusakan oleh admin.
- Kategori produk, penyesuaian stok manual, dan pengaturan identitas bengkel (kop nota).
- Ganti password dan reset password oleh admin.
- Tampilan khusus saat server tidak terjangkau.
- Pelatihan dan evaluasi model Random Forest.

### 3.2 Di Luar Lingkup (Pengembangan Lanjutan)
- **Mode offline-first** (transaksi tanpa server lalu sinkron belakangan).
- Deployment ke server online / hosting.
- Pembayaran digital (QRIS, payment gateway).
- Cetak nota lewat printer Bluetooth.
- Integrasi WhatsApp, backup ke Google Drive, atau asisten AI.
- Aplikasi iOS.
- Diagnosis dari input suara atau foto.

## 4. Pengguna dan Hak Akses

Aplikasi dipakai oleh **dua peran** pada **dua HP berbeda**, dengan data yang dipakai bersama.

### 4.1 Mekanik
- Login.
- Memilih gejala dan menjalankan diagnosis.
- Melihat hasil diagnosis.
- Memilih komponen dan jasa dari hasil diagnosis.
- Membuat **draft transaksi**.
- Melihat riwayat diagnosis dan draft transaksi miliknya.
- Mengganti password sendiri.

### 4.2 Admin
- Semua hak mekanik.
- Kelola pengguna (tambah, ubah, nonaktifkan).
- Kelola produk, jasa, dan stok.
- **Finalisasi transaksi** dan membuat nota.
- Melihat laporan penjualan.
- Kelola data gejala dan kerusakan (termasuk urgensi, solusi, komponen terkait, estimasi waktu).
- Kelola kategori produk dan menyesuaikan stok manual.
- Mengatur nama, alamat, dan telepon bengkel (kop nota).
- Mengatur ulang (reset) password pengguna lain.

### 4.3 Alasan Pembagian
Mekanik yang mengetahui kondisi motor membuat draft. Admin yang memegang uang dan stok memfinalkan pembayaran. Dengan begitu stok tidak berubah tanpa sepengetahuan admin.

## 5. Gambaran Alur Utama

```
Mekanik login
   -> pilih gejala (checklist)
   -> sistem menjalankan model Random Forest
   -> tampil hasil diagnosis
   -> mekanik pilih komponen dan jasa
   -> draft transaksi dibuat
   -> admin finalisasi (pembayaran, stok berkurang)
   -> nota dibuat
   -> tercatat di laporan
```

## 6. Kebutuhan Fungsional

### 6.1 Autentikasi
| ID | Kebutuhan |
|---|---|
| F-AUTH-01 | Pengguna dapat login dengan username dan password. |
| F-AUTH-02 | Sistem mengeluarkan token JWT setelah login berhasil. |
| F-AUTH-03 | Akses fitur dibatasi berdasarkan peran (admin / mekanik). |
| F-AUTH-04 | Pengguna dapat logout. |
| F-AUTH-05 | Setiap request ke API disertai API key sebagai lapisan keamanan tambahan (kecuali `/auth/login` dan `/health`). |
| F-AUTH-06 | Pengguna dapat mengganti password sendiri (password lama, password baru, konfirmasi; minimal 6 karakter). |
| F-AUTH-07 | Admin dapat mengatur ulang password pengguna lain. |

### 6.2 Diagnosis
| ID | Kebutuhan |
|---|---|
| F-DIAG-01 | Mekanik dapat memilih satu atau lebih gejala dari daftar checklist. |
| F-DIAG-02 | Sistem mengirim gejala ke model dan menerima hasil prediksi. |
| F-DIAG-03 | Hasil menampilkan **kerusakan utama**. |
| F-DIAG-04 | Hasil menampilkan **tingkat keyakinan** (persentase). |
| F-DIAG-05 | Hasil menampilkan **kemungkinan lain** beserta persentasenya (maksimal 2-3 teratas). |
| F-DIAG-06 | Hasil menampilkan **tingkat urgensi**, **solusi**, **komponen terkait**, dan **estimasi waktu** dari data referensi. |
| F-DIAG-07 | Hasil menampilkan **estimasi biaya** yang dihitung dari harga produk dan jasa terkait di POS, dengan label **"perkiraan"**. |
| F-DIAG-08 | Setiap diagnosis tersimpan sebagai riwayat (gejala, hasil, pengguna, waktu). |
| F-DIAG-09 | Mekanik dapat melihat riwayat diagnosis miliknya, admin dapat melihat semua. |
| F-DIAG-10 | Dari hasil diagnosis, pengguna dapat langsung membuat draft transaksi. |
| F-DIAG-11 | (Opsional) Admin dapat melihat statistik kerusakan yang paling sering terdiagnosis. |

**Contoh hasil diagnosis:**

```
Input gejala:
  - Mesin susah dihidupkan
  - Tarikan berat
  - Knalpot berasap putih

Hasil:
  Kerusakan         : Busi kotor / aus
  Tingkat keyakinan : 78%
  Kemungkinan lain  : Karburator kotor (15%), Aki lemah (7%)
  Tingkat urgensi   : Sedang (masih bisa dipakai, segera cek)
  Solusi            : Bersihkan atau ganti busi
  Komponen terkait  : Busi, kabel busi
  Estimasi biaya    : Rp30.000 - Rp80.000 (perkiraan)
  Estimasi waktu    : +/- 15 menit
```

**Sumber tiap field hasil:**

| Field | Sumber |
|---|---|
| Kerusakan utama, tingkat keyakinan, kemungkinan lain | **Model Random Forest** (`predict` dan `predict_proba`) |
| Tingkat urgensi, solusi, komponen terkait, estimasi waktu | **Data referensi** (tabel kerusakan) |
| Estimasi biaya | **Dihitung** dari harga produk dan jasa di POS |

Model hanya mengklasifikasikan. Biaya, solusi, dan urgensi bukan hasil perhitungan model.

### 6.3 Kasir dan navigasi
- Navigasi bawah: admin Beranda | Transaksi | Diagnosis | Kasir | Profil; mekanik Beranda | Riwayat | Diagnosis | Kasir | Profil.
- Kasir menjadi layar utama POS untuk memilih produk/jasa, mengisi pelanggan, dan mempertahankan keranjang.
- Katalog admin dibuka dari Beranda, tindakan stok menipis, atau header Kasir; tidak menjadi tab navigasi.
| ID | Kebutuhan |
|---|---|
| F-POS-01 | Admin dapat menambah, mengubah, dan menonaktifkan **produk** (nama, kategori, harga, stok). |
| F-POS-02 | Admin dapat menambah, mengubah, dan menonaktifkan **jasa** (nama, harga). |
| F-POS-03 | Stok produk berkurang otomatis saat transaksi difinalkan. |
| F-POS-04 | Mekanik dapat membuat **draft transaksi** berisi produk dan jasa, dengan data pelanggan opsional. |
| F-POS-05 | Admin dapat memfinalkan transaksi, dan stok dipotong dalam satu proses (semua berhasil atau batal semua). |
| F-POS-06 | Sistem membuat **nota** yang dapat dibagikan sebagai PDF. |
| F-POS-07 | Admin dapat melihat **laporan sederhana**: total penjualan per periode dan daftar transaksi. |
| F-POS-08 | Transaksi dapat ditautkan ke satu riwayat diagnosis (opsional). |
| F-POS-09 | Admin dapat mengelola **kategori produk** (tambah, ubah, nonaktifkan). Kategori yang masih dipakai produk tidak boleh dihapus. |
| F-POS-10 | Admin dapat mengatur **nama, alamat, dan telepon bengkel** untuk kop nota. |
| F-POS-11 | Admin dapat **menyesuaikan stok manual** dengan alasan. Setiap perubahan tercatat sebagai mutasi stok. |
| F-POS-12 | Saat finalisasi, admin memilih metode pembayaran (tunai atau transfer), mengisi jumlah dibayar, dan sistem menghitung kembalian. |
| F-POS-13 | Mekanik hanya melihat draft transaksi miliknya, admin melihat semua transaksi. |

- `nama_pelanggan` dan `plat_nomor` boleh null atau string kosong. Klien menampilkan "Pelanggan Umum" bila nama kosong dan tidak menampilkan plat kosong pada daftar, detail, dan nota.
| ID | Kebutuhan |
|---|---|
| F-MST-01 | Admin dapat mengelola daftar **gejala**. |
| F-MST-02 | Admin dapat mengelola daftar **kerusakan** beserta urgensi, solusi, estimasi waktu. |
| F-MST-03 | Admin dapat menautkan kerusakan ke **komponen** (produk) dan **jasa** terkait. |

> Catatan: menambah gejala atau kerusakan baru yang tidak ada saat pelatihan model memerlukan pelatihan ulang model. Fitur ini perlu dibatasi atau diberi peringatan.

### 6.5 Backup
| ID | Kebutuhan |
|---|---|
| F-BKP-01 | Backup database dilakukan manual di sisi server (misalnya `pg_dump`) dan didokumentasikan. |

### 6.6 Aplikasi (Klien)
| ID | Kebutuhan |
|---|---|
| F-APP-01 | Alamat server berasal dari konfigurasi build (`API_BASE_URL`), sehingga pengguna harian tidak mengisinya. Admin dapat mengubah alamat (satu kolom URL penuh), menjalankan **tes koneksi** (`GET /health`), dan mengembalikan ke alamat bawaan di halaman Pengaturan Server. |
| F-APP-02 | Saat server tidak terjangkau, aplikasi menampilkan layar khusus berisi penyebab umum, tombol **Coba Lagi**, dan pintasan ke Pengaturan Server **hanya untuk admin** (mekanik melihat "Hubungi admin"). |
| F-APP-03 | Tampilan mengikuti `DESIGN.md`: layar mobile potret, satu tombol utama per layar, dan status (urgensi, draft/final) selalu disertai teks. |

## 7. Daftar Layar (Fase 1)

Total **34 halaman** (33 wajib, 1 opsional). Urutan pengerjaan, jenis header, navigasi bawah, dan pola tampilan tiap halaman ada di `HALAMAN.md`. Panduan tampilan ada di `DESIGN.md`.

| No | Layar | Peran | Keterangan |
|---|---|---|---|
| 1 | Splash | Semua | Logo dan pengecekan sesi |
| 2 | Pengaturan Server | Admin | Satu kolom URL server, tes koneksi. Dibuka dari Profil, bukan alur harian |
| 3 | Login | Semua | Username dan password |
| 4 | Beranda | Semua | Menu sesuai peran, ringkasan hari ini |
| 5 | Form Gejala | Mekanik, Admin | Checklist gejala |
| 6 | Hasil Diagnosis | Mekanik, Admin | Semua field hasil, tombol buat draft transaksi |
| 7 | Riwayat Diagnosis | Mekanik, Admin | Daftar riwayat |
| 8 | Draft Transaksi / Keranjang | Mekanik, Admin | Produk dan jasa terpilih |
| 9 | Daftar Transaksi | Mekanik, Admin | Admin: draft dan final. Mekanik: "Draft Saya" (draft miliknya) |
| 10 | Finalisasi dan Nota | Admin | Pembayaran, nota, bagikan PDF |
| 11 | Katalog Produk | Admin | Layar biasa admin, dibuka dari Beranda atau Kasir |
| 12 | Katalog Jasa | Admin | Layar biasa admin, dibuka dari Katalog |
| 35 | Kasir | Mekanik, Admin | Tab navigasi bawah, keranjang dan pemilihan item |
| 13 | Menu Data Gejala dan Kerusakan | Admin | Menu menuju halaman 28 dan 29 |
| 14 | Kelola Pengguna | Admin | Daftar pengguna |
| 15 | Laporan Penjualan | Admin | Penjualan per periode |
| 16 | Profil / Logout | Semua | Info akun, menu akun, keluar |
| 17 | Detail Riwayat Diagnosis | Mekanik, Admin | Memakai ulang tampilan Hasil Diagnosis |
| 18 | Detail Transaksi | Admin | Item, total, status |
| 19 | Pemilih Produk dan Jasa | Mekanik, Admin | Bottom sheet di keranjang |
| 20 | Form Tambah/Ubah Produk | Admin | |
| 21 | Form Tambah/Ubah Jasa | Admin | |
| 22 | Detail Produk dan Penyesuaian Stok | Admin | Riwayat mutasi stok |
| 23 | Form Tambah/Ubah Gejala | Admin | |
| 24 | Form Tambah/Ubah Kerusakan | Admin | Termasuk penautan komponen dan jasa terkait |
| 25 | Form Tambah/Ubah Pengguna | Admin | |
| 26 | Akses Ditolak | Semua | Saat mekanik membuka halaman khusus admin |
| 27 | Statistik Diagnosis | Admin | **Opsional** |
| 28 | Daftar Gejala | Admin | |
| 29 | Daftar Kerusakan | Admin | |
| 30 | Ganti Password | Semua | Dari Profil |
| 31 | Reset Password Pengguna | Admin | Bottom sheet di Form Pengguna |
| 32 | Pengaturan Bengkel | Admin | Nama, alamat, telepon untuk kop nota |
| 33 | Server Tidak Terjangkau | Semua | Tampilan saat HP tidak bisa terhubung ke server |
| 34 | Kelola Kategori Produk | Admin | |

Daftar ini dapat disesuaikan. Jika berubah, perbarui juga `HALAMAN.md` dan `TASKS.md`.

## 8. Arsitektur

### 8.1 Gambaran
Sistem berbasis **client-server dengan REST API**, dengan **satu server** (FastAPI). Server memuat file model Random Forest yang dihasilkan di folder pelatihan.

```
[HP Mekanik]   [HP Admin]
      \             /
       \           /     Wi-Fi / hotspot yang sama (LAN)
        v         v
   bengkelpintar_api  (FastAPI, port 8000)
        |                    |
        v                    v
   PostgreSQL        memuat rf_model.pkl dari
   (data POS,        bengkelpintar_backend/models/
    riwayat)
```

**Penempatan:** PostgreSQL, server API, dan file model Random Forest semuanya berjalan di **laptop**. HP hanya menjalankan aplikasi Flutter (tampilan) dan tidak pernah mengakses database atau model secara langsung.

### 8.2 Teknologi
| Komponen | Teknologi |
|---|---|
| Aplikasi mobile | Flutter (Dart) |
| Server API | FastAPI (Python) |
| Database | **PostgreSQL** (satu-satunya database) |
| Akses database | SQLAlchemy (tanpa Alembic, tabel dibuat lewat kode) |
| Machine learning | scikit-learn (Random Forest), disimpan sebagai `.pkl` |
| Autentikasi | JWT, ditambah API key |

### 8.3 Struktur Folder

```
C:\bengkel\
├── AGENTS.md                       -> aturan kerja agent (OpenCode)
├── TASKS.md                        -> Bagian A frontend (T-), Bagian B backend (B-)
│
├── docs/
│   ├── PRD.md
│   ├── DESIGN.md
│   └── HALAMAN.md
│
├── bengkelpintar/                  -> Flutter (mobile, jalan di HP)
│   ├── lib/
│   │   ├── core/                   -> theme/, widgets/, utils/, konfigurasi alamat server
│   │   ├── data/                   -> model data, repository, data mock
│   │   ├── services/               -> antarmuka layanan + mock (nanti pemanggil API)
│   │   └── features/
│   │       ├── auth/               -> login
│   │       ├── diagnosis/          -> form gejala, hasil, riwayat
│   │       ├── pos/                -> katalog, transaksi, nota
│   │       └── laporan/            -> laporan dan statistik
│   ├── assets/                     -> mock/, fonts/, images/
│   ├── test/
│   └── pubspec.yaml
│
├── bengkelpintar_api/              -> server API (FastAPI), satu-satunya server
│   ├── .venv/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py                 -> endpoint login, produk, transaksi, diagnosis
│   │   ├── schemas.py              -> bentuk data request/response
│   │   ├── database.py             -> koneksi PostgreSQL (SQLAlchemy)
│   │   ├── models_db.py            -> tabel database
│   │   └── auth.py                 -> JWT, peran admin dan mekanik
│   ├── tests/
│   ├── .env, .env.example
│   └── requirements.txt
│
└── bengkelpintar_backend/          -> sisi machine learning (bukan server)
    ├── .venv/
    ├── models/
    │   ├── rf_model.pkl            -> model hasil latihan
    │   └── model_meta.json         -> daftar kode gejala dan kelas, urutan fitur
    ├── training/
    │   ├── train_model.py          -> latih dan evaluasi Random Forest
    │   └── hasil/                  -> confusion matrix, laporan akurasi
    ├── dataset/
    │   └── dataset_motor.csv       -> data gejala dan kerusakan
    └── requirements.txt
```

| Folder | Tugas |
|---|---|
| **bengkelpintar** | Tampilan admin dan mekanik |
| **bengkelpintar_api** | Login, peran, POS, PostgreSQL, riwayat diagnosis, memuat `rf_model.pkl` dan `model_meta.json` untuk prediksi |
| **bengkelpintar_backend** | Melatih dan mengevaluasi model, menyimpan `.pkl`. **Bukan server utama** |

Path ke folder `models/` dikonfigurasi di kode API (satu tempat, lewat `.env`), sehingga mudah diubah. Versi `scikit-learn` dan `numpy` di kedua `requirements.txt` harus sama, karena file `.pkl` dibuat di satu folder dan dibaca di folder lain.

### 8.4 Mode Jaringan
- **Laptop diperlakukan sebagai server sungguhan.** Aplikasi dirancang seolah-olah server sudah ada di alamat tetap, jadi pengguna harian **tidak pernah mengisi IP atau port**.
- **Alamat server tertanam saat build** lewat konfigurasi `API_BASE_URL`. Tahap demo: `http://<IP laptop>:8000`. Produksi: `https://api.<domain>`. Kodenya sama, hanya nilai konfigurasinya berbeda.
- **Tahap skripsi (demo):** server di laptop, HP terhubung lewat Wi-Fi atau hotspot yang sama, tanpa koneksi internet. Istilah resmi: *"client-server pada jaringan lokal (LAN), tidak memerlukan koneksi internet"*.
- **Tahap lanjutan (produksi):** server dipindah ke VPS dengan domain dan HTTPS (lihat 8.6).
- **Pengaturan Server (halaman 2)** hanya untuk admin, dibuka dari Profil, dipakai bila alamat perlu diganti (misalnya IP laptop berubah saat demo). Bukan bagian dari alur harian.
- Syarat saat demo: laptop menyala dan satu jaringan dengan HP.

### 8.5 Panduan Jaringan Lokal (Tahap Demo, Server di Laptop)
- PostgreSQL, API, dan model berjalan di laptop. HP hanya menjalankan aplikasi.
- API dijalankan dengan `--host 0.0.0.0 --port 8000` agar dapat dijangkau HP. Jika memakai `127.0.0.1`, HP tidak akan bisa terhubung.
- PostgreSQL hanya diakses dari laptop (`localhost`). Port database (5432) **tidak dibuka** ke jaringan.
- Firewall Windows: izinkan koneksi masuk ke port **8000**.
- IP laptop sebaiknya statis, atau pakai hotspot dengan IP yang konsisten. Cek dengan `ipconfig`.
- Android memblokir HTTP biasa pada aplikasi rilis. Pada **build demo**, server lokal memakai `http://`, jadi aplikasi mengaktifkan `usesCleartextTraffic` di `AndroidManifest.xml`. Build produksi memakai `https://` dan tidak memerlukannya.
- Sebagian Wi-Fi publik atau kampus memblokir komunikasi antar perangkat (client isolation). Gunakan hotspot jika begitu.
- Laptop tidak boleh tidur selama aplikasi dipakai.
- Backup rutin dengan `pg_dump`, karena semua data berada di satu laptop.

### 8.6 Dari Demo ke Server Sungguhan
Laptop hanyalah pengganti server untuk demo. Berpindah ke server sungguhan cukup mengganti nilai `API_BASE_URL` dan memindahkan tiga hal: API, PostgreSQL, dan file model.

| Hal | Demo (laptop) | Produksi (VPS) |
|---|---|---|
| Alamat server | `http://<IP laptop>:8000` | `https://api.<domain>` |
| Cara mengisi di aplikasi | Konfigurasi build `API_BASE_URL` | Sama, nilainya berbeda |
| HTTPS | Tidak | **Wajib** |
| Database | PostgreSQL di laptop | PostgreSQL di VPS |
| Model | `rf_model.pkl` di laptop | File yang sama di VPS |
| Syarat | Laptop menyala, satu jaringan | VPS menyala terus, ada internet |

Catatan:
- Pilih **VPS** (atau layanan yang mendukung Python dan PostgreSQL). Hosting bersama (shared hosting/cPanel) umumnya hanya mendukung PHP dan MySQL, sehingga tidak cocok untuk FastAPI dan model Python.
- Keamanan produksi: HTTPS, secret JWT yang kuat lewat environment variable, port database tidak dibuka ke internet, CORS dibatasi, pembatasan percobaan login, dan backup terjadwal.
- Kebutuhan spesifikasi VPS belum diukur. Model Random Forest berukuran kecil, tetapi kapasitas yang cukup perlu diuji saat deployment.

## 9. Kontrak API (Draft)

Semua endpoint, kecuali `/auth/login` dan `/health`, memerlukan header:
```
Authorization: Bearer <token_jwt>
X-API-Key: <api_key>
```

Mock data di fase 1 **harus berbentuk persis** seperti respons di bawah, agar saat server sudah jadi hanya sumber datanya yang diganti.

### 9.1 Daftar Endpoint
| Metode | Endpoint | Peran | Fungsi |
|---|---|---|---|
| POST | `/auth/login` | Semua | Login, mengembalikan token |
| GET | `/auth/me` | Semua | Info pengguna aktif |
| GET | `/gejala` | Semua | Daftar gejala |
| POST | `/diagnosis/predict` | Semua | Jalankan diagnosis |
| GET | `/diagnosis/riwayat` | Semua | Riwayat (mekanik: miliknya, admin: semua) |
| GET | `/diagnosis/riwayat/{id}` | Semua | Detail riwayat |
| GET / POST / PUT | `/produk` | Admin (GET: semua) | Kelola produk |
| GET / POST / PUT | `/jasa` | Admin (GET: semua) | Kelola jasa |
| POST | `/transaksi` | Semua | Buat draft transaksi |
| GET | `/transaksi` | Semua | Admin: semua transaksi. Mekanik: draft miliknya |
| GET | `/transaksi/{id}` | Semua | Detail transaksi (mekanik: miliknya) |
| PUT | `/transaksi/{id}` | Semua | Ubah draft (mekanik: draft miliknya). Transaksi final tidak bisa diubah |
| POST | `/transaksi/{id}/finalisasi` | Admin | Finalisasi dan potong stok |
| GET | `/transaksi/{id}/nota` | Admin | Data nota |
| GET | `/laporan/penjualan` | Admin | Laporan per periode |
| GET / POST / PUT | `/pengguna` | Admin | Kelola pengguna |
| GET / POST / PUT | `/kerusakan` | Admin | Kelola data kerusakan |
| POST / PUT | `/gejala` | Admin | Kelola gejala |
| GET | `/health` | Tanpa login | Tes koneksi |
| POST | `/auth/ganti-password` | Semua | Ganti password sendiri |
| POST | `/pengguna/{id}/reset-password` | Admin | Atur ulang password pengguna |
| GET / POST / PUT | `/kategori` | Admin (GET: semua) | Kelola kategori produk |
| GET / PUT | `/pengaturan-bengkel` | Admin (GET: semua) | Nama, alamat, telepon bengkel untuk kop nota |
| POST | `/produk/{id}/stok` | Admin | Penyesuaian stok manual |
| GET | `/produk/{id}/mutasi` | Admin | Riwayat mutasi stok |
| GET | `/diagnosis/statistik` | Admin | Statistik diagnosis (opsional) |

### 9.2 Contoh: Login
**Request** `POST /auth/login`
```json
{ "username": "budi", "password": "********" }
```
**Response**
```json
{
  "access_token": "eyJhbGciOi...",
  "token_type": "bearer",
  "user": { "id": 2, "nama": "Budi", "peran": "mekanik" }
}
```

### 9.3 Contoh: Diagnosis
**Request** `POST /diagnosis/predict`
```json
{
  "gejala_ids": [1, 3, 4]
}
```
**Response**
```json
{
  "riwayat_id": 31,
  "kerusakan_utama": {
    "id": 1,
    "nama": "Busi kotor / aus",
    "keyakinan": 0.78
  },
  "kemungkinan_lain": [
    { "id": 2, "nama": "Karburator kotor", "keyakinan": 0.15 },
    { "id": 3, "nama": "Aki lemah", "keyakinan": 0.07 }
  ],
  "urgensi": "sedang",
  "urgensi_keterangan": "Masih bisa dipakai, segera cek",
  "solusi": "Bersihkan atau ganti busi",
  "estimasi_waktu_menit": 15,
  "komponen_terkait": [
    { "produk_id": 1, "nama": "Busi NGK Standar", "harga": 25000 },
    { "produk_id": 2, "nama": "Kabel Busi", "harga": 35000 }
  ],
  "jasa_terkait": [
    { "jasa_id": 1, "nama": "Ganti busi", "harga": 20000 }
  ],
  "estimasi_biaya": {
    "min": 30000,
    "max": 80000,
    "keterangan": "Perkiraan"
  },
  "waktu": "2026-10-24T10:15:00"
}
```

### 9.4 Contoh: Draft Transaksi
**Request** `POST /transaksi`
```json
{
  "riwayat_diagnosis_id": 31,
  "nama_pelanggan": null,
  "plat_nomor": null,
  "items": [
    { "tipe": "produk", "id": 1, "jumlah": 1 },
    { "tipe": "jasa", "id": 1, "jumlah": 1 }
  ]
}
```
**Response**
```json
{
  "id": 105,
  "nomor": "TRX-0105",
  "status": "draft",
  "total": 45000,
  "dibuat_oleh": "Budi"
}
```

### 9.5 Contoh: Endpoint Tambahan
**`GET /health`** (tanpa login)
```json
{ "status": "ok", "versi": "1.0" }
```
**`POST /auth/ganti-password`**
```json
{ "password_lama": "********", "password_baru": "********" }
```
```json
{ "pesan": "Kata sandi berhasil diubah." }
```
**`GET /pengaturan-bengkel`**
```json
{ "nama": "Bengkel Maju Jaya", "alamat": "Jl. Merdeka No. 12, Bandung", "telepon": "0812-3456-7890" }
```
**`POST /produk/1/stok`** (penyesuaian stok manual)
```json
{ "jumlah": 10, "alasan": "Barang masuk" }
```
```json
{ "stok_baru": 14 }
```

## 10. Model Data (Gambaran Awal)

| Tabel | Isi utama |
|---|---|
| `pengguna` | id, nama, username, password_hash, peran, aktif |
| `gejala` | id, kode, nama, kategori, aktif |
| `kerusakan` | id, kode, nama, urgensi, solusi, estimasi_waktu_menit, aktif |
| `kerusakan_produk` | kerusakan_id, produk_id (komponen terkait) |
| `kerusakan_jasa` | kerusakan_id, jasa_id |
| `produk` | id, nama, kategori_id, harga, stok, stok_minimum, aktif |
| `jasa` | id, nama, harga, aktif |
| `riwayat_diagnosis` | id, pengguna_id, gejala (daftar), hasil, keyakinan, waktu |
| `transaksi` | id, nomor, status (draft/final), nama_pelanggan (nullable), plat_nomor (nullable), total, metode_bayar, jumlah_dibayar, dibuat_oleh, difinalkan_oleh, riwayat_diagnosis_id, waktu |
| `item_transaksi` | id, transaksi_id, tipe, produk_id/jasa_id, jumlah, harga_satuan |
| `mutasi_stok` | id, produk_id, jumlah, alasan, pengguna_id, transaksi_id (boleh kosong), waktu |
| `kategori` | id, nama, aktif |
| `pengaturan_bengkel` | id, nama, alamat, telepon |

Finalisasi transaksi dijalankan dalam **satu database transaction**: status berubah, stok berkurang, dan mutasi stok tercatat bersamaan, atau batal semuanya.

## 11. Rencana Model Machine Learning

### 11.1 Pendekatan
- Algoritma: **Random Forest Classifier** (scikit-learn).
- Fitur: gejala dalam bentuk biner (0 = tidak ada, 1 = ada).
- Target: jenis kerusakan (kelas).
- Keluaran: kelas prediksi dan probabilitas tiap kelas (`predict_proba`) untuk tingkat keyakinan dan kemungkinan lain.

### 11.2 Dataset (Menyusul)
Sumber data direncanakan dari salah satu atau gabungan:
- Wawancara dengan mekanik bengkel.
- Catatan servis bengkel.
- Referensi buku servis / manual motor.

Struktur dataset yang direncanakan:

| Kolom | Keterangan |
|---|---|
| `g01` ... `gNN` | Gejala (0/1) |
| `kerusakan` | Label kerusakan |

Hal yang perlu dipastikan saat pengumpulan data:
- Setiap kelas kerusakan memiliki cukup sampel dan variasi kombinasi gejala.
- Label idealnya divalidasi mekanik, bukan ditebak sendiri.
- Distribusi kelas dicatat untuk mengantisipasi data tidak seimbang.

### 11.3 Pelatihan dan Evaluasi
- Pembagian data latih dan uji (misalnya 80:20), atau cross-validation.
- Metrik: akurasi, precision, recall, F1-score, confusion matrix.
- Penyetelan parameter (misalnya `n_estimators`, `max_depth`).
- Hasil terbaik disimpan sebagai `bengkelpintar_backend/models/rf_model.pkl`, bersama `model_meta.json` (daftar kode gejala, daftar kode kelas, dan urutan fitur).
- Laporan evaluasi (confusion matrix dan metrik) disimpan di `bengkelpintar_backend/training/hasil/`.
- Hasil evaluasi menjadi bahan bab pengujian skripsi.

### 11.4 Catatan Integrasi
- Urutan fitur saat prediksi harus **sama persis** dengan saat pelatihan. Daftar kode gejala, daftar kode kelas, dan urutannya disimpan di `model_meta.json` bersama model. API memuat file itu saat menyala dan memberi peringatan jika tidak cocok dengan gejala di database.
- Kode gejala (G01 dst.) dan kode kerusakan (K01 dst.) adalah kunci penghubung antara dataset, model, dan database.
- Perubahan daftar gejala atau kelas kerusakan memerlukan pelatihan ulang.
- Tingkat keyakinan adalah probabilitas dari model, bukan jaminan kebenaran.

## 12. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| **Keamanan** | Password disimpan sebagai hash. JWT dengan masa berlaku. API key tidak dianggap rahasia penuh karena tertanam di aplikasi, sehingga keamanan utama bertumpu pada login JWT. |
| **Performa** | Respons diagnosis ditargetkan di bawah 3 detik pada jaringan lokal. |
| **Integritas data** | Finalisasi transaksi bersifat atomik (database transaction). |
| **Ketersediaan** | Server harus menyala di laptop saat aplikasi dipakai. |
| **Kegunaan** | Antarmuka berbahasa Indonesia, sederhana, dapat dipakai mekanik dengan satu tangan. |
| **Kompatibilitas** | Android (versi minimum ditentukan saat implementasi). Aplikasi mengaktifkan `usesCleartextTraffic` karena server lokal memakai HTTP. |
| **Tampilan** | Layar mobile potret, edge-to-edge, bilah status transparan. Font dibundel (tanpa unduhan internet). Detail di `DESIGN.md`. |
| **Konfigurasi** | Alamat server dapat diubah dari dalam aplikasi tanpa rebuild. |
| **Pemeliharaan** | Struktur folder dipisah per tanggung jawab (app, api, ml). |

## 13. Fase Pengerjaan

| Fase | Fokus | Hasil |
|---|---|---|
| **1** | Frontend Flutter dengan **data mock** yang mengikuti kontrak API | Seluruh 34 layar pada bagian 7 berjalan dengan data tiruan |
| **2** | `bengkelpintar_api` dan PostgreSQL | Login, produk, jasa, stok, transaksi, riwayat berjalan; aplikasi disambungkan ke API (diagnosis masih mock) |
| **3** | Pelatihan model di `bengkelpintar_backend`, sambungkan ke API | Diagnosis memakai model asli, evaluasi model selesai |
| **4** | Pengujian dan penyusunan skripsi | Pengujian fungsional, evaluasi model, dokumentasi |

Dataset perlu mulai dikumpulkan **sejak fase 1**, karena fase 3 bergantung padanya.

## 14. Pengujian

- **Pengujian model:** metrik pada bagian 11.3.
- **Pengujian fungsional:** black-box per fitur dan per peran.
- **Pengujian integrasi:** alur lengkap dari login sampai nota pada dua HP.
- **Pengujian pengguna:** uji coba dengan mekanik atau admin bengkel (misalnya kuesioner SUS), jika memungkinkan.

## 15. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Dataset sulit didapat atau terlalu sedikit | Akurasi model rendah | Mulai kumpulkan sejak awal, batasi jumlah kelas kerusakan (misalnya 8-12), validasi dengan mekanik |
| Gejala yang sama mengarah ke banyak kerusakan | Keyakinan model rendah | Tampilkan kemungkinan lain, jelaskan bahwa ini alat bantu |
| Cakupan POS terlalu besar | Skripsi tidak selesai | Pegang batas minimal pada bagian 6.3 |
| Laptop mati atau jaringan terputus saat demo | Aplikasi tidak bisa dipakai | Siapkan hotspot cadangan, uji sebelum demo |
| Alamat IP laptop berubah | Aplikasi gagal terhubung | Layar Pengaturan Server, atau IP statis |
| Estimasi biaya dianggap pasti | Salah paham pelanggan | Selalu beri label "perkiraan" |
| Mock tidak sama dengan respons asli | Layar perlu dibongkar ulang | Kontrak API ditetapkan sejak awal |
| HP gagal terhubung ke laptop (firewall, HTTP diblokir Android, client isolation) | Aplikasi tidak bisa dipakai di perangkat | Ikuti bagian 8.5, uji koneksi dari HP sejak fase 2 |
| Semua data berada di satu laptop | Data hilang jika laptop rusak | Backup rutin `pg_dump` ke penyimpanan lain |
| Tampilan meleset dari yang diharapkan karena tidak ada gambar desain | Pekerjaan ulang | `DESIGN.md` lengkap dengan sketsa, dan agent berhenti minta persetujuan setelah T-02, T-08, dan T-10 |

## 16. Asumsi

- Dipakai oleh satu bengkel, dengan dua pengguna (admin dan mekanik) pada dua HP.
- Server berjalan di laptop dalam jaringan yang sama dengan HP. **Database PostgreSQL dan model Random Forest berada di laptop yang sama.**
- Harga produk dan jasa diisi oleh admin dan bersifat acuan, sehingga estimasi biaya hanya perkiraan.
- Dataset akan tersedia sebelum fase 3.

## 17. Hal yang Belum Diputuskan

| No | Hal | Catatan |
|---|---|---|
| 1 | Sumber dan jumlah dataset | Menyusul, direncanakan wawancara mekanik / catatan servis / buku servis |
| 2 | Daftar gejala dan kelas kerusakan final | Ditentukan bersama dataset |
| 3 | Detail fitur POS (diskon, metode pembayaran, dll.) | Saat ini batas minimal saja |
| 4 | Metode cetak nota | Saat ini PDF, printer Bluetooth opsional |
| 5 | Target akurasi model | Ditetapkan setelah data terkumpul |
| 6 | Logo dan ilustrasi final | Spesifikasi di `DESIGN.md` bagian 19 |
| 7 | Nilai warna final | Estimasi dari gambar referensi, disetel setelah dicoba di perangkat |

## 18. Glosarium

| Istilah | Arti |
|---|---|
| **Random Forest** | Algoritma klasifikasi berupa kumpulan pohon keputusan yang hasilnya digabung lewat voting |
| **POS** | Point of Sale, sistem kasir dan transaksi |
| **LAN** | Local Area Network, jaringan lokal tanpa internet |
| **JWT** | JSON Web Token, token login |
| **API key** | Kunci tambahan untuk mengakses API |
| **Draft transaksi** | Transaksi yang belum difinalkan, belum memotong stok |
| **`.pkl`** | File model Python yang sudah dilatih |
| **Mock** | Data tiruan yang bentuknya sama dengan respons API asli, dipakai di fase 1 |
| **Cleartext traffic** | Koneksi HTTP tanpa enkripsi; perlu diizinkan di Android untuk server lokal |
