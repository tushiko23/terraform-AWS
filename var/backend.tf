# backendの定義
terraform {
  backend "s3" {
    bucket = "test-tf-backup"
    key    = "test-tf-retry/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
