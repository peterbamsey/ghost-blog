variable "app-name" {
  description = "The application name"
  type        = string
}

variable "availability-zones" {
  type        = list(string)
  description = "A list of availability zones"
}

variable "database-name" {
  description = "The name of the database schema"
  type        = string
}

variable "environment" {
  description = "The environment that the module is instantiated in e.g prod or staging"
  type        = string
}

variable "fargate-security-group" {
  description = "The SG of the Fargate task"
  type        = string
}

variable "instance-class" {
  default     = "db.t3.small"
  description = "The RDS instance size"
  type        = string
}

variable "master-password" {
  description = "The master database password"
  type        = string
}

variable "master-username" {
  description = "The master username for the RDS instance"
  type        = string
}

variable "number-of-instances" {
  default     = 1
  description = "The number of RDS instances"
  type        = number
}

variable "private-subnet-ids" {
  type        = list(string)
  description = "The private subnets of the VPC"
}

variable "tags" {
  description = "The AWS tags"
  type        = map(string)
}

variable "vpc-id" {
  description = "The ID of the VPC"
  type        = string
}
