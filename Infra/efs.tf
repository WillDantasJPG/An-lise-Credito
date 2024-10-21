resource "aws_efs_file_system" "mysql_data" {
  creation_token = "mysql-data-efs"  # Um identificador único para o sistema de arquivos
  performance_mode = "generalPurpose"  # Ou "maxIO" dependendo do seu caso de uso

  tags = {
    Name = "MySQLDataEFS"
  }
}

resource "aws_efs_mount_target" "mysql_data_mount" {
  file_system_id   = aws_efs_file_system.mysql_data.id
  subnet_id        = "subnet-09424067824895155"  # Substitua pelo ID da sua sub-rede
  security_groups  = ["sg-0123456789abcdef0"]    # Substitua pelo ID do seu grupo de segurança
}
