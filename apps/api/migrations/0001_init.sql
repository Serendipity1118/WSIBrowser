-- WSI Browser backend schema v1 (要件定義 F-13)
CREATE TABLE IF NOT EXISTS plugin_policies (
  plugin_id  TEXT NOT NULL,
  key        TEXT NOT NULL,
  value      TEXT NOT NULL,            -- JSON
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (plugin_id, key)
);

CREATE TABLE IF NOT EXISTS plugin_releases (
  plugin_id   TEXT NOT NULL,
  version     TEXT NOT NULL,
  zip_url     TEXT NOT NULL,           -- absolute URL served by this worker (or external https)
  r2_key      TEXT,                    -- object key in the wsi-plugins bucket, when hosted here
  notes       TEXT,
  released_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (plugin_id, version)
);
CREATE INDEX IF NOT EXISTS idx_plugin_releases_released ON plugin_releases (plugin_id, released_at DESC);

CREATE TABLE IF NOT EXISTS feedback (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  plugin_id  TEXT NOT NULL,
  device     TEXT,                     -- JSON: { os, osVersion, appVersion, model } (no identifiers)
  body       TEXT NOT NULL,
  ip_hash    TEXT,                     -- sha256(ip) for rate limiting only
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX IF NOT EXISTS idx_feedback_ip_created ON feedback (ip_hash, created_at);
