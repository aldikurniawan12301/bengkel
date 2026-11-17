# Skrip PowerShell untuk memulihkan database BengkelPintar dari berkas backup .sql
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ApiDir = Split-Path -Parent $ScriptDir
$Python = Join-Path $ApiDir ".venv\Scripts\python.exe"

if (-not (Test-Path $Python)) {
    $Python = "python"
}

& $Python (Join-Path $ScriptDir "restore.py") @args
