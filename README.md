# testman — 壊して直すインフラ学習ラボ

Docker コンテナでネットワークやサーバーを組み立て、**わざと壊して、自分で直す** ことで
インフラ・AWS・セキュリティの知識を体で覚えるための個人学習プロジェクトです。

```
lab start 01   →  正常な状態を観察する
lab break 01   →  💥 何かが壊れる (障害シナリオはランダム)
  (調査)        →  ping / traceroute / tcpdump / ログ / 設定ファイル
lab check 01   →  ✔ 直せたかを自動判定
journal/       →  振り返り (ポストモーテム) を書く
```

## なぜ「壊して直す」のか

- 障害対応は、手順書を読むだけでは身につかず、**切り分けの経験** がものを言います
- 正常な状態を知らないと異常に気づけません。まず観察してから壊す流れにしています
- 判定は自動なので、1 人でも正解が分かります
- どのラボも **AWS の何に相当するか** を対応付けているので、クラウドの理解にそのままつながります

## 必要なもの

- Docker Engine 28 以降 + Docker Compose v2 (Docker Desktop でも可)
- bash, Git
- 推奨: Linux / macOS / Windows (WSL2)

## はじめかた

```sh
git clone <このリポジトリ>
cd testman

# PATH に通しておくと便利 (任意)
export PATH="$PWD/bin:$PATH"

lab list          # ラボ一覧
lab start 01      # ラボ01 を起動
lab mission 01    # 課題を読む
lab shell 01 client
```

## コマンド一覧

| コマンド | 説明 |
|---|---|
| `lab list` | ラボ一覧と進捗 |
| `lab start <lab>` | ラボを起動 (`<lab>` は `01` のような番号でよい) |
| `lab mission <lab>` | 課題文を表示 |
| `lab break <lab> [番号]` | 障害を発生させる (番号省略でランダム) |
| `lab check <lab>` | 直せたか / 構築できたかを判定 |
| `lab hint <lab> [番号]` | ヒントを段階的に表示 |
| `lab shell <lab> <service>` | コンテナに入る |
| `lab logs <lab> [service]` | ログを表示 |
| `lab dc <lab> <args...>` | そのラボに対して `docker compose` を実行 |
| `lab reset <lab>` | 初期状態に戻す |
| `lab stop <lab>` | 停止して片付け |
| `lab progress` | クリア状況 |

## ラボ一覧

| # | タイトル | テーマ | 相当する AWS |
|---|---|---|---|
| [01](labs/01-routing/MISSION.md) | 別のネットワークにいるサーバーへ届かない | IP / サブネット / ルーティング | VPC, サブネット, ルートテーブル, NACL |
| [02](labs/02-reverse-proxy/MISSION.md) | リバースプロキシが 502 を返す | HTTP / nginx / ロードバランシング | ALB, ターゲットグループ, ヘルスチェック |
| [03](labs/03-firewall/MISSION.md) | iptables で必要な通信だけを通す | ファイアウォール / 最小権限 | セキュリティグループ |

今後追加するラボは [docs/ROADMAP.md](docs/ROADMAP.md) にまとめています。

## ドキュメント

| ドキュメント | 内容 |
|---|---|
| [docs/ROADMAP.md](docs/ROADMAP.md) | 学習ロードマップ (インフラ → AWS → セキュリティ → その先) |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | 障害調査の「型」とコマンド早見表 |
| [docs/AWS_MAPPING.md](docs/AWS_MAPPING.md) | ローカルの仕組みと AWS サービスの対応表 |
| [docs/SAFETY.md](docs/SAFETY.md) | **必読**: セキュリティ学習の法律と倫理、安全な環境の作り方 |
| [docs/CREATING_LABS.md](docs/CREATING_LABS.md) | 自分でラボを作る方法 (作ることが一番の学習) |
| [journal/](journal/) | 学習記録・ポストモーテムを書く場所 |

## ディレクトリ構成

```
bin/lab                 CLI 本体 (bash)
lib/common.sh           break.sh / verify.sh 用の共通関数
labs/
  NN-name/
    lab.conf            タイトル・難易度・タイプ
    compose.yml         環境の定義
    MISSION.md          課題文
    HINTS.md            段階的なヒント
    SOLUTION.md         解答と解説 (ネタバレ)
    break.sh            障害を起こすスクリプト
    verify.sh           合否判定スクリプト
    files/              起動時に .runtime/ にコピーされる設定ファイル (編集可)
    solution/           build タイプの解答 (自動テスト用)
  _template/            新しいラボのひな形
tests/e2e.sh            全ラボの自動テスト (壊したら検知できるか)
docs/                   ドキュメント
journal/                学習記録
.runtime/               ラボ実行中の作業ディレクトリ (git 管理外)
```

## 開発

```sh
make lint   # shellcheck
make test   # 全ラボの E2E テスト (Docker が必要、数分かかる)
```

GitHub Actions で push のたびに lint と E2E テストが走ります。
