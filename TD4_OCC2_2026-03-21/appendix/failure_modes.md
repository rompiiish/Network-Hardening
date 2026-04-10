
# TD4 — Failure Modes Encountered

## 1. Introduction

During the TLS hardening lab, the final result did not come from a straight configuration process. Several problems appeared along the way, some linked to Nginx configuration, some to TLS testing, and others to the validation of the protection mechanisms added afterward.

This section summarizes the main failure cases that had a real impact on the lab. The objective is not only to list what went wrong, but also to show how each issue was identified, corrected, and understood.

---

## 2. Failure modes

### FM-01 — TLS changes were made but not actually applied

#### Description

At one point, the TLS configuration was modified, but the service behavior did not change afterward.

#### Symptoms

- older protocols such as TLS 1.0 were still accepted,
- before/after tests looked almost identical,
- the server appeared unchanged even after editing the configuration.

#### Root cause

Two issues were possible here:

- Nginx had not been reloaded after editing the file,
- or the file that was modified was not the one actually used by the running service.

#### Resolution

The active configuration was checked, and Nginx was reloaded explicitly:

```bash id="75v7xk"
sudo systemctl reload nginx
sudo nginx -T
````

#### Lesson learned

Editing a configuration file is not enough by itself. The service must be reloaded, and the effective configuration must be verified before drawing any conclusion from test results.

---

### FM-02 — Cipher configuration was incorrect or too broad

#### Description

The cipher policy did not behave as expected after hardening.

#### Symptoms

* weak or unexpected ciphers still appeared in scans,
* the server accepted a wider TLS posture than intended,
* scan output did not clearly reflect the expected improvements.

#### Root cause

The issue came from the `ssl_ciphers` directive. Either the syntax was not correct, or the OpenSSL cipher string was too broad and did not restrict the configuration as intended.

#### Resolution

The cipher configuration was replaced with a more controlled and valid expression:

```nginx id="h4if4r"
ssl_ciphers 'ECDHE+AESGCM:ECDHE+CHACHA20';
```

#### Lesson learned

TLS cipher configuration is sensitive to syntax and naming conventions. A small mistake in the cipher string can leave the service in a weaker state than expected without producing an obvious error.

---

### FM-03 — HTTPS service was not reachable on port 8443

#### Description

During testing, the HTTPS endpoint could not be reached on the expected port.

#### Symptoms

* `curl` returned a connection refused error,
* no TLS handshake could be established,
* the service looked offline even though Nginx was installed.

#### Root cause

The most likely explanation was that Nginx was not listening on port `8443`, either because of a missing or incorrect `listen` directive.

#### Resolution

The listen directive was verified in the server block:

```nginx id="tw95kw"
listen 8443 ssl;
```

Then the active sockets were checked:

```bash id="wferhq"
sudo ss -tulpn | grep nginx
```

#### Lesson learned

Before evaluating TLS security, the first requirement is simple service availability. A server that is not listening correctly cannot be assessed meaningfully.

---

### FM-04 — TLS test output was interpreted the wrong way

#### Description

Some test results were initially treated as errors, even though they actually showed that the hardening was working.

#### Symptoms

* a failed handshake was interpreted as a broken configuration,
* there was confusion when OpenSSL no longer connected with older protocol flags,
* hardening appeared to “break” TLS.

#### Root cause

The issue was not in the service itself, but in the reading of the result. After hardening, rejection of deprecated protocols was expected behavior.

#### Resolution

The test output was reinterpreted correctly:

* `handshake failure` meant that the insecure protocol was rejected,
* `Cipher : NONE` indicated that no acceptable protocol/cipher combination was negotiated.

#### Lesson learned

Not every failed connection is a problem. In TLS hardening, a refusal can be the correct and desired result. Security testing requires interpretation, not just command execution.

---

### FM-05 — Rate limiting did not activate during testing

#### Description

The rate-limiting rule was configured, but repeated requests were still accepted without restriction.

#### Symptoms

* every request returned HTTP `200`,
* no `503` responses appeared,
* burst traffic seemed to pass normally.

#### Root cause

The problem came from configuration scope or test targeting:

* `limit_req_zone` was missing from the global `http {}` context,
* or the test requests were not sent to the location where the limit rule was applied.

#### Resolution

The shared zone was defined properly:

```nginx id="uwsdep"
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
```

Then the tests were run against `/api`, where the limiting rule was actually configured.

#### Lesson learned

Rate limiting depends on both correct declaration and correct placement. Even a valid directive will not work if it is applied in the wrong scope or tested against the wrong path.

---

### FM-06 — Request filtering rule did not block suspicious traffic

#### Description

The rule intended to block suspicious user agents did not take effect immediately.

#### Symptoms

* requests using `sqlmap` or `nikto` still returned HTTP `200`,
* filtering seemed to have no effect,
* the reverse proxy did not appear to enforce the rule.

#### Root cause

The filtering condition was either not placed in the correct `server {}` block, or Nginx had not been reloaded after the change.

#### Resolution

The rule was inserted in the active configuration:

```nginx id="z1l0p6"
if ($http_user_agent ~* "sqlmap|nikto|dirbuster") {
    return 403;
}
```

Then Nginx was reloaded so the change took effect.

#### Lesson learned

A security rule is only useful when it is placed at the right level and then validated with an actual test. Configuration without verification is not enough.

---

### FM-07 — Lack of immediate visibility during tests

#### Description

It was sometimes difficult to confirm what the server was doing while requests were being sent.

#### Symptoms

* no immediate feedback on whether rules were matched,
* filtering and rate limiting were harder to verify,
* troubleshooting took longer because the response had to be inferred indirectly.

#### Root cause

Logs were not being watched in real time while the tests were running.

#### Resolution

The Nginx access log was monitored live during the validation phase:

```bash id="ynh5yw"
sudo tail -f /var/log/nginx/access.log
```

#### Lesson learned

Real-time log observation makes troubleshooting much easier. It helps connect test actions with server decisions and confirms whether a security mechanism is actually being triggered.

---

## 3. Conclusion

The failure cases encountered during TD4 were useful because they showed where deployment and validation can go wrong, even in a relatively small lab.

Most of the issues fell into a few recurring categories:

* configuration changes not being applied correctly,
* service exposure problems,
* incorrect interpretation of TLS tool output,
* misplaced reverse-proxy protection rules,
* lack of visibility during troubleshooting.

Fixing these problems required a disciplined approach: make one change at a time, validate it immediately, read tool output carefully, and keep logs visible during testing.

These are practical habits, but they matter a lot in real deployments. TLS hardening is not only about choosing better settings. It also depends on correct implementation, correct testing, and correct interpretation of the evidence.



