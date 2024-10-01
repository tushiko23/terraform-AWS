
resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.main_vpc.id
  name   = var.SG_ec2
  ingress {
    from_port   = var.SG_ec2_port80
    to_port     = var.SG_ec2_port80
    protocol    = "tcp"
    cidr_blocks = [var.SG_ec2_80_cidr]
  }

  ingress {
    from_port   = var.SG_ec2_port22
    to_port     = var.SG_ec2_port22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  egress {
    from_port   = var.SG_egress_port0
    to_port     = var.SG_egress_port0
    protocol    = "-1"
    cidr_blocks = [var.SG_egress_cidr]
  }

  tags = {
    group = "${var.name_base}-ec2-sg"
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main_vpc.id
  name   = var.SG_rds
  ingress {
    from_port       = var.SG_rds_port3306
    to_port         = var.SG_rds_port3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = var.SG_egress_port0
    to_port     = var.SG_egress_port0
    protocol    = "-1"
    cidr_blocks = [var.SG_egress_cidr]
  }

  tags = {
    group = "${var.name_base}-rds-sg"
  }
}

resource "aws_security_group" "elb" {
  vpc_id = aws_vpc.main_vpc.id
  name   = var.SG_alb
  ingress {
    from_port   = var.SG_alb_port80
    to_port     = var.SG_alb_port80
    protocol    = "tcp"
    cidr_blocks = [var.SG_alb_80_cidr]
  }

  egress {
    from_port   = var.SG_egress_port0
    to_port     = var.SG_egress_port0
    protocol    = "-1"
    cidr_blocks = [var.SG_egress_cidr]
  }

  tags = {
    group = "${var.name_base}-alb-sg"
  }
}


