#!/bin/sh
# web サーバーのファイアウォールルール
#
# 適用方法:  lab shell 03 fw  →  sh /firewall/rules.sh
# 確認方法:  iptables -L INPUT -v -n --line-numbers
#
# 【要件】
#   1. 受信 (INPUT) は「許可したもの以外すべて拒否」(デフォルト DROP) にする
#   2. 公開サイト  tcp/80   : 誰からでも許可
#   3. 管理画面    tcp/8080 : admin (10.103.0.30) からのみ許可
#   4. ping (ICMP echo-request) : 誰からでも許可
#   5. web 自身が始めた通信の戻り (DNS の応答など) は許可
#
# 注意: nat テーブルには触らないこと (Docker の内部 DNS 127.0.0.11 が壊れます)

set -e

# 既存の INPUT ルールを消して、いったん全許可に戻す (何度実行しても同じ結果になるように)
iptables -P INPUT ACCEPT
iptables -F INPUT

# ---- ここから下にルールを書く ------------------------------------------------

# TODO: ループバック (lo) を許可

# TODO: 確立済みの通信 (ESTABLISHED,RELATED) を許可

# TODO: ICMP echo-request を許可

# TODO: tcp/80 を許可

# TODO: tcp/8080 を admin からのみ許可

# TODO: デフォルトポリシーを DROP に

echo "ルールを適用しました:"
iptables -L INPUT -v -n --line-numbers
