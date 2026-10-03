-- Finding 1: Raw IP vs domain-based hosting
SELECT
  CASE WHEN regexp_matches(url, '^https?://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
       THEN 'raw_ip' ELSE 'domain' END AS host_type,
  COUNT(*) AS n
FROM urlhaus
GROUP BY host_type;

-- Finding 2: Top domains among the domain-based subset
-- (surfaces abuse of trusted cloud platforms + free dynamic-DNS services)
SELECT regexp_extract(url, '^https?://([a-zA-Z0-9.-]+)[:/]', 1) AS host, COUNT(*) AS n
FROM urlhaus
WHERE NOT regexp_matches(url, '^https?://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
GROUP BY host
ORDER BY n DESC
LIMIT 15;
