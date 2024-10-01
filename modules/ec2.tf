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
