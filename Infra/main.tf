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
  region = "us-east-1d"  # Corrigido para uma região válida (ex: us-east-1)
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

  key_name                 = "ti_key"
  subnet_id                = var.private_subnet_id
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
# Grupo de Segurança
resource "aws_security_group" "sg" {
  name        = "sg-analise"
  description = "Grupo de Segurança para a aplicação"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Permite todo o tráfego
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Elastic Load Balancer (ELB)
resource "aws_elb" "application_load_balancer" {
  name               = "my-app-elb"
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
    Name = "my-app-elb"
  }
}

# Sistema de Arquivos (EFS)
resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs"

  tags = {
    Name = "my-efs"
  }
}

# Montagem do EFS
resource "aws_efs_mount_target" "my_efs_mount_target" {
  file_system_id = aws_efs_file_system.my_efs.id
  subnet_id      = var.private_subnet_id

  security_groups = [aws_security_group.sg.id]
}

# API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "My API Gateway"
}

resource "aws_api_gateway_resource" "my_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Função Lambda
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  handler       = "index.handler"  # Ajuste conforme seu código
  runtime       = "nodejs14.x"      # Ajuste o runtime conforme necessário

  s3_bucket     = "my_lambda_bucket" # Nome do bucket S3 onde o .zip da função está armazenado
  s3_key        = "my_lambda_function.zip" # Nome do arquivo .zip

  # Não há configurações IAM aqui
}

# Outputs
output "public_ip" {
  value = aws_instance.public_ec2_backend_1.public_ip
}

output "private_ip" {
  value = aws_instance.private_ec2_backend_2.private_ip
}

output "efs_id" {
  value = aws_efs_file_system.my_efs.id
}

output "api_gateway_url" {
  value = aws_api_gateway_rest_api.my_api.invoke_url
}
