# Setup the ECR repo and access policy
resource "aws_ecr_repository" "repo" {
  encryption_configuration {
    encryption_type = "KMS"
  }
  name = var.ecr-repo-name
  tags = var.tags
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

# Create the ECS cluster and service
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs-cluster-name
}

resource "aws_ecs_service" "ecs" {
  cluster                           = aws_ecs_cluster.cluster.id
  depends_on                        = [aws_iam_role_policy.policy]
  desired_count                     = var.desired-count
  health_check_grace_period_seconds = var.grace-period
  #  iam_role        = aws_iam_role.role.arn
  launch_type     = "FARGATE"
  name            = var.ecs-service-name
  task_definition = aws_ecs_task_definition.td.arn

  load_balancer {
    target_group_arn = var.lb-target-group-arn
    container_name   = var.container-name
    container_port   = var.container-port
  }

  network_configuration {
    subnets          = var.private-subnet-ids
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = false
  }

  lifecycle {
    #    ignore_changes = [task_definition]
  }
}

# IAM Role and policy
resource "aws_iam_role" "role" {
  name               = "${var.environment}-${var.app-name}"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com",
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "template_file" "iam-policy" {
  template = file("${path.module}/files/container-iam-policy.json")
}

resource "aws_iam_role_policy" "policy" {
  name   = "${var.environment}-${var.app-name}-policy"
  policy = data.template_file.iam-policy.rendered
  role   = aws_iam_role.role.id
}

# Task definition
data "template_file" "td" {
  template = file("${path.module}/files/task-definition.json")
  vars = {
    app-name                  = var.app-name
    cloudwatch-log-group-name = aws_cloudwatch_log_group.log_group.name
    container-port            = var.container-port
    environment-variables     = jsonencode(var.environment-variables)
    image-url                 = var.image-url
    region                    = var.region
    secrets                   = jsonencode("{}")
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/aws/ecs/${var.environment}-${var.app-name}"
  tags = var.tags
}

resource "aws_ecs_task_definition" "td" {
  container_definitions    = data.template_file.td.rendered
  cpu                      = var.task-cpu
  execution_role_arn       = aws_iam_role.role.arn
  task_role_arn            = aws_iam_role.role.arn
  family                   = "${var.environment}-${var.app-name}"
  memory                   = var.task-memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  lifecycle {
    #    ignore_changes = [id, container_definitions]
  }
}

resource "aws_security_group" "sg" {
  name = "${var.environment}-${var.app-name}-ecs"

  ingress {
    description = "TLS from Internet"
    from_port   = var.container-port
    to_port     = var.container-port
    protocol    = "tcp"
    cidr_blocks = concat(var.private-subnets, var.public-subnets)
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
