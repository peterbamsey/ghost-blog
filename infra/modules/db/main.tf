resource "aws_rds_cluster_instance" "instances" {
  cluster_identifier   = aws_rds_cluster.cluster.id
  count                = var.number-of-instances
  db_subnet_group_name = aws_db_subnet_group.subnet-group.name
  engine               = aws_rds_cluster.cluster.engine
  engine_version       = aws_rds_cluster.cluster.engine_version
  identifier           = "${var.app-name}-${count.index}"
  instance_class       = var.instance-class
}

resource "aws_rds_cluster" "cluster" {
  availability_zones     = var.availability-zones
  cluster_identifier     = "${var.app-name}-cluster"
  database_name          = var.database-name
  db_subnet_group_name   = aws_db_subnet_group.subnet-group.name
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.03.2"
  master_password        = var.master-password
  master_username        = var.master-username
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.sg.id]
}

resource "aws_db_subnet_group" "subnet-group" {
  name       = var.app-name
  subnet_ids = var.private-subnet-ids
  tags       = var.tags
}

# Add security group
resource "aws_security_group" "sg" {
  name = "${var.environment}-${var.app-name}-db"

  ingress {
    description     = "TCP from Fargate"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.fargate-security-group]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags   = var.tags
  vpc_id = var.vpc-id
}


