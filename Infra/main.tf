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
    apt update
    apt install -y mysql-server docker.io default-jdk
    systemctl start docker
    systemctl enable docker
    cd /home/ubuntu/aws
    docker build -t analise-backend .
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
    mkdir -p /home/ubuntu/aws
    if [ ! -d "/home/ubuntu/aws/.git" ]; then
      sudo git clone https://github.com/WillDantasJPG/Analise-Credito.git /home/ubuntu/aws
    else
      cd /home/ubuntu/aws
      sudo git pull origin main
    fi
    apt update
    apt install -y mysql-server docker.io default-jdk
    systemctl start docker
    systemctl enable docker
    cd /home/ubuntu/aws
    docker build -t nhyira-api .
    docker-compose up --build
EOF
  )
}

resource "aws_eip_association" "eip_assoc_01" {
  instance_id  = aws_instance.public_ec2_backend_1.id
  allocation_id = "eipalloc-05e0ad948c5b56541"
}

resource "aws_eip_association" "eip_assoc_02" {
  instance_id   = aws_instance.private_ec2_backend_2.id
  allocation_id = "eipalloc-042a32f12eb8c5c62"
}

# API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = var.api_gateway_name
  description = "API para o serviço"
}

resource "aws_elb" "my_elb" {
  name               = "MyNewLoadBalancer" // Verifique se o nome já existe
  availability_zones = ["us-east-1a", "us-east-1b"] // Adicione suas zonas de disponibilidade

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
