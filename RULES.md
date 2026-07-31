# 📋 EcoPoint - Panduan Wajib Development

> **WAJIB DIPATUHI** oleh semua agent/developer yang bekerja di project ini.  
> Dokumen ini berisi aturan build, upload, testing, dan konvensi penting.

---

## 🔨 Build APK

### Perintah Build
```bash
cd /home/user/myapp && flutter build apk --release --split-per-abi
```

### Catatan Penting Build
- **SELALU** gunakan `--split-per-abi` agar ukuran APK kecil (~18MB, bukan 53MB).
- **JANGAN** build tanpa `--split-per-abi` kecuali diminta secara eksplisit.
- Output APK ada di:
  - `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` → HP Modern (64-bit)
  - `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` → HP Lama (32-bit)
  - `build/app/outputs/flutter-apk/app-x86_64-release.apk` → Emulator/PC

### Target Ukuran APK
| Varian | Target Ukuran |
|---|---|
| ARM64 (HP Modern) | ≤ 20 MB |
| ARMv7 (HP Lama) | ≤ 18 MB |

---

## 📤 Upload APK

### Hosting File: **0x0.st** atau **catbox.moe**
Gunakan salah satu dari layanan berikut:

```bash
# Opsi 1: catbox.moe (rekomendasi - link permanen)
curl -F "reqtype=fileupload" -F "fileToUpload=@build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" https://catbox.moe/user/api.php

# Opsi 2: 0x0.st (link sementara, expired)
curl -F "file=@build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" https://0x0.st
```

### Format Penyampaian Link ke User
Selalu berikan dalam format ini:
```
1. 📲 Android HP Modern (64-bit ARM):
   • Ukuran: XX MB
   • Link Download: https://...

2. 📱 Android HP Lama (32-bit ARMv7):
   • Ukuran: XX MB
   • Link Download: https://...
```

---

## 🧪 Testing Wajib

### 1. Static Analysis
```bash
# WAJIB: Cek 0 error kompilasi
flutter analyze lib/

# OPSIONAL tapi DIANJURKAN: Format kode
flutter format .
```

### 2. Manual Testing di Android Emulator (ADB)
- **Wajib Dijalankan di Perangkat Android/Emulator** yang terhubung via ADB (`emulator-5554` / `localhost:5555`).
- **Pengujian Interaktif & Flow:**
  - Lakukan tes manual pada elemen UI: tekan tombol, isi form (input text), kirim form.
  - Tes alur utama: Registrasi akun baru, Login, Navigasi antarmuka/halaman.
- **Screenshot & UI Verification:**
  - Ambil screenshot pada **setiap tahap pengujian** (menggunakan `adb exec-out screencap -p` atau alat bantu screenshot).
  - Inspeksi screenshot untuk memastikan **fungsi berjalan 100%** dan **tampilan UI tidak cacat/broken layout/overflow error**.

### 3. Loop Perbaikan Otomatis (Iterative Autonomous Remediation Loop)
- **Alur Looping Perbaikan Mandiri:**
  1. **Jika Backend API Error/Bermasalah:** Perbaiki kode backend (`backend-api/`), kemudian wajib langsung di-deploy menggunakan `flyctl deploy`.
  2. **Perbaiki Kode Flutter (APK):** Perbaiki logika atau UI di `lib/`.
  3. **Testing via ADB & Emulator:** Jalankan dan tes aplikasi di emulator terhubung (`emulator-5554` / `localhost:5555`), lakukan tes manual (isi form, tekan tombol, registrasi/login), dan ambil screenshot tiap tahap.
  4. **Evaluasi Hasil:** Jika ditemukan error, exception, gagal API, atau cacat tampilan (broken layout/overflow): **KEMBALI KE LANGKAH 1 ATAU 2** untuk memperbaikinya lagi.
  5. **Iterasi Berulang (Looping):** Ulangi siklus ini terus-menerus hingga aplikasi **100% sempurna**, bebas error, dan UI tidak ada yang cacat sebelum menyatakan selesai.

### Setelah Perubahan Kode
- Jalankan `flutter analyze` setelah SETIAP perubahan kode.
- Pastikan **0 error** sebelum melanjutkan.
- Warning & info boleh diabaikan, tapi error **HARUS** diperbaiki.

---

## 🌐 Backend API

### Base URL
```
https://ecopoint-api.fly.dev/api
```

### Konvensi Penting
- **JANGAN** hardcode URL. Selalu gunakan `ApiConstants` dari `lib/core/constants/api_constants.dart`.
- **JANGAN** gunakan `ApiConstants.baseUrl` untuk endpoint (tidak ada `/api`). Gunakan konstanta spesifik seperti `ApiConstants.login`, `ApiConstants.wallet`, dll.
- **JANGAN** gunakan `ApiConstants.headers` (TIDAK ADA). Tulis headers inline:
  ```dart
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  }
  ```

### Endpoint yang Tersedia
| Method | Path | Role | Fungsi |
|---|---|---|---|
| POST | /login | Public | Login |
| POST | /register | Public | Registrasi |
| POST | /forgot-password | Public | Reset password via email |
| PUT | /change-password | Auth | Ganti password |
| DELETE | /account | Auth | Hapus akun |
| PUT | /profile | Auth | Update profil (name, phone) |
| GET | /wallet | User | Saldo dompet |
| GET | /orders | User | Daftar pesanan |
| GET | /prices | User | Katalog harga |
| GET | /transactions | User | Riwayat transaksi |
| POST | /order | User | Buat pesanan baru |
| PUT | /order/:id/cancel | User | Batalkan pesanan |
| POST | /redeem | User | Tukar eco points |
| POST | /wallet/topup | Auth | Top up saldo |
| POST | /wallet/withdraw | Auth | Tarik saldo ke bank |
| POST | /upload | Public | Upload foto |
| POST | /analyze-image | Public | AI analisis sampah |
| PUT | /location | Collector | Update lokasi GPS |
| GET | /nearby-orders | Collector | Pesanan terdekat |
| POST | /order/:id/accept | Collector | Terima pesanan |
| PUT | /order/:id/en-route | Collector | Status dalam perjalanan |
| POST | /order/:id/pay | Collector | Selesai & bayar |
| GET | /collector/orders | Collector | Pesanan pengepul |
| GET | /collector/earnings | Collector | Pendapatan pengepul |
| GET | /collector/wallet | Collector | Saldo pengepul |
| GET | /statistics | Admin | Statistik dashboard |
| GET | /admin/users | Admin | Daftar pengguna |
| GET | /admin/orders | Admin | Semua pesanan |
| POST | /scrape-prices | Admin | Scrape harga sampah |
| POST | /price | Admin | Update harga |
| POST | /admin/user/balance | Admin | Update saldo user |
| DELETE | /message/:id | Auth | Hapus pesan |

---

## 📁 Struktur Penting Project

```
/home/user/myapp/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart   # SEMUA endpoint API
│   │   ├── router/
│   │   │   └── app_router.dart      # GoRouter config
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       └── image_picker_helper.dart
│   ├── models/                      # Data models
│   ├── providers/                   # State management (ChangeNotifier)
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   ├── collector_provider.dart
│   │   └── admin_provider.dart
│   ├── services/
│   │   └── api_service.dart         # HTTP helper (upload dll)
│   ├── views/
│   │   ├── auth/                    # Login, Register, Forgot Password
│   │   ├── user/                    # Dashboard, Order, Wallet, Profile
│   │   ├── collector/               # Nearby, Tasks, Wallet, Profile
│   │   └── admin/                   # Dashboard, Orders, Users, Settings
│   └── widgets/                     # Shared widgets
├── backend-api/                     # Node.js Express backend
│   └── src/
│       ├── routes/api.js            # Semua routes
│       ├── controllers/             # Business logic
│       ├── middleware/auth.js        # JWT auth middleware
│       └── config/supabase.js       # Supabase client
├── pubspec.yaml
├── PROGRESS.md                      # Log progress development
├── RULES.md                         # FILE INI - panduan wajib
└── GEMINI.md                        # AI development guidelines
```

---

## 🚫 Yang JANGAN Dilakukan

1. **JANGAN** build APK tanpa `--split-per-abi`.
2. **JANGAN** hardcode API URL. Selalu pakai `ApiConstants`.
3. **JANGAN** pakai `ApiConstants.headers` (tidak ada field itu).
4. **JANGAN** pakai `ApiConstants.baseUrl` untuk endpoint (kurang `/api`).
5. **JANGAN** ubah backend tanpa update `ApiConstants` di Flutter juga.
6. **JANGAN** deploy/build sebelum `flutter analyze` = 0 error.
7. **JANGAN** pakai `withOpacity()` - sudah deprecated. Pakai `withValues(alpha: 0.x)`.
8. **JANGAN** lupa jalankan `flutter pub get` setelah menambah dependency.
9. **JANGAN** upload APK ke hosting selain catbox.moe atau 0x0.st kecuali diminta.

---

## ✅ Checklist Sebelum Rilis

- [ ] `flutter analyze lib/` = 0 error
- [ ] Berhasil diuji di Android Emulator terhubung (manual test: tombol, isi form, register flow)
- [ ] Screenshot diambil pada tiap tahap & UI dipastikan tidak cacat / broken
- [ ] `flutter build apk --release --split-per-abi` berhasil
- [ ] Ukuran APK ARM64 ≤ 20 MB
- [ ] Upload ke catbox.moe / 0x0.st
- [ ] Berikan link ke user dalam format standar
- [ ] Update PROGRESS.md dengan perubahan terbaru

---

## 🔑 Akun Testing

### User Warga
```
Email: test@ecopoint.id
Password: test123456
```

### Collector / Pengepul
```
Email: collector@ecopoint.id
Password: test123456
```

### Admin
```
Email: admin@ecopoint.id
Password: admin123456
```

> ⚠️ Akun testing mungkin perlu di-register ulang jika database direset.

---

*Terakhir diperbarui: 2026-07-31*
