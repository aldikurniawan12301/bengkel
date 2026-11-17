# Laporan Evaluasi Model Random Forest

- Peringatan: Kelas dengan kurang dari 30 sampel: {'K03': 23}. Hasil per kelas tidak stabil.

## 1. Data

- Berkas: `dataset_motor.csv` (SHA-256 `c590f2e08b23aec2...`)
- Baris dibaca: 1200; setelah membuang duplikat gejala+label: 476 (724 dibuang)
- Vektor gejala yang sama tetapi berlabel berbeda: 0 (dipertahankan)
- Jumlah gejala (fitur): 18; jumlah kelas: 10
- `sumber_data`: {'RUJUKAN_PRD_DAN_SERVIS': 1200}
- `status_verifikasi`: {'draft_pengembangan': 1200}

### Distribusi kelas

| Kelas | Nama | Jumlah | Persen |
|---|---|---:|---:|
| K01 | Busi kotor / aus | 62 | 13.0% |
| K02 | Karburator kotor | 83 | 17.4% |
| K03 | Aki lemah | 23 | 4.8% |
| K04 | Kampas rem aus | 34 | 7.1% |
| K05 | Kampas kopling aus | 31 | 6.5% |
| K06 | Rantai dan gear aus | 31 | 6.5% |
| K07 | Filter udara kotor | 58 | 12.2% |
| K08 | Oli mesin habis atau kotor | 35 | 7.4% |
| K09 | CDI bermasalah | 31 | 6.5% |
| K10 | Koil pengapian lemah | 88 | 18.5% |

Rasio kelas terbanyak terhadap tersedikit: 3.83.

## 2. Pengaturan

- Pembagian: 380 latih / 96 uji (berstrata, random_state=42).
- Parameter: `{"n_estimators": 300, "max_depth": null, "min_samples_leaf": 1, "max_features": "sqrt", "class_weight": null}`
- Parameter bawaan, tanpa penyetelan.

## 3. Hasil pada data uji

- Akurasi: **79.2%** (selang 95% kira-kira 70.0% sampai 86.1%, dari 96 baris uji)
- Akurasi top-3 (kelas benar ada di 3 peringkat teratas): 99.0%
- Pembanding: selalu menebak kelas mayoritas 18.8%; menebak acak 10.0%
- Makro: precision 0.831, recall 0.839, F1 0.829
- Berbobot: precision 0.807, recall 0.792, F1 0.793

| Kelas | Nama | Precision | Recall | F1 | Jumlah uji |
|---|---|---:|---:|---:|---:|
| K01 | Busi kotor / aus | 0.600 | 0.750 | 0.667 | 12 |
| K02 | Karburator kotor | 0.769 | 0.588 | 0.667 | 17 |
| K03 | Aki lemah | 1.000 | 1.000 | 1.000 | 5 |
| K04 | Kampas rem aus | 0.875 | 1.000 | 0.933 | 7 |
| K05 | Kampas kopling aus | 0.714 | 0.833 | 0.769 | 6 |
| K06 | Rantai dan gear aus | 1.000 | 0.833 | 0.909 | 6 |
| K07 | Filter udara kotor | 1.000 | 0.833 | 0.909 | 12 |
| K08 | Oli mesin habis atau kotor | 1.000 | 1.000 | 1.000 | 7 |
| K09 | CDI bermasalah | 0.625 | 0.833 | 0.714 | 6 |
| K10 | Koil pengapian lemah | 0.722 | 0.722 | 0.722 | 18 |

### Confusion matrix (baris = kelas sebenarnya, kolom = prediksi)

| | K01 | K02 | K03 | K04 | K05 | K06 | K07 | K08 | K09 | K10 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **K01** | 9 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
| **K02** | 6 | 10 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| **K03** | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| **K04** | 0 | 0 | 0 | 7 | 0 | 0 | 0 | 0 | 0 | 0 |
| **K05** | 0 | 0 | 0 | 0 | 5 | 0 | 0 | 0 | 0 | 1 |
| **K06** | 0 | 0 | 0 | 1 | 0 | 5 | 0 | 0 | 0 | 0 |
| **K07** | 0 | 2 | 0 | 0 | 0 | 0 | 10 | 0 | 0 | 0 |
| **K08** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 7 | 0 | 0 |
| **K09** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 5 | 1 |
| **K10** | 0 | 0 | 0 | 0 | 2 | 0 | 0 | 0 | 3 | 13 |

Pasangan yang paling sering tertukar (sebenarnya -> diprediksi):

- K02 -> K01: 6 kali
- K10 -> K09: 3 kali
- K01 -> K10: 2 kali
- K07 -> K02: 2 kali
- K10 -> K05: 2 kali

## 4. Validasi silang (gambaran kestabilan)

- 5-fold berstrata pada seluruh data setelah dibersihkan, parameter yang sama:
  akurasi 68.3% +- 4.2%, F1 makro 0.739 +- 0.036
- Ini gambaran kestabilan, bukan pengganti data uji. Jika parameter disetel, angka ini sedikit optimistis.

## 5. Gejala paling berpengaruh

| Gejala | Uraian | Kepentingan |
|---|---|---:|
| G01 | Mesin susah dihidupkan | 0.089 |
| G05 | Knalpot berasap hitam | 0.079 |
| G04 | Knalpot berasap putih | 0.076 |
| G02 | Mesin mati mendadak | 0.073 |
| G18 | Putaran gas tidak stabil | 0.067 |
| G03 | Tarikan berat | 0.067 |
| G09 | Boros bensin | 0.067 |
| G11 | Rantai berisik | 0.059 |
| G06 | Suara mesin kasar | 0.054 |
| G10 | Rem kurang pakem | 0.051 |

## 6. Cara membaca hasil ini

- Keyakinan model adalah probabilitas dari `predict_proba`, bukan jaminan kebenaran.
- Dengan 96 baris uji, selisih satu baris sekitar 1.0%. Hindari melaporkan akurasi dengan presisi berlebih.
- Kepentingan gejala menunjukkan apa yang dipelajari model dari data ini, bukan bukti sebab-akibat teknis.

## 7. Reproduksi

- Python 3.13.14, scikit-learn 1.9.1, numpy 2.5.4
- Perintah: `python training\train_model.py` dari folder `bengkelpintar_backend`.
- Dibuat: 2026-11-15 07:55 UTC
