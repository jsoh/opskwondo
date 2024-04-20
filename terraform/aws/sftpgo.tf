# EC2
resource "aws_instance" "sftpgo" {
  ami                         = "ami-08a4226735d7b809b" # ubuntu 22.04 LTS
  instance_type               = local.workspace["sftpgo_ec2_instance_type"]
  key_name                    = "sftpgo_ssh_key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sftpgo.id]
  subnet_id                   = aws_subnet.sftpgo_public[local.workspace["sftpgo_availability_zone"]].id
  availability_zone           = local.workspace["sftpgo_availability_zone"]

  // Instance profile with EC2 instance permission to access S3 bucket
  iam_instance_profile = aws_iam_instance_profile.sftpgo.name

  user_data = templatefile("templates/user_data_script.tpl", {
    aws_s3_bucket_name = aws_s3_bucket.sftpgo.id
    aws_s3_region      = local.workspace["aws_region"]
    cf_dns_api_token   = var.cloudflare_api_token
    sftpgo_db_host     = aws_db_instance.sftpgo_rds.address
    sftpgo_db_name     = var.sftpgo_db_name
    sftpgo_db_pass     = random_password.sftpgo_rds.result
    sftpgo_db_user     = var.sftpgo_db_user
    sftpgo_hostname    = "${local.workspace["dns_record_name"]}.${local.cloudflare_zone_name}"
  })

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true # Use default KMS key for encryption
  }

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}-server"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }

  depends_on = [
    aws_s3_bucket.sftpgo,
    random_password.sftpgo_rds
  ]
}

resource "aws_ebs_volume" "sftpgo" {
  availability_zone = local.workspace["sftpgo_availability_zone"]
  size              = 50 # Size in GB
  type              = "gp3"
  encrypted         = true # Use default KMS key for encryption

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

resource "aws_volume_attachment" "sftpgo" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.sftpgo.id
  instance_id = aws_instance.sftpgo.id
}

# Dedicated EIP for instance
resource "aws_eip" "sftpgo" {
  instance = aws_instance.sftpgo.id

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

resource "aws_eip_association" "sftpgo" {
  instance_id   = aws_instance.sftpgo.id
  allocation_id = aws_eip.sftpgo.id
}

# IAM role and user
resource "aws_iam_instance_profile" "sftpgo" {
  name = "sftpgo-${local.workspace["environment"]}-instance-profile"
  role = aws_iam_role.sftpgo.name
}

resource "aws_iam_role" "sftpgo" {
  name = "sftpgo-${local.workspace["environment"]}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sftpgo" {
  role       = aws_iam_role.sftpgo.name
  policy_arn = aws_iam_policy.sftpgo_ec2.arn
}

// Attachment of AWS managed policy AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "sftpgo_ssm" {
  role       = aws_iam_role.sftpgo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "sftpgo_ec2" {
  name        = "sftpgo-${local.workspace["environment"]}-s3-policy"
  description = "sftpgo access to ${local.workspace["environment"]} sftpgo bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.sftpgo.arn,
          "${aws_s3_bucket.sftpgo.arn}/*"
        ]
      }
    ]
  })
}
