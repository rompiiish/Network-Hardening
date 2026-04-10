# TD2 Policy

## Zones

- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`
- Gateway / firewall: `gw-fw`
  - LAN IP: `10.10.10.1`
  - DMZ IP: `10.10.20.1`

## Allow-list

- ALLOW `client-kali (10.10.10.10)` -> `srv-web (10.10.20.10)` TCP/80 for HTTP application testing
- ALLOW return traffic for established connections
- ALLOW SSH to `gw-fw` for administration from LAN only
- ALLOW limited ICMP for diagnostics if needed

## Default stance

- INPUT: DROP
- FORWARD: DROP
- OUTPUT: ACCEPT
- Everything not explicitly allowed is denied

## Logging

- Log denied forwarded traffic
- Log denied input traffic to `gw-fw`
