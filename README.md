# opskwondo

Welcome to Opskwondo. A martial art involving keyboarding techniques to manage ops and infra. 🥋⌨️

## Introduction

This repository is a collection of tools and scripts showcasing various workflows including, but not limited to,
container development and testing, infrastructure management, and more! A multipurpose, Swiss Army knife container is
available (a.k.a. `dev_sak`) and needs to be running to have the playground ready.

## Prerequisites

- Docker version 25+ (older versions may work YMMV)
- Linux or macOS operating system. (probably Windows 🤷)
- A [Terraform Cloud](https://app.terraform.io/) account

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

```bash

1. Build and set up the local dev container:

    ```bash
    make dev/setup
    ```

2. Shell into the running local dev container:

    ```bash
    make dev/sh
    ```

3. Do all the things! 🧑‍💻

> [!TIP]
> Run `make help` to see all available targets.

