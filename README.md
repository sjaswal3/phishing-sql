# Malware URL Infrastructure Analysis (SQL)

SQL-based threat intel analysis of a live malware URL feed, using DuckDB.
Full write-up: [writeup.md](writeup.md)

## Data source

[URLhaus](https://urlhaus.abuse.ch/) recent URLs feed (free abuse.ch feed).
Not included in this repo — see "Reproducing" below.

## Setup

1. Install [DuckDB](https://duckdb.org/) (CLI).
2. Download the feed:
   `https://urlhaus.abuse.ch/downloads/csv_recent/` → save as `urlhaus.csv` in this folder.
3. Run:
   ```
   duckdb phishing.duckdb
   ```
4. Execute the queries in `queries/` in order:
   - `01_load_data.sql` — loads the CSV into a table
   - `02_hosting_patterns.sql` — raw IP vs domain hosting, top abused domains
   - `03_malware_families.sql` — top malware families/tags

## Findings

See [writeup.md](writeup.md) for the full analysis. Summary:

1. **89.6%** of malicious URLs in the dataset are hosted directly on raw IP addresses, not domains.
2. Among the domain-based minority, trusted cloud platforms (Google Drive, Dropbox, GitHub, Discord CDN) and free dynamic-DNS services are disproportionately abused — likely to evade reputation-based blocking.
3. **Mirai** and **Mozi** IoT botnet malware dominate the dataset, targeting ELF binaries on ARM/MIPS architectures via `wget`-based infection chains.

## Notes

- URLs in this repo are never defanged for display beyond what's needed for analysis; the raw CSV is gitignored and never committed.
- Do not click or resolve any URLs from this feed.
