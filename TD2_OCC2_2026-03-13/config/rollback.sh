#!/bin/bash
echo "[ROLLBACK] Flushing all nftables rules..."
sudo nft flush ruleset
echo "[ROLLBACK] Setting permissive forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
echo "[ROLLBACK] Done — all traffic now passes. Re-apply firewall rules manually."
