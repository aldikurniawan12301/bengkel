"""Pengukuran Tabel 5 untuk bengkelpintar_api: latensi diagnosis, keberhasilan request,
dan kontrol akses (401/403). Hanya memakai library standar Python.

Rahasia (API key, password) dibaca dari variabel lingkungan atau prompt, tidak ditulis di kode.
PERHATIAN: setiap panggilan POST /diagnosis/predict menyimpan satu baris riwayat ke database.
Jalankan pada database pengembangan, bukan data yang dipakai untuk demo atau produksi.

Contoh:
    python scripts\\ukur_tabel5.py --admin-user admin --user-user NAMA_NON_ADMIN --n 50
Untuk klaim "koneksi internet normal", jalankan dari perangkat lain dengan
    --base-url http://IP_SERVER:8000
"""
import argparse
import getpass
import json
import math
import os
import random
import statistics
import sys
import time
import urllib.error
import urllib.request


def panggil(metode, url, api_key=None, token=None, badan=None, timeout=15):
    """Mengembalikan (status, json, durasi_detik, pesan_error)."""
    header = {"Accept": "application/json"}
    if api_key:
        header["X-API-Key"] = api_key
    if token:
        header["Authorization"] = f"Bearer {token}"
    data = None
    if badan is not None:
        data = json.dumps(badan).encode("utf-8")
        header["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=header, method=metode)
    mulai = time.perf_counter()
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            kode, isi = r.status, r.read()
    except urllib.error.HTTPError as e:
        kode, isi = e.code, e.read()
    except Exception as e:  # koneksi gagal atau timeout
        return None, None, time.perf_counter() - mulai, str(e)
    durasi = time.perf_counter() - mulai
    try:
        js = json.loads(isi)
    except ValueError:
        js = None
    return kode, js, durasi, None


def masuk(base, api_key, path, username, password):
    kode, js, _, err = panggil(
        "POST", base + path, api_key, badan={"username": username, "password": password}
    )
    if kode != 200 or not isinstance(js, dict):
        sys.exit(f"Login '{username}' gagal: status={kode}, error={err}, respons={js}")
    for kunci in ("access_token", "token", "jwt"):
        if kunci in js:
            return js[kunci]
    sys.exit(f"Token tidak ditemukan di respons login. Kunci yang ada: {list(js)}")


def ambil_rahasia(nama_env, prompt):
    return os.environ.get(nama_env) or getpass.getpass(prompt)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base-url", default="http://127.0.0.1:8000")
    ap.add_argument("--login-path", default="/auth/login", help="cek di /docs atau app/main.py")
    ap.add_argument("--n", type=int, default=50, help="jumlah request latensi (di luar request pertama)")
    ap.add_argument("--jumlah-gejala", type=int, default=5)
    ap.add_argument("--admin-user", required=True)
    ap.add_argument("--user-user", default=None, help="akun non-admin untuk uji 403")
    ap.add_argument("--timeout", type=float, default=15)
    a = ap.parse_args()
    base = a.base_url.rstrip("/")

    api_key = ambil_rahasia("API_KEY", "API key: ")
    token_admin = masuk(base, api_key, a.login_path, a.admin_user,
                        ambil_rahasia("ADMIN_PASSWORD", "Password admin: "))
    token_user = None
    if a.user_user:
        token_user = masuk(base, api_key, a.login_path, a.user_user,
                           ambil_rahasia("USER_PASSWORD", "Password non-admin: "))

    # Payload diagnosis: DiagnosisRequest hanya berisi gejala_ids (id database, bukan kode G01...)
    kode, daftar, _, err = panggil("GET", base + "/gejala", api_key, token_admin)
    if kode != 200 or not isinstance(daftar, list) or not daftar or "id" not in daftar[0]:
        sys.exit(f"Gagal mengambil /gejala: status={kode}, error={err}")
    ids = [g["id"] for g in daftar]
    payload = {"gejala_ids": random.Random(42).sample(ids, min(a.jumlah_gejala, len(ids)))}
    print(f"Jumlah gejala di database: {len(ids)}; payload uji: {payload}\n")

    # ---- Latensi dan keberhasilan request ----
    url = base + "/diagnosis/predict"
    k0, _, d0, e0 = panggil("POST", url, api_key, token_admin, payload, a.timeout)
    print(f"Request pertama (termasuk pemuatan model): status={k0}, {d0:.3f} dtk {e0 or ''}")

    durasi_ok, status = [], []
    for _ in range(a.n):
        k, _, d, _ = panggil("POST", url, api_key, token_admin, payload, a.timeout)
        status.append(k)
        if k == 200:
            durasi_ok.append(d)
    ok = len(durasi_ok)
    print(f"\nKeberhasilan request: {ok}/{a.n} ({100 * ok / a.n:.1f}%)")
    gagal = sorted({s for s in status if s != 200}, key=str)
    if gagal:
        print(f"  status selain 200: {gagal}")
    if durasi_ok:
        urut = sorted(durasi_ok)
        p95 = urut[max(0, math.ceil(0.95 * len(urut)) - 1)]
        print(f"Latensi (hanya yang sukses): rata-rata {statistics.mean(urut):.3f} dtk | "
              f"median {statistics.median(urut):.3f} | P95 {p95:.3f} | maks {urut[-1]:.3f}")
        print(f"  di bawah 3 dtk: {sum(d < 3 for d in urut)}/{len(urut)}")

    # ---- Kontrol akses ----
    print("\nKontrol akses (status aktual vs harapan):")
    kasus = [
        ("tanpa API key", None, None, 401),
        ("API key benar, tanpa token", api_key, None, 401),
        ("API key benar, token tidak valid", api_key, "token.palsu.tidak-valid", 401),
    ]
    if token_user:
        kasus.append(("non-admin", api_key, token_user, 403))
    kasus.append(("admin", api_key, token_admin, 200))
    for path in ("/diagnosis/statistik", "/pengguna"):
        for nama, kunci, tok, harap in kasus:
            k, _, _, err = panggil("GET", base + path, kunci, tok, timeout=a.timeout)
            tanda = "OK " if k == harap else "BEDA"
            print(f"  [{tanda}] GET {path:<22} {nama:<34} aktual={k} harapan={harap} {err or ''}")
    if not token_user:
        print("  (uji 403 dilewati: --user-user tidak diberikan)")

    print("\nCek juga log server: tidak boleh ada peringatan 'Memakai AturanTiruan'.")


if __name__ == "__main__":
    main()