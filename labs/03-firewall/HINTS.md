## ヒント1: iptables の基本形

```sh
iptables -A INPUT [条件] -j [ACCEPT|DROP|REJECT]
```

よく使う条件:

| 条件 | 意味 |
|---|---|
| `-i lo` | ループバックインターフェースから |
| `-p tcp --dport 80` | TCP の宛先ポート 80 |
| `-s 10.103.0.30` | 送信元 IP |
| `-p icmp --icmp-type echo-request` | ping |
| `-m conntrack --ctstate ESTABLISHED,RELATED` | 既に確立した通信の続き |

デフォルトポリシーは `iptables -P INPUT DROP` で設定します。

## ヒント2: 順番が大事

ルールは **上から順に** 評価されます。`-P INPUT DROP` を最初に実行すると、その後の作業中に通信できなくなることがあります。
許可ルールを全部入れてから、最後にポリシーを DROP にしましょう。

## ヒント3: 名前解決のチェックだけ失敗する

Docker の内部 DNS サーバーは `127.0.0.11` (ループバック) で動いています。
`lo` からの受信を許可していますか?

## ヒント4: Part 2 のシナリオ

`iptables -L INPUT -v -n --line-numbers` で **1 行目** を見てください。
自分で書いた覚えのないルールを `iptables -D INPUT <行番号>` で消しましょう。
それでも直らなければ `sh /firewall/rules.sh` で再適用するのも正攻法です (**Infrastructure as Code** の考え方)。
