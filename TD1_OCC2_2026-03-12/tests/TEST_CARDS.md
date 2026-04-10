# Test Cards

**Test ID:** TD1-T01

## 1) Claim (what you assert)
Client can reach `srv-web` on the required web service.

## 2) Preconditions (state you rely on)
- `client-kali` IP: `10.10.10.10/24`
- `srv-web` IP: `10.10.20.10/24`
- `gw-fw` routes traffic between LAN and DMZ
- `nginx` is running on `srv-web`
- Port `80/tcp` is listening on `srv-web`

## 3) Configuration fragment (the minimal enforceable change)
```text
Expected allowed flow:
LAN client-kali -> DMZ srv-web -> TCP/80

## 4) Test method (positive + negative)
### Positive test (should succeed)
- Command(s):curl http://10.10.20.10
- Expected result:HTTP response from serv web

### Negative test (should fail)
- Command(s):curl -k https://10.10.20.10
- Expected result:Failed HTTPS response

## 5) Telemetry / evidence (what proves it)
- Where you looked: baseline.pcap 
- What you captured: HTTP ackets on wireshark 

## 6) Result
- PASS 
- Notes (1–3 sentences, including limitations)
HTTp worked but not HTTPS
## 7) Artifacts (filenames)
- `tests/commands.txt` line 66 --> 96
- `evidence/baseline.pcap`
-------------------------------------------------------------------------------------------------------------
**Test ID:** TD1-T02

## 1) Claim (what you assert)
Unexpected ports on `srv-web` are closed or flagged as a risk.

## 2) Preconditions (state you rely on)
- `srv-web` is reachable at `10.10.20.10`
- Port scan is run from `client-kali`
- `srv-web` should mainly expose web access, and SSH only if needed for administration

## 3) Configuration fragment (the minimal enforceable change)
```text
Expected exposed ports on srv-web:
- TCP/80 for web access
- TCP/22 only if admin access is needed
All other tested ports should be closed or filtered.

## 4) Test method (positive + negative)
### Positive test (should succeed)
- Command(s):nmap -sS -sV -p 1-1000 10.10.20.10
- Expected result:Port 80/tcp and ssh/22 open

### Negative test (should fail)
- Command(s):nmap -sS -p 23,25,110,139,445 10.10.20.10
- Expected result:closed ports

## 5) Telemetry / evidence (what proves it)
- Where you looked: Nmap output 
- What you captured:22/tcp open, 80/tcp open 

## 6) Result
- PASS 
- Notes:80/tcp was expected for the web server. 22/tcp is open and should be kept under review if not strictly needed.

## 7) Artifacts (filenames)
- `tests/commands.txt` line 41 --> 54 and 98 -->112
- 'report.md'
----------------------------------------------------------------------------------------------------------------------------
**Test ID:** TD1-T03

## 1) Claim (what you assert)
The baseline capture includes the traffic generated during testing.

## 2) Preconditions (state you rely on)
- `tcpdump` capture was started on `sensor-ids`
- Test traffic was generated from `client-kali`
- `srv-web` was reachable during the capture period

## 3) Configuration fragment (the minimal enforceable change)
```text
Traffic generated during baseline:
- HTTP to srv-web
- ICMP ping to srv-web
- SSH to srv-web if used

## 4) Test method (positive + negative)
### Positive test (should succeed)
- Command(s):tcpdump -nn -r evidence/baseline.pcap port 80
tcpdump -nn -r evidence/baseline.pcap icmp
- Expected result:HTTP and ICMP packets are visible in the capture

### Negative test (should fail)
- Command(s):tcpdump -nn -r evidence/baseline.pcap port 443
tcpdump -nn -r evidence/baseline.pcap port 53
- Expected result:no traffic

## 5) Telemetry / evidence (what proves it)
- Where you looked:baseline.pcap in tcpdump 
- What you captured: HTTP, SSH and ICMP packets 

## 6) Result
- PASS 
- Notes:HTTP, SSH, ICMP visible and used while HTTPS SSH not visible.

## 7) Artifacts (filenames)
- evidence/baseline.pcap
- report.md

--------------------------------------------------------------------------------------------------------------------------

**Test ID:** TD1-T04

## 1) Claim (what you assert)
The topology diagram matches the observed addressing and routes.

## 2) Preconditions (state you rely on)
- IP addresses and routes were collected from all VMs
- The diagram was updated with the final addressing values
- `gw-fw` acts as the boundary between LAN and DMZ

## 3) Configuration fragment (the minimal enforceable change)
```text
LAN:
- client-kali: 10.10.10.10/24

DMZ:
- srv-web: 10.10.20.10/24
- sensor-ids: 10.10.20.50/24

Trust boundary:
- gw-fw: 10.10.10.1/24 and 10.10.20.1/244

## 4) Test method (positive + negative)
### Positive test (should succeed)
- Command(s):hostname
ip addr
ip route

### Negative test (should fail)
- Command(s):


## 5) Telemetry / evidence (what proves it)
- Where you looked:command outputs 
 

## 6) Result
- PASS 
- Notes:HTTP, SSH, ICMP visible and used while HTTPS SSH not visible.

## 7) Artifacts (filenames)
- diagram.pdf
README.md
- report.md
