# Appendix — Failure Modes and Troubleshooting Notes

## Introduction

The deployment did not move directly from setup to a working result. A number of issues appeared along the way, especially because the lab environment was built by reusing machines and configurations from earlier sessions. That made this appendix useful: several problems came not from the intended design itself, but from leftover state, incorrect assumptions, or troubleshooting in the wrong order.

The sections below summarize the main failure points, how they were noticed, and what was done to correct them.

---

## FM-01 — WAN interface still carried the wrong network settings

One of the earliest problems came from reused gateway configuration. An interface that was supposed to belong to the WAN still had an address from the previous DMZ layout. In practice, this meant the two gateways were not actually communicating on the expected `10.10.99.0/24` segment.

The effect was visible immediately. Gateway-to-gateway connectivity was unreliable, and the VPN could not establish because the transport path underneath it was not valid.

The fix was to clear the old addressing and apply the correct WAN configuration:
- `10.10.99.1/24` on `gw-fw`
- `10.10.99.2/24` on `gw-fw-b`

---

## FM-02 — Troubleshooting started at the VPN layer too early

At one stage, debugging focused on strongSwan and IKE negotiation before the basic WAN path had been fully checked. That created confusion because the symptoms looked like a VPN problem, while the real issue was that the two gateways were not yet communicating properly.

The correction was mainly procedural. The order of checks was changed so that lower layers were verified first:
- confirm interface addressing
- confirm route tables
- test gateway-to-gateway reachability
- only then inspect IPsec status

Once that order was followed, diagnosis became much clearer.

---

## FM-03 — Cloned gateway kept unwanted configuration remnants

The cloned gateway brought over configuration elements that no longer matched its new function in the topology. For a short time, one interface held addressing that overlapped with or contradicted the intended design, which made packet flow harder to understand.

This issue became obvious when interface inspection showed addresses that should not have been present. The solution was to flush the interface configuration and reassign only the addresses required for the new lab layout.

This was a useful reminder that cloning a machine often copies more history than expected.

---

## FM-04 — Static routes and IPsec policy caused ambiguity during testing

Static routes used during the pre-VPN phase sometimes remained active while IPsec debugging was already in progress. That made it harder to tell whether traffic was following the normal routed path or being selected by VPN policy.

The resolution was to keep the phases separate:
- first confirm that plain routed communication works
- then bring up IPsec
- then clean up or review any remaining route or policy state if behavior is unclear

Separating these steps made traffic analysis more consistent.

---

## FM-05 — SSH appeared hardened, but passwords were still accepted

This was one of the clearest examples of why configuration validation matters. The main SSH configuration file had been updated with the intended hardening rules, but password authentication was still possible afterward.

The cause was an override file located in `/etc/ssh/sshd_config.d/50-cloud-init.conf`, which still contained `PasswordAuthentication yes`.

As a result, checking only the main `sshd_config` file was not enough. The problem was resolved by updating the override as well, verifying the final daemon configuration, and restarting the SSH service.

---

## FM-06 — Uncertainty around the correct strongSwan service name

During the VPN setup, there was some confusion about which service name should actually be used to restart strongSwan. Depending on the installed package and the system layout, the expected service name was not always the first one tried.

The practical lesson was simple: use the service names that actually exist on the host, and rely on `ipsec statusall` for confirmation instead of assuming that a restart command by itself proves the VPN is operational.

---

## FM-07 — Analysis was done too high in the stack

Several delays came from investigating the higher layers too soon. When the tunnel did not come up, the first reaction was often to look at proposals, authentication settings, or daemon behavior. In this lab, that approach was less efficient than starting with the network basics.

A more reliable sequence was:

1. check interface addressing  
2. check routes  
3. verify local and remote reachability  
4. inspect daemon and tunnel status  
5. capture and verify traffic  

Following that order avoided several false leads.

---

## FM-08 — Expected behavior after IPsec was briefly misunderstood

There was also some confusion about what a successful post-IPsec state should look like. The objective of the tunnel is not to break connectivity and replace it with a different path. The objective is to keep communication working while protecting it on the transit segment.

The correct interpretation became:

- before IPsec, traffic passes normally and can be observed in clear form
- after IPsec, traffic still passes, but the transit path shows protected tunnel traffic instead of ordinary cleartext exchange

That distinction helped make the final tests more meaningful.

---

## Conclusion

Most of the failures encountered during TD5 were not due to the cryptographic mechanisms themselves. They came from reused configuration, stale addressing, routing inconsistencies, service overrides, and troubleshooting at the wrong abstraction level. In that sense, the lab reinforced a basic but important point: security controls only work reliably when the underlying network state is clean and coherent.

Once the addressing, routing, and service configuration were corrected, both the SSH hardening and the site-to-site IPsec tunnel behaved as intended.
