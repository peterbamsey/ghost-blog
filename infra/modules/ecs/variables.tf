variable "app-name" {
  description = "The name of the application to run in Fargate"
  type        = string
}

variable "cloudwatch-log-group-name" {
  description = "The name of the Cloudwatch log group to send logs to"
  type        = string
}

variable "container-name" {
  description = "The name of the container running in the task"
  type        = string
}

variable "command" {
  default     = ""
  description = "The CMD or ENTRYPOINT of the container"
  type        = string
}

variable "container-port" {
  description = "The listening port of the container"
  type        = number
}

variable "desired-count" {
  default     = 1
  description = "The number of instances of the Fargate task to run"
  type        = number
}

variable "ecs-cluster-name" {
  description = "The ECS cluster name"
  type        = string
}

variable "ecs-service-name" {
  description = "The ECS service name"
  type        = string
}

variable "ecr-repo-name" {
  description = "The ECR repo name"
  type        = string
}

variable "environment" {
  description = "The environment that the module is instantiated in e.g prod or staging"
  type        = string
}

variable "environment-variables" {
  description = "The environment variables to pass to the container"
  type        = map(string)
}

variable "grace-period" {
  default     = 90
  description = "The number of seconds the task has before LB health check starts"
  type        = number
}

variable "image-url" {
  description = "The URL of the container image"
  type        = string
}

variable "lb-target-group-arn" {
  description = "The ARN of the Target Group for the load balancer that forwards traffic to this instance"
  type        = string
}

variable "private-subnet-ids" {
  description = "The private subnets to launch the task in to"
  type        = list(string)
}

variable "private-subnets" {
  description = "The CIDR blocks of the private subnets"
  type        = list(string)
}

variable "public-subnets" {
  description = "The CIDR blocks of the public subnets"
  type        = list(string)
}

variable "region" {
  description = "The AWS Region"
  type        = string
}

variable "secrets" {
  description = "The secrets to pass to the container"
  type        = map(string)
}

variable "tags" {
  description = "The AWS tags"
  type        = map(string)
}

variable "task-cpu" {
  description = "The number of CPU units used by this task"
  default     = 1024
  type        = number
}

variable "task-memory" {
  description = "The number of memory unites used by this task"
  default     = 2048
  type        = number
}

variable "vpc-id" {
  description = "The VPC ID"
  type        = string
}
