import json
import logging
from pathlib import Path

import joblib
import numpy as np

log = logging.getLogger("bengkelpintar.rf")


class RFClassifier:
    """Implementasi Classifier yang memuat model Random Forest scikit-learn (.pkl)
    dan metadata (model_meta.json) dari folder model."""

    def __init__(self, model_dir: str | Path):
        self.model_dir = Path(model_dir)
        meta_path = self.model_dir / "model_meta.json"
        pkl_path = self.model_dir / "rf_model.pkl"

        if not meta_path.is_file():
            raise FileNotFoundError(f"Metadata model tidak ditemukan: {meta_path}")
        if not pkl_path.is_file():
            raise FileNotFoundError(f"File model tidak ditemukan: {pkl_path}")

        with open(meta_path, "r", encoding="utf-8") as f:
            self.meta = json.load(f)

        self.kode_gejala: tuple[str, ...] = tuple(self.meta["kode_gejala"])
        self.kode_kerusakan: tuple[str, ...] = tuple(self.meta["kode_kelas"])

        self.model = joblib.load(pkl_path)
        self._classes = [str(c) for c in self.model.classes_]

        # Pemetaan urutan kelas agar predict_proba selalu konsisten dengan kode_kerusakan
        self._class_indices = [self._classes.index(k) for k in self.kode_kerusakan]
        log.info(
            "Model Random Forest berhasil dimuat dari %s (%d gejala, %d kelas)",
            self.model_dir,
            len(self.kode_gejala),
            len(self.kode_kerusakan),
        )

    def predict_proba(self, vektor: list[int]) -> list[float]:
        if len(vektor) != len(self.kode_gejala):
            raise ValueError(
                f"Panjang vektor ({len(vektor)}) tidak sama dengan daftar gejala model ({len(self.kode_gejala)})."
            )
        X = np.array(vektor, dtype=np.int8).reshape(1, -1)
        raw_probs = self.model.predict_proba(X)[0]
        return [float(raw_probs[idx]) for idx in self._class_indices]
