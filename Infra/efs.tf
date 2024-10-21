resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-file-system"  # Nome único para o sistema de arquivos
  performance_mode = "generalPurpose"      # Modo de desempenho

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "my_efs_mount" {
  file_system_id = aws_efs_file_system.my_efs.id  # ID do sistema de arquivos EFS
     subnet_id      = "subnet-0123456789abcdef0"  # Substitua pelo ID da sua sub-rede
     security_groups = ["sg-0123456789abcdef0"]    # Substitua pelo ID do seu grupo de segurança
}
