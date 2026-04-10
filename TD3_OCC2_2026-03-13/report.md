# TD3 — Report: IDS/IPS Detection Engineering (Suricata)


## Topology and Sensor Placement

| Host | Role | IP / Network |
|------|------|--------------|
| `client` | LAN user workstation | `10.10.10.10` on `NH-LAN` |
| `gw-fw` | Firewall / router | `10.10.10.1` and `10.10.20.1` |
| `srv-web` | Web server in DMZ | `10.10.20.10` on `NH-DMZ` |
| `sensor-ids` | IDS sensor in DMZ | `10.10.20.50` on `NH-DMZ` |

`sensor-ids` was placed on the DMZ segment in promiscuous mode so it could inspect traffic flowing between `gw-fw` and `srv-web`. This placement allowed the sensor to observe client-to-server HTTP traffic after it passed through the firewall.

### What the Sensor Can See
- Traffic from `client` to `srv-web` that is allowed through `gw-fw`
- Responses from `srv-web` back to `client`
- Broadcast and ARP traffic on the DMZ segment

### What the Sensor Cannot See
- LAN-only traffic that never reaches the DMZ
- Packets dropped by the TD2 firewall before entering the DMZ
- Encrypted payload contents

### Evidence
- Visibility capture saved in `evidence/visibility_proof.txt`
- Chosen interface documented in `config/interface_selection.txt`

---

## Suricata Configuration

Suricata was installed on `sensor-ids` and configured to monitor the DMZ-facing interface. The `HOME_NET` variable was set to include both subnets used in the lab environment.

### Key Configuration
```yaml
vars:
  address-groups:
    HOME_NET: "[10.10.10.0/24, 10.10.20.0/24]"

af-packet:
  - interface: enp0s8
