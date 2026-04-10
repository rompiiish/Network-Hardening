# TD3 Evidence Pack

Topology:
- client: 10.10.10.10
- gw-fw: 10.10.10.1 / 10.10.20.1
- srv-web: 10.10.20.10
- sensor-ids: 10.10.20.50

How to reproduce:
1. Start Suricata on sensor-ids.
2. Run the commands listed in tests/commands.txt.
3. Check evidence/alerts_excerpt.txt and evidence/before_after_counts.txt.
