resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-file-system-${timestamp()}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "my_efs_mount" {
  count           = length(var.efs_ids) // Para garantir que você não tenta criar um mount para um EFS que já existe
  file_system_id  = var.efs_ids[count.index]
  subnet_id       = "subnet-09424067824895155" // Sua sub-rede válida
  security_groups = ["sg-08a6c790338e94c72"] // Seu grupo de segurança válido
}
