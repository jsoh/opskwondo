# opskwondo

Welcome to Opskwondo. A martial art involving keyboarding techniques to manage ops and infra. 🥋⌨️

## Introduction

This repository is a collection of tools and scripts showcasing various workflows including, but not limited to,
container development and testing, infrastructure management, and more! A multipurpose, Swiss Army knife container is
available (a.k.a. `dev_sak`) and needs to be running to have the playground ready.

## Prerequisites

- Docker version 25+ (older versions may work YMMV)
- Linux or macOS operating system. (probably Windows 🤷)

## Installation and Setup

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
