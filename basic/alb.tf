# ----------------------------
# ターゲットグループの作成
# ----------------------------

resource "aws_alb_target_group" "test_target_group" {
  name             = "test-target-group"
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "tf-test-target-group"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# ---------------------------------------------------
# ターゲットグループに作成したインスタンスを設定する
# ---------------------------------------------------

resource "aws_alb_target_group_attachment" "test_target_ec2" {
  target_group_arn = aws_alb_target_group.test_target_group.arn
  target_id        = aws_instance.main_ec2.id
}

# -----------------------
# ALB作成
# -----------------------

resource "aws_alb" "test_alb" {
  name               = "test-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb.id]
  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]

  ip_address_type = "ipv4"

  tags = {
    Name = "tf-test-alb"
  }
}

# ----------
# リスナーを設定
# ----------

resource "aws_alb_listener" "test_listener" {
  load_balancer_arn = aws_alb.test_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.test_target_group.arn
  }
}
