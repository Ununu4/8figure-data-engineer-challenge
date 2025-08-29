-- A. Sample recent rows showing the metadata fields populated
SELECT date, platform, account, campaign, load_date, source_file_name
FROM `query-470420.8figure_ads.ads_spend`
ORDER BY load_date DESC
LIMIT 10;
