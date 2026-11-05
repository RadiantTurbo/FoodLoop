PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS sales_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id TEXT NOT NULL,
  cafeteria_id TEXT NOT NULL,
  sold_date TEXT NOT NULL,
  meal_slot TEXT NOT NULL,
  prepared_qty INTEGER NOT NULL,
  sold_qty INTEGER NOT NULL,
  stockout INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'manual',
  CHECK(prepared_qty >= 0),
  CHECK(sold_qty >= 0),
  CHECK(sold_qty <= prepared_qty)
);

CREATE TABLE IF NOT EXISTS local_calendar (
  date TEXT PRIMARY KEY,
  festival_name TEXT,
  is_festival INTEGER NOT NULL DEFAULT 0,
  is_holiday INTEGER NOT NULL DEFAULT 0,
  is_exam_period INTEGER NOT NULL DEFAULT 0,
  is_semester_break INTEGER NOT NULL DEFAULT 0,
  hostel_occupancy REAL NOT NULL DEFAULT 1.0,
  campus_event_multiplier REAL NOT NULL DEFAULT 1.0
);

CREATE TABLE IF NOT EXISTS local_conditions (
  date TEXT NOT NULL,
  meal_slot TEXT NOT NULL,
  rain_level TEXT NOT NULL DEFAULT 'none',
  manual_footfall INTEGER,
  notes TEXT,
  PRIMARY KEY(date, meal_slot)
);

CREATE TABLE IF NOT EXISTS inventory_batches (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL,
  cafeteria_id TEXT NOT NULL,
  prepared_qty INTEGER NOT NULL,
  available_qty INTEGER NOT NULL,
  prepared_at TEXT NOT NULL,
  handling_deadline TEXT NOT NULL,
  safety_verified INTEGER NOT NULL DEFAULT 0,
  metadata_verified INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending'
);

CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  student_local_id TEXT NOT NULL,
  batch_id TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'reserved',
  created_at TEXT NOT NULL,
  collected_at TEXT,
  FOREIGN KEY(batch_id) REFERENCES inventory_batches(id)
);

CREATE TABLE IF NOT EXISTS sensor_readings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sensor_id TEXT NOT NULL,
  metric TEXT NOT NULL,
  sequence_id TEXT NOT NULL UNIQUE,
  value REAL,
  recorded_at TEXT NOT NULL,
  received_at TEXT NOT NULL,
  quality_status TEXT NOT NULL,
  quality_note TEXT
);

CREATE TABLE IF NOT EXISTS pending_sync (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending'
);
