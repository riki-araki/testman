#!/bin/sh
# ラボ03 解答例 (ネタバレ注意)
set -e

iptables -P INPUT ACCEPT
iptables -F INPUT

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -s 10.103.0.30 -j ACCEPT
iptables -P INPUT DROP

echo "ルールを適用しました:"
iptables -L INPUT -v -n --line-numbers
