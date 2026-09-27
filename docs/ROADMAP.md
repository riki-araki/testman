# 学習ロードマップ

目標: **バックエンドだけでなく、インフラ・クラウド・セキュリティまで幅広く戦えるエンジニア** になり、
その先でホワイトハッカー (セキュリティエンジニア / ペネトレーションテスター) を目指す。

このリポジトリのラボを軸にしつつ、ラボの外でやるべきことも併せて書いています。
チェックボックスは自分の進捗に合わせて更新してください。

---

## 全体像

```
Phase 0  土台          Linux / シェル / Git
Phase 1  ネットワーク    TCP/IP, ルーティング, DNS, HTTP, TLS          ← ラボ 01〜
Phase 2  サーバー運用    Web サーバー, DB, プロセス, リソース, ログ
Phase 3  監視と信頼性    メトリクス, ログ基盤, アラート, SLO
Phase 4  コンテナと CI/CD Docker 深掘り, Kubernetes, パイプライン
Phase 5  AWS と IaC     VPC, IAM, EC2/ECS, Terraform
Phase 6  セキュリティ    攻撃手法を知る → 検知する → 守る
Phase 7  その先         CTF, バグバウンティ, 専門分野を選ぶ
```

各フェーズは **「仕組みを理解する → ラボで壊して直す → AWS で同じことをする」** の順で進めるのがおすすめです。

---

## Phase 0: 土台 (並行して続ける)

- [ ] Linux コマンド: `ls`, `grep`, `find`, `ps`, `ss`, `journalctl`, `systemctl`
- [ ] パーミッション、ユーザー、プロセス、シグナル
- [ ] シェルスクリプト (このリポジトリの `bin/lab` を読み解けるレベル)
- [ ] Git の内部構造 (commit / tree / blob)
- [ ] Vim か好きなエディタの基本操作

**このリポジトリで学べること**: `bin/lab` は bash で書かれています。コードを読んで機能を追加するだけで、シェルスクリプトの練習になります。

## Phase 1: ネットワーク

| ラボ | 内容 | 状態 |
|---|---|---|
| 01-routing | IP・サブネット・ルーティング・戻りの経路 | ✅ |
| 02-reverse-proxy | HTTP・リバースプロキシ・ロードバランシング | ✅ |
| 03-firewall | iptables・ステートフル FW・最小権限 | ✅ |
| 04-dns | 自前の DNS サーバー (CoreDNS / BIND)、名前解決の失敗、TTL とキャッシュ | 📝 予定 |
| 05-nat | NAT ゲートウェイを自作する (MASQUERADE)、プライベートサブネットから外に出る | 📝 予定 |
| 06-tls | 自己署名 CA、証明書の期限切れ、SNI、中間証明書の欠落 | 📝 予定 |
| 07-mtu | MTU / MSS 起因で「小さい通信だけ通る」謎の障害 | 📝 予定 |
| 08-dynamic-routing | Containerlab + FRR で OSPF / BGP | 📝 予定 |

ラボ外の学習:
- [ ] 書籍『マスタリング TCP/IP 入門編』または『3 分間ネットワーク基礎講座』
- [ ] Wireshark でパケットキャプチャを読む (`tcpdump -w` で保存して開く)
- [ ] 自宅ルーターの設定画面を全部読んで理解する

## Phase 2: サーバー運用

| ラボ | 内容 |
|---|---|
| 09-db-replication | PostgreSQL のレプリケーション、フェイルオーバー、レプリケーション遅延 |
| 10-resource | ディスクフル、inode 枯渇、メモリリーク、OOM Killer、CPU 張り付き |
| 11-connection-pool | DB コネクション枯渇、タイムアウト設計 |
| 12-cache | Redis キャッシュ、キャッシュスタンピード |

## Phase 3: 監視と信頼性

| ラボ | 内容 |
|---|---|
| 13-observability | Prometheus + Grafana + Loki で「障害に気づく」仕組みを作る |
| 14-alerting | アラート設計。ラボ02 シナリオ3 (片系ダウン) を検知できるようにする |

- [ ] SRE の考え方 (SLI / SLO / エラーバジェット) — 書籍『SRE サイトリライアビリティエンジニアリング』
- [ ] ポストモーテム文化 — `journal/` に振り返りを書く習慣

## Phase 4: コンテナと CI/CD

| ラボ | 内容 |
|---|---|
| 15-container-internals | namespace / cgroup を手で触ってコンテナを自作する |
| 16-kubernetes | kind でクラスタを作り、Pod / Service / Ingress / NetworkPolicy を壊して直す |
| 17-cicd | GitHub Actions でビルド → テスト → デプロイ。このリポジトリの CI も教材 |

## Phase 5: AWS と IaC

ローカルで仕組みを理解してから AWS に進みます。対応表は [AWS_MAPPING.md](AWS_MAPPING.md) を参照してください。

1. **LocalStack + Terraform** で無料で練習
   - [ ] VPC / サブネット / ルートテーブル / IGW / NAT GW を Terraform で書く
   - [ ] セキュリティグループと NACL の違いを実験する
   - [ ] IAM ポリシーの評価ロジック (明示的 Deny > Allow > 暗黙の Deny)
2. **本物の AWS** (必ず予算アラートを設定してから)
   - [ ] AWS Budgets で月額アラート (例: $10) を設定
   - [ ] ルートユーザーに MFA、日常作業は IAM Identity Center のユーザーで
   - [ ] ALB + ECS (Fargate) + RDS の 3 層構成を Terraform で構築して、終わったら `terraform destroy`
   - [ ] CloudWatch / CloudTrail / VPC Flow Logs で「何が起きたか」を追う
3. 資格 (知識の棚卸しとして)
   - [ ] AWS Certified Solutions Architect – Associate (SAA)
   - [ ] AWS Certified Security – Specialty (セキュリティ志望なら)

## Phase 6: セキュリティ

**最初に [SAFETY.md](SAFETY.md) を必ず読んでください。** 攻撃を試してよいのは、自分が管理する環境か、明示的に許可された環境だけです。

### 6-1. 攻撃者の視点を知る

| ラボ | 内容 |
|---|---|
| 20-recon | nmap による偵察。ラボ03 の web を攻撃者目線で調べ、何が漏れているか確認 |
| 21-web-vulns | OWASP Juice Shop / DVWA を **隔離ネットワーク** に立てて SQLi, XSS, SSRF を体験 |
| 22-weak-auth | 弱いパスワード・デフォルト認証情報の危険性 (hydra を自分の環境にだけ使う) |
| 23-privesc | コンテナ内での権限昇格、特権コンテナの危険性 |

### 6-2. 検知する (ブルーチーム)

| ラボ | 内容 |
|---|---|
| 24-detect | 20〜22 の攻撃をログから検知する (nginx ログ, Suricata, Falco) |
| 25-forensics | 侵入された想定の環境から痕跡を探す |

### 6-3. 守る

| ラボ | 内容 |
|---|---|
| 26-hardening | SSH / nginx / コンテナのハードニング、CIS ベンチマーク |
| 27-secrets | シークレット管理、Git に鍵を commit してしまったときの対応 |
| 28-waf | WAF (ModSecurity) で 21 の攻撃を防ぐ |

ラボ外の学習:
- [ ] [TryHackMe](https://tryhackme.com/) の入門パス → [Hack The Box](https://www.hackthebox.com/)
- [ ] [PortSwigger Web Security Academy](https://portswigger.net/web-security) (Web 脆弱性の無料教材として最良)
- [ ] OWASP Top 10 を読む
- [ ] 資格: 情報処理安全確保支援士 → (実技を目指すなら) OSCP

## Phase 7: その先

- CTF に参加する (CTFtime で開催情報を探す、SECCON Beginners など)
- バグバウンティ (HackerOne / Bugcrowd の **スコープとルールを厳守**)
- 専門分野を選ぶ: クラウドセキュリティ / Web ペネトレーション / レッドチーム / SOC・インシデントレスポンス / 脆弱性診断

---

## このプロジェクト自体を育てることも学習になる

ラボを **使う** だけでなく **作る** ことで、さらに幅広い力がつきます。

| やること | 身につく力 |
|---|---|
| 新しいラボを作る ([CREATING_LABS.md](CREATING_LABS.md)) | 障害の仕組みを深く理解していないと作れない。人に教えられるレベルの理解 |
| `bin/lab` を Go か Python で書き直す | CLI 設計、テスト、クロスコンパイル、リリース |
| ラボの AWS 版を Terraform で作る (`labs/NN/aws/`) | IaC、クラウドの実践 |
| Web UI で進捗を可視化する | フロントエンド、API 設計 |
| CI で全ラボを自動テストする (実装済み) | CI/CD、テスト設計 |
| 学習記録をブログに書く | アウトプット力、転職・社内での評価 |

## 進め方のコツ

1. **1 日 30 分でも毎日触る**。週末にまとめてやるより定着します
2. `lab hint` を見る前に **最低 15 分は自力で調べる**
3. 直せたら必ず `journal/` に振り返りを書く。「何を見て、何を考え、何が効いたか」
4. 分からない用語は、その日のうちに一次情報 (man ページ、RFC、公式ドキュメント) にあたる
5. 1 つのラボに慣れたら、**break.sh にない壊し方を自分で考えて試す**
