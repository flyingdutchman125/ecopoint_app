# EcoPoint

Aplikasi Manajemen Sampah berbasis Ekonomi Sirkular. Memiliki fitur Warga (menyetorkan sampah untuk ditukar menjadi poin/uang) dan Mitra Pengepul (menjemput sampah dan memverifikasi timbangan).

Project ini merupakan struktur **Monorepo**:
- **Frontend:** Flutter (Mobile App)
- **Backend:** Node.js (Express, MySQL)

---

## Persiapan (Prerequisites)

Sebelum menjalankan project ini, pastikan kamu telah menginstal perangkat lunak berikut:
1. **Flutter SDK** (versi terbaru).
2. **Node.js** (v14 atau lebih baru).
3. **MySQL Server** (XAMPP / MySQL standalone).
4. Emulator Android / Device Fisik (Pastikan terhubung di satu jaringan WiFi yang sama dengan komputer server).

---

## Cara Instalasi & Menjalankan (Installation & Setup)

### 1. Konfigurasi Backend (Node.js)

1. Masuk ke folder backend:
   ```bash
   cd backend
   ```
2. Instal dependensi NPM:
   ```bash
   npm install
   ```
3. Buat database MySQL dengan nama **`ecopoint`**. (Skema tabel `users` akan terbuat otomatis secara konsep, namun pastikan struktur SQL sudah sesuai).
4. Buat file `.env` di dalam folder `backend/` dan isi konfigurasi koneksi database:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=jacki123 # Sesuaikan dengan password MySQL kamu
   DB_NAME=ecopoint
   JWT_SECRET=supersecretkey
   PORT=3000
   ```
5. Buat folder untuk menampung file upload KTP:
   ```bash
   mkdir uploads
   ```
6. Jalankan server:
   ```bash
   node server.js
   ```

*(Opsional: Jalankan `node seedAdmin.js` di folder backend untuk membuat akun admin dummy: `admin@ecopoint.com` / `admin123`).*

### 2. Konfigurasi Frontend (Flutter)

1. Buka tab terminal baru dan kembali ke root folder `ecopoint`.
2. Download dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. **PENTING:** Karena berjalan di jaringan lokal, buka file `lib/controllers/auth_controller.dart` serta file controller lainnya dan ubah IP lokal pada variabel `baseUrl` sesuai dengan IP komputer/laptop server kamu (cek menggunakan perintah `ipconfig` di Windows atau `ip a` di Linux):
   ```dart
   final String baseUrl = 'http://192.168.1.182:3000/api/auth';
   ```
4. Jalankan aplikasi di Emulator atau Device Fisik:
   ```bash
   flutter run
   ```

---

## Role Akses (Features)
- **Admin**: Verifikasi pendaftaran mitra pengepul, manajemen data (Login default: `admin@ecopoint.com`).
- **User (Warga)**: Request penjemputan sampah, melihat history transaksi, menukarkan poin (Redeem), cek jejak karbon.
- **Collector (Mitra Pengepul)**: Mendaftar dengan data kendaraan dan KTP, menunggu verifikasi Admin, dan menerima order dari Warga.
