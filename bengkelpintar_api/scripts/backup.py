"""Skrip backup database PostgreSQL untuk BengkelPintar.

Membaca konfigurasi dari .env atau argumen CLI, lalu mengekspor
struktur dan data database menggunakan pg_dump ke format SQL yang aman dan portabel.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from datetime import datetime
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
    """Temukan biner executable (misal pg_dump) di PATH atau instalasi PostgreSQL."""
    # 1. Cari di PATH
    path_ditemukan = shutil.which(nama)
    if path_ditemukan:
        return path_ditemukan

    # 2. Khusus Windows: cari di Program Files PostgreSQL
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
    # Bersihkan skema postgresql+psycopg:// menjadi postgresql://
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


def jalankan_backup(
    db_url: str | None = None,
    output_file: str | None = None,
    folder_output: str | None = None,
) -> Path:
    """Eksekusi pg_dump untuk mencadangkan database."""
    env_vars = muat_env()
    raw_url = db_url or env_vars.get("DATABASE_URL") or os.environ.get("DATABASE_URL")
    if not raw_url:
        raise ValueError("DATABASE_URL tidak ditemukan di .env maupun argumen CLI.")

    info = parse_database_url(raw_url)

    # Tentukan berkas tujuan
    if output_file:
        tujuan = Path(output_file).resolve()
    else:
        dir_tujuan = Path(folder_output) if folder_output else (DIR_API / "backups")
        dir_tujuan.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        nama_file = f"{info['dbname']}_{timestamp}.sql"
        tujuan = dir_tujuan / nama_file

    tujuan.parent.mkdir(parents=True, exist_ok=True)

    pg_dump_bin = temukan_biner("pg_dump")

    perintah = [
        pg_dump_bin,
        "-h",
        str(info["host"]),
        "-p",
        str(info["port"]),
        "-U",
        str(info["user"]),
        "-d",
        str(info["dbname"]),
        "--clean",
        "--if-exists",
        "--no-owner",
        "--no-privileges",
        "--encoding=UTF8",
        "-f",
        str(tujuan),
    ]

    print(f"[BACKUP] Memulai pencadangan database: {info['dbname']}@{info['host']}:{info['port']}")
    print(f"[BACKUP] Output: {tujuan}")

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
            print(hasil.stdout)
    except subprocess.CalledProcessError as err:
        print(f"[ERROR] pg_dump gagal dengan kode keluar {err.returncode}:", file=sys.stderr)
        print(err.stderr, file=sys.stderr)
        if tujuan.exists() and tujuan.stat().st_size == 0:
            tujuan.unlink(missing_ok=True)
        raise

    ukuran_kb = tujuan.stat().st_size / 1024
    print(f"[SUKSES] Backup selesai! Berkas: {tujuan} ({ukuran_kb:.2f} KB)")
    return tujuan


def main():
    parser = argparse.ArgumentParser(description="Backup database PostgreSQL BengkelPintar")
    parser.add_argument("--url", help="Database URL (default: ambil dari .env)")
    parser.add_argument("--output", help="Path lengkap berkas output .sql")
    parser.add_argument("--dir", help="Direktori penyimpanan backup (default: bengkelpintar_api/backups)")
    args = parser.parse_args()

    try:
        jalankan_backup(
            db_url=args.url,
            output_file=args.output,
            folder_output=args.dir,
        )
    except Exception as e:
        print(f"Gagal menjalankan backup: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
