variable "allow_ip" {
  type = string
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_name" {
  type = string
}

variable "sftpgo_db_name" {
  type    = string
  default = "sftpgo"
}

variable "sftpgo_db_user" {
  type    = string
  default = "sftpgo_admin"
}
