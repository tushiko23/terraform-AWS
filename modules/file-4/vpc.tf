terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # バージョンの指定は最新のものに設定
    }
  }
}

# こちらしかない書き方はv0.12以前の書き方
provider "aws" {
  region = "ap-northeast-1"
  # AWSアクセスキー
  # ハードコーディングよりは、変数化 or 環境変数 or profile指定を利用
  # 今回はAMTCを利用するので以下2つ記述不要
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}

# backendの定義
terraform {
  backend "s3" {
    bucket = "modules-tf-bucket"
    key    = "chapter-6/stage/test-2/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# moduleの利用
module "my_vpc" {
  # moduleの位置
  source = "../test-1"

  my_vpc_cidr_block = "172.1.0.0/16"
  name_base         = "paractice-modules"
  my_pubsub_1a_cidr = "172.1.0.0/20"
}