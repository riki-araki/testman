# ラボ02 解答 (ネタバレ注意)

| # | 症状 | エラーログ / 手がかり | 直し方 |
|---|---|---|---|
| 1 | 502 Bad Gateway | `connect() failed (111: Connection refused) ... upstream: "http://10.102.0.x:8080/"` | `server app1:8080;` → `app1:80` (app2 も) に戻して reload |
| 2 | 502 Bad Gateway | `SSL_do_handshake() failed ... wrong version number` | `proxy_pass https://` → `http://` に戻して reload |
| 3 | 200 だが常に app1 / `nginx -t` が失敗 | `lab dc 02 ps -a` で app2 が `Exited` / `host not found in upstream "app2:80"` | `lab dc 02 start app2` → `lab dc 02 exec proxy nginx -s reload` |
| 4 | 404 Not Found | アクセスログは 404、エラーログに `open() "/etc/nginx/html/..." failed` | `location /api/ {` → `location / {` に戻して reload |

## 解説

- **502** は「プロキシまでは届いたが、その先 (バックエンド) との通信に失敗した」という意味です。原因はほぼ必ずエラーログに出ます。
- シナリオ 3 は **監視していないと気づけない** 障害です。ユーザーからは正常に見えますが、冗長性が失われていて、残り 1 台が落ちたら全断します。
  AWS なら ALB の `UnHealthyHostCount` を CloudWatch アラームで監視するのが定石です。
- シナリオ 3 で app2 を起動した後にも reload が必要な理由: nginx は **起動時 (reload 時) に upstream のホスト名を名前解決して IP をキャッシュ** します。
  コンテナの IP が変わると古い IP に送り続けてしまいます。本番では `resolver` ディレクティブや、サービスディスカバリの仕組みで対策します。
- `upstream` 内の `zone` は、nginx の複数ワーカープロセス間でラウンドロビンの状態を共有するためのものです。これがないと、プロセスごとに振り分けが偏ることがあります。
