# Threat Intel Write-Up: Malware URL Infrastructure Patterns

**Date analyzed:** October 3, 2026
**Dataset:** URLhaus recent URLs feed (abuse.ch), ~16,193 rows after load
**Tooling:** DuckDB (SQL), CSV ingestion

## Scope

URLhaus is a free feed of recently reported malware distribution URLs. This
is not a phishing feed — findings here describe malware *delivery*
infrastructure, not credential-phishing pages. The feed includes some
honeypot-sourced submissions (206 rows tagged `honeypot`), which may not
reflect real victim traffic.

## Finding 1: Most malware is hosted on raw IPs, not domains

| host_type | count | % |
|---|---|---|
| raw_ip | 14,514 | 89.6% |
| domain | 1,679 | 10.4% |

The overwhelming majority of malicious URLs point directly at an IP address
with no domain name at all. This matches the profile of botnet/IoT malware
distribution, where a compromised device or disposable VPS serves a payload
for a short window before being abandoned — registering and maintaining a
domain adds cost and a takedown surface attackers don't need for
short-lived infrastructure.

**Implication:** domain-reputation and domain-blocklist defenses only cover
~10% of this threat surface. IP-reputation feeds and network-layer
detection (unusual outbound connections to residential/hosting IP ranges on
non-standard ports) matter more here than domain filtering.

## Finding 2: The domain-based minority abuses trusted platforms

Top hosts among the domain-based URLs:

| host | count |
|---|---|
| drive.google.com | 112 |
| www.dropbox.com | 77 |
| raw.githubusercontent.com | 58 |
| github.com | 54 |
| b2b.jewmailer.net | 53 |
| dstats.qzz.io | 36 |
| crystalbranchtw.blog | 36 |
| aura.tcplegit.space | 33 |
| *.work.gd (multiple subdomains) | 94 combined |
| cdn.discordapp.com | 18 |
| *.workers.dev | 19 |

Two distinct patterns here:

- **Trusted-platform abuse:** Google Drive, Dropbox, GitHub, and Discord's
  CDN together account for over 300 URLs. These are services most
  organizations can't blanket-block without breaking legitimate business
  use, which is exactly why attackers use them to host payloads.
- **Disposable free-subdomain services:** `.work.gd`, `.qzz.io`,
  `.tcplegit.space`, and similar free dynamic-DNS-style domains are
  registered and burned quickly. A few of these (e.g. adult-content
  subdomains under the same free services) appear to be unrelated spam
  riding the same infrastructure rather than malware droppers — domain
  content was not manually verified, only hosting patterns were analyzed.

**Implication:** detection should focus on anomalous *behavior* on trusted
platforms (unexpected file types, unusual download volume/pattern) rather
than blocking the platforms themselves.

## Finding 3: Mirai and Mozi dominate — this is IoT botnet activity, not endpoint malware

Top malware families/tags (tags split and recounted individually, since
rows often carry multiple co-occurring tags):

| family | count |
|---|---|
| mirai | 6,086 |
| Mozi | 5,619 |
| elf | 5,308 |
| ua-wget | 2,602 |
| 32-bit | 2,565 |
| mips | 1,627 |
| arm | 940 |
| botnetdomain | 366 |
| RemcosRAT | 237 |

Mirai and Mozi are both well-known IoT botnet malware families. The
accompanying tags — `elf` (Linux executable format), `mips`/`arm`
(embedded device architectures), and `ua-wget` (payload typically pulled
via a `wget` command) — all point to the same infection chain: an exposed
or weakly-credentialed IoT device (router, camera, DVR) is remotely
exploited and made to fetch and execute a binary.

**Implication:** this dataset is dominated by mass IoT exploitation, not
targeted endpoint compromise. Relevant SOC priorities: network
segmentation for IoT/embedded devices, egress filtering to block outbound
`wget`/`curl` calls to unknown IPs from devices that shouldn't be making
them, and monitoring for default-credential exploitation attempts.

## Limitations

- Single-source snapshot (URLhaus only) at one point in time — not
  representative of all malware distribution activity.
- Includes honeypot-sourced submissions, which may skew toward
  opportunistic/automated attacks rather than targeted campaigns.
- Domain content was not manually verified; classifications are based on
  hosting pattern and tag metadata only.
- No ASN/hosting-provider enrichment was performed in this pass.

## What a SOC should do with this

- Prioritize IP-reputation and network-behavior detection over
  domain-blocklist-only approaches, given 89.6% of URLs skip domains
  entirely.
- Alert on anomalous download behavior from trusted cloud storage/CDN
  domains rather than blocking them outright.
- Segment and monitor IoT/embedded devices separately from standard
  endpoints; this dataset shows they are the dominant target.
