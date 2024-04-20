resource "aws_s3_bucket" "sftpgo" {
  bucket = "${local.workspace["sftpgo_s3_bucket_prefix"]}-${local.aws_region_short_name}-${local.workspace["environment"]}"

  tags = {
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

resource "aws_s3_bucket_ownership_controls" "sftpgo" {
  bucket = aws_s3_bucket.sftpgo.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "sftpgo" {
  bucket = aws_s3_bucket.sftpgo.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.sftpgo
  ]
}

resource "aws_s3_bucket_versioning" "sftpgo" {
  bucket = aws_s3_bucket.sftpgo.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "sftpgo" {
  bucket = aws_s3_bucket.sftpgo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "sftpgo" {
  bucket = aws_s3_bucket.sftpgo.id
  policy = data.aws_iam_policy_document.sftpgo.json
}

data "aws_iam_policy_document" "sftpgo" {
  version = "2012-10-17"

  statement {
    sid = "S3DenyDeleteBucketAll"

    actions = [
      "s3:DeleteBucket",
    ]

    effect = "Deny"

    principals {
      type = "*"

      identifiers = [
        "*",
      ]
    }

    resources = [
      aws_s3_bucket.sftpgo.arn,
    ]
  }

  statement {
    sid = "S3AllowReadWrite"

    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.sftpgo.arn,
      ]
    }

    resources = [
      aws_s3_bucket.sftpgo.arn,
      "${aws_s3_bucket.sftpgo.arn}/*",
    ]
  }
}
