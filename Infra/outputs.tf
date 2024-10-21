output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_service_name" {
  value = aws_ecs_service.analise_service.name
}


output "subnet_id" {
  description = "Subnet ID"
  value       = "subnet-09424067824895155"  # Você pode usar uma variável ou referência de recurso aqui
}

output "security_group_id" {
  description = "Security Group ID"
  value       = "sg-08a6c790338e94c72"  # Você pode usar uma variável ou referência de recurso aqui
}

