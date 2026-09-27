## ヒント1: まずステータスコードとログ

```sh
lab shell 02 client
curl -sv http://proxy/ -o /dev/null   # ステータスコードは?
```

別のターミナルで `lab logs 02 proxy` を見ると、nginx の **エラーログ** に原因がそのまま書かれていることが多いです。

## ヒント2: proxy を飛ばして直接叩く

`curl http://app1/` や `curl http://app2/` を client から実行して、**バックエンド単体では動いているか** 確かめましょう。
バックエンドが正常なら、問題は proxy の設定です。`default.conf` を正常時と見比べましょう
(元の設定は `labs/02-reverse-proxy/files/nginx/default.conf` にあります)。

## ヒント3: 「全部 200 なのに不合格」のとき

何度かリクエストして `Hostname` を見てください。いつも同じホストになっていませんか?
`lab dc 02 ps -a` で止まっているコンテナがないか確認しましょう。
止まっていたら `lab dc 02 start <service>` で起動できます。その後 nginx 側で何かする必要があるかもしれません。

## ヒント4: 4 つのシナリオ

1. バックエンドのポート番号が違う
2. プロトコル (http / https) が違う
3. バックエンドの片方が止まっている
4. location のパスが違う
