#!/usr/bin/env bash
# ラボ03 の障害シナリオ (まず rules.sh を完成させて lab check 03 に合格してから)
set -euo pipefail
source "$LAB_ROOT/lib/common.sh"

scenario="$(pick_scenario 4 "${1:-}")"
case "$scenario" in
  1) # 誰かが「一時的に」全許可ルールを先頭に入れた
    dx fw iptables -I INPUT 1 -j ACCEPT
    ;;
  2) # 誰かが公開サイトを止めてしまった
    dx fw iptables -I INPUT 1 -p tcp --dport 80 -j DROP
    ;;
  3) # デバッグ用に管理画面をサブネット全体へ開けたまま放置
    dx fw iptables -I INPUT 1 -p tcp --dport 8080 -s 10.103.0.0/24 -j ACCEPT
    ;;
  4) # ループバックを塞いでしまった
    dx fw iptables -I INPUT 1 -i lo -j DROP
    ;;
esac
echo "障害シナリオを適用しました (lab break 03 <1-4> で指定も可能)"
