DECLARE end_date   DATE DEFAULT (SELECT MAX(date) FROM `query-470420.8figure_ads.ads_spend`);
DECLARE start_curr DATE DEFAULT DATE_SUB(end_date, INTERVAL 29 DAY);
DECLARE end_prev   DATE DEFAULT DATE_SUB(start_curr, INTERVAL 1 DAY);
DECLARE start_prev DATE DEFAULT DATE_SUB(start_curr, INTERVAL 30 DAY);

WITH base AS (
  SELECT date, platform, spend, conversions
  FROM `query-470420.8figure_ads.ads_spend`
  WHERE date BETWEEN start_prev AND end_date
),
agg AS (
  SELECT 'current' AS period, platform, SUM(spend) AS spend, SUM(conversions) AS conv
  FROM base WHERE date BETWEEN start_curr AND end_date
  GROUP BY platform
  UNION ALL
  SELECT 'prior', platform, SUM(spend), SUM(conversions)
  FROM base WHERE date BETWEEN start_prev AND end_prev
  GROUP BY platform
),
final AS (
  SELECT
    platform,
    period,
    spend,
    conv AS conversions,
    SAFE_DIVIDE(spend, NULLIF(conv,0))                 AS CAC,
    SAFE_DIVIDE(conv * 100.0, NULLIF(spend,0))         AS ROAS
  FROM agg
)
SELECT
  f.platform,

  -- absolute values
  ROUND(curr.spend, 2)         AS spend_curr,
  ROUND(prior.spend, 2)        AS spend_prev,
  curr.conversions             AS conv_curr,
  prior.conversions            AS conv_prev,
  ROUND(curr.CAC, 2)           AS cac_curr,
  ROUND(prior.CAC, 2)          AS cac_prev,
  ROUND(curr.ROAS, 3)          AS roas_curr,
  ROUND(prior.ROAS, 3)         AS roas_prev,

  -- deltas (% change)
  ROUND(SAFE_DIVIDE(curr.spend - prior.spend, NULLIF(prior.spend,0)), 4)        AS spend_delta_pct,
  ROUND(SAFE_DIVIDE(curr.conversions - prior.conversions, NULLIF(prior.conversions,0)), 4) AS conv_delta_pct,
  ROUND(SAFE_DIVIDE(curr.CAC - prior.CAC, NULLIF(prior.CAC,0)), 4)              AS cac_delta_pct,
  ROUND(SAFE_DIVIDE(curr.ROAS - prior.ROAS, NULLIF(prior.ROAS,0)), 4)           AS roas_delta_pct
FROM final f
JOIN final curr  ON curr.platform = f.platform AND curr.period  = 'current'
JOIN final prior ON prior.platform= f.platform AND prior.period = 'prior'
WHERE f.period = 'current'
ORDER BY roas_delta_pct DESC;
