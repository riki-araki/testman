#!/usr/bin/env bash
# ラボ01 の障害シナリオ
set -euo pipefail
source "$LAB_ROOT/lib/common.sh"

scenario="$(pick_scenario 4 "${1:-}")"
case "$scenario" in
  1) # client の経路が消える
    dx client ip route del 10.101.2.0/24
    ;;
  2) # server の戻りの経路が消える (行きは届くが返事が返らない)
    dx server ip route del 10.101.1.0/24
    ;;
  3) # router が転送を拒否する
    dx router iptables -P FORWARD DROP
    ;;
  4) # router の lan_b 側インターフェースが落ちる
    dx router sh -c 'ip link set "$(ip -o -4 addr show | awk "/10\.101\.2\.254/ {print \$2}")" down'
    ;;
esac
echo "障害シナリオを適用しました (lab break 01 <1-4> で指定も可能)"
