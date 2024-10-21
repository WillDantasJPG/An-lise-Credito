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
  region = "us-east-1" # ou a região que você está usando
}

# Define o par de chaves (opcional)
# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_pair_name
#   public_key = file("${path.module}/tf_key.pem.pub")
# }

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

  key_name                    = "ti_key"
  subnet_id                   = var.subnet_id # Subnet privada
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.sg_id]

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


# API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = var.api_gateway_name
  description = "API para o serviço"
}

# Load Balancer
resource "aws_elb" "my_elb" {
  name               = "MyNewLoadBalancer" # Verifique se o nome já existe
  availability_zones = ["us-east-1a", "us-east-1b"] # Adicione suas zonas de disponibilidade

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
    Name = "MyNewLoadBalancer"
  }
}

# SQS Queue
resource "aws_sqs_queue" "my_queue" {
  name = var.sqs_queue_name
}

# Cognito User Pool
resource "aws_cognito_user_pool" "my_user_pool" {
  name = var.cognito_user_pool_name
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "my_client" {
  name         = var.cognito_client_name
  user_pool_id = aws_cognito_user_pool.my_user_pool.id
  generate_secret = false
}

# Função Lambda
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  handler       = "index.handler"
  runtime       = "nodejs14.x" # ou a versão que você preferir
  role          = aws_iam_role.lambda_exec.arn
  filename      = "path/to/your/lambda.zip" # Substitua pelo caminho do seu pacote zip

  environment {
    variables = {
      MY_ENV_VARIABLE = var.my_env_variable # Usando a variável que você definiu
    }
  }

  tags = {
    Name = "MyLambdaFunction"
  }
}


# Role para a função Lambda
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

# Policy para a função Lambda
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}
