# ローカルの仕組みと AWS の対応表

AWS のサービスの多くは、Linux とネットワークの基本機能をマネージドにしたものです。
ローカルで「中身」を触っておくと、AWS の設定項目の意味が分かるようになります。

## ネットワーク

| ローカル (このラボ) | AWS | 違い・注意点 |
|---|---|---|
| Docker ネットワーク (`10.101.1.0/24`) | サブネット | AWS はサブネットごとに AZ が決まる。先頭 4 つと末尾 1 つの IP は予約済み |
| 複数のネットワークをまとめたもの | VPC | VPC の CIDR の中にサブネットを切る |
| `ip route` | ルートテーブル | AWS はサブネット単位でルートテーブルを関連付ける |
| デフォルトルートなし | プライベートサブネット | 「IGW へのルートがあるか」でパブリックかプライベートかが決まる |
| NAT (`iptables -t nat -j MASQUERADE`) | NAT Gateway | NAT GW は時間課金 + 転送量課金があり、**消し忘れると高い** |
| router コンテナ | VPC の暗黙ルーター / Transit Gateway | VPC 内のサブネット間は自動でルーティングされる |
| `iptables FORWARD` (ステートレス) | Network ACL | ステートレスなので戻り (エフェメラルポート 1024-65535) も許可が必要 |
| `iptables INPUT` + conntrack | セキュリティグループ | ステートフル。許可ルールのみ。**どれか 1 つでも許可なら通る** (順序なし) |
| DNS サーバー | Route 53 / VPC DNS (`.2` のアドレス) | Private Hosted Zone で VPC 内の名前解決 |
| `tcpdump` | VPC Flow Logs / Traffic Mirroring | Flow Logs はパケットの中身ではなく、「誰が誰にどのポートで」だけを記録する |

## コンピュートと負荷分散

| ローカル | AWS |
|---|---|
| コンテナ | ECS タスク / EC2 |
| docker compose | ECS サービス + タスク定義 |
| nginx リバースプロキシ | ALB (L7) / NLB (L4) |
| `upstream` ブロック | ターゲットグループ |
| `/healthz` | ALB ヘルスチェック |
| 片系ダウン (ラボ02 シナリオ3) | `UnHealthyHostCount` アラーム |
| kind (Kubernetes) | EKS |

## セキュリティと運用

| ローカル | AWS |
|---|---|
| Linux ユーザーとパーミッション | IAM ユーザー / ロール / ポリシー |
| `sudo` | IAM ロールの AssumeRole |
| `/var/log`, `docker logs` | CloudWatch Logs |
| `history`, 監査ログ | CloudTrail (誰がどの API を呼んだか) |
| Prometheus | CloudWatch Metrics |
| iptables の設定を監査する | AWS Config / Security Hub |
| シェルスクリプトで環境を作る | CloudFormation / Terraform / CDK |
| ModSecurity | AWS WAF |
| Suricata / Falco | GuardDuty |

## 無料で練習するには

- **LocalStack**: AWS API をローカルでエミュレートします。Terraform の練習に最適です (一部機能は有料版のみ)
- **AWS 無料利用枠**: 対象や期間は変わるため、必ず公式ページで最新情報を確認してください
- 本物の AWS を使う前に、**AWS Budgets で予算アラートを必ず設定** しましょう
