#!/usr/bin/env bash
# 全ラボの自動テスト
#   break-fix: 起動直後に合格 → 各シナリオで不合格になる
#   build    : 起動直後は不合格 → solution/ を適用すると合格 → 各シナリオで不合格になる
#
# 使い方: tests/e2e.sh [lab ...]   (省略すると全ラボ)
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LAB="$ROOT/bin/lab"
failures=0

# 学習者の進捗ファイルをテストで汚さないよう退避しておく
PROGRESS="$ROOT/.progress"
BACKUP="$(mktemp)"
had_progress=0
if [ -f "$PROGRESS" ]; then cp "$PROGRESS" "$BACKUP"; had_progress=1; fi
restore_progress() {
  if [ "$had_progress" -eq 1 ]; then cp "$BACKUP" "$PROGRESS"; else rm -f "$PROGRESS"; fi
  rm -f "$BACKUP"
}
trap restore_progress EXIT

fail() { echo "  FAIL: $*"; failures=$((failures + 1)); }

scenario_count() {
  grep -oE 'pick_scenario [0-9]+' "$1/break.sh" | awk '{print $2}'
}

run_lab() {
  local dir="$1" id
  id="$(basename "$dir")"
  local TYPE="break-fix"
  # shellcheck source=/dev/null
  source "$dir/lab.conf"
  echo "=== $id ($TYPE)"

  "$LAB" stop "$id" >/dev/null 2>&1
  "$LAB" start "$id" >/dev/null 2>&1 || { fail "$id: start"; return; }

  if [ "$TYPE" = "build" ]; then
    "$LAB" check "$id" >/dev/null 2>&1 && fail "$id: 構築前なのに合格した"
    "$LAB" solve "$id" >/dev/null 2>&1 || fail "$id: solve が失敗"
  fi
  "$LAB" check "$id" >/dev/null 2>&1 || fail "$id: 正常状態で不合格"

  local n i
  n="$(scenario_count "$dir")"
  for i in $(seq 1 "$n"); do
    "$LAB" break "$id" "$i" >/dev/null 2>&1 || fail "$id: break $i が失敗"
    if "$LAB" check "$id" >/dev/null 2>&1; then
      fail "$id: シナリオ $i で壊れていない"
    else
      echo "  ok: シナリオ $i で検知"
    fi
    "$LAB" reset "$id" >/dev/null 2>&1
    if [ "$TYPE" = "build" ]; then "$LAB" solve "$id" >/dev/null 2>&1; fi
  done

  "$LAB" stop "$id" >/dev/null 2>&1
}

if [ $# -gt 0 ]; then
  for q in "$@"; do
    matches=("$ROOT"/labs/"$q"*/)
    run_lab "${matches[0]}"
  done
else
  for d in "$ROOT"/labs/[0-9]*/; do run_lab "$d"; done
fi

echo
if [ "$failures" -eq 0 ]; then
  echo "ALL PASSED"
else
  echo "$failures FAILURE(S)"
  exit 1
fi
