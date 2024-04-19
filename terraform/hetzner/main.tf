terraform {
  required_version = ">= 1.5"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "grapefruit-league"

    workspaces {
      name = "hetzner-demo"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}
