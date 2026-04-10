# TEST CARDS

## TD3-T01 — Sensor sees DMZ traffic
Claim: sensor-ids in promiscuous mode captures HTTP traffic between client and srv-web.
Test: curl from client while tcpdump runs on sensor-ids.
Evidence: evidence/visibility_proof.txt

---

## TD3-T02 — Community rule triggers deterministically
Claim: A known scan pattern generates an alert with correct sid and source/destination IPs.
Test: nmap -sS -sV -p 1-1000 10.10.20.10 from client.
Evidence: evidence/alerts_excerpt.txt

---

## TD3-T03 — Custom rule triggers on intended traffic
Claim: Custom sid:9000001 fires when client requests /admin on srv-web.
Test: curl http://10.10.20.10/admin
Evidence: evidence/alerts_excerpt.txt

---

## TD3-T04 — Custom rule is scoped and does not fire on /index.html
Claim: The rule is specific enough not to alert on unrelated HTTP requests.
Test: curl http://10.10.20.10/index.html
Evidence: evidence/alerts_excerpt.txt, config/local.rules

---

## TD3-T05 — Tuning reduces noise without hiding risk
Claim: After thresholding, alert count drops for the same test traffic.
Test: Compare before/after counts for sid 2010937 using identical nmap scans.
Evidence: evidence/before_after_counts.txt

---

## TD3-T06 — Evidence is reproducible
Claim: Re-running the documented commands on the same topology reproduces the same alert pattern.
Test: Re-run commands from tests/commands.txt and compare fast.log excerpts.
Evidence: tests/commands.txt, evidence/alerts_excerpt.txt
