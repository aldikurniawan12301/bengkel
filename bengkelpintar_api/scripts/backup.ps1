# Skrip PowerShell untuk menjalankan backup database BengkelPintar
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ApiDir = Split-Path -Parent $ScriptDir
$Python = Join-Path $ApiDir ".venv\Scripts\python.exe"

if (-not (Test-Path $Python)) {
    $Python = "python"
}

& $Python (Join-Path $ScriptDir "backup.py") @args
