provider "aws" {
  profile                  = local.workspace["aws_profile"]
  region                   = local.workspace["aws_region"]
  shared_credentials_files = ["/home/appuser/.aws/credentials"]
}
