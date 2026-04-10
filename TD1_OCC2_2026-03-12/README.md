# Lab README

## Team members and roles

- Nathan HERBRON / all

## Lab topology summary

The lab contains two zones and one trust boundary.

### LAN
- `client`
- IP: `10.10.10.10/24`
- Gateway: `10.10.10.1`

### DMZ
- `srv-web`
- IP: `10.10.20.10/24`
- Gateway: `10.10.20.1`

- `sensor-ids`
- IP: `10.10.20.50/24`
- Gateway: `10.10.20.1`

### Trust boundary
- `gw-fw`
- LAN IP: `10.10.10.1/24`
- DMZ IP: `10.10.20.1/24`

## What was tested

The following checks were performed on the lab:

- Hostname, IP address, subnet, and routes on each VM
- Listening services using `ss -tulpn`
- Port scan of `srv-web` using `nmap -sS -sV -p 1-1000 10.10.20.10`
- Traffic capture using `tcpdump`
- Basic traffic generation from `client-kali`:
  - HTTP to `srv-web`
  - ICMP ping to `srv-web`
  - SSH to `srv-web` 

## Results summary

- `srv-web` was reachable on:
  - TCP `80` (`nginx`)
  - TCP `22` (`OpenSSH`)
- No HTTPS service.
- `sensor-ids` and `gw-fw` mainly showed local or low-value services in the collected outputs
- The main expected application flow was LAN to DMZ HTTP traffic

## Known limitations

- DNS and NTP service on `gw-fw` were not  network-facing
- Packet capture duration was limited ~ 5 min
- Firewall policy enforcement on `gw-fw` was not yet set up 
