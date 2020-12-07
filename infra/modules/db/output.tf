output "cluster-endpoint-rw" {
  value = aws_rds_cluster.cluster.endpoint
}

output "master-user" {
  value = var.master-username
}

output "master-password" {
  value = var.master-password
}