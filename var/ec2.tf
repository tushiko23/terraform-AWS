# キーペアの作成
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = var.keypair_name
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name = "${var.name_base}-keypair"
  }
}

# localPCに保存

resource "local_file" "keypair_private" {
  filename        = "/home/youren-tushiko-0223/ec2-connect-key.pem" # ローカルPCに保存するパス
  content         = tls_private_key.main.private_key_pem            # PEM形式の秘密鍵で保存
  file_permission = "0400"                                          # 秘密鍵のファイルパーミッション
}

# IAMRoleの作成
resource "aws_iam_role" "test_role" {
  name = "test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    tag-key = "${var.name_base}-role"
  }
}

# IAMPolicyの作成
resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policy"
  path        = "/"
  description = "My s3 policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::ydk-tf-bucket",
          "arn:aws:s3:::ydk-tf-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "ssm_policy"
  path        = "/"
  description = "My ssm policy"

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
}

# ポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

# インスタンスプロファイル作成
resource "aws_iam_instance_profile" "s3_ssm_access_profile" {
  name = "s3_ssm_access_profile"
  role = aws_iam_role.test_role.name
}

# EC2インスタンス作成
# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "main_ec2" {
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = var.ec2_instance_type
  availability_zone           = "ap-northeast-1a"
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
  key_name                    = var.keypair_name
  iam_instance_profile        = aws_iam_instance_profile.s3_ssm_access_profile.name

  root_block_device {
    volume_size           = var.ec2_instance_volume_size
    volume_type           = var.ec2_instance_volume_type
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y mysql
    sudo amazon-linux-extras install -y nginx1.12
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF

  tags = {
    Name = "${var.name_base}-ec2"
  }
}

# ====================
# Elastic IP
# ====================
resource "aws_eip" "main_eip" {
  instance = aws_instance.main_ec2.id
  vpc      = true

  tags = {
    Name = "${var.name_base}-eip"
  }
}
