# 🌿 EcoPoint — Platform Manajemen Sampah Berbasis Ekonomi Sirkular

EcoPoint adalah platform ekosistem pengelolaan sampah digital berbasis **Ekonomi Sirkular**. Aplikasi ini mengintegrasikan **Warga** (penyetor sampah), **Mitra Pengepul** (Kolektor penjemput), dan **Admin** melalui aplikasi mobile Flutter modern dan RESTful API Backend.

---

## 🚀 Fitur Utama & Peran Pengguna (Role-based Features)

### 👤 1. Warga (User / Resident)
- **AI Trash Scanner (AI Vision)**: Deteksi otomatis jenis sampah (plastik, kardus, logam, dll.) via kamera/galeri dengan pemetaan kategori otomatis dan estimasi harga/poin.
- **Poin & E-Wallet**: Penukaran poin hasil setor sampah menjadi saldo e-wallet, konversi pulsa/e-money, dan penarikan tunai.
- **Peta Interaktif & Rute Kolektor**: Visualisasi lokasi kolektor terdekat di OpenStreetMap dengan garis rute (**Polyline**) dari rumah Warga ke lokasi Pengepul.
- **Setor & Penjemputan Sampah**: Pembuatan order penjemputan dengan estimasi berat, alamat kustom, serta foto sampah.
- **Rating & Ulasan**: Pemberian bintang dan ulasan teks untuk kolektor setelah transaksi selesai, tersinkronisasi secara real-time.
- **EcoTree & Carbon Tracker**: Edukasi & visualisasi dampak pengurangan jejak karbon serta pertumbuhan pohon virtual.
- **EcoBook**: Modul edukasi sirkular ekonomi dan pengelolaan limbah.
- **Chat Real-time**: Komunikasi langsung antara Warga dan Pengepul penjemput.

### 🚚 2. Mitra Pengepul (Collector)
- **Manajemen Pesanan**: Menerima pesanan penjemputan terdekat dan memproses status pesanan.
- **Timbangan & Verifikasi**: Input berat pasti dan kalkulasi total imbalan di lokasi penjemputan.
- **Dashboard & Ringkasan Penghasilan**: Pemantauan total pendapatan harian/bulanan, riwayat penjemputan, dan dompet kolektor.
- **Status Kendaraan & Online**: Pengaturan ketersediaan (online/offline) serta detail armada kendaraan.
- **Chat Penjemputan**: Komunikasi langsung dengan Warga lokasi penjemputan.

### 🛡️ 3. Admin (Dashboard & Control)
- **Statistik Real-time**: Grafik & counter statistik total Warga, Pengepul Aktif, Pesanan Berlangsung, dan Total Pendapatan.
- **Kelola Pengguna**: Pencarian, filter berdasarkan role (`Warga`, `Pengepul`), dan modal detail pengguna (saldo, poin, kontak).
- **Manajemen Keamanan**: Reset password pengguna dan hapus akun pengguna terintegrasi ke backend.
- **Manajemen Pesanan**: Pemantauan status transaksi seluruh sistem secara terpusat.

---

## 🏗️ Arsitektur & Teknologi

Project ini mengusung struktur **Monorepo**:

```text
ecopoint_app/
├── lib/                   # Flutter Mobile Application (Warga, Collector, Admin)
├── backend-api/           # Primary Backend API (Node.js Express + Supabase/PostgreSQL/SQLite)
├── backend/               # Legacy Backend API (Node.js Express + MySQL)
├── frontend/              # Admin Web Interface (React + Vite)
├── android/ & ios/        # Platform Native Enablers
└── assets/ & fonts/       # Asset Media & Custom Typography
```

### Tech Stack:
- **Mobile Client**: Flutter 3.x, Dart (State Management: Provider, Routing: GoRouter, Maps: Flutter Map + LatLong2, UI Effects: Flutter Animate, Shimmer, Toastification).
- **Backend Production**: Node.js, Express.js, Supabase / PostgreSQL (dengan SQLite fallback), JSON Web Token (JWT) Auth.
- **Deployment Backend**: Fly.io (`https://ecopoint-api.fly.dev`).
- **Web Portal**: React + Vite.

---

## 🔑 Kredensial Testing Default

Aplikasi mobile sudah terkonfigurasi secara otomatis ke server production live (`https://ecopoint-api.fly.dev`).

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@ecopoint.id` | `admin123456` |
| **Warga** | `test@ecopoint.id` | `test123456` |
| **Pengepul** | `collector@ecopoint.id` | `test123456` |

---

## 💻 Panduan Instalasi & Cara Jalankan

### Prerequisites
1. **Flutter SDK** (`^3.9.0`)
2. **Node.js** (`v18+`) & **npm**
3. **Android Studio / Emulator** (`emulator-5554` atau Perangkat Fisik)

---

### 1. Menjalankan Flutter Mobile App

1. Install dependensi Flutter:
   ```bash
   flutter pub get
   ```

2. Jalankan Static Analysis untuk memastikan zero error:
   ```bash
   flutter analyze lib/
   ```

3. Jalankan aplikasi di emulator atau perangkat fisik:
   ```bash
   flutter run
   ```

> 💡 **Konfigurasi Server**:
> Aplikasi membaca file [api_constants.dart](file:///c:/Users/ASUS/Documents/code/ecopoint_app/lib/core/constants/api_constants.dart) yang telah diatur secara default ke Live Server:
> `https://ecopoint-api.fly.dev`

---

### 2. Menjalankan Backend API Lokal (`backend-api`) *(Opsional)*

Jika ingin menjalankan server backend secara lokal:

1. Masuk ke folder `backend-api`:
   ```bash
   cd backend-api
   ```
2. Instal dependensi:
   ```bash
   npm install
   ```
3. Salin file `.env.example` menjadi `.env` dan sesuaikan konfigurasi.
4. Jalankan server lokal:
   ```bash
   npm start
   ```
5. Akses dokumentasi Swagger API di `http://localhost:3000/api-docs` atau cek endpoint kesehatan `http://localhost:3000/health`.

---

### 3. Build Release APK

Untuk membagikan atau menguji rilis APK Android, jalankan perintah build dengan pemisahan per ABI:

```bash
flutter analyze lib/
flutter build apk --release --split-per-abi
```

Hasil output build APK:
- **ARM64 (Recommended)**: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (Target size ≤ 20 MB)
- **ARMv7**: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (Target size ≤ 18 MB)
- **x86_64 (Emulator)**: `build/app/outputs/flutter-apk/app-x86_64-release.apk`

---

## ⚡ Quality Assurance & Verifikasi

Project ini dipastikan memenuhi standar:
- **Static Analysis**: `flutter analyze lib/` **0 errors**.
- **ADB Interactive Testing**: Seluruh alur (Login, Scan AI Sampah, Peta Rute & Polyline, Penjemputan, Rating & Ulasan, Manajemen User Admin) telah lulus verifikasi pada emulator.

