# ------------------------------
# S3のbucketを作成する
# ------------------------------

resource "aws_s3_bucket" "tf_s3_bucket" {
  bucket = "basic-s3-tf"

  tags = {
    Name = "test-s3-bucket"
  }
}

# ------------------------------
# パブリックアクセスをブロックする設定
# ------------------------------

resource "aws_s3_bucket_public_access_block" "tf_s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.tf_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_account_public_access_block" "tf_s3_bucket_public_access_block" {
  block_public_acls   = false
  block_public_policy = false
}

# ------------------------------
# 画像保存用バケットにバージョニングを有効化
# ------------------------------

resource "aws_s3_bucket_versioning" "tf_s3_bucket_version" {
  bucket = aws_s3_bucket.tf_s3_bucket.id
  versioning_configuration {
    status = "Enabled" # バージョニングを有効にする
  }
}

