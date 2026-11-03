# AGENTS.md: BengkelPintar

File ini berisi instruksi untuk AI coding agent (OpenCode) yang bekerja di proyek ini.
Baca seluruh file ini sebelum mengubah apa pun.

## 0. Dokumen Acuan

| File | Fungsi | Kapan dibaca |
|---|---|---|
| `TASKS.md` | Daftar tugas aktif. Bagian A frontend (`T-`), Bagian B backend (`B-`) | Sebelum mengerjakan apa pun (dimuat otomatis) |
| `docs/HALAMAN.md` | 34 halaman, jenis header, navigasi bawah, penanda progres | Saat membuat atau mengubah layar (dimuat otomatis) |
| `docs/PRD.md` | Sumber kebenaran kebutuhan, 34 halaman, kontrak API | Saat ragu soal fitur, peran, atau API. **Baca bagian yang relevan saja** |
| `docs/DESIGN.md` | Acuan tampilan, perilaku, data baku, teks baku, dan aksesibilitas | **Wajib dibaca** sebelum membuat atau mengubah layar apa pun |

OpenCode memuat `AGENTS.md`, `TASKS.md`, dan `docs/HALAMAN.md` otomatis. `docs/PRD.md` dan `docs/DESIGN.md` tidak dimuat otomatis karena panjang, jadi **baca sendiri** sesuai kebutuhan.

---

## 1. Ringkasan Proyek

**BengkelPintar** adalah aplikasi mobile Flutter untuk bengkel motor dengan dua bagian utama:

1. **Diagnosis kerusakan motor** dari checklist gejala, memakai algoritma **Random Forest**.
2. **Sistem POS** sederhana: produk, jasa, stok, transaksi, nota, laporan.

Hasil diagnosis terhubung ke POS (komponen dan jasa terkait bisa menjadi draft transaksi).

Judul skripsi: *Pengembangan Sistem Klasifikasi Kerusakan pada Motor Menggunakan Metode Random Forest Berbasis Flutter*.

**`docs/PRD.md` adalah sumber kebenaran.** Jika ragu soal fitur, alur, peran, kontrak API, atau cakupan, baca `docs/PRD.md` dahulu. Jika `docs/PRD.md` dan file ini bertentangan, tanyakan kepada pengguna.

## 2. Tech Stack

| Komponen | Teknologi |
|---|---|
| Aplikasi mobile | Flutter (Dart), Android |
| State management Flutter | **Provider** |
| Server API | FastAPI (Python) |
| Database | **PostgreSQL** (satu-satunya database) |
| Akses database | SQLAlchemy (tanpa Alembic, tabel dibuat lewat kode) |
| Machine learning | scikit-learn (Random Forest), disimpan sebagai `.pkl` |
| Autentikasi | JWT, ditambah API key sebagai lapisan tambahan |

## 3. Struktur Folder dan Tanggung Jawab

```
C:\bengkel\
├── AGENTS.md
├── TASKS.md
│
├── docs\
│   ├── PRD.md
│   ├── DESIGN.md
│   └── HALAMAN.md
│
├── bengkelpintar\                  -> Flutter (mobile, jalan di HP)
│   ├── lib\
│   │   ├── core\                   -> theme\, widgets\, utils\, konfigurasi alamat server
│   │   ├── data\                   -> model data, repository, data mock
│   │   ├── services\               -> antarmuka layanan + mock (nanti pemanggil API)
│   │   └── features\               -> auth\, diagnosis\, pos\, laporan\
│   ├── assets\                     -> mock\, fonts\, images\
│   ├── test\
│   └── pubspec.yaml
│
├── bengkelpintar_api\              -> SERVER API (FastAPI), satu-satunya server
│   ├── .venv\
│   ├── app\
│   │   ├── __init__.py
│   │   ├── main.py                 -> endpoint
│   │   ├── schemas.py              -> bentuk data request/response
│   │   ├── database.py             -> koneksi PostgreSQL
│   │   ├── models_db.py            -> tabel database
│   │   └── auth.py                 -> JWT, peran
│   ├── tests\
│   ├── .env, .env.example
│   └── requirements.txt
│
└── bengkelpintar_backend\          -> SISI MACHINE LEARNING (bukan server)
    ├── .venv\
    ├── models\
    │   ├── rf_model.pkl            -> model hasil latihan
    │   └── model_meta.json         -> daftar kode gejala dan kelas, urutan fitur
    ├── training\
    │   ├── train_model.py          -> latih dan evaluasi
    │   └── hasil\                  -> confusion matrix, laporan akurasi
    ├── dataset\                    -> data gejala dan kerusakan (CSV)
    └── requirements.txt
```

### PERINGATAN: penamaan folder tidak umum

Pembagian `api` dan `backend` di proyek ini **mengikuti pola proyek `sentikampus` milik pengguna**, bukan kebiasaan umum:

- **`bengkelpintar_api`** = **satu-satunya server**. Memegang login, peran, POS, PostgreSQL, riwayat diagnosis, dan **memuat `rf_model.pkl`** untuk prediksi.
- **`bengkelpintar_backend`** = **sisi ML saja**. Melatih, mengevaluasi, dan menyimpan model. **Bukan server.** Jangan membuat endpoint atau server di folder ini.
- **`bengkelpintar`** = Flutter.

Jangan menukar atau "membetulkan" arti nama folder ini.

**Penempatan:** PostgreSQL, server API, dan file model berjalan di **laptop** (sementara, nanti dipindah ke VPS). HP hanya menjalankan aplikasi Flutter dan tidak pernah mengakses database atau model langsung.

Path ke `models\` dikonfigurasi di satu tempat di `bengkelpintar_api` (lewat `.env`). Jangan menulis path itu di banyak tempat.

### Batas Folder per Tugas

Setiap tugas hanya boleh mengubah folder yang tertulis di sini. Jika perlu menyentuh di luar batas, **berhenti dan tanyakan**.

| Tugas | Boleh mengubah |
|---|---|
| `T-01` sampai `T-30` (frontend) | **Hanya** `bengkelpintar\` |
| `B-01` sampai `B-09`, `B-12` (server) | **Hanya** `bengkelpintar_api\` |
| `B-10`, `B-11` (dataset, pelatihan, pasang model) | `bengkelpintar_backend\` untuk dataset dan pelatihan. `bengkelpintar_api\` hanya untuk menyambungkan path model |
| `B-13` sampai `B-16` (sambungan ke API) | **Hanya** `bengkelpintar\lib\services\` dan satu baris pendaftaran di `main.dart`. **Dilarang mengubah `lib\features\` (layar).** Jika layar perlu berubah, itu jadi tugas `T-` baru |

Tugas `T-` tidak boleh bergantung pada backend sama sekali. Frontend selalu bisa berjalan dengan data mock.

## 4. Perintah yang Sering Dipakai

Semua perintah dijalankan dari `C:\bengkel`. Sesuaikan jika lingkungan pengguna berbeda.

### API
```powershell
cd bengkelpintar_api
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
`--host 0.0.0.0` wajib agar HP di jaringan yang sama dapat mengakses server. Dokumentasi otomatis ada di `http://localhost:8000/docs`.

### Flutter
```powershell
cd bengkelpintar
flutter pub get
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
flutter analyze
flutter test
```

### Melatih model
```powershell
cd bengkelpintar_backend
.venv\Scripts\activate
pip install -r requirements.txt
python training\train_model.py
```
Hasil disimpan ke `models\rf_model.pkl` dan `models\model_meta.json`. Laporan evaluasi ke `training\hasil\`.

### Tes API
```powershell
cd bengkelpintar_api
pytest
```

## 5. Aturan Kode

### Umum
- UI, pesan error ke pengguna, dan label berbahasa **Indonesia**.
- Nama variabel, fungsi, dan class di kode memakai **bahasa Inggris** kecuali istilah domain yang sudah ada di PRD (misalnya `gejala`, `kerusakan`, `produk`, `jasa`, `transaksi`). Pakai konsisten, jangan campur dua gaya untuk hal yang sama.
- Perubahan kecil dan bertahap. Jangan menulis ulang file besar tanpa diminta.
- Jangan menghapus kode atau file yang tidak berkaitan dengan tugas.

### Flutter
- Ikuti struktur per fitur (`core`, `data`, `services`, `features`).
- Gunakan **Provider** untuk state management. Jangan menambah Riverpod, Bloc, GetX, atau lainnya.
- Layar tidak boleh memanggil HTTP langsung. Panggilan API hanya lewat `services/`.
- **Alamat server tidak boleh ditulis langsung di kode.** Ambil dari konfigurasi build (`API_BASE_URL`), yang hanya bisa ditimpa admin lewat layar Pengaturan Server.
- Selama fase 1, `services/` memakai **data mock**. Pastikan mock dan implementasi asli memiliki antarmuka yang sama, sehingga penggantian tidak mengubah layar.
- Jalankan `flutter analyze` sebelum menyatakan pekerjaan selesai.

### Tampilan (UI)
Gunakan `docs/DESIGN.md` sebagai acuan tampilan dan perilaku aplikasi.
- Ikuti token warna, tipografi, jarak, radius, dan komponen yang didefinisikan
  di `docs/DESIGN.md` dan `lib/core/theme`.
- Warna, gaya teks, jarak, dan radius hanya lewat token di `lib/core/theme`. Komponen dipakai ulang dari `lib/core/widgets`. Jangan menulis kode warna, ukuran font, atau radius langsung di layar.
- **Font Plus Jakarta Sans adalah font global; Poppins dipakai pada layar yang
  menetapkannya.** Semua font dibundel di `assets/fonts/`.
  Dilarang memakai `google_fonts` yang mengunduh saat runtime.
- **Ikon harus melalui `lib/core/theme/app_icons.dart`**, memakai Material
  Symbols Outlined/Rounded sesuai kebutuhan komponen. Jangan memakai `Icons.xxx` atau
  `Symbols.xxx` langsung di layar.
- Layout **fleksibel**: harus benar di lebar layar 320, 360, dan 412, dan di ukuran teks sistem 130%. Jangan memakai lebar tetap. Tidak boleh ada overflow.
- Layar potret, edge-to-edge: bilah status transparan dengan ikon terang, warna header menerus sampai tepi atas (tanpa strip putih).
- Data mock (`assets/mock/`) dan teks UI memakai **data baku (`DESIGN.md` bagian 16)** dan **teks baku (bagian 17)**. Jangan mengarang data baru.
- Satu tombol utama berbentuk pil per layar. Setiap layar berdata punya keadaan memuat, kosong, dan error.

### Python (API)
- Skema request/response di `schemas.py`, tabel di `models_db.py`, logika auth di `auth.py`, koneksi di `database.py`.
- Endpoint tidak boleh berisi logika berat. Pisahkan ke fungsi atau modul terpisah bila membesar.
- Validasi input lewat skema Pydantic.
- Pembatasan peran dilakukan di server, bukan hanya disembunyikan di UI.
- **Versi `scikit-learn` dan `numpy` di `bengkelpintar_api/requirements.txt` dan `bengkelpintar_backend/requirements.txt` harus sama persis.** File `.pkl` dibuat di satu folder dan dibaca di folder lain, dan versi yang berbeda bisa membuat model gagal dimuat atau memberi hasil yang tidak terduga.

## 6. Aturan Kontrak API

- Kontrak API ada di **`docs/PRD.md` bagian 9**.
- Respons **mock di Flutter harus persis sama bentuknya** dengan respons API asli (nama field, tipe data, struktur).
- Jika menambah, mengubah, atau menghapus endpoint atau field, **perbarui `docs/PRD.md` bagian 9** dan beri tahu pengguna.
- Semua endpoint, kecuali `/auth/login` dan `/health`, memakai header `Authorization: Bearer <token>` dan `X-API-Key`.

## 7. Aturan Domain (Mudah Dilanggar)

1. **Estimasi biaya selalu berlabel "perkiraan"** di UI dan di respons API.
2. **Model Random Forest hanya menghasilkan:** kerusakan utama, tingkat keyakinan, dan kemungkinan lain beserta persentase.
   **Urgensi, solusi, komponen terkait, dan estimasi waktu** berasal dari data referensi (tabel kerusakan). **Estimasi biaya** dihitung dari harga produk dan jasa di POS. Jangan menyiratkan bahwa model "menghitung" hal-hal ini.
3. **Mekanik hanya membuat draft transaksi. Admin yang memfinalkan.** Stok hanya berkurang saat finalisasi.
4. **Finalisasi transaksi harus atomik:** perubahan status, pemotongan stok, dan pencatatan mutasi stok dalam **satu database transaction**. Jika satu gagal, batalkan semuanya. Tolak finalisasi jika stok tidak cukup.
5. **Urutan fitur (gejala) saat prediksi harus sama persis dengan saat pelatihan.** Daftar kode gejala, daftar kode kelas, dan urutannya disimpan di `model_meta.json` bersama `rf_model.pkl`. API memakai file itu saat memuat model dan mengubah gejala terpilih menjadi vektor 0/1.
6. Mengubah daftar gejala atau kelas kerusakan berarti **model harus dilatih ulang** dan API dinyalakan ulang. Beri peringatan, jangan diam-diam mengubahnya.
7. Tingkat keyakinan adalah probabilitas model (`predict_proba`), bukan jaminan kebenaran.
8. Mekanik hanya melihat riwayat diagnosis dan draft transaksi miliknya. Admin melihat semua.

## 8. Aturan Keamanan

- Password **wajib di-hash** (bcrypt atau argon2). Jangan menyimpan atau mencatat password mentah.
- Rahasia (API key, secret JWT, password database) disimpan di **`.env`**. Jangan ditulis di kode, contoh, atau log.
- Sediakan `.env.example` berisi nama variabel tanpa nilai asli.
- JWT memiliki masa berlaku.
- API key di aplikasi bisa dibongkar dari APK. Keamanan utama bertumpu pada login JWT dan pembatasan peran di server.
- Jangan menaruh kredensial asli di kode Flutter.

## 9. Status Fase

**Fase saat ini: Fase 1 (frontend Flutter dengan data mock).**

| Fase | Fokus |
|---|---|
| 1 | Seluruh layar Flutter dengan data mock yang mengikuti kontrak API (`T-01` sampai `T-30`) |
| 2 | `bengkelpintar_api` dan PostgreSQL (`B-01` sampai `B-09`) |
| 3 | Dataset, pelatihan, dan pemasangan model (`B-10`, `B-11`), lalu sambungan Flutter ke API (`B-13` sampai `B-16`) |
| 4 | Pengujian dan penyusunan skripsi |

Kerjakan hanya tugas yang sedang diminta. Jangan membangun tugas atau fase berikutnya tanpa diminta. Pengguna akan memperbarui bagian ini saat berpindah fase.

## 10. Batasan (Jangan Dilakukan)

- Jangan menambah fitur di luar lingkup `docs/PRD.md`, termasuk: mode offline-first, pembayaran digital (QRIS), printer Bluetooth, integrasi WhatsApp atau Google Drive, asisten AI, iOS.
- Jangan menambah database lain (Firebase, MongoDB) dan jangan menambah Alembic.
- Jangan mengubah struktur folder atau menamai ulang folder tanpa bertanya.
- **Jangan mengubah file di luar batas folder tugas** (lihat bagian 3).
- Jangan menyentuh folder lain di luar `C:\bengkel` (misalnya proyek `sentikampus*`).
- Jangan menambah dependensi besar tanpa alasan. Sebutkan alasannya bila menambah paket.
- Jangan memakai font, gambar, atau ikon yang dimuat dari internet. Semua aset dibundel.
- Jangan mengubah keputusan desain di `docs/DESIGN.md` tanpa bertanya.
- Jangan menjalankan perintah destruktif (hapus data, drop tabel, `git reset --hard`, hapus folder) tanpa konfirmasi pengguna.
- Jangan mengarang data dataset atau hasil evaluasi model. Angka akurasi hanya boleh berasal dari hasil pelatihan nyata.

## 11. Cara Bekerja

1. Baca `TASKS.md` dan bagian relevan `docs/PRD.md` dan `docs/DESIGN.md` sebelum memulai. Kerjakan **satu tugas per langkah**, sesuai urutan.
2. Jika permintaan ambigu atau bertentangan dengan PRD, **tanyakan dahulu**, jangan menebak.
3. Kerjakan perubahan kecil dan bertahap, satu fitur atau satu layar per langkah.
4. Setelah selesai, jalankan pemeriksaan yang relevan (`flutter analyze`, `flutter test`, `pytest`) dan laporkan hasilnya jujur, termasuk yang gagal.
5. Akhiri dengan ringkasan singkat: file apa yang dibuat atau diubah, dan apa yang belum selesai. Centang tugas di `TASKS.md`. Centang halaman di `docs/HALAMAN.md` hanya setelah pengguna menyetujui tampilannya.
6. Jika menemukan inkonsistensi antara PRD dan kode, laporkan kepada pengguna.
7. Gunakan skill dan MCP jika relevan dengan tugas yang sedang dikerjakan.

### Gerbang Persetujuan

Tidak ada gerbang berhenti antar-tugas untuk rangkaian yang diminta pengguna.
Agent tetap wajib menjalankan pemeriksaan setelah setiap tugas, mencatat
selisih visual/keputusan yang tidak dapat ditentukan, dan tidak mencentang
halaman di `docs/HALAMAN.md` sebelum pengguna menyetujui tampilannya.

## 12. Catatan Tambahan

- **Mode jaringan:** laptop adalah server sementara (demo dan pengujian). Setelah semuanya benar, server dipindah ke VPS dengan HTTPS (`docs/PRD.md` bagian 8.6).
- **Alamat server** tertanam saat build lewat `--dart-define=API_BASE_URL=...` (demo: IP laptop, produksi: `https://api.<domain>`). Pengguna harian tidak mengisinya. Layar Pengaturan Server hanya untuk admin.
- **Android dan HTTP lokal:** build demo memakai `http://`, jadi aplikasi mengaktifkan `usesCleartextTraffic` di `AndroidManifest.xml` (tugas T-01). Build produksi memakai HTTPS. Firewall Windows harus mengizinkan port 8000.
- PostgreSQL hanya diakses dari laptop (`localhost`). Jangan membuka port database ke jaringan.
- Dataset gejala-kerusakan **belum tersedia** dan menyusul. Sampai tersedia, jangan menganggap ada model asli. Gunakan mock (frontend) atau aturan tiruan (B-08) untuk diagnosis.
- Estimasi akurasi, jumlah kelas, dan daftar gejala final belum diputuskan (lihat `docs/PRD.md` bagian 17).

## ALAT, SKILL, DAN MCP
- Gunakan skill dan MCP yang tersedia jika relevan dengan tugas, dan sebutkan apa yang dipakai di laporan akhir. Contoh: skill UI/UX atau Flutter untuk merancang dan memeriksa tampilan, context7 untuk dokumentasi Flutter/Dart/paket terbaru (jangan menebak API dari ingatan), playwright untuk memeriksa hasil di browser, codebase-memory-mcp untuk menelusuri kode.
- Jika skill atau MCP gagal atau tidak tersedia, kerjakan dengan cara lain dan laporkan; jangan berhenti.
- figcraft tidak dipakai (desain bukan dari Figma).

## TIDAK TERLIHAT BUATAN AI
Hasil kerja harus terlihat dibuat oleh pengembang dan desainer manusia yang teliti, bukan keluaran generik AI ("AI slop"). Aturan desain bagian DESIGN.md tetap menang bila ada pertentangan; aturan di bawah mengisi celahnya.

### Tampilan
1. Satu bahasa visual yang konsisten: satu keluarga warna utama (biru), jarak dan radius dari token, satu gaya ikon. Tidak ada gradasi ungu/indigo, neon, atau kombinasi warna acak.
2. Tidak ada dekorasi tanpa fungsi: tidak ada kilau, glassmorphism berlebihan, bayangan berlapis, blob, atau ilustrasi generik untuk mengisi ruang kosong.
3. Hierarki jelas: satu judul utama per layar, satu tombol utama, ukuran dan bobot teks bertingkat. Tidak semua elemen dibuat besar, tebal, atau berwarna.
4. Ikon hanya dari set yang ditetapkan (app_icons.dart), tidak memakai emoji sebagai ikon, dan tidak ada ikon yang dipasang hanya untuk memenuhi ruang.
5. Kartu dan daftar punya kerapatan yang masuk akal untuk bengkel: informasi yang dibutuhkan mekanik dan admin (plat, nominal, status) terlihat sekilas, bukan kartu besar berisi sedikit isi.
6. Data contoh terlihat nyata: nama orang Indonesia, plat nomor wajar, nominal rupiah masuk akal. Tidak ada "Lorem ipsum", "John Doe", "Item 1", atau angka bulat berurutan yang mencurigakan.
7. Keadaan kosong, memuat, dan error memiliki teks dan tindakan yang spesifik, bukan ilustrasi atau pesan generik.

### Teks di aplikasi
8. Bahasa Indonesia sehari-hari yang natural dan singkat, sesuai teks baku di DESIGN.md. Tidak ada gaya brosur atau iklan ("Solusi canggih", "Pengalaman tanpa batas", "Revolusi bengkel"), tidak ada tanda seru berlebihan, tidak ada emoji, dan tidak ada kalimat basa-basi.
9. Label tombol berupa kata kerja pendek ("Simpan", "Tambah item", "Finalisasi").

### Kode dan dokumen
10. Tidak ada komentar yang hanya mengulang isi kode, komentar berbahasa template ("// TODO: implement", "// Build the UI"), atau komentar sisa keluaran otomatis. Komentar hanya untuk alasan yang tidak jelas dari kode.
11. Tidak ada abstraksi, lapisan, atau paket yang tidak dibutuhkan. Nama class, fungsi, dan variabel spesifik terhadap domain bengkel, bukan generik (Manager, Helper, Utils, Data1, temp).
12. Kode seragam: gaya, penamaan, dan pola yang sama di seluruh proyek, seolah ditulis satu orang. Tidak ada file duplikat atau versi cadangan.
13. Dokumen dan pesan laporan ditulis lugas: tanpa pembuka ("Tentu!"), tanpa penutup basa-basi, tanpa klaim berlebihan ("sempurna", "100%", "tanpa bug"), tanpa emoji.
14. Jika ragu apakah sesuatu terlihat seperti keluaran AI generik, ambil versi yang lebih sederhana dan spesifik.

## MODE CEPAT

MODE CEPAT (bawaan untuk perbaikan kecil dan revisi tampilan; pengguna menguji
sendiri di HP):
1. Kerjakan HANYA yang diminta. Tidak ada audit seluruh layar, perapian tambahan,
   atau perubahan di luar permintaan. Jika ada masalah serupa di layar lain,
   sebutkan satu baris di laporan, jangan diperbaiki kecuali diminta.
2. Pemeriksaan: cukup dart format dan flutter analyze (nol warning). Jalankan
   flutter test hanya bila logika berubah atau test yang ada pasti terdampak.
   Jangan menambah test baru untuk perubahan tampilan murni. Jangan memakai
   Playwright, perbandingan screenshot, atau build web.
3. Jangan build APK kecuali diminta. Pengguna memakai flutter run (hot reload).
4. Dokumen: perbarui DESIGN.md hanya bila token atau aturan desain berubah, cukup
   satu baris. Jangan membuat file catatan baru.
5. Jangan mencentang HALAMAN.md atau TASKS.md.
6. Laporan maksimal 5 baris: apa yang diubah, file, dan yang perlu dicek di HP.
7. Untuk perubahan besar yang menyentuh banyak layar, kerjakan secepat mungkin dan
   berhenti di titik yang bisa dites; jangan menunggu semua selesai bila diminta
   bertahap.
