"""Skrip restore (pemulihan) database PostgreSQL untuk BengkelPintar.

Membaca berkas cadangan .sql dan memulihkannya ke database PostgreSQL
menggunakan perintah psql.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlparse

# Direktori proyek
DIR_API = Path(__file__).resolve().parent.parent


def muat_env() -> dict[str, str]:
    """Muat variabel dari berkas .env jika ada."""
    env_file = DIR_API / ".env"
    env_vars = {}
    if env_file.exists():
        for baris in env_file.read_text(encoding="utf-8").splitlines():
            baris = baris.strip()
            if baris and not baris.startswith("#") and "=" in baris:
                k, v = baris.split("=", 1)
                env_vars[k.strip()] = v.strip()
    return env_vars


def temukan_biner(nama: str) -> str:
    """Temukan biner executable (misal psql) di PATH atau instalasi PostgreSQL."""
    path_ditemukan = shutil.which(nama)
    if path_ditemukan:
        return path_ditemukan

    if sys.platform.startswith("win"):
        root_pg = Path(r"C:\Program Files\PostgreSQL")
        if root_pg.exists():
            for versi_dir in sorted(root_pg.iterdir(), reverse=True):
                calon = versi_dir / "bin" / f"{nama}.exe"
                if calon.exists():
                    return str(calon)

    return nama


def parse_database_url(url_str: str) -> dict[str, str | int]:
    """Ekstrak komponen koneksi dari URL SQLAlchemy/PostgreSQL."""
    if "://" in url_str:
        skema, sisa = url_str.split("://", 1)
        url_str = f"postgresql://{sisa}"

    u = urlparse(url_str)
    return {
        "host": u.hostname or "localhost",
        "port": u.port or 5432,
        "user": u.username or "postgres",
        "password": u.password or "",
        "dbname": u.path.lstrip("/") or "bengkelpintar",
    }


def jalankan_restore(
    file_sql: str | Path,
    db_url: str | None = None,
    dbname_override: str | None = None,
    tanpa_konfirmasi: bool = False,
) -> bool:
    """Eksekusi psql untuk memulihkan database dari berkas .sql."""
    file_path = Path(file_sql).resolve()
    if not file_path.exists():
        raise FileNotFoundError(f"Berkas backup tidak ditemukan: {file_path}")

    env_vars = muat_env()
    raw_url = db_url or env_vars.get("DATABASE_URL") or os.environ.get("DATABASE_URL")
    if not raw_url:
        raise ValueError("DATABASE_URL tidak ditemukan di .env maupun argumen CLI.")

    info = parse_database_url(raw_url)
    target_db = dbname_override or info["dbname"]

    if not tanpa_konfirmasi:
        print(f"[PERINGATAN] Anda akan memulihkan data ke database: '{target_db}' di {info['host']}:{info['port']}")
        print(f"[PERINGATAN] Berkas sumber: {file_path}")
        konfirmasi = input("Lanjutkan pemulihan? Tindakan ini dapat menimpa data yang ada (y/N): ").strip().lower()
        if konfirmasi != "y":
            print("[BATAL] Pemulihan dibatalkan oleh pengguna.")
            return False

    psql_bin = temukan_biner("psql")

    perintah = [
        psql_bin,
        "-h",
        str(info["host"]),
        "-p",
        str(info["port"]),
        "-U",
        str(info["user"]),
        "-d",
        str(target_db),
        "-v",
        "ON_ERROR_STOP=1",
        "-f",
        str(file_path),
    ]

    print(f"[RESTORE] Menjalankan pemulihan ke database '{target_db}'...")

    env_exec = os.environ.copy()
    if info["password"]:
        env_exec["PGPASSWORD"] = str(info["password"])

    try:
        hasil = subprocess.run(
            perintah,
            env=env_exec,
            capture_output=True,
            text=True,
            check=True,
        )
        if hasil.stdout:
            # Tampilkan beberapa baris informasi bila ada
            baris = [b for b in hasil.stdout.splitlines() if b.strip()]
            if baris:
                print(f"[RESTORE] Output psql: {baris[-1]}")
    except subprocess.CalledProcessError as err:
        print(f"[ERROR] psql gagal dengan kode keluar {err.returncode}:", file=sys.stderr)
        print(err.stderr, file=sys.stderr)
        raise

    print(f"[SUKSES] Database '{target_db}' berhasil dipulihkan dari {file_path.name}!")
    return True


def main():
    parser = argparse.ArgumentParser(description="Restore database PostgreSQL BengkelPintar dari berkas .sql")
    parser.add_argument("file", help="Path berkas backup .sql yang akan dipulihkan")
    parser.add_argument("--url", help="Database URL target (default: baca dari .env)")
    parser.add_argument("--dbname", help="Ganti nama database target (opsional)")
    parser.add_argument("-y", "--yes", action="store_true", help="Lewati pertanyaan konfirmasi")
    args = parser.parse_args()

    try:
        jalankan_restore(
            file_sql=args.file,
            db_url=args.url,
            dbname_override=args.dbname,
            tanpa_konfirmasi=args.yes,
        )
    except Exception as e:
        print(f"Gagal memulihkan database: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
