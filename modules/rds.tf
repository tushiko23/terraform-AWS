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
    Name = "${var.name_base}-database-subnet-group"
  }
}

#--------------------------------------------------------------
# RDS
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "rds" {
  allocated_storage      = var.storage_size
  storage_type           = var.storage_type
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  instance_class         = var.database_instance_class
  identifier             = var.database_instance_identifier
  username               = var.database_master_user
  password               = var.database_user_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  availability_zone      = var.availability_zone
  multi_az               = false
  tags = {
    Name = "${var.name_base}-rds"
  }
}

