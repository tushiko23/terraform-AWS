# terraform-AWS
### Raisetech第5回課題にて作成したAWSリソースをterraformで作成

--------

#### 以下の構成図に基づいて、terraformリソースを作成します。

![](terraform-task/images/tf-1.png)

## 前準備

### Terraformの使用準備 

####  1. AWS CLIをインストール
####  2. AWS CLIに環境変数で認証情報を登録し、terraformの操作をできるようにする
     
* [AWS CLIのインストール方法・認証情報の登録方法はこちら](https://github.com/tushiko23/CLI-AWS/blob/modify/cLI-command/cli-install.md)

####  3. LocalPCにTerraformをインストール(今回は`tfenv`を使用してインストール)
* [`tfenv`でのインストール手順はこちら](terraform-task/terraform-environment/tf-environment.md)
* [`wget`と`unzip`をインストールして、Terraformを使用する方法はこちら](terraform-task/terraform-environment/tf-wzip-install.md) 

   <def>(今回は`tfenv`を用いてTerraformを使用するので、参考までに載せておきます)
####  4. `tree`コマンドのインストール(任意です、あると構成がわかるので便利)
```
sudo apt install tree
```
* [参考サイト](https://qiita.com/inakuuun/items/25d08162b91fa4991549)

### Providerの設定

AWSのリソースを作成できるように、Provider.tfにProviderを定義する

TerraformのAWSにおけるProviderとは
* TerraformがAWSのリソースを管理・操作できるようにするためのインターフェース。具体的には、プロバイダーはAWSのAPIとTerraformの間の橋渡し役を果たす。Terraformを使ってAWSのインフラをコードで定義し、リソースを作成、更新、削除することができる。

```
# provider.tfに記述
# AWSプロバイダーのバージョンは3.0以降を設定

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# "ap-northeast-1" 東京リージョンを指定

provider "aws" {
  region = "ap-northeast-1"
  # AWSアクセスキー※今回はAWS CLIのcredentialsに認証情報を記述するので不要
  # ハードコーディングよりは、変数化 or 環境変数 or profile指定を利用
  # Cloud9を利用する場合は、access_key・secret_keyの記述が必要
  # 今回はCloud9のAMTCを利用するので以下2つ記述不要
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}
```


* [Cloud9のAMTCについてはこちら](https://dev.classmethod.jp/articles/aws-cloud9-aws-managed-temporary-credentials/)
* 使用するAWSプロバイダーのバージョンは3.0以降(つまり、3.×.×など)を指定。
* 構築するAWSリソースは`ap-northeast-1`東京リージョンを使用するよう指定
* 後ほど、SSH接続のためのキーペア作成に必要な`TLSプロバイダー`、SGの許可22ポートのマイIP取得に必要な`HTTPプロバイダー`、キーペアをLocalPCの指定ファイルに保存するために`Localプロバイダー`を設定します。リソース作成のタイミングで説明します。
### Terraformコマンドの説明

#### 1. `terraform init`コマンド
* init=初期化のこと。初期化して、Providerに対応したバイナリファイルをDLさせる。
* バイナリファイルは.terraformという隠しフォルダに格納される(`ls -la`で存在確認可)
* providerの変更・追加、modulesの変更・追加など、init後に前提条件を変更した際には再実行が必要。

実行すると、
```
$ terraform init

Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v3.76.1

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

***Terraform has been successfully initialized!*** が表示されると、成功！

#### 2. `terraform fmt`コマンド
* fmt=コード整形 Terraformはコード整形するのがスタンダードとなっていて、記述したファイルの=の位置等を揃える役割。
* コードを書いたら、実行するのが一般的。揃っていない場合は揃えたファイルが表示され、揃えるファイルがない場合は何も表示されない。
```
# provider.tfのコード整形
$ terraform fmt
provider.tf
```

#### 3. `terraform validate`コマンド
* validate=構文チェック Terraformにはバリデーション（記述が正しいかのチェック）機能もある。
* 成功すると、***Success! The configuration is valid.*** が表示され、エラーがあると、エラー箇所が表示される。

```
# 成功の場合
$ terraform validate
Success! The configuration is valid.

# エラーが出る場合
$ terraform validate

╷
│ Error: Reference to undeclared resource
│ 
│   on alb.tf line 12, in resource "aws_alb_target_group" "test_target_group":
│   12:   vpc_id = aws_vpc.main_vpc.id
│ 
│ A managed resource "aws_vpc" "main_vpc" has not been declared in the root module.
```
#### 4. `terraform plan`コマンド
* plan=ドライラン いきなり構築を開始するのではなく、これからどのような処理が始まるか、事前に目視確認ができる。
* ***+が追加(add)***、***~が更新(change)***、***-が削除(destroy)*** になる。
* 想定外のdestroyリソースが存在しないか確認するのが大事。
* リソースによっては、変更にあたってdestroyが必須なものもある。
* planを使うことで、稼働中リソースに本当に影響がないかを確認できる。
* planは完璧なわけではなく、依存関係の判断は不得意なので、場合によっては
`apply`の失敗もある。(逆もある。`plan`では失敗するが、`apply`で成功する)

VPCを作成するコードを記述して`terraform plan`を実行する場合、以下が表示される。

```
$ terraform plan
...
# aws_vpc.main_vpc will be created
+ resource "aws_vpc" "main_vpc" {
+ arn = (known after apply)
+ assign_generated_ipv6_cidr_block = false
+ cidr_block = "10.0.0.0/16"
+ default_network_acl_id = (known after apply)
+ default_route_table_id = (known after apply)
+ default_security_group_id = (known after apply)
+ dhcp_options_id = (known after apply)
+ enable_classiclink = (known after apply)
+ enable_classiclink_dns_support = (known after apply)
+ enable_dns_hostnames = true
+ enable_dns_support = true
+ id = (known after apply)
+ instance_tenancy = "default"
+ ipv6_association_id = (known after apply)
+ ipv6_cidr_block = (known after apply)
+ main_route_table_id = (known after apply)
+ owner_id = (known after apply)
+ tags = {
+ "Name" = "terraform-dev"
}
}
Plan: 1 to add, 0 to change, 0 to destroy.
```

#### 5. `terraform apply`コマンド
apply=実行 
* 実際に.tfファイルに記述したコードを読み込んで実行するコマンド
* 作成したAWSリソースのID(VPC-IDやSG-ID)が返ってきているか
* 同一のAWSリソースの作成が(VPCやSGなど)がマネジメントコンソール上で確認できるか
* tfファイルに書かれたリソースの構築を実行。必ず実行確認が出るので、yesと入力。
* 実行フォルダ内のtfファイルすべてが処理されるのを確認。

```
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
Terraform will perform the following actions:

# aws_vpc.main_vpc will be created
+ resource "aws_vpc" "main_vpc" {
+ arn = (known after apply)
+ assign_generated_ipv6_cidr_block = false
+ cidr_block = "10.0.0.0/16"
+ default_network_acl_id = (known after apply)
+ default_route_table_id = (known after apply)
+ default_security_group_id = (known after apply)
+ dhcp_options_id = (known after apply)
+ enable_classiclink = (known after apply)
+ enable_classiclink_dns_support = (known after apply)
+ enable_dns_hostnames = true
+ enable_dns_support = true
+ id = (known after apply)
+ instance_tenancy = "default"
+ ipv6_association_id = (known after apply)
+ ipv6_cidr_block = (known after apply)
+ main_route_table_id = (known after apply)
+ owner_id = (known after apply)
+ tags = {
+ "Name" = "terraform-dev"
}
}
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:  yes <- yesで実行

aws_vpc.main_vpc: Creating...
aws_vpc.main_vpc: Still creating... [10s elapsed]
aws_vpc.main_vpc: Creation complete after 14s [id=vpc-1234567890abcdefgh] ← vpc-idが返ってくるか確認。 

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

#### 6. `terraform destroy`コマンド
destroy=リソースを削除
* 現場ではあまり使用されない。
* 検証環境で、丸ごと消して良いパターンなどに限定する。
* `destroy`コマンドで削除予定のリソースを`plan`で確認する方法はなく、`destroy`コマンドを実行した際、***必ず削除確認*** が出るので、削除実行予定のリソースを確認し、よければyesと入力。

```
$ terraform destroy
aws_vpc.main_vpc: Refreshing state... [id=vpc-1234567890abcdefgh] 

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

# aws_vpc.main_vpc will be destroyed ←赤字になっている
- resource "aws_vpc" "main_vpc" {
- arn = (known after apply)
- assign_generated_ipv6_cidr_block = false
- cidr_block = "10.0.0.0/16"
- default_network_acl_id = (known after apply)
- default_route_table_id = (known after apply)
- default_security_group_id = (known after apply)
- dhcp_options_id = (known after apply)
- enable_classiclink = (known after apply)
- enable_classiclink_dns_support = (known after apply)
- enable_dns_hostnames = true
- enable_dns_support = true
- id = (known after apply)
- instance_tenancy = "default"
- ipv6_association_id = (known after apply)
- ipv6_cidr_block = (known after apply)
- main_route_table_id = (known after apply)
- owner_id = (known after apply)
- tags = {
- "Name" = "terraform-dev"
}
}

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes ←よければ、yesと入力。

aws_vpc.main_vpc: Destroying... [id=vpc-1234567890abcdefgh] 
aws_vpc.main_vpc: Destruction complete after 1s

Destroy complete! Resources: 1 destroyed.
```
#### 7. `tfファイルの中身`を変更して、リソースを変更したり、`コメントアウト`してリソースを削除する  (この方法がリソースの変更・削除には最も一般的)

VPCのリソースを変更する

* `cidr_block = "10.0.0.0/16`から`"172.16.0.0/16"`に変更
* タグ値を`"Name" = "tf-vpc"`から`"Name" = "AWS-vpc"`に変更
変更前
```
# ----------
# リソース定義
# ----------
# VPCを作る
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-vpc"
  }
}
```

変更後
```
# ----------
# リソース定義
# ----------
# VPCを作る
resource "aws_vpc" "main_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "AWS-vpc"
  }
}
```

`terraform plan` →`terraform apply`を実行

```
$ terraform plan
aws_vpc.main_vpc: Refreshing state... [id=vpc-1234567890abcdefgh]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_vpc.main_vpc must be replaced ←赤字になっている
-/+ resource "aws_vpc" "main_vpc" {
      ~ arn                                  = "arn:aws:ec2:ap-northeast-1:<自分のAWSID>:vpc/vpc-1234567890abcdefgh" -> (known after apply)
      - assign_generated_ipv6_cidr_block     = false -> null
      ~ cidr_block                           = "10.0.0.0/16" -> "172.16.0.0/16" # forces replacement ←変更したところは赤字
      ~ default_network_acl_id               = "acl-041f04345e95a03fe" -> (known after apply)
      ~ default_route_table_id               = "rtb-01fb74b9116d18ac8" -> (known after apply)
      ~ default_security_group_id            = "sg-0a023eb068f52d7eb" -> (known after apply)
      ~ dhcp_options_id                      = "dopt-0421d94fe44aa18e7" -> (known after apply)
      ~ enable_classiclink                   = false -> (known after apply)
      ~ enable_classiclink_dns_support       = false -> (known after apply)
      ~ id                                   = "vpc-01c46517d916e3d31" -> (known after apply)
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      - ipv6_netmask_length                  = 0 -> null
      ~ main_route_table_id                  = "rtb-01fb74b9116d18ac8" -> (known after apply)
      ~ owner_id                             = "865399724555" -> (known after apply)
      ~ tags                                 = {
          ~ "Name" = "tf-vpc" -> "AWS-vpc"
        }
      ~ tags_all                             = {
          ~ "Name" = "tf-vpc" -> "AWS-vpc"
        }
        # (4 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

`terraform apply`コマンドを実行
```
$ terraform plan
aws_vpc.main_vpc: Refreshing state... [id=vpc-1234567890abcdefgh]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_vpc.main_vpc must be replaced ←赤字になっている
-/+ resource "aws_vpc" "main_vpc" {
      ~ arn                                  = "arn:aws:ec2:ap-northeast-1:<自分のAWSID>:vpc/vpc-1234567890abcdefgh" -> (known after apply)
      - assign_generated_ipv6_cidr_block     = false -> null
      ~ cidr_block                           = "10.0.0.0/16" -> "172.16.0.0/16" # forces replacement ←変更したところは赤字
      ~ default_network_acl_id               = "acl-041f04345e95a03fe" -> (known after apply)
      ~ default_route_table_id               = "rtb-01fb74b9116d18ac8" -> (known after apply)
      ~ default_security_group_id            = "sg-0a023eb068f52d7eb" -> (known after apply)
      ~ dhcp_options_id                      = "dopt-0421d94fe44aa18e7" -> (known after apply)
      ~ enable_classiclink                   = false -> (known after apply)
      ~ enable_classiclink_dns_support       = false -> (known after apply)
      ~ id                                   = "vpc-1234567" -> (known after apply)
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      - ipv6_netmask_length                  = 0 -> null
      ~ main_route_table_id                  = "rtb-01fb74b9116d18ac8" -> (known after apply)
      ~ owner_id                             = "作成したAWSID" -> (known after apply)
      ~ tags                                 = {
          ~ "Name" = "tf-vpc" -> "AWS-vpc"
        }
      ~ tags_all                             = {
          ~ "Name" = "tf-vpc" -> "AWS-vpc"
        }
        # (4 unchanged attributes hidden)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.main_vpc: Destroying... [id=vpc-1234567890abcdefgh]
aws_vpc.main_vpc: Destruction complete after 1s
aws_vpc.main_vpc: Creating...
aws_vpc.main_vpc: Still creating... [10s elapsed]
aws_vpc.main_vpc: Creation complete after 13s [id=vpc-abcdefgh1234567890]

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.
```

VPCのリソースを削除する

変更前
```
# ----------
# リソース定義
# ----------
# VPCを作る
resource "aws_vpc" "main_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "AWS-vpc"
  }
}
```

`terraform plan` →`terraform apply`を実行
```
terraform plan
aws_vpc.main_vpc: Refreshing state... [id=vpc-08d214ecb3fb1b470]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_vpc.main_vpc will be destroyed
  # (because aws_vpc.main_vpc is not in configuration)
  - resource "aws_vpc" "main_vpc" {
      - arn                                  = "arn:aws:ec2:ap-northeast-1:<マイAWSID>:vpc/vpc-abcdefgh1234567890" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "172.16.0.0/16" -> null
      - default_network_acl_id               = "acl-006ec947e4fd82168" -> null
      - default_route_table_id               = "rtb-04ce8320352219e80" -> null
      - default_security_group_id            = "sg-0c2ed1ba29bc96741" -> null
      - dhcp_options_id                      = "dopt-0421d94fe44aa18e7" -> null
      - enable_classiclink                   = false -> null
      - enable_classiclink_dns_support       = false -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - id                                   ="vpc-abcdefgh0123456789" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-04ce8320352219e80" -> null
      - owner_id                             = "<マイAWSID>" -> null
      - tags                                 = {
          - "Name" = "AWS-vpc"
        } -> null
      - tags_all                             = {
          - "Name" = "AWS-vpc"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```
`terraform apply`コマンドを実行

```
aws_vpc.main_vpc: Refreshing state... [id=vpc-abcdefgh1234567890]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_vpc.main_vpc will be destroyed
  # (because aws_vpc.main_vpc is not in configuration)
  - resource "aws_vpc" "main_vpc" {
      - arn                                  = "arn:aws:ec2:ap-northeast-1:<マイAWSID>:vpc/vpc-abcdefgh1234567890" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "172.16.0.0/16" -> null
      - default_network_acl_id               = "acl-006ec947e4fd82168" -> null
      - default_route_table_id               = "rtb-04ce8320352219e80" -> null
      - default_security_group_id            = "sg-0c2ed1ba29bc96741" -> null
      - dhcp_options_id                      = "dopt-0421d94fe44aa18e7" -> null
      - enable_classiclink                   = false -> null
      - enable_classiclink_dns_support       = false -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - id                                   = "vpc-abcdefgh1234567890" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-04ce8320352219e80" -> null
      - owner_id                             = "" -> null
      - tags                                 = {
          - "Name" = "AWS-vpc"
        } -> null
      - tags_all                             = {
          - "Name" = "AWS-vpc"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.main_vpc: Destroying... [id=vpc-abcdefgh1234567890]
aws_vpc.main_vpc: Destruction complete after 0s

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
```
コンソール上でも削除を確認。

削除されたリソースを確認。

#### 8. `-target=`オプション 
* 1. -target=resource "<リースの種類>" "<リソース名>"  
* 2. -target=module "<モジュールの定義する種類>" "<リースの種類>" "<リソース名>" 

リソースを指定して削除する

今回は、`resource`で記述しているので、 -target=resource "<リースの種類>" "<リソース名>"で削除

```
terraform destroy -target=resource.aws_vpc.main_vpc
```
```
aws_vpc.main_vpc: Refreshing state... [id=vpc-abcdefgh1234567890]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_vpc.main_vpc will be destroyed
  - resource "aws_vpc" "main_vpc" {
      - arn                                  = "arn:aws:ec2:ap-northeast-1:<作成したAWSID>:vpc/vpc-abcdefgh1234567890" -> null
      - assign_generated_ipv6_cidr_block     = false -> null
      - cidr_block                           = "10.0.0.0/16" -> null
      - default_network_acl_id               = "acl-0044a1791651b051c" -> null
      - default_route_table_id               = "rtb-092ccf4a5b5d03cc3" -> null
      - default_security_group_id            = "sg-0342297b603cf5b1b" -> null
      - dhcp_options_id                      = "dopt-0421d94fe44aa18e7" -> null
      - enable_classiclink                   = false -> null
      - enable_classiclink_dns_support       = false -> null
      - enable_dns_hostnames                 = true -> null
      - enable_dns_support                   = true -> null
      - id                                   = "vpc-02e9cf1a32603d011" -> null
      - instance_tenancy                     = "default" -> null
      - ipv6_netmask_length                  = 0 -> null
      - main_route_table_id                  = "rtb-092ccf4a5b5d03cc3" -> null
      - owner_id                             = "<作成したAWSID>" -> null
      - tags                                 = {
          - "Name" = "tf-vpc"
        } -> null
      - tags_all                             = {
          - "Name" = "tf-vpc"
        } -> null
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.
╷
│ Warning: Resource targeting is in effect
│ 
│ You are creating a plan with the -target option, which means that the result of this plan may not represent all of the changes requested by the current configuration.
│ 
│ The -target option is not for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as part of an error
│ message.
╵

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_vpc.main_vpc: Destroying... [id=vpc-02e9cf1a32603d011]
aws_vpc.main_vpc: Destruction complete after 1s
╷
│ Warning: Applied changes may be incomplete
│ 
│ The plan was created with the -target option in effect, so some changes requested in the configuration may have been ignored and the output values may not be fully updated. Run the following command to verify
│ that no other changes are pending:
│     terraform plan
│ 
│ Note that the -target option is not suitable for routine use, and is provided only for exceptional situations such as recovering from errors or mistakes, or when Terraform specifically suggests to use it as
│ part of an error message.
╵

Destroy complete! Resources: 1 destroyed.
```
コンソール上でも確認
( `plan`,`apply`,`destroy`コマンドが対象)

[参考サイト](https://tama-shira.github.io/note/terraform/terraform-01-basic/)



#### 8. `tree`コマンド

### `tf.state`ファイルの説明
#### 1. 
#### 2.`git.ignore`をインストールして、`tf.state`ファイル及び`backup`に記録されたセキュリティ情報(SSH接続するキーペアの情報・RDSのログインパスワードなど)が誤ってPublic リポジトリにPushされないようにする

### 作成するリソースの説明
###  それぞれの記述方法
#### 1. Terraformの変数なし
#### 2. Terraformの変数ありVar
#### 3. Terraformのmodule変数で記述
#### 4. module変数で特定のリソースを記述
#### 5. workspaceで記述




 

