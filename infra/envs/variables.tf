variable "domain-name" {
  description = "The domain name including the TLD"
  type        = string
}

variable "environment" {
  description = "The environment - prod or staging"
  type        = string
}

variable "number-of-application-instances" {
  default = 2
  description = "The number of ECS Fargate tasks to run concurrnetly. Used for horizontal scaling of the application tier"
  type = number
}

variable "number-of-db-instances" {
  default = 2
  description = "The number of RDS read replica instances to run concurrently.  Use for horizontal sclaing of the db tier"
  type = number
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "sms-number" {
  description = "The number to send alarms to"
  type = string
  default = "+44012345678910"
}

variable "sub-domain" {
  description = "The subdomain of the DNS record"
  type        = string
}

