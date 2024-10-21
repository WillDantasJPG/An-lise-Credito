
resource "aws_efs_mount_target" "mysql_data_mount" {
  file_system_id   = aws_efs_file_system.mysql_data.id
  subnet_id        = "subnet-09424067824895155"
  security_groups  = ["sg-0123456789abcdef0"]
}
