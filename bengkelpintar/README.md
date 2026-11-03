# BengkelPintar

Aplikasi Android Flutter untuk diagnosis motor dan POS bengkel. Fase ini
berjalan dengan data mock lokal sehingga dapat diuji tanpa backend.

## Menjalankan di HP

1. Aktifkan USB debugging di HP Android dan sambungkan dengan USB.
2. Dari PowerShell:

```powershell
cd C:\bengkel\bengkelpintar
flutter pub get
flutter devices
flutter run
```

Jika memakai API lokal pada fase berikutnya, gunakan IP laptop yang bisa
dijangkau HP:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Untuk membuat APK debug:

```powershell
flutter build apk --debug
```

APK berada di `build\app\outputs\flutter-apk\app-debug.apk`.

## Akun mock

| Peran | Username | Password |
|---|---|---|
| Admin | `admin` | `admin123` |
| Mekanik | `budi` | `budi123` |
| Mekanik | `rina` | `rina123` |

Simulasi server gagal tersedia di **Profil → Alamat Server → Simulasikan server
gagal**. Matikan sakelar lalu tekan `Coba lagi` pada layar data untuk menguji
pemulihan.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
