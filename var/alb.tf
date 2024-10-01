# ----------
# ターゲットグループの作成
# ----------

resource "aws_alb_target_group" "test_target_group" {
  name             = var.target_group_name
  target_type      = var.target_type
  protocol_version = var.protocol_version
  port             = var.target_group_port
  protocol         = var.target_group_protcol

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.name_base}-target_group"
  }

  health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.health_check_protcol
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold_count
    unhealthy_threshold = var.unhealthy_threshold_count
    matcher             = "200"
  }
}

# ----------
# ターゲットグループに作成したインスタンスを設定する
# ----------

resource "aws_alb_target_group_attachment" "test_target_ec2" {
  target_group_arn = aws_alb_target_group.test_target_group.arn
  target_id        = aws_instance.main_ec2.id
}

# ----------
# ALB作成
# ----------

resource "aws_alb" "test_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.elb.id]
  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  ip_address_type = var.ip_address_type

  tags = {
    Name = "${var.name_base}-alb"
  }
}

# ----------
# リスナーを設定
# ----------

resource "aws_alb_listener" "test_listener" {
  load_balancer_arn = aws_alb.test_alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.test_target_group.arn
  }
}

