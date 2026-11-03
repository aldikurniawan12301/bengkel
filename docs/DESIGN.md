# DESIGN.md: Panduan UI/UX BengkelPintar (v2.2)

Panduan tampilan, perilaku, data, teks, dan aksesibilitas untuk aplikasi Flutter
BengkelPintar. Agent wajib membaca dokumen ini sebelum membuat atau mengubah
layar. Dokumen lain: `PRD.md`, `HALAMAN.md`, `TASKS.md`, dan `AGENTS.md`.

**Perubahan v2.1:** gradasi header dibuat full biru, tidak ada indigo/ungu.
Ujung gradasi memakai `gradientEnd` (`#1B43C2`). Font global adalah **Plus
Jakarta Sans** 400/500/600/700, dibundel tanpa unduhan runtime. Poppins dipakai
pada layar yang menetapkannya. Ikon Material Symbols dapat berupa Outlined atau
Rounded dan selalu dipanggil lewat satu file `app_icons.dart`.

**Perubahan v2.2:** radius header dan navigasi bawah menjadi 12 dp; header H1
200 dp, H2 104 dp, H3 148 dp, H4 105 dp. Header daftar dibuat ringkas. Beranda
memakai statistik empat kolom, tindakan, menu lain, dan diagnosis terbaru tanpa
banner Diagnosis Cepat atau pil Ringkasan Hari Ini. Kartu daftar memakai border
tipis, nominal warna `textTitle`, dan daftar tidak memakai FAB. Label navigasi
sejajar; tinggi isi 60 dp. Header isi 56 dp di bawah inset status; isi layar mulai 16 dp setelah header; form dan tombol memakai radius 12 dp.

**Perubahan v2.0:** paket ikon diputuskan: **Material Symbols gaya outline**
(paket `material_symbols_icons`). Bagian 18 kini berupa tabel fungsi ke nama
ikon yang pasti, dan semua ikon dipanggil lewat satu file `app_icons.dart`,
bukan ditulis langsung di layar.

**Perubahan v1.9:** token warna aksen yang tidak digunakan dihapus. Ditambah token warna lembut `successSoft`, `warningSoft`, `dangerSoft`, dan `infoSoft` untuk latar badge status, supaya konsisten di semua layar. Tidak ada warna baru. Ditambah aturan pemakaian oranye.

**Perubahan v1.8:** lengkung bawah header biru dibuat lebih landai (radius 32 menjadi 20), tinggi H2, H3, H4 sedikit dipangkas (120 menjadi 112, 200 menjadi 188, 180 menjadi 168), kartu yang menimpa header 60 menjadi 48 dp, dan lingkaran hiasan dibuat lebih tipis dan lebih sedikit.

**Perubahan v1.7:** navigasi bawah menjadi bar penuh kiri-kanan (margin 0, sudut atas melengkung, area aman bawah di dalam bar). Aplikasi tidak dibungkus bingkai atau canvas, dan tidak menggambar jam, sinyal, Wi-Fi, atau baterai (bilah status digambar oleh Android). Ditambah aturan area aman kiri-kanan dan cara memakai area aman (satu cara saja). Sketsa tidak lagi menggambar isi bilah status.

**Perubahan v1.5:** laptop diperlakukan sebagai server sungguhan. Alamat server tertanam saat build, layar Pengaturan Server (2) hanya untuk admin dan dibuka dari Profil, memakai satu kolom URL (tanpa kolom port), dan tautannya dihapus dari Login. Teks layar Server Tidak Terjangkau memakai bahasa awam.

**Perubahan v1.3:** halaman Daftar Transaksi (9) kini juga dipakai mekanik sebagai "Draft Saya", menu cepat Beranda dan menu Profil dilengkapi (Data Master, Pengaturan Bengkel, Kelola Kategori), dan angka pada sketsa Daftar Transaksi disamakan dengan data baku.

**Perubahan v1.1:** aturan bilah status (tidak boleh ada strip putih di atas), kontrol form, grafik dan tabel, keadaan komponen, sketsa pola layar, data contoh baku, teks baku, ikon, dan logo.

---

## Perubahan Profil dan Transaksi Baru

- Profil memakai header H3 ringkas: avatar 64 dp di kiri, nama, dan badge peran di kanan. Menu dikelompokkan ke kartu radius 12 dengan judul muted **Akun**, **Bengkel** (admin saja), dan **Aplikasi**. Setiap baris memakai kotak ikon lembut 36 dp, label, panah, serta pemisah tipis. **Keluar** adalah tombol outline merah penuh tinggi 48 dengan versi aplikasi di bawahnya.
- Layar **Transaksi** dan **Draft Saya** menampilkan tombol utama **Transaksi Baru** di antara pencarian dan chip filter. Tombol memakai ikon tambah, tinggi 48, radius 12, dan membuka Draft Transaksi kosong. Pintasan yang sama tersedia pada aksi cepat Beranda. Tidak memakai FAB.


### 0.1 Ukuran dan Orientasi
| Hal | Nilai |
|---|---|
| Perangkat | **Android, potret (portrait)** |
| Ukuran acuan | **360 x 800 dp** |
| Rentang yang harus tampil benar | Lebar **320 sampai 412 dp**, tinggi sekitar 640 sampai 915 dp |
| Ukuran teks sistem | Benar sampai **130%** |
| Orientasi | Hanya potret (dikunci lewat kode). Tidak ada tampilan lanskap |
| Tampilan | **Layar penuh dari tepi ke tepi (edge-to-edge)** |

Aturan:
- **Layout fleksibel.** Lebar konten = lebar layar dikurangi 40 (margin kiri dan kanan 20). Jangan menulis lebar tetap 320 atau 360 di kode.
- Tinggi kartu, tombol, dan baris mengikuti isi, bukan angka tetap, supaya teks yang diperbesar tidak terpotong.
- Tidak boleh ada **overflow** (strip kuning-hitam Flutter) di lebar 320, 360, maupun 412.
- Tidak ada margin atau latar di sekeliling layar. Warna latar halaman (biru muda `#F3F6FF`) hanya berada di dalam layar, di balik kartu.
- **Tanpa bingkai ponsel dan tanpa canvas.** Aplikasi langsung memenuhi layar perangkat. Ukuran 360 x 800 hanya acuan uji, bukan wadah yang digambar.

### 0.2 Bilah Status (Bagian Atas Layar)
Tinggi bilah status Android sekitar **24 dp** (di kode pakai `MediaQuery.of(context).padding.top`, jangan angka tetap). Aturannya:

1. **Bilah status transparan.** Warna latar halaman atau header **menerus sampai tepi paling atas layar**. Tidak boleh ada strip putih atau abu-abu di atasnya.
2. Isi bilah status (jam, sinyal, Wi-Fi, baterai) **digambar oleh Android, bukan oleh aplikasi**. Aplikasi tidak boleh menggambar jam, sinyal, Wi-Fi, atau baterai sendiri (tidak ada jam palsu di layar mana pun, termasuk Splash). Ikon sistem **berwarna putih** karena berada di atas biru, diatur lewat `SystemUiOverlayStyle.light`.
3. **Setiap layar memakai header biru** (kecuali dialog dan bottom sheet), jadi bilah status selalu berada di atas biru. Tidak ada layar dengan bagian atas putih.
4. Isi header (tombol kembali, judul) dimulai **di bawah 24 dp** bilah status, bukan menimpanya.
5. Pada Splash, seluruh layar biru sehingga bilah status ikut biru.

```
y=0   +----------------------------+
      | (bilah status sistem)       |  <- 24dp, TRANSPARAN, digambar Android,
y=24  |                             |     latar biru menerus ke atas,
      |  <-    Judul Layar    (o)   |     ikon putih
y=80  |                             |
```

Implementasi Flutter:
- Aktifkan mode edge-to-edge dan buat bilah status transparan dengan ikon terang (`SystemUiOverlayStyle.light` dengan `statusBarColor: Colors.transparent`).
- Latar header digambar sampai tepi atas, dan konten diberi padding atas `MediaQuery.of(context).padding.top`.
- Header yang ikut tergulir tetap menyisakan **strip biru setinggi bilah status** di atas (misalnya `SliverAppBar` dengan `pinned: true`), supaya tidak ada area putih saat digulir.

### 0.3 Bagian Bawah Layar
- Bilah gestur sistem sekitar **16-24 dp**. Latar halaman menerus sampai tepi bawah.
- **Navigasi bawah (bar penuh):** menempel di tepi kiri, kanan, dan bawah layar (margin 0). Tinggi isi 60, ditambah `MediaQuery.of(context).padding.bottom` **di dalam bar**, sehingga latar biru menerus sampai tepi bawah. Sudut atas melengkung 12, sudut bawah lurus. Label sejajar termasuk Diagnosis.
- **Tombol utama mengambang** (pada layar tanpa navigasi): tinggi 52, margin 16 dari kiri, kanan, dan bawah, ditambah area aman bawah.
- **Padding bawah daftar:** 96 dp **ditambah `padding.bottom`** bila ada navigasi bawah (64 tinggi bar + 16 tonjolan tombol Diagnosis + 16 jarak), dan 84 dp ditambah `padding.bottom` bila ada tombol mengambang, supaya konten terakhir tidak tertutup. Tinggi bar disimpan sebagai satu konstanta di `app_spacing.dart`, jangan menulis angka 64 atau 96 di layar.

### 0.4 Jenis Header
Setiap halaman di `HALAMAN.md` memakai salah satu jenis header berikut. **Tinggi sudah termasuk bilah status.**

| Kode | Nama | Tinggi total (perkiraan) | Isi | Dipakai di |
|---|---|---|---|---|
| **H0** | Biru penuh | Seluruh layar | Latar biru penuh, tanpa app bar | Splash |
| **H1** | Header Beranda | 200 | Avatar, nama, peran, notifikasi, statistik empat kolom | Beranda |
| **H2** | Header kecil | 104 | Tombol kembali, judul kiri, aksi kecil opsional. Lengkung bawah 12 | Form, layar sederhana |
| **H3** | Header detail | 148 | Seperti H2, ditambah kartu putih yang menimpa 48 dp | Hasil Diagnosis, Detail, Profil, Login, Pengaturan Server |
| **H4** | Header daftar | 105 | Judul kiri ringkas, aksi kecil di kanan | Daftar (Riwayat, Transaksi, Katalog, Laporan, dll.) |

### 0.5 Grid dan Area Aman (Fleksibel)
- Margin kiri dan kanan: **20 dp**. Lebar konten efektif = lebar layar - 40 (320 pada layar 360, 280 pada layar 320).
- Grid produk 2 kolom: lebar kartu = (lebar konten - 12) / 2, jarak antar kolom 12 (154 pada layar 360).
- Teks tidak boleh melewati margin 20 dp. Judul panjang dipotong dua baris dengan elipsis, chip dan tab bisa digulir horizontal.
- Elemen penting tidak boleh berada di area bilah status atau bilah gestur. Pakai area aman dari sistem, bukan angka tetap.
- **Area aman kiri dan kanan:** margin konten = 20 + `MediaQuery.padding.left` atau `right` (biasanya 0 pada potret, lebih besar pada HP dengan lekuk atau tepi layar melengkung). Pada navigasi bawah, latar tetap penuh sampai tepi, sedangkan isinya diberi padding horizontal minimal 8 ditambah inset yang sama.
- **Satu cara memakai area aman:** pakai `MediaQuery.padding` secara manual. Jangan membungkus seluruh layar dengan `SafeArea` (menimbulkan strip putih di atas) dan jangan menambah padding yang sama dua kali. Bila memakai `SafeArea`, hanya pada bagian isi dengan `top: false`.

### 0.6 Catatan Implementasi Flutter
- **Edge-to-edge:** aktifkan mode `SystemUiMode.edgeToEdge`, bilah status transparan dengan ikon terang (`SystemUiOverlayStyle`). Dipusatkan di `lib/core/theme/app_system_ui.dart`.
- **Orientasi:** kunci potret lewat `SystemChrome.setPreferredOrientations`.
- **Header:** `BlueHeader` menggambar gradasi sampai tepi atas, isinya diberi padding atas sebesar `MediaQuery.of(context).padding.top`. Untuk header yang ikut tergulir, pakai `CustomScrollView` dengan `SliverAppBar` (`pinned: true`) supaya strip biru di atas tidak hilang.
- **Keyboard:** form dibungkus `SingleChildScrollView`. Kolom yang sedang diisi dan tombol utama harus tetap terlihat saat keyboard muncul (pertimbangkan `MediaQuery.of(context).viewInsets.bottom`).
- **Area aman bawah:** navigasi bawah menambahkan `MediaQuery.of(context).padding.bottom` di dalam bar. Tombol utama mengambang menambahkannya ke margin bawahnya.
- **Tanpa pembungkus tampilan:** tidak ada `DevicePreview`, `Center` atau `ConstrainedBox` berukuran tetap, atau `Container` berwarna di luar `Scaffold`. `MaterialApp` langsung memenuhi layar.
- **Teks diperbesar:** jangan memberi tinggi tetap pada widget berisi teks. Pakai `Flexible`, `Wrap`, `maxLines`, dan `TextOverflow.ellipsis`. Uji dengan skala teks 1.3.
- **Daftar panjang:** `ListView.builder`, dengan padding bawah sesuai bagian 0.3.
- **Hiasan:** lingkaran konsentris dan gradasi dibungkus `IgnorePointer` agar tidak menangkap ketukan.
- **Bottom sheet:** `showModalBottomSheet` dengan `isScrollControlled: true`, tinggi maksimum 85% layar.
- **Aset:** font dan ikon dibundel. Tidak ada gambar dari internet.

### 0.7 Pemeriksaan Hasil di Emulator atau HP
Agent **tidak bisa melihat tampilan**, jadi jangan menulis "sudah sesuai desain" tanpa pengguna memeriksanya. Pemeriksaan dilakukan pengguna di emulator atau HP.

| Pemeriksaan | Benar | Salah |
|---|---|---|
| Lebar layar 320, 360, 412 | Tidak ada overflow, susunan tetap rapi | Strip kuning-hitam, elemen saling menimpa |
| Bagian atas | Biru menerus sampai tepi, ikon bilah status putih | Strip putih atau abu-abu di atas |
| Teks sistem 130% | Teks tidak terpotong, tombol tetap terjangkau | Teks terpotong atau menimpa elemen lain |
| Keyboard muncul | Kolom aktif dan tombol utama terlihat | Tertutup keyboard |
| Bagian bawah | Konten terakhir tidak tertutup navigasi atau tombol | Konten terpotong di bawah |
| Orientasi | Tetap potret | Berputar ke lanskap |
| Bingkai dan bilah status | Aplikasi memenuhi layar, bilah status hanya milik Android | Ada canvas atau bingkai di belakang, atau jam dan ikon sinyal gambaran aplikasi |
| Navigasi bawah | Penuh kiri-kanan, biru menerus sampai tepi bawah, ikon tidak tertimpa bilah gestur | Ada celah di kiri, kanan, atau bawah, atau ikon tertimpa bilah gestur |

**Gerbang persetujuan:** setelah T-02, T-08, dan T-10, agent berhenti dan menunggu pengguna memeriksa tabel di atas (lihat `AGENTS.md` bagian 11).

---

## 1. Sumber Referensi

Gaya tampilan mengikuti dua referensi dari pengguna (aplikasi lowongan kerja dan aplikasi toko elektronik). Gambarnya **tidak disertakan di proyek**, jadi seluruh gaya yang dipakai sudah dituangkan sebagai aturan tertulis di file ini. Jangan menyalin logo, foto orang, nama merek, atau teks dari referensi mana pun.

| Referensi | Dipakai untuk |
|---|---|
| **Referensi A**: UI kit "Apply Job" (biru, kartu bertumpuk) | Header biru melengkung, kartu putih menimpa header, kartu statistik di header, tab pil, tag kecil berwarna, tombol CTA pil dengan panah bulat, navigasi bawah, daftar centang bulat biru, pemisah garis putus-putus |
| **Referensi B**: aplikasi e-commerce "TechHub" (biru royal, putih bersih) | Bar atas dengan lencana notifikasi, kolom pencarian pil dengan tombol filter bulat, banner gelap bergradasi, deret ikon kategori bulat, kartu produk dengan lencana dan tombol bulat, tombol tengah menonjol di navigasi bawah, judul bagian dengan "Lihat Semua" |

### 1.1 Karakter Gaya yang Dipertahankan
- **Modern, bersih, ramah.** Banyak ruang putih, sudut sangat membulat.
- **Satu warna utama: biru.** Aksen hanya untuk status dan lencana.
- **Bentuk pil dan lingkaran** untuk semua elemen interaktif (tombol, tag, chip, tab, kolom cari). Satu-satunya pengecualian: navigasi bawah berupa bar penuh (bagian 5.7).
- **Kartu putih** di atas latar biru muda sangat tipis, dengan garis tipis atau bayangan lembut.
- **Tipografi geometris tebal** untuk judul, abu-abu tenang untuk keterangan.
- **Header biru berhias lingkaran samar** (konsentris) sebagai ciri khas.

### 1.2 Catatan Penyesuaian untuk Bengkel
- Referensi adalah aplikasi lowongan kerja dan toko elektronik. Isi diganti ke konteks bengkel (diagnosis, transaksi, stok), **gaya visualnya yang dipakai**.
- Foto orang di referensi **tidak dipakai**. Gantinya: ikon, ilustrasi sederhana, atau bentuk geometris bertema motor dan perkakas.
- Aplikasi berjalan di **jaringan lokal tanpa internet** (lihat `PRD.md` bagian 8.4), jadi **tidak boleh ada font, gambar, atau ikon yang dimuat dari internet**. Semua aset dibundel di `assets/`.

---

## 2. Warna

Nilai heksadesimal di bawah adalah **estimasi dari gambar referensi**, bukan nilai pasti. Boleh disetel sedikit, tapi **semua warna hanya boleh didefinisikan sekali** di `lib/core/theme/app_colors.dart` dan dipakai lewat nama. Dilarang menulis kode heksadesimal langsung di layar.

### 2.1 Warna Utama (Biru)
| Token | Hex | Pemakaian |
|---|---|---|
| `primary` | `#2457E6` | Tombol utama, header, tab aktif, ikon aktif, tautan |
| `primaryDark` | `#1B43C2` | Tombol saat ditekan, bagian header yang lebih gelap |
| `primaryDeep` | `#14338F` | Gradasi banner gelap (ujung terang) |
| `navy` | `#0B1B4D` | Banner gelap (ujung gelap), tooltip grafik |
| `primarySoft` | `#E6ECFF` | Latar chip tidak aktif, tombol tonal, latar ikon bulat |
| `primaryTint` | `#F3F6FF` | Latar halaman (putih kebiruan tipis) |
| `gradientEnd` | `#1B43C2` | Ujung gradasi header, sama dengan `primaryDark` |
| `lightBlue` | `#9DB8FF` | Teks aksen di atas latar biru (contoh: kata "Pintar" pada logo), garis grafik sekunder |

### 2.2 Netral
| Token | Hex | Pemakaian |
|---|---|---|
| `surface` | `#FFFFFF` | Kartu, kolom input, bar bawah |
| `background` | `#F3F6FF` | Latar halaman (sama dengan `primaryTint`) |
| `textTitle` | `#101828` | Judul dan teks penting |
| `textBody` | `#475467` | Teks isi |
| `textMuted` | `#667085` | Keterangan, placeholder, label kecil |
| `border` | `#E4E7EC` | Garis kartu, garis input, pemisah |
| `disabled` | `#D0D5DD` | Elemen nonaktif |
| `onPrimaryMuted` | putih 70% | Teks sekunder di atas biru |

### 2.3 Warna Status
| Token | Hex | Pemakaian |
|---|---|---|
| `success` | `#12B76A` | Urgensi rendah, transaksi final, stok aman |
| `warning` | `#F79009` | Urgensi sedang, draft, stok menipis, label "perkiraan" |
| `danger` | `#E5484D` | Urgensi tinggi, hapus, error, stok habis |
| `info` | `#2457E6` | Sama dengan `primary` |

**Token latar lembut status** (bukan warna baru: warna status yang sama pada opasitas 12% di atas putih, diberi nama supaya hasilnya konsisten):

| Token | Hex | Dari | Pemakaian |
|---|---|---|---|
| `successSoft` | `#E3F6ED` | `success` | Latar badge Rendah, Final, Aktif, kotak status "Terhubung" |
| `warningSoft` | `#FEF2E1` | `warning` | Latar badge Sedang, Draft, Stok Menipis, label "Perkiraan", banner peringatan |
| `dangerSoft` | `#FCE9E9` | `danger` | Latar badge Tinggi, Habis, kotak error |
| `infoSoft` | `#E6ECFF` | `primary` | Sama dengan `primarySoft` |

Teks dan ikon di atas latar lembut memakai warna status penuh. Token ini didefinisikan sekali di `app_colors.dart`, dilarang menghitung opasitas sendiri di layar.

### 2.4 Aturan Pemakaian
1. Tombol utama dan elemen aktif **selalu `primary`**.
2. Status memakai warna status. **Jangan memakai warna lain untuk menandai urgensi.**
3. Teks putih hanya di atas `primary`, `primaryDark`, `navy`, atau warna status penuh.
4. Maksimal **satu warna aksen non-biru** per kartu.
   - **Oranye (`warning`) hanya untuk status** (Sedang, Draft, Stok Menipis, Perkiraan, peringatan). Jangan dipakai untuk dekorasi, ikon biasa, atau tombol.
   - Bila satu layar sudah banyak oranye (misalnya Beranda), pakai badge lembut (`warningSoft` + teks oranye), bukan badge oranye penuh, supaya tidak ramai.
5. Tidak ada mode gelap (dark mode) di fase ini.

---

## 3. Tipografi

**Font global: Plus Jakarta Sans.** Dibundel di
`assets/fonts/` dan didaftarkan di `pubspec.yaml`; sumber upstream adalah
Google Fonts CSS resmi Plus Jakarta Sans, bobot 400, 500, 600, dan 700.
**Dilarang memakai paket `google_fonts` yang mengunduh saat runtime**, karena
aplikasi tanpa internet. Poppins 400/500/600/700 juga dibundel untuk layar yang
memakainya.

| Gaya | Ukuran | Bobot | Warna | Pemakaian |
|---|---|---|---|---|
| `display` | 28 | Bold | putih / `textTitle` | Judul besar di header ("Transaksi") |
| `title` | 20 | SemiBold | `textTitle` | Judul layar di app bar, judul kartu besar |
| `heading` | 16 | SemiBold | `textTitle` | Judul bagian ("Gejala Terpilih") |
| `subheading` | 14 | SemiBold | `textTitle` | Judul kartu, nama item |
| `body` | 14 | Regular | `textBody` | Teks isi |
| `bodySmall` | 12 | Regular | `textMuted` | Keterangan, tanggal, lokasi |
| `label` | 12 | Medium | sesuai konteks | Teks tag, chip, tab |
| `button` | 14 | SemiBold | putih | Teks tombol |
| `overline` | 11 | SemiBold, kapital, jarak huruf 0.5 | `primary` | Label kecil di atas judul ("HASIL DIAGNOSIS") |
| `statNumber` | 24 | Bold | putih | Angka statistik di header |

Aturan:
- Gaya teks hanya didefinisikan di `lib/core/theme/app_text.dart` dan dipakai lewat nama gaya. Font global token adalah Plus Jakarta Sans; style layar yang memang memakai Poppins menggunakan token eksplisit, bukan nama font langsung di layar.
- Dukung pembesaran teks sistem sampai 130% tanpa teks terpotong atau menimpa elemen lain.
- Judul panjang dipotong dua baris dengan elipsis. Jangan mengecilkan font untuk memaksa muat.

---

## 4. Bentuk, Jarak, dan Bayangan

### 4.1 Sudut (Radius)
| Token | Nilai | Pemakaian |
|---|---|---|
| `radiusSm` | 8 | Gambar kecil, indikator, kotak centang (6) |
| `radiusMd` | 12 | Kolom input teks |
| `radiusLg` | 16 | Kartu daftar |
| `radiusXl` | 24 | Kartu besar, kartu yang menimpa header, banner, dialog, sudut atas navigasi bawah |
| `radiusHeader` | 20 | Lengkung bawah header biru (landai, jangan dibesarkan) |
| `radiusFull` | 999 | Tombol, tag, chip, tab, kolom cari |

### 4.2 Jarak (kelipatan 4)
| Token | Nilai |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 24 |
| `xxl` | 32 |

- Margin tepi halaman: **20**.
- Padding dalam kartu: **16**.
- Jarak antar kartu dalam daftar: **12**.
- Jarak antar bagian: **24**.
- Area sentuh minimum semua elemen interaktif: **48 x 48**.

### 4.3 Bayangan dan Garis
- Kartu daftar: garis `border` 1px, **tanpa bayangan**.
- Kartu menonjol (produk, banner): bayangan lembut, blur 16, offset y 4, hitam opasitas 6%.
- Navigasi bawah (bar penuh): bayangan tipis ke atas, blur 16, offset y -2, `primary` opasitas 15%.
- Hindari bayangan tebal atau berlapis.

### 4.4 Ikon
- **Paket ikon: Material Symbols Rounded**, pengaturan tetap di seluruh aplikasi: **fill 0 (outline), weight 400, grade 0, optical size 24**. Satu keluarga, satu pengaturan. Jangan campur dengan `Icons.xxx` bawaan Flutter, jangan campur varian terisi (filled) atau tajam (sharp).
- Paket `material_symbols_icons` dibundel di aplikasi (jalan tanpa internet). Alasan menambah dependensi: ikon bawaan Flutter tidak punya varian outline membulat yang sesuai gaya. Pengaruh ke ukuran aplikasi dicek saat build pertama.
- Ukuran: 20 (dalam tag/teks), 24 (standar), 28-32 (ikon kategori).
- Ikon dalam lingkaran: lingkaran `primarySoft` dengan ikon `primary`, atau lingkaran `primary` dengan ikon putih untuk aksi utama.
- **Semua ikon dipanggil lewat `lib/core/theme/app_icons.dart`** (satu konstanta per fungsi, misalnya `AppIcons.home`). Layar dilarang menulis `Icons.xxx` atau `Symbols.xxx` langsung. Menambah ikon baru = menambah satu baris di `app_icons.dart` dan satu baris di tabel bagian 18.
- Daftar ikon baku (fungsi ke nama ikon) ada di bagian 18.

---

## 5. Komponen

Semua komponen dibuat sekali di `lib/core/widgets/` dan dipakai ulang. **Jangan membuat gaya tombol, tag, atau kartu sendiri di dalam layar.**

### 5.1 Tombol
| Komponen | Tampilan | Pemakaian |
|---|---|---|
| `AppButton.primary` | Pil penuh, latar `primary`, teks putih, tinggi 52. Boleh dengan **lingkaran putih berisi panah** di ujung kanan | Aksi utama layar |
| `AppButton.secondary` | Pil penuh, garis `primary` 1.5px, latar putih, teks `primary` | Aksi kedua |
| `AppButton.tonal` | Pil penuh, latar `primarySoft`, teks `primary` | Aksi ringan di dalam kartu |
| `AppButton.small` | Pil, tinggi 36, teks 12 | Tombol status pada kartu transaksi |
| `AppButton.danger` | Pil, latar `danger` atau garis `danger` | Hapus, nonaktifkan |
| `CircleIconButton` | Lingkaran 40-44, ikon di tengah, latar `primarySoft` atau putih translusen di atas header | Bel, profil, filter, kembali |

Aturan:
- Satu layar hanya punya **satu tombol utama**.
- Tombol utama pada layar detail **mengambang di bawah** dengan bayangan biru.
- Nonaktif: latar `disabled`, teks putih. Saat memproses: indikator berputar di dalam tombol dan ketukan dinonaktifkan.

### 5.2 Kolom Pencarian dan Input
- **Pencarian:** pil penuh, latar putih, garis `border`, ikon kaca pembesar di kiri, placeholder `textMuted`, tinggi 48. Di kanan, **tombol filter** berbentuk kotak membulat (radius 14) berwarna `primary` dengan ikon putih.
- **Input teks (form):** radius 12, garis `border` 1px, latar putih, tinggi 52, label di atas, garis `primary` 1.5px saat fokus, garis `danger` + pesan merah kecil saat error.
- Pesan error selalu di bawah kolom, bahasa Indonesia, spesifik.

### 5.3 Chip dan Tab (Filter)
- **Aktif:** pil, latar `primary`, teks putih, bobot Medium.
- **Tidak aktif:** pil, latar `primarySoft`, teks `textTitle`.
- Deret chip bisa digulir horizontal.

### 5.4 Tag dan Lencana
- **Tag kecil:** pil, tinggi 22-24, teks putih 11 Medium, latar `primary`.
- **Lencana status** di pojok kiri atas kartu: pil sangat kecil, latar warna status, teks putih kapital 10 Bold.
- **Lencana angka** pada ikon bel: lingkaran 16-18 `primary` (atau `danger`), angka putih.
- **Label urgensi:** `UrgensiBadge`: Rendah (`success`), Sedang (`warning`), Tinggi (`danger`). Selalu ada teks. Pada kartu daftar pakai varian lembut (latar `successSoft`, `warningSoft`, `dangerSoft`, teks warna penuh). Varian penuh (latar warna status, teks putih) hanya untuk lencana di pojok kartu produk dan di kartu hasil diagnosis.
- **Label status transaksi:** Draft (`warning`), Final (`success`).
- **Label "Perkiraan":** pil kecil `warning` lembut dengan ikon info, **wajib** di dekat setiap angka estimasi biaya.

### 5.5 Kartu
- **Kartu daftar:** putih, radius 16, garis `border`, padding 16. Ikon/avatar bulat di kiri, judul + subjudul di tengah, ikon aksi di kanan, tag di baris bawah, info kecil di baris paling bawah.
- **Kartu produk:** putih, radius 16, bayangan lembut. Lencana kiri atas, area ikon produk (kotak 64 `primarySoft`), nama (maks 2 baris), harga tebal, **tombol bulat biru kecil** di kanan bawah.
- **Kartu yang menimpa header:** putih, radius 24, menimpa header biru sekitar 48 dp, ikon bulat besar (64) setengah keluar di tengah atas.
- **Banner:** radius 24, gradasi `navy` ke `primary`, teks putih, tombol pil, hiasan lingkaran samar atau bentuk perkakas, titik indikator bila lebih dari satu.
- **Kartu angka besar** (Laporan): gradasi `primary` ke `gradientEnd`, teks putih, angka `display`.

### 5.6 Header Biru
- Latar `primary` dengan gradasi halus ke `gradientEnd`, sudut bawah melengkung `radiusHeader`, **menerus sampai tepi atas layar** (lihat bagian 0.2).
- **Hiasan lingkaran konsentris** sangat samar (putih opasitas 5-8%), ukuran sedang, **maksimal dua kelompok lingkaran** per header (satu di pojok kanan atas, satu opsional di kiri bawah) dan tidak boleh menutupi judul atau tombol. Widget `HeaderDecoration`.
- Lengkung bawah **landai** (`radiusHeader` 20). Jangan membesarkan lengkung karena terlihat menggembung dan berat.
- Jenis header H0 sampai H4 ada di bagian 0.4.

### 5.7 Navigasi Bawah
- **Bar penuh:** latar `primary`, lebar penuh layar (margin kiri, kanan, bawah = 0), tinggi isi 64 ditambah `padding.bottom` di dalam bar. Sudut atas radius 24, sudut bawah lurus. Bayangan tipis ke atas (bagian 4.3). Ini pengecualian dari aturan pil.
- **Isi bar:** lima slot sama lebar. Padding horizontal isi minimal 8 ditambah inset sistem kiri-kanan (bagian 0.5).
- **Item aktif:** ikon putih + label putih. **Tidak aktif:** putih opasitas 60%.
- **Tombol tengah menonjol (Diagnosis):** lingkaran 64, latar putih, ikon `primary`, cincin putih tebal, menonjol sekitar 16 di atas tepi atas bar, terpusat horizontal.

| Peran | Kiri 1 | Kiri 2 | **Tengah** | Kanan 1 | Kanan 2 |
|---|---|---|---|---|---|
| **Mekanik** | Beranda | Riwayat | **Diagnosis** | Draft | Profil |
| **Admin** | Beranda | Transaksi | **Diagnosis** | Katalog | Profil |

- Navigasi **disembunyikan** pada layar form, finalisasi, dan layar dengan tombol utama mengambang. Halaman mana yang memakai navigasi tercantum di `HALAMAN.md`.
- Menu **Katalog** membuka satu layar dengan dua tab: **Produk** dan **Jasa**.

### 5.8 Daftar Centang
- Lingkaran 20 `primary` dengan ikon centang putih, diikuti teks `body`.
- Dipakai untuk **komponen terkait**, **jasa terkait**, dan **langkah solusi**.

### 5.9 Pemisah
- Garis **putus-putus** `border` untuk memisah ringkasan dari isi di kartu detail.
- Garis biasa 1px `border` untuk pemisah item daftar.

### 5.10 Dialog, Snackbar, Sheet
- **Dialog konfirmasi:** radius 24, lebar 300, judul `heading`, dua tombol (kanan: utama, kiri: sekunder). Aksi merusak: tombol utama `danger`.
- **Snackbar:** melayang di atas navigasi, radius 16. Hijau (`success`), merah (`danger`), atau `navy` untuk info. Teks Indonesia singkat.
- **Bottom sheet:** sudut atas radius 24, pegangan kecil di tengah atas, latar putih, tinggi maksimum 85% layar. Dipakai untuk pemilih produk dan jasa, filter, penyesuaian stok, dan reset password.

### 5.11 Keadaan Khusus (Wajib di Setiap Layar Berdata)
| Keadaan | Tampilan |
|---|---|
| **Memuat** | Kerangka (skeleton) abu-abu muda berbentuk kartu dengan kilau halus. Bukan hanya spinner |
| **Kosong** | Ikon bulat `primarySoft` besar, judul singkat, satu kalimat penjelasan, tombol aksi bila relevan |
| **Error** | Ikon bulat `danger` lembut, pesan jelas, tombol "Coba Lagi" |
| **Server tidak terjangkau** | Ilustrasi sederhana, teks "Tidak dapat terhubung ke server" dengan penyebab umum, tombol "Coba Lagi". **Admin** juga melihat tautan "Pengaturan Server", **mekanik** melihat "Hubungi admin" (halaman 33) |
| **Akses ditolak** | Ikon gembok, teks "Halaman ini hanya untuk admin", tombol kembali (halaman 26) |

### 5.12 Kotak Centang, Radio, dan Sakelar
| Komponen | Tampilan |
|---|---|
| **Kotak centang** | Kotak 22 dp, radius 6, garis `border` 1.5px. Terpilih: latar `primary`, ikon centang putih |
| **Radio** | Lingkaran 22 dp, garis `border` 1.5px. Terpilih: garis `primary` dan titik `primary` 10 dp di tengah |
| **Sakelar (switch)** | Lebar 48, tinggi 28. Mati: lintasan `disabled`, bulatan putih. Hidup: lintasan `primary`, bulatan putih di kanan |
| **Kartu terpilih** | Kartu dengan kotak centang: bila terpilih garis `primary` 2px dan latar `primarySoft` sangat tipis |

Pemakaian: kotak centang di Form Gejala, radio untuk metode pembayaran bila tidak memakai chip, sakelar untuk status aktif/nonaktif di form produk, jasa, gejala, kerusakan, kategori, dan pengguna.

### 5.13 Dropdown dan Pemilih
- **Dropdown** tampil seperti input teks dengan ikon panah bawah di kanan. Mengetuknya membuka **bottom sheet** berisi pilihan (radio atau daftar), bukan menu kecil.
- **Pemilih tanggal:** ikon kalender di input. Dialog tanggal dengan warna utama `primary`, tanggal terpilih lingkaran `primary` berteks putih.
- **Pemilih periode (Laporan):** deret chip (Hari Ini, 7 Hari, Bulan Ini, Kustom). "Kustom" membuka dua pemilih tanggal.
- **Pemilih banyak (komponen terkait):** bottom sheet dengan pencarian dan daftar berkotak centang, tombol "Pilih" di bawah.

### 5.14 Pemilih Jumlah (QtyStepper)
- Tombol `-`: lingkaran 36, latar `primarySoft`, ikon `primary`. Nonaktif saat nilai 1 (abu-abu).
- Tombol `+`: lingkaran 36, latar `primary`, ikon putih.
- Angka di tengah `subheading`, lebar tetap 32, rata tengah.
- **Satu komponen dipakai di semua tempat** (keranjang, penyesuaian stok).

### 5.15 Tabel dan Baris Data
Untuk Laporan dan Detail Transaksi, **jangan memakai tabel lebar bergaris**. Pakai **daftar baris**:
- Satu baris: nama di kiri (`body`), nilai di kanan (`subheading`, rata kanan).
- Pemisah garis `border` 1px antar baris.
- Baris total: garis putus-putus di atasnya, teks tebal, `heading`.
- Pada data banyak kolom (misalnya laporan), tampilkan sebagai **kartu per item**, bukan kolom sempit.

### 5.16 Keadaan Komponen
| Keadaan | Aturan |
|---|---|
| **Normal** | Sesuai bagian 5 |
| **Ditekan** | Gelap sedikit ke `primaryDark`, skala 0.97 |
| **Fokus** | Garis `primary` 1.5-2px |
| **Terpilih** | Latar `primarySoft` atau `primary`, garis `primary` |
| **Nonaktif** | Latar `disabled`, teks putih atau abu-abu, tidak merespons ketukan |
| **Error** | Garis `danger` 1.5px, pesan merah 12 di bawah |
| **Memuat** | Indikator di dalam elemen, ketukan dinonaktifkan |

### 5.17 Gaya Nota
Nota tampil di **layar** dan **PDF** dengan gaya sama:
- Lebar kertas tampilan: 300 dp, di tengah layar, latar putih, radius 12, bayangan lembut, di atas latar `background`.
- Kop (tengah): ikon kecil, **nama bengkel** (`heading`), alamat dan telepon (`bodySmall`), bersumber dari Pengaturan Bengkel.
- Garis putus-putus, lalu info nomor nota, tanggal, kasir, pelanggan, dan plat (dua kolom, label `bodySmall`, isi `body`).
- Garis putus-putus, lalu daftar item (nama di kiri, "jumlah x harga" kecil di bawahnya, subtotal rata kanan).
- Garis putus-putus, lalu **Total** (`title`, rata kanan), metode bayar, dibayar, kembalian.
- Penutup tengah: "Terima kasih telah mempercayakan motor Anda kepada kami."
- Font nota: Poppins di layar. PDF memakai font yang sama (dibundel).

---

## 6. Pola Layar

Semua pola mengikuti bagian 0 (layout fleksibel, tanpa bingkai, tanpa strip putih di atas). Sketsa di bawah menunjukkan **urutan dan susunan**, bukan ukuran pasti. Baris "(bilah status sistem)" hanya penanda area milik Android, bukan sesuatu yang digambar aplikasi.

### 6.1 Splash (halaman 1) `H0`
- Latar `primary` penuh dengan gradasi halus ke `gradientEnd` (`primaryDark`) di bawah, **menerus sampai tepi atas** (bilah status ikut biru).
- Tampilkan hanya logo pengguna `assets/images/logo.png`, dipusatkan horizontal dan vertikal. Logo telah memuat nama **Bengkel Pintar**, sehingga teks nama tidak diulang.
- PNG transparan hasil penghapusan latar putih dari salinan `assets/images/logo_original.jpeg`; bentuk, warna, dan tulisan asli dipertahankan.
- Tidak ada tagline, subjudul, indikator memuat, atau nomor versi. Pemeriksaan sesi tetap berjalan dan navigasi dilakukan setelah splash.

```
+------------------------------+  y=0
|    (bilah status sistem)     |  latar biru menerus
|                              |
|       ( logo Bengkel Pintar )|
|                              |
+------------------------------+  y=800
        latar biru penuh
```

Logo yang sama dipakai pada header Login. Ikon launcher dan splash native Android
menggunakan logo PNG transparan dengan latar adaptive/splash `#2457E6`.

### 6.2 Beranda (halaman 4) `H1`
 Susunan ringkas untuk melihat status kerja dan tindak lanjut:

1. Header H1 biru: avatar inisial, nama, peran, tombol bel, empat kolom statistik sama lebar.
2. Kolom cari "Cari pelanggan atau plat" tanpa judul pembuka.
3. Admin melihat "Perlu tindakan" berdasarkan data draft dan stok; baris nol disembunyikan. Mekanik melihat draft miliknya.
4. Admin melihat grid empat kolom "Menu lain" untuk Laporan, Data gejala dan kerusakan, Pengguna, Kategori produk, dan Pengaturan bengkel.
5. "Diagnosis terbaru" maksimal tiga baris dalam satu kartu, ikon sesuai urgensi, serta "Lihat semua".
6. Navigasi bawah. Tidak ada banner Diagnosis Cepat atau pil Ringkasan Hari Ini.

**Perbedaan peran:**

| Hal | Admin | Mekanik |
|---|---|---|
| Empat angka statistik | Diagnosis, Draft, Final, Stok Menipis | Diagnosis, Draft Saya, Final, Riwayat |
| Menu lain | Laporan, Data gejala dan kerusakan, Pengguna, Kategori produk, Pengaturan bengkel | Tidak ditampilkan |
| Daftar terbaru | Diagnosis terbaru **semua pengguna** (ada nama mekanik) | Diagnosis terbaru **milik sendiri** |
| Navigasi bawah | Beranda, Transaksi, [Diagnosis], Katalog, Profil | Beranda, Riwayat, [Diagnosis], Draft, Profil |

```
+------------------------------+
|    (bilah status sistem)     |
| (foto) Andi P.    (bel2)(org)|
|        Admin                 |
|  12      3       9      2    |
| Diagn. Draft Final Stok men.  |
+------------------------------+
 ( Cari pelanggan/plat  ) [=]
 Perlu tindakan
 [3 draft menunggu finalisasi]
 Menu lain
 [Laporan] [Data] [Pengguna] [Kategori]
 Diagnosis Terbaru  Lihat Semua
 [ikon urgensi] Busi kotor / aus [Sedang] >
            (D)
================================
 Beranda Trans   Katalog Profil
```

### 6.3 Form Gejala (halaman 5) `H2`
- Header H2 dengan judul "Pilih Gejala" dan penghitung "3 gejala dipilih" (pil kecil di kanan).
- Kolom pencarian pil dan **chip kategori gejala** yang bisa digulir (Semua, Mesin, Kelistrikan, Rem, Transmisi).
- Daftar gejala sebagai **kartu dengan kotak centang** di kiri. Kartu terpilih: garis `primary` 2px dan latar `primarySoft` tipis.
- **Bar bawah tetap** (putih, bayangan atas): "3 gejala dipilih" di kiri, tombol pil **"Diagnosis"** di kanan (nonaktif bila nol). **Tanpa navigasi bawah.**

```
+------------------------------+
|    (bilah status sistem)     |
| <-   Pilih Gejala  [3 dipilih]|
+------------------------------+
 ( Cari gejala ...          )
 [Semua][Mesin][Listrik][Rem]
 +--------------------------+
 |[v] Mesin susah dihidupkan|  terpilih
 +--------------------------+
 |[ ] Mesin mati mendadak   |
 +--------------------------+
 |[v] Tarikan berat         |
 +--------------------------+
 ---------------------------
 3 gejala dipilih [Diagnosis]
```

### 6.4 Hasil Diagnosis (halaman 6, 17) `H3`
1. **Header H3** dengan tombol kembali, judul "Hasil Diagnosis", dan tombol bagikan.
2. **Kartu putih menimpa header** (radius 24), **ikon bulat** setengah keluar di atas.
3. Nama **kerusakan utama** (`title`), badge urgensi, **keyakinan** sebagai angka besar `primary` dengan cincin progres.
4. **Garis putus-putus**.
5. Bagian berjudul `heading`: **Kemungkinan Lain** (bar persentase tipis), **Solusi** (daftar centang), **Komponen Terkait** dan **Jasa Terkait** (daftar centang dengan harga di kanan), **Estimasi Biaya** (angka tebal + **label "Perkiraan"** + estimasi waktu).
6. Catatan kecil: "Hasil ini alat bantu, bukan kepastian."
7. **Tombol mengambang**: "Buat Draft Transaksi" dengan lingkaran panah, dan "Diagnosis Ulang" (sekunder). **Tanpa navigasi bawah.**

```
+------------------------------+
|    (bilah status sistem)     |
| <    Hasil Diagnosis    (<)  |
|     +--------------------+   |
|     |     ( ikon )       |   |
|     | Busi kotor / aus   |   |
|     | [Sedang]    78%    |   |
|     | - - - - - - - - -  |   |
|     | Kemungkinan Lain   |   |
|     | Karburator  15% == |   |
|     | Solusi             |   |
|     | (v) Bersihkan busi |   |
|     | Komponen Terkait   |   |
|     | (v) Busi  Rp25.000 |   |
|     | Estimasi [Perkiraan]|  |
|     | Rp30.000-Rp80.000  |   |
|     +--------------------+   |
|  [ Buat Draft Transaksi ->]  |
+------------------------------+
```

**Detail Riwayat (halaman 17):** sama dengan di atas, ditambah baris info di atas kartu: tanggal, nama mekanik, dan gejala yang dipilih (chip kecil).

### 6.5 Daftar Transaksi dan Riwayat (halaman 7, 9) `H4`
- Header H4 ringkas: judul kiri dan aksi kecil di kanan. Transaksi memakai tombol plus di header, bukan FAB.
- Kolom cari, lalu chip filter berjumlah berdasarkan data: Semua, Draft, Final (untuk Riwayat: Semua, Hari Ini, Minggu Ini).
- **Peran mekanik (halaman 9):** judul menjadi **"Draft Saya"**, hanya berisi draft miliknya, **tanpa tab Final** dan tanpa tombol Finalisasi. Ketukan pada kartu membuka Draft Transaksi (halaman 8) untuk diubah. Dibuka dari item **Draft** pada navigasi bawah.
- **Peran admin:** semua transaksi. Ketukan membuka Detail Transaksi (halaman 18).
- Transaksi dikelompokkan berdasarkan tanggal terbaru. Kartu: plat tebal dan badge status, nama pelanggan dan jumlah item, nomor/waktu/pembuat dalam teks kecil, nominal semibold warna `textTitle`. Draft punya garis kiri `warning`; Final memakai badge lembut tanpa garis kiri.
- Kartu, chip, dan input memiliki radius 12 dp, garis kartu tipis tanpa bayangan tebal. Tidak ada lingkaran avatar kosong pada kartu daftar.
- Navigasi bawah (bar penuh).

```
+------------------------------+
|    (bilah status sistem)     |
|                         (bel)|
| Transaksi                    |
| [Semua][Draft][Final]        |
+------------------------------+
 +--------------------------+
 |▏D 1234 XX          [Draft]|
 |  Dedi Kurniawan · 2 item  |
 |  TRX-0105 · 10:15 · Budi S. Rp45.000|
 +--------------------------+
 +--------------------------+
 |  D 5678 AB          [Final]|
 |  Siti A. · 4 item          |
 |  TRX-0104 · 09:40 · Rina W. Rp135.000|
 +--------------------------+
            (D)
================================
 Beranda Trans   Katalog Profil
```

### 6.6 Katalog Produk dan Jasa (halaman 11, 12) `H4`
- Header H4 ringkas dengan judul "Katalog", tombol tambah di header, **tab Produk | Jasa**, pencarian, dan chip kategori.
- **Produk:** grid 2 kolom (kartu 154 dp). Kartu: lencana status stok ("Stok Menipis" `warning`, "Habis" `danger`), ikon produk, nama, harga, stok kecil, tombol bulat (admin: ubah).
- **Jasa:** daftar kartu (nama, harga, tombol ubah).
- Tidak memakai FAB untuk tambah; aksi ada di header.
- Pada tab Produk, di samping chip kategori ada tautan kecil **"Kelola Kategori"** (khusus admin) yang membuka halaman 34.

```
+------------------------------+
|    (bilah status sistem)     |
| Katalog               (bel)  |
| [  Produk  ][  Jasa  ]       |
+------------------------------+
 ( Cari produk ...          )[=]
 [Semua][Pengapian][Oli][Rem]
 +-----------+ +-----------+
 |[Menipis]  | |           |
 |  [ikon]   | |  [ikon]   |
 | Busi NGK  | | Oli 1L    |
 | Rp25.000  | | Rp55.000  |
 | Stok 4 (o)| | Stok 20(o)|
 +-----------+ +-----------+
                         (+)
            (D)
================================
 Beranda Trans   Katalog Profil
```

### 6.7 Keranjang / Draft Transaksi (halaman 8) `H2`
- Header H2 dengan judul "Draft Transaksi" dan chip status "Draft".
- Kartu info pelanggan (nama, plat, ikon ubah).
- Daftar item dengan **QtyStepper** (bagian 5.14). Geser atau ikon sampah untuk hapus.
- Tombol "Tambah Item" tonal berikon plus, membuka bottom sheet pemilih produk dan jasa (halaman 19).
- Kartu ringkasan: subtotal produk, subtotal jasa, garis putus-putus, **Total** tebal.
- Tombol mengambang: "Simpan Draft" (mekanik) atau "Lanjut ke Pembayaran" (admin). **Tanpa navigasi bawah.**

```
+------------------------------+
|    (bilah status sistem)     |
| <   Draft Transaksi  [Draft] |
+------------------------------+
 +--------------------------+
 | Dedi K.  D 1234 XX   (e) |
 +--------------------------+
 Item
 +--------------------------+
 | Busi NGK       Rp25.000  |
 |            (-) 1 (+)     |
 +--------------------------+
 | Jasa ganti busi Rp20.000 |
 |            (-) 1 (+)     |
 +--------------------------+
 [ + Tambah Item ]
 +--------------------------+
 | Produk         Rp25.000  |
 | Jasa           Rp20.000  |
 | - - - - - - - - - - - -  |
 | Total          Rp45.000  |
 +--------------------------+
 [ Simpan Draft          ->  ]
```

### 6.8 Finalisasi dan Nota (halaman 10) `H2`
- Header H2 "Pembayaran".
- Kartu ringkasan item dan total.
- Chip metode pembayaran: Tunai, Transfer.
- Input "Jumlah Dibayar", dan baris **Kembalian** tebal berwarna `success` yang dihitung otomatis.
- Tombol mengambang "Finalisasi Transaksi".
- Setelah berhasil: layar **Nota** (gaya bagian 5.17) dengan ikon centang hijau, dan tombol "Bagikan PDF" (utama) serta "Selesai" (sekunder).

**Sketsa Pembayaran (halaman 10):**

```
+------------------------------+
|    (bilah status sistem)     |
| <        Pembayaran          |
+------------------------------+
 +--------------------------+
 | TRX-0105                 |
 | Dedi Kurniawan           |
 | D 1234 XX                |
 | - - - - - - - - - - - -  |
 | Busi NGK Standar Rp25.000|
 | Ganti busi       Rp20.000|
 | - - - - - - - - - - - -  |
 | Total            Rp45.000|
 +--------------------------+
 Metode Pembayaran
 ( Tunai )[ Transfer ]
 Jumlah Dibayar
 [ Rp50.000               ]
 Kembalian         Rp5.000   (hijau)
 [ Finalisasi Transaksi  -> ]
```

**Sketsa Nota (setelah berhasil):**

```
+------------------------------+
|    (bilah status sistem)     |
| (v)  Transaksi Berhasil      |
+------------------------------+
   +----------------------+
   |    ( ikon bengkel )  |
   |   Bengkel Maju Jaya  |
   |   Jl. Merdeka No. 12 |
   |   0812-3456-7890     |
   | - - - - - - - - - -  |
   | No    TRX-0105       |
   | Kasir Andi Pratama   |
   | - - - - - - - - - -  |
   | Busi NGK Standar     |
   |  1 x 25.000   25.000 |
   | Ganti busi           |
   |  1 x 20.000   20.000 |
   | - - - - - - - - - -  |
   | TOTAL         45.000 |
   | Tunai         50.000 |
   | Kembali        5.000 |
   |  Terima kasih ...    |
   +----------------------+
 [ Bagikan PDF  ->]  [ Selesai ]
```

### 6.9 Form Tambah/Ubah (halaman 20-25, 30, 32) `H2`
- Header H2 dengan judul ("Tambah Produk", "Ubah Pengguna", dll.). **Tanpa navigasi bawah.**
- Kolom input bertumpuk dengan jarak 16, label di atas tiap kolom.
- Sakelar "Aktif" di bagian bawah isi.
- Tombol mengambang "Simpan". Aksi hapus atau nonaktifkan berupa teks `danger` di bawah isi, **bukan** tombol utama.

```
+------------------------------+
|    (bilah status sistem)     |
| <      Tambah Produk         |
+------------------------------+
 Nama Produk
 [ Busi NGK Standar         ]
 Kategori
 [ Pengapian             v  ]
 Harga (Rp)        Stok
 [ 25.000    ]  [ 20      ]
 Aktif                [ON]
 Nonaktifkan produk   (merah)
 [ Simpan                    ]
```

### 6.10 Laporan (halaman 15) dan Statistik (halaman 27) `H4`
- Header H4 "Laporan" dengan chip periode (Hari Ini, 7 Hari, Bulan Ini, Kustom).
- **Kartu angka besar** (gradasi biru): total penjualan, perubahan dibanding periode lalu.
- Dua kartu kecil: jumlah transaksi dan rata-rata per transaksi.
- **Grafik batang** penjualan per hari (bagian 20).
- Bagian "Terlaris": daftar kartu dengan peringkat.
- Bagian "Daftar Transaksi Final": kartu daftar.
- **Statistik (27):** **grafik donat** distribusi kerusakan dan daftar peringkat kerusakan terbanyak.
- Kartu angka memakai gradasi keluarga biru `primary` ke `gradientEnd`. Grafik donat membedakan potongan dengan warna biru bertingkat (`primary`, `primaryDark`, `lightBlue`) lalu warna status (`success`, `warning`) dan netral (`border`).

```
+------------------------------+
|    (bilah status sistem)     |
| <  Laporan                   |
| [Hari][7 Hari][Bulan][Kustom]|
+------------------------------+
 +--------------------------+
 | Total Penjualan          |
 | Rp3.250.000              |
 | naik 12% dari minggu lalu|
 +--------------------------+
 +----------+ +-------------+
 | 18 trans.| | Rp180.555   |
 +----------+ +-------------+
 Penjualan per Hari
 | ||  |||  |   ||||  ||
 | Sen Sel Rab Kam Jum Sab Min
 Terlaris
 1 Busi NGK            12 terjual
```

### 6.11 Login dan Pengaturan Server (halaman 2, 3) `H3`
- Bagian atas biru (menerus ke tepi atas) dengan nama aplikasi, bagian bawah **kartu putih besar** (radius 24) berisi form menimpa header.
- **Login:** input nama pengguna, input kata sandi dengan ikon mata, tombol "Masuk" pil penuh. **Tidak ada tautan ke Pengaturan Server.**
- **Pengaturan Server (khusus admin, dibuka dari Profil):** header H3 dengan tombol kembali, kartu berisi judul "Alamat Server", keterangan singkat, **satu kolom "Alamat Server" berisi URL penuh** (contoh `http://192.168.1.10:8000`, tanpa kolom port terpisah), tombol "Tes Koneksi" (sekunder), kartu status koneksi di dalam kartu yang sama, tautan teks "Kembalikan ke bawaan", dan tombol mengambang "Simpan".

**Sketsa Login (halaman 3):**

```
+------------------------------+
|    (bilah status sistem)     |
|      ( ikon motor+kunci )    |
|        BengkelPintar         |
|     Selamat datang kembali   |
|     Masuk untuk mulai bekerja|
|   +----------------------+   |
|   | Nama Pengguna        |   |
|   | [ (o) budi         ] |   |
|   | Kata Sandi           |   |
|   | [ (k) ********  (e)] |   |
|   | [ Masuk         ->  ]|   |
|   +----------------------+   |
|   Hanya untuk admin dan      |
|   mekanik bengkel.           |
+------------------------------+
```

**Sketsa Pengaturan Server (halaman 2, khusus admin):**

```
+------------------------------+
|    (bilah status sistem)     |
| <      Pengaturan Server     |
+------------------------------+
   +----------------------+
   |   ( ikon server )    |
   | Alamat Server        |
   | Alamat server tempat |
   | data disimpan. Ubah  |
   | hanya jika diminta.  |
   | [ http://192.168.1.10:8000 ]
   | [ (sinyal) Tes Koneksi ]
   | +------------------+ |
   | | (v) Terhubung ke | |
   | |     server.      | |
   | +------------------+ |
   | Kembalikan ke bawaan |
   +----------------------+
 [ Simpan                 -> ]
```

### 6.12 Profil (halaman 16) dan Ganti Password (halaman 30) `H3` / `H2`
- **Profil:** header H3 dengan avatar besar dan tag peran. Daftar menu dalam kartu putih: Ganti Password, **Alamat Server (khusus admin, halaman 2)**, **Pengaturan Bengkel (khusus admin, halaman 32)**, Tentang Aplikasi, Keluar (merah). Navigasi bawah.
- **Ganti Password:** Form (6.9) dengan tiga kolom kata sandi (lama, baru, konfirmasi), semua berikon mata, dan indikator kekuatan kata sandi.

**Sketsa Profil (halaman 16, tampilan admin):**

```
+------------------------------+
|    (bilah status sistem)     |
|         ( avatar )           |
|        Andi Pratama          |
|           [Admin]            |
+------------------------------+
 +--------------------------+
 | Ganti Password         > |
 | Alamat Server          > |   hanya admin
 | Pengaturan Bengkel     > |   hanya admin
 | Tentang Aplikasi       > |
 | Keluar            (merah)|
 +--------------------------+
            (D)
================================
 Beranda Trans   Katalog Profil
```

### 6.13 Menu dan Daftar Data Master (halaman 13, 28, 29, 14, 34) `H2` / `H4`
- **Menu Data (13):** header H2, dua kartu besar bertumpuk: "Gejala" (ikon, jumlah) dan "Kerusakan" (ikon, jumlah), masing-masing membuka daftarnya.
- **Daftar (28, 29, 14, 34):** header H4 dengan judul besar, pencarian, kartu daftar dengan lencana status (Aktif hijau / Nonaktif abu-abu), FAB tambah.
- **Daftar Kerusakan:** kartu menampilkan nama, badge urgensi, dan "3 komponen terkait".
- Tampilkan **peringatan kecil** (banner `warning` lembut) pada daftar gejala dan kerusakan: "Mengubah daftar ini memerlukan pelatihan ulang model."

### 6.14 Pemilih Produk dan Jasa (halaman 19) dan Reset Password (halaman 31) Sheet
- **Bottom sheet** (bagian 5.10): pegangan, judul, pencarian, tab Produk | Jasa, daftar kartu kecil dengan tombol bulat tambah, tombol "Selesai" di bawah.
- **Reset Password:** bottom sheet kecil dengan nama pengguna, dua input kata sandi, tombol "Atur Ulang".

### 6.15 Detail Transaksi (halaman 18) dan Detail Produk (halaman 22) `H3`
- Header H3 dengan kartu menimpa berisi ringkasan: nomor, tanggal, pelanggan, plat (transaksi) atau nama, kategori, harga, stok (produk).
- Bagian daftar baris (bagian 5.15): item dan total.
- **Detail Produk:** bagian "Riwayat Stok" berupa daftar mutasi (masuk hijau `+`, keluar merah `-`, alasan, tanggal), tombol "Sesuaikan Stok" yang membuka bottom sheet dengan QtyStepper dan pilihan alasan.
- Tombol mengambang: "Finalisasi" (draft) atau "Lihat Nota" (final).

### 6.16 Akses Ditolak (halaman 26) dan Server Tidak Terjangkau (halaman 33) `H2`
- Header H2, di tengah: ilustrasi atau ikon bulat besar, judul, penjelasan satu sampai dua kalimat, tombol sesuai bagian 5.11.
**Sketsa Server Tidak Terjangkau (halaman 33):**

```
MEKANIK                          ADMIN
+------------------------+       +------------------------+
|   ( ilustrasi )        |       |   ( ilustrasi )        |
| Tidak dapat terhubung  |       | Tidak dapat terhubung  |
| ke server.             |       | ke server.             |
| Pastikan perangkat     |       | Pastikan perangkat     |
| server menyala dan HP  |       | server menyala dan HP  |
| tersambung ke jaringan |       | tersambung ke jaringan |
| bengkel.               |       | bengkel.               |
| [ Coba Lagi        ]   |       | [ Coba Lagi        ]   |
| Hubungi admin          |       | Pengaturan Server      |
+------------------------+       +------------------------+
```


---

## 7. Gerak dan Interaksi

- Durasi transisi **200-300 ms**, kurva `easeOutCubic`. Tidak ada animasi berlebihan.
- Perpindahan layar: geser horizontal standar. Bottom sheet naik dari bawah.
- Tombol saat ditekan: sedikit mengecil (skala 0.97) atau menggelap ke `primaryDark`.
- Daftar: tarik untuk menyegarkan pada layar berdata.
- Kerangka memuat berkilau lembut.
- Hargai pengaturan "kurangi gerak" sistem.

---

## 8. Bahasa dan Isi Teks

- Seluruh teks UI dalam **bahasa Indonesia** yang ramah dan singkat. Kumpulan teks baku ada di bagian 17.
- Tombol berupa kata kerja: "Simpan", "Diagnosis", "Buat Draft Transaksi", "Finalisasi", "Coba Lagi".
- Format uang: `Rp30.000` (titik pemisah ribuan, tanpa desimal) lewat satu helper.
- Format tanggal: `24 Okt 2026, 10:15`. Format jam: `10:15`.
- Persentase tanpa desimal: `78%`.
- Estimasi biaya **selalu** berdampingan dengan label "Perkiraan".
- Pesan error menjelaskan masalah dan solusi, bukan kode teknis.

---

## 9. Aksesibilitas

- Kontras teks terhadap latar minimal 4.5:1 (teks kecil) dan 3:1 (teks besar). `textMuted` hanya untuk keterangan.
- Status **tidak boleh hanya warna**: selalu sertakan teks atau ikon.
- Semua ikon tanpa teks diberi `Semantics` / `tooltip`.
- Area sentuh minimal 48 x 48, jarak antar elemen sentuh minimal 8.
- Urutan fokus mengikuti urutan baca. Keyboard layar tidak boleh menutupi tombol utama.

---

## 10. Aset

| Aset | Letak | Catatan |
|---|---|---|
| Font Poppins (400, 500, 600, 700) | `assets/fonts/` | Dibundel, tanpa unduhan runtime |
| Logo BengkelPintar | `assets/images/` | Spesifikasi di bagian 19 |
| Ilustrasi keadaan kosong dan error | `assets/images/` | Sederhana dan seragam gayanya |
| Ikon | Material Symbols Rounded (paket `material_symbols_icons`, dibundel) | Outline, weight 400, lewat `app_icons.dart` |

Dilarang: gambar dari URL internet, foto stok orang, logo pihak lain.

---

## 11. Struktur Kode Tema

```
lib/core/
├── theme/
│   ├── app_colors.dart
│   ├── app_icons.dart        -> pemetaan fungsi ke ikon (bagian 18)
│   ├── app_text.dart
│   ├── app_spacing.dart
│   ├── app_system_ui.dart    -> bilah status transparan, ikon terang (bagian 0.2)
│   └── app_theme.dart        -> ThemeData Material 3
└── widgets/
    ├── app_button.dart
    ├── circle_icon_button.dart
    ├── app_search_bar.dart
    ├── app_chip.dart
    ├── app_tag.dart
    ├── app_checkbox.dart
    ├── app_switch.dart
    ├── app_dropdown.dart
    ├── urgensi_badge.dart
    ├── status_badge.dart
    ├── perkiraan_label.dart
    ├── list_card.dart
    ├── product_card.dart
    ├── stat_header_card.dart
    ├── blue_header.dart          -> H1 sampai H4 + HeaderDecoration
    ├── floating_nav_bar.dart     -> bar bawah penuh kiri-kanan (nama file lama dipertahankan)
    ├── floating_action_bar.dart  -> tombol utama mengambang
    ├── qty_stepper.dart
    ├── check_list_item.dart
    ├── data_row_item.dart
    ├── dashed_divider.dart
    ├── bar_chart_card.dart
    ├── donut_chart_card.dart
    ├── receipt_view.dart
    ├── empty_state.dart
    ├── error_state.dart
    ├── server_unreachable.dart
    └── loading_skeleton.dart
```

Aturan kode:
- Layar **hanya merakit** komponen dari `lib/core/widgets`.
- Tidak ada angka warna, ukuran font, atau radius yang ditulis langsung di layar.
- `ThemeData` Material 3 dengan `ColorScheme` dari token dan `textTheme` dari `app_text.dart`.
- Setiap layar memakai jenis header H0-H4 sesuai `HALAMAN.md`.

---

## 12. Peta Halaman ke Pola Desain

| Halaman | Pola | Header | Navigasi bawah |
|---|---|---|---|
| 1 Splash | 6.1 | H0 | Tidak |
| 2 Pengaturan Server, 3 Login | 6.11 | H3 | Tidak |
| 4 Beranda | 6.2 | H1 | Ya |
| 5 Form Gejala | 6.3 | H2 | Tidak |
| 6 Hasil Diagnosis, 17 Detail Riwayat | 6.4 | H3 | Tidak |
| 7 Riwayat, 9 Daftar Transaksi | 6.5 | H4 | Ya |
| 8 Keranjang | 6.7 | H2 | Tidak |
| 10 Finalisasi dan Nota | 6.8 | H2 | Tidak |
| 11 Katalog Produk, 12 Katalog Jasa | 6.6 | H4 | Ya |
| 13 Menu Data, 28 Daftar Gejala, 29 Daftar Kerusakan, 14 Kelola Pengguna, 34 Kategori | 6.13 | H2 / H4 | Tidak |
| 15 Laporan, 27 Statistik | 6.10 | H4 | Tidak |
| 16 Profil | 6.12 | H3 | Ya |
| 18 Detail Transaksi, 22 Detail Produk | 6.15 | H3 | Tidak |
| 19 Pemilih Produk dan Jasa, 31 Reset Password | 6.14 | Sheet | Tidak |
| 20-25, 30, 32 Form | 6.9 / 6.12 | H2 | Tidak |
| 26 Akses Ditolak, 33 Server Tidak Terjangkau | 6.16 | H2 | Tidak |

---

## 13. Aturan untuk Agent (Ringkas)

**Wajib:**
1. Baca `DESIGN.md` sebelum membuat atau mengubah layar apa pun. Jangan menyatakan tampilan "sudah sesuai" tanpa pengguna memeriksanya (bagian 0.7).
2. **Layout fleksibel, benar di lebar 320, 360, dan 412**, layar penuh edge-to-edge, bilah status transparan, tanpa strip putih di atas, tanpa overflow (bagian 0).
3. Pakai token warna, teks, jarak, dan komponen bersama.
4. Satu tombol utama per layar, berbentuk pil.
5. Setiap layar berdata punya keadaan **memuat, kosong, dan error**.
6. Estimasi biaya selalu disertai label "Perkiraan".
7. Semua aset dibundel. Aplikasi harus jalan tanpa internet.
8. Bahasa UI Indonesia, memakai teks baku bagian 17.
9. Pakai **data contoh baku** bagian 16 di semua layar, jangan mengarang data baru.

**Dilarang:**
1. Paket yang mengunduh font atau aset saat runtime.
2. Menambah warna aksen baru di luar bagian 2.
3. Mencampur gaya ikon.
4. Menyalin logo, foto, atau teks dari gambar referensi.
5. Membuat varian tombol, tag, atau kartu baru di dalam layar tanpa menambahkannya sebagai komponen.
6. Mode gelap atau tema lain tanpa diminta.
7. Strip putih di bagian atas layar, lebar tetap yang memicu overflow, atau margin dan latar di sekeliling layar.

---

## 14. Daftar Periksa Desain per Layar

- [ ] Benar di lebar 320, 360, dan 412 tanpa overflow, dengan ukuran teks sistem 130%
- [ ] Bilah status transparan, ikon putih, warna biru menerus ke tepi atas
- [ ] Jenis header sesuai `HALAMAN.md`
- [ ] Navigasi bawah sesuai `HALAMAN.md` (ada atau tidak)
- [ ] Konten tidak tertutup navigasi atau tombol mengambang (padding bawah cukup, sudah termasuk `padding.bottom`)
- [ ] Navigasi bawah penuh kiri-kanan, biru menerus sampai tepi bawah, ikon tidak tertimpa bilah gestur
- [ ] Tidak ada canvas, bingkai, jam, atau ikon sinyal yang digambar aplikasi
- [ ] Margin kiri-kanan memakai inset sistem, tanpa `SafeArea` penuh dan tanpa padding ganda
- [ ] Hanya memakai komponen dari `lib/core/widgets` dan token tema
- [ ] Ada keadaan memuat, kosong, dan error
- [ ] Satu tombol utama, area sentuh minimal 48
- [ ] Tidak ada teks terpotong saat teks sistem diperbesar
- [ ] Status memakai teks atau ikon, bukan hanya warna
- [ ] Estimasi biaya berlabel "Perkiraan" (jika ada)
- [ ] Memakai data contoh dan teks baku
- [ ] `flutter analyze` bersih

---

## 15. Yang Belum Diputuskan

| No | Hal | Catatan |
|---|---|---|
| 1 | Nilai warna pasti | Hex di bagian 2 estimasi dari gambar, boleh disetel setelah dicoba di perangkat |
| 2 | Foto produk | Saat ini memakai ikon. Foto produk bisa jadi pengembangan lanjutan |
| 3 | Paket ikon final | **Sudah diputuskan:** Material Symbols Rounded (bagian 4.4). Yang tersisa: logo motor dengan kunci inggris dibuat sebagai aset sendiri |

---

## 16. Data Contoh Baku

Pakai data ini di **semua** layar (tampilan dan data mock Flutter) supaya isi tampilan konsisten.

### 16.1 Bengkel
- Nama: **Bengkel Maju Jaya**
- Alamat: Jl. Merdeka No. 12, Bandung
- Telepon: 0812-3456-7890

### 16.2 Pengguna
| Nama | Peran | Username |
|---|---|---|
| Andi Pratama | Admin | `admin` |
| Budi Santoso | Mekanik | `budi` |
| Rina Wulandari | Mekanik | `rina` |

### 16.3 Pelanggan dan Plat
| Pelanggan | Plat |
|---|---|
| Dedi Kurniawan | D 1234 XX |
| Siti Aminah | D 5678 AB |
| Agus Salim | F 4321 CD |
| Rizky Maulana | B 9876 EF |

### 16.4 Gejala (18)
| Kode | Gejala | Kategori |
|---|---|---|
| G01 | Mesin susah dihidupkan | Mesin |
| G02 | Mesin mati mendadak | Mesin |
| G03 | Tarikan berat | Mesin |
| G04 | Knalpot berasap putih | Mesin |
| G05 | Knalpot berasap hitam | Mesin |
| G06 | Suara mesin kasar | Mesin |
| G07 | Lampu redup | Kelistrikan |
| G08 | Klakson lemah atau mati | Kelistrikan |
| G09 | Boros bensin | Mesin |
| G10 | Rem kurang pakem | Rem |
| G11 | Rantai berisik | Transmisi |
| G12 | Kopling selip | Transmisi |
| G13 | Getaran berlebih di stang | Transmisi |
| G14 | Mesin overheat | Mesin |
| G15 | Bunyi ketukan di mesin | Mesin |
| G16 | Starter elektrik tidak berfungsi | Kelistrikan |
| G17 | Oli cepat habis | Mesin |
| G18 | Putaran gas tidak stabil | Mesin |

### 16.5 Kerusakan (10)
| Kode | Kerusakan | Urgensi | Solusi | Waktu |
|---|---|---|---|---|
| K01 | Busi kotor / aus | Sedang | Bersihkan atau ganti busi | 15 menit |
| K02 | Karburator kotor | Sedang | Bersihkan karburator | 45 menit |
| K03 | Aki lemah | Sedang | Isi ulang atau ganti aki | 20 menit |
| K04 | Kampas rem aus | Tinggi | Ganti kampas rem | 30 menit |
| K05 | Kampas kopling aus | Sedang | Ganti kampas kopling | 90 menit |
| K06 | Rantai dan gear aus | Sedang | Ganti set rantai dan gear | 60 menit |
| K07 | Filter udara kotor | Rendah | Bersihkan atau ganti filter udara | 10 menit |
| K08 | Oli mesin habis atau kotor | Tinggi | Ganti oli mesin | 15 menit |
| K09 | CDI bermasalah | Tinggi | Periksa atau ganti CDI | 40 menit |
| K10 | Koil pengapian lemah | Sedang | Ganti koil pengapian | 30 menit |

### 16.6 Kategori Produk
Pengapian, Pelumas, Rem, Transmisi, Kelistrikan, Filter.

### 16.7 Produk
| Produk | Kategori | Harga | Stok |
|---|---|---|---|
| Busi NGK Standar | Pengapian | Rp25.000 | 4 (menipis) |
| Kabel Busi | Pengapian | Rp35.000 | 12 |
| Koil Pengapian | Pengapian | Rp95.000 | 6 |
| CDI | Kelistrikan | Rp180.000 | 3 (menipis) |
| Aki 12V | Kelistrikan | Rp280.000 | 5 |
| Lampu Depan | Kelistrikan | Rp35.000 | 15 |
| Oli Mesin 1 Liter | Pelumas | Rp55.000 | 20 |
| Filter Udara | Filter | Rp40.000 | 10 |
| Kampas Rem Depan | Rem | Rp45.000 | 8 |
| Kampas Rem Belakang | Rem | Rp40.000 | 0 (habis) |
| Kampas Kopling Set | Transmisi | Rp120.000 | 4 |
| Set Rantai dan Gear | Transmisi | Rp250.000 | 3 |

### 16.8 Jasa
| Jasa | Harga |
|---|---|
| Ganti busi | Rp20.000 |
| Ganti oli | Rp10.000 |
| Ganti kampas rem | Rp25.000 |
| Ganti aki | Rp15.000 |
| Cek kelistrikan | Rp30.000 |
| Ganti rantai dan gear | Rp50.000 |
| Servis karburator | Rp60.000 |
| Ganti kampas kopling | Rp80.000 |
| Tune up | Rp75.000 |

### 16.9 Contoh Diagnosis
Gejala: Mesin susah dihidupkan, Tarikan berat, Knalpot berasap putih.
Hasil: **Busi kotor / aus**, keyakinan **78%**. Kemungkinan lain: Karburator kotor 15%, Aki lemah 7%. Urgensi **Sedang**. Solusi: Bersihkan atau ganti busi. Komponen: Busi NGK Standar (Rp25.000), Kabel Busi (Rp35.000). Jasa: Ganti busi (Rp20.000). Estimasi biaya **Rp30.000 - Rp80.000 (Perkiraan)**. Estimasi waktu 15 menit.

### 16.10 Contoh Transaksi
| Nomor | Pelanggan | Item | Total | Status | Waktu |
|---|---|---|---|---|---|
| TRX-0105 | Dedi Kurniawan | Busi NGK Standar, Ganti busi | Rp45.000 | Draft | 24 Okt 2026, 10:15 |
| TRX-0104 | Siti Aminah | Kampas Rem Depan, Oli Mesin 1 Liter, Ganti kampas rem, Ganti oli | Rp135.000 | Final | 24 Okt 2026, 09:40 |
| TRX-0103 | Agus Salim | Set Rantai dan Gear, Ganti rantai dan gear | Rp300.000 | Final | 23 Okt 2026, 16:20 |
| TRX-0102 | Rizky Maulana | Aki 12V, Ganti aki | Rp295.000 | Final | 23 Okt 2026, 11:05 |

### 16.11 Contoh Angka Beranda dan Laporan
- Beranda Admin: Diagnosis **12**, Draft **3**, Final **9**, Stok Menipis **2**.
- Beranda Mekanik (Budi): Diagnosis **7**, Draft Saya **2**, Final **5**, Riwayat **24**.
- Laporan (7 hari): Total **Rp3.250.000**, **18** transaksi, rata-rata **Rp180.555**, naik **12%**.
- Penjualan per hari (Rp ribu): Sen 420, Sel 380, Rab 510, Kam 290, Jum 640, Sab 720, Min 290.
- Distribusi kerusakan (Statistik): Busi kotor 28%, Oli mesin 18%, Kampas rem 15%, Aki lemah 12%, Karburator 10%, Lainnya 17%.

---

## 17. Teks Baku

### 17.1 Tombol
Masuk, Keluar, Mulai, Simpan, Batal, Hapus, Ubah, Tambah, Selesai, Lanjut, Kembali, Cari, Filter, Diagnosis, Diagnosis Ulang, Buat Draft Transaksi, Simpan Draft, Lanjut ke Pembayaran, Finalisasi Transaksi, Bagikan PDF, Lihat Nota, Tes Koneksi, Coba Lagi, Pengaturan Server, Sesuaikan Stok, Atur Ulang, Lihat Semua.

### 17.2 Label Status
Draft, Final, Aktif, Nonaktif, Rendah, Sedang, Tinggi, Stok Menipis, Habis, Perkiraan.

### 17.3 Judul Layar
Pilih Gejala, Hasil Diagnosis, Riwayat Diagnosis, Draft Transaksi, Pembayaran, Nota, Transaksi, Katalog, Produk, Jasa, Laporan, Statistik Diagnosis, Data Gejala dan Kerusakan, Kelola Pengguna, Kategori Produk, Pengaturan Bengkel, Ganti Password, Profil, Pengaturan Server.

### 17.4 Pesan Kosong
| Layar | Judul | Keterangan |
|---|---|---|
| Riwayat | Belum ada riwayat diagnosis | Mulai diagnosis pertama Anda dari tombol di tengah. |
| Transaksi | Belum ada transaksi | Transaksi akan muncul setelah draft dibuat. |
| Produk | Belum ada produk | Tambahkan produk pertama untuk mulai berjualan. |
| Pencarian | Tidak ditemukan | Coba kata kunci lain. |

### 17.5 Pesan Error dan Validasi
- "Nama pengguna atau kata sandi salah."
- "Kolom ini wajib diisi."
- "Harga tidak boleh negatif."
- "Stok tidak mencukupi untuk Busi NGK Standar."
- "Kata sandi minimal 6 karakter."
- "Konfirmasi kata sandi tidak sama."
- "Tidak dapat terhubung ke server. Pastikan perangkat server menyala dan HP tersambung ke jaringan bengkel."
- "Pilih minimal satu gejala."

### 17.6 Pesan Berhasil
"Draft transaksi disimpan.", "Transaksi berhasil difinalisasi.", "Produk disimpan.", "Kata sandi berhasil diubah.", "Terhubung ke server."

### 17.7 Dialog Konfirmasi
- Keluar: "Keluar dari akun? Anda perlu masuk lagi untuk memakai aplikasi."
- Finalisasi: "Finalisasi transaksi? Stok akan berkurang dan draft tidak bisa diubah lagi."
- Nonaktifkan: "Nonaktifkan item ini? Item tidak akan muncul di pilihan baru."

### 17.8 Catatan Tetap
- Di Hasil Diagnosis: "Hasil ini alat bantu, bukan kepastian."
- Di data master: "Mengubah daftar ini memerlukan pelatihan ulang model."
- Di biaya: label "Perkiraan".

---

## 18. Ikon Baku

Paket: **Material Symbols Rounded, outline** (bagian 4.4). Tabel ini adalah satu-satunya acuan. Kolom "Nama ikon" memakai nama di Material Symbols; di kode dibungkus lewat `app_icons.dart`. Nama ikon di tabel ditulis dari ingatan, jadi agent **wajib memeriksa bahwa tiap nama ada di paket** saat T-02 dan melaporkan yang tidak ada, bukan memilih pengganti sendiri.

### 18.1 Navigasi dan aksi umum
| Fungsi | Nama ikon |
|---|---|
| Beranda | `home` |
| Diagnosis (tombol tengah) | `stethoscope` |
| Transaksi | `receipt_long` |
| Riwayat | `history` |
| Draft | `edit_document` |
| Katalog | `inventory_2` |
| Produk | `inventory_2` |
| Jasa | `build` |
| Laporan | `bar_chart` |
| Pengguna | `group` |
| Profil | `account_circle` |
| Bel | `notifications` |
| Pencarian | `search` |
| Filter | `tune` |
| Tambah | `add` |
| Ubah | `edit` |
| Hapus | `delete` |
| Bagikan | `share` |
| Kembali | `arrow_back` |
| Lanjut (panah di tombol) | `arrow_forward` |
| Panah bawah (dropdown, lipat) | `keyboard_arrow_down` |
| Panah kanan (item menu) | `chevron_right` |

### 18.2 Form, status, dan sistem
| Fungsi | Nama ikon |
|---|---|
| Nama pengguna | `person` |
| Kata sandi | `lock` |
| Tampilkan kata sandi | `visibility` |
| Sembunyikan kata sandi | `visibility_off` |
| Centang (daftar solusi, berhasil) | `check_circle` |
| Info (label "Perkiraan") | `info` |
| Peringatan | `warning` |
| Kalender | `calendar_today` |
| Gejala | `checklist` |
| Data Master | `database` |
| Kategori produk | `category` |
| Pengaturan Bengkel | `storefront` |
| Pengaturan Server | `dns` |
| Tes Koneksi | `wifi` |
| Server tidak terjangkau | `wifi_off` |
| Akses ditolak | `lock` |
| Keluar | `logout` |
| Tentang Aplikasi | `info` |
| Logo kecil (motor) | `two_wheeler` |

### 18.3 Ikon kategori kerusakan dan produk (di kartu)
| Kategori | Nama ikon |
|---|---|
| Pengapian | `flare` |
| Pelumas | `water_drop` |
| Rem | `album` |
| Transmisi | `settings` |
| Kelistrikan | `bolt` |
| Filter | `filter_alt` |
| Aki | `battery_full` |

Catatan: logo BengkelPintar (motor dengan kunci inggris menyilang, bagian 19) dibuat sebagai aset gambar sendiri, bukan dari paket ikon. `two_wheeler` hanya untuk versi sangat kecil di dalam teks atau daftar.

---

## 19. Logo dan Ilustrasi

### 19.1 Logo
- **Lambang:** ikon sepeda motor sederhana (garis) dengan **kunci inggris menyilang**, di dalam lingkaran atau kotak membulat.
- **Versi 1 (di atas biru):** lambang putih, di dalam lingkaran putih translusen.
- **Versi 2 (di atas putih):** lambang `primary` di dalam kotak `primarySoft`.
- **Tulisan:** "BengkelPintar", Poppins Bold. Pada latar biru: "Bengkel" putih, "Pintar" `lightBlue`. Pada latar putih: "Bengkel" `navy`, "Pintar" `primary`.
- Area aman di sekeliling logo minimal setinggi huruf "B".
- Ukuran minimum lambang: 24 dp.

### 19.2 Ilustrasi
- Gaya **datar (flat) geometris**, garis tebal 2 dp, bentuk membulat.
- Palet terbatas: `primary`, `primarySoft`, putih, dan `lightBlue`. Aksen kecil `warning` boleh untuk percikan atau peringatan.
- Tanpa orang dan tanpa tekstur atau gradasi rumit.
- Tema: kunci inggris, roda gigi, motor, busi, aki, server dan Wi-Fi (untuk keadaan error), kotak kosong (untuk keadaan kosong).
- Ukuran: 160-200 dp di tengah layar pada keadaan kosong dan error.

---

## 20. Grafik

Dibuat dengan paket grafik Flutter yang bisa jalan tanpa internet. Semua grafik tampil di dalam **kartu putih** (radius 16) dengan judul `heading` dan keterangan `bodySmall`.

### 20.1 Grafik Batang (Penjualan per Hari)
- Batang `primary` dengan sudut atas membulat 6, lebar 16-20, jarak antar batang 12.
- Batang periode terpilih (misalnya hari ini): `primary` penuh. Lainnya: `primary` opasitas 40%.
- Garis bantu horizontal putus-putus `border`, tanpa garis vertikal.
- Label sumbu `bodySmall` `textMuted`. Hari dalam tiga huruf (Sen, Sel, Rab).
- Tooltip: kotak `navy` radius 8, teks putih "Rp720 rb".
- Tinggi grafik 180 dp.

### 20.2 Grafik Donat (Distribusi Kerusakan)
- Lingkaran donat dengan tebal 28 dp, celah antar potongan 2 dp, ujung potongan membulat.
- Palet potongan berurutan: `primary`, `primaryDark`, `lightBlue`, `success`, `warning`, `border`.
- Di tengah donat: angka total (`title`) dan keterangan ("diagnosis").
- Legenda di bawah: titik warna + nama + persentase, satu baris per item.
- Warna tidak boleh menjadi satu-satunya pembeda: setiap potongan punya label di legenda.

### 20.3 Bar Persentase (Kemungkinan Lain)
- Batang horizontal tipis: tinggi 6, radius penuh, latar `primarySoft`, isi `primary`.
- Nama di kiri atas, persentase di kanan atas (`subheading`).
- Lebar mengikuti persentase.

### 20.4 Cincin Progres (Keyakinan)
- Cincin tebal 10 dp, ukuran 72 dp, jalur `primarySoft`, isi `primary`, ujung membulat.
- Angka persentase di tengah (`title`, `primary`).
