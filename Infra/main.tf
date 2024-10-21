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
  associate_public_ip_address = true  # Esta configuração é necessária para instâncias públicas
  vpc_security_group_ids      = [var.sg_id]

  tags = {
    Name = "analise-privada-ec2-01"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Cria a pasta aws
    mkdir -p /home/ubuntu/aws

    # Clonar ou atualizar o repositório
    if [ ! -d "/home/ubuntu/aws/.git" ]; then
      sudo git clone https://github.com/WillDantasJPG/Analise-Credito.git /home/ubuntu/aws
    else
      cd /home/ubuntu/aws
      sudo git pull origin main  # Atualiza o repositório
    fi

    # Instala o MySQL
    apt update
    apt install -y mysql-server

    # Instala Docker e Docker Compose
    apt update
    apt install -y docker.io

    # Baixar a versão mais recente do Docker Compose
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K[^\"]+')
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Atualiza pacotes e instala Java
    apt-get install -y default-jdk

    # Inicia e habilita o Docker
    systemctl start docker
    systemctl enable docker

    # Navega até o diretório do projeto
    cd /home/ubuntu/aws

    # Constrói a imagem Docker usando o Dockerfile
    docker build -t analise-backend .

    # Executa o Docker Compose para iniciar os serviços
    docker-compose up --build
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

    # Cria a pasta aws
    mkdir -p /home/ubuntu/aws

    # Clonar ou atualizar o repositório
    if [ ! -d "/home/ubuntu/aws/.git" ]; then
      sudo git clone https://github.com/WillDantasJPG/Analise-Credito.git /home/ubuntu/aws
    else
      cd /home/ubuntu/aws
      sudo git pull origin main  # Atualiza o repositório
    fi

    # Instala o MySQL
    apt update
    apt install -y mysql-server

    # Instala Docker e Docker Compose
    apt update
    apt install -y docker.io

    # Baixar a versão mais recente do Docker Compose
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K[^\"]+')
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Atualiza pacotes e instala Java
    apt-get install -y default-jdk

    # Inicia e habilita o Docker
    systemctl start docker
    systemctl enable docker

    # Navega até o diretório do projeto
    cd /home/ubuntu/aws

    # Constrói a imagem Docker usando o Dockerfile
    docker build -t nhyira-api .

    # Executa o Docker Compose para iniciar os serviços
    docker-compose up --build
EOF
  )
}

resource "aws_eip_association" "eip_assoc_01" {
  instance_id  = aws_instance.public_ec2_backend_1.id
  allocation_id = "eipalloc-05e0ad948c5b56541" # ID de alocação
}

resource "aws_eip_association" "eip_assoc_02" {
  instance_id   = aws_instance.private_ec2_backend_2.id
  allocation_id = "eipalloc-042a32f12eb8c5c62"  # ID de alocação
}

# API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = var.api_gateway_name
  description = "API para o serviço"
}

# Elastic Load Balancer
resource "aws_elb" "my_elb" {
  name               = var.elb_name
  availability_zone  = var.az

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

  instances = [aws_instance.public_ec2_backend_1.id]

  tags = {
    Name = var.elb_name
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = var.ecs_cluster_name
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
