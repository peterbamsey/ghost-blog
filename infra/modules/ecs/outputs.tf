output "container-name" {
  value = var.container-name
}

output "security-group-id" {
  value = aws_security_group.sg.id
}