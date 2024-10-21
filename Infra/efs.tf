resource "aws_efs_file_system" "my_efs" {
  creation_token = "my-efs-file-system-${timestamp()}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "my_efs_mount" {
  file_system_id  = aws_efs_file_system.my_efs.id
  subnet_id       = "subnet-0123456789abcdef0"
  security_groups  = ["sg-0123456789abcdef0"]
}
