output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_service_name" {
  value = aws_ecs_service.analise_service.name
}


output "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = "subnet-09424067824895155"
}

output "security_group_id" {
 description = "Security Group ID"
   type        = string
   default     = "sg-08a6c790338e94c72"
}
