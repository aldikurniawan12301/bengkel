#!/usr/bin/env bash
# Skrip Bash untuk menjalankan backup database BengkelPintar di Linux/VPS
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$(dirname "$SCRIPT_DIR")"

PYTHON="${API_DIR}/.venv/bin/python"
if [ ! -f "$PYTHON" ]; then
    PYTHON="python3"
fi

exec "$PYTHON" "${SCRIPT_DIR}/backup.py" "$@"
