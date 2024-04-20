terraform {
  required_version = ">= 1.5"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "grapefruit-league"

    workspaces {
      prefix = "aws-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.30"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}
