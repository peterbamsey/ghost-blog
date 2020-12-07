locals {
  tags = {
    "env" = var.environment
  }
  app-name = "ghost"

  # Database environment variables
  environment-variables = [
    {
      name  = "url"
      value = "https://${var.sub-domain}.${var.domain-name}"
    },

    {
      name  = "database__client"
      value = "mysql"
    },
    {
      name  = "database__connection__host"
      value = module.db.cluster-endpoint-rw
    },
    {
      name  = "database__connection__port"
      value = "3306"
    },
    {
      name  = "database__connection__user"
      value = module.db.master-user
    },
    {
      name  = "database__connection__password"
      value = module.db.master-password
    },
    {
      name  = "database__connection__database"
      value = "ghost"
    }
  ]
}

# The the availability zones
data "aws_availability_zones" "azs" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Create the networking
module "networking" {
  source             = "../modules/networking"
  availability-zones = data.aws_availability_zones.azs.names
  environment        = var.environment
  tags               = local.tags
}

# Create ECS infra
module "ecs" {
  source                    = "../modules/ecs"
  app-name                  = "ghost"
  cloudwatch-log-group-name = "/aws/ecs/${var.environment}-ghost"
  container-name            = "ghost"
  container-port            = 2368
  desired-count             = var.number-of-application-instances
  ecr-repo-name             = "ghost"
  ecs-cluster-name          = "ghost"
  ecs-service-name          = "ghost"
  environment               = var.environment
  environment-variables     = local.environment-variables
  image-url                 = "ghost"
  lb-target-group-arn       = module.load-balancer.target-group-arn
  private-subnet-ids        = module.networking.private-subnet-ids
  private-subnets           = module.networking.private-subnets
  public-subnets            = module.networking.public-subnets
  region                    = var.region
  secrets                   = null
  tags                      = local.tags
  vpc-id                    = module.networking.vpc-id
}

# Create a load balancer
module "load-balancer" {
  source      = "../modules/lb"
  app-name    = "ghost"
  environment = var.environment
  subnets     = module.networking.public-subnet-ids
  tags        = local.tags
  target-id   = module.ecs.container-name
  vpc-id      = module.networking.vpc-id
  domain-name = var.domain-name
  sub-domain  = var.sub-domain
}

# Create a RDS instance
module "db" {
  source                 = "../modules/db"
  app-name               = "ghost"
  availability-zones     = data.aws_availability_zones.azs.names
  database-name          = "ghost"
  master-username        = "master"
  master-password        = "rootroot!!!"
  number-of-instances    = var.number-of-db-instances
  private-subnet-ids     = module.networking.private-subnet-ids
  tags                   = local.tags
  environment            = var.environment
  fargate-security-group = module.ecs.security-group-id
  vpc-id                 = module.networking.vpc-id
}

module "monitoring" {
  source      = "../modules/monitoring"
  app-name    = local.app-name
  environment = var.environment
}

module "alerting" {
  source = "../modules/alerting"

  app-name    = local.app-name
  environment = var.environment
  sms-number  = var.sms-number
}