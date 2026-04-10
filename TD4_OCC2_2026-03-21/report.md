# TD4 Report — TLS Audit and Hardening with Nginx

## 1. Introduction

The purpose of this lab was to study how secure or insecure an HTTPS service can be depending on its TLS configuration. The work started from an intentionally weak Nginx setup, then moved through an audit phase, a hardening phase, and finally a validation phase to check whether the changes actually improved the service.

The point was not only to get HTTPS working, but to show the full process in a structured way. For that reason, the lab was documented with a before/after method: configuration files were saved, commands were run from the client machine, and outputs and logs were kept as evidence.

---

## 2. Lab environment

The lab environment was built around four virtual machines:

| VM Name | Role | IP Address |
|---|---|---|
| `client` | testing and audit machine | `10.10.10.10` |
| `gw-fw` | gateway / firewall | `10.10.10.1 / 10.10.20.1` |
| `srv-web` | web server running Nginx | `10.10.20.10` |
| `sensor-ids` | IDS / optional monitoring host | `10.10.20.50` |

The network was divided into two zones:

- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`

The client machine was placed in the LAN and used to test the web service hosted in the DMZ. Communication between both networks passed through the gateway.

---

## 3. Threat model

In this lab, the main asset to protect was the HTTPS service exposed by `srv-web`. The attacker model remained simple on purpose: either someone on the same lab network able to observe or interfere with traffic, or a remote scanner probing the web server for weak settings.

The main risks considered were the following:

- support for obsolete protocol versions such as TLS 1.0 and TLS 1.1,
- acceptance of weak or overly broad cipher suites,
- poor certificate trust due to the use of a self-signed certificate,
- lack of basic reverse-proxy protections against suspicious requests or traffic bursts.

The target state was therefore a service that rejects legacy TLS versions, limits the negotiated cipher surface, improves forward secrecy, makes the certificate situation explicit, and applies a few basic protections at the Nginx layer.

---

## 4. Tools used

Several standard tools were used throughout the lab:

- `nginx`
- `openssl s_client`
- `curl`
- `testssl.sh`
- `tcpdump`
- `nftables`

These tools were enough to deploy the service, inspect TLS behavior, apply security changes, and observe the result.

---

## 5. Weak baseline deployment

The first step was to generate a self-signed certificate on `srv-web`:

```bash
openssl req -x509 -nodes -days 7 \
-newkey rsa:2048 \
-keyout server.key \
-out server.crt \
-subj "/CN=td4.local"
