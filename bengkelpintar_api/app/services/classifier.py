import logging
from pathlib import Path
from typing import Protocol

from app import config
from app.services.aturan_tiruan import AturanTiruan

log = logging.getLogger("bengkelpintar.classifier")


class Classifier(Protocol):
    """Antarmuka yang dipakai layanan diagnosis. Model Random Forest asli (B-11) cukup
    menyediakan tiga hal ini, dengan urutan gejala dan kelas yang sama seperti saat pelatihan."""

    kode_gejala: tuple[str, ...]
    kode_kerusakan: tuple[str, ...]

    def predict_proba(self, vektor: list[int]) -> list[float]: ...


_pengklasifikasi: Classifier | None = None


def muat_pengklasifikasi() -> Classifier:
    """Memuat model RF asli jika MODEL_DIR disetel dan file tersedia, jika tidak pakai AturanTiruan."""
    global _pengklasifikasi
    if config.MODEL_DIR:
        path = Path(config.MODEL_DIR)
        if not path.is_absolute():
            path = Path(__file__).resolve().parent.parent.parent / path
        if (path / "rf_model.pkl").is_file() and (path / "model_meta.json").is_file():
            try:
                from app.services.rf_classifier import RFClassifier

                _pengklasifikasi = RFClassifier(path)
                return _pengklasifikasi
            except Exception as e:
                log.warning(
                    "Gagal memuat model Random Forest dari %s: %s. Memakai AturanTiruan.",
                    path,
                    e,
                )

    _pengklasifikasi = AturanTiruan()
    return _pengklasifikasi


def ambil_pengklasifikasi() -> Classifier:
    """Dipasang sebagai dependency FastAPI, sehingga mudah diganti (B-11) atau ditimpa di tes."""
    global _pengklasifikasi
    if _pengklasifikasi is None:
        _pengklasifikasi = muat_pengklasifikasi()
    return _pengklasifikasi
