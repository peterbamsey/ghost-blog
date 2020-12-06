locals {
  tags = {
    "env" = var.environment
  }
  environment-variables = {
    logging = {
      path  = "blog/"
      level = "info"
      rotation = {
        enabled : true
        count : 15
        period : "1d"
      }
      transports = ["stdout"]
    }
  }
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
  ecr-repo-name             = "ghost"
  ecs-cluster-name          = "ghost"
  ecs-service-name          = "ghost"
  environment               = var.environment
  environment-variables     = null
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