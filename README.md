# 8 Figure Agency – Data Engineer Challenge

## Overview
This project implements an end-to-end pipeline for digital ads data:
1. **Ingestion** from CSV into **BigQuery** (via n8n workflow).
2. **Metadata tracking** (`load_date`, `source_file_name`) for provenance.
3. **KPI modeling**: CAC and ROAS, with comparisons of last 30 days vs prior 30 days.
4. **Analyst access**: ready-to-run SQL scripts, with simple parameter editing for any date window.

---

## 1. Ingestion Workflow
- The ingestion is defined in **`workflows/ingestion_bq.json`**.  
- Logic:
  - Fetch a CSV file from Google Drive.
  - Transform with Pandas (normalize `date`, add `load_date` and `source_file_name`).
  - Add a stable `insertId` to prevent duplicates on re-runs.
  - Insert into BigQuery table:  
    ```
    project: query-470420
    dataset: 8figure_ads
    table:   ads_spend
    ```

### To run:
1. Import `workflows/ingestion_bq.json` into n8n.
2. Configure BigQuery credentials (service account).
3. Execute workflow — rows stream into `ads_spend`.

---

## 2. Table Schema
Target table `8figure_ads.ads_spend` contains:
- `date` (DATE)  
- `platform`, `account`, `campaign`, `country`, `device` (STRING)  
- `spend` (FLOAT)  
- `clicks`, `impressions`, `conversions` (INTEGER)  
- `load_date` (TIMESTAMP)  
- `source_file_name` (STRING)  
- `insertId` (STRING, used for de-duplication)

---

## 3. KPI SQL Scripts
Located under `sql/`.

- **`kpi_30_vs_prev.sql`**  
  Compare last 30 days vs prior 30 days. Returns spend, conversions, CAC, ROAS with % deltas.  

- **`kpi_30_vs_prev_by_platform.sql`**  
  Same as above, but grouped per platform.  

- **`kpi_parametrized_literals_by_platform.sql`**  🚨 **Main Script**  
  This is the most important script for analysts. It computes CAC & ROAS per platform for **any chosen date window**.  
  - To use it, simply edit the first two lines in the SQL to set the desired window:
    ```sql
    DECLARE START_DATE DATE DEFAULT DATE '2025-07-01';
    DECLARE END_DATE   DATE DEFAULT DATE '2025-07-31';
    ```
  - No BigQuery parameters or UI configuration are required — just change the dates in the code and run.  
  - This makes it the most convenient and reliable script for real analyst use.

---

## 4. Provenance & Persistence
- Every row has `load_date` (ingestion timestamp) and `source_file_name` (origin file).  
- Data persists across refreshes. Duplicate rows are avoided using `insertId`.

---

## 5. Screenshots
See the `screenshots/` folder for:
- n8n workflow node logic.
- BigQuery metada, persistance, loaded date min.
- KPI query results in RESULT

---

## 6. How to Use
1. **Ingest Data**: Import and execute the workflow JSON in n8n.  
2. **Run Analysis**: Copy any SQL from `sql/` into BigQuery Console.  
3. **Adjust Windows**: For `kpi_parametrized_literals_by_platform.sql`, edit the `DECLARE START_DATE` and `DECLARE END_DATE` lines.  
4. **Interpret Results**: Focus on CAC and ROAS values per platform to evaluate campaign efficiency.  

---

## Key Reminder
While multiple KPI scripts are provided, **`kpi_parametrized_literals_by_platform.sql`** is the **primary script reviewers and analysts should use**.  
It is self-contained, requires no extra setup, and provides the clearest view of CAC and ROAS performance across platforms.
