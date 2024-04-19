variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "http_protocol" {
  type    = string
  default = "http"
}

variable "http_port" {
  type    = number
  default = "80"
}

variable "instances" {
  type    = number
  default = "1"
}

variable "server_type" {
  type    = string
  default = "cax11"
}

variable "os_type" {
  type    = string
  default = "ubuntu-22.04"
}

variable "disk_size" {
  type    = number
  default = "40"
}

variable "ip_range" {
  type    = string
  default = "10.0.1.0/24"
}
