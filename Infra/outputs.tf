output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_service_name" {
  value = aws_ecs_service.analise_service.name
}


output "vpc_id" {
  value = aws_vpc.my_vpc.id
}


output "subnet_ids" {
  value = aws_subnet.my_subnet[*].id
}

output "subnet_id" {
  value = var.subnet_id
}

output "security_group_id" {
  value = var.sg_id
}
