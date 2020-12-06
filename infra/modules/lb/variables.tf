variable "app-name" {
  description = "The name of the application to run in Fargate"
  type        = string
}

variable "domain-name" {
  description = "The public domain in which to create certificates"
  type        = string
}

variable "environment" {
  description = "The environment that the module is instantiated in e.g prod or staging"
  type        = string
}

variable "lb-type" {
  default     = "application"
  description = "The type of load balancer"
  type        = string
}

variable "listener-port" {
  default     = 443
  description = "The port that the load balancer listens on"
  type        = number
}

variable "listener-protocol" {
  default     = "HTTPS"
  description = "The protocol that the load balancer expects"
  type        = string
}

variable "protocol" {
  default     = "HTTP"
  description = "The protocol to use for the target group"
  type        = string
}

variable "ssl-policy" {
  default     = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  description = "The latest SSL policy for the ACM TLS cert"
  type        = string
}

variable "sub-domain" {
  description = "The subdomain to add to the ACM subject alternative domain certificate e.g. blog from blog.example.com"
  type        = string
}

variable "subnets" {
  description = "The subnets that the LB will be created in"
  type        = list(string)
}

variable "target-port" {
  default     = 2368
  description = "The port that will accept traffic on the target instance"
  type        = number
}

variable "target-type" {
  default     = "ip"
  description = "The target type - HTTP or IP"
  type        = string
}

variable "tags" {
  description = "The AWS tags"
  type        = map(string)
}

variable "target-id" {
  description = "The instance IP or container ID to target"
  type        = string
}

variable "vpc-id" {
  description = "The ID of the VPC"
  type        = string
}

