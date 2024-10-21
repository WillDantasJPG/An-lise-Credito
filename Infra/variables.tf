variable "api_gateway_name" {
  description = "Nome do API Gateway"
  type        = string
  default     = "MyApiGateway"
}

variable "elb_name" {
  description = "Nome do Elastic Load Balancer"
  type        = string
  default     = "MyLoadBalancer"
}

variable "ecs_cluster_name" {
  description = "Nome do Cluster ECS"
  type        = string
  default     = "MyEcsCluster"
}

variable "efs_ids" {
  description = "List of existing EFS IDs"
  type        = list(string)
  default     = []
}


variable "sqs_queue_name" {
  description = "Nome da fila SQS"
  type        = string
  default     = "MyQueue"
}

variable "cognito_user_pool_name" {
  description = "Nome do User Pool do Cognito"
  type        = string
  default     = "MyUserPool"
}

variable "cognito_client_name" {
  description = "Nome do cliente Cognito"
  type        = string
  default     = "MyCognitoClient"
}

variable "az" {
  description = "Availability Zone"
  type        = string
  default     = "us-east-1d"
}

variable "key_pair_name" {
  description = "Key Pair Name"
  type        = string
  default     = "tf_key"
}

variable "efs_ids" {
  description = "List of existing EFS IDs."
  type        = list(string)
  default     = []  # Defina um valor padrão ou deixe vazio se necessário
}


variable "ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-048c8cb78e7408897"  # O ID da AMI

}

variable "inst_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.medium"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
  default     = "subnet-09424067824895155"
}

variable "sg_id" {
  description = "Security Group ID"
  type        = string
  default     = "sg-08a6c790338e94c72"
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
}

variable "snapshot_id" {
  default = "snap-0d20b4350b63ed2ee"
  description = "Snapshot ID Backend"
 type  =string
}