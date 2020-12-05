variable "availability-zones" {
  type        = list(string)
  description = "A list of availability zones"
}

variable "cidr-block" {
  type        = string
  default     = "172.20.0.0/20"
  description = "The IP ranges of the VPC"
}

variable "environment" {
  description = "The environment to tag the ASG with"
  type        = string
}

variable "private-subnets" {
  type = list(string)
  default = [
    "172.20.0.0/23",
    "172.20.2.0/23",
    "172.20.4.0/23"
  ]
  description = "The private subnets of the VPC"
}

variable "public-subnets" {
  type = list(string)
  default = [
    "172.20.10.0/23",
    "172.20.12.0/23",
    "172.20.14.0/23"
  ]
  description = "The public subnets of the VPC"
}


variable "tags" {
  description = "The map of tags to use"
  type        = map(string)
}