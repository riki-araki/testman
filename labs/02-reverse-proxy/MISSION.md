# ラボ02: リバースプロキシが 502 Bad Gateway を返す

## 構成

```
                         ┌───────────────┐      ┌────────────────┐
 client ──── HTTP ─────▶ │ proxy (nginx) │ ───▶ │ app1 (whoami)  │
 (ブラウザ: 127.0.0.1:8002) │   :80         │ ───▶ │ app2 (whoami)  │
                         └───────────────┘      └────────────────┘
```

- `proxy` はリクエストを `app1` と `app2` に **交互に** 振り分けます (ロードバランシング)
- `app1` / `app2` は受け取ったリクエストの中身 (ホスト名・ヘッダー) をそのまま返すアプリです
- nginx の設定ファイルは `.runtime/02-reverse-proxy/nginx/default.conf` にあり、**ホスト側で直接編集** できます
  - 編集したら `lab dc 02 exec proxy nginx -t` で文法チェック → `lab dc 02 exec proxy nginx -s reload` で反映

## ミッション

1. `lab start 02` で起動し、正常な状態を観察する
   - ブラウザで http://127.0.0.1:8002 を何度かリロードし、`Hostname` が変わることを確認
   - `lab shell 02 client` → `curl -v http://proxy/` でレスポンスヘッダーも見る
   - `default.conf` を読み、各行の意味を調べる
2. `lab break 02` で障害を起こす
3. 「サイトがおかしい」という報告を受けた想定で調査して直す
4. `lab check 02` で合格すれば完了。**4 種類すべて** 直してみましょう

## 学べること

- リバースプロキシとロードバランサの役割
- HTTP ステータスコード (`502`, `404`, `504`) の意味と原因の切り分け
- `upstream`, `proxy_pass`, `proxy_set_header` の読み方
- ログを読む習慣 (`lab logs 02 proxy`)
- 「エラーは出ていないが実は壊れている」状態 (**片系ダウン**) に気づく観点

## 使えるコマンド

| コマンド | 用途 |
|---|---|
| `lab logs 02 proxy` | nginx のアクセスログ・エラーログ |
| `lab dc 02 ps -a` | 全コンテナの状態 (停止しているものも表示) |
| `lab dc 02 exec proxy nginx -t` | 設定ファイルの文法チェック |
| `lab dc 02 exec proxy nginx -s reload` | 設定の再読み込み (無停止) |
| `curl -v http://proxy/` (client 内) | リクエスト/レスポンスを詳細表示 |
| `curl http://app1/` (client 内) | proxy を通さず直接バックエンドを叩く |

## AWS との対応

| このラボ | AWS |
|---|---|
| proxy (nginx) | ALB (Application Load Balancer) |
| `upstream app_backend` | ターゲットグループ |
| app1 / app2 | ターゲット (EC2 / ECS タスク) |
| `/healthz` | ALB のヘルスチェック |
| `X-Real-IP` / `X-Forwarded-For` | ALB が付与する `X-Forwarded-For` |
| 502 Bad Gateway | ALB の `HTTPCode_ELB_502_Count` メトリクス |
