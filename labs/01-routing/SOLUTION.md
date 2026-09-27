# ラボ01 解答 (ネタバレ注意)

| # | 症状 | 調べ方 | 直し方 |
|---|---|---|---|
| 1 | client から router の先に一切届かない | client で `ip route` → `10.101.2.0/24` がない | `lab shell 01 client` → `ip route add 10.101.2.0/24 via 10.101.1.254` |
| 2 | ping の要求は server に届くが返事がない | router で `tcpdump -ni any icmp` → echo request だけ流れる / server で `ip route` | `lab shell 01 server` → `ip route add 10.101.1.0/24 via 10.101.2.254` |
| 3 | router 自身には届くが、その先へ行かない | router で `iptables -S` → `-P FORWARD DROP` | `iptables -P FORWARD ACCEPT` |
| 4 | router の lan_b 側 (10.101.2.254) に届かない | router で `ip -br link` → 片方が `DOWN` | `ip link set <IF名> up` |

## 解説

- ルーティングは **行きと戻りの両方** がそろって初めて通信が成立します。シナリオ 2 は現場でも非常によくある罠です。
- シナリオ 3 は AWS の **Network ACL** と同じ構図です。NACL はステートレスなので、戻りのエフェメラルポートも許可が必要になる点に注意。
- `traceroute` は「どこで止まったか」を、`tcpdump` は「実際に何が流れているか」を教えてくれます。推測より観測。

## おまけ: Docker 28 以降の落とし穴

`compose.yml` のネットワーク設定に `trusted_host_interfaces` という項目があります。
Docker 28 以降は、「コンテナ宛てのパケットが、そのコンテナのブリッジ以外から来たら捨てる」保護が入りました。
router コンテナでの転送はこの保護に引っかかるため、相手側ブリッジを明示的に信頼しています。
`iptables -t raw -S PREROUTING` をホストで実行すると、実際のルールを確認できます (Linux ホストの場合)。
