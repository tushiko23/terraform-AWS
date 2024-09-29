# ---------------------------
# キーペア
# ---------------------------
# キーペアの作成

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "ec2-keypair"
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name = "tf-ec2-keypair"
  }
}

# ---------------------------
# 秘密鍵を.pemファイルとして指定されたパスに保存
# ---------------------------

resource "local_file" "keypair_private" {
  filename        = "/home/youren-tushiko-0223/ec2-keypair.pem" # ローカルPCに保存するパス
  content         = tls_private_key.main.private_key_pem        # PEM形式の秘密鍵で保存
  file_permission = "0400"                                      # 秘密鍵のファイルパーミッション
}

# ---------------------------
# IAMRoleの作成
# ---------------------------
# IAMRoleの作成

resource "aws_iam_role" "test_role" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tf-iam-role"
  }
}


# ---------------------------
# IAMPolicyの作成
# ---------------------------
# IAMPollicyの作成

resource "aws_iam_policy" "s3_test_policy" {
  name        = "s3_test_policy"
  path        = "/"
  description = "My s3 test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::terraform-tushiko-bucket",
          "arn:aws:s3:::terraform-tushiko-bucket/*"
        ]
      }
    ]
    }
  )
  tags = {
    Name = "tf-s3-iam-policy"
  }
}

resource "aws_iam_policy" "ssm_test_policy" {
  name        = "ssm_test_policy"
  path        = "/"
  description = "My ssm test policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = {
    Name = "tf-ssm-iam-policy"
  }
}



# ---------------------------
# IAMポリシーをIAMロールにアタッチ
# ---------------------------
# IAMポリシーをIAMロールにアタッチ

#S3に関するポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "s3_polisy_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.s3_test_policy.arn
}

#SSMに関するポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ssm_polisy_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.ssm_test_policy.arn
}

# ---------------------------
# インスタンスプロファイルを作成し、IAMロールをEC2インスタンスにアタッチする設定をする
# ---------------------------
resource "aws_iam_instance_profile" "s3_ssm_access_profile" {
  name = "s3_ssm_access_profile"
  role = aws_iam_role.test_role.name
}

# ---------------------------
# EC2
# ---------------------------
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2作成
resource "aws_instance" "main_ec2" {
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-1a"
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.main.key_name
  iam_instance_profile        = aws_iam_instance_profile.s3_ssm_access_profile.id
  user_data                   = <<-EOF
              #!/bin/bash
              sudo yum update -y
　　　　　　　sudo yum install -y mysql
              sudo amazon-linux-extras install -y nginx1.12
              sudo systemctl start nginx
              sudo systemctl enable nginx

EOF
  tags = {
    Name = "tf-main-ec2"
  }
}

# ---------------------------
# ElasticIP
# ---------------------------
# 作成したEC2にアタッチ
resource "aws_eip" "main_eip" {
  instance = aws_instance.main_ec2.id
  vpc      = true
  tags = {
    Name = "tf-ec2-eip"
  }
}
