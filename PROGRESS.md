# EcoPoint App — Progress & Continuation Guide

> **Last Updated**: 2026-08-03 06:12 UTC

---

## ✅ Apa yang Sudah Selesai

### 1. Admin Dashboard — UI Overhaul & Fitur Manajemen User
- **Dashboard Tab**: Statistik real-time (Total Warga, Pengepul, Pesanan, Pendapatan) dengan kartu animasi dan ikon.
- **Kelola Pengguna Tab**: Daftar user dengan search bar, filter role badge (`Semua`, `Warga`, `Pengepul`).
- **Fitur Lihat Detail User**: Bottom sheet menampilkan ID, email, nama, role, nomor HP, saldo wallet, poin.
- **Fitur Reset Password**: Dialog modal input password baru + konfirmasi, dengan toggle visibilitas.
- **Fitur Hapus User**: Dialog konfirmasi peringatan merah dengan info user yang akan dihapus.

### 2. Backend API (Express + Supabase)
- **Deployed ke Fly.io**: `https://ecopoint-api.fly.dev`
- **Endpoint Admin** yang tersedia:
  - `GET /api/admin/users` — List semua user
  - `DELETE /api/admin/user/:userId` — Hapus user
  - `POST /api/admin/reset-password` — Reset password user
  - `GET /api/statistics` — Statistik dashboard
- **Health check**: `GET /health` → `{"status":"ok"}`

### 3. Flutter App Build
- `baseUrl` sudah diset ke **production**: `https://ecopoint-api.fly.dev`
- `flutter analyze lib/` → **0 errors** (21 info/warnings, bukan error)
- APK berhasil di-build:
  - **ARM64**: 19.7 MB ≤ 20 MB ✅
  - **ARMv7**: 17.4 MB ≤ 18 MB ✅
  - **x86_64**: 21.0 MB (emulator only)

### 4. ADB Testing (Verified via Screenshots)
Semua fitur interaktif diuji pada `emulator-5554`:
- ✅ Login admin → navigasi ke admin dashboard
- ✅ Dashboard tab menampilkan statistik
- ✅ Pengguna tab menampilkan daftar user
- ✅ Modal Lihat Detail User berfungsi
- ✅ Modal Reset Password berfungsi
- ✅ Modal Hapus User berfungsi

---

## ⚠️ Hal Penting yang Perlu Diketahui

### Fly.io Machine Auto-Stop
Server Fly.io dikonfigurasi dengan `auto_stop_machines = true` dan `min_machines_running = 0`.
Artinya **machine akan otomatis berhenti jika tidak ada traffic**, tapi juga `auto_start_machines = true` yang artinya **machine akan otomatis start saat ada request masuk**.

Jadi kalau buka aplikasi dan request pertama agak lambat (cold start ~5-10 detik), itu normal.

Jika ingin machine selalu hidup, ubah di `backend-api/fly.toml`:
```toml
min_machines_running = 1
```
Lalu deploy ulang: `flyctl deploy` dari folder `backend-api/`.

### Fly.io Deploy Error (Registry Push 401)
Saat sesi ini, `flyctl deploy` gagal karena error `401 Unauthorized` di registry push (kemungkinan token expired).
**Solusi**: Jalankan ulang:
```bash
cd /home/user/myapp/backend-api
flyctl auth login
flyctl deploy
```

### GoogleFonts Disabled
`GoogleFonts` (package `google_fonts`) sudah **diganti dengan `TextStyle` biasa** di `lib/core/theme/app_theme.dart` karena menyebabkan crash `SocketException: Failed host lookup 'fonts.gstatic.com'` di emulator. Font default Flutter (`Roboto`) digunakan sebagai pengganti.

---

## 📁 File-File Utama yang Diubah

| File | Perubahan |
|------|-----------|
| `lib/core/constants/api_constants.dart` | `baseUrl` = `https://ecopoint-api.fly.dev` (production) |
| `lib/core/theme/app_theme.dart` | GoogleFonts → TextStyle biasa (fix crash) |
| `lib/views/auth/login_screen.dart` | Pre-fill admin credentials + role-based routing |
| `lib/views/admin/admin_dashboard_tab.dart` | Statistik dashboard + loading/error state |
| `lib/views/admin/admin_users_tab.dart` | Kelola pengguna: search, filter, detail, reset pass, hapus |
| `backend-api/src/routes/api.js` | Endpoint admin (users, delete, reset-password) |
| `backend-api/fly.toml` | Fly.io deployment config |

---

## 📦 Link Download APK Terakhir (Production)

> ⚠️ Link `tmpfiles.org` expire setelah beberapa jam.

| Arsitektur | Ukuran | Link |
|------------|--------|------|
| ARM64-v8a (Recommended) | 19.7 MB | `https://tmpfiles.org/dl/wTweRlNuB6Rh/app-arm64-v8a-release.apk` |
| ARMv7 | 17.4 MB | `https://tmpfiles.org/dl/w2wVRSNjBbkk/app-armeabi-v7a-release.apk` |
| x86_64 (Emulator) | 21.0 MB | `build/app/outputs/flutter-apk/app-x86_64-release.apk` |

### Perubahan 2026-08-03
- **AdminProvider**: `fetchDashboardData()` pagination loop — ambil semua halaman user (`limit=1000`), bukan default 20
- **Backend `paginate.js`**: ceiling `limit` 100 → 1000
- **AdminDashboardTab**: tap `Total Warga` → filter `user`, tap `Kolektor Aktif` → filter `collector` di tab Pengguna
- **AdminUsersTab**: menerima `selectedRole` dari parent, auto-filter saat navigasi
- **Backend**: deploy ulang via `flyctl deploy --depot=false`

---

## 🔑 Kredensial Testing

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@ecopoint.id` | `admin123456` |
| Warga | `test@ecopoint.id` | `test123456` |
| Pengepul | `collector@ecopoint.id` | `test123456` |

---

## 🔄 Langkah untuk Melanjutkan Nanti

1. **Pastikan backend aktif**:
   ```bash
   curl https://ecopoint-api.fly.dev/health
   ```
   Jika tidak responsif, start manual:
   ```bash
   cd /home/user/myapp/backend-api
   flyctl machine start 0800532f033448
   ```

## Work Completed

1. **AI Vision Fixing & Category Mapping**:
   - Fixed the issue where AI scan result was getting stuck on `Logam/Besi`.
   - Added robust `_mapAiCategoryToIndonesian` logic mapping backend AI detection results (`PET Plastic`, `Cardboard`, `Metal/Aluminum`, `Cooking Oil`, etc.) into valid Indonesian waste categories (`Botol Plastik`, `Kardus`, `Logam/Besi`, `Minyak Jelantah`).
   - Integrated this mapping in both `AiVisionPage` and `CreateOrderScreen`.

2. **Manual Category Selection & Custom Price Editing**:
   - Added a manual Dropdown selector for **Jenis Sampah** on `AiVisionPage`, allowing users to correct or manually choose any waste item type anytime.
   - Added an editable text field for **Harga Satuan (Custom)**, enabling users to enter or adjust custom prices per kg/liter manually before proceeding to order.
   - Forwarded selected category, custom price, and photo URL seamlessly to `/create-order`.

3. **Peningkatan Rute Map Interaktif**:
   - Menambahkan banner informasi fungsi **Rute Map** bagi warga.
   - Menyiapkan fallback kolektor terdekat & penanda (marker) interaktif pada peta OpenStreetMap.
   - Menambahkan gambar garis rute (**Polyline**) hijau yang menghubungkan lokasi rumah Warga dengan posisi kolektor yang dipilih.
   - Menambahkan BottomSheet detail kolektor (Rating, Jarak km, Status Online/Offline) dengan tombol aksi cepat *"Chat Kolektor"* dan *"Pesan Penjemputan"*.

4. **Perbaikan & Integrasi Fitur Rating & Ulasan**:
   - Membuat `RatingState` (`lib/core/rating_state.dart`) untuk mengelola status ulasan secara presisten (SharedPreferences) & integrasi API backend `/api/order/:id/review`.
   - Menghubungkan halaman `RatingPage` & `ReviewDetailPage` secara otomatis real-time via `ValueListenableBuilder`.
   - Mengubah status peninjauan: saat warga memberikan ulasan 1-5 bintang & teks ulasan, item secara otomatis berpindah dari tab *"Belum diberikan Ulasan"* ke tab *"Cek Ulasan Anda"*.
   - Menyediakan indikator loading & SnackBar pemberitahuan sukses pengiriman ulasan.

5. **Testing & Verification**:
   - Static analysis `flutter analyze lib/` passed dengan 0 errors.
   - ADB Emulator testing terverifikasi via screenshot: pemberian bintang rating, penulisan ulasan teks, pengiriman ulasan, dan pergantian tab otomatis.

6. **Release APK Builds**:
   - ARM64 (`app-arm64-v8a-release.apk`): 19.7MB (Target ≤ 20MB)
   - ARMv7 (`app-armeabi-v7a-release.apk`): 17.4MB (Target ≤ 18MB)

4. **Jika perlu build ulang APK Flutter**:
   ```bash
   cd /home/user/myapp
   flutter analyze lib/        # Pastikan 0 errors
   flutter build apk --release --split-per-abi
   ```

5. **Jika perlu test di emulator**:
   ```bash
   adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-x86_64-release.apk
   adb -s emulator-5554 shell am start -n com.ecopoint.app/.MainActivity
   ```

---

## 📝 Catatan Tambahan

- APK sudah **mengarah ke server production live** (`https://ecopoint-api.fly.dev`), BUKAN localhost.
- Login screen sudah **pre-fill** credentials admin untuk kemudahan testing (bisa dihapus untuk production).
- Semua fitur admin (lihat detail, reset password, hapus user) sudah **verified working** via ADB screenshot testing.
