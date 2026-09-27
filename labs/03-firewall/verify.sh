#!/usr/bin/env bash
# ラボ03 の合格条件
set -uo pipefail
source "$LAB_ROOT/lib/common.sh"

expect_ok   "client → web:80   (公開サイト) にアクセスできる" \
  dx client curl -sf -m 2 -o /dev/null http://10.103.0.10/
expect_ok   "admin  → web:80   (公開サイト) にアクセスできる" \
  dx admin curl -sf -m 2 -o /dev/null http://10.103.0.10/
expect_ok   "admin  → web:8080 (管理画面) にアクセスできる" \
  dx admin curl -sf -m 2 -o /dev/null http://10.103.0.10:8080/
expect_fail "client → web:8080 (管理画面) は遮断される" \
  dx client curl -sf -m 2 -o /dev/null http://10.103.0.10:8080/
expect_ok   "client → web への ping が通る" \
  dx client ping -c 1 -W 1 10.103.0.10
expect_ok   "INPUT のデフォルトポリシーが DROP" \
  dx fw sh -c 'iptables -S INPUT | grep -qx -- "-P INPUT DROP"'
expect_ok   "client から見て未使用ポート tcp/22 が filtered (応答なし = DROP されている)" \
  dx client sh -c 'nmap -Pn -p 22 --max-retries 1 --host-timeout 10s 10.103.0.10 | grep -q "22/tcp.*filtered"'
expect_ok   "web から名前解決ができる (DNS の戻りが許可されている)" \
  dx fw nslookup -timeout=2 client 127.0.0.11

verify_summary
