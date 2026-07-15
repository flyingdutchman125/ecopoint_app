# EcoPoint API

Backend API untuk aplikasi waste collection on-demand. Express + Supabase.

## Fitur

- **Auth JWT** — Login/register via Supabase Auth (3 role: user, collector, admin)
- **AI Vision** — Deteksi jenis sampah dari foto (OpenAI SDK + custom baseURL)
- **Upload Foto** — Upload ke Supabase Storage (S3-compatible), dapet public URL
- **Pagination** — Semua list endpoint pake `page` + `limit`
- **Nearby Orders** — Cari order terdekat pake Haversine (gak perlu PostGIS RPC)
- **Routing** — Rute dari collector ke pickup via OSRM
- **Wallet** — Dompet internal, transfer antar user, redeem eco points
- **Order Tracking** — Riwayat status order (`status_history` JSONB)
- **Scraper** — Ambil harga terbaru dari banksampahindonesia.com
- **Swagger UI** — Dokumentasi API di `/api-docs`

## Tech Stack

- **Runtime**: Node.js 22
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL + PostGIS)
- **Storage**: Supabase Storage (S3-compatible)
- **AI Vision**: OpenAI SDK (xstresser endpoint)
- **Routing**: OSRM (router.project-osrm.org)
- **Scraper**: Cheerio

## Instalasi

```bash
npm install
```

## Environment Variables (`.env`)

```env
PORT=3000

SUPABASE_URL=https://ornflvmefieggnezxeza.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

OPENAI_API_KEY=your-api-key
OPENAI_BASE_URL=https://xstresser.eu.org/v1
OPENAI_MODEL=gemini/gemini-3.1-flash-lite-preview

S3_ENDPOINT=https://ornflvmefieggnezxeza.storage.supabase.co/storage/v1/s3
S3_REGION=ap-southeast-2
S3_ACCESS_KEY_ID=your-access-key
S3_SECRET_ACCESS_KEY=your-secret-key
S3_BUCKET=ecopoint
```

## Database Setup

Jalankan di Supabase SQL Editor:

1. **init.sql** — tabel & fungsi dasar:
```bash
cat database/init.sql
```

2. **migration_v2.sql** — status_history + redeem eco_points:
```bash
cat database/migration_v2.sql
```

## Menjalankan Server

```bash
npm run dev    # development (--watch)
npm start      # production
```

Health check: `GET http://localhost:3000/health`

## API Endpoints

### Publik (tanpa auth)

| Method | Path | Deskripsi |
|--------|------|-----------|
| POST | `/api/login` | Login (email, password) → JWT |
| POST | `/api/register` | Register (email, password, name, role) |
| POST | `/api/analyze-image` | Deteksi jenis sampah dari URL foto |

### User (`role: user`)

| Method | Path | Deskripsi |
|--------|------|-----------|
| POST | `/api/order` | Buat order jemput sampah |
| GET | `/api/orders?page=&limit=&status=` | Daftar order user (pagination) |
| GET | `/api/order/:id` | Detail order |
| PUT | `/api/order/:id/cancel` | Batalkan order (kalo masih pending) |
| GET | `/api/prices` | Daftar harga sampah per kg |
| GET | `/api/wallet` | Saldo wallet + eco points |
| GET | `/api/transactions?page=&limit=` | Riwayat transaksi (pagination) |
| POST | `/api/redeem` | Tukar eco points → saldo (min 1000, bonus Rp5.000/1000pts) |
| POST | `/api/upload` | Upload foto (multipart field: `photo`) → public URL |

### Collector (`role: collector`)

| Method | Path | Deskripsi |
|--------|------|-----------|
| PUT | `/api/location` | Update posisi GPS + status online |
| GET | `/api/nearby-orders?radius=5000` | Cari order pending terdekat (Haversine) |
| POST | `/api/order/:id/accept` | Ambil order |
| PUT | `/api/order/:id/en-route` | Mulai perjalanan ke pickup |
| GET | `/api/order/:id/route` | Rute dari posisi saat ini ke pickup (OSRM) |
| POST | `/api/order/:id/pay` | Selesaikan order + transfer pembayaran |
| GET | `/api/collector/orders?page=&limit=&status=` | Daftar order collector (pagination) |
| GET | `/api/collector/earnings?period=all\|day\|week\|month` | Pendapatan collector |
| POST | `/api/upload` | Upload foto (multipart field: `photo`) |

### Admin (`role: admin`)

| Method | Path | Deskripsi |
|--------|------|-----------|
| GET | `/api/statistics` | Statistik platform |
| GET | `/api/admin/users?page=&limit=&role=` | Daftar semua user (pagination) |
| GET | `/api/admin/orders?page=&limit=&status=` | Daftar semua order (pagination) |
| POST | `/api/scrape-prices` | Scrape harga dari banksampahindonesia.com |
| POST | `/api/price` | Update harga manual |
| POST | `/api/admin/user/balance` | Tambah/kurang saldo user |
| POST | `/api/upload` | Upload foto (multipart field: `photo`) |

## Pagination

Semua list endpoint return:

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "total_pages": 5
  }
}
```

Query params: `?page=1&limit=10` (default page=1, limit=20, max limit=100)

## Order Status Flow

```
pending → accepted → en_route → completed
    ↓
 cancelled
```

Setiap perubahan status otomatis dicatat ke `status_history` (kolom JSONB di tabel orders).

## Upload Foto

1. `POST /api/upload` (multipart, field `photo`, max 10MB)
2. Response: `{ "success": true, "data": { "url": "https://...public-url..." } }`
3. URL bisa dipake di `POST /api/order` (field `photo_url`)

## Redeem Eco Points

`POST /api/redeem`
```json
{ "points": 1000 }
```
- Minimal 1000 points, kelipatan 1000
- Bonus: 1000 points = Rp 5.000 ke wallet

## Swagger UI

Buka `http://localhost:3000/api-docs/` untuk dokumentasi interaktif.

## Struktur Project

```
src/
├── config/          - Koneksi Supabase
├── controllers/     - Request handlers
├── middleware/       - Auth + role check
├── routes/          - Route definitions (flat, 1 file)
├── services/        - Business logic (AI, scraper, OSRM, wallet, upload, tracking)
├── utils/           - Pagination helper
└── server.js        - Entry point
database/
├── init.sql         - Schema awal
└── migration_v2.sql - Migrasi status_history + redeem
```

## Catatan

- AI Vision butuh API key valid (current key expired — 401)
- Collector perlu saldo cukup buat bayar order (current balance: Rp230)
- PostGIS RPC `get_nearby_orders` gak dipake — pake Haversine JS
- Gak ada WebSocket — tracking real-time dari frontend aja

### Mobile App Features (Semua Role)
| Method | Path | Deskripsi |
|--------|------|-----------|
| POST | `/api/forgot-password` | Lupa password |
| PUT | `/api/profile` | Update profile (name, phone, avatar_url) |
| GET | `/api/addresses` | Daftar alamat user (Saved Addresses) |
| POST | `/api/addresses` | Tambah alamat baru |
| DELETE | `/api/addresses/:id` | Hapus alamat |
| POST | `/api/wallet/topup` | Top Up saldo |
| POST | `/api/wallet/withdraw` | Tarik tunai saldo |
| POST | `/api/order/:id/messages` | Kirim chat di dalam order |
| GET | `/api/order/:id/messages` | Lihat riwayat chat order |
| POST | `/api/order/:id/review` | Kasih rating & review ke kolektor |
