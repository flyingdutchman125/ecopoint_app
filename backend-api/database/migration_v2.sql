-- Migration v2: status_history, fungsi earnings, redeem eco_points
-- Jalankan di Supabase SQL Editor

-- 1. Tambah kolom status_history ke orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status_history JSONB DEFAULT '[]'::jsonb;

-- 2. Fungsi untuk redeem eco_points ke wallet_balance
CREATE OR REPLACE FUNCTION redeem_eco_points(
  p_user_id UUID,
  p_points INTEGER DEFAULT 1000
)
RETURNS JSON AS $$
DECLARE
  current_points INTEGER;
  bonus NUMERIC;
  result JSON;
BEGIN
  SELECT eco_points INTO current_points FROM users WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;
  IF current_points < p_points THEN RAISE EXCEPTION 'Insufficient eco points. Available: %, Required: %', current_points, p_points; END IF;

  bonus := (p_points / 1000) * 5000;

  UPDATE users SET eco_points = eco_points - p_points, wallet_balance = wallet_balance + bonus WHERE id = p_user_id;

  INSERT INTO transactions (order_id, sender_id, receiver_id, amount, type, description)
  VALUES (NULL, p_user_id, p_user_id, bonus, 'redeem', CONCAT('Redeemed ', p_points, ' eco points for Rp ', bonus));

  result := json_build_object('success', true, 'points_redeemed', p_points, 'bonus_received', bonus);
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
