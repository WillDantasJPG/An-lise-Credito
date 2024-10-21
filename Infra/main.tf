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
  region = "us-east-1"
}

# Variável para a Subnet Privada
variable "private_subnet_id" {
  description = "Private Subnet ID"
  type        = string
  default     = "subnet-09424067824895155"
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

  key_name                    = var.key_pair_name
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
    sudo apt install -y docker.io

    # Atualiza pacotes e instala Java
    sudo apt-get install -y default-jdk

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

# Instância EC2 privada (mantida para testes futuros)
resource "aws_instance" "private_ec2_backend_2" {
  ami               = var.ami
  availability_zone = var.az
  instance_type    = var.inst_type

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 16
    volume_type = "gp3"
  }

  key_name               = var.key_pair_name
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.sg_id]

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
    sudo apt install -y docker.io

    # Atualiza pacotes e instala Java
    sudo apt-get install -y default-jdk

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

# Removido Elastic Load Balancer (ELB) para evitar problemas
# Removido Sistema de Arquivos (EFS) para evitar problemas
# Removido IAM Role para Lambda e Função Lambda (se não forem necessários)

output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.my_api.id}.execute-api.${var.region}.amazonaws.com/prod/items"
}
