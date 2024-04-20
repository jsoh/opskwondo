output "rds_password" {
  value     = random_password.sftpgo_rds.result
  sensitive = true
}
