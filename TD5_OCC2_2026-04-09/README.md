
# TD5 OCC2 — 2026-04-09

## Lab Context

This practical session reuses the virtual machines from the previous work and extends them into a two-site security scenario. The objective is to secure administrative access to the server and to protect inter-site traffic with an IPsec tunnel.

## Reused Virtual Machines

- `gw-fw` → `siteA-gw`
- `client-kali` → `siteA-client`
- `gw-fw-b` → `siteB-gw`
- `srv-web` → `siteB-srv`
- `sensor-ids` → optional packet capture point on WAN or DMZ

## Addressing Plan

### Site A
- `siteA-gw`: `10.10.10.1/24` on LAN, `10.10.99.1/24` on WAN
- `siteA-client`: `10.10.10.10/24`

### Site B
- `siteB-gw`: `10.10.20.1/24` on DMZ, `10.10.99.2/24` on WAN
- `siteB-srv`: `10.10.20.10/24`

## Network Segments

- `NH-LAN`: `10.10.10.0/24`
- `NH-DMZ`: `10.10.20.0/24`
- `NH-WAN`: `10.10.99.0/24`

## Technical Goals

This lab has two main goals:

- harden SSH access on `siteB-srv`
- deploy a site-to-site IKEv2 IPsec VPN between `siteA-gw` and `siteB-gw`

The deliverable is evidence-driven and must include configuration extracts, command output, connectivity tests, and VPN status information.

---

## 1. Purpose of the Lab

The exercise focuses on two complementary controls commonly used in enterprise environments.

The first control is SSH hardening. Administrative access to the remote server must be restricted so that only an authorized user with a valid key pair can connect. Weak access paths such as password authentication and direct root login must be removed.

The second control is a site-to-site IPsec VPN. Instead of letting traffic cross the WAN unprotected, communications between the internal network at Site A and the server-side network at Site B must be encapsulated and encrypted.

Together, these controls improve both administrative security and network-level confidentiality.

---

## 2. Architecture Overview

The lab is built around two isolated sites connected through a transit WAN segment.

```text
Site A (LAN)                         Site B (DMZ)
---------------------               ---------------------
siteA-client                        siteB-srv
10.10.10.10                         10.10.20.10
        |                                   |
        |                                   |
   siteA-gw  ----------------------  siteB-gw
   10.10.10.1                        10.10.20.1
   10.10.99.1                        10.10.99.2
            \_______________________________/
                     WAN 10.10.99.0/24
````

Site A represents the client side from which administration and testing are performed. Site B hosts the target server and the second VPN endpoint.

---

## 3. System Roles

| VM             | Function                 | Description                                               |
| -------------- | ------------------------ | --------------------------------------------------------- |
| `siteA-client` | Administration host      | Generates SSH keys, tests connectivity, collects evidence |
| `siteA-gw`     | Gateway and VPN endpoint | Routes Site A traffic and terminates IPsec                |
| `siteB-gw`     | Gateway and VPN endpoint | Routes Site B traffic and terminates IPsec                |
| `siteB-srv`    | Server / bastion host    | Remote system accessed through hardened SSH               |

---

## 4. Security Objectives

### SSH Protection

The SSH service on `siteB-srv` must be restricted to a safer profile:

* password login disabled
* root login prohibited
* access limited to a dedicated account
* public key authentication enforced

### IPsec Protection

The VPN must provide protected communication between:

* `10.10.10.0/24` at Site A
* `10.10.20.0/24` at Site B

Only traffic matching these subnets should be tunneled.

---

## 5. Implementation Summary

### 5.1 Base Network Preparation

Before adding security controls, routing between the two sites must be correct. IP forwarding is enabled on both gateways so they can move packets between interfaces.

```bash
sysctl -w net.ipv4.ip_forward=1
```

Static routes are then configured so that each gateway knows how to reach the remote protected subnet through the WAN peer.

```bash
# On siteA-gw
ip route add 10.10.20.0/24 via 10.10.99.2

# On siteB-gw
ip route add 10.10.10.0/24 via 10.10.99.1
```

This step is important because VPN troubleshooting is difficult if basic reachability is already broken.

---

### 5.2 SSH Hardening on the Server

A dedicated key pair is created on the client workstation.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_td5
ssh-copy-id -i ~/.ssh/id_td5.pub admin1@10.10.20.10
```

On `siteB-srv`, the SSH daemon configuration is adjusted to remove weak access methods.

File modified: `/etc/ssh/sshd_config`

```text
PasswordAuthentication no
PermitRootLogin no
AllowUsers admin1
PubkeyAuthentication yes
MaxAuthTries 3
LoginGraceTime 30
```

This configuration narrows the attack surface by ensuring that only the intended account can authenticate, and only with a trusted key.

Validation checks include:

* successful login with the generated private key
* failed login attempt using a password
* failed login attempt as `root`

---

### 5.3 IPsec Deployment with strongSwan

The VPN service is implemented with strongSwan on both gateways.

```bash
sudo apt install strongswan
```

The configuration defines an IKEv2 site-to-site tunnel using a pre-shared key and restricted traffic selectors.

#### `siteA-gw` — `/etc/ipsec.conf`

```text
config setup
    charondebug="ike 2, knl 2, cfg 2"

conn site-to-site
    authby=secret
    left=10.10.99.1
    leftsubnet=10.10.10.0/24
    right=10.10.99.2
    rightsubnet=10.10.20.0/24
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256-modp2048!
    keyexchange=ikev2
    auto=start
```

#### `siteB-gw` — `/etc/ipsec.conf`

```text
conn site-to-site
    authby=secret
    left=10.10.99.2
    leftsubnet=10.10.20.0/24
    right=10.10.99.1
    rightsubnet=10.10.10.0/24
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256-modp2048!
    keyexchange=ikev2
    auto=start
```

#### Shared Secret — `/etc/ipsec.secrets`

```text
10.10.99.1 10.10.99.2 : PSK "<REDACTED>"
```

The tunnel is limited to the two internal subnets. This avoids routing unrelated traffic into the VPN.

---

### 5.4 Service Start and Tunnel Verification

Once both peers are configured, the IPsec service is restarted and the status is checked.

```bash
sudo systemctl restart strongswan-starter
sudo ipsec restart
sudo ipsec statusall
```

A correct setup should show an active IKE security association and installed child SAs for the protected subnets.

Expected indicators include:

* `ESTABLISHED`
* `INSTALLED`
* `10.10.10.0/24 === 10.10.20.0/24`

---

## 6. Validation Method

### Before VPN Activation

Before the IPsec tunnel is active, connectivity between the two sites can still be tested, but traffic is exposed on the WAN. ICMP is visible in plaintext during packet capture.

```bash
tcpdump -ni enp0s8 icmp
```

This confirms that communication exists, but not that it is protected.

### After VPN Activation

After the tunnel is established, the same connectivity tests should still succeed. The difference is that the WAN capture should now show encrypted ESP packets instead of clear ICMP payloads.

```bash
tcpdump -ni enp0s8
```

The expected observation is:

* ICMP-based communication still functions end to end
* traffic on the WAN is carried as ESP
* internal packet content is no longer directly readable

---

## 7. Observed Results

| Verification Item                       | Outcome |
| --------------------------------------- | ------- |
| SSH authentication with key             | Success |
| SSH password login                      | Blocked |
| SSH root login                          | Blocked |
| Reachability between sites before IPsec | Success |
| IKEv2/IPsec tunnel establishment        | Success |
| ESP observed on WAN link                | Success |

---

## 8. Security Value of the Configuration

Several concrete improvements were achieved during this lab.

SSH hardening reduces the risk of brute-force attempts, credential guessing, and misuse of privileged accounts. By forcing key-based authentication and restricting access to a named user, the remote administration path becomes narrower and easier to audit.

The IPsec deployment ensures confidentiality of traffic crossing the WAN segment. Even if packets are captured in transit, their contents are protected. The use of scoped subnets also limits exposure by ensuring the tunnel only carries the intended inter-site flows.

From a hardening perspective, the final design is significantly stronger than a default routed setup with standard SSH access.

---

## 9. Key Lessons Learned

This lab highlighted several operational points.

IPsec is highly dependent on correct routing and interface configuration. If the network path is wrong, the VPN will often fail in ways that are not immediately obvious. For that reason, plain connectivity must always be tested first.

It also became clear that SSH hardening is simple to configure but easy to lock yourself out with if keys are not validated before disabling passwords.

Finally, the troubleshooting process is more effective when done layer by layer: interface state, addressing, routing, service configuration, then security associations and packet capture.

---

## 10. Suggested Repository Layout

```text
TD5/
├── README.md
├── report.md
├── config/
├── evidence/
├── tests/
└── appendix/
```

A structure like this helps separate configurations, captured outputs, and written analysis.

---

## 11. Conclusion

This practical session combined host-level and network-level hardening into a single secure design.

On the host side, SSH was restricted to a controlled, key-based administration model. On the network side, the link between both sites was protected using an IKEv2 IPsec tunnel.

The final result is a more defensible architecture in which:

* administrative access is tightly controlled
* direct credential-based access is removed
* inter-site communications are encrypted
* traffic exposure on the WAN is reduced

The lab therefore demonstrates how access control and transport protection can be integrated into a small but realistic network hardening scenario.


