locals {
  tags = {
    "env" = var.environment
  }
}

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