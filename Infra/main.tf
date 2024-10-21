terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"  # Corrigido para um região válida (ex: us-east-1)
}

# Instância EC2 pública
resource "aws_instance" "public_ec2_backend_1" {
  ami               = var.ami
  availability_zone = var.az
  instance_type    = var.inst_type

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 16
    volume_type = "gp3"
  }

  key_name                    = "ti_key"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id]

  tags = {
    Name = "analise-privada-ec2-01"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    mkdir -p /home/ubuntu/aws
    if [ ! -d "/home/ubuntu/aws/.git" ]; then
      sudo git clone https://github.com/WillDantasJPG/Analise-Credito.git /home/ubuntu/aws
    else
      cd /home/ubuntu/aws
      sudo git pull origin main
    fi
    # Instala o MySQL
    sudo apt update
    sudo apt install -y mysql-server

    # Instala Docker e Docker Compose
    sudo apt update
    sudo apt install -y docker.io

    # Atualiza pacotes e instala Java
    sudo apt-get install -y default-jdk

    # Dar permissão de execução ao binário
    sudo chmod +x /usr/local/bin/docker-compose

    # Verifique se a instalação foi bem-sucedida
    docker-compose --version

    # Inicia e habilita o Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # Navega até o diretório do projeto
    cd /home/ubuntu/aws

    # Constrói a imagem Docker usando o Dockerfile
    sudo docker build -t nhyira-api .

    # Executa o Docker Compose para iniciar os serviços
    sudo docker-compose up --build
  EOF
  )
}

# Instância EC2 privada
resource "aws_instance" "private_ec2_backend_2" {
  ami               = var.ami
  availability_zone = var.az
  instance_type    = var.inst_type

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 16
    volume_type = "gp3"
  }

  subnet_id                = var.subnet_id
  vpc_security_group_ids   = [var.sg_id]

  tags = {
    Name = "analise-privada-ec2-02"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    mkdir -p /home/ubuntu/aws
    if [ ! -d "/home/ubuntu/aws/.git" ]; then
      sudo git clone https://github.com/WillDantasJPG/Analise-Credito.git /home/ubuntu/aws
    else
      cd /home/ubuntu/aws
      sudo git pull origin main
    fi
    # Instala o MySQL
    sudo apt update
    sudo apt install -y mysql-server

    # Instala Docker e Docker Compose
    sudo apt update
    sudo apt install -y docker.io

    # Atualiza pacotes e instala Java
    sudo apt-get install -y default-jdk

    # Dar permissão de execução ao binário
    sudo chmod +x /usr/local/bin/docker-compose

    # Verifique se a instalação foi bem-sucedida
    docker-compose --version

    # Inicia e habilita o Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # Navega até o diretório do projeto
    cd /home/ubuntu/aws

    # Constrói a imagem Docker usando o Dockerfile
    sudo docker build -t nhyira-api .

    # Executa o Docker Compose para iniciar os serviços
    sudo docker-compose up --build
  EOF
  )
}


# Exemplo de API Gateway (removido os IAM roles)
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "my_api"
  description = "My API description"
}

# Exemplo de Load Balancer (removido os IAM roles)
resource "aws_elb" "my_elb" {
  name               = "MyNewLoadBalancer"
  availability_zones = [var.az]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "MyLoadBalancer"
  }
}

# Exemplo de SQS Queue (removido os IAM roles)
resource "aws_sqs_queue" "my_queue" {
  name = "MyQueue"
}

# Exemplo de Cognito User Pool (removido os IAM roles)
resource "aws_cognito_user_pool" "my_user_pool" {
  name = "MyUserPool"
}

# Criação de uma função Lambda
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler" # Nome do arquivo e da função
  runtime       = "nodejs14.x"     # Runtime do Lambda

  # O código pode ser enviado diretamente ou referenciando um arquivo zip em um bucket S3
  s3_bucket = "your-s3-bucket"
  s3_key    = "path/to/lambda.zip"

  # Configurações de timeout e memória
  timeout  = 10
  memory_size = 128
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}

# Criação de um cluster ECS
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my_ecs_cluster"
}

# Definição da tarefa ECS
resource "aws_ecs_task_definition" "my_ecs_task" {
  family                   = "my_task"
  requires_compatibilities = ["FARGATE"] # Ou EC2, dependendo de como você deseja executar

  network_mode = "awsvpc" # Necessário para Fargate

  container_definitions = jsonencode([
    {
      name      = "my_container"
      image     = "nginx"  # Imagem do contêiner
      memory    = 512       # Memória em MiB
      cpu       = 256       # CPU em unidades
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }]
    }
  ])
}

# Criação de um serviço ECS
resource "aws_ecs_service" "my_ecs_service" {
  name            = "my_ecs_service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_ecs_task.arn
  desired_count   = 1

  launch_type = "FARGATE" # Ou EC2

  network_configuration {
subnets          = [var.subnet_id]  # Usando a variável subnet_id
    security_groups  = [var.sg_id]      # Usando a variável sg_id
    assign_public_ip = true
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.my_ecs_cluster.name
}
