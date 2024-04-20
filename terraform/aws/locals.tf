locals {
  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_zone_name = var.cloudflare_zone_name

  aws_region_short_name = join("", regex("(\\w{2})-(\\w{1})\\w+-(\\d{1})", data.aws_region.current.name))

  workspaces = {

    default = {
      name        = "default"
      environment = terraform.workspace

      # AWS
      aws_profile = "default"
      aws_region  = "us-west-2"

      # SFTPgo configuration
      sftpgo_availability_zone = "us-west-2a"
      sftpgo_ec2_instance_type = "t2.micro"
      sftpgo_s3_bucket_prefix  = "jsoh-io-sftpgo"
      sftpgo_vpc_cidr_block    = "10.0.0.0/16"

      sftpgo_public_subnet_cidr_blocks = {
        "us-west-2a" = "10.0.1.0/24"
        "us-west-2b" = "10.0.2.0/24"
        "us-west-2c" = "10.0.3.0/24"
      }

      # RDS configuration
      rds_engine_version         = "16.1"
      rds_instance_class         = "db.t4g.micro"
      rds_parameter_group_family = "postgres16"

      dns_record_name = "default-sftp"
    }

    # Test environment overrides
    test = {
      name = "test"

      # SFTPgo configuration
      sftpgo_ec2_instance_type = "t2.small"
      sftpgo_vpc_cidr_block    = "10.1.0.0/16"

      sftpgo_public_subnet_cidr_blocks = {
        "us-west-2a" = "10.1.1.0/24"
        "us-west-2b" = "10.1.2.0/24"
        "us-west-2c" = "10.1.3.0/24"
      }

      # RDS configuration
      rds_instance_class = "db.t4g.small"

      dns_record_name = "test-sftp"
    }

    # Demo environment overrides
    demo = {
      name = "demo"

      # SFTPgo configuration
      sftpgo_vpc_cidr_block = "10.2.0.0/16"

      sftpgo_public_subnet_cidr_blocks = {
        "us-west-2a" = "10.2.1.0/24"
        "us-west-2b" = "10.2.2.0/24"
        "us-west-2c" = "10.2.3.0/24"
      }

      dns_record_name = "demo-sftp"
    }
  }

  # Merge to coalesce environment configurations
  workspace = merge(local.workspaces["default"], local.workspaces[terraform.workspace])
}
