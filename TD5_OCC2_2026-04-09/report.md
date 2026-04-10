# TD5 Report — Secure Remote Access with SSH Hardening and Site-to-Site IPsec

## 1. Introduction

This lab addressed the problem of securing remote administration in a small two-site environment. The work combined host-level hardening and network-level protection. On the server side, SSH was restricted so that administration no longer depended on password authentication or broad account access. On the network side, an IPsec tunnel was introduced between both gateways so that traffic crossing the WAN was no longer exposed in cleartext.

The purpose of the exercise was not limited to enabling security features. The more important objective was to take a defined security requirement, implement it correctly, and then verify through tests and system evidence that the observed behavior matched the intended policy.

## 2. Topology and Environment

The lab reused the virtual machines from earlier sessions and reorganized them into a two-site architecture.

### Site A
- `client-kali` — administrative workstation — `10.10.10.10/24`
- `gw-fw` — Site A gateway — `10.10.10.1/24` and `10.10.99.1/24`

### Site B
- `srv-web` — managed server — `10.10.20.10/24`
- `gw-fw-b` — Site B gateway — `10.10.20.1/24` and `10.10.99.2/24`

### Network Segments
- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`
- WAN: `10.10.99.0/24`

The two gateways were linked through the WAN network. Basic inter-site routing was established first by enabling IP forwarding and configuring static routes. This ensured that ordinary connectivity existed before any VPN protections were added.

## 3. Security Rationale

The main asset considered in this lab was the remote administrative path to the server hosted on Site B. Two broad categories of risk were examined.

The first category concerned SSH exposure. A default or weak SSH configuration can allow password guessing, account misuse, or unauthorized access through overly permissive login rules. The second category concerned traffic moving between both sites. Without protection, packets crossing the WAN can be observed or altered by an attacker positioned on that path.

Based on these risks, the lab aimed to enforce the following requirements:

- only the designated administrator account should be able to access the server remotely
- password-based SSH login should be disabled
- root should not be allowed to log in directly
- traffic exchanged between Site A and Site B should be encrypted and integrity protected
- the VPN should be restricted to the required subnets rather than acting as a broad tunnel
- system events related to authentication and tunnel establishment should remain visible for validation and troubleshooting

## 4. SSH Hardening Phase

The SSH hardening work was performed on `srv-web`. A dedicated administration account, `adminX`, was used for remote access. On `client-kali`, an Ed25519 key pair was generated and the public key was installed for that account on the server.

A key point in the method was sequencing. Key-based access was verified before password authentication was disabled. This avoided the common failure mode of locking out administrative access by changing the policy too early.

The final SSH policy relied on the following settings:

- `PasswordAuthentication no`
- `PermitRootLogin no`
- `AllowUsers adminX`
- `PubkeyAuthentication yes`
- `MaxAuthTries 3`
- `LoginGraceTime 30`
- `KbdInteractiveAuthentication no`

During validation, one important issue was discovered. Editing the main `/etc/ssh/sshd_config` file was not sufficient on its own because `/etc/ssh/sshd_config.d/50-cloud-init.conf` still contained `PasswordAuthentication yes`. As a result, password login remained available even though the primary configuration had been hardened. The problem was resolved by correcting the include file and restarting the SSH service.

After that fix, the server behaved as intended:

- `adminX` could authenticate with the configured private key
- password-based attempts were rejected
- direct root login was rejected

This phase produced both configuration evidence and test-based evidence showing that the hardening was active in practice.

## 5. Site-to-Site IPsec Deployment

The second phase of the lab secured traffic between the two sites by deploying a site-to-site VPN with strongSwan using IKEv2.

The design was intentionally limited in scope. The tunnel covered only the traffic exchanged between the Site A LAN and the Site B DMZ:

- `10.10.10.0/24`
- `10.10.20.0/24`

This was an important design choice because it prevented the VPN from becoming an uncontrolled full-tunnel path. Only the traffic that actually needed protection was selected.

For this lab, peer authentication used a pre-shared key. That was acceptable for a contained educational environment, although it would not be the preferred choice in a larger or long-term production deployment. In operational settings, certificate-based authentication would generally provide better scalability and stronger trust management.

The cryptographic profile applied to both gateways included:

- IKEv2
- AES-256
- SHA-256
- MODP2048
- explicit traffic selectors through `leftsubnet` and `rightsubnet`

Once the WAN-side addressing errors were corrected, the two gateways successfully established the tunnel and traffic continued to pass between both sites through the protected path.

## 6. Validation Strategy

Verification was handled in stages rather than through a single end-state check. This made troubleshooting more precise and reduced the risk of drawing the wrong conclusion from partial success.

Before enabling IPsec, the following baseline conditions were verified:

- connectivity from `client-kali` to the local gateway
- connectivity between `gw-fw` and `gw-fw-b` over the WAN
- end-to-end reachability from `client-kali` to `srv-web`

The SSH validation then focused on the three most important behaviors:

- successful login for `adminX` using the configured key
- failure of password-only authentication
- failure of direct root login

The VPN validation relied on several indicators:

- `ipsec statusall` showing active security associations
- successful connectivity between both sites after the tunnel was brought up
- confirmation that the protected traffic matched the intended subnet scope

This method was useful because it linked each security claim to something directly observable rather than relying on assumption alone.

## 7. Difficulties and Failure Points

Most of the real problems encountered during the lab came from configuration consistency rather than from the encryption mechanisms themselves.

The first major issue was a WAN addressing problem inherited from an earlier setup. One of the gateways still carried an address tied to the old lab design, which prevented proper peer communication across the transit segment.

The second issue was methodological. IPsec debugging started before the WAN path had been fully validated. That led to time being spent investigating the VPN layer while the actual problem still existed at the network layer underneath.

Another source of confusion came from stale routes and old xfrm state left behind during repeated tests. These residual elements sometimes caused traffic to behave inconsistently and made it harder to determine whether packets were using the intended path.

The SSH phase also exposed a configuration layering issue. A cloud-init include file silently overrode the expected policy and kept password authentication enabled until it was manually corrected.

These failure cases were valuable because they showed that secure configurations depend not only on the final command syntax but also on the surrounding system state and configuration inheritance.

## 8. Final Outcome

By the end of the lab, the main security objectives had been met.

For SSH:
- access was limited to `adminX`
- public key authentication worked correctly
- password authentication was disabled in the effective policy
- root login was blocked
- authentication events were available in logs for evidence and review

For IPsec:
- the gateways successfully established a site-to-site IKEv2 tunnel
- the VPN covered only the intended internal subnets
- communication between Site A and Site B remained functional after activation
- the deployed design matched the defined security objective

## 9. Residual Risks

Even though the lab was successful, the resulting setup still has limits that would matter in a production environment.

The use of a pre-shared key is one of those limits. It is manageable in a small lab but not ideal for environments where trust relationships need to scale or be rotated cleanly. Certificates would provide a better long-term model.

On the SSH side, the security of the system still depends heavily on the protection of the administrator’s private key. If that key were stolen, the attacker could potentially gain access unless additional controls such as a strong passphrase, hardware-backed storage, or another factor were used.

The environment also does not include stronger identity controls such as MFA, device trust checks, or more advanced authorization controls around remote administration.

## 10. Conclusion

This lab showed that secure remote access is built from several dependent layers rather than from a single setting. Hardening SSH improves the security of administration, but it does not protect the network path by itself. Adding a VPN protects traffic in transit, but that alone does not guarantee controlled access to the target system. Both mechanisms also depend on correct addressing, routing, and service configuration underneath.

The most useful outcome of the exercise was therefore not just the final working tunnel or the hardened SSH daemon. It was the ability to justify the final design with evidence, explain the cause of earlier failures, and demonstrate through concrete tests that the resulting behavior matched the intended security policy.
