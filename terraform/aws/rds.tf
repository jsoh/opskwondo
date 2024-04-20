resource "random_password" "sftpgo_rds" {
  length  = 24
  special = false
}

resource "aws_db_instance" "sftpgo_rds" {
  identifier     = "jsoh-io-sftpgo-${local.workspace["environment"]}"
  port           = "5432"
  engine         = "postgres"
  engine_version = local.workspace["rds_engine_version"]
  instance_class = local.workspace["rds_instance_class"]

  db_name  = var.sftpgo_db_name
  password = random_password.sftpgo_rds.result
  username = var.sftpgo_db_user

  allocated_storage = 20
  storage_encrypted = true
  storage_type      = "gp3"

  backup_retention_period = 7
  backup_window           = "08:00-09:00"
  maintenance_window      = "Sun:05:00-Sun:06:00"
  skip_final_snapshot     = true

  db_subnet_group_name   = aws_db_subnet_group.sftpgo_rds.name
  vpc_security_group_ids = [aws_security_group.sftpgo_rds.id]
  publicly_accessible    = false

  allow_major_version_upgrade  = true
  apply_immediately            = false
  auto_minor_version_upgrade   = true
  deletion_protection          = true
  multi_az                     = false
  performance_insights_enabled = false

  parameter_group_name = aws_db_parameter_group.sftpgo_rds.name

  tags = {
    application = "sftpgo"
    environment = local.workspace["environment"]
  }
}

resource "aws_db_parameter_group" "sftpgo_rds" {
  name        = "jsoh-io-sftpgo-${local.workspace["environment"]}"
  family      = local.workspace["rds_parameter_group_family"]
  description = "Parameter group for sftpgo RDS ${local.workspace["environment"]}"

  parameter {
    name  = "rds.force_ssl"
    value = 0
  }

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sftpgo_rds" {
  name        = "jsoh-io-sftpgo-${local.workspace["environment"]}-rds"
  description = "Allow traffic to RDS only from sftpgo-${local.workspace["environment"]}-server VPC"
  vpc_id      = aws_vpc.sftpgo.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sftpgo.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all traffic out
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "sftpgo_rds" {
  name       = "jsoh-io-sftpgo-${local.workspace["environment"]}"
  subnet_ids = [for s in aws_subnet.sftpgo_public : s.id]

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}