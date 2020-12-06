output "vpc-cidr-block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc-id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private-subnets" {
  value = var.private-subnets
}

output "public-subnets" {
  value = var.public-subnets
}

output "private-subnet-ids" {
  value = aws_subnet.private.*.id
}

output "public-subnet-ids" {
  value = aws_subnet.public.*.id
}
