#!/usr/bin/env bash
# ラボ02 の合格条件
set -uo pipefail
source "$LAB_ROOT/lib/common.sh"

expect_ok "nginx の設定ファイルが正しい (nginx -t)" \
  dx proxy nginx -t
expect_ok "ヘルスチェック /healthz が 200 を返す" \
  dx client curl -sf -m 3 -o /dev/null http://proxy/healthz
expect_ok "トップページ / が 200 を返す" \
  dx client curl -sf -m 3 -o /dev/null http://proxy/
expect_ok "リクエストが app1 と app2 の両方に振り分けられる" \
  dx client sh -c '
    out=$(for i in 1 2 3 4 5 6; do curl -s -m 3 http://proxy/; done)
    echo "$out" | grep -q "Hostname: app1" && echo "$out" | grep -q "Hostname: app2"'
expect_ok "バックエンドにクライアントの IP (X-Real-Ip) が渡っている" \
  dx client sh -c 'curl -s -m 3 http://proxy/ | grep -q "X-Real-Ip: 10\.102\.0\."'

verify_summary
