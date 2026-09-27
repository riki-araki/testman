#!/usr/bin/env bash
# ラボ01 の合格条件
set -uo pipefail
source "$LAB_ROOT/lib/common.sh"

expect_ok "client → server に HTTP でアクセスできる" \
  dx client curl -sf -m 3 -o /dev/null http://10.101.2.10/
expect_ok "client の lan_b 行きの経路が router (10.101.1.254) を向いている" \
  dx client sh -c 'ip route get 10.101.2.10 | grep -q "via 10.101.1.254"'
expect_ok "server の lan_a 行きの経路が router (10.101.2.254) を向いている" \
  dx server sh -c 'ip route get 10.101.1.10 | grep -q "via 10.101.2.254"'
expect_ok "client → server の通信が router を経由している (traceroute)" \
  dx client sh -c 'traceroute -n -w 1 -q 1 -m 3 10.101.2.10 | grep -q "10.101.1.254"'

verify_summary
