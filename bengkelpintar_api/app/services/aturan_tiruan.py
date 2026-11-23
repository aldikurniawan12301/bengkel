"""Pengklasifikasi TIRUAN untuk pengembangan, sampai model Random Forest asli tersedia (B-10, B-11).

PENTING:
- Bobot di bawah disusun manual dari nama gejala dan kerusakan. Ini BUKAN data penelitian,
  BUKAN hasil pelatihan, dan belum divalidasi mekanik.
- Keluaran tidak boleh dikutip sebagai akurasi, evaluasi, atau hasil model di skripsi.
- Antarmukanya sengaja sama dengan model asli (daftar gejala, daftar kelas, predict_proba),
  sehingga B-11 cukup mengganti isinya.

Perilaku yang ditiru dari Random Forest: banyak "pohon" yang masing-masing hanya melihat
sebagian gejala, tiap pohon memberi distribusi kelas, lalu distribusi dirata-rata sehingga
keluaran berupa probabilitas yang jumlahnya 1. Tidak ada angka acak: hasilnya selalu sama
untuk masukan yang sama.
"""

import hashlib
import math

KODE_GEJALA = tuple(f"G{n:02d}" for n in range(1, 32))
KODE_KERUSAKAN = tuple(f"K{n}" for n in range(1, 10))

# kerusakan -> {gejala: kekuatan hubungan 0..1}
# Disusun berdasarkan hubungan logis gejala-kerusakan untuk motor injeksi/matic
# Bobot TIRUAN, bukan hasil pelatihan. Ganti dengan model RF asli setelah B-11 selesai.
BOBOT: dict[str, dict[str, float]] = {
    "K1": {  # Busi lemah/kotor
        "G01": 0.9, "G02": 0.7, "G03": 0.8, "G04": 0.5, "G05": 0.6,
        "G06": 0.5, "G07": 0.6, "G19": 1.0, "G20": 0.5, "G26": 0.4,
    },
    "K2": {  # V-belt aus/mulur
        "G04": 0.7, "G09": 0.9, "G10": 0.7, "G12": 0.8, "G13": 0.9, "G30": 1.0,
    },
    "K3": {  # Roller CVT aus/peyang
        "G04": 0.6, "G10": 0.9, "G12": 0.9, "G13": 0.8, "G31": 1.0,
    },
    "K4": {  # Per CVT lemah
        "G04": 0.7, "G11": 0.9, "G12": 0.7, "G13": 0.7,
    },
    "K5": {  # Dinamo starter/bendik bermasalah
        "G14": 1.0, "G15": 0.8, "G16": 0.9, "G18": 0.6,
    },
    "K6": {  # Aki lemah
        "G14": 0.7, "G15": 0.9, "G16": 0.6, "G17": 1.0,
    },
    "K7": {  # Kompresi bocor
        "G01": 0.7, "G08": 0.6, "G21": 0.9, "G22": 0.9, "G23": 0.7,
        "G24": 1.0, "G25": 0.8,
    },
    "K8": {  # Fuel pump lemah
        "G01": 0.6, "G02": 0.7, "G05": 0.8, "G08": 0.9, "G25": 0.7, "G26": 0.8,
    },
    "K9": {  # Injektor/throttle body kotor
        "G03": 0.7, "G04": 0.6, "G05": 0.7, "G06": 0.6, "G07": 0.9,
        "G26": 0.7, "G27": 0.8, "G28": 0.6, "G29": 0.7,
    },
}


def _termasuk(pohon: int, kode: str, fraksi: float) -> bool:
    """Penentuan subset gejala per pohon, tetap dan tidak bergantung versi Python."""
    byte = hashlib.sha256(f"{pohon}:{kode}".encode()).digest()[0]
    return byte / 255 < fraksi


class AturanTiruan:
    kode_gejala = KODE_GEJALA
    kode_kerusakan = KODE_KERUSAKAN

    def __init__(self, jumlah_pohon: int = 40, fraksi_gejala: float = 0.7, suhu: float = 0.3, penalti: float = 0.15):
        self.suhu = suhu
        self.penalti = penalti
        self._subset = [
            {k for k in self.kode_gejala if _termasuk(p, k, fraksi_gejala)} for p in range(jumlah_pohon)
        ]

    def predict_proba(self, vektor: list[int]) -> list[float]:
        if len(vektor) != len(self.kode_gejala):
            raise ValueError("Panjang vektor gejala tidak sama dengan daftar gejala model.")
        ada = {k for k, v in zip(self.kode_gejala, vektor) if v}
        total = [0.0] * len(self.kode_kerusakan)
        for subset in self._subset:
            terlihat = ada & subset
            skor = []
            for kelas in self.kode_kerusakan:
                bobot = BOBOT[kelas]
                skor.append(sum(bobot.get(g, -self.penalti) for g in terlihat))
            puncak = max(skor)
            eksp = [math.exp((s - puncak) / self.suhu) for s in skor]
            jumlah = sum(eksp)
            for i, e in enumerate(eksp):
                total[i] += e / jumlah
        return [t / len(self._subset) for t in total]
