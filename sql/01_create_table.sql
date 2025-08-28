-- scripts/sql/01_create_table.sql
-- This script creates the target table for the n8n workflow to insert into.

CREATE TABLE IF NOT EXISTS ads_spend (
    date DATE,
    platform VARCHAR,
    account VARCHAR,
    campaign VARCHAR,
    country VARCHAR,
    device VARCHAR,
    spend DOUBLE,
    clicks INTEGER,
    impressions INTEGER,
    conversions INTEGER,
    load_date TIMESTAMP,           -- Metadata: When was this row loaded?
    source_file_name VARCHAR       -- Metadata: Where did this data come from?
);