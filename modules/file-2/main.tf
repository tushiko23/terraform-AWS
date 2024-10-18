terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # バージョンの指定は最新のものに設定
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0" 
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1" 
    }
}
}

# 以前の記述の仕方はコメントアウト
# provider "http" {
  # HTTP providerの設定  
# }

# provider "local" {
  # Local providerの設定
# }

# backend
terraform {
  backend "s3" {
    bucket = "modules-ydk-tf-bucket" # バケット名を記述
    key    = "chapter-6/prod/terraform.tfstate" # 記録するterraform.tfstateのパス
    region = "ap-northeast-1" # リージョンを記述 
  }
}

# moduleの利用
module "my_vpc" {
  # moduleの位置
  source = "../modules"

  # Networkリソースのみ変数の値を設定
  # デフォルト値でよいものは記述しないでOK
  # 1. VPCのCIDRブロック
  # 2. プロジェクト単位で分析できるようにするためのタグ値
  # 3. ap-northeast-1aのPublicSubnetのCIDRブロック
  # 4. ap-northeast-1cのPublicSubnetのCIDRブロック
  # 5. ap-northeast-1aのPrivateSubnetのCIDRブロック
  # 6. ap-northeast-1cのPublicSubnetのCIDRブロック

  my_vpc_cidr_block = "172.1.0.0/16"
  name_base         = "paractice-modules"
  my_pubsub_1a_cidr = "172.1.0.0/20"
  my_pubsub_1c_cidr = "172.1.16.0/20"
  my_prisub_1a_cidr = "172.1.128.0/20"
  my_prisub_1c_cidr = "172.1.144.0/20"

  # SGのパラメータ値の設定
  # 1. EC2に付与するSG名
  # 2. RDSに付与するSG名
  # 3. ALBに付与するSG名

  SG_ec2 = "modules-ec2-SG"
  SG_rds = "modules-rds-SG"
  SG_alb = "modules-alb-SG"

  # RDSのパラメータ値の設定
  # 1. Database名
  # 2. db識別子

  database_name                = "test-rds"
  database_instance_identifier = "modules-tf"

  # キーペアのパラメータ値の設定
  # キーペア名 

  keypair_name = "ec2-connect-keypair"

  # EC2のパラメータ値の設定
  # EC2インスタンス名

  ec2_instance_name = "modules-ec2-instance"

  # ALBのパラメータ値の設定
  # 1. ターゲットグループ名
  # 2. ALB名

  target_group_name = "modules-target-group"
  alb_name          = "modules-alb"

  # S3のパラメータ値の設定
  # S3バケット名

  s3_name = "modules-backet"
}



