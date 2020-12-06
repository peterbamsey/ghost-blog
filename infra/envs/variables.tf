variable "domain-name" {
  description = "The domain name including the TLD"
  type        = string
}

variable "environment" {
  description = "The environment - prod or staging"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "sub-domain" {
  description = "The subdomain of the DNS record"
  type        = string
}

