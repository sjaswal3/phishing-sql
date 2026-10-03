-- Load URLhaus recent URLs CSV into DuckDB
-- Source: https://urlhaus.abuse.ch/downloads/csv_recent/
-- The file has a 9-line comment header and quoted fields, hence the options below.

CREATE TABLE urlhaus AS
SELECT * FROM read_csv('urlhaus.csv', comment='#', header=false, all_varchar=true,
  quote='"', escape='"', delim=',', ignore_errors=true,
  columns={'id':'VARCHAR','dateadded':'VARCHAR','url':'VARCHAR','url_status':'VARCHAR',
  'last_online':'VARCHAR','threat':'VARCHAR','tags':'VARCHAR','urlhaus_link':'VARCHAR','reporter':'VARCHAR'});

-- Sanity check row count
SELECT COUNT(*) FROM urlhaus;
