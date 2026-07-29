-- Migration v5: Enhance dashboard support with carbon reduction, route tracking, live prices, and EcoBook

-- 1. Add carbon reduction and status history to orders
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS carbon_reduction NUMERIC(10, 2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS status_history JSONB DEFAULT '[]'::jsonb;

-- 2. Add price history tracking for charting price movement over time
CREATE TABLE IF NOT EXISTS catalog_price_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_name VARCHAR(255) NOT NULL,
  price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  unit VARCHAR(50) DEFAULT 'kg',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_catalog_price_history_item_name ON catalog_price_history(item_name);

-- 3. Add EcoBook resource library for warga dashboard
CREATE TABLE IF NOT EXISTS eco_books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  summary TEXT,
  content TEXT,
  category VARCHAR(100),
  image_url TEXT,
  url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_eco_books_category ON eco_books(category);

-- 4. Seed initial EcoBook content if table is empty
INSERT INTO eco_books (title, summary, content, category, url)
SELECT 'Panduan Pemilahan Sampah Rumah Tangga', 'Langkah-langkah mudah memilah sampah anorganik dari rumah.', 'Pelajari cara memisahkan sampah organik, plastik, logam, dan kertas agar dapat didaur ulang dengan benar. Mulai dari ruang tamu hingga dapur.', 'Pemilahan Sampah', 'https://example.com/eco-book/1'
WHERE NOT EXISTS (SELECT 1 FROM eco_books);

INSERT INTO eco_books (title, summary, content, category, url)
SELECT 'Cara Menabung Eco Points', 'Strategi mengumpulkan Eco Points untuk ditukar kembali.', 'Dapatkan poin tambahan dengan menyerahkan sampah berkualitas, mengikuti program komunitas, dan menyelesaikan pesanan secara teratur.', 'Eco Points', 'https://example.com/eco-book/2'
WHERE NOT EXISTS (SELECT 1 FROM eco_books WHERE title = 'Cara Menabung Eco Points');

INSERT INTO eco_books (title, summary, content, category, url)
SELECT 'Manfaat Recycle bagi Lingkungan', 'Mengapa mendaur ulang membantu mengurangi emisi karbon.', 'Daur ulang mengurangi kebutuhan produksi material baru, menghemat energi, dan mengurangi sampah di TPA. Setiap kilogram sampah yang didaur ulang membantu bumi.', 'Lingkungan', 'https://example.com/eco-book/3'
WHERE NOT EXISTS (SELECT 1 FROM eco_books WHERE title = 'Manfaat Recycle bagi Lingkungan');
