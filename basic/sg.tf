# 外部APIを使って自分のIPアドレスを取得
data "http" "my_ip" {
  url = "https://api.ipify.org?format=json"
}

locals {
  my_ip = "${jsondecode(data.http.my_ip.response_body)["ip"]}/32"
}

resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "web-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    group = "tf-ec2-sg"
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "rds-sg"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    group = "tf-rds-sg"
  }
}

resource "aws_security_group" "elb" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "elb-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    group = "tf-elb-sg"
  }
}
