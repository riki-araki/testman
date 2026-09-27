#!/usr/bin/env bash
# 解答を適用する (lab solve 03 から呼ばれる。自動テスト用)
set -euo pipefail
source "$LAB_ROOT/lib/common.sh"

cp "$LAB_DIR/solution/firewall/rules.sh" "$LAB_RUNTIME/firewall/rules.sh"
dx fw sh /firewall/rules.sh >/dev/null
echo "解答を適用しました"
