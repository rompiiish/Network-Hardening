# TD4 — TLS Audit and Hardening with Nginx

## Purpose

This lab studies how TLS security depends on configuration quality rather than simply enabling HTTPS. The objective was to begin with a purposely weak Nginx TLS setup, assess its exposure with repeatable tests, then harden it and verify that the improvements were effective.

The deliverable is organized as an evidence-based repository. Configuration files, command outputs, and selected logs are kept so that each conclusion in the report can be traced back to concrete proof.

---

## Lab context

The exercise was carried out in a segmented virtual environment composed of four machines.

| VM name | Function | Addressing |
|---|---|---|
| `client` | audit and test workstation | `10.10.10.10` |
| `gw-fw` | gateway and firewall | `10.10.10.1 / 10.10.20.1` |
| `srv-web` | Nginx web server hosting the TLS service | `10.10.20.10` |
| `sensor-ids` | IDS and optional traffic observation point | `10.10.20.50` |

Network layout:

- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`

The client reaches the web server through the gateway, which also provides filtering and outbound NAT when Internet access is required for package installation or tool retrieval.

---

## Technical objective

The work was designed around a simple question: what changes when an insecure TLS configuration is replaced with a more defensible one?

To answer that, the lab was divided into successive stages:

1. deploy an intentionally weak HTTPS configuration on Nginx,
2. collect a baseline using command-line audit tools,
3. apply hardening measures,
4. rerun the same tests,
5. compare both states using saved evidence,
6. extend protection with simple edge controls and log review.

---

## Tools used

The main tools involved in the lab were:

- `nginx` for the HTTPS service
- `openssl` for handshake and certificate inspection
- `curl` for functional HTTPS testing
- `testssl.sh` for automated TLS analysis
- `nftables` for NAT and filtering support
- `tcpdump` and Nginx logs for visibility and triage

---

## Summary of the work performed

### 1. Weak initial deployment

A self-signed certificate was created on `srv-web` for lab use. The first Nginx TLS profile deliberately allowed outdated protocol versions and a broad cipher surface to simulate a legacy or poorly maintained deployment.

This initial state included issues such as:

- acceptance of deprecated TLS versions,
- support for weaker cipher choices,
- no HSTS policy,
- incomplete forward secrecy guarantees.

### 2. Baseline assessment

From the `client` machine, the HTTPS service was tested with OpenSSL, curl, and optionally `testssl.sh`. These commands were used to confirm which protocols and ciphers were accepted and to record certificate and handshake behavior before any remediation.

The outputs from this stage were stored under the `evidence/before/` directory.

### 3. TLS hardening

The Nginx configuration was then revised to reduce protocol and cipher exposure. The hardened target state was based on current good practice for a lab setting and included:

- allowing only TLS 1.2 and TLS 1.3,
- preferring modern AEAD cipher suites,
- enforcing forward secrecy via ECDHE,
- enabling HSTS.

The resulting configuration was preserved in `config/nginx_after.conf`.

### 4. Post-hardening validation

The same audit commands were executed again after the configuration change. This made it possible to directly compare the pre-hardening and post-hardening states using the same methodology rather than relying on assumptions.

The outputs from this second pass were saved in `evidence/after/`.

### 5. Edge protections

To go beyond protocol hardening alone, two lightweight protections were added at the Nginx layer:

- request rate limiting on a selected path,
- filtering of suspicious user agents often associated with scanning tools.

These controls were tested and their behavior was recorded as part of the final evidence set.

### 6. Basic triage

Server logs were reviewed to identify blocked or suspicious requests and to confirm that the protections produced observable traces. This part of the lab highlights that hardening is not limited to configuration; visibility is also required to understand what the service is receiving and how it reacts.

---

## Main security improvements observed

The hardened service showed clear differences compared with the original configuration:

- TLS 1.0 and TLS 1.1 were no longer accepted,
- the cipher surface was reduced,
- TLS 1.3 became available,
- forward secrecy was more consistently enforced,
- HSTS was introduced,
- abusive request patterns could be limited or blocked.

In other words, the final setup presented a smaller attack surface and a more controlled HTTPS posture than the baseline configuration.

---

## Repository structure

```text
TD4/
├── README.md
├── report.md
├── commands.txt
├── config/
│   ├── nginx_before.conf
│   ├── nginx_after.conf
│   ├── cert_info_before.txt
│   └── cert_info_after.txt
├── evidence/
│   ├── before/
│   └── after/
├── tests/
│   └── TEST_CARDS.md
└── appendix/
    ├── failure_modes.md
    └── triage.md
