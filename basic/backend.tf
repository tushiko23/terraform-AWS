# backendの定義
terraform {
  backend "s3" {
    bucket = "tf-basic-backup"
    key    = "terraform-basic/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
