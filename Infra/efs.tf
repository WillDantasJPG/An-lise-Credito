resource "aws_efs_file_system" "my_efs" {
  creation_token = "mysql-data-efs"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "my_efs_mount" {
  file_system_id = aws_efs_file_system.my_efs.id
}
