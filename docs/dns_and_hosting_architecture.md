# DNS & Hosting Architecture for jyablonski.dev

Three providers each own one layer, plus a GCP VM for two apps. In short: Squarespace says *who runs the DNS*, Cloudflare says *where each hostname points*, and AWS (CloudFront) actually *serves the traffic* over HTTPS.

```
Squarespace (registrar)          Cloudflare (DNS, free tier)              AWS / GCP (origins)
"the domain is managed at   →    "www → de3b5zgfe5aot.cloudfront.net"  →  CloudFront → S3 / Lambda
 milan/zelda.ns.cloudflare.com"  "nbadashboard → 34.83.137.138"        →  GCP VM (Streamlit + MCP)
```

### 1. Squarespace: domain registrar

Squarespace is where the domain itself is registered (originally Google Domains; paid through 2029, ~$12/yr). Its only ongoing job is telling the `.dev` TLD registry which nameservers are authoritative, currently `milan.ns.cloudflare.com` and `zelda.ns.cloudflare.com`. Squarespace has no API or Terraform provider, so nameserver changes are manual clicks under Domains → Domain Nameservers. The DNS records Squarespace shows in its own DNS Settings page are **inactive** leftovers; they only matter if the domain ever switches back to Squarespace's nameservers.

### 2. Cloudflare: DNS hosting (free tier)

The zone and all records live in Cloudflare, managed by `cloudflare.tf`. The free tier covers everything used here (a full DNS zone, unlimited queries, CNAME flattening at the apex), which is why this replaced the Route53 hosted zone ($0.50/mo → $0.00/mo).

Records (all defined in `cloudflare.tf`):

| Hostname                        | Type  | Target                                                   |
| ------------------------------- | ----- | -------------------------------------------------------- |
| `jyablonski.dev` (apex) + `www` | CNAME | CloudFront `website_v2` (S3 static site)                 |
| `api`                           | CNAME | CloudFront API distribution (Lambda function URL origin) |
| `doqs`                          | CNAME | CloudFront doqs distribution (private S3 + OAC)          |
| `nbadashboard`, `mcp`           | A     | GCP VM `34.83.137.138`                                   |
| `_<hash>` validation record     | CNAME | AWS ACM (certificate renewal, never delete)              |

Every record is **DNS-only** (`proxied = false`, "grey cloud"): Cloudflare answers DNS lookups but never touches the actual traffic. This is deliberate: CloudFront already provides CDN/TLS, stacking Cloudflare's proxy on top adds latency for nothing, and the proxy's buffering breaks the SSE streaming the MCP server uses. Consequently Cloudflare's own certificates and CDN features are unused; Cloudflare here is purely a (free) DNS server.

### 3. AWS: certificates and content delivery

**HTTPS certificates**: a single ACM certificate covers `jyablonski.dev` + `*.jyablonski.dev` (`aws_acm_certificate.jacobs_website_cert` in `website.tf`). All three CloudFront distributions present it via SNI. ACM auto-renews the cert by checking the DNS validation CNAME, which now lives in Cloudflare (`cloudflare_dns_record.website_cert_validation`). If that record disappears, renewal silently fails and the sites break when the cert expires.

**CloudFront** is the front door for the three AWS-hosted properties. Each distribution terminates TLS with the ACM cert, caches at the edge, and forwards to its origin:

- `website_v2`: the main site; origin is the `jyablonski-site` S3 bucket, apex and `www` are aliases.
- `jacobs_website_api_distribution`: the REST API; origin is a Lambda function URL, caching disabled.
- `doqs_distribution`: docs site; origin is a private S3 bucket accessed via Origin Access Control, with a CloudFront Function rewriting extensionless URIs to `index.html`.

**GCP VM** (not AWS, same pattern): `nbadashboard` and `mcp` skip CloudFront entirely, using plain A records to the VM, which terminates its own TLS.

### Anatomy of a request

`https://www.jyablonski.dev` → browser asks DNS → resolver walks root → `.dev` registry → *"ask milan/zelda"* (that delegation is what Squarespace configured) → Cloudflare answers *"CNAME de3b5zgfe5aot.cloudfront.net"* → browser connects to CloudFront → TLS handshake with the ACM cert → CloudFront serves from edge cache or fetches from S3.

### Cost summary

| Item                              | Cost                                     |
| --------------------------------- | ---------------------------------------- |
| Domain registration (Squarespace) | ~$12/yr, unavoidable                     |
| DNS (Cloudflare free tier)        | $0                                       |
| ACM certificate                   | $0                                       |
| CloudFront / S3 / Lambda          | usage-based, ~pennies at current traffic |
