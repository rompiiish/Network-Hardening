# Failure Modes

- FM-01 Wrong interface selected: symptom = zero alerts; fix = use ip link and choose the NH-DMZ interface.
- FM-02 Promiscuous mode off: symptom = sensor only sees its own traffic; fix = enable promisc in Linux and VirtualBox Allow All.
- FM-03 Wrong HTTP keyword: http_uri instead of http.uri; symptom = rule loads but never fires.
- FM-04 Firewall state not documented: symptom = low alert count seems suspicious; fix = state whether TD2 firewall was ON or OFF.
