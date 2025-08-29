-- === EDIT THESE TWO LINES ONLY ===
DECLARE START_DATE DATE DEFAULT DATE '2023-07-01';
DECLARE END_DATE   DATE DEFAULT DATE '2025-07-31';
-- =================================

WITH base AS (
  SELECT date, platform, spend, conversions
  FROM `query-470420.8figure_ads.ads_spend`
  WHERE date BETWEEN START_DATE AND END_DATE
),
agg AS (
  SELECT
    platform,
    SUM(spend)       AS spend,
    SUM(conversions) AS conv
  FROM base
  GROUP BY platform
)
SELECT
  platform,
  ROUND(spend, 2)                                       AS spend,
  conv                                                  AS conversions,
  ROUND(SAFE_DIVIDE(spend, NULLIF(conv, 0)), 2)         AS CAC,
  ROUND(SAFE_DIVIDE(conv * 100.0, NULLIF(spend, 0)), 3) AS ROAS,
  START_DATE                                            AS window_start,
  END_DATE                                              AS window_end
FROM agg
ORDER BY ROAS DESC;
