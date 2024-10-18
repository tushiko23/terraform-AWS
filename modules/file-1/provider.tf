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

# こちらしかない書き方はv0.12以前の書き方
provider "aws" {
  region = "ap-northeast-1"
  # AWSアクセスキー
  # ハードコーディングよりは、変数化 or 環境変数 or profile指定を利用
  # 今回はAMTCを利用するので以下2つ記述不要
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}
