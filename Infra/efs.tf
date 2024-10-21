resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-file-system"  # Nome único para o sistema de arquivos
  performance_mode = "generalPurpose"      # Modo de desempenho
}

resource "aws_efs_mount_target" "mysql_data_mount" {
  file_system_id = aws_efs.my_efs.id      # ID do sistema de arquivos EFS
  subnet_id      = output.subnet_id.value  # ID da sua subnet
  security_groups = [output.security_group_id.value]  # Grupo de segurança
}

resource "aws_efs_mount_target" "my_efs_mount" {
  file_system_id = aws_efs.my_efs.id      # ID do sistema de arquivos EFS
  subnet_id      = output.subnet_id.value  # ID da sua subnet
  security_groups = [output.security_group_id.value]  # Grupo de segurança
}
