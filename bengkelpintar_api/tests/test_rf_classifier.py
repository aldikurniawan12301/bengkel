from pathlib import Path
import pytest
from app.services.rf_classifier import RFClassifier

MODEL_DIR = Path(__file__).resolve().parent.parent.parent / "bengkelpintar_backend" / "models"


def test_muat_rf_classifier_sukses():
    if not (MODEL_DIR / "rf_model.pkl").is_file():
        pytest.skip("Model rf_model.pkl belum dilatih di bengkelpintar_backend/models")
    rf = RFClassifier(MODEL_DIR)
    assert len(rf.kode_gejala) == 18
    assert len(rf.kode_kerusakan) == 10
    assert rf.kode_gejala[0] == "G01"
    assert rf.kode_gejala[-1] == "G18"
    assert rf.kode_kerusakan[0] == "K01"
    assert rf.kode_kerusakan[-1] == "K10"


def test_rf_classifier_predict_proba():
    if not (MODEL_DIR / "rf_model.pkl").is_file():
        pytest.skip("Model rf_model.pkl belum dilatih di bengkelpintar_backend/models")
    rf = RFClassifier(MODEL_DIR)

    # Vektor G01, G03, G04 aktif
    vektor = [1 if g in ("G01", "G03", "G04") else 0 for g in rf.kode_gejala]
    probs = rf.predict_proba(vektor)

    assert len(probs) == 10
    assert all(0 <= p <= 1 for p in probs)
    assert sum(probs) == pytest.approx(1.0)

    # K01 (Busi kotor) harus memiliki probabilitas signifikan
    idx_k01 = rf.kode_kerusakan.index("K01")
    assert probs[idx_k01] > 0.2


def test_rf_classifier_panjang_vektor_salah():
    if not (MODEL_DIR / "rf_model.pkl").is_file():
        pytest.skip("Model rf_model.pkl belum dilatih di bengkelpintar_backend/models")
    rf = RFClassifier(MODEL_DIR)
    with pytest.raises(ValueError, match="Panjang vektor"):
        rf.predict_proba([1, 0, 1])


def test_rf_classifier_folder_tidak_ditemukan(tmp_path):
    with pytest.raises(FileNotFoundError):
        RFClassifier(tmp_path / "folder_kosong")
