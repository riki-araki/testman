#!/usr/bin/env bash
# ラボ02 の障害シナリオ
set -euo pipefail
source "$LAB_ROOT/lib/common.sh"

conf="$LAB_RUNTIME/nginx/default.conf"
scenario="$(pick_scenario 4 "${1:-}")"
case "$scenario" in
  1) # バックエンドのポート番号を間違える
    sed -i 's/server app1:80;/server app1:8080;/; s/server app2:80;/server app2:8080;/' "$conf"
    ;;
  2) # HTTP のバックエンドに HTTPS で接続しようとする
    sed -i 's#proxy_pass http://app_backend;#proxy_pass https://app_backend;#' "$conf"
    ;;
  3) # バックエンドの片方が停止する (一見正常に見える)
    dc stop app2 >/dev/null 2>&1
    ;;
  4) # location のパスを間違える
    sed -i 's#location / {#location /api/ {#' "$conf"
    ;;
esac
dx proxy nginx -s reload >/dev/null 2>&1 || true
echo "障害シナリオを適用しました (lab break 02 <1-4> で指定も可能)"
