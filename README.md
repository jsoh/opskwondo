# opskwondo

Welcome to Opskwondo. A martial art involving keyboarding techniques to manage ops and infra. 🥋⌨️

## Introduction

This repository is a collection of tools and scripts showcasing various workflows including, but not limited to,
container development and testing, infrastructure management, and more! A multipurpose, Swiss Army knife container is
available (a.k.a. `dev_sak`) and needs to be running to have the playground ready.

## Prerequisites

- Docker version 25+ (older versions may work YMMV)
- Linux or macOS operating system. (probably Windows 🤷)
- A [Terraform Cloud](https://app.terraform.io/) account (optional)
- A [Cloudflare](https://www.cloudflare.com/) account (optional)

Although a Terraform Cloud account is optional, it is recommended to use it for managing remote state and running.
Otherwise changes have to be made to store tfstate locally.

The Cloudflare account is also optional, but it is used in the AWS demo workspace to automatically provision DNS records.

## Installation and Setup

### Setting up Terraform Cloud

Log in to your Terraform Cloud account
to [generate an API token](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/api-tokens).
Run the following command to configure your local Terraform setup:

 ```bash
 make tfcloud/config
 ```

### Setting up the local development environment

In order to have a consistent development environment and experience across all devices, a local development container
is provided.

1. Copy the `.env.dist` file to `.env` and update the respective values as required.

    ```bash
    cp .env.dist .env
    ```

2. Build and set up the local dev container:

    ```bash
    make dev/setup
    ```

3. Shell into the running local dev container:

    ```bash
    make dev/sh
    ```

4. Do all the things! 🧑‍💻

> [!TIP]
> Run `make help` to see all available targets.

## Demo Workspaces

### AWS

This workspace contains a simple AWS infrastructure setup using Terraform. The setup includes commonly used resources
including a VPC, subnets, security groups, an EC2 instance, an RDS instance, and an S3 bucket. It also includes a
configuration to provision an Elastic IP and create DNS records in Cloudflare to automatically point to the new server.

This demo showcases a docker deployment that runs a simple [SFTPGo](https://github.com/drakkan/sftpgo) service with
automatic SSL provisioning via Let's Encrypt using [Traefik](https://github.com/traefik/traefik) as a load balancer and
reverse proxy.

The workspace is available in the `terraform/aws` directory.

### Hetzer Cloud

Another alternative cloud provider with a simple infrastructure setup using Terraform. The setup includes subnets,
loadbalancers, and a VM instance where node count is configurable.

The workspace is available in the `terraform/hetzner` directory.
