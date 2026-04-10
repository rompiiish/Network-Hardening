# Report

## Packet capture analysis

### Observation 1
- Timestamp range:2026-03-12 19:28:50 --> 19:28:56
- Flow matrix row reference:F01
- What you observed:SSH traffic from client-kali to srv-webover TCP port 22
- Why it matters for hardening: admin access to srv-web is possible from the LAN, whici increases attack surface.
- Proposed control:Restrict SSH to admins
- Evidence pointer: packets 236,237, 238

### Observation 2
- Timestamp range:2026-03-12 19:28:08 --> 19:28:19
- Flow matrix row reference:F04
- What you observed:HTTP traffic from clien-kali to srv-web over TCP port 80.
- Why it matters for hardening: It shows that it is reachable across the trust boundary and that it is active.
- Proposed control:Keep it allowed only in the required source. Consider redirecting HTTPS
- Evidence pointer:5, 7, 19, 21

### Observation 3
- Timestamp range:2026-03-12 19:29:11
- Flow matrix row reference:F05
- What you observed:ICMP echo and replly traffic.
- Why it matters for hardening:Good for troobleshooting and connectivity tests, but unrestricted ICMP can help attackers map reachable hosts.
- Proposed control:Restric by source zone
- Evidence point: 29 --> 65
 
### Observation 4
- Timestamp range: same as obsr 1
- Flow matrix row reference:1
- What you observed: http filter returns traffic while tls returns none. The http exchange is unencrypted traffic.
- Why it matters for hardening: Unencrypted web traffic can expose requests and content to anyone who can read the segment.
- Proposed control:add HTTPS on port 443 with TLS and reduce/redirect plain HTTP
- Evidence pointer:same as obsr 1

### Observation 5
- Timestamp range: 0
- Flow matrix row reference:F02
- What you observed:No DNS exchange
- Why it matters for hardening:It is not required
- Proposed control:remove or keep in review DNS until a real service needs it.
- Evidence pointer:


## Top 10 risks

- Unencrypted HTTP on srv-web.
- SSH open from the LAN to the DMZ without fine-grained restrictions.
- No explicit filtering policy on gw-fw yet.
- Broad reachability between LAN and DMZ.
- Unexpected ports possibly open on srv-web.
- No logging of refusals at the gw-fw level.
- Network outputs not explicitly limited.
- Dependency on undocumented default installed services.
- Poor separation between admin traffic and application traffic.
- Significant network visibility from sensor-ids, useful defensively but needs to be protected.

## Top 5 quick wins

- Close all unnecessary ports on srv-web.
- Restrict SSH to client only, or mark it as temporary.
- Prepare a default deny policy on gw-fw for TD2.
- Remove unnecessary ICMP flows after the test phase.
- Document and explicitly limit the flows allowed in the matrix.
