variable "app-name" {
  description = "The name of the application to run in Fargate"
  type        = string
}

variable "environment" {
  description = "The environment that the module is instantiated in e.g prod or staging"
  type        = string
}

variable "sms-number" {
  description = "The mobile number to send text alerts to"
  type        = string
}