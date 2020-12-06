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


