CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TYPE user_role AS ENUM ('user', 'collector', 'admin');
CREATE TYPE order_status AS ENUM ('pending', 'accepted', 'en_route', 'completed', 'cancelled');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role user_role NOT NULL DEFAULT 'user',
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  wallet_balance NUMERIC(10, 2) DEFAULT 0 CHECK (wallet_balance >= 0),
  eco_points INTEGER DEFAULT 0 CHECK (eco_points >= 0),
  location GEOGRAPHY(Point, 4326),
  is_online BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_location ON users USING GIST(location);
CREATE INDEX idx_users_is_online ON users(is_online) WHERE role = 'collector';

CREATE TABLE catalog_prices (
  id SERIAL PRIMARY KEY,
  item_name VARCHAR(255) NOT NULL UNIQUE,
  current_price NUMERIC(10, 2) NOT NULL CHECK (current_price >= 0),
  unit VARCHAR(50) DEFAULT 'kg',
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_catalog_prices_item_name ON catalog_prices(item_name);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  collector_id UUID REFERENCES users(id) ON DELETE SET NULL,
  status order_status NOT NULL DEFAULT 'pending',
  item_type VARCHAR(255) NOT NULL,
  est_weight NUMERIC(10, 2),
  actual_weight NUMERIC(10, 2),
  photo_url TEXT,
  pickup_location GEOGRAPHY(Point, 4326) NOT NULL,
  pickup_address TEXT,
  notes TEXT,
  total_amount NUMERIC(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_collector_id ON orders(collector_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_pickup_location ON orders USING GIST(pickup_location);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
  sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
  receiver_id UUID REFERENCES users(id) ON DELETE SET NULL,
  amount NUMERIC(10, 2) NOT NULL,
  type VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_transactions_order_id ON transactions(order_id);
CREATE INDEX idx_transactions_sender_id ON transactions(sender_id);
CREATE INDEX idx_transactions_receiver_id ON transactions(receiver_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at DESC);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION transfer_dummy_balance(
  sender_id UUID,
  receiver_id UUID,
  amount NUMERIC,
  order_id UUID
)
RETURNS JSON AS $$
DECLARE
  sender_balance NUMERIC;
  result JSON;
BEGIN
  IF amount <= 0 THEN
    RAISE EXCEPTION 'Amount must be greater than zero';
  END IF;

  SELECT wallet_balance INTO sender_balance
  FROM users
  WHERE id = sender_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Sender not found';
  END IF;

  IF sender_balance < amount THEN
    RAISE EXCEPTION 'Insufficient balance. Available: %, Required: %', sender_balance, amount;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM users WHERE id = receiver_id) THEN
    RAISE EXCEPTION 'Receiver not found';
  END IF;

  UPDATE users
  SET wallet_balance = wallet_balance - amount
  WHERE id = sender_id;

  UPDATE users
  SET wallet_balance = wallet_balance + amount
  WHERE id = receiver_id;

  INSERT INTO transactions (order_id, sender_id, receiver_id, amount, type, description)
  VALUES (order_id, sender_id, receiver_id, amount, 'payment', 'Order payment from collector to user');

  result := json_build_object(
    'success', true,
    'amount', amount,
    'sender_id', sender_id,
    'receiver_id', receiver_id,
    'order_id', order_id
  );

  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_nearby_orders(
  collector_lng NUMERIC,
  collector_lat NUMERIC,
  radius_meters NUMERIC DEFAULT 5000
)
RETURNS TABLE (
  order_id UUID,
  user_id UUID,
  item_type VARCHAR,
  est_weight NUMERIC,
  pickup_address TEXT,
  distance_meters NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    o.id AS order_id,
    o.user_id,
    o.item_type,
    o.est_weight,
    o.pickup_address,
    ST_Distance(
      o.pickup_location,
      ST_SetSRID(ST_MakePoint(collector_lng, collector_lat), 4326)::geography
    ) AS distance_meters,
    o.created_at
  FROM orders o
  WHERE o.status = 'pending'
    AND ST_DWithin(
      o.pickup_location,
      ST_SetSRID(ST_MakePoint(collector_lng, collector_lat), 4326)::geography,
      radius_meters
    )
  ORDER BY distance_meters ASC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_distance(
  lng1 NUMERIC,
  lat1 NUMERIC,
  lng2 NUMERIC,
  lat2 NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
  RETURN ST_Distance(
    ST_SetSRID(ST_MakePoint(lng1, lat1), 4326)::geography,
    ST_SetSRID(ST_MakePoint(lng2, lat2), 4326)::geography
  );
END;
$$ LANGUAGE plpgsql;

INSERT INTO catalog_prices (item_name, current_price, unit) VALUES
  ('PET Plastic', 3500, 'kg'),
  ('Cardboard', 2000, 'kg'),
  ('Metal', 5000, 'kg'),
  ('Cooking Oil', 1500, 'liter')
ON CONFLICT (item_name) DO NOTHING;
