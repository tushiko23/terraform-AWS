# backendの定義
terraform {
  backend "s3" {
    bucket = "test-tf-buckup"
    key    = "test-tf-retry/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
