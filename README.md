# Ghost Blog Project

### What is it?
This repository provides all the necessary tooling to deploy an instance of the [Ghost](https://ghost.org/) CMS on 
Amazon Web Services. 

### What does it do?
This repository will use Hashicorp's [Terraform](https://www.terraform.io/) tool to deploy all the architecture required
to run an enterprise ready CMS.  The Terraform code will create the following:

* VPC, Subnets, Internet Gateway, NAT Gateways
* Route 53 records, TLS Certificate, Application Load Balancers, Security Groups
* An Elastic Container Service, Task Definition to run the community maintained [Docker image](https://hub.docker.com/_/ghost)
of of the Ghost CMS

For more information on the infrastructure configuration, see the diagram below.

![Ghost Blog Project](https://github.com/peterbamsey/ghost-blog/blob/main/diagram/ghost-blog.drawio.jpg "Ghost Blog Project")

### How?
The entire stack, including public DNS records can be deployed directly from your computer.

#### Prerequisites
* The Terraform cli installed locally.  This has been tested with v0.13.5
* An AWS account with an AWS IAM user with Admin level privileges with an [access and secret key configured](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
* A DNS domain registered with [Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/getting-started.html#getting-started-find-domain-name)

#### Config
* Clone the repo locally `git clone git@github.com:peterbamsey/ghost-blog.git`
* Open the terraform.sh.default file and enter your AWS Access and Secret keys as well as the target AWS region
````shell script
export AWS_ACCESS_KEY_ID="your_access_key_here"
export AWS_SECRET_ACCESS_KEY="your_secret_access_key_here"
export AWS_DEFAULT_REGION="target_aws_region"
````
* Save the file as `terraform.sh`
* Open `prod.tfvars.default` and enter your Route53 managed domain name and target AWS region.  The sub-domain and
environment parameters can stay as default
````
region      = "eu-west-1"
domain-name = "yourdomain.com"
sub-domain  = "blog"
environment = "prod"

````
* Save the file as `prod.tfvars`
* Execute the `terraform.sh` script with `./terraform "prod"` from the command line.
* You will be prompted to confirm the changes that Terraform will make. Type `yes` at the prompt.
* Wait a for the Terraform run to complete. After local DNS servers have updated your new blog site should be at
[https://blog.yourdomain.com](https://blog.yourdomain.com)
* To destroy the infrastructure and blog site so you are no longer charged, uncomment the last line in the terraform.sh
file and re-run the script
```shell script
# Uncomment the line below line to destroy the stack
#terraform destroy -var-file="${ENVIRONMENT}.tfvars"
```

#### Scaling the instances
This project is configured to allow horizontal scaling of both the application and database tiers.
To scale the application tier change the  default value of the `number-of-applicaiton-instances` variable.
```hcl-terraform
variable "number-of-application-instances" {
  default = 1
  description = "The number of ECS Fargate tasks to run concurrnetly. Used for horizontal scaling of the application tier"
  type = number
}
```
To scale the database tier change the default value of the ``
```hcl-terraform

variable "number-of-db-instances" {
  default = 2
  description = "The number of RDS read replica instances to run concurrently.  Use for horizontal sclaing of the db tier"
  type = number
}

```

To improve this configuration we would create an autosclaing configuration for both the ECS Fargate task and the RDS Aurora 
service which automatically scales the instances based on a predefined metric.

#### Monitoring
This project creates a very basic example monitoring dashboard in AWS Cloudwatch.  It uses metric widgets to display 
basic information about the application.  The Dashboard name is `prod-ghost`.

We can improve this considerably by templating the metric widgets and dashbaords to make the module more reusable.

#### Alerting
This project creates a very basic alerting system by utilising Cloudwatch Alarms and an SNS topic.  When the ECS instances
go above a certain CPU utilisation, an alarm triggers that pushes a message to the SNS topic and sends an SMS message to
the number defined in:
```hcl-terraform
variable "sms-number" {
  description = "The number to send alarms to"
  type = string
  default = "+44012345678910"
}
```

This module is currently unfinished, though the foundations are present.
