
## TD5-T01 — Authorized administrator can connect with the SSH key

**Security statement**

The account `adminX` is able to access `srv-web` using the SSH key prepared during the lab.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ssh -i ~/.ssh/id_td5 adminX@10.10.20.10 "echo SSH_KEY_OK"
````

**What should happen**

The remote command should execute successfully and return:

```text
SSH_KEY_OK
```

**Recorded evidence**

* `evidence/ssh_tests.txt`

---

## TD5-T02 — Password-only SSH login is blocked

**Security statement**

It must not be possible to authenticate to `srv-web` using only a password.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password -o BatchMode=yes adminX@10.10.20.10 "echo SHOULD_NOT_WORK"
```

**What should happen**

The connection should fail. A typical result is an SSH denial such as:

```text
Permission denied (publickey)
```

**Recorded evidence**

* `evidence/ssh_tests.txt`
* `evidence/authlog_excerpt.txt`

---

## TD5-T03 — Direct root login over SSH is refused

**Security statement**

The server must reject direct SSH access as `root`.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ssh -i ~/.ssh/id_td5 -o BatchMode=yes root@10.10.20.10 "echo SHOULD_NOT_WORK"
```

**What should happen**

The login attempt should be denied.

**Recorded evidence**

* `evidence/ssh_tests.txt`

---

## TD5-T04 — SSH access is limited to the declared admin account

**Security statement**

Remote access through SSH should be reserved for the intended administration account and not available to arbitrary users.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ssh testuser@10.10.20.10
```

**What should happen**

The connection should not be accepted.

**Recorded evidence**

* `config/sshd_config_excerpt.txt`
* `evidence/authlog_excerpt.txt`

---

## TD5-T05 — SSH successes and failures appear in the logs

**Security statement**

The server must record both successful and unsuccessful SSH authentication activity.

**Where the test is run**

On `srv-web`.

**Command used**

```bash
sudo tail -n 50 /var/log/auth.log
```

**What should happen**

The log output should include at least:

* one successful public-key login for `adminX`
* one failed authentication event

**Recorded evidence**

* `evidence/authlog_excerpt.txt`

---

## TD5-T06 — Site A client can reach its own gateway

**Security statement**

Basic local connectivity on Site A is working correctly.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ping -c 4 10.10.10.1
```

**What should happen**

The local gateway should respond without packet loss.

**Recorded evidence**

* `evidence/preflight_topology.txt`

---

## TD5-T07 — Both gateways can communicate across the WAN

**Security statement**

The WAN link between `gw-fw` and `gw-fw-b` is operational.

**Where the test is run**

From `gw-fw`.

**Command used**

```bash
ping -c 4 10.10.99.2
```

**What should happen**

The remote gateway WAN address should reply successfully.

**Recorded evidence**

* `evidence/preflight_topology.txt`

---

## TD5-T08 — End-to-end inter-site connectivity is available

**Security statement**

`client-kali` must be able to reach `srv-web` through the two-site topology.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ping -c 4 10.10.20.10
```

**What should happen**

The server should respond without packet loss.

**Recorded evidence**

* `evidence/preflight_topology.txt`
* `evidence/tunnel_ping.txt`

---

## TD5-T09 — The IPsec tunnel comes up correctly

**Security statement**

The two gateways are able to negotiate and install the VPN tunnel.

**Where the test is run**

On either gateway.

**Command used**

```bash
sudo ipsec statusall
```

**What should happen**

The output should show:

* an established IKE security association
* an installed CHILD SA
* protection applied to the declared subnets

**Recorded evidence**

* `evidence/ipsec_status.txt`

---

## TD5-T10 — The VPN is restricted to the intended networks

**Security statement**

The IPsec policy must apply only to `10.10.10.0/24` and `10.10.20.0/24`, rather than tunneling unrelated traffic.

**Where the test is run**

By inspecting the VPN configuration files.

**Command used**

```bash
grep -E 'leftsubnet|rightsubnet' config/ipsec_siteA.conf config/ipsec_siteB.conf
```

**What should happen**

The configuration should reference only the Site A LAN and Site B DMZ subnets.

**Recorded evidence**

* `config/ipsec_siteA.conf`
* `config/ipsec_siteB.conf`

---

## TD5-T11 — Connectivity remains available after the tunnel is active

**Security statement**

The VPN must protect the communication path without interrupting service reachability.

**Where the test is run**

From `client-kali`.

**Command used**

```bash
ping -c 4 10.10.20.10
```

**What should happen**

The destination should still be reachable once the tunnel is established.

**Recorded evidence**

* `evidence/tunnel_ping.txt`
* `evidence/ipsec_status.txt`

---

## TD5-T12 — Cloud-init defaults do not weaken the SSH policy

**Security statement**

The final SSH behavior must not be overridden by the cloud-init include configuration.

**Where the test is run**

By inspecting the include file on `srv-web`.

**Command used**

```bash
sudo cat /etc/ssh/sshd_config.d/50-cloud-init.conf
```

**What should happen**

The file should no longer contain a setting that re-enables password authentication.

**Recorded evidence**

* `/etc/ssh/sshd_config.d/50-cloud-init.conf`



