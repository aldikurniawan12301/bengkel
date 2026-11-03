# HALAMAN.md: Daftar Halaman BengkelPintar (v1.6)

Centang `[x]` jika halaman sudah selesai dan disetujui.
Acuan: `PRD.md` bagian 7, `DESIGN.md` (v1.6), dan `TASKS.md` (di root proyek).

**Peran:** M = mekanik, A = admin

---

## Aturan Tampilan (Berlaku untuk Semua Halaman)

Detail lengkap ada di `DESIGN.md` bagian 0.

- **Android potret, layout fleksibel**, benar di lebar 320, 360, dan 412 dengan ukuran teks sistem sampai 130%. Tidak boleh ada overflow.
- **Edge-to-edge:** bilah status transparan dengan ikon putih, dan warna biru header menerus sampai tepi paling atas. **Tidak boleh ada strip putih di atas.**
- Margin kiri dan kanan 20. Padding bawah cukup supaya konten tidak tertutup navigasi atau tombol mengambang.
- Tampilan dibuat langsung di Flutter mengikuti `DESIGN.md`. Tidak ada gambar desain.

**Arti kotak centang:** lolos pemeriksaan otomatis dan persetujuan akhir tetap saya nilai lewat uji di HP.

### Kode Jenis Header
| Kode | Nama | Tinggi total | Dipakai di |
|---|---|---|---|
| **H0** | Biru penuh | Seluruh layar | Splash |
| **H1** | Header Beranda (statistik) | 250 | Beranda |
| **H2** | Header kecil (kembali + judul) | 120 | Form dan layar sederhana |
| **H3** | Header detail (kartu putih menimpa) | 200 | Hasil, detail, profil, login |
| **H4** | Header judul besar (+ tab pil) | 180 | Daftar |
| **Sheet** | Bottom sheet atau dialog | - | Pemilih dan reset password |

**Nav** = navigasi bawah mengambang. "Ya" berarti ditampilkan, "Tidak" berarti disembunyikan (layar memakai tombol utama mengambang atau bar bawah tetap).

---

## Halaman Utama (16)

- [ ] 1. Splash (M, A) - T-06 | Header: H0 | Nav: Tidak | Pola: 6.1
- [ ] 2. Pengaturan Server (A) - T-06 | Header: H3 | Nav: Tidak | Pola: 6.11 (dibuka dari Profil 16, bukan alur harian)
- [ ] 3. Login (M, A) - T-07 | Header: H3 | Nav: Tidak | Pola: 6.11
- [ ] 4. Beranda (M, A) - T-08 | Header: H1 | Nav: Ya | Pola: 6.2
- [ ] 5. Form Gejala (M, A) - T-09 | Header: H2 | Nav: Tidak (bar bawah tetap) | Pola: 6.3
- [ ] 6. Hasil Diagnosis (M, A) - T-10 | Header: H3 | Nav: Tidak (tombol mengambang) | Pola: 6.4
- [ ] 7. Riwayat Diagnosis (M, A) - T-11 | Header: H4 | Nav: Ya | Pola: 6.5
- [ ] 8. Draft Transaksi / Keranjang (M, A) - T-13 | Header: H2 | Nav: Tidak (tombol mengambang) | Pola: 6.7
- [ ] 9. Daftar Transaksi (M, A) - T-14 | Header: H4 | Nav: Ya | Pola: 6.5
- [ ] 10. Finalisasi dan Nota (A) - T-15 | Header: H2 | Nav: Tidak (tombol mengambang) | Pola: 6.8
- [ ] 11. Katalog Produk (A) - T-16 | Header: H4 (tab Produk) | Nav: Ya | Pola: 6.6
- [ ] 12. Katalog Jasa (A) - T-17 | Header: H4 (tab Jasa) | Nav: Ya | Pola: 6.6
- [ ] 13. Menu Data Gejala dan Kerusakan (A) - T-19 | Header: H2 | Nav: Tidak | Pola: 6.13
- [ ] 14. Kelola Pengguna (A) - T-20 | Header: H4 | Nav: Tidak | Pola: 6.13
- [ ] 15. Laporan Penjualan (A) - T-21 | Header: H4 | Nav: Tidak | Pola: 6.10
- [ ] 16. Profil / Logout (M, A) - T-23 | Header: H3 | Nav: Ya | Pola: 6.12

## Halaman dan Tampilan Tambahan (10)

- [ ] 17. Detail Riwayat Diagnosis (M, A) - T-11 | Header: H3 | Nav: Tidak | Pola: 6.4 (tambah info tanggal, mekanik, gejala)
- [ ] 18. Detail Transaksi (A) - T-14 | Header: H3 | Nav: Tidak | Pola: 6.15
- [ ] 19. Pemilih Produk dan Jasa (M, A) - T-13 | Header: Sheet | Nav: Tidak | Pola: 6.14
- [ ] 20. Form Tambah/Ubah Produk (A) - T-16 | Header: H2 | Nav: Tidak | Pola: 6.9
- [ ] 21. Form Tambah/Ubah Jasa (A) - T-17 | Header: H2 | Nav: Tidak | Pola: 6.9
- [ ] 22. Detail Produk dan Penyesuaian Stok (A) - T-18 | Header: H3 | Nav: Tidak | Pola: 6.15
- [ ] 23. Form Tambah/Ubah Gejala (A) - T-19 | Header: H2 | Nav: Tidak | Pola: 6.9
- [ ] 24. Form Tambah/Ubah Kerusakan (A) - T-19 | Header: H2 | Nav: Tidak | Pola: 6.9 (termasuk pemilih komponen dan jasa terkait)
- [ ] 25. Form Tambah/Ubah Pengguna (A) - T-20 | Header: H2 | Nav: Tidak | Pola: 6.9
- [ ] 26. Akses Ditolak (M, A) - T-03 | Header: H2 | Nav: Tidak | Pola: 6.16

## Halaman Tambahan Hasil Peninjauan (7)

- [ ] 28. Daftar Gejala (A) - T-29 | Header: H4 | Nav: Tidak | Pola: 6.13
- [ ] 29. Daftar Kerusakan (A) - T-29 | Header: H4 | Nav: Tidak | Pola: 6.13
- [ ] 30. Ganti Password (M, A) - T-27 | Header: H2 | Nav: Tidak | Pola: 6.12
- [ ] 31. Reset Password Pengguna (A) - T-27 | Header: Sheet | Nav: Tidak | Pola: 6.14
- [ ] 32. Pengaturan Bengkel (A) - T-26 | Header: H2 | Nav: Tidak | Pola: 6.9
- [ ] 33. Server Tidak Terjangkau (M, A) - T-28 | Header: H2 | Nav: Tidak | Pola: 6.16
- [ ] 34. Kelola Kategori Produk (A) - T-30 | Header: H4 | Nav: Tidak | Pola: 6.13

## Opsional (1)

- [ ] 27. Statistik Diagnosis (A) - T-22 | Header: H4 | Nav: Tidak | Pola: 6.10

---

## Navigasi Bawah per Peran

| Peran | Kiri 1 | Kiri 2 | Tengah (menonjol) | Kanan 1 | Kanan 2 |
|---|---|---|---|---|---|
| **Mekanik** | Beranda | Riwayat | **Diagnosis** | Draft | Profil |
| **Admin** | Beranda | Transaksi | **Diagnosis** | Katalog | Profil |

Halaman yang menampilkan navigasi bawah: **4, 7, 9, 11, 12, 16**.
Menu **Katalog** (admin) membuka satu layar dengan dua tab: **Produk (11)** dan **Jasa (12)**.

## Halaman per Peran

**Mekanik (14):** 1, 3, 4, 5, 6, 7, 8, 9, 16, 17, 19, 26, 30, 33

**Admin (semua):** 1 sampai 26 dan 28 sampai 34, ditambah 27 jika diambil

## Prioritas Pengerjaan Kode (Flutter)

1. **Alur utama:** 1, 2, 3, 4, 5, 6, 8, 10, 33
2. **Pendukung POS:** 7, 9, 11, 12, 19, 20, 21, 22, 32, 34 (11, 12, dan 34 dibutuhkan sebelum keranjang)
3. **Pengelolaan:** 13, 14, 23, 24, 25, 28, 29, 31
4. **Pelengkap:** 15, 16, 17, 18, 26, 30, 27

## Ringkasan

| Kelompok | Jumlah |
|---|---|
| Halaman utama | 16 |
| Halaman dan tampilan tambahan | 10 |
| Tambahan hasil peninjauan | 7 |
| Opsional | 1 |
| **Total** | **34** |

## Progres

Total: **0 / 34** selesai (perbarui angka ini secara manual)
