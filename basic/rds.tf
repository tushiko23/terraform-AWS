# ------------------------------
# Database Configuration
# ------------------------------
resource "aws_db_subnet_group" "main" {
  name = "tf-rds-main"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]

  tags = {
    Name = "tf-test-rds"
  }
}

#--------------------------------------------------------------
# RDS
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  identifier             = "tf-rds"
  username               = "admin"
  password               = "mypassword"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  availability_zone      = "ap-northeast-1a"
  multi_az               = false
}
