terraform {
  required_version = ">= 1.5"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "grapefruit-league"

    workspaces {
      prefix = "hetzner-"
    }
  }

  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}
