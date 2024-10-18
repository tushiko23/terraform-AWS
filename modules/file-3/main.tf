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
    key    = "chapter-6/stage/test-1/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# ------------------------------
# Networkを作成
# ------------------------------

variable "my_vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "name_base" {
  default = "project"
}

variable "my_pubsub_1a_cidr" {
  # "my_pubsub_1a_cidr"を設定
  default = "10.0.0.0/20"
}

variable "my_pubsub_1a_az" {
  # "ap-northeast-1a"を設定
  default = "ap-northeast-1a"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.my_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_base}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.name_base}-igw"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.main_vpc.id

  availability_zone = var.my_pubsub_1a_az
  cidr_block        = var.my_pubsub_1a_cidr

  tags = {
    Name = "${var.name_base}-pubsub-1a"
  }
}
