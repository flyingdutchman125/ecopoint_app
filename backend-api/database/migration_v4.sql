-- Migration v4: Add sign-up profile details for warga

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS city VARCHAR(100),
  ADD COLUMN IF NOT EXISTS address TEXT,
  ADD COLUMN IF NOT EXISTS subdistrict VARCHAR(255),
  ADD COLUMN IF NOT EXISTS consent_sorting_anorganic BOOLEAN DEFAULT false;
