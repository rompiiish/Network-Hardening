````md
# TEST CARDS — TD4 TLS Audit and Hardening

---

## TD4-T01 — Baseline accepts TLS 1.0

**Claim**  
The initial Nginx TLS configuration accepts TLS 1.0 connections.

**Why this matters**  
TLS 1.0 is deprecated and should not remain enabled on a hardened service. Its presence in the baseline demonstrates the weakness that will later be removed.

**Preconditions**  
- Weak baseline configuration deployed on `srv-web`
- Service listening on `10.10.20.10:8443`

**Command**
```bash
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1
````

**Expected result**
The handshake succeeds.

**Observed result**
The handshake completed successfully, confirming that TLS 1.0 was still supported in the baseline configuration.

**Evidence**

* `evidence/before/openssl_tls1.txt`
* `evidence/before/tls_scan.txt`

---

## TD4-T02 — Baseline accepts TLS 1.1

**Claim**
The initial TLS configuration also accepts TLS 1.1.

**Why this matters**
TLS 1.1 is also deprecated and should be removed from a hardened profile.

**Preconditions**

* Weak baseline configuration deployed
* Service reachable from `client`

**Command**

```bash
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1_1
```

**Expected result**
The handshake succeeds.

**Observed result**
The handshake succeeded, showing that TLS 1.1 was enabled in the weak baseline.

**Evidence**

* `evidence/before/openssl_tls1_1.txt`
* `evidence/before/tls_scan.txt`

---

## TD4-T03 — Hardened configuration rejects TLS 1.0 and TLS 1.1

**Claim**
After hardening, the server rejects deprecated protocol versions.

**Why this matters**
Removing TLS 1.0 and TLS 1.1 is one of the main goals of the hardening phase.

**Preconditions**

* Hardened Nginx configuration deployed
* Nginx syntax checked and reloaded successfully

**Commands**

```bash
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1_1
```

**Expected result**
Both handshakes fail.

**Observed result**
Both protocol versions were rejected after hardening.

**Evidence**

* `evidence/after/openssl_tls1.txt`
* `evidence/after/openssl_tls1_1.txt`
* `evidence/after/tls_scan.txt`

---

## TD4-T04 — Hardened configuration still accepts TLS 1.2

**Claim**
The hardened service remains functional for modern TLS clients.

**Why this matters**
Hardening should reduce exposure without breaking valid client access.

**Preconditions**

* Hardened TLS configuration active
* Service reachable from `client`

**Command**

```bash
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1_2
```

**Expected result**
The handshake succeeds.

**Observed result**
TLS 1.2 remained accepted after hardening.

**Evidence**

* `evidence/after/openssl_tls1_2.txt`
* `evidence/after/openssl_s_client.txt`

---

## TD4-T05 — HSTS header is enabled after hardening

**Claim**
The hardened server sends an HSTS header.

**Why this matters**
HSTS helps enforce HTTPS on the client side and is part of the hardened profile in this lab.

**Preconditions**

* Hardened configuration deployed
* HSTS header configured in Nginx

**Command**

```bash
curl -skI https://10.10.20.10:8443/
```

**Expected result**
The response contains:

```text
Strict-Transport-Security: max-age=300
```

**Observed result**
The HSTS header appeared in the HTTPS response after hardening.

**Evidence**

* `evidence/after/headers.txt`

---

## TD4-T06 — Rate limiting triggers on burst traffic

**Claim**
Burst requests to `/api` trigger the configured rate-limiting control.

**Why this matters**
This demonstrates a basic reverse-proxy control for availability protection.

**Preconditions**

* `limit_req_zone` and `limit_req` configured in Nginx
* `/api` location active

**Command**

```bash
for i in $(seq 1 30); do
  curl -sk -o /dev/null -w "%{http_code}\n" https://10.10.20.10:8443/api
done
```

**Expected result**
Initial requests return `200`, and excess requests return `503` or another limiting response.

**Observed result**
The first requests succeeded, and later requests were limited, producing `503` responses.

**Evidence**

* `evidence/after/rate_limit_test.txt`
* `evidence/after/nginx_access_log_rate.txt`

---

## TD4-T07 — Suspicious request is blocked by filtering

**Claim**
A request matching the filtering rule is rejected by Nginx.

**Why this matters**
This proves that the reverse proxy is enforcing a basic request-filtering control.

**Preconditions**

* Filtering rule active in Nginx
* Service reachable from `client`

**Command**

```bash
curl -k -A "sqlmap" https://10.10.20.10:8443
```

**Expected result**
The server returns HTTP `403`.

**Observed result**
The request using a suspicious User-Agent was blocked with HTTP `403`.

**Evidence**

* `evidence/after/filter_test.txt`
* `evidence/after/nginx_access_log_filter.txt`

---

## TD4-T08 — Normal request remains allowed after filtering

**Claim**
The filtering rule does not block normal traffic.

**Why this matters**
A control is only useful if it blocks suspicious traffic without breaking normal requests.

**Preconditions**

* Filtering rule active
* No malicious header or User-Agent used

**Command**

```bash
curl -k https://10.10.20.10:8443/
```

**Expected result**
The server returns HTTP `200`.

**Observed result**
A normal request succeeded, showing that the rule was selective and did not deny standard traffic.

**Evidence**

* `evidence/after/curl_vk.txt`
* `evidence/after/filter_test.txt`

```
```
