# ラボ03 解答 (ネタバレ注意)

## Part 1

解答例は [`solution/firewall/rules.sh`](solution/firewall/rules.sh) にあります。

```sh
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -s 10.103.0.30 -j ACCEPT
iptables -P INPUT DROP
```

## Part 2

| # | 症状 | 原因 | 直し方 |
|---|---|---|---|
| 1 | 管理画面が丸見え、nmap で全ポートが見える | 先頭に `-j ACCEPT` (全許可) | `iptables -D INPUT 1` |
| 2 | 公開サイトに誰もアクセスできない | 先頭に `--dport 80 -j DROP` | `iptables -D INPUT 1` |
| 3 | client から管理画面が見える | 先頭に `--dport 8080 -s 10.103.0.0/24 -j ACCEPT` | `iptables -D INPUT 1` |
| 4 | web から名前解決できない | 先頭に `-i lo -j DROP` | `iptables -D INPUT 1` |

## 解説

- どのシナリオも「先頭に 1 行追加された」だけで、既存のルールは正しいままです。**評価順序** がすべてを決めることを体感できたでしょうか。
- シナリオ 1, 3 は **ユーザーからの苦情が来ない** 障害 (= セキュリティインシデント) です。定期的な設定監査や、
  AWS なら AWS Config / Security Hub による「SG が 0.0.0.0/0 に開いていないか」の自動チェックが有効です。
- 手でルールを消すより `rules.sh` を再適用するほうが確実です。サーバーの状態を「手作業」ではなく「コード」で管理する、これが IaC の出発点です。
- `DROP` は相手に何も返さないので nmap からは `filtered` に、`REJECT` は拒否を返すので `closed` に見えます。
  攻撃者に情報を与えないという意味では DROP、運用時の切り分けやすさでは REJECT に利点があります。
