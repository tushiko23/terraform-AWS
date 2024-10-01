# provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# backend
terraform {
  backend "s3" {
    bucket = "modules-ydk-tf-bucket"
    key    = "chapter-6/stage/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# moduleの利用
module "my_vpc" {
  # moduleの位置
  source = "../modules/"
}

