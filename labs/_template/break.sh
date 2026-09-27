#!/usr/bin/env bash
set -euo pipefail
source "$LAB_ROOT/lib/common.sh"

scenario="$(pick_scenario 2 "${1:-}")"
case "$scenario" in
  1) dx client true ;;  # TODO: 障害 1
  2) dx client true ;;  # TODO: 障害 2
esac
echo "障害シナリオを適用しました"
