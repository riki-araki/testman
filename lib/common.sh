# shellcheck shell=bash
# break.sh / verify.sh から source される共通ヘルパー。
# lab コマンドが以下の環境変数を渡す:
#   LAB_ROOT     リポジトリのルート
#   LAB_ID       ラボのディレクトリ名 (例: 01-routing)
#   LAB_DIR      ラボのディレクトリ
#   LAB_PROJECT  docker compose のプロジェクト名
#   LAB_RUNTIME  ラボ実行中の作業ディレクトリ (.runtime/<LAB_ID>)

# このラボの docker compose を実行する
dc() {
  LAB_RUNTIME="$LAB_RUNTIME" docker compose -p "$LAB_PROJECT" -f "$LAB_DIR/compose.yml" "$@"
}

# コンテナ内でコマンドを実行する (TTY なし)
dx() {
  local svc="$1"
  shift
  dc exec -T "$svc" "$@"
}

if [ -t 1 ]; then
  C_GREEN=$'\e[32m'; C_RED=$'\e[31m'; C_YELLOW=$'\e[33m'; C_BOLD=$'\e[1m'; C_RESET=$'\e[0m'
else
  C_GREEN=''; C_RED=''; C_YELLOW=''; C_BOLD=''; C_RESET=''
fi

info() { printf '%s\n' "$*"; }
warn() { printf '%s%s%s\n' "$C_YELLOW" "$*" "$C_RESET" >&2; }
die()  { printf '%s%s%s\n' "$C_RED" "$*" "$C_RESET" >&2; exit 1; }

# ---- verify.sh 用 ----------------------------------------------------------

CHECK_TOTAL=0
CHECK_FAILED=0

# expect_ok "説明" コマンド...   : コマンドが成功すれば合格
expect_ok() {
  local desc="$1"
  shift
  CHECK_TOTAL=$((CHECK_TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    printf '  %s✔%s %s\n' "$C_GREEN" "$C_RESET" "$desc"
  else
    printf '  %s✘%s %s\n' "$C_RED" "$C_RESET" "$desc"
    CHECK_FAILED=$((CHECK_FAILED + 1))
  fi
}

# expect_fail "説明" コマンド... : コマンドが失敗すれば合格 (遮断されていることの確認など)
expect_fail() {
  local desc="$1"
  shift
  CHECK_TOTAL=$((CHECK_TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    printf '  %s✘%s %s\n' "$C_RED" "$C_RESET" "$desc"
    CHECK_FAILED=$((CHECK_FAILED + 1))
  else
    printf '  %s✔%s %s\n' "$C_GREEN" "$C_RESET" "$desc"
  fi
}

# 結果を表示し、全項目合格なら 0 を返す
verify_summary() {
  local passed=$((CHECK_TOTAL - CHECK_FAILED))
  echo
  if [ "$CHECK_FAILED" -eq 0 ]; then
    printf '%s%s合格: %d/%d%s\n' "$C_BOLD" "$C_GREEN" "$passed" "$CHECK_TOTAL" "$C_RESET"
    return 0
  fi
  printf '%s%s不合格: %d/%d%s\n' "$C_BOLD" "$C_RED" "$passed" "$CHECK_TOTAL" "$C_RESET"
  return 1
}

# ---- break.sh 用 -----------------------------------------------------------

# pick_scenario 最大番号 [指定番号] : 指定がなければランダムにシナリオ番号を選ぶ
pick_scenario() {
  local max="$1" requested="${2:-}"
  if [ -n "$requested" ]; then
    if ! [[ "$requested" =~ ^[0-9]+$ ]] || [ "$requested" -lt 1 ] || [ "$requested" -gt "$max" ]; then
      die "シナリオ番号は 1〜$max で指定してください"
    fi
    echo "$requested"
  else
    echo $((RANDOM % max + 1))
  fi
}
