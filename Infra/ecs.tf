

resource "aws_ecs_task_definition" "analise_task" {
  family                   = "analise_task"
  network_mode             = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
      name      = "mysql"
      image     = "mysql:8.0.37"
      essential = true
      portMappings = [{
        containerPort = 3306
        hostPort      = 3306  # Deve ser igual ao containerPort
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "MYSQL_ROOT_PASSWORD"
          value = "will@123"  # Considere usar um gerenciador de segredos
        },
        {
          name  = "MYSQL_DATABASE"
          value = "analiseDB"
        }
      ]
      mountPoints = [{
        sourceVolume  = "mysql_data"
        containerPath = "/var/lib/mysql"
      }]
    },
    {
      name      = "analise-backend"
      image     = "analise-backend_1"  # Altere para o seu nome de imagem do backend
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080  # Deve ser igual ao containerPort
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "SPRING_APPLICATION_NAME"
          value = "servico-credito"
        },
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:mysql://mysql:3306/analiseDB"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = "root"
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = "will@123"  # Considere usar um gerenciador de segredos
        },
        {
          name  = "SPRING_DATASOURCE_DRIVER_CLASS_NAME"
          value = "com.mysql.cj.jdbc.Driver"
        },
        {
          name  = "SPRING_JPA_DEFER_DATASOURCE_INITIALIZATION"
          value = "true"
        },
        {
          name  = "SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT"
          value = "org.hibernate.dialect.MySQLDialect"
        },
        {
          name  = "SPRING_JPA_SHOW_SQL"
          value = "true"
        },
        {
          name  = "MERCADO_PAGO_ACCESS_TOKEN"
          value = "APP_USR-824007135770533-052015-ba3b308de0439bc6e6ad15c2c6152ca6-1722687388"  # Considere usar um gerenciador de segredos
        }
      ]
    }
  ])

  volume {
    name = "mysql_data"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.mysql_data.id  # Removido `count.index`
    }
  }
}


resource "aws_efs_mount_target" "mysql_data_mount" {
  file_system_id   = aws_efs_file_system.mysql_data.id  # Removido `count.index`
  subnet_id        = "subnet-09424067824895155"         # Substitua pelo ID da sua sub-rede
  security_groups  = ["sg-0123456789abcdef0"]           # Substitua pelo ID do seu grupo de segurança
}
