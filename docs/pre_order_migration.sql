-- =============================================================
-- GTEC CANTEEN — PRE-ORDER TOKEN SYSTEM MIGRATION
-- Run once against your PostgreSQL database.
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. EXTEND users TABLE
-- ─────────────────────────────────────────────────────────────
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS department VARCHAR(10),
  ADD COLUMN IF NOT EXISTS year       VARCHAR(10),
  ADD COLUMN IF NOT EXISTS section    VARCHAR(2);

-- Drop constraints if they already exist (idempotent re-run)
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_department;
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_year;
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_section;

ALTER TABLE users
  ADD CONSTRAINT chk_department CHECK (
    department IS NULL OR department IN ('CSE','ECE','EEE','MECH','CIVIL','IT','AI&DS','BME','CHEM')
  ),
  ADD CONSTRAINT chk_year CHECK (
    year IS NULL OR year IN ('1st Year','2nd Year','3rd Year','4th Year')
  ),
  ADD CONSTRAINT chk_section CHECK (
    section IS NULL OR section IN ('A','B','C','D')
  );

-- ─────────────────────────────────────────────────────────────
-- 2. EXTEND menu_items TABLE
-- ─────────────────────────────────────────────────────────────
ALTER TABLE menu_items
  ADD COLUMN IF NOT EXISTS pre_order_limit INT NOT NULL DEFAULT 50;

-- ─────────────────────────────────────────────────────────────
-- 3. CREATE meal_slots TABLE
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS meal_slots (
  id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_name            VARCHAR(20)  NOT NULL,
  start_time           TIME         NOT NULL,
  end_time             TIME         NOT NULL,
  current_token_number INT          NOT NULL DEFAULT 0,
  now_serving          INT          NOT NULL DEFAULT 0,
  is_active            BOOLEAN      NOT NULL DEFAULT TRUE,
  date                 DATE         NOT NULL DEFAULT CURRENT_DATE,
  created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  UNIQUE (slot_name, date)
);

-- ─────────────────────────────────────────────────────────────
-- 4. CREATE pre_order_bookings TABLE
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pre_order_bookings (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_item_id    UUID        NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
  meal_slot_id    UUID        NOT NULL REFERENCES meal_slots(id) ON DELETE CASCADE,
  booked_quantity INT         NOT NULL DEFAULT 0,
  date            DATE        NOT NULL DEFAULT CURRENT_DATE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (menu_item_id, meal_slot_id, date)
);

-- ─────────────────────────────────────────────────────────────
-- 5. EXTEND orders TABLE
-- ─────────────────────────────────────────────────────────────
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS token_number  INT,
  ADD COLUMN IF NOT EXISTS meal_slot_id  UUID REFERENCES meal_slots(id),
  ADD COLUMN IF NOT EXISTS department    VARCHAR(10),
  ADD COLUMN IF NOT EXISTS year          VARCHAR(10),
  ADD COLUMN IF NOT EXISTS section       VARCHAR(2),
  ADD COLUMN IF NOT EXISTS total_items   INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pickup_time   VARCHAR(10),
  ADD COLUMN IF NOT EXISTS order_type    VARCHAR(20) NOT NULL DEFAULT 'regular';

-- ─────────────────────────────────────────────────────────────
-- 6. CREATE token_audit TABLE
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS token_audit (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id     UUID        NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  token_start  INT         NOT NULL,
  token_end    INT         NOT NULL,
  meal_slot_id UUID        NOT NULL REFERENCES meal_slots(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────
-- 7. SEED — today's meal slots (safe ON CONFLICT)
-- ─────────────────────────────────────────────────────────────
INSERT INTO meal_slots (slot_name, start_time, end_time, date)
VALUES
  ('breakfast', '07:00:00', '10:00:00', CURRENT_DATE),
  ('lunch',     '12:00:00', '14:00:00', CURRENT_DATE),
  ('snacks',    '16:00:00', '18:00:00', CURRENT_DATE),
  ('dinner',    '19:00:00', '21:00:00', CURRENT_DATE)
ON CONFLICT (slot_name, date) DO NOTHING;

-- ─────────────────────────────────────────────────────────────
-- 8. HELPFUL INDEXES
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_meal_slots_date        ON meal_slots (date);
CREATE INDEX IF NOT EXISTS idx_meal_slots_slot_date   ON meal_slots (slot_name, date);
CREATE INDEX IF NOT EXISTS idx_pre_order_bookings_slot ON pre_order_bookings (meal_slot_id, date);
CREATE INDEX IF NOT EXISTS idx_orders_meal_slot        ON orders (meal_slot_id);
CREATE INDEX IF NOT EXISTS idx_orders_token_number     ON orders (token_number);
CREATE INDEX IF NOT EXISTS idx_token_audit_order       ON token_audit (order_id);
CREATE INDEX IF NOT EXISTS idx_token_audit_slot        ON token_audit (meal_slot_id);
