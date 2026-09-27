#!/usr/bin/env bash
set -uo pipefail
source "$LAB_ROOT/lib/common.sh"

# 「どう直したか」ではなく「あるべき状態になっているか」を検証する
expect_ok   "説明" dx client true
expect_fail "遮断されていること等" dx client false

verify_summary
